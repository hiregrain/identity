// checks/cross-schema-queries.mjs is the cross-schema lint (foundation/03,
// decision 017).
//
// Some table pairs must be unlinkable, and "no query joins these" is
// unenforceable by intent alone. Someone will write the join. The
// declared incompatible schema pairs live in
// db/incompatible-schema-pairs.json; this lint fails any file containing
// qualified references to both members of a declared pair. Granularity is
// deliberately per file, stricter than per statement: a file that touches
// both schemas at all is either the forbidden query or close enough to
// one that a human should split it.
//
// Database-side enforcement (no role can read both members) is
// test/append-only.test.mjs's job; this lint catches the query before it
// exists. The declared list is empty until party-registry/04 lands the
// first pair; the mechanism is exercised by `make check-red`, which
// points it at a fixture pair list plus a planted query and asserts
// exit 1.
//
// Usage: node checks/cross-schema-queries.mjs [pairsFile] [scanDir...]
//   Defaults: db/incompatible-schema-pairs.json, scanning the trees where
//   queries can live: db, surfaces, core, checks.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, basename } from "node:path";

const pairsFile = process.argv[2] ?? "db/incompatible-schema-pairs.json";
const scanDirs =
  process.argv.length > 3
    ? process.argv.slice(3)
    : ["db", "surfaces", "core", "checks"];

const pairs = JSON.parse(readFileSync(pairsFile, "utf8")).pairs;
for (const pair of pairs) {
  if (!Array.isArray(pair) || pair.length !== 2) {
    console.error(
      `cross-schema-queries: ${pairsFile}: each pair must be a two-element ` +
        `array of schema names, got ${JSON.stringify(pair)}`,
    );
    process.exit(1);
  }
}

const skipped = new Set(["node_modules", "fixtures"]);
let filesScanned = 0;
let violations = 0;

for (const dir of scanDirs) {
  if (!existsSync(dir) || !statSync(dir).isDirectory()) continue;
  walk(dir);
}

if (violations > 0) {
  console.error(
    `cross-schema-queries: ${violations} file(s) touch both members of a ` +
      `declared incompatible schema pair (decision 017)`,
  );
  process.exit(1);
}

console.log(
  `cross-schema-queries: ${filesScanned} file(s) scanned against ` +
    `${pairs.length} declared pair(s), no query touches both members of one`,
);

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || skipped.has(entry.name)) continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(path);
      continue;
    }
    if (!entry.isFile() || basename(path) === basename(pairsFile)) continue;
    filesScanned += 1;
    if (pairs.length === 0) continue;
    const content = readFileSync(path, "utf8");
    for (const [left, right] of pairs) {
      if (references(content, left) && references(content, right)) {
        console.error(
          `cross-schema-queries: ${path}: references both ${left}.* and ` +
            `${right}.*, a declared incompatible pair`,
        );
        violations += 1;
      }
    }
  }
}

// A qualified reference: the schema name, a dot, an identifier. Matches
// SQL (`schema.table`) and any string literal carrying one in code.
function references(content, schema) {
  return new RegExp(`\\b${schema}\\s*\\.\\s*[\\w"]`, "i").test(content);
}
