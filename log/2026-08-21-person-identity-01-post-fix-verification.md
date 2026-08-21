# person-identity/01: post-fix verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, PR #14's diff and body, and the running system.

Why a third record. The first verification
(`log/2026-08-21-person-identity-01-verification.md`) passed at
`85ab176`, the second
(`log/2026-08-21-person-identity-01-reverification.md`) at `639adc2`.
The second landed a finding: the assurance CHECK compared a nullable
`line_country` with `=`, so a mobile line of unknown country made the
rule neither true nor false and the row went in carrying
`ph-sim-registered`. Commit `93a16e6` fixes that, and a verification
records a head, so the fixed head gets its own record.

Implementation head verified:
`93a16e623c2d1c264730c348ca64d492dc91bd76`. Driven in an isolated
worktree checked out detached at that SHA, working tree otherwise clean.
Sibling worktrees hold compose host ports 5433/5434, so the run used a
`!reset` no-ports override held outside the repo and passed through
`COMPOSE_FILE`; every database access in this repo goes through
`docker compose exec`, so nothing under test touches a host port. The
compose file declares no volumes, so a `down` leaves the databases
empty.

Verdict: **PASS**. Every acceptance criterion, and the Outside check.
One bookkeeping finding is recorded below and is closed by the commit
that carries this record.

## CI and the standing pipeline

All stages green at the head, run 32512932660, including the `signup and
id issuance` job this task adds to the graph. `check-red-db` runs inside
the `db replay + typegen check` job and passed there.

Run by the verifier at the head, in this worktree:

- `make check` -> exit 0, "check: green".
- `make check-red` -> exit 0, "all red paths fail as required".
- `make check-red-db` -> exit 0, "planted violations fail as required
  and the databases are left as found", on a pair of planes reset from
  empty first.

Green here is a precondition, not evidence for any criterion.

## Criteria

**1. Signup with an email and nothing else yields a usable identity; no
field beyond one verified channel is required anywhere in the path.**
Mechanical. Discharged.

- `go test -tags db -count=1 -v -run TestSignupWithEmailAloneYieldsAUsableIdentity ./person/...`
  -> exit 0, PASS in 5.88s.
- `go test -count=1 -v -run TestEmailAloneIsACompleteRequest ./person/...`
  -> exit 0, PASS.

Read against the test source rather than its name: the call passes a
`Request` whose only non-zero content is `Email.Address` and
`Email.VerifiedAt`, then asserts the spine `person` row and its single
`active` transition at commit, an `Encrypt`/`Decrypt` round trip under
the fresh id before any payload row exists, zero `person_record` rows
before the drain, `display_name_ciphertext IS NULL` and
`line_country` absent after it, the stored ciphertext decrypting back to
the address, and the address absent from both the payload dump and the
spine instruction bytes. The verifier reproduced the same shape
independently under the Outside check below.

**2. A tombstoned id can never be issued again, proven by a test
attempting reuse against the generator and the table.** Mechanical.
Discharged.

- `go test -tags db -count=1 -v -run TestTombstonedIDIsNeverIssuedAgain ./person/...`
  -> exit 0, PASS in 3.00s.
- `go test -count=1 -v -run 'TestNewIDIsRandomVersion4|TestIDsDoNotSortByIssuanceOrder' ./person/...`
  -> exit 0, both PASS.
- `node test/append-only.test.mjs`, inside `make check` and again inside
  `make check-red-db` -> exit 0, 18 assertions on both planes.

The table half is the `person` primary key plus the absence of any
delete path: `identity_purge` does not exist as a role on the spine at
all, which the verifier confirmed by attempting to connect as it.

**3. PH mobile signups carry the elevated assurance marker; US mobiles
do not.** Mechanical. Discharged.

- `go test -tags db -count=1 -v -run TestAssuranceFollowsTheLine ./person/...`
  -> exit 0, PASS in 14.72s.
- `go test -count=1 -v -run TestAssuranceRule ./person/...` -> exit 0,
  PASS.

The fix under review is the CHECK in
`db/migrations/payload/0036-person-record-and-channels.sql`, now
`line_country IS NOT DISTINCT FROM 'ph'`. The rule is total rather than
three-valued because both remaining terms sit on NOT NULL columns:
`assurance` and `line_type`. Had `line_type` been nullable the same
defect would have survived on the other conjunct, so this was checked
against the column definitions and not assumed from the comment.

## Outside check

Run as written: "Verifier creates an identity with email only, inspects
the row for absent optional data, attempts id reuse, and confirms
lifecycle state is not an updatable column." Driven by a throwaway
program the verifier wrote against the real `person.Service`, run at the
head and deleted afterwards, plus the specific probe this round was
asked for: a mobile line with NULL country refused the elevated marker.

```
1. signed up with email alone: c68b9293-bcd8-4c06-9296-1acdaaee57af
   spine person row at commit: c68b9293-bcd8-4c06-9296-1acdaaee57af
   lifecycle rows: active
drain: 2 applied, 0 failed, 2 pending seen
2. display_name_ciphertext: NULL
   channels: email|email|NULL|unknown|channel-control
3. reuse INSERT as identity_app: ERROR: duplicate key value violates unique constraint "person_pkey"
3. reuse INSERT as identity: ERROR: duplicate key value violates unique constraint "person_pkey"
   tombstoned: true
   post-tombstone reuse INSERT as identity_app: ERROR: duplicate key ... "person_pkey"
   post-tombstone reuse INSERT as identity: ERROR: duplicate key ... "person_pkey"
4. UPDATE lifecycle state as identity_app: ERROR: permission denied for table person_lifecycle_transition
4. UPDATE lifecycle state as identity_purge: FATAL: role "identity_purge" does not exist
   grants on the two spine tables: identity_app:INSERT, identity_app:SELECT (both tables)
   second 'active' transition: ERROR: duplicate key value violates unique constraint
     "person_lifecycle_transition_pkey"
5. elevated marker on US mobile                -> REFUSED (person_contact_channel_check1)
5. elevated marker on mobile, unknown country  -> REFUSED (person_contact_channel_check1)
5. elevated marker on landline in ph           -> REFUSED (person_contact_channel_check1)
5. elevated marker on voip in ph               -> REFUSED (person_contact_channel_check1)
5. elevated marker on unknown line in ph       -> REFUSED (person_contact_channel_check1)
5. elevated marker on email channel            -> REFUSED (person_contact_channel_check1)
5. elevated marker on PH mobile                -> ACCEPTED
```

What was attempted and failed to break it:

- Id reuse as the serving role and as the table owner, before and after
  the tombstone. Four refusals on the primary key.
- Lifecycle written as a column: there is none. `person` carries
  `person_id` and `created_at` only, and the serving role holds SELECT
  and INSERT alone on both spine tables, so the transition rows cannot
  be edited. A second `active` transition conflicts on
  `(person_id, state)` rather than overwriting.
- The marker probe was widened past the two rows the suite plants, to
  every non-qualifying shape the columns admit: a PH landline, a PH
  VOIP line, a PH line of unknown type, and an email channel. All
  refused. The qualifying shape, a PH mobile, was accepted, so the
  constraint refuses by rule and is not vacuously refusing everything.

## Findings

**The completion claim stood one commit ahead of its record.** At the
head verified, `plans/person-identity/01-signup-and-id-issuance.md`
already carried `status: done`, `verified_by:
clean-context-reverifier@2026-08-21`, and evidence naming `639adc2`,
while `93a16e6` sat on top of it changing a migration, the derivation's
doc comment and the acceptance suite. A schema change under a standing
`done` is exactly the state the fence exists to prevent. Closed by the
commit carrying this record, which re-points `evidence` and
`verified_by` at `93a16e6`.

**Scope.** The diff reaches outside `core/person` in four places, and
each is required by the task's own path rather than added beside it:
`outbox.InsertStatement`, so signup's spine commit runs the same entry
statement `Enqueue` does; `residency_region` in `Instruction.validate`'s
reserved columns, without which an instruction could override the
column default that stamps the region; the spine allow-list entry for
`person_lifecycle_transition.state` with its justification block in
`0010-person-core`, and the red-path fixture mirror of it; and the CI
job, without which the suite would never run on a PR. No scope creep
found.

**PR body claims checked.** The three criterion paragraphs describe
tests that exist and assert what they claim, read against the test
source. "`checks/transport-seam.mjs` is green with no test-file
exemption" holds: the check's only exemption prunes a fixture root, and
no `_test.go` is excluded.
