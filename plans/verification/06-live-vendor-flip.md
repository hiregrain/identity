---
id: verification/06
type: task
layer: verification
satisfies: [7]
status: draft
depends_on: [verification/03]
migrations: []
binds: [decisions/LOG.md#040, decisions/LOG.md#070]
evidence: []
verified_by: null
---

# The live vendor flip

## Objective

Production verification starts the day the founder rules the vendor
terms acceptable, and not a day before.

## Scope

- Draft by the gated_criteria convention: this task goes ready only
  when a decisions entry records the founder's ruling on the vendor
  terms (subprocessor scope, retention and destruction schedules,
  India residency posture), backed by an internal research memo in
  `research/` (decision 070). No counsel is engaged or planned; the
  gate names its real owner.
- When workable: production credentials configured, the sandbox-only
  check from task 03 retired in the same change, retention and
  destruction schedules from the signed terms recorded beside the
  configuration, and the KMS-conformance founder gate's cross-session
  destroy scenario noted as still governing the production KMS side.

## Acceptance

1. AC (mechanical): the production configuration cites the ruling's
   decisions entry at the site; the sandbox-only check is retired in
   the same diff, asserted over the landing commit.
2. AC (mechanical): a production-flow fixture (vendor test mode)
   produces an attestation through ingestion identical in shape to the
   sandbox fixtures.

## Outside check

Verifier reads the ruling entry, confirms the citation at the
configuration site, and diffs the production and sandbox attestation
shapes.
