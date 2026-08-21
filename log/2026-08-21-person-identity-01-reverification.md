# person-identity/01: clean-context reverification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, PR #14's diff and body, and the running system.

Why a second record. The first verification
(`log/2026-08-21-person-identity-01-verification.md`) passed at
`85ab176ef3c18c565ddffab2260c2dfd25bdee0f`. Code changed after it: a
code-review rework moved every SQL path onto `core/transport`, renumbered
the payload migration from `0010` to `0036`, and merged `main`. A
verification records a head, so the reworked head gets its own.

Implementation head verified:
`639adc292c748881376693ce28a648c2c69c4462`. Driven in an isolated
worktree checked out detached at that SHA, working tree otherwise clean.
Sibling worktrees hold compose host ports 5433/5434, so the run used a
`!reset` no-ports override; every database access in this repo goes
through `docker compose exec`, so nothing under test touches a host
port. The override was removed before this record landed, and the
compose file declares no volumes, so a `down` leaves the databases
empty.

Verdict: **PASS**. Every acceptance criterion, and the Outside check.
One finding is recorded below that no criterion and no outside check
reaches, and that a code review should close before merge.

## CI and the standing pipeline

All stages green at the head, run 32509674273, including the `person`
job this task adds to the graph. The PR body still cites run
32501436217 at `a15253c`, three heads back.

Run by the verifier at the head, in this worktree:

- `make check` -> exit 0, "check: green".
- `make check-red` -> exit 0, "all red paths fail as required".
- `make check-red-db` -> exit 0, "planted violations fail as required
  and the databases are left as found".

Green here is a precondition, not evidence for any criterion.

## Criteria

**1. Signup with an email and nothing else yields a usable identity; no
field beyond one verified channel is required anywhere in the path.**
Mechanical. Pass.

Command:
`cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v -run
TestSignupWithEmailAloneYieldsAUsableIdentity ./person/...` -> exit 0,
`--- PASS` in 4.43s.

Type-level half:
`cd core && go test -count=1 -v -run TestEmailAloneIsACompleteRequest
./person/...` -> exit 0, `--- PASS`. A zero `RiskSignals` normalizes to
a valid one, so no caller has to supply a signal to sign up.

Read against the diff rather than taken from the test's own name:
`person.Request` has three fields, and the two that are not the email
channel are a pointer and a string, both zero-valid.
`Channel.normalize` fills line type, carrier reputation and the velocity
threshold when a caller supplies none. The one field that is not
optional is `VerifiedAt`, refused by `Channel.validate` and, on the
payload plane, by `verified_at NOT NULL`. That is the verified channel
itself, not a field beyond it.

**2. A tombstoned id can never be issued again, proven by a test
attempting reuse against the generator and the table.** Mechanical.
Pass.

Command:
`cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v -run
TestTombstonedIDIsNeverIssuedAgain ./person/...` -> exit 0, `--- PASS`
in 2.51s. Generator half without a database:
`cd core && go test -count=1 -v -run
'TestNewIDIsRandomVersion4|TestIDsDoNotSortByIssuanceOrder'
./person/...` -> exit 0, both `--- PASS`.

Both sides the criterion names are attacked, not merely asserted:
`person.NewID` reads `crypto/rand` alone, so no input steers it at a
spent id, and the batch of 20000 is unique, valid, and never the spent
id; the `person` primary key refuses a second INSERT of a spent id as
`identity_app` and as the owner. The verifier's own attempts are in the
outside-check transcript below.

**3. PH mobile signups carry the elevated assurance marker; US mobiles
do not.** Adjudicated, with a mechanical run behind it. Pass.

Command:
`cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v -run
TestAssuranceFollowsTheLine ./person/...` -> exit 0, `--- PASS` in
8.03s. Rule as a table:
`cd core && go test -count=1 -v -run TestAssuranceRule ./person/...` ->
exit 0, `--- PASS`.

Judged from the criterion and the diff: `person.Assurance` returns
`ph-sim-registered` exactly when the channel is a phone, the line type
is `mobile`, and the country is `ph`; every other channel gets
`channel-control`. `channelRow` writes that result and the country from
the same `RiskSignals` value, so the pair cannot disagree at the write
site. What would have failed this: an email channel on a PH account
picking up the marker, a US mobile picking it up, or the marker being
derived at read time from rules that can move under a stored row. None
of those hold. Three accounts were signed up through the real path,
drained, and read back, and the email channel on each PH account came
back `channel-control`.

## Outside check

Run as written, as an attack rather than a reading. An email-only
identity was created through the real path (`Signup`, no display name,
no phone, zero `RiskSignals`), the outbox drained, and every row read
back as the owner role.

Identity created: `59109bc6-9a52-4a97-8e10-7e69c01bbd31`.

**Absent optional data, not defaulted data.**

```
person_record:            display_name_ciphertext NULL, residency_region us
person_contact_channel:   one row, channel_kind email, line_type email,
                          line_country NULL, carrier_reputation unknown,
                          velocity_observed 0, velocity_threshold 5,
                          assurance channel-control, residency_region us
person (spine):           person_id + created_at, nothing else
person_lifecycle_transition: one row, state active
```

No phone row exists, the display name is NULL rather than an empty
string, and the country is NULL rather than a placeholder.

**Id reuse, attempted seven ways.** Every statement below was run
directly against the spine as the named role, outside the package under
test.

```
identity_app  INSERT INTO person (person_id) VALUES (<spent>)
              -> ERROR duplicate key value violates "person_pkey"
identity_app  INSERT ... ON CONFLICT DO NOTHING
              -> 0 rows; the row is not replaced
identity_app  DELETE FROM person WHERE person_id = <spent>
              -> ERROR permission denied for table person
identity_app  TRUNCATE person CASCADE
              -> ERROR permission denied for table person
identity_app  DELETE FROM person_lifecycle_transition ...
              -> ERROR permission denied for table person_lifecycle_transition
identity_app  INSERT INTO person_lifecycle_transition (person_id, state)
              VALUES (<spent>, 'active')
              -> ERROR duplicate key violates "person_lifecycle_transition_pkey"
identity      INSERT INTO person (person_id) VALUES (<spent>)
              -> ERROR duplicate key value violates "person_pkey"
identity      DELETE FROM person WHERE person_id = <spent>
              -> ERROR violates foreign key "person_lifecycle_transition_person_id_fkey"
```

The serving role cannot free the key by any route, and the owner cannot
free it by `DELETE` either, because the lifecycle row references it.
What the owner can do is in finding 4.

**Lifecycle state is not an updatable column.**

```
identity_app  UPDATE person_lifecycle_transition SET state = 'tombstoned' ...
              -> ERROR permission denied for table person_lifecycle_transition
identity_app  UPDATE person SET created_at = now() ...
              -> ERROR permission denied for table person
```

The schema carries no lifecycle column at all: state is a following row
keyed `(person_id, state)`, so a state is entered at most once and a
second entry conflicts rather than overwriting. The migration grants
nothing beyond the `SELECT`/`INSERT` the serving role already held, and
`make check`'s `append-only` stage passed at this head, which is where
that grant surface is enumerated.

**Hostile free text through the real path.** A display name carrying a
single quote, a backslash-x sequence, a literal `$1`, a SQL comment, a
`DROP TABLE person;` fragment, an astral-plane character and double
quotes was driven through `Signup` alongside an address containing an
apostrophe. Signup succeeded, the drain applied both rows, and full
`pg_dump` output of both planes greps clean:

```
O'Brien                 payload=0 spine=0
DROP TABLE person;      payload=0 spine=0
probe-nasty             payload=0 spine=0
probe-plain@example.test payload=0 spine=0
+639179998888           payload=0 spine=0
```

Content reaches the payload plane only as ciphertext under the person's
own key, and the spine's outbox instruction bytes hold none of it in the
clear.

## Findings

**1. The elevated assurance marker is reachable on a mobile line whose
country is NULL.** Not a criterion failure, and not reachable through
the delivered path, but it falsifies a claim the diff makes twice and
the PR body makes once.

`0036-person-record-and-channels.sql` states: "The elevated marker is
reachable only the way decision 013 describes it: a Philippine mobile
line. The database refuses the marker on anything else, so a write-site
bug cannot quietly promote an account." `core/person/person.go` repeats
it: "The database refuses the elevated marker on anything else." The PR
body states it a third time: "the marker is unreachable on a line that
does not qualify, whatever a write site believes."

The constraint is

```sql
CHECK (assurance = 'channel-control'
       OR (line_type = 'mobile' AND line_country = 'ph'))
```

With `line_country` NULL, `line_country = 'ph'` is NULL, the disjunction
is `false OR NULL` which is NULL, and a CHECK admits everything that is
not false. The verifier drove the whole line vocabulary at the table as
the owner. Every row was refused except two:

```
phone mobile 'ph'  ph-sim-registered  -> accepted (correct)
phone mobile NULL  ph-sim-registered  -> ACCEPTED (should be refused)
phone email/landline/voip/unknown, any country -> refused
phone mobile 'us'  ph-sim-registered  -> refused
phone mobile 'PH'  ph-sim-registered  -> refused
email any                             -> refused
phone mobile 'ph'  gold-plated        -> refused
```

`Signup` cannot produce that row: `Assurance` returns the elevated
marker only when `Risk.Country == "ph"`, and `channelRow` writes
`line_country` from the same field, so the two move together. The
constraint exists for the case where a future write site separates them,
which is exactly the case it does not catch. One-line fix:
`line_country IS NOT DISTINCT FROM 'ph'`, or an explicit
`line_country IS NOT NULL AND`. Until it lands, the two source comments
overstate what the database enforces, which decision 052 calls a review
defect rather than a nitpick.

**2. The landed payload migration is not named by the task's
`migrations` claim.** Frontmatter claims `[0010-person-core]`; the
payload half landed as `0036-person-record-and-channels`.
`checks/migration-numbers.mjs` passes, because it fails only when one
number maps to more than one name and does not require a landed file to
be claimed. `migrations` is outside the fence for the implementer and
for the verifier alike, so the amendment is a `docs(plans):` commit on
main. The migration file says so in its own header. Raised, not fixed.

**3. The PR body has drifted from the head.** Its `## Criteria` section
still says `0010-person-core` on the payload carries `person_record` and
`person_contact_channel`, and its `## Judgment calls` section still
carries the superseded raise arguing that both halves share one number.
The rework settled that question the other way. The body also still
cites run 32501436217 at `a15253c`. The `## Verification` section is
rewritten by this record's commit; the rest is the implementer's to
correct.

**4. The owner role can free a spent id, and can rewrite a lifecycle
transition row.** Recorded so a later reader does not take the reuse
criterion for more than it is.

```
identity  TRUNCATE person CASCADE -> succeeds, cascades to the transitions
identity  UPDATE person_lifecycle_transition SET state = ... -> succeeds
identity  UPDATE person SET created_at = now() -> succeeds
```

`identity` is the migration owner, and the repo's append-only proof
enumerates the grants held by `identity_app` and `identity_purge`, not
by the owner. This is the standing posture across every table on both
planes rather than anything this task introduced, and the same note was
made by the first verification. No serving path reaches it.

## Scope

Every file the diff touches against the merge base is called for by the
task or is the mechanical consequence of one: the two
migrations, the package and its test files, the generated plane
types on both planes and in both languages, the spine allow-list entry
for `person_lifecycle_transition.state` and its red-path mirror, the
`person-test` target, and the `person` CI job with its fan-in entry.

Two edits reach outside `core/person` and both are load-bearing rather
than incidental. `core/outbox` gains an exported `InsertStatement`, so
signup's spine commit runs the same entry statement `Enqueue` does
instead of a second one that merely looks like it, with
`TestInsertStatementIsTheWholeEntryStatement` asserting the statement
whole. The instruction denylist gains `residency_region`, which is what
makes the payload tables' residency default binding rather than
customary, since a flat INSERT rendered from an instruction cannot
subquery for the region. Neither is scope creep; both are the smallest
edit that keeps one fact in one place.

No file in the diff is unexplained by the task, and nothing in the task
is missing from the diff.

## Judgment calls, checked

The PR body's judgment calls were read as claims. Two were tested and
hold: no decisions entry rules a velocity threshold, so
`DefaultVelocityThreshold = 5` is a stated default rather than a policy
choice made against a ruling; and decision 013 puts the escalation
policy with the anti-fraud work, so recording signals without a provider
interface is the scope, not a gap in it. Two are stale rather than
wrong, covered by finding 3. None claimed "None."
