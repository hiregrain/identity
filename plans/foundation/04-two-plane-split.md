---
id: foundation/04
type: task
status: ready
depends_on: [foundation/03]
migrations: [0003-spine-core, 0004-payload-us-bootstrap]
binds:
  - decisions/LOG.md#011
evidence: []
verified_by: null
---

# Two-plane physical split

## Objective

Two physical databases from the first row of data (decision 011): the
global spine and `payload-us` — so the residency seam is real, not a
naming convention.

## Scope

- Two databases with separate migration chains (`db/migrations/spine/`,
  `db/migrations/payload/`) sharing **one global numbering sequence**
  (foundation/02, decision 017); the harness from foundation/02 runs both.
  Both carry the roles/append-only posture from foundation/03. **Payload
  deletion is not a vague exemption here** — `foundation/08` defines
  exactly which payload tables are physically deletable and by which role;
  this task grants nothing.
- `0003-spine-core`: the spine's base conventions — object-ID and
  commitment column domains, ledger-timestamp column, and an **exhaustive
  allow-list of permitted spine column types/domains**, enumerated rather
  than described. "Readable-content type" was never defined, which left
  implementers to invent the boundary: the allow-list is the definition.
- **Any spine column outside the allow-list requires a written
  justification in its migration**, reviewed by a human against
  `foundation/09`'s linkage threat model. The lint cannot prove an opaque
  `bytea` or an id does not encode personal data (decision 017) — the
  justification requirement covers exactly the case the lint is blind to.
- `0004-payload-us-bootstrap`: the payload database's base conventions —
  `residency_region` NOT NULL on every table (enforced by the lint, seeded
  `'us'`), payload rows keyed by spine object ID.
- **The database is authoritative for residency; the column is a checked
  assertion** (decision 017). Two records of one fact needed a rule for
  which governs. The column exists because it is what survives a dump or a
  restore — exactly when the database name is lost — and a check fails any
  row whose column disagrees with the database it sits in, so a
  disagreement is a caught error rather than an open question.
- The **spine schema lint** (CI): allow-listed column types/domains only
  in spine migrations; any text/blob/JSON column outside the allow-list
  fails the build with a message naming the rule (AC-F3's mechanism).
- Connection plumbing: application config holds two connection strings;
  no code path may join across the planes in SQL (cross-plane assembly
  happens in application code, by design). The FDW/dblink ban in
  `foundation/07` is what makes this structural rather than aspirational.
- **The split must be provably physical.** Two schemas behind two
  connection strings would satisfy a naive reading; the acceptance below
  proves separate databases with separate roles and no shared transaction
  boundary.

## Acceptance

- AC-F3 (mechanical, narrowed to what it can prove): a test migration
  adding a column of a type outside the spine allow-list fails CI via the
  lint, and a column outside the allow-list without a justification comment
  also fails. The criterion no longer claims to prove that opaque columns
  carry no personal data — `foundation/09` and human review cover that.
- AC (mechanical): the two planes are separate databases, not schemas —
  proven by showing a transaction cannot span them and that each has its
  own role set.
- AC-F4 (mechanical): a payload table without `residency_region` fails
  the lint; every seeded table carries it NOT NULL; and a row whose
  `residency_region` disagrees with its database is caught by a check.
- AC: both chains replay from empty in CI; the append-only test from
  foundation/03 passes against both databases.

## Outside check

Verifier replays both chains, runs the lint against three planted bad
migrations (spine column of a disallowed type; allow-listed-exception
column with no justification; payload table missing the residency column),
confirms each fails with a message naming the rule, and attempts a
transaction spanning both planes to confirm it cannot open.
