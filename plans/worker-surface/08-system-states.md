---
id: worker-surface/08
type: task
layer: worker-surface
satisfies: [5, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#035
  - DESIGN.md#12
  - design/08-app-inventory.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# The five states, and the screens that are only a state

## Objective

The states every surface must carry, built once as shell renderers rather
than drawn sixty times, plus the surfaces that are nothing but a state.

Surfaces implemented: I1, I2, I3, I4, I5, I8, I10.

## Scope

- Loading, empty, error with a retry, offline, and permission denied, as
  renderers a surface declares rather than screens each surface redraws.
  `design/08` §2 treats these as work remaining per surface, which is five
  times the register; this is the same coverage at a fraction of the surface
  area.
- Offline is §12's micro-caption band with the record still readable from
  cache, never a dialog.
- Address not found, update required, signed out unexpectedly, the content of
  each push notification, and the legal surfaces.
- **Push content carries no read events** (decision 035 §B4). The three events
  are a party attesting, a grant ending, and a dispute deadline.
- Address not found never reveals whether an address once existed.

## Acceptance

- AC (mechanical): every surface in the register declares which of the five
  states it has, and every declared state renders non-empty and distinct.
  A surface declaring none fails.
- AC (mechanical): the offline state leaves the record readable, proven by
  cutting the network and asserting the cached record still renders.
- AC (mechanical): no push payload contains a field derived from a read event.
- AC (mechanical): the not-found surface emits an identical response for an
  address that never existed and one that was deleted.
- AC (adjudicated): no error surface blames the worker or reports a raw
  exception.

## Outside check

Verifier cuts the network mid-session and confirms the record still reads,
then requests a deleted handle and a never-existent one and confirms the two
responses are indistinguishable.
