# foundation/04 — clean-context verification

- Task: `plans/foundation/04-two-plane-split.md` (satisfies foundation criteria 3, 4, 8)
- PR: #4, branch `task/foundation-04`
- Head SHA verified: `1f1fc0bf6957a82fb9fae5c9b2e23a57d950bcb6`
- Verifier: clean-context session, 2026-08-19. Fresh clone; no implementer
  transcripts consulted. CI at this SHA: all seven checks SUCCESS
  (run 32305345776).
- Verdict: **PASS** — every mechanical criterion re-run green, criterion 8
  adjudicated pass.

## Mechanical outcomes (re-run, not re-read)

All commands run in a fresh clone at the head SHA, both planes booted from
empty (`make db-up`; verifier-local compose port override only, host ports
being held by another session — every check connects via
`docker compose exec`, so the override touches nothing the checks use).

1. **Both chains replay; append-only holds on both planes.**
   `make check` → green end to end: root `0001`/`0002` + `spine/0003` +
   `payload/0004` replay from empty twice with identical dumps and a no-op
   second pass (`migrate-verify`), typegen `--check` green,
   `test/append-only.test.mjs` 18 assertions passed on both planes,
   `spine-schema` (3 columns), `payload-residency` (2 tables),
   `two-plane-split` (8 assertions).
2. **Criterion 3 red paths, verifier's own plants** (distinct from the
   shipped fixtures):
   - Planted `probe_bad (data jsonb)` on the live spine →
     `node checks/spine-schema.mjs` exit 1, message naming the rule:
     bare type "jsonb" outside the spine allow-list (foundation/04,
     decision 017).
   - Planted declared exception `probe_exc.raw bytea` (verifier's own
     allow-list copy) with no justification block in any scanned
     migration dir → exit 1, message naming the missing
     `-- justify-column: probe_exc.raw` block and the five-question
     checklist.
   - Green baseline re-confirmed after each plant was dropped.
3. **Physical split.** `test/two-plane-split.test.mjs` → 8 assertions:
   distinct `pg_control_system()` identifiers, neither cluster's
   `pg_database` contains the other plane, a transaction opened on either
   plane aborts on a qualified reference to the other
   (`cross-database references are not implemented`), a probe role created
   on one plane absent from the other, own `identity`/`identity_app` role
   set per plane. Verifier's own additional spanning attempt — an open
   transaction on spine INSERTing into `payload.public.schema_migrations`
   — aborted (psql exit 3, ON_ERROR_STOP); no write landed.
4. **Criterion 4 red paths, verifier's own plants:**
   - Planted `probe_no_res (x integer)` on payload →
     `node checks/payload-residency.mjs` exit 1, message naming the rule
     (every payload table carries `residency_region` NOT NULL).
   - Planted row `residency_region = 'eu'` in `schema_migrations` →
     exit 1: 1 row disagrees with the database's declared `'us'`
     (database authoritative, column checked).
5. **Stale-exception rule.** Verifier's own allow-list carrying a fully
   justified exception `ghost_table.ghost (integer)` matching no live
   column → exit 1: "matches no live spine column — a standing permission
   with nothing under it must be removed".
6. **Shipped red suites.** `make check-red` and `make check-red-db` both
   complete with every planted violation failing as required (including
   red paths db 4–7, this task's) and both databases left as found.

## Criterion 8 adjudication (foundation-8, adjudicated)

> "No spine column can re-identify a person on its own. … a verifier with
> a clean context, given foundation/04's correlation checklist and the
> spine schema alone, finds no spine column from which a person could be
> re-identified without the payload plane."

Judged from the correlation checklist (task file / lint header) and the
spine schema alone — the payload schema was not consulted for this
section. The live spine schema at this head is one table,
`schema_migrations (number integer, name text, applied_at timestamptz)`,
plus three domains with no columns yet (`spine_object_id`,
`spine_commitment`, `spine_ledger_timestamp`).

**Per column, all five questions:**

- `schema_migrations.number` — (1) ordering reveals migration apply
  order, which is a fact about the schema and already public in the
  repository's file listing; no person appears in it. (2) Not a
  timestamp. (3) The only join target is the repository's own migration
  files; there is no person-linked value to join a roster against.
  (4) Not a commitment; no salt. (5) An adversary with a partial external
  dataset learns which migrations ran — public information. The table has
  one row per migration, not per person; there is no subject dimension to
  re-identify.
- `schema_migrations.name` — the one column of a genuinely readable type
  (bare `text`). (1) No ordering beyond `number`'s. (2) Not a timestamp.
  (3)/(5) Values are repository filenames; nothing person-derived reaches
  the column through the migration runner, and the residual risk (a
  future migration named after a person) is a review-time concern on the
  migration itself, not a schema leak. (4) No commitment, no salt.
  Cannot re-identify anyone.
- `schema_migrations.applied_at` — (2) full-precision timestamps reveal
  when the operator ran migrations: an activity pattern of the
  **operator**, not of any subject on the ledger. (1) Duplicates
  `number`'s ordering. (3)/(5) Joinable only to deployment history.
  (4) No commitment. No person on the record is described, so no
  re-identification is possible from it.
- **Cross-column:** number + name + applied_at jointly reconstruct the
  deployment timeline and nothing else; there is no per-person row for
  any external roster to align against.
- **The three domains** carry no columns yet, so nothing to judge live;
  their pre-answered checklists in `0003` correctly bind the reasoning to
  the *purpose* and explicitly defer per-column review to the migration
  that first uses each — they do not claim to discharge future columns.

**Honesty of the written justifications (0001/0003):** each block answers
all five questions specifically rather than gesturing. The strongest
evidence of honesty is what they concede: `name` admits `text` is a
readable type and states why no person-derived value can reach it;
`applied_at` admits full precision reveals operator timing and records
the acceptance with its reason; `spine_object_id` admits the type cannot
enforce UUIDv4 and names generation sites as the review point;
`spine_commitment` admits the lint is blind to what a bytea encodes.
Every "risk accepted" carries a "because". These are examined answers,
not boilerplate.

**Verdict: PASS.** No spine column at this head could re-identify a
person without the payload plane, and the recorded justifications
honestly answer the checklist.

## Judgment calls reviewed

- **No-bare-base-types allow-list** (standing list is only the three
  purpose-built domains; even bare `integer`/`timestamptz` fail): sound.
  Declaring the domain is declaring the purpose the correlation reasoning
  attaches to; bookkeeping handled as justified exceptions keeps the
  standing surface minimal and reviewed.
- **Unpinned commitment length, deferred to trust-kernel via
  `ALTER DOMAIN`**: sound. A length CHECK would silently pin the hash
  algorithm, which no decisions entry has ruled; the deferral is explicit
  in the migration and the PR body rather than chosen quietly, and no
  committing write exists yet to widen the exposure.
- **uuid-v4-as-convention**: sound, and the weakest of the three — a
  convention the type cannot enforce. Acceptable here because no
  generation site exists yet and the migration names the exact failure a
  reviewer must catch (UUIDv7/ULID leaking enrollment order, checklist
  q1). A future mechanical check on generation sites would harden it;
  out of this task's scope.
- Also reviewed and found sound: `residency_region` stamped onto payload
  `schema_migrations` so "every payload table" is literally true with no
  exemption list; the singleton `database_residency` declaration
  (second INSERT conflicts, no UPDATE grant exists); the
  justification-block format documented as the lint's contract with the
  stale-exception rule preventing accumulated standing permissions.

## Scope

Diff (15 files, +844/−10) maps entirely to the task's scope items:
migrations `0003`/`0004`, allow-list, the two checks, the split test,
red-path fixtures, connection plumbing, comment-only justification edit
to `0001` with matching allow-list exceptions, regenerated types, and
CI/Makefile wiring the task called for. No scope creep found.

## Delta re-verification — review-fix head `638a51aa69a4ff426e0190a6662bf7636c86cdef`

One review-fix commit landed after the PASS above (`638a51a`,
`fix(foundation/04): bind exception justifications to the declared
migration file; a decoy block elsewhere is not a match`). Re-verified in
a fresh clone at that SHA; CI green there (run 32306243967, all seven
checks SUCCESS).

**Delta confirmed exhaustive** — three files, nothing else:
`checks/spine-schema.mjs` (an exception's justification now resolves
ONLY from the migration file its `migration` field names, with two
distinct failures: the declared file absent; the declared file blockless,
naming any wrong-file block found), the decoy fixture
`test/fixtures/redpath/spine-schema/decoy/9997-unrelated-decoy.sql`, and
red path db 5b in the Makefile. A PR comment documents the fix. No scope
creep.

**Re-run outcomes:**
- `make check` green end to end at `638a51a` (spine-schema "3 columns
  checked" present; append-only 18 assertions both planes;
  two-plane-split 8 assertions).
- `make check-red-db`: every red path fails as designed, including 5b —
  the decoy block fails with the message naming the decoy file as "not a
  match".
- Verifier's own decoy variant: a real exception
  (`schema_migrations.number`) re-pointed at
  `0002-roles-and-default-privileges` (exists, blockless) while its
  block sits in `0001` → lint exit 1, naming the decoy location
  (`db/migrations/0001-migration-infrastructure.sql ... is not a
  match`). Second variant naming a nonexistent migration file → exit 1
  with the declared-file-absent message. Reverted; baseline green.

**Deviation judged legitimate, not a dodge:** the decoy red path lives
in `check-red-db` rather than `check-red` because the lint iterates live
spine columns from `information_schema` — without the planted live
column, the justification branch is unreachable (the stale-exception
failure would fire instead, which is a different rule). The placement
follows from the lint's structure.

**Criterion 8 stands unchanged:** the delta touches no schema — no
migration, no domain, no column. The adjudication above applies verbatim
at `638a51a`.

**Verdict at `638a51a`: PASS.**
