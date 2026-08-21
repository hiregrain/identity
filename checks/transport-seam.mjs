// checks/transport-seam.mjs asserts core/transport is the one package
// that constructs a database invocation (trust-kernel/08, decision
// 065): every other SQL path in the repo reaches a plane through
// Query or Tx, never through docker, psql, or a database/sql driver
// directly. That is what lets the eventual Postgres-driver decision
// change one file (plans/ORDER.md's decision gates) instead of every
// call site's own quoting and row-parsing copy.
//
// This is a lexical lint over every Go file in the repo (there is no
// other language a database invocation could hide in today), walked
// from the repo root, core/transport itself and generated code
// (core/gen/) excluded by path, not by directory name, so an unrelated
// directory that happened to be named "transport" or "gen" elsewhere
// in the tree would still be scanned. test/ is pruned wherever it
// appears, the same exclusion every check's red-path fixtures get, so
// a deliberately planted violation fixture does not fail the check
// that exists to catch planted violations. There is no exemption for a
// real Go test file living where production code lives (core/, not
// test/): a _test.go that shells out to docker or psql duplicates the
// seam exactly as much as production code would, and decision 065
// named "envelope's db test drops its duplicate renderer" as part of
// the same discipline. What it catches: `exec.Command` whose first
// argument is the literal "docker" or "psql" (the shape every prior
// hand-rolled copy took), and an import of "database/sql" or a known Postgres
// driver module. What it cannot catch: a dynamically constructed
// command name. That gap is accepted the same way
// checks/serving-credentials.mjs accepts its own: the loud, early
// failure on the ordinary case, not the only enforcement layer.
//
// Usage: node checks/transport-seam.mjs [rootDir]
//   rootDir defaults to the repo root; the fixture red path passes
//   test/fixtures/redpath/transport, a synthetic Go tree.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, relative, sep } from "node:path";

const root = process.argv[2] ?? ".";

// Paths (repo-relative, posix-separated) excluded from the scan: the
// transport package itself and its generated code.
const EXEMPT_PATHS = new Set(["core/transport", "core/gen"]);

// Directory names excluded at any depth: version control, dependency
// trees no Go source lives in, and test/, which holds this check's own
// red-path fixture (a deliberately planted violation) alongside every
// other check's, the same exclusion counts.mjs makes for the same
// reason. The red-path invocation passes a path inside test/ directly
// as rootDir, which is scanned normally: this exemption only prunes
// test/ when it is encountered as a descendant of the scan root.
const EXEMPT_NAMES = new Set([".git", "node_modules", "test"]);

// execPattern matches both exec.Command("cmd", ...) and
// exec.CommandContext(ctx, "cmd", ...), the ordinary Go idiom for a
// cancellable shell-out: CommandContext takes a leading context
// argument before the command literal, which the optional non-greedy
// group here skips over. A code-review finding on trust-kernel/08
// confirmed CommandContext was invisible to the plain exec.Command(...
// pattern: a planted exec.CommandContext(ctx, "psql", ...) outside
// core/transport passed the check green.
function execPattern(cmd) {
  return new RegExp(
    `exec\\.Command(?:Context)?\\(\\s*(?:[^,"]+,\\s*)?"${cmd}"`,
    "g",
  );
}

const EXEC_PATTERNS = [
  {
    pattern: execPattern("docker"),
    what: 'exec.Command(Context) reaching "docker"',
  },
  {
    pattern: execPattern("psql"),
    what: 'exec.Command(Context) reaching "psql"',
  },
];

const IMPORT_PATTERNS = [
  { pattern: /"database\/sql"/g, what: "database/sql import" },
  { pattern: /"github\.com\/lib\/pq[^"]*"/g, what: "lib/pq driver import" },
  { pattern: /"github\.com\/jackc\/pgx[^"]*"/g, what: "pgx driver import" },
];

let filesScanned = 0;
let violations = 0;

if (existsSync(root) && statSync(root).isDirectory()) {
  walk(root);
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

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (EXEMPT_NAMES.has(entry.name)) continue;
    const path = join(dir, entry.name);
    const relPath = relative(root, path).split(sep).join("/");
    if (EXEMPT_PATHS.has(relPath)) continue;
    if (entry.isDirectory()) {
      walk(path);
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
