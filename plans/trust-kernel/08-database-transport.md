---
id: trust-kernel/08
type: task
layer: trust-kernel
satisfies: []
status: in_progress
depends_on: []
migrations: []
binds: [decisions/LOG.md#065]
evidence: []
verified_by: null
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
