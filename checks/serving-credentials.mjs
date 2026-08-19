// checks/serving-credentials.mjs — no serving process holds owner or
// migration credentials (foundation/03, decision 017).
//
// This repo has no server yet, so "serving process" is defined here,
// concretely, ahead of the first one: a serving process is any process
// whose code lives in the runtime trees — `surfaces/` and `core/`,
// excluding generated types (`core/gen/`) and Go test files. Everything
// such code may hold is the application-role connection (`identity_app`,
// migration 0002). The owner/migration credential is the compose
// `identity` user (docker-compose.yml); it belongs exclusively to
// migration and verification tooling (db/migrate.mjs, db/typegen.mjs,
// the Makefile's db targets, test/append-only.test.mjs), none of which
// live in a runtime tree.
//
// The check scans every file under the runtime trees for owner-credential
// tokens and fails on the first hit. Today the trees hold no serving code,
// so the scan passes while being shaped to catch the first violation: the
// first serving process that embeds or reads the owner credential fails
// CI here. Red path: `make check-red` points this check at a planted
// fixture and asserts exit 1.
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
