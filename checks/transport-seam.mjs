// checks/transport-seam.mjs asserts core/transport is the one package
// that constructs a database invocation (trust-kernel/08, decision
// 065): every other SQL path in the repo reaches a plane through
// Query or Tx, never through docker, psql, or a database/sql driver
// directly. That is what lets the eventual Postgres-driver decision
// change one file (plans/ORDER.md's decision gates) instead of every
// call site's own quoting and row-parsing copy.
//
// This is a lexical lint over every Go file in the repo, core/transport
// itself and generated code (core/gen/) excluded. There is no
// test-file exemption: a test that shells out to docker or psql
// duplicates the seam exactly as much as production code would, and
// decision 065 named "envelope's db test drops its duplicate renderer"
// as part of the same discipline. What it catches: `exec.Command`
// whose first argument is the literal "docker" or "psql" (the shape
// every prior hand-rolled copy took), and an import of "database/sql"
// or a known Postgres driver module. What it cannot catch: a
// dynamically constructed command name. That gap is accepted the same
// way checks/serving-credentials.mjs accepts its own: the loud, early
// failure on the ordinary case, not the only enforcement layer.
//
// Usage: node checks/transport-seam.mjs [rootDir]
//   rootDir defaults to the repo root; the fixture red path passes
//   test/fixtures/redpath/transport, a synthetic Go tree.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const root = process.argv[2] ?? ".";
const SCAN_TREES = ["core"];
const EXEMPT_DIRS = new Set(["transport", "gen"]);

const EXEC_PATTERNS = [
  {
    pattern: /exec\.Command\(\s*"docker"/g,
    what: 'exec.Command reaching "docker"',
  },
  {
    pattern: /exec\.Command\(\s*"psql"/g,
    what: 'exec.Command reaching "psql"',
  },
];

const IMPORT_PATTERNS = [
  { pattern: /"database\/sql"/g, what: "database/sql import" },
  { pattern: /"github\.com\/lib\/pq[^"]*"/g, what: "lib/pq driver import" },
  { pattern: /"github\.com\/jackc\/pgx[^"]*"/g, what: "pgx driver import" },
];

let filesScanned = 0;
let violations = 0;

for (const tree of SCAN_TREES) {
  const dir = join(root, tree);
  if (!existsSync(dir) || !statSync(dir).isDirectory()) continue;
  walk(dir, true);
}

if (violations > 0) {
  console.error(
    `transport-seam: ${violations} database invocation(s) outside core/transport; ` +
      `every SQL path reaches a plane through Query or Tx (trust-kernel/08, decision 065)`,
  );
  process.exit(1);
}

console.log(
  `transport-seam: ${filesScanned} Go file(s) scanned, no database invocation outside core/transport`,
);

function walk(dir, atTreeRoot) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    if (atTreeRoot && EXEMPT_DIRS.has(entry.name)) continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(path, false);
      continue;
    }
    if (!entry.isFile() || !entry.name.endsWith(".go")) continue;
    filesScanned += 1;
    const content = readFileSync(path, "utf8");
    for (const { pattern, what } of [...EXEC_PATTERNS, ...IMPORT_PATTERNS]) {
      pattern.lastIndex = 0;
      let match;
      while ((match = pattern.exec(content)) !== null) {
        const line = content.slice(0, match.index).split("\n").length;
        console.error(
          `transport-seam: ${path}:${line}: ${what} (${match[0].trim()})`,
        );
        violations += 1;
      }
    }
  }
}
