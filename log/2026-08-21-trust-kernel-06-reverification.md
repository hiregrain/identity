# trust-kernel/06 reverification: the harness holds at the post-review head

Verdict: pass.

Implementation head verified: `97871a14ca514df6e925796a3ef2b4c36a6227f2`.

This reverification supersedes
`log/2026-08-21-trust-kernel-06-verification.md`, which read
`7a29679c915aa984d918691ec8a1f26bdce0a2c0`. Seven code-review fixes to
the harness's own integrity landed after that head, so the earlier
`done` did not cover the harness now in the tree. Everything below was
run from scratch at `97871a1` in a clean worktree, tree byte-clean
before and after every plant.

## Preconditions

`make check` was run at this head. It passed green through every stage
this task can affect: `gofmt + prettier`, `go vet + test` (all
`core/*` packages `ok`, including `core/kernel`), `reference-test` (53
assertions), and `differential` (zero divergence over 20108 requests at
the make-chosen seed 1041921727). It then stopped at `db-up` because a
concurrent sibling worktree held host ports 5433/5434; the database
stages connect through `docker compose exec` on container-internal
ports, so the collision is a host-resource artifact, not a defect, and
this task carries `migrations: []` and no database code. Those stages
are green in CI at this exact head (run 32531563892, `headSha`
`97871a1`, conclusion success): "db replay + typegen check", "deletion
mechanics", "cross-plane outbox scenarios", "envelope suite", "signup
and id issuance", "kernel against the reference model", "red-path
fixtures". The precondition is met across the local run and CI together.

## Criteria

Layer criterion 7 (mechanical), first clause: the reference model and
the kernel agree byte-for-byte over fuzzed input.

- AC1 (mechanical), zero divergence over corpus plus fresh random input.
  PASS. Runs, each `reference` against `kernel`
  (`cd core && go run ./cmd/kernel-adapter`):
  - seed 826143902, 20000 fresh, 20108 requests: zero divergence.
  - seed 17, 50000 fresh, 50108 requests: zero divergence.
  - seed 1041921727 (make-chosen inside `make check`), 20108 requests:
    zero divergence.
  - the `differential-red` control, seed 7, 608 requests: zero
    divergence.
  Command: `node reference/harness/differential.ts --impl
  reference="node reference/adapter.ts" --impl kernel="cd core && go run
  ./cmd/kernel-adapter" --fresh <n> --seed <seed>`.

- AC2 (mechanical), a planted canonicalization bug is caught by the
  harness. PASS. `make differential-red`: all seven mutants from
  `mutant.ts --list` (key-order-locale, key-order-utf8, normalize-nfc,
  number-format-fixed, number-format-negative-zero, surrogate-escape,
  surrogate-substitute) caught against both the reference and the
  kernel, fourteen legs, each on exit 2 plus a reported DIVERGENCE line;
  control run green. In `make check-red` as red path 21.

- AC3 (adjudicated), every surfaced ambiguity is resolved in the
  contract or recorded as a known divergence. PASS. Decision 082 rules
  the four ambiguities A1 through A4, written into
  `contract/CONTRACT.md`. A3 superseded preserve-and-escape with
  refusal; both superseded readings are retained as the mutants
  `surrogate-substitute` and `surrogate-escape`, and both were confirmed
  caught in AC2, so the ruling leaves a test behind rather than a
  sentence. What would have failed this: an ambiguity present in
  `reference/README.md` with no corresponding decision-082 clause, or a
  superseded reading with no mutant guarding it.

## Outside check

Independence. No dispatch record exists for this task, so independence
was checked against the tree, not asserted from one. Every import in
`reference/*.ts` and `reference/harness/*.ts` resolves to a Node builtin
or a sibling file under `reference/`; nothing imports `core/` or the
kernel. The only mentions of the kernel in the reference are prose in
comments. The implementer's notes and conversation were not read, by
protocol.

Fresh random input: the seeds above, all zero divergence.

One number-formatting bug planted in each implementation in turn, both
caught, both reverted, tree byte-clean afterward:

- Reference: `ecmascriptNumberToString` made to return `"1.0"` for the
  value 1. `make`-style differential at seed 3, 2108 requests: 56
  divergences, exit 2. Reverted.
- Kernel: `formatNumber` made to return `"0.0"` for zero in
  `core/kernel/number.go`. Differential at seed 5, 2108 requests: 98
  divergences, exit 2, including through the `sign` path. Reverted.

## The seven post-review fixes, re-probed

Finding 1, the harness can no longer pass by testing nothing. Confirmed
closed on both halves.

- Deleting `reference/harness/mutant.ts` now fails `make
  differential-red`. With the file moved aside, `mutant.ts --list`
  cannot load, the mutant list is empty, and the target exits non-zero
  (make error 2) rather than passing. Restored byte-clean.
- A renamed BUGS key cannot silently retire its own leg. Renaming
  `key-order-utf8` to `key-order-utf8-RENAMED` made the new name appear
  in `mutant.ts --list`, and `differential-red` then ran and caught it
  on both sides under the new name. The list is derived from the file,
  so a rename moves a leg rather than dropping it. Reverted.

Finding 4, the generator has a node budget and does not hang. Confirmed.
Over 200000 draws the generator reached max depth 199, max container
width 64, and max node count 301, the last bounded by the per-shape
budget (max 300 plus root). The 50108-request run at seed 17 completed
in seconds, so the deeper and wider generator introduced no
unbounded-size case.

Finding 5, a crash is distinguished from a refusal. Confirmed. On a
lone-surrogate `canonicalize` input, which the reference refuses
(`refused: true`), the harness reports a DIVERGENCE and exits 2 against
a peer that answers with a crash-marked failure, and reports zero
divergence and exits 0 against a peer that answers with a clean
refusal. "Both failed" is agreement only when both refused.

## Findings

None is a criterion failure.

1. Layer criterion 7 has a second clause, "each checkpoint's predecessor
   link verifies", that no part of this task's scope reaches. The task's
   Scope limits it to canonicalization and the JWS envelope; checkpoints
   belong to trust-kernel/04. `trust-kernel/06` is the only task
   declaring `satisfies: [7]`, so the checkpoint clause of layer
   criterion 7 currently has no owner. This outlives the PR and is a
   layer-coverage gap, not a defect in this task.

2. The database stages of `make check` could not be run to completion
   locally because a concurrent worktree held the compose host ports.
   They pass in CI at this head. Recorded so the next reader does not
   read the local stop as a failure.

## Verdict

pass. All three acceptance criteria discharged at `97871a1`; the outside
check's independence, fresh-input, and per-implementation planted-bug
legs all held; the seven post-review harness fixes are each re-probed
and closed.
