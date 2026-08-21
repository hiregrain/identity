---
id: worker-identity-surface
type: layer
status: draft
milestone: v1
depends_on: [worker-surface, verification]
binds:
  - decisions/LOG.md#010
  - decisions/LOG.md#028
  - decisions/LOG.md#036
  - decisions/LOG.md#040
  - decisions/LOG.md#046
  - decisions/LOG.md#070
  - decisions/LOG.md#071
  - decisions/LOG.md#079
  - decisions/LOG.md#080
  - design/08-app-inventory.md
  - design/12-platform-seam.md
gated_criteria: []
evidence: []
verified_by: null
---

# worker-identity-surface

The screens a worker walks to have an identity document checked. Register
section F, and nothing else.

**Why this is its own layer** (decision 079). It was task 05 of
`worker-surface`, and the outside voice argued that layer was several layers
wearing one name. The argument survived because this corner is gated on things
no engineer controls: the Persona DPA and its sixteen US subprocessors, India
DPDP residency, and counsel on the vendor terms (`plans/ORDER.md`, decisions
040 §C and 070). Left inside `worker-surface`, a legal timetable would have
held the record, sharing, deletion and onboarding hostage. Split out, it blocks
only itself.

**The boundary, which already existed.** `plans/verification/LAYER.md` records
it: "request-creation UX surfaces (worker-surface renders, this layer exposes
the flows)". `verification` owns the adapter, the vendor integration, the
method extensions and the derived assurance level. This layer owns the screens
and nothing under them. It renders in the chassis `worker-surface` task 01
builds, which is why it depends on that layer rather than duplicating it.

**The alternative that was not taken, recorded so it is not rediscovered.**
These surfaces could have moved into `verification`, whose gates are already
exactly the ones that block them. That was rejected because `verification` is
`ready`, and widening a ready layer's scope is what the plan protocol exists to
prevent (decision 039's own warning). A new draft layer is the cheaper mistake.

Scope: the identity flow's screens end to end. Why now and what is taken; the
country and document choice; the handoff to the vendor's own capture, which
neither vendor permits an app to host (040 §C); the checking state; the result
and what it does not send; liveness as a separate declinable step after the
document passes (036); and the could-not-verify state with a route that does
not dead-end. The camera permission prompt belongs here because nothing else
asks for a camera.

**Not in scope**: the vendor adapter, the assurance ladder's computation, and
sanctions screening, all `verification`. The chassis, the bar and the five-state
renderer, all `worker-surface`. Storage of anything the vendor returns, which
decision 010 settles as results-only and which no surface touches.

Acceptance:
1. **The ladder never reaches a party.** (mechanical) no packet or
   party-facing payload produced anywhere in this layer carries the
   none/channel/document/biometric level, asserted on the serialised payload
   rather than on a screen. Decision 071 supersedes 028 on this line: a binary
   verified chip is a graded claim collapsed to a yes, which the constitution
   forbids.
2. **No surface calls a person verified.** (mechanical) the string "verified"
   never renders applied to a person, asserted over the render tree of every
   surface in this layer. A document is checked; a person is not a claim that
   can be true (027).
3. **Declining costs nothing already held.** (mechanical) declining liveness
   leaves every pre-existing fact on the record unchanged and every existing
   grant resolving, proven by diffing the record before and after a decline.
4. **No image reaches a store this layer can read.** (mechanical) no document
   or liveness image is written to any store reachable from this layer,
   asserted by inspecting every write path the surfaces expose. **The vendor's
   own retention is `verification`'s to prove, not this layer's**; the split is
   decision 079's, because a surface cannot prove a vendor's behaviour.
5. **The vendor is named before the handoff, not after.** (adjudicated) given
   the criterion and the diff, a verifier finds the capture screen names the
   vendor and says what it will do before the vendor's screen opens. 036
   requires the worker never be handed to a stranger mid-flow.
6. **Every surface carries all five of its states.** (mechanical) every surface
   in register section F carries loading, empty, error with a retry, offline
   and permission denied, or declares in the register why a state does not
   apply to it.
7. **Every surface renders on both platforms and at 200% type.** (mechanical)
   both platforms, both viewports, no clipped or overlapping text.

## Design venue

The surfaces are drawn in
[`design/13-platform-screens/`](../../design/13-platform-screens/) and imported
by `design/14-web-app`. The mockup gate binds here exactly as it does in
`worker-surface`: nothing is built until the surface it implements is drawn.

## What blocks this layer, and it is not engineering

The Persona DPA and its subprocessor scope, India DPDP residency, and counsel on
the vendor terms. All three are founder gates in `plans/ORDER.md`. Sandbox work
is ungated; live verification is not.
