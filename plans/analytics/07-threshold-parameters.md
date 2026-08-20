---
id: analytics/07
type: task
layer: analytics
satisfies: [3]
status: draft
depends_on: [analytics/04]
migrations: []
binds: [decisions/LOG.md#066, decisions/LOG.md#067]
evidence: []
verified_by: null
---

# The ruled threshold parameters land

## Objective

The founder's numeric ruling becomes the live line, and the boundary
fixtures prove the product refuses below it and answers above it.

## Scope

- Draft by the gated_criteria convention: this task goes ready only
  when the founder has ruled the numeric parameters against task 04's
  calibration fixtures (ORDER.md decision gate). It exists so
  criterion 3's satisfying task is declared rather than implied.
- When workable: the ruled parameters land as the live configuration,
  the ruling's decisions entry is cited at the site, and the published
  rule sentence renders from them.

## Acceptance

1. AC (mechanical): the live parameters equal the ruled ones, asserted
   against the decisions entry's stated values; the golden fixtures
   just below and just above the ruled line produce the refusal and
   the score respectively.
2. AC (mechanical): the published sentence rendered from the live
   parameters matches the ruling, byte-for-byte.

## Outside check

Verifier reads the ruling's decisions entry and the live configuration,
diffs the rendered sentence against the ruled one, and runs the
boundary fixtures at the ruled line.
