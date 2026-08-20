---
id: self-asserted-record/07
type: task
layer: self-asserted-record
satisfies: [6]
status: ready
depends_on: [self-asserted-record/01, trust-kernel/02]
migrations: []
binds: [decisions/LOG.md#063]
evidence: []
verified_by: null
---

# Operator reads of version history are chained events

## Objective

An operator cannot look at a worker's edit history without leaving a
tamper-evident record of who, when, and why.

## Scope

- The version-history read path for operators goes through one function
  that emits a privileged-operator-action event into the trust kernel's
  event log before returning data; the event carries operator identity,
  subject, claim ref, and a mandatory reason from a controlled reason
  list.
- Impossible-without-event by construction: the history tables grant no
  read to operator roles except through that function, the same
  narrow-path pattern as the recording functions.
- Version history is excluded from every packet assembly input; the
  exclusion is asserted here and inherited by prior-packet when it
  builds.
- Worker-facing rendering of these events is worker-surface's scope.

## Acceptance

1. AC (mechanical): an operator history read emits exactly one chained
   privileged-operator-action event with a reason; a read with an empty
   or unlisted reason is rejected.
2. AC (mechanical): operator roles have no direct SELECT on version
   tables; the only path is the emitting function, proven by privilege
   inspection and a bypass attempt.
3. AC (mechanical): the worker's own history reads emit no operator
   event and are not reason-gated.

## Outside check

Verifier inspects role privileges on a fresh clone, performs a read
through the function and a bypass attempt around it, and confirms the
event lands in the kernel log with the chain intact.
