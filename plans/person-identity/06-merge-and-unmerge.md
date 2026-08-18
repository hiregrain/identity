---
id: person-identity/06
type: task
status: ready
depends_on: [person-identity/05, trust-kernel/03]
migrations: [0013-merge-events-and-aliases]
binds: [decisions/LOG.md#013, design/ledger-design-0.1.md#1.4]
evidence: []
verified_by: null
---

# Merge and unmerge

## Objective

Two records become one — reversibly, without rewriting a single
attestation or breaking a single signature.

## Scope

- `0013-merge-events-and-aliases`: `person_merged{survivor_id,
  absorbed_id, evidence_refs, actor, ts}` and `person_unmerged{...}` as
  append-only events; a permanent alias table; alias-closure resolution
  at read time.
- **Attested history is never rewritten**: attestations keep the
  `subject_id` they were issued against forever (rewriting would break
  every signature); reads assemble across the closure.
- Two-steward approval where both records carry verified attestations,
  one otherwise (decision 013). Approval identities recorded on the
  event.
- Unmerge flips the alias pointer; attestations issued against the
  survivor *during* the merged window are flagged for steward
  re-assignment review (the one genuinely manual residue).
- Chain implications: both persons' subject streams continue
  independently; the merge event itself is a spine record in the
  survivor's stream.

## Acceptance

- AC (mechanical): merge → unmerge round-trips with zero mutation of
  either event stream; every signature still verifies.
- AC (mechanical): reads through an absorbed id resolve to the survivor
  in the merged state and back to the original after unmerge.
- AC (mechanical): a single-steward merge over two attested records is
  rejected.
- AC: merge-window attestations surface in the re-assignment queue on
  unmerge.

## Outside check

Verifier executes merge, verifies all signatures, unmerges, re-verifies,
and confirms the re-assignment queue contents — then attempts the
single-steward path.
