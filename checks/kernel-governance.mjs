// checks/kernel-governance.mjs asserts that two approving reviews are
// actually required on the frozen core (trust-kernel/01, decision 019).
//
// The point of this check is the distinction decision 019 drew: CODEOWNERS
// REQUESTS reviewers, a host rule REQUIRES them. A repo with a CODEOWNERS
// entry and no host rule looks governed and is not, and a synthetic pull
// request in local CI cannot tell the difference. So this check does two
// separate things and reports them separately:
//
//   1. The file half. .github/CODEOWNERS covers core/kernel/ with an owner.
//   2. The host half. The host is asked what actually protects the default
//      branch, and the answer must require at least two approving reviews
//      and code-owner review.
//
// The host has two mechanisms and either one governs, so either one passes:
//
//   * A repository ruleset, the host's current mechanism. Read through
//     `repos/{owner}/{repo}/rules/branches/{branch}`, which returns the
//     rules in force on that branch from every ruleset targeting it,
//     repository and organization alike. It answers for a token with
//     ordinary read access, which is why this check can run in CI.
//   * Classic branch protection, the older mechanism. Read through
//     `repos/{owner}/{repo}/branches/{branch}/protection`, which needs
//     repository-admin credentials and 404s without them. A 404 is
//     therefore ambiguous between absent and unreadable, and is reported as
//     one input rather than as the answer.
//
// Wired into CI as its own job (.github/workflows/ci.yml) and into the
// all-green fan-in, so it blocks a merge. It is deliberately not in
// `make check`, whose whole pipeline runs against local containers with no
// credentials; a host query there would fail for every developer who has
// not authenticated. `make kernel-governance` is the local entry point.
//
// Usage: node checks/kernel-governance.mjs [owner/repo] [canned-answer-dir]
//
// The second argument replaces the host query with canned answers on disk
// (repo.json, rules.json, protection.json; a missing file models an answer
// the host refuses). It is how `make check-red` proves both verdicts fire,
// including the governed one, which no real query can demonstrate while
// the rule does not exist. Same convention as checks/spine-schema.mjs,
// which takes fixture paths positionally for the same reason.
//
// Needs the gh CLI, authenticated with read access, unless canned answers
// are given. No database.

import { existsSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { join } from "node:path";

const REPOSITORY = process.argv[2] ?? "hiregrain/identity";
const CANNED = process.argv[3];
const CODEOWNERS = ".github/CODEOWNERS";
const GOVERNED_PATH = "/core/kernel/";
const REQUIRED_APPROVALS = 2;

const failures = [];

// 1. The file half.
const codeowners = readFileSync(CODEOWNERS, "utf8");
const entry = codeowners
  .split("\n")
  .map((line) => line.replace(/#.*$/, "").trim())
  .find((line) => line.startsWith(`${GOVERNED_PATH} `));
if (entry === undefined) {
  failures.push(`${CODEOWNERS}: no entry covers ${GOVERNED_PATH}`);
} else if (!/@[\w-]/.test(entry)) {
  failures.push(`${CODEOWNERS}: the ${GOVERNED_PATH} entry names no owner`);
} else {
  console.log(`kernel-governance: ${CODEOWNERS} covers ${GOVERNED_PATH}`);
}

// 2. The host half.
const branch = hostAnswer("repo", [
  `repos/${REPOSITORY}`,
  "--jq",
  ".default_branch",
]);
if (branch.error !== undefined) {
  failures.push(`host: cannot read ${REPOSITORY}: ${branch.error}`);
} else {
  const target = `${REPOSITORY}@${branch.value}`;
  const ruleset = rulesetVerdict(REPOSITORY, branch.value);
  const classic = classicVerdict(REPOSITORY, branch.value);
  const governed = ruleset.governed
    ? ruleset
    : classic.governed
      ? classic
      : null;

  if (governed !== null) {
    console.log(`kernel-governance: ${target} is governed. ${governed.reason}`);
  } else {
    failures.push(
      `host: ${target} does not require ${REQUIRED_APPROVALS} approving reviews with code-owner review. ` +
        `ruleset: ${ruleset.reason}; classic protection: ${classic.reason}. ` +
        `The frozen core is ungoverned until such a rule exists, and creating it is a repository-admin act.`,
    );
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log("kernel-governance: the frozen core is governed by a host rule");

// rulesetVerdict reads the rules in force on the branch. The endpoint
// returns one entry per rule from every ruleset that targets the branch,
// so the two requirements can arrive from two different rulesets and both
// still be in force; they are looked for independently for that reason.
function rulesetVerdict(repository, branch) {
  const rules = hostAnswer("rules", [
    `repos/${repository}/rules/branches/${encodeURIComponent(branch)}`,
  ]);
  if (rules.error !== undefined) {
    return { governed: false, reason: `not readable (${rules.error})` };
  }
  if (!Array.isArray(rules.value)) {
    return { governed: false, reason: "the host returned no rule list" };
  }

  const pullRequestRules = rules.value.filter(
    (rule) => rule?.type === "pull_request",
  );
  if (pullRequestRules.length === 0) {
    return {
      governed: false,
      reason: `no pull_request rule in force (${rules.value.length} rule(s) on the branch)`,
    };
  }

  const approvals = Math.max(
    ...pullRequestRules.map(
      (rule) => rule.parameters?.required_approving_review_count ?? 0,
    ),
  );
  const codeOwners = pullRequestRules.some(
    (rule) => rule.parameters?.require_code_owner_review === true,
  );
  return verdict(approvals, codeOwners, "a ruleset");
}

function classicVerdict(repository, branch) {
  const protection = hostAnswer("protection", [
    `repos/${repository}/branches/${encodeURIComponent(branch)}/protection`,
  ]);
  if (protection.error !== undefined) {
    // Ambiguous on its own: absent, or present and unreadable by a
    // non-admin token. Said as what it is rather than resolved.
    return {
      governed: false,
      reason: `absent, or unreadable without repository-admin credentials (${protection.error})`,
    };
  }
  const reviews = protection.value?.required_pull_request_reviews;
  return verdict(
    reviews?.required_approving_review_count ?? 0,
    reviews?.require_code_owner_reviews === true,
    "classic branch protection",
  );
}

function verdict(approvals, codeOwners, mechanism) {
  if (approvals < REQUIRED_APPROVALS) {
    return {
      governed: false,
      reason: `${mechanism} requires ${approvals} approving review(s)`,
    };
  }
  if (!codeOwners) {
    return {
      governed: false,
      reason: `${mechanism} requires ${approvals} approving reviews but not code-owner review, so ${CODEOWNERS} only requests one`,
    };
  }
  return {
    governed: true,
    reason: `${mechanism} requires ${approvals} approving reviews including a code owner`,
  };
}

// hostAnswer returns { value } or { error }. Canned answers come from
// disk when a directory was given; otherwise the host is queried.
function hostAnswer(name, args) {
  if (CANNED !== undefined) {
    const path = join(CANNED, `${name}.json`);
    if (!existsSync(path))
      return { error: `canned answer ${name}.json absent` };
    return { value: JSON.parse(readFileSync(path, "utf8")) };
  }

  const result = spawnSync("gh", ["api", ...args], { encoding: "utf8" });
  if (result.error) return { error: String(result.error) };
  if (result.status !== 0) {
    return { error: (result.stderr || result.stdout).trim().split("\n")[0] };
  }
  const output = result.stdout.trim();
  try {
    return { value: JSON.parse(output) };
  } catch {
    return { value: output };
  }
}
