---
id: analytics/04
type: task
layer: analytics
satisfies: [3]
status: ready
depends_on: [analytics/03]
migrations: []
binds: [decisions/LOG.md#066]
evidence: []
verified_by: null
---

# The confidence threshold: construction, fixtures, and the raise

## Objective

Below the evidence line the product refuses with a reason instead of
guessing, and the line itself is a published sentence, not a vibe.

## Scope

- The threshold construction per decision 066: evidence-class-based
  and deterministic, a stated minimum of distinct sources and
  provenance classes, expressible in one published sentence. Built
  with the parameters as named configuration, not literals.
- The insufficient-data result: a structured refusal carrying the
  published rule sentence and a suggestion path. The refusal renders
  the rule and never the person's source count (decision 067). The
  suggestion diverges from 022 knowingly (decision 067): it suggests
  adding evidence, never an assessment product that does not exist,
  and reverts to 022's wording when assessment ships.
- Golden calibration fixtures: fixture persons from a single
  self-asserted chapter through corroborated multi-source histories,
  each annotated with the expected outcome per candidate parameter
  set. These are the artifacts the founder rules the numeric
  parameters against (ORDER.md decision gate).
- **The number is a raise, not a choice.** This task builds the
  construction and the fixtures; task 07 (draft) lands the ruled
  parameters and discharges criterion 3, which stays gated until then
  per ORDER.md's gated_criteria convention.

## Acceptance

1. AC (mechanical): at each of two named test parameter sets, the
   fixture just below the line yields the insufficient-data result and
   no score, the one just above yields a score, and the boundary moves
   with the parameters; the two outputs are structurally distinct.
2. AC (mechanical): the rule renders as one sentence from the live
   parameters; a parameter change changes the rendered sentence, so
   the published rule cannot drift from the enforced one; the rendered
   refusal contains no per-person source count, asserted on the
   refusal fixture.
3. AC (mechanical): every provenance class and every corroboration
   value appears in at least one calibration fixture, asserted by a
   coverage check over the fixture set.

## Outside check

Verifier runs the fixture suite at two parameter sets and confirms the
boundary behavior moves with the parameters and the rendered sentence
follows.
