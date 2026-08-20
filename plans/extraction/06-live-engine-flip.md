---
id: extraction/06
type: task
layer: extraction
satisfies: [7]
status: draft
depends_on: [extraction/02, extraction/05]
migrations: []
binds: [decisions/LOG.md#072]
evidence: []
verified_by: null
---

# The live engine flip

## Objective

Real resumes flow to a commercial model the day the founder names it
and its retention terms, and not a day before.

## Scope

- Draft by the gated_criteria convention: this task goes ready only
  when a decisions entry records the founder's engine ruling, naming
  the model, its zero-data-retention terms, and the eval numbers it
  cleared (task 05's harness). The verification-layer flip pattern.
- When workable: production engine configured citing the ruling at the
  site; the eval registry's passing scripts are the proposal-enabled
  set; the stub remains CI's engine forever.

## Acceptance

1. AC (mechanical): the production configuration cites the ruling's
   decisions entry and its terms reference at the site; startup fails
   without them.
2. AC (mechanical): a production-flow fixture in the vendor's test
   mode yields proposals identical in shape to the stub's, diffed
   against the contract schema.

## Outside check

Verifier reads the ruling entry, confirms the citations at the site,
and diffs production and stub proposal shapes.
