// Frontmatter well-formedness for plan files: every file inside a layer
// directory carries a parseable frontmatter block with the fields and
// vocabulary plans/ORDER.md defines. This is the minimal check
// foundation/01's CI metadata stage needs; the full validation suite is
// foundation/06's port and extends this file.
//
// Usage: node checks/frontmatter.mjs [plans-root]
// Top-level files (ORDER.md, t1-spike.md) are not layers and are skipped.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const STATUSES = new Set([
  "draft",
  "ready",
  "in_progress",
  "done",
  "abandoned",
]);
const TYPES = new Set(["layer", "task"]);
const COMMON_FIELDS = [
  "id",
  "type",
  "status",
  "depends_on",
  "evidence",
  "verified_by",
];
const TASK_FIELDS = ["layer", "satisfies"];

const root = process.argv[2] ?? "plans";
const failures = [];

for (const entry of readdirSync(root)) {
  const dir = join(root, entry);
  if (!statSync(dir).isDirectory()) continue;
  for (const name of readdirSync(dir)) {
    if (name.endsWith(".md")) checkFile(join(dir, name));
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log("frontmatter: every layer-directory plan file is well-formed");

function checkFile(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  if (lines[0] !== "---") {
    failures.push(`${path}: does not open with a frontmatter block`);
    return;
  }
  const end = lines.indexOf("---", 1);
  if (end === -1) {
    failures.push(`${path}: frontmatter block never closes`);
    return;
  }

  const fields = new Map();
  for (const line of lines.slice(1, end)) {
    const match = /^([a-z_]+):(.*)$/.exec(line);
    if (match) fields.set(match[1], match[2].trim());
  }

  for (const field of COMMON_FIELDS) {
    if (!fields.has(field)) failures.push(`${path}: missing field ${field}`);
  }
  const type = fields.get("type");
  if (type !== undefined && !TYPES.has(type)) {
    failures.push(`${path}: type "${type}" is not layer or task`);
  }
  const status = fields.get("status");
  if (status !== undefined && !STATUSES.has(status)) {
    failures.push(
      `${path}: status "${status}" is outside the ORDER.md vocabulary`,
    );
  }
  if (type === "task") {
    for (const field of TASK_FIELDS) {
      if (!fields.has(field))
        failures.push(`${path}: task missing field ${field}`);
    }
  }
}
