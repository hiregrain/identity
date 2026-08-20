---
id: verification/03
type: task
layer: verification
satisfies: [1, 4]
status: ready
depends_on: [verification/02, verification/04]
migrations: []
binds: [decisions/LOG.md#010, decisions/LOG.md#040, decisions/LOG.md#070]
evidence: []
verified_by: null
---

# The Persona sandbox adapter

## Objective

The primary vendor's flow runs end to end against its sandbox,
results-only, and a worker who fails or abandons it loses nothing.

## Scope

- The Persona adapter behind `verify(person, method)`, against the
  sandbox environment; the capture step hands off with the vendor
  named on Grain's screen (decision 040 relaxing 036 F3), and the SDK
  facts recorded in the layer (legacy-bridge RN module, no
  `codegenConfig`, no Expo plugin, forced location prompt) are handled
  and documented at the integration site.
- Results-only: the adapter receives the vendor's outcome and builds
  the attestation in the A-2 shape; no document image, biometric, or
  raw PII from the
  vendor persists anywhere in the ledger (decision 010), asserted by
  schema (no image or binary column exists in any verification table)
  and by the all-writes inspection; the vendor transaction reference
  persists payload-side only.
- The liveness step is separate and declinable (decision 036, the part
  040 did not relax): declining liveness completes the document method
  at document level; accepting it is the biometric method. Both shapes
  land here.
- Failure and abandonment: the flow ends with the account at its prior
  assurance level; retry is available; nothing partial persists.
- Production credentials are task 06's gated flip, not this task.

## Acceptance

1. AC (mechanical): a sandbox pass produces an attestation through
   ingestion with method, level, and expiry populated; the
   all-writes inspection during the flow finds no image or biometric
   payload in either plane.
2. AC (mechanical): a sandbox fail and an abandonment each leave the
   derived assurance level byte-identical to its pre-flow value and
   leave no partial rows.
3. AC (mechanical): production credential configuration fails the
   startup check unless it cites a founder ruling decisions entry at
   the configuration site; sandbox configuration passes without one.
4. AC (mechanical): declining liveness yields a document-level
   attestation; accepting it yields the biometric method; both against
   sandbox fixtures.

## Outside check

Verifier runs pass, fail, and abandon fixtures against the sandbox on
a fresh clone and inspects all writes during each.
