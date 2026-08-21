# trust-kernel/02: head re-verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, the trust-kernel layer file, PR #18's diff and
body, and the running system.

## Why this record exists

The task frontmatter carried `status: done` and
`verified_by: clean-context-verifier@2026-08-21` recorded against head
`898d61621f4a4a2186aa81a23c9388ed7c677b8e`. Six code-review fixes landed
after that record, in `bb58123`, and PR #18's head is now
`a6207056986e3a8ee126e9ecc4dfd7b5b790a67f`. A `done` recorded against the
pre-fix head does not cover the current code, so this re-verification runs
every criterion again at the new head and re-probes each of the six fixes.
It supersedes the prior record, which stays in place as the account of the
`898d616` head it named.

Implementation head verified:
`a6207056986e3a8ee126e9ecc4dfd7b5b790a67f` (PR #18, branch
`task/trust-kernel-02`). This is a merge of `bb58123` (the six fixes) over
`80fd83d` (the prior verify commit) over `1cd626b` (the original feature).
The post-`done` diff `1cd626b..a620705` is twenty-one files.

Environment: an isolated worktree, `pnpm install --frozen-lockfile`,
databases through `docker compose exec` on this worktree's own compose
project. `make check` drives `migrate-verify`, which resets both planes
from empty, so no planted state from a probe survives into the graded run.

Verdict: **PASS**. Every acceptance criterion discharged at the new head,
the Outside check run adversarially, all six fixes re-probed and holding.
Two observations recorded, neither fatal to a criterion.

## Precondition

```
make check        -> exit 0, "check: green"
make check-red    -> exit 0, "check-red: all red paths fail as required"
make check-red-db -> exit 0, "planted violations fail as required and the
                     databases are left as found"
```

`make check` runs the two new database stages (`signing-test` before the
databases, `keylog-test` after `person-test`) and the `signing-seam` stage
inside the metadata group (`27 Go file(s) scanned`).

## Criteria

Task `satisfies: [5]`. Layer criterion 5: no code path outside the kernel
can produce a signature, and no non-operator party key is invokable, both
enforced structurally rather than by a runtime check. The task's own three
acceptance clauses are verified alongside it.

- **Layer criterion 5 (signing seam):** `node checks/signing-seam.mjs` ->
  `27 Go file(s) scanned, no signing primitive outside the kernel`, exit 0.
  The no-key-parameter half is structural and proven by red path 18
  (`kernel.Sign` takes no key argument; the fixture that supplies one does
  not compile), which fired in `make check-red`.
- **AC 1 (compromise cut, mechanical):**
  `go -C core test ./kernel -run TestSignatureValidAcrossTheRuleBoundaries`
  -> PASS, 21 subtests covering strictly-before / at / strictly-after every
  comparison the rule makes, down to nanosecond distance, plus four
  cross-party and cross-key rows.
  `TestABackdatedCompromiseClaimInvalidatesNothing` (the Outside check's
  adversarial case) -> PASS. Over the live spine,
  `TestTheCompromiseCutHoldsOverRowsReadBack` -> PASS (6 subtests, one at
  microsecond distance through the round trip).
- **AC 2 (provider swap is config-only):**
  `GRAIN_KEY_PROVIDER=software go -C core test ./kernel/operatorkey/...` ->
  ok; `GRAIN_KEY_PROVIDER=stub-kms ...` -> ok. Falsified adversarially: an
  unknown provider name takes the whole suite red rather than defaulting
  (see finding 5 below).
- **AC 3 (rotation invisible, mechanical):**
  `TestRotationIsInvisibleToCallers` -> PASS: a byte-identical `kernel.Sign`
  call on both sides of a rotation, the post-rotation record naming the new
  key, the pre-rotation record still verifying, the two keys distinct.
- **The log, against the live spine:** `go -C core test -tags db
  ./kernel/keylog/...` -> ok, every subtest passing, including the
  append-only posture, the write-once primary key, the closed vocabulary,
  and the serving role unable to supply `ledger_ts`.

## The six fixes, re-probed

1. **Signing seam catches aliased and dot imports.**
   `checks/signing-seam.mjs` now binds the qualifier from the
   `crypto/ed25519` import rather than matching the literal `ed25519.`
   text, and refuses a dot import outright. Red path 21 points it at
   `test/fixtures/redpath/signing`, which now carries `aliased.go`
   (`import ed "crypto/ed25519"` then `ed.Sign`/`ed.GenerateKey`/
   `ed.NewKeyFromSeed`) and `dotimported.go` (`. "crypto/ed25519"` with a
   bare `Sign(...)`), alongside the original `planted.go`. Run directly:
   the red fixture reports all seven violations and exits 1; the green
   fixture (`verifier.go`, an aliased import used only for `ed.Verify`, and
   a method named `Sign` on a local value) scans clean and exits 0. The
   full-repo scan is clean at 27 files.

2. **Cross-party key retirement is refused (the fix flagged most.)**
   In `core/kernel/keyevent.go`, `SignatureValid` skips any event whose
   `PartyID` or `KeyID` does not match the record's
   (`if event.PartyID != partyID || event.KeyID != keyID { continue }`), so
   a stranger appending `revoked`/`compromised`/`rotated` under its own
   `party_id` folds into nothing for the owner. `keylog.Events` predicates
   its SELECT on `party_id = $1 AND key_id = $2`, so the read is scoped by
   the pair too, and 0006's primary key is `(party_id, key_id, event)` so
   the stranger's rows take no conflict writing.
   `TestAnotherPartyCannotRetireThisPartysKey` (kernel) and
   `TestOnePartyCannotRetireAnotherPartysKey` (live spine) both PASS: the
   owner's signatures stay valid across the stranger's whole attack, and the
   stranger's own unregistered key is never valid.

3. **Registration folds to the latest, closes and compromise to the
   earliest.** In `SignatureValid`, `KeyRegistered` folds through
   `latest(...)` and `KeyRotated`/`KeyRevoked`/`KeyCompromised` through
   `earliest(...)`, each the direction that cannot widen validity.
   `TestDuplicateEventsFoldInTheDirectionThatCannotWidenValidity` -> PASS:
   two registrations keep the later window start, two closes keep the
   earlier end, two compromise reports keep the earlier cut.

4. **Timestamps cross as epoch microseconds; a sub-hour zone reads
   identically; an unparsable field hard-errors.** `keylog.go` renders each
   timestamptz through `ledgerTSExpr` as
   `(extract(epoch FROM col) * 1000000)::bigint`, one spelling in every
   session. `TestTimestampsSurviveASubHourSessionTimeZone` -> PASS: after
   `ALTER DATABASE spine SET TimeZone TO 'Asia/Kolkata'` (+05:30) the same
   row reads back as an equal instant, and the test restores the zone in
   `t.Cleanup`. `parseLedgerTS` returns an error on any non-integer field
   and never a zero time, so an unparsable value propagates out of `Events`
   rather than reading as "no event recorded" (the permissive answer for a
   compromise report). This last path is enforced by reading; no test
   drives it, since the query only ever yields the integer expression.

5. **The suite fails if it ran against a provider other than the
   configured one.** `TestTheSuiteRanAgainstTheConfiguredProvider` reads
   `keys.ConfiguredProviderName()` and asserts the built provider's name
   matches; it runs (not skips) whenever `GRAIN_KEY_PROVIDER` is set. Probed
   directly: `GRAIN_KEY_PROVIDER=hardware-token go -C core test
   ./kernel/operatorkey/` takes the suite red (`unknown provider
   "hardware-token"`), so a mismatch cannot pass. The getenv-else-software
   block was lifted into `keys.ConfiguredProviderName()` and the five prior
   copies (deletion, envelope and deletion db tests, the person harness, the
   operatorkey suite) now call it; the `set` boolean is what the guard uses
   to tell "asked for software" from "asked for nothing". This refactor is
   responsive to the finding, not scope creep.

6. **`checks/ledger-stamp-grant.mjs` asserts the column-scoped INSERT and a
   blanket grant fails it.** `node checks/ledger-stamp-grant.mjs` -> exit 0
   on the migrated spine. Probed adversarially, matching red path db 11:
   `GRANT INSERT ON ALL TABLES IN SCHEMA public TO identity_app` takes the
   check red (`identity_app holds a TABLE-level INSERT grant ... reopened
   backdating`); restoring the column-scoped grant returns it green. Red
   path db 11b (revoking a writable column's INSERT also fails it) fired in
   `make check-red-db`, which ended leaving the databases as found. The
   check is registered as the `ledger-stamp-grant` stage in `make check`.

## Outside check

Run as the task names it: the boundary-case table, plus the adversarial
backdated-compromise case, over both the pure rule and rows read back from
the live spine. History is not retroactively invalidated: a compromise
reported today (its `ledger_ts` today, its `effective_at` a year back)
invalidates nothing already stamped, proven at nanosecond distance in the
kernel and at microsecond distance through the round trip. The cross-party
denial the prior record raised as finding 3 is now closed by fix 2 and was
re-attacked here from both the kernel and the database.

## Observations (neither fatal to a criterion)

1. **Stale evidence lines in the task frontmatter, corrected on this pass.**
   The `test:` evidence line named `TestARepeatedEventKindTakesTheEarliest`,
   which the fixes renamed to
   `TestDuplicateEventsFoldInTheDirectionThatCannotWidenValidity` (its
   fold direction is no longer uniformly "earliest"); the `diff:` and
   `check:` lines pointed at `1cd626b0`. Evidence is a fence-writable field,
   so these are updated to the current head as part of the pass.

2. **Finding 4's unparsable-field path has no test.** The hard-error is
   correct by reading, but nothing exercises it, because the SELECT only
   returns the integer expression. Left as an observation; the rule the log
   feeds does not depend on it.

## Record integration

The PR branch `task/trust-kernel-02` is checked out in a second worktree,
so this verifier could not commit onto it directly. The pass commit is made
on branch `verify/trust-kernel-02` at the verified head and reported for
fast-forward integration onto the PR branch.
