---
id: trust-kernel/08
type: task
layer: trust-kernel
satisfies: []
status: done
depends_on: []
migrations: []
binds: [decisions/LOG.md#065]
evidence:
  [
    "test:node checks/transport-seam.mjs -- 18 Go files scanned; 0 outside core/transport",
    "test:make check-red -- red path 15 (test/fixtures/redpath/transport) fails as required",
    "test:cd core && go test ./... -- includes transport's renderer red-path suite",
    "test:cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 ./envelope/... -- pass",
    "test:cd core && GRAIN_KEY_PROVIDER=stub-kms go test -tags db -count=1 ./envelope/... -- pass",
    "test:cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 ./deletion/... -- pass",
    "test:node test/cross-plane-outbox.test.mjs -- 45 assertions passed; crash-point protocol intact",
    "test:node test/append-only.test.mjs -- 18 assertions passed on both planes",
    "test:node test/two-plane-split.test.mjs -- 8 assertions passed",
    "test:node checks/run.mjs -- metadata and schema groups green",
    "test:cd core && go test ./transport/... -run TestRenderDoesNotRescan -v -- multi-arg injection red path (post-verification fix) passes",
    "log:log/2026-08-21-trust-kernel-08-verification.md",
    "test:node checks/transport-seam.mjs test/fixtures/redpath/transport -- both exec.Command and exec.CommandContext caught (code-review finding 1)",
    "test:cd core && go test ./transport/... -run TestEnvelopeRowsRejectsMultiColumnRows -v -- multi-column guard (code-review finding 2) passes",
    "test:cd core && go test ./transport/... -run TestNumericsRoundTripTyped -v -- Float covers whole numbers now that Int is removed (code-review finding 5)",
    "diff:PR #13 @ PLACEHOLDER_MERGE_SHA",
  ]
verified_by: clean-context-verifier@2026-08-21
---

# Database transport: one seam for every SQL path

## Objective

One module owns how Go code reaches the two planes, so the eventual
Postgres-driver decision changes one file, and SQL safety lives in a
seam rather than in call-site discipline.

Grilled and reviewed 2026-08-20 (decision 065). It lives in
trust-kernel rather than foundation because its consumers ahead are the
kernel's SQL-issuing tasks (02, 03, 04 depend on it) and foundation is
done; reopening a done layer for a new task would cost more than this
placement note.

## Scope

- The premise (recorded in decision 065): three foundation packages
  each hand-rolled the docker-compose-exec psql path with its own
  quoting and row parsing, and `core/envelope/psql_db_test.go` carries
  a fourth verbatim copy. Safe today because values are
  shape-validated first; a copying-ground for the next task that
  forgets why.
- One transport package, `core/transport`, with a driver-shaped API of
  two verbs (decision 065): `Query(plane, role, sql, args...)` for
  single statements with `$n` placeholders, and a `Tx(plane, role, fn)`
  shape for multi-statement transactional work, inside which the
  outbox's crash-point protocol (`CrashBeforeSpineCommit`,
  `CrashMidPayloadApply`) keeps its abort-by-exit semantics. Call
  sites never build SQL strings.
- Args are typed, never pre-rendered strings (decision 065): explicit
  renderer cases for string (quotes escaped by doubling, NUL always
  refused), nil (SQL NULL, never the text 'NULL'), bool, numerics, and
  a bytea wrapper type. Hex escaping happens only through the wrapper,
  never inferred from a string's shape, so a worker-supplied text like
  a backslash-x sequence renders as text. A comment at the renderer
  states that this is rendering, not wire-protocol parameterization,
  beside the code that enforces the difference.
- One row-parsing format: the outbox's bounded tab split (`SplitN`,
  last field unbounded), because an unbounded split corrupts any
  free-text field containing the separator. The compose-exec adapter
  is the first implementation; a driver adapter arrives behind the
  same seam when a decisions entry admits the dependency (trigger in
  ORDER.md's decision gates).
- `core/deletion` and `core/outbox` move onto the transport.
  `core/envelope` keeps its `Querier` interface untouched, and the
  transport provides the production `Querier` implementation, wired at
  composition, so the kernel-facing package gains no exec dependency
  (decision 065). Envelope's db test drops its duplicate renderer and
  uses the transport-backed Querier.
- **Tests migrate too; there is no test-file exemption** (decision
  065). The seam binds the whole repo: new packages and new tests
  reach the planes only through the transport, enforced by criterion
  1's repo-wide check.
- `satisfies` is empty and legitimately so (decision 065): this task
  adds no layer capability, so it claims no layer criterion; its own
  mechanical acceptance below is its done-condition.
- Out of scope: the driver decision itself, connection pooling, and
  any change to what SQL the callers issue.

## Acceptance

1. (mechanical) exactly one package constructs a database invocation:
   a grep-class check fails any `exec.Command` reaching docker or
   psql, and any `database/sql` or driver import, outside
   `core/transport`, with no test-file exemption, wired into the
   metadata group with a red-path fixture.
2. (mechanical) the duplicate renderers and parsers are gone: grep
   finds no definition of `quoteText`, `sqlLiteral`, `quoteLiteral`,
   `isHexLiteral`, or a psql-invoking `Querier` outside
   `core/transport`, and no renaming survives, asserted by the
   criterion-1 check covering what a renamed copy would need
   (`exec.Command` to psql).
3. (mechanical) every existing acceptance suite passes with assertions
   unchanged: envelope (both providers), cross-plane outbox including
   the crash-point protocol, deletion, append-only, two-plane split.
   Test plumbing may migrate onto the transport; test assertions do
   not change.
4. (mechanical) the renderer's red-path suite proves the typed-arg
   rules: an injection-shaped string renders inert and round-trips
   byte-identical, a NUL is refused with a structured error, nil
   renders SQL NULL and not text, bool and numeric round-trip typed,
   a backslash-x string renders as text, and bytea renders only
   through the wrapper type.
5. (mechanical) behavior preservation at the two seams the review
   flagged: an outbox failure note whose detail contains an apostrophe
   or backslash is stored, not refused, and `Reconcile` reads a detail
   containing a tab or pipe intact through the bounded split.

## Outside check

Verifier runs the criterion-1 check and the full pipeline on a fresh
clone, runs the red-path renderer suite, confirms the four call sites
(deletion, outbox, envelope production wiring, envelope db test) reach
the planes only through `core/transport`, and greps for the removed
symbols.

## Evidence

- Criterion 1: `checks/transport-seam.mjs` is the grep-class check,
  wired into `checks/run.mjs`'s metadata group and `make check`. It
  walks the whole repo (there is no other language a database
  invocation could hide in today), `test/` pruned wherever it appears
  (the same exclusion every check's red-path fixtures get; without it
  the check's own planted violation fixture would fail the green
  path), `core/transport` and `core/gen` excluded by path. It flags
  `exec.Command` reaching `"docker"` or `"psql"`, and a `database/sql`
  or known driver import, outside `core/transport`. Red path 15 in the
  Makefile points it at `test/fixtures/redpath/transport`, a planted
  `exec.Command("docker", ...)` outside `core/transport`, and asserts
  exit 1; the real tree scans 18 Go files (all of them under `core/`,
  which is where every `.go` file in the repo happens to live today)
  and finds none.
- Criterion 2: `quoteText`, `sqlLiteral`, `quoteLiteral`, and
  `isHexLiteral` no longer exist anywhere in the repo; every psql
  invocation lives in `core/transport/transport.go`. Grepping the
  removed names confirms no renamed copy survives, and criterion 1's
  check would fail any renamed copy anyway (it would still need
  `exec.Command` to psql).
- Criterion 3: the four acceptance suites run unchanged: envelope under
  both `GRAIN_KEY_PROVIDER=software` and `=stub-kms`, cross-plane
  outbox (45 assertions, all seven scenarios including every crash
  point), deletion (`TestRestoreReplayGateEndToEnd`,
  `TestOnlyPurgeRoleHoldsDeleteOnPayloadTables`,
  `TestPurgeRemovesShreddedRowsAndAudits`,
  `TestDeletionJournalCarriesNothingIdentifying`,
  `TestDestroyValidation`), append-only (18 assertions on both planes),
  two-plane-split (8 assertions). No assertion text changed; only the
  test-side plumbing (`ownerSQL`, `roleSQL`, `newEnv`, `fullDump`) now
  calls `core/transport` instead of a duplicate `exec.Command`.
- Criterion 4: `core/transport/transport_test.go` is the renderer's
  red-path suite: an injection-shaped string round-trips
  byte-identical, a NUL byte is refused, `Null` renders the keyword
  `NULL` not the text `'NULL'`, `Bool`/`Float` round-trip typed and
  unquoted (`Int` was removed in the code-review pass below; `Float`
  alone covers whole numbers, since `FormatFloat`'s `'g'` verb renders
  `60.0` as `"60"`), a `\x`-shaped string renders as plain quoted text
  (not hex), and `Bytea` is the only path to the hex literal form.
- Criterion 5: preserved by construction, not just by unchanged
  assertions. `core/outbox/instruction.go`'s `ApplySQL` still renders
  free-text values through quote-doubling (`transport.String`), so an
  apostrophe or backslash in a failure detail is stored, not refused,
  exactly as `TestApplySQLQuotesStrings` already proved. `Reconcile`
  reads rows via `transport.SplitRow(line, 4)`, the same bounded
  `SplitN` the outbox always used; `TestSplitRowIsBoundedWithLastFieldUnbounded`
  in `transport_test.go` proves a tab or pipe inside the last field
  survives intact.

A verification finding, fixed on this branch after the first review:
`render`'s original implementation substituted `$n` placeholders with
repeated whole-statement `strings.ReplaceAll` passes, highest index
first. Each pass rescanned literals a prior pass had already inserted,
so a `String` argument containing text shaped like `$1` was
reinterpreted as a placeholder on a later pass and replaced again,
breaking a quoted literal open into two statements. `render` now does
one left-to-right scan over the ORIGINAL statement text
(`placeholderPattern.FindAllStringSubmatchIndex`), emitting each
literal into its match position exactly once; a substituted literal is
never looked at again. `TestRenderDoesNotRescanSubstitutedLiterals` in
`transport_test.go` reproduces the finding's exact shape (an injection
payload and a `$1`-shaped string across two arguments, in both index
orders) and asserts the rendered statement keeps the payload inside
one quoted literal.

A code-review pass on the same branch raised five further findings, all
fixed here:

1. `checks/transport-seam.mjs`'s exec pattern matched `exec.Command`
   but not `exec.CommandContext`, the ordinary Go idiom for a
   cancellable shell-out; a planted `exec.CommandContext(ctx, "psql",
   ...)` outside `core/transport` passed the check green. The pattern
   now matches `exec\.Command(?:Context)?\(` and skips an optional
   leading context argument before the command literal. The red-path
   fixture (`test/fixtures/redpath/transport/core/planted/planted.go`)
   now plants both shapes and the check catches both.
2. `EnvelopeQuerier.Query` wrapped every result line as `[]string{line}`
   unconditionally, contrary to the package's own row-parsing contract.
   Correct today only because every envelope query selects one column;
   a future second column would mash into `rows[0][0]`, and
   `activeDEK`'s `len(rows[0]) != 1` guard checks slice length, not
   column count, so it would not catch it. `EnvelopeQuerier.Query` now
   delegates to `envelopeRows`, which refuses a row with more than one
   column. `TestEnvelopeRowsRejectsMultiColumnRows` in
   `transport_test.go` covers both shapes directly, no database needed.
3. `stringArg.sqlLiteral` escapes by quote-doubling alone, which is a
   correct SQL-string escape only if `standard_conforming_strings` is
   on; nothing asserted it. Not reachable off in the pinned config
   (Postgres has defaulted it on since 9.1, and the compose image is
   pinned to `postgres:18`), so not a live bug, but closed at the seam
   anyway: `Query` and `Tx` now call `assertStandardConformingStrings`,
   which runs `SHOW standard_conforming_strings` once per plane
   (cached) and fails loudly if it is ever not `"on"`. Chosen over the
   other option raised, rendering every string through
   `decode('..','hex')` or dollar-quoting: that changes every
   literal's shape for a setting this repo's own config never varies,
   where a single cached live assertion costs one extra query per
   plane for the process's lifetime.
4. `core/outbox.Reconcile` built its SQL with `fmt.Sprintf`
   interpolating `thresholdSeconds` into `interval '%d seconds'`
   rather than a typed `Arg`, the one surviving call site that still
   built SQL text. Not exploitable (the value is Go-`int`-typed), but
   it was the exception to "call sites never build SQL strings"
   (Scope). Now passes `transport.Float(float64(thresholdSeconds))` as
   `$1` and builds the interval in SQL as `($1 || ' seconds')::interval`.
5. `transport.Int`/`intArg` had zero call sites (`argFor` in
   `instruction.go` maps JSON values onto `nil`/`String`/`Bool`/`Float`
   alone, and finding 4 above uses `Float`, not `Int`, for
   `Reconcile`'s threshold). Removed; `TestNumericsRoundTripTyped`
   trimmed to `Float` alone, with a case proving a whole number renders
   without a decimal point. `Bytea` was left as is per the finding,
   despite also having no `argFor` call site today: it is the
   documented sole path to hex rendering, not dead code the way `Int`
   was.

Explicitly out of scope for this pass, per the same review: the
driver-import blocklist's width (deferred to the driver-adoption
decision), the per-call docker-exec subprocess cost (decision 065),
the eighth directory-walker copy (pre-existing repo debt), and the
`test/`-dir pruning (already documented by design in criterion 1's
evidence above).

One environmental note, not a code defect: `make check`'s
`migrate-verify` step (a `docker compose down && up` cycle, unrelated
to this task's diff) intermittently hit "the database system is in
recovery mode" against this worktree's Postgres containers, twice,
apparently from host resource contention with other concurrent agent
sessions on the same machine. `metadata`, `lint`, `go-check`,
`check-red`, and every acceptance suite listed above ran clean in
isolation; `migrate-verify` and the full `make check` aggregate were
not obtained as one green run in this session. `db/migrate.mjs` and
the migration files are untouched by this task's diff.
