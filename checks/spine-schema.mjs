// checks/spine-schema.mjs — the spine schema lint (foundation/04,
// decision 017; layer criterion foundation-3).
//
// The spine carries ordering and commitments, never content, and
// "readable-content type" was never defined — so the boundary is the
// enumerated allow-list in db/spine-allow-list.json, and this lint is
// its enforcement. Against the live spine schema, every column must be
// one of:
//
//   * a column of an allow-listed DOMAIN (the standing permissions:
//     the purpose-built domains from 0003-spine-core), or
//   * a declared per-column EXCEPTION in the allow-list, whose
//     introducing migration carries a written justification block
//     answering foundation/04's five-question correlation checklist.
//
// Anything else — a bare base type, a text/blob/JSON column, an unlisted
// domain, an exception with no justification — fails with a message
// naming the rule. The lint proves type discipline and justification
// PRESENCE only; it does not claim an opaque bytea or an id encodes no
// personal data — the justification content is human-reviewed, and the
// correlation judgment is layer criterion foundation-8.
//
// The justification block format (the lint's contract, detected here,
// judged by humans) is a comment in the migration that introduces the
// column — "risk accepted, because —" is a valid answer; absence is not:
//
//   -- justify-column: <table>.<column> (<type>)
//   --   1 ordering: <answer>
//   --   2 timestamp-granularity: <answer>
//   --   3 external-roster-join: <answer>
//   --   4 commitment-salt-reuse: <answer>
//   --   5 partial-dataset-adversary: <answer>
//
// A declared exception no live column matches also fails: a standing
// permission with nothing under it is exactly the drift the list format
// exists to prevent.
//
// Usage: node checks/spine-schema.mjs [allow-list.json] [migrationsDir...]
//   Defaults: db/spine-allow-list.json, scanning the spine chain
//   (db/migrations plus db/migrations/spine). Requires the spine
//   database up and migrated. Dependency-free; introspection goes
//   through `docker compose exec psql` like the rest of the pipeline.

import { execFileSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const allowListFile = process.argv[2] ?? "db/spine-allow-list.json";
const migrationDirs =
  process.argv.length > 3
    ? process.argv.slice(3)
    : ["db/migrations", join("db/migrations", "spine")];

const allowList = JSON.parse(readFileSync(allowListFile, "utf8"));
const allowedDomains = new Set(allowList.domains.map((d) => d.domain));

const QUESTIONS = [
  "1 ordering:",
  "2 timestamp-granularity:",
  "3 external-roster-join:",
  "4 commitment-salt-reuse:",
  "5 partial-dataset-adversary:",
];

const failures = [];

// --- live spine columns ------------------------------------------------

const rows = psql(`
  SELECT c.table_schema, c.table_name, c.column_name, c.data_type,
         coalesce(c.domain_name, '')
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema AND t.table_name = c.table_name
   WHERE t.table_type = 'BASE TABLE'
     AND c.table_schema NOT IN ('pg_catalog', 'information_schema')
   ORDER BY 1, 2, 3
`);

const justifications = collectJustifications(migrationDirs);
const matchedExceptions = new Set();

for (const line of rows) {
  const [schema, table, column, dataType, domain] = line.split("|");
  const where = `${schema}.${table}.${column}`;

  if (domain !== "") {
    if (allowedDomains.has(domain)) continue;
    failures.push(
      `spine column ${where} uses domain "${domain}", which is not in the ` +
        `spine allow-list (${allowListFile}) — every spine column type is ` +
        `enumerated, never described (foundation/04, decision 017)`,
    );
    continue;
  }

  const exception = allowList.exceptions.find(
    (e) => e.table === table && e.column === column && e.type === dataType,
  );
  if (exception === undefined) {
    failures.push(
      `spine column ${where} has bare type "${dataType}": outside the spine ` +
        `allow-list (${allowListFile}) and no declared exception — no ` +
        `unlisted type may sit on the spine (foundation/04, decision 017)`,
    );
    continue;
  }

  matchedExceptions.add(exception);
  const block = justifications.get(`${table}.${column}`);
  if (block === undefined) {
    failures.push(
      `spine column ${where} is a declared allow-list exception, but no ` +
        `migration in [${migrationDirs.join(", ")}] carries its ` +
        `justification block ("-- justify-column: ${table}.${column} ...") ` +
        `— every exception answers foundation/04's five-question ` +
        `correlation checklist in the migration that introduces it`,
    );
    continue;
  }
  const missing = QUESTIONS.filter(
    (q) => !new RegExp(`${escapeRegExp(q)}\\s*\\S`).test(block.text),
  );
  if (missing.length > 0) {
    failures.push(
      `spine column ${where}: justification block in ${block.source} is ` +
        `incomplete — unanswered: ${missing.map((q) => `"${q}"`).join(", ")} ` +
        `(foundation/04's correlation checklist; "risk accepted, because —" ` +
        `is a valid answer, absence is not)`,
    );
  }
}

for (const exception of allowList.exceptions) {
  if (matchedExceptions.has(exception)) continue;
  failures.push(
    `allow-list exception ${exception.table}.${exception.column} ` +
      `(${exception.type}) matches no live spine column — a standing ` +
      `permission with nothing under it must be removed from ${allowListFile}`,
  );
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `spine-schema: every spine column is an allow-listed domain or a ` +
    `justified exception (${rows.length} columns checked)`,
);

// --- helpers -----------------------------------------------------------

// Map "table.column" -> { text, source } for every justify-column block
// found in the chain's migration files. A block is the justify-column
// line plus the contiguous comment lines that follow it.
function collectJustifications(dirs) {
  const blocks = new Map();
  for (const dir of dirs) {
    if (!existsSync(dir)) continue;
    for (const name of readdirSync(dir)) {
      if (!name.endsWith(".sql")) continue;
      const path = join(dir, name);
      const lines = readFileSync(path, "utf8").split("\n");
      for (let i = 0; i < lines.length; i++) {
        const match =
          /^\s*--\s*justify-column:\s*([a-z0-9_]+\.[a-z0-9_]+)/.exec(lines[i]);
        if (!match) continue;
        const body = [];
        for (let j = i + 1; j < lines.length; j++) {
          const line = lines[j];
          if (!/^\s*--/.test(line)) break;
          if (/^\s*--\s*justify-column:/.test(line)) break;
          body.push(line.replace(/^\s*--\s?/, ""));
        }
        blocks.set(match[1], { text: body.join("\n"), source: path });
      }
    }
  }
  return blocks;
}

function escapeRegExp(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function psql(sql) {
  const out = execFileSync(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      "spine",
      "psql",
      "-v",
      "ON_ERROR_STOP=1",
      "-U",
      "identity",
      "-d",
      "spine",
      "-tA",
      "-c",
      sql,
    ],
    { encoding: "utf8", stdio: ["pipe", "pipe", "inherit"] },
  ).trim();
  return out === "" ? [] : out.split("\n");
}
