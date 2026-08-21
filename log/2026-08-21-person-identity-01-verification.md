# person-identity/01: clean-context verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, the layer file, PR #14's diff and body, and the
repo protocol.

Implementation head verified:
`85ab176ef3c18c565ddffab2260c2dfd25bdee0f`. Driven in an isolated
worktree checked out detached at that SHA, working tree clean. Sibling
worktrees hold compose host ports 5433/5434, so the run used a `!reset`
no-ports override; every database access in this repo goes through
`docker compose exec`, so nothing under test touches a host port. The
override was removed and the containers taken down before this record
landed, and the compose file declares no volumes, so the databases were
left as found.

Verdict: **PASS**. Every acceptance criterion, and the Outside check.

## CI and the standing pipeline

All stages green at the head, run 32501737594 (metadata, red-path
fixtures, lint, db replay + typegen, go, ts, envelope both providers,
outbox, **signup and id issuance**, deletion mechanics, fan-in). The PR
body cites run 32501436217 at `a15253c`; the head's own run is the one
above, and `85ab176` changes nothing but the plan file's `evidence`
list, which is why the body's `diff:` pointer names the commit before
it.

Run by the verifier at the head:

- `make check` → exit 0, "check: green".
- `make check-red` → exit 0, "all red paths fail as required".
- `make check-red-db` → exit 0, "planted violations fail as required and
  the databases are left as found".

Green here is a precondition, not evidence for any criterion.

## Criteria

**1. Signup with an email and nothing else yields a usable identity; no
field beyond one verified channel is required anywhere in the path.**
PASS (mechanical).

- `cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v
  -run TestSignupWithEmailAloneYieldsAUsableIdentity ./person/...` →
  exit 0.
- `cd core && go test -count=1 -v -run
  'TestEmailAloneIsACompleteRequest|TestRequestValidation|TestValidIDRejectsWhatIsNotOurs'
  ./person/...` → exit 0.

The type-level half holds: a `Request` with only `Email.Address` and
`Email.VerifiedAt` set normalizes to a valid `RiskSignals`, so nothing
beyond the channel is required before the database is reached. The
database half is confirmed independently under the Outside check below.

**2. A tombstoned id can never be issued again, proven against the
generator and the table.** PASS (mechanical).

- `cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v
  -run TestTombstonedIDIsNeverIssuedAgain ./person/...` → exit 0.
- `cd core && go test -count=1 -v -run
  'TestNewIDIsRandomVersion4|TestIDsDoNotSortByIssuanceOrder' ./person/...`
  → exit 0.
- `test/append-only.test.mjs` green on both planes inside `make check`.

Both halves were re-attacked by hand, below.

**3. PH mobile signups carry the elevated assurance marker; US mobiles
do not.** PASS.

- `cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v
  -run 'TestAssuranceFollowsTheLine|TestUnverifiedChannelIsRefused'
  ./person/...` → exit 0.
- `cd core && go test -count=1 -v -run TestAssuranceRule ./person/...` →
  exit 0.

The rule is one publishable sentence, deterministic, and the same
evidence yields the same marker. Widened by hand across the vocabulary,
below.

## Outside check (verifier's own, not the shipped test)

An identity was created through the real `Signup` path with an email and
nothing else (`6c01478f-475e-4235-92b3-53298ad80558`), drained, then
probed with raw psql as both the serving role and the owner. Full
transcript, one line per probe.

**Inspected for absent optional data.** Every optional field is absent
rather than defaulted:

- `person` row present at spine commit with a non-null `created_at`.
- `person_lifecycle_transition` holds exactly `active`.
- `person_record`: `display_name_ciphertext IS NULL` true, residency
  stamped `us`.
- Exactly one channel, `email`; no phone row exists.
- Channel fields: `email | line_country IS NULL | unknown | 0 | 5 |
  channel-control`.
- `address_ciphertext` is 57 bytes of ciphertext; a `LIKE` for the
  address text over the column returns 0.

**Id reuse, attempted every way it could be reached.** The id was
tombstoned as `identity_app`, then:

- `INSERT INTO person` with the spent id as `identity_app` → refused,
  `duplicate key value violates unique constraint "person_pkey"`.
- The same as the owner `identity` → refused, same constraint.
- `INSERT ... ON CONFLICT DO NOTHING RETURNING person_id` → statement
  succeeds and inserts nothing; `count(*)` stays 1 and
  `min(created_at) = max(created_at)`. The id is not reissued by this
  route; the exit status is the no-op's, not an insert's.
- `DELETE FROM person` as `identity_app` → `permission denied`.
- `TRUNCATE person` as `identity_app` → `permission denied`.
- `DELETE` of the tombstone row as `identity_app` → `permission denied`.
- The person row and its `person_tombstoned` view entry both survive.

**Lifecycle state is not an updatable column.**

- `SELECT state FROM person` → `column "state" does not exist`. There is
  no lifecycle column to update; the state is transition rows.
- `UPDATE person_lifecycle_transition SET state` as `identity_app` →
  `permission denied`.
- `UPDATE ... SET recorded_at` as `identity_app` → `permission denied`.
- `UPDATE person SET created_at` as `identity_app` → `permission denied`.
- Re-entering a state already entered → refused,
  `person_lifecycle_transition_pkey`. Write-once holds.
- An invented state value → refused by the CHECK constraint.
- `identity_app`'s grants on the table are exactly `INSERT, SELECT`.

**Assurance marker, attacked at the table.** Every non-qualifying line
was refused by `person_contact_channel_check1`, and the qualifying one
accepted:

- elevated marker on a US mobile → refused.
- on a PH landline → refused.
- on a PH VOIP line → refused.
- on an email channel → refused.
- on a PH mobile → accepted, returns `ph-sim-registered`.
- promotion by `UPDATE` as `identity_app` → `permission denied`.
- an email channel carrying a `line_country` → refused by the sibling
  CHECK.
- a channel row with `verified_at NULL` → refused by the NOT NULL
  constraint.
- a second `person_record` for one person → refused by the UNIQUE
  constraint.

**Hostile content through the whole path.** A display name of
`Robert'); DROP TABLE person_record; --` and an address carrying quotes,
a backslash and a hex escape were driven through `Signup` and the
outbox. Both tables survived, the display name round-tripped byte-exact
under the person's key, and full `pg_dump` data dumps of **both** planes
were grepped clean of the name, the address, and the string
`DROP TABLE person_record`. Sealing before the spine transaction opens,
and hex-literal rendering, are what make this hold; neither plane holds
worker content in the clear.

**Two further refusals worth recording.** An uppercase country code
(`PH`) is rejected rather than silently lowercased, so no caller can
lose the RA 11934 marker on a line that qualifies for it. A request with
a phone and no email is rejected, so signup stays email-primary
(decision 013).

## Diff scope

15 files, and each traces to the scope or to making a criterion
runnable: the two `0010-person-core` migrations, `core/person` and its
three test files, the regenerated plane types on both sides (required by
`typegen-check`), the `person_lifecycle_transition.state` entry in both
the live spine allow-list and the red-path fixture mirror, the Makefile
target, the CI job, and the plan file's `evidence`. No scope creep
found. The plan file edit touches `evidence` only, which the fence
permits.

Two additions are not literally named in the scope and both are argued
in the PR body:

- **`declared_residency_region()`** on the payload plane. An outbox
  apply renders one flat INSERT and cannot carry 0005's subquery, and
  letting the instruction carry a region would let a caller choose it.
  The column default keeps the authority where 0004 put it. Sound, and
  narrower than the alternative.
- **The CI `person` job.** A suite absent from the pipeline graph never
  runs on a PR. Required for the criteria to mean anything on a PR.

## Judgment assessments

- **`assurance` stored rather than derived at read**: sound. The rule is
  deterministic and lives in one function, and the database refuses the
  elevated value on a line that does not qualify, so storage is a record
  of what was decided rather than a second source of truth.
- **The DEK provisioned and content sealed before the spine transaction
  opens**: sound, and forced. Payload rows must ride the instruction as
  ciphertext, so no other ordering exists. The orphan case, a key
  registered for an id that was never issued, protects nothing: no path
  can reach an unissued id and the generator never returns it again.
- **No risk-lookup provider interface invented**: correct restraint. The
  scope asks for a recording site, the signals arrive as request input,
  and an interface with no implementation behind it would be
  speculation.
- **Verified control enforced by `verified_at NOT NULL`**: sound.
  Building a second challenge mechanism here would duplicate
  person-identity/02's and drift from it.
- **`core/person` establishing the layer's package path**: matches
  ORDER.md's naming rule for a layer's first executed task. The
  psql-through-compose seam is held behind two small interfaces, so
  trust-kernel/08's replacement stays one file.
- **`DefaultVelocityThreshold = 5` with no decision behind it**:
  correctly flagged as unruled. The threshold is written to every
  channel row precisely so a later policy is reconstructable against
  accounts that predate it, and a decisions entry supersedes the number
  in one commit.

## Findings

No criterion failed and no probe broke the implementation. Two items for
the executive, neither blocking this verdict.

1. **RAISE, already surfaced by the implementer: the payload half
   carries the same migration number and name as the spine half.**
   `migrations: [0010-person-core]` is fence-protected, so a second
   number was not available to the implementer, and the task's scope
   marks `0010-person-core` `(spine)` while naming the payload row
   without a number. Verified against the check itself:
   `checks/migration-numbers.mjs` keys on (number, name) pairs and fails
   only when one number maps to more than one name, so two files
   declaring the identical pair pass, and they do. The precedent named
   in the PR body is foundation/08's unclaimed `0022`, amended on `main`
   afterwards. Either resolution is one edit and the executive should
   pick; nothing in the diff has to move either way.

2. **Observation, not a defect: the owner role can rewrite a lifecycle
   transition row.** On a fresh person holding only `active`, `UPDATE
   person_lifecycle_transition SET state = 'tombstoned'` as `identity`
   succeeds. This is the repo's standing posture rather than anything
   this task introduced: `test/append-only.test.mjs` scopes its
   guarantee to non-owner roles by design, and the protection is keeping
   owner credentials away from serving. The Outside check's clause is
   met in the sense the scope states it, since `person` carries no state
   column at all and the serving role holds `INSERT, SELECT` alone.
   Recorded so a later reader does not mistake the owner path for a
   hole this verification missed.
