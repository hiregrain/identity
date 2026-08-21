---
id: trust-kernel/02
type: task
layer: trust-kernel
satisfies: [5]
status: done
depends_on: [trust-kernel/01, foundation/03, trust-kernel/08]
migrations: [0006-key-event-log]
binds: [design/stack-litigation/d3-verdict.md, decisions/LOG.md#011]
evidence:
  [
    "test:cd core && go test ./kernel -run TestSignatureValidAcrossTheRuleBoundaries -- the boundary table passes",
    "test:cd core && go test ./kernel -run 'TestABackdatedCompromiseClaimInvalidatesNothing|TestTheRuleIsIndependentOfEventOrder|TestARepeatedEventKindTakesTheEarliest|TestValidKeyEventKind' -- pass",
    "test:make signing-test -- the operatorkey suite green under GRAIN_KEY_PROVIDER=software and =stub-kms",
    "test:cd core && go test -tags db -count=1 ./kernel/keylog/... -- every test passes against the live spine",
    "test:node checks/signing-seam.mjs -- 27 Go files scanned; 0 signing primitives outside the kernel",
    "test:make check-red -- red path 21 fails as required and the verify-only green fixture passes",
    "test:make check -- check: green at 1cd626b0",
    "test:make check-red-db -- planted violations fail as required; databases left as found",
    "diff:1cd626b0",
    "review:log/2026-08-21-trust-kernel-02-verification.md",
  ]
verified_by: clean-context-verifier@2026-08-21
---

# Key provider and the key-event log

## Objective

Key custody behind the provider interface (software local/CI, KMS in
prod per decision 011) and the append-only key-event log that makes the
compromise-vs-backdating rule enforceable.

## Scope

- Provider interface for ledger signing keys: **`sign(bytes)`** returning
  signature plus the key identifier used, and `publicKey(id)` for
  verification (decision 019, no key parameter on the signing path).
  Software provider now; KMS provider stubbed with the same tests, wired at
  provisioning (founder gate). Rotation is internal to the provider:
  `sign` always uses the current active key.
- `0006-key-event-log` (spine): `{party_id, key_id, event
  (registered|rotated|revoked|compromised), effective_at, ledger_ts}`,
  append-only, never edited.
- The verification rule as a kernel function: a signature is valid iff
  the key was active at signing time AND the attestation's ledger
  timestamp predates any compromise report for that key.
- No code path outside the kernel can reach a signing operation (criterion 5's
  first half; the no-non-operator-key rule lands with the registry). Note
  the amended invariant: the operator signs with **its own** key, held as a
  single registry self-entry (decisions 015/016). The rule is that no
  *other* party's key is invokable, not that no key is.

## Acceptance

- AC (mechanical): a compromise event at T invalidates verification for
  signatures ledger-stamped after T and leaves pre-T signatures valid,
  proven with a table-driven test across boundary cases.
- AC: provider swap is config-only; suite green under both.
- AC (mechanical): rotation is invisible to callers. `sign` continues to
  work across a rotation with no caller change, and reports the new key
  identifier.

## Outside check

Verifier runs the boundary-case table, adds one adversarial case
(backdated compromise claim), and confirms history is not retroactively
invalidated.

## Evidence

- AC 1 (compromise at T): `core/kernel/keyevent.go` holds the rule,
  `core/kernel/keyevent_test.go` the table. Every comparison the rule
  makes is exercised strictly before, exactly at, and strictly after,
  including at nanosecond distance from the report. The database half
  runs the same claim over rows that made a round trip through the spine
  (`TestTheCompromiseCutHoldsOverRowsReadBack`), so a coarsened or lost
  timestamp on the way in or out shows up.
  `TestABackdatedCompromiseClaimInvalidatesNothing` is the adversarial
  case the Outside check names, written before the rule.
- AC 2 (provider swap is config-only): `make signing-test` runs
  `core/kernel/operatorkey`'s whole suite once per provider with
  `GRAIN_KEY_PROVIDER` as the only difference between the two runs, the
  shape `envelope-test` already uses. Every test taking one provider
  takes the configured one, so the variable is load-bearing rather than
  decorative. `TestTheTwoProvidersMintDistinguishableIdentifiers` is
  what stops a swap passing by the two being one implementation in two
  coats.
- AC 3 (rotation is invisible): `TestRotationIsInvisibleToCallers`
  drives `kernel.Sign` with a byte-identical call on both sides of a
  rotation and asserts the record signed after names the new key, the
  record signed before still verifies, and the two are not the same key.
  Conformance checks 4 through 6 state the same contract for any future
  provider.
- Criterion 5's first half: `checks/signing-seam.mjs`, in
  `checks/run.mjs`'s metadata group and therefore in `make check` and
  CI. It flags a call to `ed25519.Sign`, `ed25519.GenerateKey`, or
  `ed25519.NewKeyFromSeed` outside `core/kernel`, `core/cmd/kernel-adapter`
  and `core/gen`. Red path 21 points it at a planted violation and at a
  verify-only package that must pass, since the lint bans producing a
  signature and not checking one.
- The log: `db/migrations/spine/0006-key-event-log.sql`. Append-only by
  the grants it does not hold, one event of each kind per key by its
  primary key, and `ledger_ts` unwritable by the serving role because
  the table-level INSERT grant is revoked and re-granted over the four
  columns a caller may name. Each of those three is asserted against the
  live database in `core/kernel/keylog/keylog_db_test.go`.
