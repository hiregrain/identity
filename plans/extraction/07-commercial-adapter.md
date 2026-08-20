---
id: extraction/07
type: task
layer: extraction
satisfies: []
status: ready
depends_on: [extraction/02]
migrations: []
binds: [decisions/LOG.md#072, decisions/LOG.md#073]
evidence: []
verified_by: null
---

# The commercial engine adapter, sandbox mode

## Objective

The chosen commercial model drives extraction through the seam in test
mode, sending only text and accepting only the contract.

## Scope

- The commercial API adapter behind task 02's seam, structured output
  enforced against the proposal contract, sandbox/test-mode
  configuration only; the production flip is task 06's gated ruling.
- The adapter's configuration shape requires the zero-data-retention
  terms reference even in test mode, so the requirement exists before
  the ruling does.
- Only the text layer is ever sent, the seam's signature already
  guarantees it; the adapter adds no document upload path.
- `satisfies` is empty and legitimately so, the trust-kernel/08
  precedent: the adapter is an implementation behind criteria 2 and 6,
  which task 02's stub already discharges; its own acceptance is its
  done-condition.

## Acceptance

1. AC (mechanical): the adapter passes the same golden contract
   fixtures as the stub in the vendor's test mode, run by the eval
   harness environment and attached as evidence; CI runs none of it.
2. AC (mechanical): adapter configuration without a
   zero-data-retention terms reference fails validation, in test mode
   too.
3. AC (mechanical): the adapter's landing diff touches only the
   adapter directory and the engine registry, the task 02
   path-allowlist check.

## Outside check

Verifier re-validates the attached harness evidence against the
contract schema, attempts the termless configuration, and runs the
allowlist check over the landing commit.
