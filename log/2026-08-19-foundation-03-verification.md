# foundation/03 — clean-context verification

- **Task:** `foundation/03` — Roles and append-only enforcement
- **PR:** #3, branch `task/foundation-03`
- **Head SHA verified:** `20b7d9cb25ffbf30587e9afc35cfd5cbd38d8a27`
- **Verifier:** clean-context session, 2026-08-19. Inputs: the task file, the
  PR diff, `plans/foundation/LAYER.md`, `plans/ORDER.md`, the PR body. No
  implementer transcripts.
- **Environment:** fresh clone of the PR head into a scratch directory, no
  cloud credentials in the environment; both compose planes booted from empty
  and migrated (`0001`, `0002`) before every probe.
- **CI:** run 32301617898 at the head SHA, `completed success`; every job
  green (metadata, red-path fixtures, lint, go, ts, db replay + typegen, all
  stages).
- **Verdict: PASS.**

## Criterion 1 (task; layer criterion foundation-1) — append-only enforced by the database

The application role cannot UPDATE or DELETE any table outside the enumerated
exemption list; a later table inherits the restriction with no manual step;
the exemption list is asserted explicitly.

- `node test/append-only.test.mjs` — 18 assertions passed on both planes
  (grant set equals the empty EXEMPTIONS list; no column-level UPDATE grants;
  role boxed in; raw mutations denied; SELECT/INSERT work; inheritance in the
  existing schema and under a second owner in a second schema; SECURITY
  DEFINER scan; incompatible-pair sweep). Exit 0.
- Raw `UPDATE public.schema_migrations SET name = name` and
  `DELETE FROM public.schema_migrations` as `identity_app` via psql:
  `ERROR: permission denied for table schema_migrations`, exit 1 — on spine
  and repeated on payload.
- Verifier's own scratch "later migration": as owner, created
  `public.v_public_rows` on **both** planes with no grant step. As
  `identity_app`: INSERT and SELECT succeeded; UPDATE, DELETE, and TRUNCATE
  each failed `permission denied`. `COPY ... FROM STDIN` as the app role
  succeeded, which is correct — COPY FROM requires only INSERT and is an
  append path.
- Verifier's own second schema under a second owner (`v_schema` /
  `v_owner NOLOGIN`), set up per the once-per-schema pattern in migration
  0002's header, on both planes: table created by the second owner inherited
  SELECT/INSERT-only with no per-table step; UPDATE and DELETE denied.
- Exemption gating, probed independently: `GRANT UPDATE ON
  public.v_public_rows TO identity_app` on payload made
  `test/append-only.test.mjs` exit 1 ("mutation grants do not equal the
  exemption list"); adding a matching entry to `EXEMPTIONS` made it pass;
  revoking the grant and reverting the edit restored green. Adding an
  exemption therefore requires editing the standing proof.

## SECURITY DEFINER bodies contain no UPDATE/DELETE

- Independent catalog query on both planes: zero SECURITY DEFINER functions
  exist outside system schemas; independent regex over `prosrc` returned
  nothing.
- Planted my own `SECURITY DEFINER` function containing DELETE on spine: my
  own grep found it, and the shipped test failed on it
  (`contains DELETE; such functions may only INSERT`). Dropped; green again.

## No serving process has access to owner or migration credentials

- The check's definition (`checks/serving-credentials.mjs`): a serving
  process is code in the runtime trees `surfaces/` and `core/`, excluding
  `core/gen/` and Go test files; the owner credential is the compose
  `identity` user, matched as DSN, `user=`, `-U`, `PGUSER`, and
  `POSTGRES_PASSWORD` shapes.
- Baseline run: 2 runtime-tree files scanned, no credential, exit 0. Planted
  an owner DSN in `surfaces/` and a `PGUSER=identity` shape in `core/`: each
  failed with the file and line named, exit 1; removed, green.
- Database-side half re-run: `identity_app` holds no escalation attribute, no
  role membership, and `SET ROLE identity` is denied.
- Honesty judgment: for a pre-server repo the definition is honest — it is
  the only mechanical form the criterion can currently take, and the check's
  own comments say it is shaped to catch the first violator rather than
  claiming completeness. It is gameable in principle (string-assembled or
  env-injected credentials evade a static grep); the database-side boundary
  and human review cover that residue today, and a deployment-level control
  should join it when a real serving process exists — the migration header
  already points real credentials at the managed-Postgres founder gate.

## Incompatible schema pairs

- Declared my own TEST pair, not the shipped fixtures: schemas `v_left` /
  `v_right` with disjoint owners and disjoint readers on both planes, added
  `["v_left", "v_right"]` to `db/incompatible-schema-pairs.json`. The
  shipped test swept it (1 declared pair + the planted probe pair) and
  passed; manual joins as every defined non-superuser role (`identity_app`,
  `v_owner`, `v_left_owner`, `v_right_owner`) each failed
  `permission denied for schema ...` on both planes.
- Planted my own query touching both members (`db/verifier-planted-join.sql`):
  `checks/cross-schema-queries.mjs` exited 1 naming the file; removed, exit 0.
- All probes reverted; databases reset from empty and re-migrated afterwards.

## Shipped red paths, re-run

- `make check-red`: red paths 1–6 all fail as required (5 and 6 are this
  task's: planted owner credential; planted cross-schema query against the
  fixture pair list).
- `make check-red-db`: planted schema drift fails typegen; planted
  unenumerated `GRANT UPDATE` fails the append-only test; planted mutating
  SECURITY DEFINER function fails it; databases left as found and the final
  green run passes.

## Scope

No scope creep. The diff contains the migration, the standing proof, the two
checks, the declared-pairs list, red-path fixtures, and the CI/Makefile/
eslint/prettier wiring those artifacts require. The task file itself is
untouched by the diff (the fence held).

## Judgment calls, assessed

- **Named exemptions deferred to their own migration sites, list empty** —
  matches the spec's own words ("each licensed ... at its own migration
  site"); the mechanism (documented license + enumerated EXEMPTIONS) ships
  here and was proven to gate. Sound.
- **Superusers excluded from the pair-join sweep** — a superuser bypasses the
  ACL layer, so "fails at the permission layer" is not a statement Postgres
  can make about one; the compose owner is a superuser. The exclusion is
  disclosed and complemented by the credentials boundary. Sound.
- **Once-per-schema default-privileges pattern rather than an event
  trigger** — Dispatch's pattern adopted verbatim in structure as the spec
  directs; "no manual step" is the per-table claim and that is what the test
  proves, including under a second owner and schema. A future migration that
  forgets the pattern fails closed (the app role gets nothing, not too much).
  Sound.
- **`test/append-only.test.mjs` versus the spec's literal
  `test/append-only.test`** — the repo's dependency-free Node `.mjs`
  convention appended to the spec's name; lint globs updated to cover it.
  Acceptable.
- **`identity_app` naming, throwaway local password, sequence USAGE/SELECT,
  plane-agnostic 0002, per-file lint granularity, red-path placement** — each
  derived from an existing name or landed precedent, disclosed in the PR
  body, and within the spec. Sound.

## Result

All mechanical criteria re-run and pass at
`20b7d9cb25ffbf30587e9afc35cfd5cbd38d8a27`. **PASS.**

## Delta re-verification at review-fix head `eef3d59cad502bb8c9a9a4b5e06e5edbb42d7530`

Two review-fix commits landed after the pass above (`1f3559b`, `eef3d59`).
Delta re-verified by the same clean-context verifier, 2026-08-19, from a
fresh clone at `eef3d59`.

- **Diff `20b7d9c..eef3d59` is exactly the review fixes, nothing else.**
  Three files: `test/append-only.test.mjs` — the grant sweep now includes
  sequences (relkind `'S'` with the sequence-kind default ACL in the
  `acldefault` comparison), owner-implicit entries filtered so an owner's
  legitimate sequence UPDATE never trips it; `Makefile` — red path db 2b, a
  planted `GRANT UPDATE ON SEQUENCE ... TO identity_app` must fail the test
  until dropped; `checks/serving-credentials.mjs` — doc comment softened to
  claim only literal-shape (lexical) detection, naming the database-side
  role restriction as the enforcement layer. The PR body's criterion-4
  paragraph carries the matching correction ("lexical lint ... early alarm
  and not the boundary"). No scope creep.
- **CI:** run 32303639592 at `eef3d59`, `success`, every job green.
- **Re-run:** `make check` green from the fresh clone (includes the standing
  proof, 18 assertions on both planes). `make check-red` — red paths 1–6
  all fail as required. `make check-red-db` — planted drift, planted table
  grant, **planted sequence grant (red path 2b, spine)**, and planted
  mutating SECURITY DEFINER function each fail the check; databases left as
  found.
- **Independent sequence probes, on the other plane from the shipped red
  path:** verifier's own `CREATE SEQUENCE v_seq; GRANT UPDATE ON SEQUENCE
  v_seq TO identity_app` on **payload** made the test exit 1 ("mutation
  grants do not equal the exemption list"); dropped, green. An
  owner-created sequence with its implicit UPDATE, exercised with a real
  `setval`, did **not** trip the sweep — 18 assertions, exit 0.

**Delta verdict: PASS at `eef3d59cad502bb8c9a9a4b5e06e5edbb42d7530` —
the merged SHA is the verified SHA.**
