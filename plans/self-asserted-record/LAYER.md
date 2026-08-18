---
id: self-asserted-record
type: layer
status: draft
milestone: first-product
depends_on: [person-identity]
binds:
  - design/ledger-design-0.1.md#2.2
  - decisions/LOG.md#002
acceptance: [AC-SA1, AC-SA2, AC-SA3, AC-SA4]
evidence: []
verified_by: null
---

# self-asserted-record

The worker-authored half of the record, and its ingestion accelerants.

Scope: self-asserted claim CRUD (work history, skills, credentials,
education at credential-name/issuer grain only) — worker-editable with
version history until first third-party verification, then frozen with the
edit path closed (freeze warning shown at the moment verification is
requested, per the consent design); **resume/profile import**: LLM
extraction into the strict claim schema (OSS layout/OCR for PDF-to-text
only — legacy OSS resume parsers rejected as abandonware), worker reviews
and confirms every extracted claim before save, everything lands as
`self_asserted`; job-board/profile-link import through the same pipeline
with source attribution kept vertical-side; import is a funnel accelerant,
never a trust source.

Acceptance:
- AC-SA1 (mechanical): a verified claim's edit path is closed at the API
  and DB layer; prior versions remain worker-visible.
- AC-SA2: no imported claim persists without explicit worker confirmation;
  every imported claim carries `self_asserted` provenance.
- AC-SA3 (mechanical): extraction output validates against the claim
  schema including the sensitive-data ban (no DOB, government IDs, photos
  from resumes enter the record).
- AC-SA4: import failure degrades to manual entry, never a blocked signup.
