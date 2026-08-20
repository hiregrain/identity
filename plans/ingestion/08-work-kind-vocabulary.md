---
id: ingestion/08
type: task
layer: ingestion
satisfies: []
status: ready
depends_on: [trust-kernel/08]
migrations: [0034-work-kind-vocabulary]
binds: [decisions/LOG.md#006, decisions/LOG.md#069, model/attestation-interface.md]
evidence: []
verified_by: null
---

# The work-kind vocabulary: ledger-authored, bound forever

## Objective

Every attestation names its kind of work in the ledger's own
vocabulary, and a term once bound at a version never changes meaning.

## Scope

- `0034-work-kind-vocabulary` (global spine, the institution-registry
  precedent: public reference data, no personal data, one copy): terms
  at detailed-work-activity grain, versioned, with immutable historical
  bindings per interface A-1/R-1; ledger-authored per decision 069,
  which closed the 028/006 conflict for the ratified position.
- A seeded v1 term set covering the first vertical's work kinds, each
  term carrying its definition; crosswalks to O*NET/ISCO/ESCO are
  published alongside and are not the binding.
- Term additions append at a new version; no term at a bound version is
  ever edited, enforced at the database like every append-only table
  here. Council governance arrives per the interface's versioning
  section; until then additions are founder-approved.
- `satisfies` is empty and legitimately so, the trust-kernel/08
  precedent (decision 065): vocabulary storage is what criterion 2's
  validation reads, not a layer capability of its own; its own
  acceptance is its done-condition.

## Acceptance

1. AC (mechanical): the v1 seed loads on a fresh clone; every term
   carries a definition and a version; `work_kind@version` lookups
   resolve for every seeded term and fail for an unknown term or an
   unbound version.
2. AC (mechanical): editing a term at a bound version fails at the
   database; adding the term at a new version succeeds and the old
   binding still resolves unchanged.
3. AC (mechanical): the published crosswalk file exists for the seeded
   set and a crosswalk entry pointing at a nonexistent term fails a
   check.

## Outside check

Verifier loads the seed on a fresh clone, attempts the bound-version
edit, and runs the crosswalk consistency check.
