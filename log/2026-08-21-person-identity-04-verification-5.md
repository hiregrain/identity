# person-identity/04 verification, fifth pass

Implementation head SHA verified:
`2d041346e09cbebc73f21961ec20f90612040583`
(`fix(person): earlier-of-two-ends and a named conflict target, not a
blanket one`, the fix pass answering the fourth verification's criterion
3 failure and the outbox regression it caught, landed after decision 092).

Verdict: **pass**.

Clean context. The task file, the diff against `main`, decisions 091 and
092, and the PR body were the inputs. Everything below ran in a detached
checkout of the head SHA under a private compose project
(`verify-afdda8`) whose containers carry no host port bindings, since
other verification containers already hold 5433 and 5434. No program in
the tree reads `db/connections.json`, so removing the host ports changes
nothing the suites depend on.

## Precondition

`make check` at the head SHA, exit 0, last line `check: green`. The run
carried this task's own suite (`ok
github.com/hiregrain/identity/core/person 47.639s`) and every other
plane and contract check.

## The two blocking fixes, confirmed from scratch

### Criterion 3 / decision 092: LEAST, not COALESCE

The live view was read directly, not off the diff:
`pg_get_viewdef('person_name_effective')` renders
`LEAST(period_end, lead(asserted_at) OVER (PARTITION BY person_id, use,
representation ORDER BY asserted_at, outbox_entry_id))` for the effective
`period_end`. The `COALESCE` the fourth pass failed on is gone.

The previously-failing shape, driven by verifier-authored
`TestVerifyAfdda8SupersededFutureEndDropsFromCurrent` through the public
API against the live planes: append an official/ABC name with a stated
`period_end` two years out, append a replacement under the same key with
no stated period, drain once.

- `CurrentNames` returns exactly one row, the replacement. The prior name
  with the future stated end is **absent from the employer render**.
- `AllNames` returns both. The prior row is present with an effective
  `PeriodEnd` **earlier than its own stated end** (the successor's
  `asserted_at`), so it stays matchable while withheld.
- The prior row's **raw `period_end` column**, read as the table owner,
  still holds the two-year-out value the caller wrote. Nothing was
  mutated; the end-dating is entirely a read-time derivation.

Decision 091's three shapes, each re-confirmed as its own
verifier-authored probe on rows the derivation had to evaluate
independently:

- `TestVerifyAfdda8FutureEndNoSuccessorStaysCurrent`: a solitary row with
  a future stated end stays current. **Pass.**
- `TestVerifyAfdda8PastEndBesideLiveLeavesOneCurrent`: an expired row
  (past stated end) beside an unsuperseded live row leaves exactly one
  current, the live one. The zero-current-rows defect 091 named stays
  closed. **Pass.**
- `TestVerifyAfdda8NoOverlapInversion`: two rows in one key with both
  windows closed, asserted opposite to their window order, report zero
  current and each keep their own raw `period_end` (neither borrows the
  other's). **Pass.**

The shipped suite's own coverage of the same shapes
(`TestSupersededRowWithAFutureStatedEndIsNotCurrent`,
`TestFutureStoredEndStaysCurrentUntilItPasses`,
`TestPastEndBesideALiveRowLeavesExactlyOneCurrent`,
`TestNoOverlapInversion`) also passed under the full run, but the verdict
rests on the independently authored probes above.

### Regression: the narrowed default ON CONFLICT target

The live constraints were read directly:
`name_index_entry` carries the named `name_index_entry_dedup_key`
(explicit, not Postgres's auto-generated name); `person_record` still
carries `person_record_person_id_key`.

`TestVerifyAfdda8DuplicatePersonRecordErrors`, verifier-authored, run
against an **empty, freshly migrated** payload plane (so no leftover
outbox entry pollutes the count): sign one person up, drain, assert one
`person_record` row. Enqueue a second `person_record` instruction for the
same `person_id` through the ordinary unnamed default apply path, drain.

    drain result: applied=0 failed=1
    person_record rows: 1 -> 1

The duplicate **fails to apply again** rather than silently no-op, which
is the regression the fourth pass caught (a blanket, unspecified
`ON CONFLICT DO NOTHING` swallowed it). One caveat recorded for honesty:
run against a shared, unreset DB the count reads `failed=2`, because the
shipped suite's own `TestDuplicatePersonRecordStillErrorsThroughTheApply
Path` leaves its permanently-failing duplicate in the outbox and every
later `Drain` retries it; on an empty DB the count is exactly 1. This is
a test-isolation property of `Drain`'s global retry, not an
implementation defect.

No other outbox-written table's idempotency changed, confirmed at the
render boundary by `TestVerifyAfdda8DefaultConflictTargetIsNarrow`: an
unnamed `Instruction` renders `ON CONFLICT (outbox_entry_id) DO NOTHING`
with no `ON CONSTRAINT`, and only a named `ConflictConstraint`
(`name_index_entry`'s) renders `ON CONFLICT ON CONSTRAINT
name_index_entry_dedup_key`. Source-side, `core/person/name.go`'s
`enqueueRow` passes `""` for `person_name` and `document_name` and the
named constant only for `name_index_entry`, so the opt-in reaches exactly
one table.

## The earlier criteria, re-confirmed

The full shipped `-tags db` suite passed at the head SHA
(`ok core/person 51.567s` standalone; `47.639s` inside `make check`),
covering the criteria the fix did not touch:

- Criterion 1, mononym round-trip and the MRZ no-`<<` named test:
  `TestMononymMRZWithNoDoubleFillerIsNotSplit`,
  `TestMononymRoundTripsWithoutAnEmptySurname`. **Pass.**
- Criterion 2, index regeneration reproduces exactly and is idempotent
  across two `WriteIndex` calls:
  `TestNameIndexRegenerationReproducesExactly`,
  `TestWriteIndexTwiceLeavesTheStoredSetUnchanged`. **Pass.**
- Criterion 4, CJK three representations render per purpose:
  `TestCJKThreeRepresentationsRenderPerPurpose`. **Pass.**
- Criterion 5, over-bound input rejected loudly, no silent truncation:
  `TestNameTextOverTheBoundIsRejectedLoudly`,
  `TestOverLengthNameTextIsRejectedLoudlyAtTheServiceBoundary`. **Pass.**

## Scope

The diff extends `core/outbox` with an optional `ConflictConstraint`
field and narrows its default target. The task's Scope section names no
`core/outbox` change, and the fourth pass flagged this. It is the minimal
correct resolution of the task's own `name_index_entry` idempotency
requirement: the alternative it replaces (a blanket target) was itself
the defect, and the opt-in is proven non-expanding for every other table
by the two probes above. Recorded as an observation, not a finding. No
other out-of-scope change is present; the remaining diff is the name
model, migration 0011-names, its generated types, the `person-test`
make target, the task file, and the prior verification records.

## Findings

None blocking.

## Verdict

**pass** at `2d041346e09cbebc73f21961ec20f90612040583`. All five criteria
and the full fixture set hold; both blocking fixes from the fourth pass
are confirmed from scratch.
