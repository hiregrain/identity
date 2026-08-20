---
id: self-asserted-record/09
type: task
layer: self-asserted-record
satisfies: [3]
status: draft
depends_on: [self-asserted-record/05]
migrations: []
binds: [decisions/LOG.md#062, decisions/LOG.md#063]
evidence: []
verified_by: null
---

# Batch commit earns its threshold

## Objective

A high-confidence import commits in one confirmation; anything doubtful
falls back to per-claim, and the line between them is published, not
guessed.

## Scope

- Draft by the gated_criteria convention: criterion 3 is gated until
  `extraction` authors and publishes its confidence contract (decision
  062). This task exists so the criterion's satisfying task is declared
  rather than implied, and it goes ready when that contract lands.
- When workable: task 05's batch plumbing reads the published threshold;
  a batch is eligible only when every populated field is source-span
  traceable and every claim and match clears the threshold; any
  ineligible row routes the whole batch to per-claim confirmation.
- The threshold value itself belongs to `extraction`; this task consumes
  it and never defines it. Setting it to never-batch must degrade
  cleanly to task 05's per-claim behaviour.

## Acceptance

1. AC (mechanical): a batch with one untraceable field or one
   below-threshold confidence routes to per-claim confirmation; a fully
   eligible batch commits on one confirmation with every row carrying
   its confirmation reference.
2. AC (mechanical): with the threshold set to never-batch, behaviour is
   identical to task 05's per-claim flow, proven by the same fixtures
   passing unchanged.

## Outside check

Verifier runs the eligibility fixtures at both threshold extremes
against the stub proposer and confirms criterion 2's constraint holds
for batch commits.
