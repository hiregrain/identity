// checks/ledger-stamp-grant.mjs holds the ledger's own timestamp out of
// caller reach (trust-kernel/02).
//
// The compromise-vs-backdating rule reads `ledger_ts` and nothing else,
// so the rule is worth exactly as much as the guarantee that a caller
// cannot write that column. Migration 0006-key-event-log buys the
// guarantee by revoking the serving role's table-level INSERT and
// re-granting the four columns a caller may name.
//
// That narrowing is one line of boilerplate away from being undone.
// Migration 0002's header tells every future migration to repeat
// `GRANT INSERT ON ALL TABLES IN SCHEMA public TO identity_app`, and a
// blanket table-level grant silently restores INSERT on every column,
// `ledger_ts` included. Nothing else in the repo would notice:
// test/append-only.test.mjs enumerates UPDATE, DELETE and TRUNCATE by
// construction and says nothing about INSERT, which is a privilege the
// serving role is supposed to hold. So the moment backdating reopened,
// every check would still be green and only this one fails.
//
// What is asserted, per declared column: the serving role holds NO
// table-level INSERT on the table (a table-level grant covers every
// column, which is the hole), it holds column-level INSERT on every
// column a caller may name, and it holds none on the ledger-stamped
// column itself.
//
// Usage: node checks/ledger-stamp-grant.mjs
// Reads the live spine through `docker compose exec psql`, matching
// db/migrate.mjs; requires migrated databases (make db-up + migrate).

import { execFileSync } from "node:child_process";

const PLANE = "spine";
const SERVING_ROLE = "identity_app";

// The ledger-stamped columns and the writable columns beside them. One
// entry today; the list is the declaration, so a second table with a
// ledger stamp adds a line here and inherits the assertion.
const GUARDED = [
  {
    table: "key_event",
    stamp: "ledger_ts",
    writable: ["party_id", "key_id", "event", "effective_at"],
    migration: "0006-key-event-log",
  },
];

const failures = [];

for (const { table, stamp, writable, migration } of GUARDED) {
  if (tableInsert(table)) {
    failures.push(
      `${PLANE}.${table}: ${SERVING_ROLE} holds a TABLE-level INSERT grant, which covers every ` +
        `column including ${stamp}. ${migration} revoked it deliberately; a blanket ` +
        `"GRANT INSERT ON ALL TABLES" has restored it and reopened backdating`,
    );
    continue;
  }
  if (columnInsert(table, stamp)) {
    failures.push(
      `${PLANE}.${table}.${stamp}: ${SERVING_ROLE} holds INSERT on the ledger's own timestamp, ` +
        `so a caller can supply it and the compromise-vs-backdating rule reads a claim ` +
        `rather than a fact (${migration})`,
    );
  }
  for (const column of writable) {
    if (!columnInsert(table, column)) {
      failures.push(
        `${PLANE}.${table}.${column}: ${SERVING_ROLE} holds no INSERT, so the serving path ` +
          `cannot write a key event at all (${migration})`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}

console.log(
  `ledger-stamp-grant: every ledger-stamped column is out of ${SERVING_ROLE}'s reach ` +
    `and every column beside it is writable (${GUARDED.length} table(s) checked)`,
);

function tableInsert(table) {
  return (
    psql(
      `SELECT has_table_privilege('${SERVING_ROLE}', '${table}', 'INSERT')`,
    ) === "t"
  );
}

function columnInsert(table, column) {
  return (
    psql(
      `SELECT has_column_privilege('${SERVING_ROLE}', '${table}', '${column}', 'INSERT')`,
    ) === "t"
  );
}

// has_column_privilege answers true when the privilege is held at either
// level, so tableInsert is checked first and short-circuits: without
// that order a blanket table grant would read as a healthy column grant.
function psql(sql) {
  return execFileSync(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      PLANE,
      "psql",
      "-v",
      "ON_ERROR_STOP=1",
      "-U",
      "identity",
      "-d",
      PLANE,
      "-tAq",
      "-c",
      sql,
    ],
    { encoding: "utf8" },
  ).trim();
}
