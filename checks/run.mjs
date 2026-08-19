// checks/run.mjs — the repo verifies itself, then the queue is printed
// (foundation/06). Runs every check, then prints the workable frontier;
// `node checks/run.mjs` is the only source of what is workable
// (plans/ORDER.md's executive loop reads this and nothing else).
//
// Two groups, split so foundation/01's CI can run the first before any
// database boots:
//
//   --metadata  file checks, no database required
//   --schema    live-schema checks, both plane databases up and migrated
//
// With no flag, both groups run. Every check runs even after a failure —
// the executive wants the whole picture, not the first stumble — and the
// frontier prints only when the metadata group is green, because a
// frontier computed over an invalid graph is noise. Exempt from the plan
// gate: this file verifies the repo, not the product (CLAUDE.md).
//
// Usage: node checks/run.mjs [--metadata|--schema]
// Dependency-free Node.

import { spawnSync } from "node:child_process";
import { join } from "node:path";
import { analyze, printFrontier } from "./plan-graph.mjs";

const METADATA = [
  "frontmatter",
  "plan-graph",
  "decisions-index",
  "migration-numbers",
  "migration-order",
  "verbatim-copies",
  "counts",
  "serving-credentials",
  "cross-schema-queries",
  "cross-plane-constructs",
];
const SCHEMA = ["spine-schema", "payload-residency", "scored-columns"];

const flag = process.argv[2];
let groups;
if (flag === undefined) groups = [...METADATA, ...SCHEMA];
else if (flag === "--metadata") groups = METADATA;
else if (flag === "--schema") groups = SCHEMA;
else {
  console.error(`run: unknown flag "${flag}" — use --metadata or --schema`);
  process.exit(2);
}

const failed = [];
for (const check of groups) {
  const args = [join(import.meta.dirname, `${check}.mjs`)];
  if (check === "plan-graph") args.push("--no-frontier");
  const result = spawnSync(process.execPath, args, { stdio: "inherit" });
  if (result.status !== 0) failed.push(check);
}

if (failed.length > 0) {
  console.error(`run: FAILED — ${failed.join(", ")}`);
  process.exit(1);
}
console.log(`run: every check green (${groups.join(", ")})`);

if (flag !== "--schema") {
  printFrontier(analyze("plans"));
}
