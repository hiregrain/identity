// test/two-plane-split.test.mjs — the physical-split proof
// (foundation/04, decision 011).
//
// Two schemas behind two connection strings would satisfy a naive
// reading of "two planes"; this test proves the split is physical:
// separate database clusters, no shared transaction boundary, and a
// role catalog per plane. What is proven:
//
//   1. The planes are distinct clusters: pg_control_system() reports a
//      different system identifier on each, and neither cluster's
//      pg_database contains the other plane's database — stronger than
//      "separate databases", which one cluster could fake.
//   2. A transaction cannot span the planes: inside an open transaction
//      on the spine, a qualified reference to the payload database is an
//      error that aborts the transaction. There is no SQL path from one
//      plane to the other (the FDW/dblink ban that keeps it that way is
//      foundation/07's).
//   3. Each plane has its own role set: roles are cluster-wide in
//      Postgres, and a role created on one plane does not exist on the
//      other. The shared names (identity, identity_app) are two
//      independent roles per plane, not one shared principal.
//
// Probe roles created here are dropped before exit on the green path; on
// a failure the next `make db-reset` rebuilds from empty.
//
// Usage: node test/two-plane-split.test.mjs
// Requires both databases up (make db-up); migration state is irrelevant
// to what it proves.

import { execFileSync } from "node:child_process";

const PLANES = ["spine", "payload"];
let assertions = 0;

// --- 1. distinct clusters ----------------------------------------------

const identifiers = PLANES.map(
  (plane) =>
    psql(plane, "SELECT system_identifier FROM pg_control_system()")[0],
);
assert(
  identifiers[0] !== identifiers[1],
  `the planes are distinct clusters (system identifiers ${identifiers[0]} ` +
    `vs ${identifiers[1]})`,
  `both planes report system identifier ${identifiers[0]} — one cluster, ` +
    `not a physical split`,
);

for (const [i, plane] of PLANES.entries()) {
  const other = PLANES[1 - i];
  const databases = psql(plane, "SELECT datname FROM pg_database");
  assert(
    databases.includes(plane) && !databases.includes(other),
    `${plane}'s cluster contains "${plane}" and no "${other}" database`,
    `${plane}'s cluster databases [${databases.join(", ")}] — the other ` +
      `plane is reachable from this cluster`,
  );
}

// --- 2. a transaction cannot span the planes ---------------------------

for (const [i, plane] of PLANES.entries()) {
  const other = PLANES[1 - i];
  const spanning =
    `BEGIN;\n` +
    `SELECT count(*) FROM ${other}.public.schema_migrations;\n` +
    `COMMIT;\n`;
  let failed = false;
  let output = "";
  try {
    execFileSync(
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
        "-f",
        "-",
      ],
      { encoding: "utf8", input: spanning, stdio: ["pipe", "pipe", "pipe"] },
    );
  } catch (error) {
    failed = true;
    output = `${error.stdout ?? ""}${error.stderr ?? ""}`;
  }
  assert(
    failed && output.includes("cross-database references are not implemented"),
    `a transaction on ${plane} cannot reference ${other} (aborted: ` +
      `cross-database references are not implemented)`,
    `a transaction on ${plane} reached ${other} — the planes share a ` +
      `transaction boundary`,
  );
}

// --- 3. each plane has its own role set --------------------------------

const PROBE_ROLE = "probe_split_role";
psql("spine", `CREATE ROLE ${PROBE_ROLE} NOLOGIN`);
try {
  const onSpine = psql(
    "spine",
    `SELECT count(*) FROM pg_roles WHERE rolname = '${PROBE_ROLE}'`,
  )[0];
  const onPayload = psql(
    "payload",
    `SELECT count(*) FROM pg_roles WHERE rolname = '${PROBE_ROLE}'`,
  )[0];
  assert(
    onSpine === "1" && onPayload === "0",
    `a role created on spine does not exist on payload — one role catalog ` +
      `per plane`,
    `probe role visible on spine=${onSpine} payload=${onPayload} — the ` +
      `planes share a role catalog`,
  );
} finally {
  psql("spine", `DROP ROLE ${PROBE_ROLE}`);
}

for (const plane of PLANES) {
  const roles = psql(
    plane,
    `SELECT count(*) FROM pg_roles WHERE rolname IN ('identity', 'identity_app')`,
  )[0];
  assert(
    roles === "2",
    `${plane} carries its own identity and identity_app roles`,
    `${plane} is missing its own role set (found ${roles} of 2)`,
  );
}

console.log(`\ntwo-plane-split: ${assertions} assertions passed`);

function assert(condition, pass, fail) {
  if (!condition) {
    console.error(`FAIL ${fail}`);
    process.exit(1);
  }
  assertions += 1;
  console.log(`  ok: ${pass}`);
}

function psql(plane, sql) {
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
      sql,
    ],
    { encoding: "utf8", stdio: ["pipe", "pipe", "inherit"] },
  ).trim();
  return out === "" ? [] : out.split("\n");
}
