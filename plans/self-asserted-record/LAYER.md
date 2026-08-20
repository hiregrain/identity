---
id: self-asserted-record
type: layer
status: draft
milestone: first-product
depends_on: [person-identity]
binds:
  - design/ledger-design-0.1.md#2.2
  - decisions/LOG.md#002
evidence: []
verified_by: null
---

# self-asserted-record

The worker-authored half of the record, and its ingestion accelerants.

**Added 2026-08-19:** claim CRUD and résumé import both populate
`chapter.party_country` and `party_locality` whenever `party_ref` is null
(`model/record-schema.md`). Import must ask rather than guess: an LLM inferring a
country from an employer name is exactly the silent resolution the schema forbids.

Scope: self-asserted claim CRUD (work history, skills, credentials,
education at credential-name/issuer grain only), worker-editable with
version history until first third-party verification, then frozen with the
edit path closed (freeze warning shown at the moment verification is
requested, per the consent design); **resume/profile import**: LLM
extraction into the strict claim schema (OSS layout/OCR for PDF-to-text
only, legacy OSS resume parsers rejected as abandonware), worker reviews
and confirms every extracted claim before save, everything lands as
`self_asserted`; job-board/profile-link import through the same pipeline
with source attribution kept vertical-side; import is a funnel accelerant,
never a trust source.

Acceptance:
1. **Once verified, the edit path is closed at the API, not just in the UI.** (mechanical) a verified claim's edit path is closed at the API
   and DB layer; prior versions remain worker-visible.
2. **Nothing imported is saved until the worker confirms it.** no imported claim persists without explicit worker confirmation;
   every imported claim carries `self_asserted` provenance.
3. **Extraction output either fits the schema or is rejected.** (mechanical) extraction output validates against the claim
   schema including the sensitive-data ban (no DOB, government IDs, photos
   from resumes enter the record).
4. **A failed import falls back to typing, never to a dead end.** import failure degrades to manual entry, never a blocked signup.
