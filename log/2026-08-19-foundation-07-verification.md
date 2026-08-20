# foundation/07: clean-context verification

- Task: `foundation/07` (plans/foundation/07-cross-plane-write-consistency.md),
  layer criterion foundation-5
- Head SHA verified: `40620300c9315b567e4997efa5ca4ee897a6970c` (PR #7,
  branch `task/foundation-07`); re-verified at the integration head
  `ad2ad82ab1f6f824691ec5c4f6bb6491c7a7be57`, delta section at the end
- Verifier: clean-context session, 2026-08-19. Inputs: the task file,
  plans/foundation/LAYER.md, the PR diff and body, plans/ORDER.md. No
  implementer transcripts. Environment: fresh clone into an isolated
  scratch directory, no cloud credentials; sibling checkouts held the host
  ports, so the clone ran under a no-ports compose override (established
  precedent), the checks reach Postgres through `docker compose exec`
  and never a host port.
- CI run: all eight jobs green at `4062030…`, including the new
  `cross-plane outbox scenarios` job and the `all stages green` fan-in
  (https://github.com/hiregrain/identity/actions/runs/32308828505).
- Verdict: **PASS**

## Criterion 1: kill between the planes, recover on restart

Ran the full harness (`node test/cross-plane-outbox.test.mjs`) on the fresh
clone: 45 assertions passed. It builds the real worker binary and kills it
at `before-spine-commit` (nothing lands anywhere), `before-payload-apply`
(spine durable, payload untouched, unacknowledged), `mid-payload-apply`
(aborted payload transaction keeps nothing), and `after-payload-apply`
(payload row durable, no acknowledgment). After each kill a plain `drain`,
no flags, no operator action, completed the entry, and the payload row
count stayed 1 across restart and a further drain.

## Criterion 2: same entry twice, one payload row

Harness scenario 5: `apply -entry-id` on an already-acknowledged entry, run
twice, `count(*) = 1` for that entry id. Idempotency is the target table's
UNIQUE `outbox_entry_id` plus `ON CONFLICT DO NOTHING`, so the count
assertion is against the database, not worker logic.

## Criterion 3: permanent failure surfaces through the reconciler

Harness scenario 6 plus my own probe: an entry targeting a missing table
recorded one `'failed'` attempt row per drain (append-only, two drains,
two following rows), `reconcile -threshold 0` printed the QUEUE line naming
the entry plus the ALERT summary and exited 1; after creating the table and
draining (forward-only, no compensation), the reconciler exited 0. Repeated
independently with my own straggler: exit 1 with the entry listed while
stalled, exit 0 on a healthy tree.

## Criterion 4: no FDW/dblink in either chain

Re-ran `checks/cross-plane-constructs.mjs` in both modes green, then every
red path: the planted fixture migration (`0099-planted-fdw.sql`) fails file
mode with three FAIL lines; a live `CREATE EXTENSION postgres_fdw` on the
spine fails `--live`; a live foreign server on the payload plane fails
`--live` via the catalog net; green re-confirmed after each drop.

## Criterion 5: nothing acknowledges before both planes are durable

Harness scenario 7 (6-second stall) plus my own indefinite stall: an owner
transaction held an ACCESS EXCLUSIVE lock with `pg_sleep(600)`; the live
worker sat blocked inside the payload apply and the entry stayed absent
from `cross_plane_acknowledged` at every poll. A failed entry likewise
never appears in the view. The view reports an entry only once an
`'applied'` row exists, and that row is written only after the payload
commit.

## Independent probes beyond the shipped scenarios

- **Two workers, one outbox.** Enqueued 8 entries and ran two `drain`
  processes simultaneously. Result: 8 payload rows for 8 entries (no
  double-apply), no entry with more than one `'applied'` row, the
  `(entry_id, attempt)` primary key made the losing worker's
  acknowledgment insert conflict, and it aborted with exit 1. Safety holds
  under contention; the failure mode is a noisy worker exit, not a
  duplicate. Noted: a drain that dies on that conflict stops processing
  its remaining entries, so the design implicitly assumes one worker at a
  time, with contention degrading to retry, acceptable, worth knowing.
- **Real SIGKILL, not just flags.** Injected a sleep into the
  before-payload-apply window in my clone, SIGKILLed the worker there
  (status 137): spine durable, payload untouched, no acknowledgment; a
  plain restart with the pristine binary completed it, one row. Second
  real kill: SIGKILLed the worker while it sat lock-blocked inside the
  payload apply. Finding: killing the Go process does not kill its
  in-flight `docker compose exec psql` child, which finished its
  BEGIN/INSERT/COMMIT script once the lock lifted, payload committed, no
  acknowledgment, i.e. exactly the modeled after-payload-apply crash
  class; restart re-applied as a no-op (count stayed 1) and acknowledged.
  Every real-kill outcome landed in a modeled crash class and recovered.
- **Append-only with the new tables.** `make append-only` green (18
  assertions, both planes). Direct probes as `identity_app`: UPDATE on a
  `cross_plane_outbox` row, UPDATE on a `cross_plane_outbox_attempts`
  row, and DELETE on an outbox row all fail with permission denied.
- **Standing checks.** `make spine-schema` green at 12 columns, the five
  new spine columns (`target_plane`, `instruction`, `attempt`, `state`,
  `detail`) each carry a five-question justification block in migration
  `0020-cross-plane-outbox` and an allow-list entry naming that
  migration. `go test ./...` green, including the instruction
  quoting/injection unit tests.

## Judgment assessments

- **psql-over-compose instead of a Go driver: accepted, with the caveat
  recorded.** Consistent with the repo's entire existing database access
  pattern and with 05's precedent; a driver is a dependency decision
  nobody has made, and the SQL runs under the real serving role's
  SELECT+INSERT posture. The one behavioral difference my real-kill probe
  exposed, the worker's death does not abort its in-flight psql child,
  is covered by the idempotency and acknowledgment guards, so it is
  honest test plumbing, not a dodge; the driver swap will be its own
  reviewed change when managed Postgres clears its founder gate.
- **Flag-based crash points: honestly discharge criterion 1 together with
  the real-kill probes.** The flags make the three points deterministic
  and nameable; the SIGKILL probes confirm a real kill lands in the same
  crash classes and recovers the same way.
- **Opaque bytea instruction with the ciphertext rule pointed at 05:
  accepted.** Same honesty posture as `spine_commitment` (0003): the lint
  proves type discipline, the justification says plainly it cannot prove
  opacity, and the write-site rule is recorded in the migration that
  future generation sites will be reviewed against.
- **Exit-code reconciler as "alert": accepted.** No alerting
  infrastructure exists; a non-zero exit in a pipeline plus one QUEUE
  line per entry is the minimal honest reading of "surfaces as an alert
  and a queue item", and the 60-second documented default with
  `-threshold 0` in the scenarios is stated at the call sites.
- **Scope:** every file in the diff serves the task; the red-path
  fixture allow-list mirror is explained and required by red path db 5.
  No scope creep found.

## Delta re-verification at the integration head

PR #7 gained a sibling-integration merge commit; the merged head
`ad2ad82ab1f6f824691ec5c4f6bb6491c7a7be57` (merge of origin/main, bringing
foundation/05 into `task/foundation-07`) is now the verified SHA.

- **Merge content.** The combined diff of the merge commit against both
  parents touches exactly three files: Makefile, ci.yml, db/typegen.mjs,
  plus type files regenerated against the merged chains (proven by
  `typegen --check` inside `make check` below). Nothing beyond conflict
  resolution: the Makefile `.PHONY`/`check` chains carry both
  `envelope-test` and `cross-plane-constructs cross-plane-outbox`; ci.yml
  carries the complete `envelope` and `outbox` jobs with `all-green`
  needing both; typegen.mjs holds a single `uuid` mapping whose comment
  cites both introducing migrations (0005 and 0020).
- **Set-diff, both directions.** Enumerated every Makefile target and CI
  job on the main parent (`62b5a70`), the pre-merge branch (`4062030`),
  and the merged head: no target or job present on either parent is
  missing from the merged head, and the merged head contains nothing
  absent from both parents. Nothing dropped, nothing invented.
- **CI at the merged head:** run 32310042148, nine jobs all green at
  `ad2ad82…`, including both acceptance suites
  (https://github.com/hiregrain/identity/actions/runs/32310042148).
- **Re-run on a fresh clone at `ad2ad82…`** (no-ports compose override,
  no cloud credentials): `make check` green end-to-end, envelope suite
  under both key providers (software and stub-kms) AND the outbox
  scenarios (45 assertions), with append-only (18 assertions),
  spine-schema, residency, two-plane-split, and typegen-check all green
  in the chain. `make check-red` and `make check-red-db`: every red path
  fails as required, including db 8/8b, the live FDW on each plane,
  and the databases are left as found.
- **Delta verdict: PASS.** The merged head is conflict resolution only;
  everything verified at `4062030…` holds at `ad2ad82…`.
