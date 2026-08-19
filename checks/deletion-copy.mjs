// checks/deletion-copy.mjs — the residual-window disclosure check
// (foundation/08, decision 017; layer criterion foundation-6's
// disclosure half).
//
// The residual window between a deletion and the expiry of the last
// backup holding the person is DISCLOSED rather than hidden: the
// worker-facing deletion copy (copy/deletion.md, the canonical text
// every deletion surface renders) states the numbers, and the numbers
// it states are the numbers the retention config enforces
// (db/deletion-policy.json — backup_retention_days, which db/backup.mjs
// enforces, and purge_interval_days, the stated purge schedule). This
// check fails when they drift, in either direction:
//
//   1. Every day count written in the copy ("<number> days" — the
//      grammar the copy's own header commits to) must equal one of the
//      config's values. A number in the copy the config does not
//      enforce is a promise nothing keeps.
//   2. Every config value must appear in the copy at least once. An
//      enforced window the copy does not state is a hidden window,
//      which is the exact thing decision 017 ruled against.
//
// HTML comments in the copy are stripped first — the header is
// maintainer guidance, not worker-facing text.
//
// Usage: node checks/deletion-copy.mjs [copy.md] [policy.json]
//   Defaults: copy/deletion.md, db/deletion-policy.json. File-only, no
//   database; runs in `make metadata`. Red path: `make check-red`
//   points it at a drifted fixture and asserts exit 1.

import { readFileSync } from "node:fs";

const copyFile = process.argv[2] ?? "copy/deletion.md";
const policyFile = process.argv[3] ?? "db/deletion-policy.json";

const failures = [];

const policy = JSON.parse(readFileSync(policyFile, "utf8"));
const enforced = new Map(); // number -> config key(s)
for (const key of ["backup_retention_days", "purge_interval_days"]) {
  const value = policy[key];
  if (!Number.isInteger(value) || value <= 0) {
    console.error(
      `FAIL ${policyFile}: ${key} must be a positive integer, got ${JSON.stringify(value)}`,
    );
    process.exit(1);
  }
  if (!enforced.has(value)) enforced.set(value, []);
  enforced.get(value).push(key);
}

const copy = readFileSync(copyFile, "utf8").replace(/<!--[\s\S]*?-->/g, "");

const stated = [...copy.matchAll(/(\d+)\s+days?\b/g)].map((m) => Number(m[1]));

if (stated.length === 0) {
  failures.push(
    `${copyFile} states no day count at all — the residual window is ` +
      `disclosed in the copy, as "<number> days" (decision 017)`,
  );
}

for (const value of stated) {
  if (!enforced.has(value)) {
    failures.push(
      `${copyFile} states "${value} days" but ${policyFile} enforces ` +
        `${[...enforced.keys()].join(", ")} — a stated window the config ` +
        `does not enforce is a promise nothing keeps`,
    );
  }
}

for (const [value, keys] of enforced) {
  if (!stated.includes(value)) {
    failures.push(
      `${policyFile} enforces ${keys.join(" and ")} = ${value} but ` +
        `${copyFile} never states "${value} days" — an enforced window ` +
        `the copy does not state is a hidden window (decision 017)`,
    );
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}

console.log(
  `deletion-copy: the copy's stated window(s) and the config's enforced ` +
    `window(s) agree (${[...enforced.entries()]
      .map(([value, keys]) => `${keys.join("=")}=${value}`)
      .join(", ")})`,
);
