# trust-kernel/08: clean-context verification at the post-review head (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, PR #13's diff and body, and the running system.

Verified head: `556c22c5683ec969f7e7e2f7c81886c0f8daee5b`.

Why a second record. The branch already carries a verification at
`286a1af81cab5322684500fb8f16849bae7f986b`
(`log/2026-08-21-trust-kernel-08-verification.md`), and `status: done`
was written against that head. Code changed afterwards: `7f6c667`
applied five code-review findings to `checks/transport-seam.mjs`,
`core/transport/transport.go`, `core/transport/transport_test.go`,
`core/outbox/outbox.go` and the red-path fixture, and `beee7b0` merged
that line with the earlier verification commit. A `done` recorded at a
head the current code no longer matches is a claim nothing proved, so
every criterion below was discharged again at the current head. This
record does not replace the first one; it names the head it verified
and stands beside it.

Merge fidelity. `git diff 557d3f1 beee7b0` is the verification record
plus the three frontmatter lines that commit carried, and
`git diff d7ee533 beee7b0` is exactly the code-review pass. The merge
lost nothing and resolved nothing by hand beyond the frontmatter
placeholder `556c22c` then filled in.

Verdict: **pass**. Every criterion discharged at `556c22c`.

## Environment

Sibling agent worktrees held the compose host ports 5433 and 5434 for
the whole session, so this run used a no-ports compose override
(`ports: !reset []` on both services, supplied through `COMPOSE_FILE`,
never written into the tree). Nothing under test reaches a plane over a
host port: every database access in this repo goes through
`docker compose exec`, and the one file naming those ports outside
`docker-compose.yml` is `db/connections.json`, which no program in the
repo reads. The compose project stayed this worktree's own, so no
sibling's containers were touched.

One note on that override, because it produced a real failure worth
recording rather than hiding: pinning `COMPOSE_FILE` to the relative
path `docker-compose.yml` failed the envelope suite, since
`transport.psql` no longer sets `cmd.Dir` the way the harnesses it
replaced did, and the Go test process runs in `core/envelope`. Absolute
paths in `COMPOSE_FILE` fixed it. See finding 4.

## Precondition

`make check` at `556c22c`, exit 0, end to end, `migrate-verify`
included. The task file's Evidence section says the aggregate "was not
obtained as one green run in this session" and blames intermittent
Postgres recovery-mode failures under host contention; at this head, on
this machine, with other agents' containers running throughout, the
aggregate came back green on the first attempt after the override was
corrected. That caveat is superseded.

`make check-red`, exit 0, including red path 15.

## Criteria

**1 (mechanical), one package constructs a database invocation.** Pass.

- `node checks/transport-seam.mjs` in the real tree: exit 0,
  "18 Go file(s) scanned, no database invocation outside
  core/transport".
- `node checks/transport-seam.mjs test/fixtures/redpath/transport`:
  exit 1, flagging both the `exec.Command("docker", ...)` and the
  `exec.CommandContext(ctx, "docker", ...)` shapes in the fixture.
- Wiring confirmed by reading: `checks/run.mjs`'s metadata group lists
  `transport-seam`, and the group's green line at the head of the
  `make check` log names it. Red path 15 in the Makefile runs the
  fixture and asserts the non-zero exit.
- The no-test-file-exemption clause was probed, not taken on trust. A
  synthetic `core/sneaky/sneaky_test.go` outside the tree, planting
  `exec.Command("psql", ...)`, `exec.CommandContext(ctx, "psql", ...)`,
  a `docker` invocation with the command literal on its own line, a
  `CommandContext` with the context argument on its own line, and a
  `database/sql` import, was caught in full: exit 1, five violations,
  in a `_test.go` file.

**2 (mechanical), the duplicate renderers and parsers are gone.** Pass.

- `grep -rn "quoteText\|quoteLiteral\|isHexLiteral" core checks test db
  surfaces`: no match.
- `grep -rn "sqlLiteral" core`: every hit is inside
  `core/transport/transport.go`.
- `grep -rn "os/exec\|exec\.Command" core`: `core/transport` plus one
  `exec.Command("node", ...)` in `core/deletion/deletion_db_test.go`,
  which runs the operator scripts and is not a database invocation.
- `grep -rn "Querier" core`: the only implementation is
  `transport.EnvelopeQuerier`, and all three construction sites
  (`core/deletion/deletion.go`, `core/envelope/psql_db_test.go`,
  `core/deletion/deletion_db_test.go`) pass it.
- A renamed copy is caught by criterion 1's check regardless of name,
  proven by the synthetic probe above, whose functions carry none of
  the removed names.

**3 (mechanical), every existing acceptance suite passes with
assertions unchanged.** Pass.

From the green `make check` at `556c22c`:

- `GRAIN_KEY_PROVIDER=software go test -tags db ./envelope/...`: ok.
- `GRAIN_KEY_PROVIDER=stub-kms go test -tags db ./envelope/...`: ok.
- `go test -tags db ./deletion/...`: ok.
- `node test/cross-plane-outbox.test.mjs`: 45 assertions passed.
- `node test/append-only.test.mjs`: 18 assertions passed on both
  planes.
- `node test/two-plane-split.test.mjs`: 8 assertions passed.

Assertions unchanged, checked mechanically rather than claimed:
`git diff --stat 64b5901 HEAD -- test/ core/outbox/instruction_test.go
core/outbox/outbox_test.go` returns the new red-path fixture and
nothing else, and `core/envelope/envelope_db_test.go` is absent from
the diff entirely. The two db test files that did change
(`core/envelope/psql_db_test.go`, `core/deletion/deletion_db_test.go`)
were read hunk by hunk: every change is harness plumbing
(`ownerSQL`, `appSQL`, `roleSQL`, `newEnv`, `payloadDump`, `fullDump`,
`contentTable`'s cleanup) moving onto `core/transport`, with the
deleted duplicate renderers alongside. No assertion text moved.

**4 (mechanical), the renderer's red-path suite proves the typed-arg
rules.** Pass.

`cd core && go test -count=1 -v ./transport/...`, every test PASS:
`TestStringRendersInertAndRoundTrips`, `TestStringRefusesNUL`,
`TestNullRendersKeywordNotText`, `TestBoolRoundTripsTyped`,
`TestNumericsRoundTripTyped`, `TestBackslashXStringRendersAsText`,
`TestByteaRendersOnlyThroughTheWrapper`,
`TestRenderDoesNotRescanSubstitutedLiterals`,
`TestEnvelopeRowsRejectsMultiColumnRows`,
`TestSplitRowIsBoundedWithLastFieldUnbounded`.

Each rule the criterion names maps to a test above, and the rules were
also driven against a live plane in the outside check below rather than
against `Literal` alone.

**5 (mechanical), behavior preservation at the two flagged seams.**
Pass.

- `go test -run TestApplySQL -v ./outbox/...`: `TestApplySQLQuotesStrings`
  PASS, alongside the determinism and nested-value tests. Read from the
  code: `instruction.ApplySQL` maps a JSON string onto
  `transport.String`, whose `sqlLiteral` doubles quotes and leaves a
  backslash alone, so a failure detail carrying either is stored, not
  refused. `outbox.note` renders `detail` the same way.
- `TestSplitRowIsBoundedWithLastFieldUnbounded` PASS, and
  `outbox.Reconcile` reads through `transport.SplitRow(line, 4)` with
  `detail` in the unbounded last position.
- Driven live in the outside check: a note containing a tab, a pipe and
  a backslash round-tripped byte-identical.

## Outside check

The task's outside check is the criterion-1 check, the full pipeline on
a clean tree, the red-path renderer suite, the four call sites, and the
greps. All are above. Two adversarial probes were added, because a
check passed without an attempt to fail it is not a check. Both test
files were written by the verifier, run against the live planes, and
deleted; `git status` is clean.

**Live injection round-trip through the seam.** A verifier-authored
`core/transport/verifier_probe_db_test.go` created a payload table and
inserted, through `transport.Query` with typed args, nine adversarial
notes: `'); DROP TABLE ...; --`, the bare text `$1`, a string
containing `\x68656c6c6f`, a value carrying both a tab and a pipe, a
value mixing backslashes with single and double quotes, the
E-prefixed escape-string form `E'\\x41'`, an embedded newline, a
`$$dollar$$` quoted shape, and printf verbs. Result: PASS. The table
survived, the row count was exactly what was inserted, every note came
back byte-identical, `Bytea` round-tripped as hex while the
hex-shaped string stayed text, a NUL was refused before reaching psql,
`Null` produced a real SQL NULL rather than the text, and the same
payload inside `Tx` behaved identically. Nothing broke out of a
literal.

**The standard_conforming_strings guard.** A second verifier-authored
test set `ALTER DATABASE payload SET standard_conforming_strings = off`,
cleared the transport's per-plane cache, and called `Query` and `Tx`.
Both refused, naming the setting and the reason:
`transport: payload has standard_conforming_strings = "off", want "on"`.
The setting was reset and confirmed back to `on`, so the databases were
left as found. The guard the code-review pass added is real, not
decorative.

**A bypass the check does not close.** See finding 1: a Go file under
any directory named `test`, at any depth including inside `core/`,
is not scanned. Reproduced with a synthetic
`core/deletion/test/helper.go` shelling out to docker and psql; the
check reported "0 Go file(s) scanned" and exited 0.

## Scope

The diff against the merge-base `64b5901` touches the Makefile (red
path 15), `checks/run.mjs` (one registration line),
`checks/transport-seam.mjs`, `core/transport/`, the four call sites the
scope names, the red-path fixture, the task file, and the first
verification record. Every file is called for by the task. No scope
creep found.

The fence holds: the task file's Objective, Scope, Acceptance and
Outside check sections are byte-identical to the merge-base. What was
added is frontmatter status, evidence and `verified_by`, plus an
`## Evidence` section below the criteria.

The PR body's Judgment calls were falsified where they could be. Three
of the four hold as written. The `Dump` addition is defensible on the
stated ground: criterion 1 has no test-file exemption, so the
harnesses' own `pg_dump` calls had to cross the seam or the check would
fail the real tree. The `Transaction` naming is forced by Go. The
`EnvelopeQuerier` hex note is accurate. The list is incomplete: it does
not mention `Literal` and `ExecLiteral`, two exported additions beyond
the two verbs decision 065 names, both load-bearing for
`instruction.ApplySQL`. The first verification record raised the same
omission and it is still unaddressed in the body.

## Findings

None blocking. All five criteria pass at `556c22c`.

1. `checks/transport-seam.mjs` prunes every directory named `test` at
   any depth, not just the repo-root `test/`. A Go file at
   `core/<pkg>/test/helper.go` shelling out to docker or psql passes
   the check green, reproduced above. The criterion's "no test-file
   exemption" clause is about `_test.go` files, which are scanned, so
   this is not a criterion failure, and the pruning is disclosed in the
   check's own comment and the task's Evidence. It is still a hole in a
   check whose whole job is to have none: pruning only the path `test`
   relative to the scan root would keep the red-path fixture exempt and
   close it.

2. The same file's header comment says the scan is Go-only because
   "there is no other language a database invocation could hide in
   today". That is false: `db/migrate.mjs`, `db/typegen.mjs`,
   `db/backup.mjs`, `db/restore.mjs`, several `checks/*.mjs` and the
   `test/*.test.mjs` suites all invoke psql through Node right now. The
   Go-only scope is correct, because decision 065 scopes the seam to
   how Go code reaches the planes, but the reason given for it is not.
   A comment whose claim has drifted from the code is a review defect
   (decision 052).

3. `Transaction.Exec` requires the caller to terminate the statement
   with a semicolon and nothing says so. `openScript` joins statements
   with a newline and appends `COMMIT;`, so an unterminated statement
   yields a syntax error at COMMIT. Found by writing a `Tx` call
   without one. Both existing call sites terminate, and the failure is
   loud rather than silent, so this is a documentation gap: a line on
   `Exec`, or appending the semicolon when absent, closes it.

4. `transport.psql` and `transport.Dump` dropped the
   `cmd.Dir = repoRoot` the harnesses they replaced set, so every
   database invocation in the repo now depends on the process working
   directory sitting at or below the repo root for `docker compose` to
   locate the compose file. True of every call path today, and the
   suites prove it. It is a new implicit precondition where there used
   to be an explicit one, and it cost this verification a full pipeline
   run before the cause was found.

5. `EnvelopeQuerier` infers a hex bytea argument from a string's shape,
   the one place the seam's own rule that hex is never inferred from a
   string's shape does not hold uniformly. Bounded to the one adapter,
   documented there, and safe under envelope's argument contract. The
   first verification record raised this and it stands.

6. `outbox.Reconcile` renders its threshold through `transport.Float`
   into `($1 || ' seconds')::interval`. `FormatFloat`'s `g` verb emits
   scientific notation for very large magnitudes, which that cast would
   reject. Reachable only with an absurd threshold; the Makefile passes
   0 and 60, and `Int` was removed by code-review finding 5, so `Float`
   is the only numeric left.

7. The frontmatter `diff:` entry names `beee7b0`, the merge commit,
   while the head is `556c22c`. A commit cannot record its own SHA, so
   naming its parent is the closest reachable, and this record names
   the head verified.
