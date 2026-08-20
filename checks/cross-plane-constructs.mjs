// checks/cross-plane-constructs.mjs enforces the FDW/dblink ban (foundation/07,
// decisions 011, 017; layer criterion foundation-5's fourth AC).
//
// The two planes are physically split (foundation/04) and the outbox
// (migration 0020) is the ONLY cross-plane channel. What keeps "no SQL
// joins across planes" mechanically true rather than aspirational is
// this ban: no cross-database FDW, dblink, or shared-connection
// construct may exist anywhere in either chain. This check asserts it
// twice over:
//
//   * File mode (default; no database): every migration file in both
//     chains is scanned for the banned constructs. CREATE EXTENSION of
//     a cross-database extension, FOREIGN DATA WRAPPER, CREATE SERVER,
//     CREATE FOREIGN TABLE, IMPORT FOREIGN SCHEMA, and dblink calls.
//     Runs under `make metadata`, before any database boots.
//   * Live mode (--live): both live databases are introspected. Any
//     banned extension in pg_extension, any row in
//     pg_foreign_data_wrapper or pg_foreign_server, any relation of
//     relkind 'f' (foreign table) fails. This is the schema check the
//     acceptance criterion names: it catches a construct created
//     outside the migration chain too.
//
// The banned-extension list is the cross-database family shipped with
// or commonly added to Postgres. The catalog assertions are the general
// net, and an FDW of ANY name is a failure, listed or not.
//
// Red paths: `make check-red` points file mode at a planted fixture
// migration; `make check-red-db` creates a real extension live and
// asserts the failure.
//
// Usage: node checks/cross-plane-constructs.mjs [--live | migrationsRoot]

import { execFileSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const PLANES = ["spine", "payload"];
const BANNED_EXTENSIONS = ["postgres_fdw", "dblink", "file_fdw", "pglogical"];

const FILE_PATTERNS = [
  {
    pattern: new RegExp(
      String.raw`\bCREATE\s+EXTENSION\b[^;]*\b(${BANNED_EXTENSIONS.join("|")})\b`,
      "i",
    ),
    what: "cross-database extension",
  },
  { pattern: /\bFOREIGN\s+DATA\s+WRAPPER\b/i, what: "foreign data wrapper" },
  { pattern: /\bCREATE\s+SERVER\b/i, what: "foreign server" },
  { pattern: /\bCREATE\s+FOREIGN\s+TABLE\b/i, what: "foreign table" },
  { pattern: /\bIMPORT\s+FOREIGN\s+SCHEMA\b/i, what: "foreign schema import" },
  { pattern: /\bdblink\w*\s*\(/i, what: "dblink call" },
];

const live = process.argv[2] === "--live";
const migrationsRoot = live ? null : (process.argv[2] ?? "db/migrations");

const failures = [];

if (live) {
  for (const plane of PLANES) checkLivePlane(plane);
} else {
  checkFiles(migrationsRoot);
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  console.error(
    "cross-plane-constructs: the spine-first outbox (migration " +
      "0020-cross-plane-outbox) is the only cross-plane channel; FDW, " +
      "dblink and shared-connection constructs are banned (foundation/07)",
  );
  process.exit(1);
}
console.log(
  live
    ? "cross-plane-constructs: no FDW, dblink, or cross-database construct in either live database"
    : `cross-plane-constructs: no banned construct in any migration under ${migrationsRoot}`,
);

function checkFiles(root) {
  if (!existsSync(root) || !statSync(root).isDirectory()) {
    failures.push(`${root} is not a directory`);
    return;
  }
  let scanned = 0;
  for (const path of sqlFilesUnder(root)) {
    scanned += 1;
    // Strip SQL comments so prose about the ban (like migration 0020's
    // header, or this ban being documented in a future file) cannot
    // trip the scan; only executable SQL counts.
    const sql = readFileSync(path, "utf8")
      .replace(/--[^\n]*/g, "")
      .replace(/\/\*[\s\S]*?\*\//g, "");
    for (const { pattern, what } of FILE_PATTERNS) {
      const match = pattern.exec(sql);
      if (match) failures.push(`${path}: ${what} ("${match[0].trim()}")`);
    }
  }
  if (scanned === 0) failures.push(`${root} contains no .sql files to scan`);
}

function* sqlFilesUnder(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) yield* sqlFilesUnder(path);
    else if (entry.isFile() && entry.name.endsWith(".sql")) yield path;
  }
}

function checkLivePlane(plane) {
  const extensions = psql(
    plane,
    `SELECT extname FROM pg_extension
      WHERE extname IN (${BANNED_EXTENSIONS.map((e) => `'${e}'`).join(", ")})`,
  );
  for (const name of extensions) {
    failures.push(`${plane}: banned extension "${name}" is installed`);
  }
  const wrappers = psql(plane, "SELECT fdwname FROM pg_foreign_data_wrapper");
  for (const name of wrappers) {
    failures.push(`${plane}: foreign data wrapper "${name}" exists`);
  }
  const servers = psql(plane, "SELECT srvname FROM pg_foreign_server");
  for (const name of servers) {
    failures.push(`${plane}: foreign server "${name}" exists`);
  }
  const foreignTables = psql(
    plane,
    `SELECT n.nspname || '.' || c.relname
       FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind = 'f'`,
  );
  for (const name of foreignTables) {
    failures.push(`${plane}: foreign table "${name}" exists`);
  }
}

function psql(plane, query) {
  const out = execFileSync(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      plane,
      "psql",
      "-v",
      "ON_ERROR_STOP=1",
      "-U",
      "identity",
      "-d",
      plane,
      "-tA",
      "-c",
      query,
    ],
    { encoding: "utf8" },
  ).trim();
  return out === "" ? [] : out.split("\n");
}
