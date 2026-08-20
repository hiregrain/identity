// checks/scored-columns.mjs asserts no fact-table column stores a judgment
// about a person (foundation/06, the Dispatch schema-grep pattern).
// Grain says what is known and how well it is known; the partner decides
// what it means. No column may therefore store a capability score, tier,
// or trajectory, nor any derived reliability, trust, or weighting score
// about a person. Decision 025 withdrew the one mechanism (attester
// trust) that would have needed such a column, so this check now catches
// an unlicensed reintroduction rather than a bounded exception.
//
// Mechanism: every base-table column name on BOTH live planes is
// tokenized on underscores and matched against the judgment vocabulary
// below. A hit is a failure naming the rule; there is no exemption list,
// and adding one would be the decision this check exists to force into
// decisions/LOG.md first. The check is lexical over names. A judgment
// column laundered under an innocent name passes it, which is what
// code review and criterion adjudication are for; this catches the
// ordinary reintroduction loudly and early.
//
// The spine schema lint (checks/spine-schema.mjs, foundation/04) is this
// check's sibling in the schema group: it constrains spine column TYPES;
// this constrains column MEANINGS on both planes.
//
// Usage: node checks/scored-columns.mjs
// Requires both plane databases up and migrated; introspection goes
// through `docker compose exec psql` like the rest of the pipeline.

import { execFileSync } from "node:child_process";

// Tokens that name a stored judgment about a person. `rank`/`rating` are
// included as the ordinary synonyms a reintroduction would reach for.
const JUDGMENT_TOKENS = new Set([
  "score",
  "scores",
  "scored",
  "scoring",
  "tier",
  "tiers",
  "trajectory",
  "reliability",
  "trust",
  "trusted",
  "weight",
  "weights",
  "weighting",
  "weighted",
  "rank",
  "ranking",
  "rating",
  "rated",
]);

const failures = [];
let columnsChecked = 0;

for (const plane of ["spine", "payload"]) {
  const rows = psql(
    plane,
    `
    SELECT c.table_schema, c.table_name, c.column_name
      FROM information_schema.columns c
      JOIN information_schema.tables t
        ON t.table_schema = c.table_schema AND t.table_name = c.table_name
     WHERE t.table_type = 'BASE TABLE'
       AND c.table_schema NOT IN ('pg_catalog', 'information_schema')
     ORDER BY 1, 2, 3
  `,
  );
  for (const line of rows) {
    const [schema, table, column] = line.split("|");
    columnsChecked += 1;
    const hit = column
      .toLowerCase()
      .split("_")
      .find((token) => JUDGMENT_TOKENS.has(token));
    if (hit !== undefined) {
      failures.push(
        `${plane} column ${schema}.${table}.${column} carries judgment ` +
          `token "${hit}". No fact-table column stores a capability ` +
          `score, tier, trajectory, or any derived reliability, trust, or ` +
          `weighting score about a person (CLAUDE.md; decision 025 ` +
          `withdrew the last licensed use). Storing one requires a ` +
          `superseding decisions entry, not a column`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `scored-columns: ${columnsChecked} column(s) across both planes store ` +
    `no capability, tier, trajectory, reliability, trust, or weighting ` +
    `judgment`,
);

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
