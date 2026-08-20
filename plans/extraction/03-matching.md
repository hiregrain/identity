---
id: extraction/03
type: task
layer: extraction
satisfies: [4]
status: ready
depends_on: [extraction/02, self-asserted-record/03]
migrations: []
binds: [decisions/LOG.md#062, decisions/LOG.md#072]
evidence: []
verified_by: null
---

# Match proposal: propose with a probability, never assert

## Objective

An extracted employer or institution name comes back with candidates
and honest numbers, and nothing binds until a worker says so.

## Scope

- Splink run locally as a library over the institution registry
  (self-asserted-record/03's table); no candidate means the raw string
  stands. The party tier is a declared v1 extension arriving with
  party-registry (decision 073), not built here.
- Calibrated match probabilities from the Fellegi-Sunter model, the
  number the confidence contract publishes a threshold against;
  proposals carry candidates and probabilities, never a binding.
- Operating posture, stated as this layer's own rule: the threshold is
  set against the false-merge rate, never F1, because a
  false match attributes one worker's employer to another's.
- Blocking and comparison configuration is versioned like the
  instrument tables elsewhere; a config change without a version bump
  fails a check.

## Acceptance

1. AC (mechanical): a name matching a registry row proposes it with
   candidates ranked by probability; a name matching nothing yields no
   candidates and the raw string unmodified.
2. AC (mechanical): every candidate carries a calibrated probability;
   the fixture set includes a known-different-entity pair whose
   probability falls below any sane threshold, the false-merge guard.
3. AC (mechanical): the proposal payload schema carries no binding
   field, so a pre-bound `institution_ref` cannot exist in a proposal,
   asserted by schema validation with a planted-field red path.

## Outside check

Verifier runs the tiered fixtures, checks the false-merge pair, and
inspects privileges.
