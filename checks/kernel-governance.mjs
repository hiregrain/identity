// checks/kernel-governance.mjs asserts the host policy that actually
// protects the frozen core (trust-kernel/01, decision 087).
//
// What 087 ruled, and why this check changed shape. Decision 019 gave the
// frozen core two-human review and trust-kernel/01 made that a
// host-enforced required-approval rule. The loop then established the fact
// on the ground: every pull request here is authored under the founder's
// own account, and the host forbids approving your own pull request, so a
// required-approval rule of any count is unsatisfiable by the only human in
// the repository. A rule bypassed on every merge enforces nothing and
// claims otherwise, which is worse than its absence.
//
// So the check asserts what is true and is enforced:
//
//   1. The host blocks force pushes on the default branch. This is the rule
//      with teeth: the decisions log is append-only and every verification
//      record cites SHAs, so a rewritten default branch is the one git
//      operation that silently invalidates the repository's own evidence.
//   2. The host blocks deletion of the default branch.
//   3. .github/CODEOWNERS carries the kernel paths, as the reviewer-request
//      seed. It requests reviewers and does not require them, which is why
//      it is checked separately from the host and never instead of it.
//
// Kernel review itself is enforced by the loop's gates now: clean-context
// verification, a code review pass, and the founder's read at merge. That
// is decision 019's intent carried by the process that runs rather than by
// a setting that would be theatre.
//
// Each missing piece is reported on its own line. An aggregate "not
// governed" tells a reader nothing about which half to go fix.
//
// Usage: node checks/kernel-governance.mjs [owner/repo] [canned-answer-dir]
//
// The second argument replaces both halves with canned answers on disk
// (repo.json, rules.json, and a CODEOWNERS stand-in; a missing file models
// an answer that is not there). It is how `make check-red` proves every
// verdict fires, including the governed one, and it is the only way to
// exercise the missing-CODEOWNERS branch without deleting the real file.
// Same convention as checks/spine-schema.mjs, which takes fixture paths
// positionally for the same reason.
//
// Needs the gh CLI, authenticated with read access, unless canned answers
// are given. No database.

import { existsSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { join } from "node:path";

const REPOSITORY = process.argv[2] ?? "hiregrain/identity";
const CANNED = process.argv[3];
const CODEOWNERS = ".github/CODEOWNERS";
const GOVERNED_PATHS = ["/core/kernel/", "/core/cmd/vectors/", "/contract/"];

// The rule types decision 087 put in force, named as the host names them.
const REQUIRED_RULES = [
  ["non_fast_forward", "force pushes are not blocked"],
  ["deletion", "the branch can be deleted"],
];

const failures = [];

// 1. The file half.
const codeownersPath =
  CANNED === undefined ? CODEOWNERS : join(CANNED, "CODEOWNERS");
if (!existsSync(codeownersPath)) {
  failures.push(
    `${codeownersPath}: absent, so no reviewer is requested at all`,
  );
} else {
  const owned = readFileSync(codeownersPath, "utf8")
    .split("\n")
    .map((line) => line.replace(/#.*$/, "").trim())
    .filter((line) => line !== "" && /@[\w-]/.test(line))
    .map((line) => line.split(/\s+/)[0]);

  const uncovered = GOVERNED_PATHS.filter((path) => !owned.includes(path));
  for (const path of uncovered) {
    failures.push(`${codeownersPath}: no entry with an owner covers ${path}`);
  }
  if (uncovered.length === 0) {
    console.log(
      `kernel-governance: ${codeownersPath} covers ${GOVERNED_PATHS.join(", ")}`,
    );
  }
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
  const rules = hostAnswer("rules", [
    `repos/${REPOSITORY}/rules/branches/${encodeURIComponent(branch.value)}`,
  ]);

  if (rules.error !== undefined) {
    failures.push(
      `host: cannot read the rules in force on ${target}: ${rules.error}`,
    );
  } else if (!Array.isArray(rules.value)) {
    failures.push(`host: ${target} returned no rule list`);
  } else {
    const inForce = new Set(
      rules.value
        .map((rule) => rule?.type)
        .filter((type) => type !== undefined),
    );
    const missing = REQUIRED_RULES.filter(([type]) => !inForce.has(type));
    for (const [type, what] of missing) {
      failures.push(
        `host: ${target} has no ${type} rule in force, so ${what}. ` +
          `Decision 087 requires it; ${rules.value.length} rule(s) are in force.`,
      );
    }
    if (missing.length === 0) {
      console.log(
        `kernel-governance: ${target} blocks force pushes and branch deletion (${inForce.size} rule type(s) in force)`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  "kernel-governance: the host enforces decision 087's policy on the frozen core",
);

// approvalVerdict is decision 087's dormant trigger, kept rather than
// deleted. 087 superseded 019's ENFORCEMENT and not its intent, and it
// wrote the condition for the reversal down: the day a second maintainer
// holds write access, required approvals return to the host settings and
// this check asserts them again. Deleting the code would mean rediscovering
// which host fields carry the answer, and both mechanisms have to be read
// because either can carry the rule.
//
// It is not called. A required-approval rule today is unsatisfiable by the
// only human here, since the host forbids approving your own pull request,
// so asserting one would fail every run for a reason no pull request can
// fix. To revive: call it alongside the REQUIRED_RULES loop above.
export function approvalVerdict(rules, protection, requiredApprovals = 2) {
  const pullRequestRules = (Array.isArray(rules) ? rules : []).filter(
    (rule) => rule?.type === "pull_request",
  );
  const fromRuleset = {
    approvals: Math.max(
      0,
      ...pullRequestRules.map(
        (rule) => rule.parameters?.required_approving_review_count ?? 0,
      ),
    ),
    codeOwners: pullRequestRules.some(
      (rule) => rule.parameters?.require_code_owner_review === true,
    ),
  };
  const reviews = protection?.required_pull_request_reviews;
  const fromClassic = {
    approvals: reviews?.required_approving_review_count ?? 0,
    codeOwners: reviews?.require_code_owner_reviews === true,
  };

  for (const [mechanism, verdict] of [
    ["a ruleset", fromRuleset],
    ["classic branch protection", fromClassic],
  ]) {
    if (verdict.approvals >= requiredApprovals && verdict.codeOwners) {
      return {
        governed: true,
        reason: `${mechanism} requires ${verdict.approvals} approving reviews including a code owner`,
      };
    }
  }
  return {
    governed: false,
    reason: `no mechanism requires ${requiredApprovals} approving reviews with code-owner review`,
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
