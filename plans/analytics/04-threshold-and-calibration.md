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
  published rule sentence and a suggestion path; the suggestion copy
  degrades honestly while no assessment product exists (it suggests
  adding evidence, never a product that is not there).
- Golden calibration fixtures: a set of fixture persons spanning the
  evidence space (single self-asserted chapter through corroborated
  multi-source histories), each annotated with what the product should
  do. These are the artifacts the founder rules the numeric parameters
  against.
- **The number is a raise, not a choice.** This task builds the
  construction and the fixtures, then raises the parameter ruling to
  the founder (ORDER.md decision gate). Criterion 3 stays gated until
  that ruling is recorded; this task's own acceptance does not include
  the ruling.

## Acceptance

1. AC (mechanical): with any parameter set, a fixture just below the
   line yields the insufficient-data result and no score, and one just
   above yields a score; the two outputs are structurally distinct.
2. AC (mechanical): the rule renders as one sentence from the live
   parameters; a parameter change changes the rendered sentence, so
   the published rule cannot drift from the enforced one.
3. AC (adjudicated): the calibration fixtures span the evidence space
   and their annotations are coherent, judged by a clean-context
   verifier against the fixture set alone.
4. AC (mechanical): the founder raise exists: a documented parameter
   proposal with fixture outcomes per candidate parameter set, filed
   for ruling.

## Outside check

Verifier runs the fixture suite at two parameter sets and confirms the
boundary behavior moves with the parameters and the rendered sentence
follows.
