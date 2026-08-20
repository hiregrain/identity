---
id: analytics/03
type: task
layer: analytics
satisfies: [2, 7, 9]
status: ready
depends_on: [self-asserted-record/01]
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
  references where any exist (none in first-product), and the
  observable meta-signals decision
  022 names (average tenure in role, described responsibility,
  seniority). The `provenance` field on each claim is the input;
  fixtures set it directly, so no attestation machinery is needed to
  test weighting (decision 067).
- Provenance weighting with fixed published weights: `self_asserted`,
  `peer_attested`, and `party_attested` evidence for the same assertion
  never weigh equally; corroboration (`none | single | multi`) enters
  the weight, and one claim corroborated by two sources counts once at
  higher weight, never twice; the weight table is versioned, and the
  run record carries the instrument version on every run.
- Party score exclusion: the scoring path contains no reference to
  party score fields, a grep-class check over the query surface; the
  column-privilege assertion lands with v1 when ingestion creates
  `score_summary` (decision 067).
- Determinism as a property of the whole instrument: no LLM, no
  network call, no clock- or randomness-dependent value inside a
  scored run (the run record's timestamp and pseudonym are written by
  the runner, outside the instrument). LLM enhancement is a later
  instrument version with its own decisions entry (decision 066).

## Acceptance

1. AC (mechanical): two fixtures asserting the same claim at different
   provenance classes produce different weights; one claim
   corroborated by two sources counts once at higher weight, proven by
   a fixture where double-counting would cross a distinct output
   boundary; a
   `self_asserted`-only fixture never reaches the confidence of a
   corroborated `party_attested` fixture with the same content.
2. AC (mechanical): the query surface contains no reference to party
   score fields, asserted by a grep-class check with a red-path
   fixture.
3. AC (mechanical): the same inputs and instrument version produce
   byte-identical output across repeated runs and across processes,
   and a scored run completes with network egress blocked; the run
   record written for the fixture run carries the instrument version.
4. AC (mechanical): the weight table is versioned; changing a weight
   without bumping the version fails a check.

## Outside check

Verifier re-runs the determinism fixture on a fresh clone with egress
blocked, diffs outputs byte-for-byte, and runs the query-surface check.
