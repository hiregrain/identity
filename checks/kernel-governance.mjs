// checks/kernel-governance.mjs asserts that two approving reviews are
// actually required on the frozen core (trust-kernel/01, decision 019).
//
// The point of this check is the distinction decision 019 drew: CODEOWNERS
// REQUESTS reviewers, branch protection REQUIRES them. A repo with a
// CODEOWNERS entry and no host rule looks governed and is not, and a
// synthetic pull request in local CI cannot tell the difference. So this
// check does two separate things and reports them separately:
//
//   1. The file half. .github/CODEOWNERS covers core/kernel/ with an owner.
//   2. The host half. The repository host is queried for the branch
//      protection on the default branch, and the answer must require at
//      least two approving reviews and code-owner review.
//
// It is deliberately NOT in `make check` or in CI. Reading branch
// protection needs repository-admin credentials, which neither the CI
// token (contents: read) nor the token this repo's tooling runs under
// carries, so wiring it into the blocking pipeline would make every pull
// request fail for a reason no pull request can fix. It is run by whoever
// holds admin on the repository. See the raise recorded on
// plans/trust-kernel/01: the host policy does not exist yet and only the
// founder can create it.
//
// Usage: node checks/kernel-governance.mjs [owner/repo]
// Needs the gh CLI, authenticated as a repository admin. No database.

import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";

const REPOSITORY = process.argv[2] ?? "hiregrain/identity";
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

// 2. The host half. A missing rule and an unreadable one are different
// answers and are reported as different answers: the first is a governance
// gap, the second is a credentials problem, and treating them alike is how
// an ungoverned repo comes to look governed.
const branch = hostJSON(["repos/" + REPOSITORY, "--jq", ".default_branch"]);
if (branch.error) {
  failures.push(`host: cannot read ${REPOSITORY}: ${branch.error}`);
} else {
  const protection = hostJSON([
    `repos/${REPOSITORY}/branches/${branch.value}/protection`,
  ]);
  if (protection.error) {
    failures.push(
      `host: no readable branch protection on ${REPOSITORY}@${branch.value}: ${protection.error}. ` +
        `Either the rule does not exist, or these credentials are not a repository admin. ` +
        `The frozen core is ungoverned until a rule requiring ${REQUIRED_APPROVALS} approving reviews and code-owner review exists.`,
    );
  } else {
    const reviews = protection.value?.required_pull_request_reviews;
    const approvals = reviews?.required_approving_review_count ?? 0;
    if (approvals < REQUIRED_APPROVALS) {
      failures.push(
        `host: ${REPOSITORY}@${branch.value} requires ${approvals} approving review(s), the frozen core needs ${REQUIRED_APPROVALS}`,
      );
    }
    if (reviews?.require_code_owner_reviews !== true) {
      failures.push(
        `host: ${REPOSITORY}@${branch.value} does not require code-owner review, so ${CODEOWNERS} only requests one`,
      );
    }
    if (failures.length === 0) {
      console.log(
        `kernel-governance: ${REPOSITORY}@${branch.value} requires ${approvals} approving reviews including a code owner`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log("kernel-governance: the frozen core is governed by a host rule");

function hostJSON(args) {
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
