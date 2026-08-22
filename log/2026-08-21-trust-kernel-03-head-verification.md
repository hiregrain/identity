# trust-kernel/03: clean-context head verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, the trust-kernel layer file, PR #20's diff and
body, and the running system.

Implementation head verified:
`c8958fa25214c7b4013afa432b2eb549c0dbb2d6` (PR #20, branch
`task/trust-kernel-03`). This is the code-review fix head. Merge base
with `origin/main` at `9818ca0`; the task diff is seventeen files.

Environment: a detached worktree at the implementation head, its own
compose project (`agent-a262cbaaa570598d1-{spine,payload}-1`), Go
1.26.6. `make check` was run end to end and reports `check: green`.

## Rebase and prior-verifier state

The task message stated the branch was rebased onto current
`origin/main`. It was not. `origin/main` is at `d6c0f4b` and carries two
commits absent from the PR head: `a6b2c57` (decision 094 entry) and
`d6c0f4b` (contract rule 5 amended to spell the preimage order). The PR
head does not contain decision 094 in `decisions/LOG.md` or the amended
rule 5 in `contract/CONTRACT.md`. This does not affect code correctness:
decision 094 pinned the contract wording to the order the code already
used, and `chain.go` matches it (below). The branch is behind main by
those two documentation commits and should be brought current before
merge so the shipped tree carries the contract sentence its code is
written against.

The prior verification commit `e88ed10` ("verify(trust-kernel/03): pass
at 99fdbf8"), which set `status: done`, `verified_by`, and added
`log/2026-08-21-trust-kernel-03-verification.md` (202 lines), is not
reachable from the PR head. The rebase dropped it. The current head is
consistent with an unverified task: `status: in_progress`,
`verified_by: null`, no trust-kernel-03 record in `log/`. Fence fields
are coherent with each other and with the absence of a record. The PR
body still carries the prior Verification section, which references head
`99fdbf8` and a log path not present on this branch; that section is a
dangling reference from the rebase and is replaced by this pass.

## chain.go preimage order (decision 094)

`core/kernel/chain.go`'s `Link` computes
`SHA-256(0x02 || prev || canonical(record))`:

    digest.Write([]byte{ChainLinkTag})  // 0x02
    digest.Write(prev[:])               // prev, 32 bytes
    digest.Write(canonical)             // canonical(record)

This is exactly the order decision 094 pinned into contract rule 5.
`TestLinkPreimageIsTagPrevCanonical` computes the expected digest
independently from the three parts and asserts equality, so the order is
pinned by something other than the implementation calling itself. The
order is unchanged by the code-review fix pass: `c8958fa` touches
`core/streams/streams.go`, its tests, and the `0007` migration only, not
`chain.go`.

## Per-criterion result

All five acceptance criteria are mechanical. Each was run at `c8958fa`
against a fresh migrated spine, not taken from the `make check`
aggregate.

1. Mutated historical record detected at the correct position in every
   stream type. PASS.
   `cd core && go test -tags db -count=1 ./streams/...` (the full
   suite), exit 0. The criterion tests each pass:
   `TestMutatedRecordIsDetectedInEveryStreamType` (ranges over
   `streams.Types`), `TestEveryPositionIsReportedAtItsOwnIndex`,
   `TestMutatedRecordIsDetectedInEveryStreamItBelongsTo`,
   `TestMutatedDeletionJournalRowIsDetected`,
   `TestRemovedRecordIsDetectedAtMinLength`,
   `TestTamperedLinkRowIsDetected`, `TestRemovedLinkRowIsDetected`.
   Teeth confirmed: neutering `VerifyChain` to always return
   `OK: true` made `TestMutatedRecordIsDetectedInEveryStreamType` and
   `TestRemovedRecordIsDetectedAtMinLength` fail (reported
   `OK:true Position:-1` where a divergence at index 1 was required),
   then reverted to a clean working tree.
2. A merge moves no record between chains. PASS.
   `TestMergeMovesNoRecordBetweenChains` and `TestResolutionIssuesNoWrite`
   green in the suite above.
3. An unmerge restores prior resolution with zero chain writes. PASS.
   `TestUnmergeRestoresPriorResolutionWithZeroChainWrites` green.
4. Dropping stream heads and rebuilding reproduces identical heads.
   PASS. `TestRebuildReproducesIdenticalHeads` and
   `TestHeadsMatchTheChainsTheyProject` green.
5. Chain append adds one round trip max (measured). PASS.
   `cd core && go test -tags db -count=1 -run
   TestChainAppendAddsOneRoundTrip ./streams/...`, exit 0. Logged:
   "round trips: unchained 1, chained into three streams 2, added 1".

Frozen-core primitive suite (evidence entry 1):
`cd core && go test ./kernel/...`, exit 0, including the chain tests
(`TestGenesisPrevIsThirtyTwoZeroBytes`,
`TestEmptyHeadIsSixtyFourHexZerosAndMatchesGenesis`,
`TestLinkPreimageIsTagPrevCanonical`,
`TestVerifyChainReportsMinLengthOnAMismatch`,
`TestVerifyChainRefusesAReorder`).

Append-only posture (evidence entry 4):
`node test/append-only.test.mjs`, "append-only: 18 assertions passed on
both planes". The `0007` migration's serving-grant comment names its
enforcement in place: `TestServingRoleCannotRewriteLinks` and
`test/append-only.test.mjs` (code-review finding 2, decision 052).

## Code-review fix pass (three findings at c8958fa)

1. Stage dedup. PASS. `Stage` runs a pre-pass over `record.Streams` that
   validates each stream and rejects a repeat `(Type, Key)` with
   `ErrDuplicateStream` before any `tx.Exec` is issued; only the second
   loop stages links and head moves. A record naming one stream twice
   produces a clean error and zero links, never two.
   `TestStageRefusesADuplicateStreamInOneRecord` (unit: a nil
   transaction is never touched, so the reject precedes any statement)
   and `TestOneRecordChainsOncePerStream` (db: staging `{s, s}` errors
   and `Entries` returns zero rows) both green. Normal multi-stream
   staging is undisturbed: the round-trip measurement over three
   distinct streams still reads "added 1", and the full streams suite is
   green.
2. Migration `0007` serving-grant comment now names its enforcement.
   PASS (read above).
3. Prose counts removed. PASS. `streams.go` header "Three claims" ->
   "The claims"; migration "two reasons" -> "reasons".

## Outside check

Run as written. Mutation in each stream type detected on every affected
stream (criterion 1 tests, which sweep `streams.Types` and run every
mutation as the table owner); merge diffed for membership before and
after with no row moved (criterion 2); unmerge confirmed to issue no
chain write (criterion 3); rebuild diff re-run (criterion 4). The
teeth-check above is the honest attempt to make the mutation suite pass
vacuously; it went red as required.

## Scope

The diff is confined to the chain primitive (`core/kernel/chain.go`,
tests, `doc.go` update), the `core/streams` package and its tests, the
`0007` migration, the round-trip counter in `core/transport`, generated
spine types (`core/gen`, `db/gen`), the spine allow-list and its red-path
fixture, the `streams-test` Makefile target and the CI `per-stream hash
chains` job, and the task file. No existing write path was retrofitted
to chain, which would have belonged to the record-owning tasks. Nothing
present exceeds the task's scope in code.

One process note, not a code finding: the plan body gained a
`## Evidence` prose section inside the implementation diff. The
fence-protected sections (Objective, Scope, Acceptance, Outside check)
are byte-unchanged on the branch; only the `evidence:` frontmatter (a
fence field) and this appended prose section differ. Repo convention is
that plan prose lands on `main` via `docs(...)` commits, not inside a
task branch. Pre-existing and non-blocking for the criteria.

## CI state

The CI run for `c8958fa` (run 32538506234) is not fully green. The
`per-stream hash chains` stage, this task's own stage, is green. Two
stages are red: `signup and id issuance` (`make person-test`) and the
`all stages green` fan-in that depends on it. The person-test failure is
a duplicate-key violation on `person_record_person_id_key` during an
outbox drain redelivery, inside `core/person`, a layer this task's diff
does not touch. The only shared file this task changed is
`core/transport/transport.go`, whose sole change is a thread-safe
`atomic.Int64` increment in `psql()` that cannot introduce a redelivery
race. `make person-test` passed locally twice (inside `make check` and
standalone against a fresh `db-reset`), so the CI red is a flaky failure
outside this task. It does mean the human merge gate ("CI green") is not
yet satisfied: CI should be re-run to green before merge, and the branch
brought current with `origin/main` (decision 094) at the same time.

## Findings

- The claimed rebase onto current `origin/main` did not happen; the
  branch is two documentation commits behind (decision 094). Code
  matches 094 regardless. Bring the branch current before merge.
- The rebase dropped the prior verification commit `e88ed10`; the PR
  body's Verification section is a dangling reference to head `99fdbf8`
  and a missing log path. Replaced by this pass.
- Evidence entry 6 as authored ("every stage green") is currently false
  on CI; corrected in the task file to state the actual CI status.
- CI is red on an unrelated flaky person-test; the human merge gate is
  not met until CI is re-run green.

## Verdict

pass. All five acceptance criteria discharged at
`c8958fa25214c7b4013afa432b2eb549c0dbb2d6`, the outside check run with a
teeth-check, and the three code-review fixes confirmed. Merge is gated
on a green CI re-run and on bringing the branch current with decision
094, neither of which is a criteria failure.
