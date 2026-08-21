---
id: worker-identity-surface/01
type: task
layer: worker-identity-surface
satisfies: [1, 2, 3, 4, 5, 6, 7]
status: draft
depends_on: []
binds:
  - decisions/LOG.md#010
  - decisions/LOG.md#027
  - decisions/LOG.md#036
  - decisions/LOG.md#040
  - decisions/LOG.md#071
  - research/09-idv-vendor-landscape.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# Checking identity, and what never crosses

## Objective

The identity flow, and the constraint that shapes every word in it: nowhere
may a graded claim collapse into a yes.

Surfaces implemented: F1, F2, F3, F4, F5, F6, F7, I6.

## Scope

- Why now, document type and issuing country, the handoff to capture,
  checking, the result, liveness, failure, and the camera permission.
- **Capture is a handoff, not a hosted camera** (decision 040 §C). Neither
  vendor permits hosting the capture step in the host app's chrome, so this is
  Grain's screen naming the vendor before it opens, so the worker is never
  handed to a stranger mid-flow.
- **Liveness is a separate, declinable step after the document passes**
  (decision 036), so refusing it costs nothing the worker already has.
- **The ladder never reaches a partner** (decision 071, superseding 028 on
  this line). none/channel/document/biometric is internal and worker-facing
  and appears in no packet and no party-facing payload, because a binary chip
  is a graded claim collapsed to a yes.
- Results only; no document image ever enters the ledger (decision 010).

## Acceptance

1. **The assurance ladder never reaches a party.** (mechanical) no packet or party-facing payload produced anywhere in
  this flow contains an assurance tier, a verification chip, or any boolean
  derived from one. Asserted over the serialised payload, not the UI.
2. **No surface calls a person verified.** (mechanical) no surface renders the string "verified" applied to a
  person, asserted over the rendered text of every surface in this task.
3. **Declining liveness costs nothing already on the record.** (mechanical) declining liveness leaves every pre-existing fact on the
  record unchanged, proven by comparing the record before and after.
4. **No document image reaches a store this layer can read.** (mechanical) no document image is written to any store the ledger can
  read, asserted after a full capture cycle.
5. **The vendor is named before its screen opens, not after.** (adjudicated) the capture screen names the vendor before the handoff
  rather than after, and does not depict a viewfinder the integration does not
  provide.

## Outside check

Verifier completes a document check, then dumps every payload the flow emits
to a party and confirms none carries a tier or a chip. Then declines liveness
and confirms nothing already on the record changed.
