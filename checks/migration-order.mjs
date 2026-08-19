// checks/migration-order.mjs — cross-reference ordering under the one
// shared numbering sequence (decision 017, foundation/06). When a
// migration references an object another migration creates, the
// referencing migration must carry the higher number; collisions
// (checks/migration-numbers.mjs) and gaps do not catch an inversion. The
// constraint the check guards is live in the claim ledger today:
// 0014-safety-markers (person-identity/07) will reference party
// structure 0009-party-core (party-registry/01) creates, and the moment
// both land as SQL an inversion between them fails here.
//
// Mechanism: each landed migration's created objects (CREATE TABLE/
// DOMAIN/TYPE/SEQUENCE/FUNCTION/VIEW/INDEX) are collected, then every
// migration that references a created name — comments stripped, since
// prose may mention future objects while code may not — must carry a
// number strictly above the creator's. Namespaces follow the physical
// split: the root chain (db/migrations/*.sql) runs on both planes, and
// each plane chain (spine/, payload/) sees only itself plus the root —
// the same bare name created once per plane (0003 and 0004 both define
// spine_object_id) is two objects in two databases, not a reference.
//
// Ordering is deliberately NOT derived from task depends_on: the claim
// ledger legitimately inverts it (person-identity/01 claims 0010 while
// depending on foundation/07's 0020 — numbers were allocated per layer
// block, not topologically), and db/migrate.mjs applies any unapplied
// number in order, so a late-landing lower number is legal. Only an
// actual reference constrains order, and references exist only in SQL.
//
// Usage: node checks/migration-order.mjs [db-migrations-root]
// Dependency-free Node, no database.

import { readdirSync, readFileSync } from "node:fs";
import { join, relative, sep } from "node:path";

const NAME = /^(\d{4})-[a-z0-9]+(?:-[a-z0-9]+)*$/;
const CREATE =
  /\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:UNLOGGED\s+|TEMP(?:ORARY)?\s+|UNIQUE\s+)?(?:TABLE|DOMAIN|TYPE|SEQUENCE|FUNCTION|VIEW|INDEX)\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:CONCURRENTLY\s+)?("?[a-z_][\w$]*"?(?:\."?[a-z_][\w$]*"?)?)/gi;

const dbRoot = process.argv[2] ?? "db/migrations";
const failures = [];

const landed = []; // { number, name, path, chain, sql }
walk(dbRoot);

// creators: chain -> Map(bare object name -> creating migration)
const creators = new Map();
for (const migration of landed) {
  if (!creators.has(migration.chain)) creators.set(migration.chain, new Map());
  const byName = creators.get(migration.chain);
  for (const match of migration.sql.matchAll(CREATE)) {
    const bare = match[1].split(".").pop().replaceAll('"', "").toLowerCase();
    const existing = byName.get(bare);
    if (existing === undefined || migration.number < existing.number) {
      byName.set(bare, migration);
    }
  }
}

for (const migration of landed) {
  // A plane migration sees its own chain plus the root chain; a root
  // migration runs on both planes and sees only the root chain.
  const visible =
    migration.chain === "root" ? ["root"] : [migration.chain, "root"];
  for (const chain of visible) {
    for (const [object, creator] of creators.get(chain) ?? []) {
      if (creator === migration || creator.number <= migration.number) {
        continue;
      }
      if (new RegExp(`\\b${object}\\b`, "i").test(migration.sql)) {
        failures.push(
          `${migration.path}: references "${object}", created by the ` +
            `higher-numbered ${creator.name} (${creator.path}) — a ` +
            `migration referencing an object another migration creates ` +
            `must carry the higher number (decision 017's shared sequence)`,
        );
      }
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
const objectCount = [...creators.values()].reduce((n, m) => n + m.size, 0);
console.log(
  `migration-order: every cross-reference among ${landed.length} landed ` +
    `migration(s) points at a lower number (${objectCount} created ` +
    `objects across ${creators.size} chain namespace(s))`,
);

function walk(dir) {
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return; // no migrations directory yet — nothing landed
  }
  for (const entry of entries) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(path);
      continue;
    }
    if (!entry.name.endsWith(".sql")) continue;
    const name = entry.name.replace(/\.sql$/, "");
    const match = NAME.exec(name);
    if (!match) continue; // grammar failures are migration-numbers.mjs's
    const parts = relative(dbRoot, path).split(sep);
    landed.push({
      number: Number(match[1]),
      name,
      path,
      chain: parts.length === 1 ? "root" : parts[0],
      sql: stripComments(readFileSync(path, "utf8")),
    });
  }
}

function stripComments(sql) {
  return sql.replace(/--[^\n]*/g, "").replace(/\/\*[\s\S]*?\*\//g, "");
}
