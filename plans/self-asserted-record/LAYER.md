---
id: self-asserted-record
type: layer
status: ready
milestone: first-product
depends_on: [person-identity, trust-kernel]
soft_depends_on: [extraction]
binds:
  - design/ledger-design-0.1.md#2.2
  - decisions/LOG.md#002
  - decisions/LOG.md#008
  - decisions/LOG.md#009
  - decisions/LOG.md#010
  - decisions/LOG.md#062
  - decisions/LOG.md#063
  - decisions/LOG.md#064
  - model/record-schema.md
  - model/attestation-interface.md
gated_criteria: [3, 10]
evidence: []
verified_by: null
---

# self-asserted-record

The worker-authored half of the record: chapters, positions, education,
credentials, the institution registry, the verification-request freeze
machinery, and the confirmation surface that import writes through.

Grilled 2026-08-20 (decision 062); engineering review passed the same
day (decision 063). Criteria are final.

Scope, per decisions 062 and 063:

- Chapter and position CRUD against the ratified sections of
  `model/record-schema.md`, worker-editable with version history until a
  verification request freezes the object (schema §1 freeze rule and
  §10). Freeze at request creation; thaw on decline or expiry; permanent
  once attested. Unfrozen claims are deletable; delete is the far end of
  edit, implemented as a tombstone version row because foundation/03's
  ratified invariant permits recording functions to INSERT only
  (decision 064); physical removal happens only at profile deletion
  through foundation/08.
- The `verification_request` table (schema §10), with mandatory expiry.
  This layer defines the table and the freeze/thaw transitions; the
  `verification` layer later owns issuance flows against it.
- Education and credential CRUD against schema §8 and §9, including the
  credential document attachment under the document rule (payload plane,
  subject DEK, no provenance upgrade). Skills do not exist and nothing
  here reintroduces them.
- The institution registry table and its seeding task: rows sourced from
  national accreditation lists with the source recorded per row.
  `extraction` proposes against it and stores nothing. Sourcing
  governance stays schema open item 6.
- `party_country` and `party_locality` collected whenever `party_ref` is
  null, and `institution_country` and `issuer_country` likewise. Asked,
  never inferred.
- The import confirmation contract: this layer defines the proposal
  payload shape and a stub proposer, so criteria 2 and 5 verify against
  the stub; `extraction` implements the contract. Worker confirmation is
  the floor, always; batch-level commit only when every populated field
  is source-span traceable and extraction confidence clears the
  published threshold, per-claim otherwise; zero-action auto-binding
  never. The uploaded artifact is ephemeral and no imported claim
  persists unconfirmed, with everything landing `self_asserted`.
- Self-asserted record writes hash-chain through the trust kernel from
  day one, as a governing event in the kernel's list (decision 063).
  Version history rows live in the payload plane under the subject's
  DEK and die with the profile.
- Operator reads of version history are privileged-operator-action
  events in the kernel's chain, with a recorded reason. This layer
  emits the event; worker-surface later renders these into the
  disclosure record.
- Out of scope: rendering (worker-surface), parsing and matching
  (`extraction`), packet assembly (prior-packet carries the
  pointer-not-file rule as an inherited criterion candidate), dispute
  handling, coworker attestation, and verification issuance flows.

Acceptance:

1. **Freeze and thaw follow the request lifecycle, enforced at the API
   and the database.** (mechanical) creating a verification request
   freezes the whole claim at both layers; decline and expiry each thaw
   it; a claim with an attested request rejects edits and deletes
   permanently; an unfrozen claim edits and deletes cleanly; prior
   versions remain worker-readable throughout.
2. **Nothing imported is saved until the worker confirms it.**
   (mechanical) an imported claim row cannot exist without a
   confirmation reference, the constraint schema §10 defines (decision
   064), not application discipline; every imported chapter, education,
   and credential carries `self_asserted` provenance and
   `origin: resume_parsed`, and positions ride their chapter. Verified
   against the stub proposer.
3. **Batch commit is earned, not default.** (mechanical, gated) a batch
   containing any field that is not source-span traceable, or whose
   extraction confidence is below the threshold the `extraction` layer
   publishes, falls back to per-claim confirmation. Gated: the threshold
   contract does not exist until `extraction` authors it.
4. **Claim writes either fit the schema or are rejected.** (mechanical)
   every write validates against schema 0.2 and rejects the
   `model/attestation-interface.md` A-4 sensitive-data ban categories,
   as extended by decisions 008 and 010, including scanning free-text
   fields; no DOB, government ID, or photo from a resume enters the
   record.
5. **A failed import falls back to typing, never to a dead end.**
   (adjudicated) import failure degrades to manual entry, never a
   blocked signup.
6. **Operator reads of version history are accountable.** (mechanical)
   an operator read of a worker's version history emits a
   privileged-operator-action event into the trust kernel's chain,
   carrying a recorded reason; a read with no event is impossible by
   construction. That version history never appears in a packet is
   prior-packet's inherited criterion, provable only where packets are
   built (decision 064).
7. **A credential document never changes what the record claims.**
   (mechanical) attaching a document leaves `provenance` unchanged and
   the file is reachable only through the payload plane under the
   subject's DEK.
8. **Institution matches are confirmed, never assumed.** (mechanical) no
   `institution_ref` is written without a confirmation reference,
   enforced by a database constraint; the asserted raw string is stored
   verbatim in every case, match or no match.
9. **Every record write is chained, and deletion leaves no hash
   behind.** (mechanical) every committed claim write, manual and
   imported, across chapters, education, and credentials, with position
   writes chaining through their chapter's stream, appends to the
   subject's per-stream chain and passes chain verification over a
   CRUD-plus-import fixture; the fixture includes delete-after-chain,
   proving no hash retention across deletion (decision 009).
10. **Issuer matches are confirmed, never assumed.** (mechanical, gated)
    no `issuer_ref` is written without a confirmation reference,
    enforced the same way as criterion 8. Gated: matching requires the
    party registry, a v1 layer; first-product ships raw issuer strings
    only.

Screens defect list from the 2026-08-20 audit, owned by the design pass,
recorded here so the grilling's findings are not rediscovered. **Every item was
discharged in the 2026-08-21 design pass**, in `design/13-platform-screens` and
imported by `design/14-web-app`; each is marked with what closed it. The list
stays rather than being deleted, because a discharged defect that leaves no
trace is one nobody can check was ever fixed.

- DISCHARGED. `RequestAttestation` warns that the attestation is permanent but never
  that the worker's own claim freezes at the ask, thawing only if no
  attestation arrives (decision 063 trigger).
- DISCHARGED. `AddChapter` asked for neither `party_country`/`party_locality` nor
  `relationship_kind`, so the manual path cannot produce a valid
  chapter.
- DISCHARGED by decision 074 and the redraw. `ChapterDetail` rendered title as a chapter-level fact and claimed to
  show every raw fact while missing roughly half the 0.1 field set.
- DISCHARGED. No screen existed for import failure to manual entry, sensitive-data
  rejection, education entry, credential entry, per-claim import
  confirmation, or a job-board/link import source.
- DISCHARGED. `Parsing` advertised "Matching businesses Grain already knows" as a
  silent pipeline step; matching is propose-and-confirm and the screen
  must show the confirmation.
- DISCHARGED. `AddPosition` asserted a non-overlap rule the schema does not have;
  the claim is dropped (decision 062).
