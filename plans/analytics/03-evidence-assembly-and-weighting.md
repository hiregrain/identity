---
id: analytics/03
type: task
layer: analytics
satisfies: [2, 7, 9]
status: ready
depends_on: []
migrations: []
binds: [decisions/LOG.md#022, decisions/LOG.md#066, model/record-schema.md]
evidence: []
verified_by: null
---

# Deterministic evidence assembly and provenance weighting

## Objective

The v0 instrument: inputs assembled from the record, weighted by how
well they are known, producing the same answer every time, with no
model anywhere in it.

## Scope

- Input assembly from the record objects: work history at whatever
  verification level exists, education and credentials, structured
  references where any exist, and the observable meta-signals decision
  022 names (average tenure in role, described responsibility,
  seniority).
- Provenance weighting with fixed published weights: `self_asserted`,
  `peer_attested`, and `party_attested` evidence for the same assertion
  never weigh equally; corroboration (`none | single | multi`) enters
  the weight; the weight table is versioned and its version is what the
  run record carries.
- `score_summary` exclusion enforced at the query surface: the scoring
  path has no read on party score fields.
- Determinism as a property of the whole instrument: no LLM, no
  network call, no clock- or randomness-dependent value inside a
  scored run (the run record's timestamp and pseudonym are written by
  the runner, outside the instrument). LLM enhancement is a later
  instrument version with its own decisions entry (decision 066).

## Acceptance

1. AC (mechanical): two fixtures asserting the same claim at different
   provenance classes produce different weights; a
   `self_asserted`-only fixture never reaches the confidence of a
   corroborated `party_attested` fixture with the same content.
2. AC (mechanical): the scoring path cannot read `score_summary`,
   asserted by a check over the query surface and by privilege on the
   column.
3. AC (mechanical): the same inputs and instrument version produce
   byte-identical output across repeated runs and across processes,
   and a scored run completes with network egress blocked.
4. AC (mechanical): the weight table is versioned; changing a weight
   without bumping the version fails a check.

## Outside check

Verifier re-runs the determinism fixture on a fresh clone with egress
blocked, diffs outputs byte-for-byte, and runs the query-surface check.
