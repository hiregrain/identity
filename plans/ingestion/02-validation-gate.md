---
id: ingestion/02
type: task
layer: ingestion
satisfies: [2]
status: ready
depends_on: [ingestion/01, ingestion/08]
migrations: []
binds: [model/attestation-interface.md, decisions/LOG.md#008, decisions/LOG.md#010, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# The validation gate and the published pattern set

## Objective

Nothing malformed and nothing banned gets past the door, and the rules
that say so are published, not guessed at.

## Scope

- Schema validation at submission, before the queue: interface
  version, required fields per scope (`engagement | period |
  evaluation`), `work_kind@version` existence against the
  ledger-authored vocabulary task 08 stores (decision 069),
  `evaluation_kind` present iff scope is evaluation (A-7).
- The banned-information scanner: the A-4 list plus the 008/010
  extensions (government IDs, birth dates, health data, criminal
  proceedings, nationality and immigration detail, education beyond
  credential name and issuer, sanctions hit detail), enforced in every
  field including free text by fixed patterns (decision 068). The
  pattern set lives at `contract/ban-patterns.json`, created by this
  task; the scanner reads that file at startup, so the
  published rules and the enforced rules cannot diverge, and the AC2
  check diffs the loaded patterns against the file.
- Rejections are synchronous and structured, naming the failed rule;
  nothing failing validation reaches the queue.

## Acceptance

1. AC (mechanical): each banned category, planted in a structured
   field and in free text, is rejected with a structured error naming
   the category, proven against red-path fixtures per category.
2. AC (mechanical): the scanner's live patterns are read from the
   published set; a pattern change without republishing fails a check.
3. AC (mechanical): a schema-invalid submission (bad version, missing
   field, unknown work_kind, evaluation_kind mismatch) is rejected
   synchronously and never enqueued, proven by queue inspection after
   each red-path fixture.

## Outside check

Verifier runs every red-path fixture, diffs the live patterns against
the published set, and inspects the queue after each rejection.
