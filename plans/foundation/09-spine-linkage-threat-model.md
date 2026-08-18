---
id: foundation/09
type: task
status: abandoned
depends_on: [foundation/04]
migrations: []
binds: [decisions/LOG.md#017, research/06]
evidence: []
verified_by: null
---

# Spine linkage threat model

> **ABANDONED 2026-08-18.** Cut on founder ruling. The correlation questions
> this task existed to ask move into `foundation/04` as a reviewer checklist
> applied when a spine column is added, rather than a standing document that is
> stale the week after it lands. The reasoning below is retained because the
> checklist is derived from it.

## Objective

Establish what the spine leaks by correlation, given that it leaks nothing
by column — because the column-level lint can never answer this question.

## Scope

- The gap this closes: AC-F3 promises no readable personal data on the
  spine and enforces it with a type lint. The lint blocks a `text` column.
  It cannot prove an opaque `bytea` or id does not encode a name, and it
  says nothing about the harder direction — **stable object ids,
  timestamps, issuer ids, and commitment patterns can identify people by
  correlation with zero readable columns present**.
- Deliverable: a written threat model covering, at minimum — id structure
  and whether ordering leaks enrollment time; timestamp granularity and
  what activity patterns it exposes; issuer-id plus timing correlation
  against a known external roster; commitment and salt reuse across
  streams; and what an adversary holding a partial external dataset can
  join against.
- For each identified leak: state the mitigation adopted, or state
  explicitly that the risk is accepted and why. An accepted risk that is
  written down is a decision; an unexamined one is a liability.
- Feeds back into `foundation/04`'s allow-list and per-column
  justification requirement: any spine column outside the allow-list is
  reviewed against this model, not just against the type lint.
- This is a document task with no code. It is in foundation because every
  layer above adds spine columns, and they need something to be reviewed
  against.

## Acceptance

- AC: the model covers every spine column existing at authoring time, with
  a leak assessment and either a mitigation or a recorded accepted risk
  for each.
- AC: at least the five correlation vectors named in scope are addressed
  explicitly, including the ones concluded to be non-issues.
- AC: `foundation/04`'s justification requirement references this document
  as the review standard.

## Outside check

Verifier picks two spine columns at random and confirms each has a leak
assessment and a disposition; attempts the roster-correlation attack
described in the model against a synthetic dataset to confirm the stated
mitigation holds.
