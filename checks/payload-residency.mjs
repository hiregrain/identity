// checks/payload-residency.mjs is the residency check (foundation/04,
// decision 017; layer criterion foundation-4).
//
// The DATABASE is authoritative for residency; the `residency_region`
// column is a checked assertion of it. The column is what survives a
// dump or restore, exactly when the database name is lost. Two halves,
// both against the live payload database:
//
//   1. Structural: every base table carries `residency_region` NOT NULL.
//      No exemption list exists, bookkeeping included. "Every table"
//      stays checkable only while it is literally true
//      (0004-payload-us-bootstrap adds the column to schema_migrations
//      for exactly this reason).
//   2. Rows: `database_residency` holds exactly one declared region, and
//      no row in any table disagrees with it. A disagreement is a caught
//      error, never an open question about which record governs.
//
// Usage: node checks/payload-residency.mjs
// Requires the payload database up and migrated. Dependency-free;
// connects through `docker compose exec psql` like the rest of the
// pipeline.

import { execFileSync } from "node:child_process";

const failures = [];

// --- 1. every base table carries residency_region NOT NULL -------------

const tables = psql(`
  SELECT t.table_schema, t.table_name,
         coalesce(c.is_nullable, 'MISSING')
    FROM information_schema.tables t
    LEFT JOIN information_schema.columns c
      ON c.table_schema = t.table_schema
     AND c.table_name = t.table_name
     AND c.column_name = 'residency_region'
   WHERE t.table_type = 'BASE TABLE'
     AND t.table_schema NOT IN ('pg_catalog', 'information_schema')
   ORDER BY 1, 2
`);

for (const line of tables) {
  const [schema, table, nullable] = line.split("|");
  if (nullable === "MISSING") {
    failures.push(
      `payload table ${schema}.${table} has no residency_region column. ` +
        `Every payload table carries residency_region NOT NULL ` +
        `(foundation/04, decision 017)`,
    );
  } else if (nullable !== "NO") {
    failures.push(
      `payload table ${schema}.${table}.residency_region is nullable. ` +
        `The residency assertion is NOT NULL on every payload table ` +
        `(foundation/04, decision 017)`,
    );
  }
}

// --- 2. no row disagrees with the database's declared region -----------

const declared = psql(`SELECT residency_region FROM database_residency`);
if (declared.length !== 1) {
  failures.push(
    `database_residency must hold exactly one declared region, found ` +
      `${declared.length} rows. The database's declaration is a singleton ` +
      `(0004-payload-us-bootstrap)`,
  );
} else {
  const region = declared[0];
  for (const line of tables) {
    const [schema, table, nullable] = line.split("|");
    if (nullable === "MISSING") continue; // already failed above
    const disagreeing = psql(
      `SELECT count(*) FROM "${schema}"."${table}" ` +
        `WHERE residency_region IS DISTINCT FROM '${region}'`,
    )[0];
    if (disagreeing !== "0") {
      failures.push(
        `${disagreeing} row(s) in ${schema}.${table} carry a ` +
          `residency_region other than this database's declared '${region}'. ` +
          `The database is authoritative and the column is a checked ` +
          `assertion (foundation/04, decision 017)`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `payload-residency: ${tables.length} table(s) carry residency_region ` +
    `NOT NULL and every row agrees with the database's declared region`,
);

function psql(sql) {
  const out = execFileSync(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      "payload",
      "psql",
      "-v",
      "ON_ERROR_STOP=1",
      "-U",
      "identity",
      "-d",
      "payload",
      "-tA",
      "-c",
      sql,
    ],
    { encoding: "utf8", stdio: ["pipe", "pipe", "inherit"] },
  ).trim();
  return out === "" ? [] : out.split("\n");
}
