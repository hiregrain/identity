# trust-kernel/06: clean-context verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, `plans/trust-kernel/LAYER.md` criterion 7, PR #12's
diff and body, decision 082, `contract/CONTRACT.md`, and the running
system.

Implementation head verified:
`7a29679c915aa984d918691ec8a1f26bdce0a2c0` (PR #12, branch
`task/trust-kernel-06`). The last commit touching anything but the task
file is `dc58543`, which is the SHA the task file's evidence cites. The
diff against `origin/main` is twenty files.

Environment: the implementation head checked out detached in this
session's own worktree, fresh `pnpm install --frozen-lockfile`, Node
v24.16.0, Go 1.26.6. Sibling worktrees held the compose host ports 5433
and 5434, so the database stages ran under a port-free compose overlay
passed through `COMPOSE_FILE` and `COMPOSE_PROJECT_NAME`, both entries
absolute, leaving the tree under verification untouched. Nothing in the
repo connects over a host port; every database access goes through
`docker compose exec`.

Verdict: **PASS**. Every acceptance criterion discharged. Six findings
below, none of them a criterion failure; finding 1 is a layer-level gap
that outlives this task.

## Precondition

```
make check      -> exit 0, "check: green"
make check-red  -> exit 0, "check-red: all red paths fail as required"
```

Both green at the implementation head in this session. All thirteen CI
jobs are green on the PR at the same SHA, including the new
`kernel against the reference model` job and the red-path job that now
carries `differential-red`.

## Criteria

### AC1 (mechanical): the harness runs both implementations over the committed corpus plus fresh randomized input with zero divergence

**Pass.** Run at four seeds this session chose, not the implementer's,
plus one the Makefile drew at random:

```
node reference/harness/differential.ts \
  --impl reference="node reference/adapter.ts" \
  --impl kernel="cd core && go run ./cmd/kernel-adapter" \
  --fresh 20000 --seed 20260821
-> exit 0, "zero divergence over 20108 requests"

  ... --fresh 20000 --seed 991137    -> exit 0, 20108 requests
  ... --fresh 50000 --seed 4242424   -> exit 0, 50108 requests
make differential (seed 375195730)   -> exit 0, 20108 requests
make differential (seed 1612192823, inside make check) -> exit 0
```

The kernel leg is live rather than a second copy of the reference: see
AC2, where a bug planted in `core/kernel/number.go` moved the kernel
leg's output and the reference's did not.

### AC2 (mechanical): a deliberately introduced canonicalization bug in either implementation is caught by the harness, not just by the vectors

**Pass.** `make differential-red` exits 0, meaning every planted
misreading was caught and the unplanted control was green:

```
make differential-red -> exit 0
  7 mutants x {reference, kernel} = 14 combinations, each exit 1
  control: reference vs kernel, 608 requests, zero divergence
```

The target's `for` loop suppresses output and only asserts a non-zero
exit, so this session re-ran all fourteen with output kept, to rule out a
mutant that fails by crashing rather than by diverging. Every one
produced real `DIVERGENCE` reports and a `FAIL differential: N
divergence(s)` line: 6, 59, 63, 17, 65, 69 and 69 divergences over 608
requests for `key-order-utf8`, `key-order-locale`, `number-format-fixed`,
`number-format-negative-zero`, `normalize-nfc`, `surrogate-substitute`
and `surrogate-escape`. The counts are identical against the reference
and against the kernel, which is itself corroboration that the two agree
exactly.

## Outside check

> Verifier confirms from the task's dispatch record that the reference
> author had no kernel access, runs the harness on fresh random input,
> and plants one number-formatting bug in each implementation in turn to
> confirm detection.

**Kernel access.** No dispatch record for `trust-kernel/06` exists in
this repository, so the clause was discharged from a stronger artifact
than the one it names. `core/kernel/` and `core/cmd/kernel-adapter` are
absent from the tree at the branch base `f244e6f` and at the first branch
commit `7eeb746`:

```
git ls-tree -r --name-only 7eeb746^ -- core/  -> no core/kernel/* entry
git ls-tree -r --name-only 7eeb746 -- core/kernel core/cmd
  -> core/cmd/deletion/main.go, core/cmd/outbox/main.go only
```

Kernel source was unreadable, not merely unread. The kernel arrived later
by merge, so the question becomes whether the model was afterwards edited
to match it. Only one post-merge commit touches `reference/*.ts`:
`274643c`, the move to refusal on unpaired surrogates, which decision 082
compelled and which ruled against the kernel's then-behaviour as well, so
it is the contract deciding and not the model copying. `d524c6b` touches
`Makefile` and `reference/README.md` and no reference semantics.

**Fresh random input.** Four seeds above, none of them the implementer's.

**A number-formatting bug planted in each implementation in turn.** Both
plants were made with the editor, run, then reverted by editing back; the
tree was confirmed byte-clean against the head afterwards
(`git status --porcelain` empty).

*In the kernel.* `core/kernel/number.go`, the ECMA-262 step 5 exponent
boundary, `n <= 21` narrowed to `n <= 20` in both fixed-point branches.
Caught, on the committed corpus before any fresh input reached it:

```
DIVERGENCE at numbers.json[6] (request 43)
  request  {"op":"canonicalize","value":100000000000000000000}
  reference  "100000000000000000000"
  kernel     "1e+20"
FAIL differential: 1233 divergence(s) over 20108 requests.
```

It also propagated into the `sign` path, so the divergence was visible in
the produced envelope and not only in the canonical bytes.

*In the reference.* `reference/canonical.ts`,
`ecmascriptNumberToString` altered to strip the `+` from exponents, a
plausible JCS misreading and distinct from every mutant in `mutant.ts`.
Caught by the harness on the corpus and by `make reference-test`:

```
FAIL differential: 1268 divergence(s) over 20108 requests.
FAIL rule 2: 1e21 carries a + sign
    expected "1e+21"
    actual   "1e21"
```

The harness therefore fails when either side is wrong, in an
implementation that is not the mutant adapter.

### AC3 (adjudicated): every ambiguity the harness surfaced is either resolved in the contract or recorded as a known-divergence with reasoning

**Pass.** Four ambiguities are recorded in `reference/README.md`'s table,
all four are ruled in decision 082, and all four are written into
`contract/CONTRACT.md`: unpaired surrogates refused (line 13), the true
verdict exactly `{"valid":true}` (line 29), base64url strict to a decode
and re-encode round trip (lines 30 to 31), and the false verdict saying
nothing. None is left as a known-divergence, so the weaker branch of the
criterion is unused. The table names the enforcement point for each
ruling rather than restating the ruling, and both readings decision 082
ruled against on A3 survive as the `surrogate-escape` and
`surrogate-substitute` mutants, so the ruling is held by a test rather
than by a sentence.

What would have failed this: an ambiguity present in the README table and
absent from both decision 082 and the contract, or a ruling recorded with
no enforcement point and no test.

## Scope

The diff is the reference model, the harness, the corpus, the three
Makefile targets, their wiring into `check` and `check-red`, a CI job,
the `@types/node` devDependency, and the task file's `evidence` and
`Evidence` section. Nothing in it is unrelated to the task's scope
section. The CI job is not named by the task file; it is the mechanical
criterion becoming a standing gate, which is what makes the criterion
mean anything after this PR merges, and it is judged in scope.

## Findings

1. **Layer criterion 7 is not fully discharged by the layer's task set.**
   The criterion reads "the reference model and the kernel agree
   byte-for-byte over fuzzed input, **and each checkpoint's predecessor
   link verifies**." This task reaches the first clause only, which its
   own scope section is honest about, and `trust-kernel/06` is the only
   task in the layer declaring `satisfies: [7]`. The second clause has no
   task. `trust-kernel/04` covers Merkle checkpoints and declares
   `satisfies: [2]`. Raise for the layer, not against this PR: nothing
   this task could have done would close it.

2. **A committed constraint statement is wrong about the code it cites.**
   `reference/package.json`'s description, repeated in the PR body, says
   `pnpm-workspace.yaml` "globs `surfaces/*` only". It globs `contract/*`
   and `surfaces/*`. The conclusion survives, since `reference/` matches
   neither, but decision 052 makes a comment whose claim has drifted from
   the code a review defect rather than a nitpick, and this one is in a
   file that ships.

3. **A stale comment.** `reference/adapter.ts` line 7: "The kernel joins
   the same way when trust-kernel/01 lands." It has landed and is wired
   into `make differential`. `reference/harness/differential.ts` line 47
   carries the same tense in an error string: "Until trust-kernel/01
   lands there is nothing to differ from."

4. **A new devDependency, `@types/node`.** `CLAUDE.md` lists adding
   dependencies under "never without being asked". The implementer
   flagged it rather than absorbing it, and it is types-only and
   dev-only, with no alternative that keeps the deliverable in
   TypeScript. It needs an explicit accept, not a silent one.

5. **The package path departs from `plans/ORDER.md` without a decisions
   entry.** ORDER.md § Naming fixes a layer's package path at
   `core/<name>` unless the task file names one; this task file names
   none, and `trust-kernel/01` established `core/kernel`. `reference/` is
   the right call, since `core/` is a Go module root and the task file
   makes the deliverable TypeScript, but `CLAUDE.md` holds that an
   unrecorded divergence is drift. One decisions entry closes it.

6. **The mutant list is duplicated by hand.** `DIFFERENTIAL_MUTANTS` in
   the Makefile restates the keys of `BUGS` in
   `reference/harness/mutant.ts`. They agree today, checked entry by
   entry. Nothing checks the pairing, so a mutant added to `mutant.ts`
   and not to the Makefile is never exercised and the red path quietly
   shrinks. `mutant.ts` already prints its own key list on a bad
   `--bug`, so the Makefile could read it instead.

## What was not verified

The `verify` op ignores the injected `CanonicalRules`, by construction:
verification compares envelope bytes and does not canonicalize. A
canonicalization misreading is therefore caught on the `canonicalize` and
`sign` draws and not on `verify` draws. That is correct rather than a
gap, and is recorded so a later reader does not mistake the coverage for
wider than it is.

The harness compares `ok` and `out` and deliberately not `error`, so the
two implementations must agree on whether an input is refused and need
not agree on the wording. Two refusals for different reasons read as
agreement. The reasoning is stated at `reference/adapter.ts` lines 21 to
25 and is sound; comparing free text would report a divergence on every
wording difference.
