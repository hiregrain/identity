// checks/kernel-budget.mjs holds the frozen core under its line budget
// (trust-kernel/01, decision 019). CI runs it in the metadata group, so an
// overrun blocks a merge rather than being noticed in review.
//
// What is measured, and why it is this and not something else:
//
//   * Scope is the non-test Go files directly in core/kernel. Decision 019
//     names the frozen core as canonicalization, sign/verify, chain
//     append/verify, and tree construction and proofs, and it puts
//     orchestration (schedulers, publishers, reconciliation, per-party
//     root assembly) outside. The package boundary is what makes that
//     split reviewable, so subdirectories are kernel-adjacent by
//     construction and are not counted. Moving code into a subpackage to
//     duck the budget would be a review defect, not a clever fix.
//   * Blank lines and comment lines do not count. The budget bounds what
//     gets two-human review, fuzzing, and formal specs; a comment
//     explaining a contract rule lowers the cost of that review rather
//     than raising it, and a budget that taxed explanation would buy
//     terser code and worse review.
//   * Tests do not count. They are reviewed, but the budget is on the
//     surface a subtle bug can hide in.
//
// Usage: node checks/kernel-budget.mjs [dir] [budget]
// Dependency-free Node, no database.

import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

// Decision 019 fixes the budget at under three thousand lines and records
// why raising it was rejected: strict review over a two-thirds larger
// surface becomes perfunctory, and a budget that moves when it is
// inconvenient is not a budget. Changing this number needs a superseding
// decisions entry, not an edit here.
const DEFAULT_BUDGET = 3000;
const DEFAULT_DIRECTORY = "core/kernel";

const directory = process.argv[2] ?? DEFAULT_DIRECTORY;
const budget = Number(process.argv[3] ?? DEFAULT_BUDGET);

let total = 0;
const perFile = [];
for (const entry of readdirSync(directory, { withFileTypes: true })) {
  if (!entry.isFile()) continue;
  if (!entry.name.endsWith(".go") || entry.name.endsWith("_test.go")) continue;
  const counted = countLines(join(directory, entry.name));
  perFile.push([entry.name, counted]);
  total += counted;
}

perFile.sort(([left], [right]) => (left < right ? -1 : 1));
for (const [name, counted] of perFile) {
  console.log(`  ${String(counted).padStart(5)}  ${name}`);
}

if (total >= budget) {
  console.error(
    `FAIL kernel-budget: ${directory} is ${total} lines, the budget is under ${budget}`,
  );
  process.exit(1);
}
console.log(
  `kernel-budget: ${directory} is ${total} lines against a budget of under ${budget}`,
);

// countLines counts lines that are neither blank nor comment-only. A line
// inside a block comment is a comment line; a line with code before a
// trailing comment is code.
function countLines(path) {
  let counted = 0;
  let inBlockComment = false;

  for (const rawLine of readFileSync(path, "utf8").split("\n")) {
    let line = rawLine.trim();
    if (inBlockComment) {
      const end = line.indexOf("*/");
      if (end === -1) continue;
      inBlockComment = false;
      line = line.slice(end + 2).trim();
    }
    while (line.startsWith("/*")) {
      const end = line.indexOf("*/", 2);
      if (end === -1) {
        inBlockComment = true;
        line = "";
        break;
      }
      line = (line.slice(0, 0) + line.slice(end + 2)).trim();
    }
    if (line === "" || line.startsWith("//")) continue;
    counted += 1;
  }
  return counted;
}
