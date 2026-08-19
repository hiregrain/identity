// Frontmatter validation for plan files: every file inside a layer
// directory carries a parseable frontmatter block with exactly the fields
// and vocabulary plans/ORDER.md defines. foundation/01 landed the
// well-formedness core; this is foundation/06's full validation:
//
//   * field allow-list per type — an unknown field is vocabulary drift,
//     not an extension point;
//   * status enum (draft/ready/in_progress/done/abandoned — blocked is
//     computed, never stored);
//   * evidence entries as `<kind>:<ref>`, kind in test|diff|log|review;
//   * verified_by as null or `<verifier>@<YYYY-MM-DD>`;
//   * `status: done` is not typeable without evidence and verified_by —
//     a completion claim with no linked evidence does not stick;
//   * ids derived, never invented: a layer's id is its directory, a
//     task's id is `<dir>/<NN>` matching its filename;
//   * depends_on grammar: tasks depend on `<layer>/<NN>`, layers on
//     layer names (referent existence is checks/plan-graph.mjs's job).
//
// Usage: node checks/frontmatter.mjs [plans-root]
// Top-level files (ORDER.md, t1-spike.md) are not layers and are skipped.
// Dependency-free Node, no database.

import { readPlanFiles } from "./lib/plan-files.mjs";

const STATUSES = new Set([
  "draft",
  "ready",
  "in_progress",
  "done",
  "abandoned",
]);
const TYPES = new Set(["layer", "task"]);
const MILESTONES = new Set(["v1", "first-product"]);
const COMMON_FIELDS = [
  "id",
  "type",
  "status",
  "depends_on",
  "evidence",
  "verified_by",
];
const TASK_FIELDS = ["layer", "satisfies"];
// The full vocabulary per type (plans/ORDER.md, "Frontmatter, and what
// each field is for"). `soft_blocks` predates this check on main
// (plans/app-shell/LAYER.md) and is admitted as the inverse notation of
// soft_depends_on; ORDER.md does not list it — flagged at authoring.
const LAYER_ALLOWED = new Set([
  ...COMMON_FIELDS,
  "binds",
  "milestone",
  "soft_depends_on",
  "soft_blocks",
  "gated_criteria",
  "discharged_at_layer",
]);
const TASK_ALLOWED = new Set([
  ...COMMON_FIELDS,
  ...TASK_FIELDS,
  "binds",
  "migrations",
]);

const EVIDENCE = /^(test|diff|log|review):\S.*$/;
const VERIFIED_BY = /^[A-Za-z0-9._-]+@\d{4}-\d{2}-\d{2}$/;
const TASK_REF = /^[a-z0-9-]+\/\d{2}$/;
const LAYER_REF = /^[a-z0-9-]+$/;

const root = process.argv[2] ?? "plans";
const failures = [];

for (const file of readPlanFiles(root)) {
  const { path, dir, name, fields, errors } = file;
  for (const error of errors) failures.push(`${path}: ${error}`);
  if (!fields.has("type")) {
    failures.push(`${path}: missing field type`);
    continue;
  }

  const type = fields.get("type").raw;
  if (!TYPES.has(type)) {
    failures.push(`${path}: type "${type}" is not layer or task`);
    continue;
  }

  const allowed = type === "layer" ? LAYER_ALLOWED : TASK_ALLOWED;
  for (const key of fields.keys()) {
    if (!allowed.has(key)) {
      failures.push(
        `${path}: field "${key}" is outside the ORDER.md vocabulary for a ${type}`,
      );
    }
  }
  const required =
    type === "layer" ? COMMON_FIELDS : [...COMMON_FIELDS, ...TASK_FIELDS];
  for (const field of required) {
    if (!fields.has(field)) {
      failures.push(`${path}: ${type} missing field ${field}`);
    }
  }

  // --- id and layer are derived from the path, never invented ---------
  const id = fields.get("id")?.raw;
  if (id !== undefined) {
    const expected = type === "layer" ? dir : `${dir}/${name.slice(0, 2)}`;
    const plausible =
      type === "layer" || /^\d{2}-.*\.md$/.test(name) ? expected : null;
    if (plausible === null) {
      failures.push(
        `${path}: task filename does not match NN-<slug>.md, so its id ` +
          `cannot be derived`,
      );
    } else if (id !== expected) {
      failures.push(
        `${path}: id "${id}" does not match its path-derived id ` +
          `"${expected}" — names are derived, never invented (ORDER.md)`,
      );
    }
  }
  if (type === "task") {
    const layer = fields.get("layer")?.raw;
    if (layer !== undefined && layer !== dir) {
      failures.push(
        `${path}: layer "${layer}" does not match its directory "${dir}"`,
      );
    }
  }

  // --- enums ----------------------------------------------------------
  const status = fields.get("status")?.raw;
  if (status !== undefined && !STATUSES.has(status)) {
    failures.push(
      `${path}: status "${status}" is outside the ORDER.md vocabulary ` +
        `(blocked is computed, never stored)`,
    );
  }
  const milestone = fields.get("milestone")?.raw;
  if (milestone !== undefined && !MILESTONES.has(milestone)) {
    failures.push(
      `${path}: milestone "${milestone}" is not a milestone ORDER.md defines`,
    );
  }

  // --- list-valued fields ---------------------------------------------
  const refPattern = type === "layer" ? LAYER_REF : TASK_REF;
  const refShape = type === "layer" ? "<layer>" : "<layer>/<NN>";
  for (const key of ["depends_on", "soft_depends_on", "soft_blocks"]) {
    for (const ref of requireList(path, fields, key) ?? []) {
      if (!refPattern.test(ref)) {
        failures.push(
          `${path}: ${key} entry "${ref}" is not a ${refShape} reference`,
        );
      }
    }
  }
  for (const entry of requireList(path, fields, "satisfies") ?? []) {
    if (!/^\d+$/.test(entry)) {
      failures.push(
        `${path}: satisfies entry "${entry}" is not a criterion number — ` +
          `criteria are identified by position (decision 042)`,
      );
    }
  }
  requireList(path, fields, "migrations");
  requireList(path, fields, "binds");

  // --- evidence and verification --------------------------------------
  const evidence = requireList(path, fields, "evidence");
  for (const entry of evidence ?? []) {
    if (!EVIDENCE.test(entry)) {
      failures.push(
        `${path}: evidence entry "${entry}" is not <kind>:<ref> with kind ` +
          `in test|diff|log|review (ORDER.md)`,
      );
    }
  }
  const verifiedBy = fields.get("verified_by")?.raw;
  if (
    verifiedBy !== undefined &&
    verifiedBy !== "null" &&
    !VERIFIED_BY.test(verifiedBy)
  ) {
    failures.push(
      `${path}: verified_by "${verifiedBy}" is neither null nor ` +
        `<verifier>@<YYYY-MM-DD> (ORDER.md)`,
    );
  }
  if (status === "done") {
    if ((evidence ?? []).length === 0) {
      failures.push(
        `${path}: status done with empty evidence — a completion claim ` +
          `with no linked evidence does not stick (CLAUDE.md)`,
      );
    }
    if (verifiedBy === undefined || verifiedBy === "null") {
      failures.push(
        `${path}: status done with verified_by null — only the ` +
          `verification recorder writes done (ORDER.md)`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  "frontmatter: every layer-directory plan file carries valid fields and vocabulary",
);

// Returns the parsed list for a field, records a failure when the field
// is present but not a list, and null when absent.
function requireList(path, fields, key) {
  const field = fields.get(key);
  if (field === undefined) return null;
  if (field.list === null) {
    failures.push(`${path}: ${key} "${field.raw}" is not a [] list`);
    return null;
  }
  return field.list;
}
