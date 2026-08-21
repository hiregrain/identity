# trust-kernel/02: clean-context verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, the trust-kernel layer file, PR #18's diff and
body, and the running system.

Implementation head verified:
`898d61621f4a4a2186aa81a23c9388ed7c677b8e` (PR #18, branch
`task/trust-kernel-02`). Merge base with `origin/main` at
`d3ef9be`; the task diff is twenty-one files.

Environment: a detached worktree at the implementation head, fresh
`pnpm install --frozen-lockfile`, its own compose project. A sibling
session held the compose host ports 5433 and 5434, so this run used a
port-free compose override supplied through `COMPOSE_FILE` and
`COMPOSE_PROJECT_NAME`, leaving the tree under verification untouched.
Every database access in the repo goes through `docker compose exec`,
so nothing needed a host port.

Verdict: **PASS**. Every acceptance criterion discharged, the Outside
check run adversarially, and three findings recorded below, none of
them fatal to a criterion.

## Precondition

`make check` exits 0 at the implementation head, the full pipeline in
one run, including `migrate-verify`, `signing-test` and `keylog-test`.

```
make check       -> exit 0, "check: green"
make check-red   -> exit 0, "check-red: all red paths fail as required"
make check-red-db -> exit 0, "planted violations fail as required and the
                     databases are left as found"
```

`make check` carries both new stages: `signing-seam` inside the
metadata group (`27 Go file(s) scanned`), `signing-test` before the
databases, `keylog-test` after `person-test`
(`ok github.com/hiregrain/identity/core/kernel/keylog 22.901s`).

## Criteria

**AC 1 (mechanical): a compromise event at T invalidates verification
for signatures ledger-stamped after T and leaves pre-T signatures
valid, proven with a table-driven test across boundary cases.**
**Pass.**

```
cd core && go test -count=1 -v -run 'TestSignatureValidAcrossTheRuleBoundaries|
  TestABackdatedCompromiseClaimInvalidatesNothing|TestTheRuleIsIndependentOfEventOrder|
  TestARepeatedEventKindTakesTheEarliest|TestValidKeyEventKind' ./kernel
-> exit 0; the table runs 19 named subtests, all PASS
```

The table is a table and not a sample: registration, closure and the
compromise report are each exercised strictly before, exactly at, and
strictly after, and the compromise report additionally at one
nanosecond on either side. The database half,
`TestTheCompromiseCutHoldsOverRowsReadBack`, makes the same claim over
rows that made a round trip through the live spine, at microsecond
distance, which is the resolution timestamptz actually stores.

The table was mutation-tested rather than read. Two mutations to
`core/kernel/keyevent.go`, each applied alone and reverted:

```
compromised = earliest(compromised, event.EffectiveAt)   [was LedgerTS]
-> FAIL TestABackdatedCompromiseClaimInvalidatesNothing

recordLedgerTS.After(compromised)   [was !recordLedgerTS.Before(...)]
-> FAIL TestSignatureValidAcrossTheRuleBoundaries/at_the_instant_of_the_compromise_report
   FAIL TestABackdatedCompromiseClaimInvalidatesNothing
```

The tree was restored from a copy taken before each mutation;
`git status` is clean at the head SHA.

**AC 2: provider swap is config-only; suite green under both. Pass.**

```
make signing-test -> exit 0
  GRAIN_KEY_PROVIDER=software  go test -count=1 ./kernel/operatorkey/... -> ok
  GRAIN_KEY_PROVIDER=stub-kms  go test -count=1 ./kernel/operatorkey/... -> ok
```

The variable is load-bearing, not decorative, and that was falsified
rather than assumed:

```
GRAIN_KEY_PROVIDER=hardware-token go test -count=1 ./kernel/operatorkey/...
-> FAIL, three tests, each at the FromConfig call:
   TestConfiguredProviderConformance, TestRotationIsInvisibleToCallers,
   TestAProviderSignsImmediatelyAfterConstruction
```

Every test that takes a provider takes the configured one, so a run
under the wrong name fails rather than quietly using software. The two
providers are also proved distinguishable
(`TestTheTwoProvidersMintDistinguishableIdentifiers`), which is what
stops a swap passing by the two being one implementation twice.

**AC 3 (mechanical): rotation is invisible to callers. Pass.**

`TestRotationIsInvisibleToCallers` passes under both providers as part
of `make signing-test`. The call under test is `kernel.Sign(payload, p)`
byte-for-byte on both sides of the rotation, which is possible because
`kernel.Sign(payload []byte, signer Signer)` has no key parameter
(decision 019). It asserts the post-rotation record names the new key,
the pre-rotation record still verifies, and the two keys differ.
Conformance checks 4 through 6 state the same contract for any future
provider.

**Criterion 5's first half (scope): no code path outside the kernel can
reach a signing operation. Pass, with a finding.**

`checks/signing-seam.mjs` is registered in `checks/run.mjs`'s metadata
group, so it runs in `make check` and in CI. Red path 21 exercises both
directions: the planted fixture fails on all three shapes
(`ed25519.Sign`, `ed25519.GenerateKey`, `ed25519.NewKeyFromSeed`), and
the verify-only green fixture passes, since the lint bans producing a
signature and not checking one. The layer's own wording puts the
enforcement structurally, "by the signing function having no key
parameter, not by a runtime check", and that holds:
`core/kernel/jws.go:63` takes a `Signer` and no key. The lint's gap is
finding 1 below.

The `core/cmd/kernel-adapter` exemption was checked rather than
accepted on the PR body's word: the directory exists at this SHA and
`main.go:212` does call `ed25519.Sign`, with a key handed in over
stdin by the differential harness. Exempting it by path with the reason
written into the check is the honest reading.

**Scope: the key-event log.** `db/migrations/spine/0006-key-event-log.sql`
applies under `migrate-verify` from empty, its two `text` columns carry
the five-question justification block and are mirrored into both
allow-lists, and the grant state is what the migration claims:

```
\dp key_event as identity_app
-> identity_app=r/identity at table level (SELECT only)
   column INSERT (a) on party_id, key_id, event, effective_at only
```

## Outside check

*"Verifier runs the boundary-case table, adds one adversarial case
(backdated compromise claim), and confirms history is not retroactively
invalidated."*

The boundary table is run above. The adversarial work was written by
this session against the live spine, in a probe file added, run, and
deleted (`git status` clean afterwards). Four probes, all passing:

```
go test -tags db -count=1 -v -run TestProbe ./kernel/keylog/...
--- PASS: TestProbeAYearOfHistorySurvivesABackdatedReport (19.07s)
--- PASS: TestProbeACrossPartyReportCannotReachBack (6.56s)
--- PASS: TestProbeAFutureDatedClaimDoesNotPostponeTheCut (5.36s)
--- PASS: TestProbeMicrosecondDistanceSurvivesTheRoundTrip (5.00s)
ok  github.com/hiregrain/identity/core/kernel/keylog 36.238s
```

- A key registered a year ago, four records stamped across that year,
  then a compromise filed today through `keylog.Append` claiming an
  `effective_at` from before the key existed. All four stay valid; a
  record stamped after the report does not.
- A second party filing `compromised` against the first party's key
  identifier cannot reach back: its report is stamped now.
- A compromise claimed effective next year does not postpone the cut
  either. The rule is symmetric in ignoring `effective_at`.
- A ledger stamp 123 microseconds off a round hour survives the psql
  text round trip, and the cut lands on the correct side of it.

The database half of the backdating defence was attacked directly, as
`identity_app`, the serving role:

```
INSERT INTO key_event VALUES (...)                    -> permission denied
INSERT INTO key_event (..., ledger_ts) SELECT ...     -> permission denied
INSERT INTO key_event (..., ledger_ts) VALUES (..., DEFAULT) -> permission denied
COPY key_event FROM STDIN                             -> permission denied
ALTER TABLE key_event ALTER COLUMN ledger_ts SET DEFAULT ... -> must be owner
UPDATE key_event SET ledger_ts = ...                  -> permission denied
DELETE FROM key_event ...                             -> permission denied
TRUNCATE key_event                                    -> permission denied
second 'compromised' for one (party, key)             -> duplicate key
event 'suspended'                                     -> CHECK violation
```

The one legal insert stamped `ledger_ts` at now() while carrying an
`effective_at` 400 days back, which is the split the rule rests on. A
positional insert and a `COPY` both name every column and are therefore
refused, so the column-level grant is not evaded by omitting the column
list.

History is not retroactively invalidated. Confirmed.

## Findings

**1. `checks/signing-seam.mjs` is evaded by an aliased import.** A
package outside the kernel writing `import ed "crypto/ed25519"` and
calling `ed.Sign(...)` passes the check green:

```
node checks/signing-seam.mjs <fixture with an aliased ed25519.Sign call>
-> "1 Go file(s) scanned, no signing primitive outside the kernel", exit 0
```

Not fatal to criterion 5, whose enforcement the layer places on the
signing function having no key parameter, and the check's own posture
is a loud failure on the ordinary case rather than the only layer. It
is recorded because the sibling check the header cites as precedent,
`checks/transport-seam.mjs`, closes exactly this hole by matching the
`database/sql` import as well as the call, and because the header
enumerates what the check cannot catch (a `crypto.Signer` behind an
interface, a third-party library) without naming the cheapest bypass of
the three. Under decision 052 an enumeration that has drifted from what
the code does is a review defect. A code-review item, not a blocker.

**2. The task's evidence line carried a count that did not hold.** It
read "20 boundary cases pass"; the table runs 19 subtests. Corrected in
the bookkeeping commit that follows this record to name the table
rather than count it, which is what CLAUDE.md's no-hand-written-counts
rule asks for.

**3. Nothing binds a compromise report to the key's owner.** Any
`party_id` may file `compromised` against any `key_id`, and the rule
takes the earliest report for a key across parties. Probe 2 above shows
this cannot rewrite history, because the intruder's report is stamped
now, so it is not a backdating hole. It is a forward denial of service
until the registry lands. Out of this task's scope, which states that
`party_id` carries no `REFERENCES` clause because the party table is
not in this graph yet. Raised for `party-registry` rather than against
this diff.

## Scope

Twenty-one files, all called for. The rule and its table, the custody
seam with its conformance suite and both providers, the log package and
its live-database suite, migration 0006 and the generated types and
allow-list entries it forces, the signing-seam check with its red and
green fixtures, the three wirings in `Makefile`, `checks/run.mjs` and
`.github/workflows/ci.yml`, and the task file. Nothing present the task
did not ask for.

The PR body's judgment calls were checked rather than accepted. Call 1
(both conjuncts read `ledger_ts`) is the one it flags for attention and
is discharged by the mutation test above. Call 2 (the grant narrowing
adds no `EXEMPTIONS` entry) is discharged by `test/append-only.test.mjs`
passing 18 assertions inside `make check` and by red path db 10 still
failing as required. Call 5 (`GRAIN_KEY_PROVIDER` reused, the names
imported from `core/keys` rather than copied) is held by the compiler.
Call 9's line figure is the check's own output: `kernel-budget:
core/kernel is 617 lines against a budget of under 3000`. Call 10, the
hand-maintained red-path allow-list mirror that drifts silently, is
real and is left where the implementer left it, noted rather than
fixed.
