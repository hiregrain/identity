---
id: worker-surface/04
type: task
layer: worker-surface
satisfies: [1, 2, 5, 6, 7, 8]
status: draft
depends_on: [worker-surface/01, worker-surface/03]
binds:
  - decisions/LOG.md#035
  - decisions/LOG.md#038
  - decisions/LOG.md#055
  - decisions/LOG.md#060
  - design/13-platform-screens
evidence: []
verified_by: null
---

# Asking a party to attest

## Objective

The three routes by which a chapter stops being only the worker's account
of it, and the state each leaves behind.

Surfaces implemented: D1, D2, D3, D4, D5, D6, D7.

**Widened after the 2026-08-21 pass.** D7 is the route chooser, without which D2,
D3 and D4 were unreachable from anywhere in the app: the record named the
chapters worth chasing and the sheet explaining the gap ended in a button that
closed it. Which routes it offers is decided by whether the party is registered,
because that is what decides whether Grain can check anything. D6 is the list of
requests already made, without which a worker could send several and then never
see any of them again.

## Scope

- The actionable list on the record, requesting attestation from a registered
  party, asking a manager by work address, asking a coworker, and the state a
  request leaves behind.
- **Each route says exactly what the party can and cannot write**, because the
  difference between them is the whole epistemic point. A coworker is a real
  witness, not a lesser answer, and the marks carry that difference rather
  than the words ranking them (decision 055).
- **The attester's own surfaces are not here.** Decision 038 put that flow on
  the web; an invitation opens `public-web` and the form is `peer-references`.
- No read events, in the request state or anywhere else (decision 035 §B4).
  A worker is never told the party opened the request.

## Acceptance

1. **Nothing counts or ranks what is unattested.** (mechanical) no surface in this task renders a count of unattested
  chapters, or any ordering that ranks one provenance class above another.
2. **Nothing here says whether anyone opened a request.** (mechanical) the request state surface exposes no field derived from
  whether the recipient has opened anything, asserted over the render tree.
3. **A request tells a party about one chapter and no others.** (mechanical) a request discloses to the party only the chapter it
  concerns, proven by inspecting the outbound payload for any other chapter.
4. **No surface calls the coworker route lesser.** (adjudicated) no surface describes the coworker route as lesser, weaker
  or a fallback, and no surface orders the routes by strength. **Decision 080
  narrowed this from a parity claim**, which asked copy to deny what the system
  states: 055 gives each provenance class its own mark so a reader can tell
  them apart. What it still catches is copy that makes a worker with informal
  employment history feel second-class.

## Outside check

Verifier sends one request by each route and confirms the record shows a
distinct mark for each outcome, and that nothing anywhere reports that a
recipient read the request.
