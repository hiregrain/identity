// test/append-only.test.mjs — the standing proof (foundation/03).
//
// The database, not discipline, guarantees append-only. This test proves
// it against both live planes, and it is the enumerated home of every
// exemption: granting UPDATE or DELETE to any non-owner role anywhere
// requires editing EXEMPTIONS below, so the exception is a reviewed edit
// to the standing proof, never something the proof quietly tolerates.
//
// What is proven, per plane (spine and payload):
//   1. The set of UPDATE/DELETE/TRUNCATE grants to non-owner roles —
//      table-level, column-level, and on sequences (sequence UPDATE is
//      setval/nextval, which rewrites sequence state) — equals
//      EXEMPTIONS exactly.
//   2. The application role cannot UPDATE or DELETE (raw statements fail
//      with permission denied); SELECT and INSERT work, so the denial is
//      a boundary and not a broken role.
//   3. A table created by a later migration (simulated here: created by
//      the owner after the grants migration ran) inherits SELECT/INSERT-
//      only with no manual step — in the existing schema under the
//      existing owner, AND in a second schema under a second owner role,
//      because Postgres default privileges are per granting role and per
//      schema, so the single-schema single-owner case proves far less
//      than the claim.
//   4. The application role holds no escalation path: no superuser /
//      createrole / createdb / replication / bypassrls attribute, no role
//      memberships, and SET ROLE to the owner is denied.
//   5. Every SECURITY DEFINER function body contains no UPDATE, DELETE,
//      or TRUNCATE. Zero such functions may exist; the scan still runs
//      and is shaped to catch the first one that violates.
//   6. For every declared incompatible schema pair
//      (db/incompatible-schema-pairs.json) no role can read both members
//      — the cross-schema join is attempted as every defined
//      non-superuser role and must fail at the permission layer. While
//      the declared list is empty the same assertion runs against a
//      planted probe pair, so the enforcement pattern is exercised, not
//      dormant.
//
// Superuser roles are excluded from the pair-join sweep by ruling of the
// permission model itself: a superuser bypasses the ACL layer entirely,
// so "fails at the permission layer" is not a statement Postgres can make
// about one. Keeping superuser/owner credentials away from serving
// processes is the operational boundary asserted by
// checks/serving-credentials.mjs and by assertion 4 above.
//
// Probe objects created here are dropped before exit on the green path;
// on a failure the run exits non-zero and the next `make db-reset`
// rebuilds from empty, so nothing can leak into a green pipeline.
//
// Usage: node test/append-only.test.mjs
// Connects through `docker compose exec <plane> psql`, matching
// db/migrate.mjs; requires migrated databases (make db-up + migrate).

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";

const PLANES = ["spine", "payload"];
const OWNER = "identity"; // migration/owner credentials (compose user)
const APP = "identity_app"; // the serving role (migration 0002)

// The enumerated exemption list. An entry is
//   { plane, schema, table, grantee, privilege, decision }
// and must cite the licensing decision. Granted only per table, by name,
// to a named role, in the migration that creates or licenses the table
// (migration 0002's header). Ruled but not yet landed — they arrive with
// their own migration sites and get entries here in the same PR:
//   * party_users erasure (decision 016, party-registry)
//   * payload purge role (foundation/08)
//   * stream_heads rebuildable projection (trust-kernel/03, decision 019)
const EXEMPTIONS = [];

const MUTATION_PRIVILEGES = ["UPDATE", "DELETE", "TRUNCATE"];

let assertions = 0;

for (const plane of PLANES) {
  console.log(`\nappend-only(${plane}):`);
  assertGrantSetEqualsExemptions(plane);
  assertNoColumnLevelMutationGrants(plane);
  assertAppRoleIsBoxedIn(plane);
  assertRawMutationsDenied(plane, "public", "schema_migrations");
  assertAppCanSelectAndInsert(plane, "public", "schema_migrations");
  assertInheritanceInExistingSchema(plane);
  assertInheritanceUnderSecondOwnerAndSchema(plane);
  assertSecurityDefinerBodiesOnlyInsert(plane);
  assertIncompatiblePairsUnreadable(plane);
}

console.log(`\nappend-only: ${assertions} assertions passed on both planes`);

// --- 1. the grant set equals the exemption list, exactly ---------------

function assertGrantSetEqualsExemptions(plane) {
  const sql = `
    SELECT n.nspname, c.relname,
           CASE WHEN a.grantee = 0 THEN 'PUBLIC'
                ELSE a.grantee::regrole::text END,
           a.privilege_type
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace,
    LATERAL aclexplode(coalesce(c.relacl, acldefault(
      (CASE WHEN c.relkind = 'S' THEN 'S' ELSE 'r' END)::"char",
      c.relowner))) a
    -- views ('v', 'm'), foreign tables ('f') and sequences ('S') are
    -- included: an auto-updatable view with an UPDATE grant is a
    -- table-grant bypass, and sequence UPDATE (setval) rewrites sequence
    -- state. The owner's own implicit entries are filtered below, so the
    -- owner legitimately keeping sequence UPDATE never trips this.
    WHERE c.relkind IN ('r', 'p', 'v', 'm', 'f', 'S')
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND a.privilege_type IN (${MUTATION_PRIVILEGES.map((p) => `'${p}'`).join(", ")})
      AND a.grantee <> c.relowner`;
  const found = rows(psql(plane, OWNER, sql))
    .map(
      ([schema, table, grantee, privilege]) =>
        `${schema}.${table} ${privilege} -> ${grantee}`,
    )
    .sort();
  const declared = EXEMPTIONS.filter((e) => e.plane === plane)
    .map((e) => `${e.schema}.${e.table} ${e.privilege} -> ${e.grantee}`)
    .sort();
  if (found.join("\n") !== declared.join("\n")) {
    fail(
      plane,
      `mutation grants do not equal the exemption list.\n` +
        `  in database: ${found.length ? found.join("; ") : "(none)"}\n` +
        `  declared:    ${declared.length ? declared.join("; ") : "(none)"}`,
    );
  }
  pass(
    plane,
    `UPDATE/DELETE/TRUNCATE grants equal the exemption list ` +
      `(${declared.length} exemption(s))`,
  );
}

function assertNoColumnLevelMutationGrants(plane) {
  const sql = `
    SELECT n.nspname, c.relname, att.attname,
           CASE WHEN a.grantee = 0 THEN 'PUBLIC'
                ELSE a.grantee::regrole::text END,
           a.privilege_type
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute att ON att.attrelid = c.oid AND att.attacl IS NOT NULL,
    LATERAL aclexplode(att.attacl) a
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND a.privilege_type = 'UPDATE'
      AND a.grantee <> c.relowner`;
  const found = rows(psql(plane, OWNER, sql));
  if (found.length > 0) {
    fail(
      plane,
      `column-level UPDATE grants exist (a column grant is a table-grant ` +
        `bypass): ${found.map((r) => r.join(" ")).join("; ")}`,
    );
  }
  pass(plane, "no column-level UPDATE grant to any non-owner role");
}

// --- 4 (numbered as documented above): the app role is boxed in --------

function assertAppRoleIsBoxedIn(plane) {
  const attrs = rows(
    psql(
      plane,
      OWNER,
      `SELECT rolsuper, rolcreaterole, rolcreatedb, rolreplication,
              rolbypassrls
       FROM pg_roles WHERE rolname = '${APP}'`,
    ),
  );
  if (attrs.length !== 1) fail(plane, `role ${APP} not found`);
  if (attrs[0].some((v) => v !== "f")) {
    fail(plane, `${APP} holds an escalation attribute: ${attrs[0].join(",")}`);
  }
  const memberships = rows(
    psql(
      plane,
      OWNER,
      `SELECT roleid::regrole::text FROM pg_auth_members
       WHERE member = '${APP}'::regrole`,
    ),
  );
  if (memberships.length > 0) {
    fail(plane, `${APP} is a member of: ${memberships.flat().join(", ")}`);
  }
  expectPermissionDenied(plane, APP, `SET ROLE ${OWNER}`, `SET ROLE ${OWNER}`);
  pass(
    plane,
    `${APP} has no escalation attribute, no role membership, ` +
      `and cannot SET ROLE ${OWNER}`,
  );
}

// --- 2. raw mutations denied; select/insert work -----------------------

function assertRawMutationsDenied(plane, schema, table) {
  expectPermissionDenied(
    plane,
    APP,
    `UPDATE ${schema}.${table} SET name = name`,
    `UPDATE ${schema}.${table}`,
  );
  expectPermissionDenied(
    plane,
    APP,
    `DELETE FROM ${schema}.${table}`,
    `DELETE FROM ${schema}.${table}`,
  );
  pass(plane, `raw UPDATE and DELETE on ${schema}.${table} denied to ${APP}`);
}

function assertAppCanSelectAndInsert(plane, schema, table) {
  psql(plane, APP, `SELECT count(*) FROM ${schema}.${table}`);
  // Rolled back so the bookkeeping table is left as found; what is
  // proven is that the INSERT passes the permission layer.
  psql(
    plane,
    APP,
    `BEGIN;
     INSERT INTO ${schema}.${table} (number, name)
       VALUES (9999, 'append-only-probe');
     ROLLBACK;`,
  );
  pass(plane, `${APP} can SELECT and INSERT on ${schema}.${table}`);
}

// --- 3. inheritance with no manual step --------------------------------

function assertInheritanceInExistingSchema(plane) {
  // Simulates a later migration: the owner creates a table after the
  // grants migration ran. No GRANT is issued anywhere in this block.
  psql(
    plane,
    OWNER,
    `CREATE TABLE public.probe_rows
       (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, note text)`,
  );
  try {
    psql(plane, APP, `SELECT count(*) FROM public.probe_rows`);
    psql(plane, APP, `INSERT INTO public.probe_rows (note) VALUES ('probe')`);
    expectPermissionDenied(
      plane,
      APP,
      `UPDATE public.probe_rows SET note = 'x'`,
      `UPDATE on inherited-privilege table public.probe_rows`,
    );
    expectPermissionDenied(
      plane,
      APP,
      `DELETE FROM public.probe_rows`,
      `DELETE on inherited-privilege table public.probe_rows`,
    );
  } finally {
    psql(plane, OWNER, `DROP TABLE public.probe_rows`);
  }
  pass(
    plane,
    "a table created later in public by the owner inherits " +
      "SELECT/INSERT-only with no manual step",
  );
}

function assertInheritanceUnderSecondOwnerAndSchema(plane) {
  // A second schema under a second owner role, set up exactly as the
  // once-per-schema pattern in migration 0002's header prescribes for a
  // schema-creating migration. The table itself then gets no per-table
  // step, which is the claim under test.
  psql(
    plane,
    OWNER,
    `CREATE ROLE probe_owner NOLOGIN;
     CREATE SCHEMA probe_schema AUTHORIZATION probe_owner;
     GRANT USAGE ON SCHEMA probe_schema TO ${APP};
     ALTER DEFAULT PRIVILEGES FOR ROLE probe_owner IN SCHEMA probe_schema
       GRANT SELECT, INSERT ON TABLES TO ${APP};
     ALTER DEFAULT PRIVILEGES FOR ROLE probe_owner IN SCHEMA probe_schema
       GRANT USAGE, SELECT ON SEQUENCES TO ${APP};
     SET ROLE probe_owner;
     CREATE TABLE probe_schema.probe_rows
       (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, note text);
     RESET ROLE;`,
  );
  try {
    psql(plane, APP, `SELECT count(*) FROM probe_schema.probe_rows`);
    psql(
      plane,
      APP,
      `INSERT INTO probe_schema.probe_rows (note) VALUES ('probe')`,
    );
    expectPermissionDenied(
      plane,
      APP,
      `UPDATE probe_schema.probe_rows SET note = 'x'`,
      `UPDATE under second owner in second schema`,
    );
    expectPermissionDenied(
      plane,
      APP,
      `DELETE FROM probe_schema.probe_rows`,
      `DELETE under second owner in second schema`,
    );
  } finally {
    psql(
      plane,
      OWNER,
      `DROP OWNED BY probe_owner;
       DROP ROLE probe_owner;`,
    );
  }
  pass(
    plane,
    "a table created by a second owner role in a second schema inherits " +
      "SELECT/INSERT-only with no manual per-table step",
  );
}

// --- 5. SECURITY DEFINER bodies may only INSERT ------------------------

function assertSecurityDefinerBodiesOnlyInsert(plane) {
  const sql = `
    SELECT n.nspname || '.' || p.proname,
           replace(encode(convert_to(p.prosrc, 'UTF8'), 'base64'), E'\\n', '')
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.prosecdef
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')`;
  const fns = rows(psql(plane, OWNER, sql));
  for (const [name, bodyBase64] of fns) {
    const body = Buffer.from(bodyBase64.replace(/\s/g, ""), "base64")
      .toString("utf8")
      .replace(/--[^\n]*/g, "") // strip line comments
      .replace(/\/\*[\s\S]*?\*\//g, ""); // strip block comments
    const match = /\b(update|delete|truncate)\b/i.exec(body);
    if (match) {
      fail(
        plane,
        `SECURITY DEFINER function ${name} contains ${match[1].toUpperCase()};` +
          ` such functions may only INSERT (decision 017)`,
      );
    }
  }
  pass(
    plane,
    `every SECURITY DEFINER function body is free of UPDATE/DELETE/` +
      `TRUNCATE (${fns.length} function(s) scanned)`,
  );
}

// --- 6. incompatible schema pairs: no role reads both ------------------

function assertIncompatiblePairsUnreadable(plane) {
  const declared = JSON.parse(
    readFileSync("db/incompatible-schema-pairs.json", "utf8"),
  ).pairs;

  for (const [left, right] of declared) {
    const leftTable = anyTableIn(plane, left);
    const rightTable = anyTableIn(plane, right);
    assertNoRoleJoins(plane, left, leftTable, right, rightTable, "declared");
  }

  // While the declared list is empty (first real pair: party-registry/04)
  // the enforcement pattern is exercised against a planted probe pair —
  // two schemas with disjoint owners and disjoint readers, the shape a
  // pair-declaring migration must produce.
  psql(
    plane,
    OWNER,
    `CREATE ROLE probe_owner_left NOLOGIN;
     CREATE ROLE probe_owner_right NOLOGIN;
     CREATE SCHEMA probe_left AUTHORIZATION probe_owner_left;
     CREATE SCHEMA probe_right AUTHORIZATION probe_owner_right;
     SET ROLE probe_owner_left;
     CREATE TABLE probe_left.probe_rows (id integer PRIMARY KEY);
     RESET ROLE;
     SET ROLE probe_owner_right;
     CREATE TABLE probe_right.probe_rows (id integer PRIMARY KEY);
     RESET ROLE;
     GRANT USAGE ON SCHEMA probe_left TO ${APP};
     GRANT SELECT ON probe_left.probe_rows TO ${APP};`,
  );
  try {
    // Positive control: one side is readable, so the join failures below
    // are the boundary and not a vacuously unreadable database.
    psql(plane, APP, `SELECT count(*) FROM probe_left.probe_rows`);
    assertNoRoleJoins(
      plane,
      "probe_left",
      "probe_rows",
      "probe_right",
      "probe_rows",
      "planted probe",
    );
  } finally {
    psql(
      plane,
      OWNER,
      `DROP OWNED BY probe_owner_left;
       DROP OWNED BY probe_owner_right;
       DROP ROLE probe_owner_left;
       DROP ROLE probe_owner_right;`,
    );
  }
  pass(
    plane,
    `no role can read both members of an incompatible pair ` +
      `(${declared.length} declared pair(s) + the planted probe pair)`,
  );
}

function assertNoRoleJoins(plane, left, leftTable, right, rightTable, kind) {
  const roles = rows(
    psql(
      plane,
      OWNER,
      `SELECT rolname FROM pg_roles
       WHERE rolname NOT LIKE 'pg\\_%' AND NOT rolsuper
       ORDER BY rolname`,
    ),
  ).flat();
  if (roles.length === 0) {
    fail(plane, "no non-superuser roles defined; the pair sweep is vacuous");
  }
  for (const role of roles) {
    expectPermissionDenied(
      plane,
      OWNER,
      `SET ROLE "${role}";
       SELECT count(*) FROM ${left}.${leftTable} l, ${right}.${rightTable} r;`,
      `${kind} pair ${left}|${right}: join as ${role}`,
    );
  }
}

function anyTableIn(plane, schema) {
  const found = rows(
    psql(
      plane,
      OWNER,
      `SELECT c.relname FROM pg_class c
       JOIN pg_namespace n ON n.oid = c.relnamespace
       WHERE n.nspname = '${schema}' AND c.relkind IN ('r', 'p')
       ORDER BY c.relname LIMIT 1`,
    ),
  );
  if (found.length === 0) {
    fail(
      plane,
      `declared incompatible schema ${schema} has no table to attempt ` +
        `the join against; a declared pair must be joinable-in-principle ` +
        `for the sweep to prove anything`,
    );
  }
  return found[0][0];
}

// --- plumbing ----------------------------------------------------------

function psql(plane, role, sql) {
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
      role,
      "-d",
      plane,
      "-tA",
      "-F",
      "\t",
      "-c",
      sql,
    ],
    { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] },
  );
}

function expectPermissionDenied(plane, role, sql, label) {
  let stderr = "";
  try {
    psql(plane, role, sql);
  } catch (error) {
    stderr = String(error.stderr ?? "");
    if (/permission denied/i.test(stderr)) return;
  }
  fail(
    plane,
    `${label}: expected "permission denied", got ` +
      (stderr === "" ? "success" : `a different error: ${stderr.trim()}`),
  );
}

function rows(output) {
  const trimmed = output.trim();
  if (trimmed === "") return [];
  return trimmed.split("\n").map((line) => line.split("\t"));
}

function pass(plane, message) {
  assertions += 1;
  console.log(`  ok(${plane}): ${message}`);
}

function fail(plane, message) {
  console.error(`append-only(${plane}): FAIL: ${message}`);
  process.exit(1);
}
