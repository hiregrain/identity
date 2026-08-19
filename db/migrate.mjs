// Migration runner (foundation/02). Plain SQL files applied in number
// order and recorded in schema_migrations; already-recorded numbers are
// skipped, so a second run over an up-to-date database applies nothing.
//
// A plane's chain is the plane-agnostic files at db/migrations/ (today:
// 0001-migration-infrastructure, the bookkeeping table itself) plus the
// plane's own directory (db/migrations/spine/ or db/migrations/payload/).
// The two chains share one numbering sequence (decision 017); uniqueness
// across chains is checks/migration-numbers.mjs's job, not this file's.
//
// Each migration runs in a single transaction together with its
// bookkeeping INSERT — a failed migration records nothing. Migrations
// execute as the table owner (the compose `identity` user); constraining
// the application role is foundation/03.
//
// Usage: node db/migrate.mjs <spine|payload>
// Connects through `docker compose exec <plane> psql`, matching the rest
// of the local pipeline; no cloud credentials exist or are required.

import { execFileSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const PLANES = new Set(["spine", "payload"]);
const ROOT = "db/migrations";

const plane = process.argv[2];
if (!PLANES.has(plane)) {
  console.error("usage: node db/migrate.mjs <spine|payload>");
  process.exit(2);
}

const chain = chainFor(plane);
const applied = appliedNumbers(plane);
let count = 0;

for (const migration of chain) {
  if (applied.has(migration.number)) continue;
  const bookkeeping =
    `INSERT INTO schema_migrations (number, name) VALUES ` +
    `(${migration.number}, '${migration.name}');`;
  const sql = `${readFileSync(migration.path, "utf8")}\n${bookkeeping}\n`;
  console.log(`migrate(${plane}): applying ${migration.path}`);
  psql(plane, ["--single-transaction", "-f", "-"], sql);
  count += 1;
}

console.log(`migrate(${plane}): applied ${count} migration(s)`);

function chainFor(plane) {
  const files = [
    ...sqlFiles(ROOT).map((name) => ({ name, path: join(ROOT, name) })),
    ...sqlFiles(join(ROOT, plane)).map((name) => ({
      name,
      path: join(ROOT, plane, name),
    })),
  ];
  const chain = files.map(({ name, path }) => {
    const match = /^(\d{4})-[a-z0-9]+(?:-[a-z0-9]+)*\.sql$/.exec(name);
    if (!match) {
      console.error(
        `migrate(${plane}): ${path} does not match NNNN-<kebab-noun-phrase>.sql`,
      );
      process.exit(1);
    }
    return {
      number: Number(match[1]),
      name: name.replace(/\.sql$/, ""),
      path,
    };
  });
  return chain.sort((a, b) => a.number - b.number);
}

function sqlFiles(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".sql"))
    .map((entry) => entry.name);
}

function appliedNumbers(plane) {
  const exists = psql(
    plane,
    ["-tA", "-c", "SELECT to_regclass('public.schema_migrations')"],
    null,
  ).trim();
  if (exists === "") return new Set();
  const rows = psql(
    plane,
    ["-tA", "-c", "SELECT number FROM schema_migrations"],
    null,
  ).trim();
  return new Set(
    rows === "" ? [] : rows.split("\n").map((line) => Number(line)),
  );
}

function psql(plane, args, input) {
  return execFileSync(
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
      ...args,
    ],
    {
      encoding: "utf8",
      input: input ?? undefined,
      stdio: ["pipe", "pipe", "inherit"],
    },
  );
}
