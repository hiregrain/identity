---
id: trust-kernel/02
type: task
layer: trust-kernel
satisfies: [5]
status: ready
depends_on: [trust-kernel/01, foundation/03]
migrations: [0006-key-event-log]
binds: [design/stack-litigation/d3-verdict.md, decisions/LOG.md#011]
evidence: []
verified_by: null
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
