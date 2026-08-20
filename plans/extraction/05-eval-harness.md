---
id: extraction/05
type: task
layer: extraction
satisfies: []
status: ready
depends_on: [extraction/02]
migrations: []
binds: [decisions/LOG.md#072, decisions/LOG.md#073]
evidence: []
verified_by: null
---

# The eval harness: numbers before proposals

## Objective

No script gets proposals until an engine has passing numbers on it,
and every engine competes on the same corpus.

## Scope

- The corpus: synthetic-only and English-only in v0 (decision 073),
  each fixture with golden expected proposals; languages expand by
  decisions entry as markets are entered, and no donated real document
  enters without a recorded consent and a deletion path.
- Per-engine, per-script accuracy published from harness runs into
  `contract/eval-registry.json` (committed empty by task 01, schema
  owned here): pass/fail per script
  with the run it came from; a registry entry without a run reference
  fails validation.
- Engine comparison is the same harness: any candidate engine,
  commercial or otherwise, scores on the same corpus, which is what
  makes the seam's switch decision a numbers decision (decision 072).
- The harness runs in its own environment and is the only thing that
  calls real engines; CI runs it against the stub only.
- `satisfies` is empty and legitimately so, the trust-kernel/08
  precedent: the harness is what criterion 3's gate and criterion 7's
  future ruling read, not a layer capability; its own acceptance is
  its done-condition.

## Acceptance

1. AC (mechanical): the harness scores the stub engine on the corpus
   and produces the per-script report; golden report for the stub
   matches byte for byte.
2. AC (mechanical): an eval-registry entry without a run reference
   fails validation; flipping a script to passing changes task 01's
   gate behavior, riding its fixtures.
3. AC (mechanical): the corpus manifest's language list equals the
   ruled v0 list, English only (decision 073), and every corpus
   fixture is tagged synthetic; a donated-tagged fixture fails
   validation while no consent instrument exists.

## Outside check

Verifier runs the harness on the stub, diffs the golden report, and
reads the corpus manifest against the thesis.
