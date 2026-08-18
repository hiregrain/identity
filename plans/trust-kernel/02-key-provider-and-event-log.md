---
id: trust-kernel/02
type: task
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

- Provider interface for ledger signing keys: `sign(kid, bytes)`,
  `publicKey(kid)` — software provider now; KMS provider stubbed with the
  same tests, wired at provisioning (founder gate).
- `0006-key-event-log` (spine): `{party_id, key_id, event
  (registered|rotated|revoked|compromised), effective_at, ledger_ts}`,
  append-only, never edited.
- The verification rule as a kernel function: a signature is valid iff
  the key was active at signing time AND the attestation's ledger
  timestamp predates any compromise report for that key.
- No code path outside the kernel can reach a signing operation (AC-TK5's
  first half; the no-party-key rule lands with the registry).

## Acceptance

- AC (mechanical): a compromise event at T invalidates verification for
  signatures ledger-stamped after T and leaves pre-T signatures valid —
  table-driven test across boundary cases.
- AC: provider swap is config-only; suite green under both.

## Outside check

Verifier runs the boundary-case table, adds one adversarial case
(backdated compromise claim), and confirms history is not retroactively
invalidated.
