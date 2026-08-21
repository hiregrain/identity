# trust-kernel/08: clean-context verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, decision 065, PR #13's diff and body, and the
running system.

Implementation head verified:
`286a1af81cab5322684500fb8f16849bae7f986b` (PR #13, branch
`task/trust-kernel-08`). Merge base `origin/main` at
`2086df5`; the task diff is twelve files.

Environment: a detached worktree at the implementation head, fresh
`pnpm install --frozen-lockfile`, its own compose project. Sibling
worktrees held the compose host ports 5433 and 5434, so this run used a
port-free compose override supplied through `COMPOSE_FILE` and
`COMPOSE_PROJECT_NAME`, leaving the tree under verification untouched.
Nothing in the repo connects over a host port: the only occurrence of
5433 outside `docker-compose.yml` is
`test/fixtures/redpath/serving/surfaces/plane-client.ts`, a
serving-credentials fixture string, and every database access goes
through `docker compose exec`.

Verdict: **PASS**. Every acceptance criterion discharged.

## Precondition

`make check` exits 0 at the implementation head, the full pipeline in
one run, including `migrate-verify`.

```
make check -> exit 0, "check: green"
make check-red -> exit 0, "check-red: all red paths fail as required"
```

The PR body records that `migrate-verify` was never obtained green in
the same run as the rest during implementation, twice failing with
"the database system is in recovery mode". The first `migrate-verify`
attempt in this session failed the same way on the first
`docker compose down && up` cycle and passed on immediate retry with no
change to the tree. That reproduces the implementer's environmental
reading: a container-restart race under host contention, not a defect
in this diff, which touches neither `db/migrate.mjs` nor any migration.
The claim is discharged rather than accepted: the aggregate ran green
here.

## Criteria

**1. One package constructs a database invocation (mechanical, pass).**
`checks/transport-seam.mjs` exists, is wired into `checks/run.mjs`'s
`METADATA` list, therefore into `make check`'s `metadata` target, and
into `make check-red` as red path 15.

```
node checks/transport-seam.mjs
  -> exit 0, "18 Go file(s) scanned, no database invocation outside core/transport"
node checks/transport-seam.mjs test/fixtures/redpath/transport
  -> exit 1, flags the planted exec.Command("docker", ...)
node checks/run.mjs --metadata
  -> exit 0, transport-seam listed in "every check green"
```

The check was not taken on its own word. Three violations were planted
in the real tree and each was caught, the check returning exit 1 with
all three named:

- `core/outbox/probe_a.go`, `exec.Command("psql", ...)` in production
  code;
- `core/deletion/probe_b_test.go`, a `database/sql` import in a test
  file;
- `core/envelope/probe_c_test.go`, `exec.Command("docker", ...)` in a
  test file.

The two test-file plants confirm the no-test-file-exemption clause. All
three probes were removed and the check re-run clean.

The check's accepted gap, a dynamically constructed command name, is
stated in its own header and is the gap criterion 2 acknowledges.
`test/` is pruned at any depth, which is what keeps the check's own
red-path fixture from failing the green path; today no Go file outside
`core/` exists, so nothing real is hidden by that pruning.

**2. Duplicate renderers and parsers are gone (mechanical, pass).**

```
grep -rn -e quoteText -e sqlLiteral -e quoteLiteral -e isHexLiteral --include='*.go' .
```

Every hit is inside `core/transport/transport.go` (the `sqlLiteral`
method on the `Arg` interface). `quoteText`, `quoteLiteral`, and
`isHexLiteral` do not exist anywhere in the repo. Exactly one
`Query(ctx context.Context, ...)` implementation exists,
`transport.EnvelopeQuerier`. A renamed copy would still need
`exec.Command` to docker or psql, which criterion 1's check catches
regardless of the name it wears, proven by the `probe_a` plant above.

**3. Existing acceptance suites pass, assertions unchanged (mechanical,
pass).** From the single `make check` run:

```
node test/append-only.test.mjs        -> 18 assertions passed on both planes
node test/two-plane-split.test.mjs    -> 8 assertions passed
GRAIN_KEY_PROVIDER=software  go test -tags db -count=1 ./envelope/... -> ok 22.034s
GRAIN_KEY_PROVIDER=stub-kms  go test -tags db -count=1 ./envelope/... -> ok 31.102s
node test/cross-plane-outbox.test.mjs -> 45 assertions passed, all seven scenarios
GRAIN_KEY_PROVIDER=software  go test -tags db -count=1 ./deletion/...  -> ok 57.474s
cd core && go vet ./... && go test ./...                               -> exit 0
```

No `test/*.mjs` file appears in the diff, so the crash-point protocol's
driver is unchanged. The two Go test files that do change
(`core/deletion/deletion_db_test.go`, `core/envelope/psql_db_test.go`)
change only harness plumbing: `composePsql`, the duplicate
`psqlQuerier`, `isHex`, `fullDump`, `ownerSQL`, `roleSQL`, `appSQL`,
`payloadDump`, `newEnv`, and one cleanup call. No assertion text moves.

**4. The renderer's red-path suite (mechanical, pass).**

```
cd core && go test -count=1 -v ./transport/... -> 9 tests, all PASS
```

Each rule in the criterion has its own test: injection-shaped string
renders inert and round-trips byte-identical; NUL refused with a
structured error; `Null` renders the bare keyword, not text; `Bool`,
`Int`, `Float` render bare and unquoted; a `\x`-shaped string renders
as plain quoted text; `Bytea` is the only path to the hex form.
`TestRenderDoesNotRescanSubstitutedLiterals` additionally covers the
placeholder-rescan shape in both argument orders.

**5. Behavior preservation at the two flagged seams (mechanical,
pass).** The implementer's claim here is "preserved by construction"
plus a unit test of `SplitRow`. That is weaker than the criterion, which
names stored-not-refused and read-intact, so both were driven live
against migrated planes.

A throwaway verifier test (written into `core/transport`, run, then
deleted, never committed) issued the exact statement `core/outbox`'s
`note` issues, with the same typed args, for the detail:

```
psql: O'Brien said \x68 "quoted" and a<TAB>tab and a|pipe
```

- The insert succeeded: the detail is stored, not refused.
- Reading it back through `transport.Query` returned it byte-identical.
- `outbox.Reconcile(0)` printed it intact:
  `reconcile: QUEUE entry aaaaaaaa-... 1 attempt(s), last detail: psql:
  O'Brien said \x68 "quoted" and a<TAB>tab and a|pipe`, the tab and the
  pipe both surviving the bounded `SplitRow(line, 4)`.

Three further live probes in the same run:

- an injection payload `x'); DROP TABLE cross_plane_outbox_attempts;
  --` stored as data; the table still exists and still reads;
- `SELECT $1::text` with a `\x`-shaped string returns the text
  unchanged, and `encode($1::bytea, 'hex')` with `Bytea("hello")`
  returns `68656c6c6f`: hex only through the wrapper, live;
- `SHOW standard_conforming_strings` returns `on`, which is the
  precondition that makes quote-doubling alone sufficient escaping.
  The renderer does not assert this itself.

## Outside check

Run as written. The criterion-1 check and the full pipeline on a fresh
checkout: both green, transcripts above. The red-path renderer suite:
green. The four call sites reach the planes only through
`core/transport`, confirmed two ways, by reading the diff (`core/deletion`
imports `core/transport` and its own `psql`, `script`, `scriptAs`,
`rows`, `psqlQuerier` are deleted; `core/outbox` likewise; both db test
harnesses now call `transport.Query` and `transport.Dump`) and by the
repo-wide check, whose exclusivity was itself falsified with three
plants. The removed symbols are gone, grep transcript above.

The adversarial attempts that did not break it: three planted seam
violations, two of them in test files; an injection payload driven to
the database and back; a `\x`-shaped string offered to the renderer as
plain text; a tab and a pipe inside a free-text detail column read
through `Reconcile`.

## Findings

None blocking. Three recorded.

**The PR body's "Judgment calls" list is incomplete.** It names
`transport.Dump` as the one addition beyond the two verbs decision 065
rules. `transport.Literal` and `Transaction.ExecLiteral` are also
additions beyond `Query` and `Tx`, and they are the more consequential
pair: `ExecLiteral` accepts an already-rendered statement and performs
no escaping, so a future caller can cross the seam holding an
unescaped string and no check will catch it. Today it has one caller,
`core/outbox`'s `Apply`, feeding `Instruction.ApplySQL`, whose values
do go through `transport.Literal` and whose table and column names are
validated by `Instruction.validate`. The scope line "call sites never
build SQL strings" is therefore true of values and not of statement
shape. This is inside the task's scope, which explicitly leaves "what
SQL the callers issue" alone, but it is the seam's soft spot and the
next task to reach for `ExecLiteral` should be made to justify it.

**`EnvelopeQuerier` infers bytea from a string's shape.** The scope
says hex escaping happens "never inferred from a string's shape". The
general `Arg` renderer honors that; this adapter does not, and the PR
body discloses it. The exception is bounded correctly: `envelope.Querier`
takes `args ...string`, decision 065 keeps that interface untouched, and
every arg envelope passes is a validated uuid, its own `hexArg` output,
or a provider name, confirmed by reading `core/envelope/envelope.go`.
No worker-supplied free text reaches this adapter. Recorded because it
is the one place the seam's own rule is not uniform, not because it is
exploitable today.

**The task file's diff evidence names the wrong commit.**
`diff:PR #13 @ e52399ed05aaa1419c82a5833ec03a91e3a4f7d4` points at the
parent of the head verified here. The bookkeeping commit that follows
this record corrects it to `286a1af`.

## Scope

Twelve files, all called for. `checks/transport-seam.mjs` and its
fixture, the two one-line wirings in `Makefile` and `checks/run.mjs`,
`core/transport` and its test, the four call sites, and the task file.
Nothing present the task did not ask for. `transport.Dump` is an
addition to the package's surface, justified by criterion 1's
no-test-exemption clause: the db test harnesses' `pg_dump` calls are
database invocations, so they had to move behind the seam or the check
would fail.
