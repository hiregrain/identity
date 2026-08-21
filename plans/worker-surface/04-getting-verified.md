---
id: worker-surface/04
type: task
layer: worker-surface
satisfies: [1, 5, 6, 7, 8]
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

Surfaces implemented: D1, D2, D3, D4, D5.

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

- AC (mechanical): no surface in this task renders a count of unattested
  chapters, or any ordering that ranks one provenance class above another.
- AC (mechanical): the request state surface exposes no field derived from
  whether the recipient has opened anything, asserted over the render tree.
- AC (mechanical): a request discloses to the party only the chapter it
  concerns, proven by inspecting the outbound payload for any other chapter.
- AC (adjudicated): given the criterion and the diff, a verifier finds that
  the coworker route is not presented as a fallback or a lesser option.

## Outside check

Verifier sends one request by each route and confirms the record shows a
distinct mark for each outcome, and that nothing anywhere reports that a
recipient read the request.
