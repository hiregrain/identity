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

- Splink run locally as a library over the candidate sources in ruled
  priority order: Grain-registered parties, then the institution
  registry (self-asserted-record/03's table), then no candidate and
  the raw string stands.
- Calibrated match probabilities from the Fellegi-Sunter model, the
  number the confidence contract publishes a threshold against;
  proposals carry candidates and probabilities, never a binding.
- Operating posture per the schema's employer-normalization rule: the
  threshold is set against the false-merge rate, never F1, because a
  false match attributes one worker's employer to another's.
- Blocking and comparison configuration is versioned like the
  instrument tables elsewhere; a config change without a version bump
  fails a check.

## Acceptance

1. AC (mechanical): fixtures at each tier resolve in priority order;
   a name matching both a registered party and a registry row
   proposes the party first; a name matching nothing yields no
   candidates and the raw string unmodified.
2. AC (mechanical): every candidate carries a calibrated probability;
   the fixture set includes a known-different-entity pair whose
   probability falls below any sane threshold, the false-merge guard.
3. AC (mechanical): no code path writes a `party_ref` or
   `institution_ref` anywhere; proposals are the only output, proven
   by privilege inspection.

## Outside check

Verifier runs the tiered fixtures, checks the false-merge pair, and
inspects privileges.
