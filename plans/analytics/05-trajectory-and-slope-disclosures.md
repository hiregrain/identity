---
id: analytics/05
type: task
layer: analytics
satisfies: [4]
status: ready
depends_on: [analytics/03]
migrations: []
binds: [decisions/LOG.md#022, decisions/LOG.md#066]
evidence: []
verified_by: null
---

# Trajectory computation and the slope disclosures

## Objective

A trajectory read that states its own three failure modes on its face,
in words the founder ratified.

## Scope

- Deterministic trajectory computation over the assembled evidence:
  progression meta-signals (tenure per position, responsibility
  described, role changes over time), instrument-versioned like
  everything in v0. Where `chapter_standing` exists it enters; in
  first-product it mostly will not, and the computation degrades to
  the meta-signals honestly rather than inventing levels.
- **The slope disclosure text is this task's deliverable** (decision
  066): the three failure modes from decision 022 (routing flattens
  raw grades while ability rises; frozen difficulty priors read
  promotions as decline; grader drift tracks the trend being measured)
  drafted as product copy, carried on the face of every trajectory
  output, unslop-compliant. The founder ratifies the text at this
  task's review; until then it is draft copy in the PR.
- Mapping fidelity and customer-authored views are deferred to v1
  (decision 067): the artifact is modeled nowhere and blocked on
  `chapter_standing`, which first-product does not derive. The task
  carries the disclosure copy knowingly beside the computation, the
  self-asserted-record 03/05 pattern: the halves share one
  done-condition, a trajectory output that is honest on its face.

## Acceptance

1. AC (mechanical): every trajectory output carries the three
   disclosures in the rendered output, not only the payload, asserted
   by rendering fixtures.
2. AC (adjudicated): the disclosure text states the three failure
   modes accurately against decision 022's wording, judged by a
   clean-context verifier given only 022 and the rendered output.
3. AC (mechanical): trajectory output is byte-identical across
   repeated runs at the same instrument version.

## Outside check

Verifier renders the fixtures, reads the disclosures against decision
022 with no other context, and re-runs for determinism.
