---
id: self-asserted-record
type: layer
status: draft
milestone: first-product
depends_on: [person-identity, trust-kernel]
soft_depends_on: [extraction]
binds:
  - design/ledger-design-0.1.md#2.2
  - decisions/LOG.md#002
  - decisions/LOG.md#062
  - model/record-schema.md
gated_criteria: [3]
evidence: []
verified_by: null
---

# self-asserted-record

The worker-authored half of the record: chapters, positions, education,
credentials, and the confirmation surface that import writes through.

Grilled 2026-08-20, rulings in decision 062. Not yet through the
engineering review; task files wait for it.

Scope, per decision 062:

- Chapter and position CRUD against the ratified sections of
  `model/record-schema.md`, worker-editable with version history until
  first attestation, then frozen whole-object at the API and the
  database. Unattested claims are deletable; delete is the far end of
  edit.
- Education and credential CRUD against schema 0.2 §8 and §9, including
  the credential document attachment under the document rule (payload
  plane, subject DEK, pointer-not-file in packets, no provenance
  upgrade). Skills do not exist and nothing here reintroduces them.
- `party_country` and `party_locality` collected whenever `party_ref` is
  null, and `institution_country` and `issuer_country` likewise. Asked,
  never inferred: an LLM deriving a country from an employer name is the
  silent resolution the schema forbids.
- The import confirmation contract: the `extraction` layer proposes,
  this layer owns the review surface contract and the write. Worker
  confirmation is the floor, always; batch-level commit only when every
  populated field is source-span traceable and extraction confidence
  clears the published threshold, per-claim otherwise; zero-action
  auto-binding never. The uploaded artifact is ephemeral and no imported
  claim persists unconfirmed, with everything landing `self_asserted`.
- Self-asserted writes hash-chain through the trust kernel from day one.
- Out of scope: rendering (worker-surface), parsing and matching
  (`extraction`), dispute handling, coworker attestation, party registry
  state, and any verification.

Acceptance:

1. **Once attested, the edit path is closed at the API and the
   database, not just in the UI.** (mechanical) a frozen claim rejects
   edits and deletes at both layers; prior versions remain
   worker-readable; an unattested claim edits and deletes cleanly.
2. **Nothing imported is saved until the worker confirms it.**
   (mechanical) no imported claim persists without a recorded worker
   confirmation; every imported claim carries `self_asserted` provenance
   and `origin: resume_parsed`.
3. **Batch commit is earned, not default.** (mechanical, gated) a batch
   containing any field that is not source-span traceable, or whose
   extraction confidence is below the threshold the `extraction` layer
   publishes, falls back to per-claim confirmation. Gated: the threshold
   contract does not exist until `extraction` authors it.
4. **Claim writes either fit the schema or are rejected.** (mechanical)
   every write validates against schema 0.2 including the
   sensitive-data ban; no DOB, government ID, or photo from a resume
   enters the record.
5. **A failed import falls back to typing, never to a dead end.**
   import failure degrades to manual entry, never a blocked signup.
6. **Operator reads of version history are accountable.** (mechanical)
   an operator read of a worker's version history requires a recorded
   reason and lands in the worker's disclosure record; version history
   never appears in a prior packet.
7. **A credential document never changes what the record claims.**
   (mechanical) attaching a document leaves `provenance` unchanged, the
   file is reachable only through the payload plane under the subject's
   DEK, and a packet rendering shows the on-file pointer, never the
   file.
8. **Institution and issuer matches are confirmed, never assumed.**
   (mechanical) no `institution_ref` or `issuer_ref` is written without
   a recorded worker confirmation; the asserted raw string is stored
   verbatim in every case, match or no match.

Screens defect list from the 2026-08-20 audit, owned by the design pass,
recorded here so the grilling's findings are not rediscovered:

- `RequestAttestation` warns that the attestation is permanent but never
  that the worker's own claim freezes; the freeze warning describes the
  wrong permanence.
- `AddChapter` asks for neither `party_country`/`party_locality` nor
  `relationship_kind`, so the manual path cannot produce a valid
  chapter.
- `ChapterDetail` renders title as a chapter-level fact and claims to
  show every raw fact while missing roughly half the 0.1 field set.
- No screen exists for import failure to manual entry, sensitive-data
  rejection, education entry, credential entry, per-claim import
  confirmation, or a job-board/link import source.
- `Parsing` advertises "Matching businesses Grain already knows" as a
  silent pipeline step; matching is propose-and-confirm and the screen
  must show the confirmation.
- `AddPosition` asserts a non-overlap rule the schema does not have;
  the claim is dropped (decision 062).
