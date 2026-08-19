// Restore of the payload plane from a db/backup.mjs dump (foundation/08,
// decision 017). The mechanics exist to make one sentence true: a
// restored backup does not resurrect a deleted person, and a restored
// system that has not replayed the deletion journal does not serve.
//
// What a restore does, in order:
//
//   1. Recreates the payload container from empty (`docker compose rm`
//      + `up`). The spine is untouched — it holds the deletion journal
//      the replay will read, and the journal outliving payload backups
//      is the whole design.
//   2. Recreates the serving roles (identity_app, identity_purge) with
//      the attributes their migrations declare (0002, 0022). Roles are
//      cluster-level state pg_dump does not carry; on managed Postgres
//      a cluster restore carries them, and this script is the local
//      equivalent of that step. Table/column ACLs, default privileges
//      and row-security policies all travel INSIDE the dump.
//   3. Applies the dump and appends the restore_gate 'restored' row in
//      ONE psql transaction. This ordering is load-bearing: the gate
//      row commits with the data it gates, so there is no instant at
//      which a serving process could observe restored data without the
//      unbalanced gate that refuses it (core/envelope checks the gate
//      on every serving read and write). The gate stays unbalanced
//      until `deletion replay` (core/cmd/deletion) has re-destroyed
//      every journaled person and appended the balancing 'replayed'
//      row. The replay is a gate, not a cleanup step.
//
// Usage: node db/restore.mjs <dumpfile>
//   Prints the restore_id; the system refuses traffic until
//   `deletion replay` completes. Requires Docker; the spine database up
//   is not required for the restore itself, only for the replay.

import { execFileSync } from "node:child_process";
import { randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";

const dumpFile = process.argv[2];
if (!dumpFile) {
  console.error("usage: node db/restore.mjs <dumpfile>");
  process.exit(2);
}
const dump = readFileSync(dumpFile, "utf8");

// --- 1. fresh payload container, spine untouched -----------------------

console.log("restore: recreating the payload container from empty");
docker(["compose", "rm", "-sf", "payload"]);
docker(["compose", "up", "-d", "--wait", "payload"]);

// --- 2. serving roles: cluster-level state outside pg_dump's scope -----

// Attribute-for-attribute what 0002 (identity_app) and 0022
// (identity_purge) declare. CONNECT is granted the same way those
// migrations grant it; every in-database grant (tables, schema, default
// privileges, row security) arrives with the dump itself.
psql(`
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'identity_app') THEN
    CREATE ROLE identity_app
      LOGIN PASSWORD 'identity_app'
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'identity_purge') THEN
    CREATE ROLE identity_purge
      LOGIN PASSWORD 'identity_purge'
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO identity_app', current_database());
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO identity_purge', current_database());
END
$$;
`);

// --- 3. the dump and the gate row, one transaction ---------------------

// The dump sets an empty search_path for its own statements, so the
// gate insert schema-qualifies everything. ON_ERROR_STOP + a single
// transaction: a failed restore leaves an empty database and no gate
// row, never data without a gate.
const restoreID = randomUUID();
console.log(`restore: applying ${dumpFile} (restore_id ${restoreID})`);
psql(
  [
    "BEGIN;",
    dump,
    `INSERT INTO public.restore_gate (restore_id, event, residency_region)`,
    `SELECT '${restoreID}', 'restored', residency_region FROM public.database_residency;`,
    "COMMIT;",
  ].join("\n"),
);

console.log(
  `restore: complete and GATED — restore_id ${restoreID}. The payload ` +
    `plane refuses serving traffic until the deletion journal is ` +
    `replayed: run \`deletion replay\` (core/cmd/deletion).`,
);

function docker(args) {
  execFileSync("docker", args, { stdio: ["pipe", "inherit", "inherit"] });
}

function psql(sql) {
  execFileSync(
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
      "-f",
      "-",
    ],
    {
      encoding: "utf8",
      input: sql,
      stdio: ["pipe", "pipe", "inherit"],
      maxBuffer: 1024 * 1024 * 1024,
    },
  );
}
