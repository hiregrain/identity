// checks/serving-credentials.mjs asserts no serving process holds owner or
// migration credentials (foundation/03, decision 017).
//
// This repo has no server yet, so "serving process" is defined here,
// concretely, ahead of the first one: a serving process is any process
// whose code lives in the runtime trees, `surfaces/` and `core/`,
// excluding generated types (`core/gen/`) and Go test files. Everything
// such code may hold is the application-role connection (`identity_app`,
// migration 0002). The owner/migration credential is the compose
// `identity` user (docker-compose.yml); it belongs exclusively to
// migration and verification tooling (db/migrate.mjs, db/typegen.mjs,
// the Makefile's db targets, test/append-only.test.mjs), none of which
// live in a runtime tree.
//
// What this check is, exactly: a lexical lint. It scans every file under
// the runtime trees for the literal owner-credential shapes listed below
// and fails on any hit. That catches the ordinary failure, a hardcoded
// owner DSN or `-U identity` in serving code, and nothing subtler: a
// dynamically constructed DSN, or credentials fetched from an
// environment this lint cannot see, pass it. The real enforcement layer
// is the database-side role restriction: whatever credential a serving
// process manages to hold, the application role it is supposed to run as
// cannot UPDATE or DELETE (migration 0002, proven by
// test/append-only.test.mjs, which also proves identity_app cannot
// escalate to the owner). This lint exists to make the ordinary failure
// loud early, not to be the boundary. Red path: `make check-red` points
// it at a planted fixture and asserts exit 1.
//
// Usage: node checks/serving-credentials.mjs [rootDir]
//   rootDir defaults to the repo root; the fixture red path passes
//   test/fixtures/redpath/serving, which contains its own runtime trees.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const root = process.argv[2] ?? ".";
const RUNTIME_TREES = ["surfaces", "core"];

// Owner-credential shapes. `identity` followed by `_` (as in
// identity_app) is not the owner credential, hence the lookaheads.
const OWNER_CREDENTIAL_PATTERNS = [
  {
    pattern: /postgres(?:ql)?:\/\/identity(?![\w])[^\s"'`]*/g,
    what: "owner DSN",
  },
  { pattern: /\buser=identity(?![\w])/g, what: "owner user= parameter" },
  { pattern: /-U\s+identity(?![\w])/g, what: "psql -U owner flag" },
  {
    pattern: /\bPGUSER\s*[:=]\s*["']?identity(?![\w])/g,
    what: "PGUSER owner setting",
  },
  { pattern: /\bPOSTGRES_PASSWORD\b/g, what: "superuser password variable" },
];

const skipped = new Set(["gen", "node_modules"]);
let filesScanned = 0;
let violations = 0;

for (const tree of RUNTIME_TREES) {
  const dir = join(root, tree);
  if (!existsSync(dir) || !statSync(dir).isDirectory()) continue;
  walk(dir);
}

if (violations > 0) {
  console.error(
    `serving-credentials: ${violations} owner-credential reference(s) in ` +
      `runtime trees; serving processes hold only the application role ` +
      `(migration 0002-roles-and-default-privileges)`,
  );
  process.exit(1);
}

console.log(
  `serving-credentials: ${filesScanned} runtime-tree file(s) scanned, no ` +
    `owner or migration credential present`,
);

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || skipped.has(entry.name)) continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(path);
      continue;
    }
    if (!entry.isFile() || entry.name.endsWith("_test.go")) continue;
    filesScanned += 1;
    const content = readFileSync(path, "utf8");
    for (const { pattern, what } of OWNER_CREDENTIAL_PATTERNS) {
      pattern.lastIndex = 0;
      const match = pattern.exec(content);
      if (match) {
        const line = content.slice(0, match.index).split("\n").length;
        console.error(
          `serving-credentials: ${path}:${line}: ${what} (${match[0].trim()})`,
        );
        violations += 1;
      }
    }
  }
}
