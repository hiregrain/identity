---
id: extraction/04
type: task
layer: extraction
satisfies: [5]
status: ready
depends_on: [extraction/02, extraction/03]
migrations: []
binds: [decisions/LOG.md#062, decisions/LOG.md#072]
evidence: []
verified_by: null
---

# The published confidence contract

## Objective

The line between one-tap batch commit and per-claim confirmation is a
published rule that cannot drift from the enforced one.

## Scope

- The contract, per decision 072: field traceability is binary (a
  populated field carries a verified span or it is blank, task 02's
  verifier); match confidence is the calibrated probability (task 03);
  batch eligibility is every populated field traceable and every
  proposed match above the published threshold.
- The published rendering: the contract and its threshold render from
  the live configuration, the analytics threshold-sentence pattern, so
  published and enforced cannot diverge.
- This is the artifact self-asserted-record criterion 3 and its task
  09 are gated on; landing it is what promotes that task's gate.
- The threshold value starts at never-batch and moves only with eval
  numbers (task 05) behind it; the configuration schema marks the
  threshold's justification field required.

## Acceptance

1. AC (mechanical): a proposal set with one untraceable field or one
   below-threshold match evaluates batch-ineligible; fully traceable
   and above-threshold evaluates eligible; both against the stub
   engine.
2. AC (mechanical): the published contract renders from the live
   configuration; the drift check diffs published against rendered at
   two configurations and fails on a planted divergence.
3. AC (mechanical): a threshold configuration without a cited
   justification fails validation; the initial configuration is
   never-batch.

## Outside check

Verifier evaluates the eligibility fixtures at both configurations,
runs the drift check, and attempts the unjustified threshold.
