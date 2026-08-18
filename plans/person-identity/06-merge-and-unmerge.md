---
id: person-identity/06
type: task
status: ready
depends_on: [person-identity/05, trust-kernel/03]
migrations: [0013-merge-events-and-aliases]
binds: [decisions/LOG.md#013, decisions/LOG.md#017, decisions/LOG.md#019, decisions/LOG.md#020, design/ledger-design-0.1.md#1.4]
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
  append-only events; **alias state is derived from those events, never a
  mutable pointer** — decision 017 dropped the blanket derived/cache
  exemption, so the alias projection is licensed by name to a named role at
  its migration site like `stream_heads`, and "unmerge flips the pointer"
  becomes "unmerge appends an event and the projection follows";
  alias-closure resolution at read time.
- **Attested history is never rewritten**: attestations keep the
  `subject_id` they were issued against forever (rewriting would break
  every signature); reads assemble across the closure.
- Two-steward approval where both records carry verified attestations,
  one otherwise (decision 013). Approval identities recorded on the
  event.
- Unmerge flips the alias pointer; attestations issued against the
  survivor *during* the merged window are flagged for steward
  re-assignment review (the one genuinely manual residue).
- **Chain implications** (decision 019). Chain membership is fixed at write
  time and never re-keyed: a merge moves no record between chains, and every
  attestation stays in the chain keyed to the id live when it was written.
  Both persons' subject streams continue independently. **The merge event
  appends to both subject chains** (decision 020) — survivor and absorbed —
  because the merge changed the absorbed chain's meaning more than the
  survivor's, and with membership now permanent, a merge absent from the
  absorbed chain would never be recorded there at all. An auditor walking
  either chain alone must see a complete story. Unmerge likewise appends to
  both.
- **Deletion under merge** (decision 017): destroying a merged person
  destroys every DEK in the alias closure — a surviving pre-merge key would
  leave the record readable. This task owns the closure, so it owns proving
  the deletion subsystem receives the correct one, including under a
  merge-or-unmerge racing a deletion.

## Acceptance

- AC (mechanical): merge → unmerge round-trips with zero mutation of
  either event stream; every signature still verifies.
- AC (mechanical): reads through an absorbed id resolve to the survivor
  in the merged state and back to the original after unmerge.
- AC (mechanical): a single-steward merge over two attested records is
  rejected.
- AC (mechanical): a merge appends to both subject chains; an auditor
  walking the absorbed chain alone sees the event that changed its
  resolution.
- AC (mechanical): merge and unmerge move no record between chains —
  membership is byte-identical before and after.
- AC (mechanical): the alias projection rebuilds exactly from its events; no
  mutable pointer exists.
- AC (mechanical): deleting a merged person yields the full alias closure to
  the deletion subsystem, including when a merge or unmerge is executing
  concurrently.
- AC: merge-window attestations surface in the re-assignment queue on
  unmerge.

## Outside check

Verifier executes merge, verifies all signatures, unmerges, re-verifies,
and confirms the re-assignment queue contents — then attempts the
single-steward path.
