# Record schema: schema_version 0.2 (PROPOSED; §2, §3, §7 RATIFIED)

Closes `DESIGN.md` gap 4: *"no field list exists anywhere for a work-history row,
a skill, or a credential. Every surface in this document renders data that is not
yet specified."*

**Ratification state.** Decision 062 ratifies the chapter (§2), position
(§3) and envelope (§7) sections as they stood in 0.1; those sections bind.
0.2 adds `education` (§8) and `credential` (§9), which are PROPOSED until a
founder ratifies them. Section numbers §1 through §7 are stable across the
version because other documents cite them.

**Scope.** This defines the ledger's own record objects: what a worker owns, what
the imprint renders, what a surface displays. It does **not** redefine the
boundary contract; `model/attestation-interface.md` (RATIFIED, 0.2) owns what
crosses to and from a vertical, and nothing here changes it.

The two documents divide as: **an attestation is what a party asserts; a chapter
is what the record holds; standing is what the ledger derives.**

---

## 1. Objects

| Object | Created by | Mutable | Renders as |
|---|---|---|---|
| `chapter` | the worker | until first attestation, then frozen | one band of the imprint |
| `position` | the worker | until its chapter freezes | a division inside the band |
| `attestation` | a registered party | never, append-only | thread density on the band |
| `chapter_standing` | derived by the ledger | recomputed | lobe depth |
| `grant` | the worker | revocable | not drawn |
| `dispute` | the worker | resolvable | a mark on the chapter |
| `education` | the worker | until first attestation, then frozen | undecided, owned by worker-surface |
| `credential` | the worker | until first attestation, then frozen | undecided, owned by worker-surface |

**The freeze rule (decision 062).** A worker-created object is fully
worker-owned until the first attestation lands on it: editable with
version history, and deletable. From that moment its edit path closes at
the API and the database, whole object, never per field. Corrections
after freeze are new objects (`superseded_by`) or the dispute path. Prior
versions stay readable by the worker and by operators whose reads are
reason-gated, logged, and written to the worker's disclosure record;
they never reach a reading party, because edit history read by a party
turns pre-verification editing into a performance signal.

**There is no `skill` object.** The seven responsibility dimensions replace it.
A skill list is a self-asserted claim about capability; a dimension level is an
attested claim about scope of work performed. Introducing skills would reintroduce
the self-asserted-competence model the thesis rejects.

**`education` and `credential` exist from 0.2** (decision 062, reversing
0.1's exclusion). 0.1 kept credentials in the prior packet only; the packet
now carries projections of the record objects in §8 and §9, each with its
provenance class. Education earned its object because degree-granting
institutions are the one issuer population with authoritative registries
to resolve against; credentials ride along self-asserted, with
verification arriving in a later layer.

---

## 2. `chapter`: the atom

One relationship with one party. Decision 028: tenure is the relationship, not the
activity. A task platform worked sporadically across three years is **one**
chapter. A rehire after leaving is a **new** chapter.

| Field | Type | Notes |
|---|---|---|
| `chapter_id` | opaque id | never reissued |
| `subject_id` | `ledger_person_id` | |
| `party_ref` | registered party id, nullable | null when the party is unregistered |
| `party_asserted` | string, nullable | worker-typed name, used only when `party_ref` is null. **Never mutated, and never resolved into `party_ref` automatically. A name match is not an identity.** Normalization is derived and disposable; the raw string is authoritative and must be reproducible verbatim. |
| `party_country` | ISO 3166-1 alpha-2 | **Required whenever `party_ref` is null.** Disambiguating context for later resolution. |
| `party_locality` | string, nullable | City or town as the worker gives it. Same purpose. |
| `relationship_kind` | enum | `employment \| engagement \| platform \| agency \| self_employed` |
| `started_on` · `ended_on` | month precision | **Month, never day.** Day precision is more identifying, invites exact-gap inference, and is not needed by any surface. `ended_on` null while ongoing. |
| `ended_reason` | enum, optional | `relationship_ended \| party_declared_dormant`. Never a reason for leaving, that is a performance claim wearing a metadata costume. |
| `positions[]` | array of `position` | §3 |
| `work_kind` · `work_kind_version` | `term@version` | The ledger's own vocabulary, bound immutably (interface A-1, R-1). Crosswalks to O\*NET/ISCO/ESCO are published; the crosswalk is not the binding. |
| `volume` | `{unit, count}`, optional | units completed across the chapter |
| `provenance` | enum | `self_asserted \| peer_attested \| party_attested`. Derived from the strongest attestation attached; `self_asserted` when none. |
| `corroboration` | enum | `none \| single \| multi`. Count of distinct attesting parties, coarsened. Never a number on any surface. |
| `attestation_refs[]` | ids | attestations scoped to this chapter |
| `disputed` | bool | true while any unresolved dispute references this chapter |
| `origin` | enum | `worker_created \| resume_parsed \| ingested`. `resume_parsed` requires worker confirmation before commit. |
| `superseded_by` | chapter id, optional | corrections are new chapters, never edits |

**Not present, deliberately.** No job title as a first-class comparable field.
Titles are administrative acts and `THESIS.md` rejects them as a progression
signal; the title lives on `position` as an asserted string for human reading
only. No salary. No reason-for-leaving. No manager name. No performance free text.

## 3. `position`: a promotion or role change inside a chapter

| Field | Type | Notes |
|---|---|---|
| `position_id` | opaque id | |
| `title_asserted` | string | display only, never compared across parties |
| `started_on` · `ended_on` | month precision | must fall inside the chapter's bounds |
| `is_current` | bool | |

Renders as a hairline division within the band, spaced tighter than the gap
between chapters (decision 028).

## 4. `chapter_standing`: derived, never asserted

Per chapter, per dimension. The ledger computes this; no party writes it.

| Field | Type | Notes |
|---|---|---|
| `dimension` | enum of 7 | fixed slot order, the angular registration of the imprint depends on it never changing |
| `level_entry` · `level_exit` | 0–6 | 0 means *not exercised* and is a legitimate, non-pejorative score |
| `corroboration` | `single \| multi` | per dimension, not per chapter |
| `as_of` | date | |
| `supporting_attestation_refs[]` | ids | |

**Derivation rule.** The drawn level is the **exit** level. Where attesting parties
disagree, the level is the highest at which at least two parties agree; a lone
attester's claim stands at their level but carries `single`. **Disagreeing
attesters are never averaged.** Averaging invents a level nobody asserted.

`level_entry` exists so slope is computable in the analytics layer. **It is not
drawn in the imprint** (`imprint/README.md` §2).

## 5. `grant`: the unit of consent

| Field | Type | Notes |
|---|---|---|
| `grant_id` | opaque id | |
| `subject_id` · `grantee_party_ref` | | |
| `scope` | enum | `read_record \| write_attestation \| both` |
| ~~`chapters`~~ | none | **Deleted, decision 035 §B3.** A grant is always the whole record. A chapter-scoped grant is claim curation wearing a grant's clothes and silently reverses founder decision 7 (`design/ledger-design-0.1.md` §7.1). |
| `granted_at` · `expires_at` | | **expiry is mandatory**; a grant with no end is a permanent disclosure the worker forgets making |
| `revoked_at` | nullable | |
| `last_read_at` | nullable | **Not surfaced to the worker, decision 035 §B4.** The worker sees the grant's *state* (issued, active, expired, revoked) and no read events. The field is retained for the disclosure record that satisfies GDPR Art. 15(1)(c) on request. |

**Share links** are grants with no `grantee_party_ref`, a 30-day default expiry,
and a statement at creation of what the recipient receives: full work-history
detail, and the ability to ask Grain to analyse it (decision 035). It is written
as what the recipient gets, not as a warning. **The public URL is not a grant.** It is a separate
worker-curated projection carrying verification status and work history only.

## 6. `dispute`

| Field | Type | Notes |
|---|---|---|
| `dispute_id` | | |
| `chapter_ref` · `attestation_ref` | | |
| `raised_by` | `subject` | only the worker raises |
| `statement` | string | the worker's account, attached permanently |
| `state` | enum | `open \| party_amended \| party_declined \| withdrawn` |

**Grain adjudicates authenticity, never substance** (decision 028). There is no
`resolved_by_ledger` state on a substantive dispute, and that absence is
deliberate: FCRA §611 reinvestigation is a defining CRA duty.

A disputed claim stays **visible and marked**, never hidden, never removed.

---

## 7. Envelope

W3C Verifiable Credentials 2.0 for signing, status and presentation (decision
028). The payload is ours. **Open Badges 3.0 and 1EdTech CLR are rejected as the
payload shape.** They model an issuer *conferring an achievement*, which is the
credential logic the thesis attacks.

---

## 8. `education`: enrollment at an institution (PROPOSED, decision 062)

One enrollment at one institution. A second degree at the same
institution is a new record, parallel to the rehire rule on chapters.

| Field | Type | Notes |
|---|---|---|
| `education_id` | opaque id | never reissued |
| `subject_id` | `ledger_person_id` | |
| `institution_ref` | institution registry id, nullable | null when unresolved. Resolution is propose-and-confirm, never automatic; the worker confirms every match. |
| `institution_asserted` | string | worker-typed name, always stored, never mutated, authoritative when `institution_ref` is null. Same rule as `party_asserted`. |
| `institution_country` | ISO 3166-1 alpha-2 | **Required whenever `institution_ref` is null.** Same disambiguation purpose as `party_country`. |
| `degree_level` | enum | `secondary \| diploma \| bachelor \| master \| doctorate \| other`. Closed set; a crosswalk to EQF levels may be published later and, as with `work_kind`, the crosswalk is not the binding. |
| `field_of_study` | string | raw, never mutated. A named slot for an ISCED-F crosswalk exists (published, not binding) but no in-house taxonomy is invented; every institutional standard surveyed defers here (research/17). |
| `started_on` · `ended_on` | month precision | same rule as chapters |
| `completed` | bool | an uncompleted enrollment is a legitimate record, not a defect |
| `provenance` | enum | `self_asserted \| party_attested`. Derived, `self_asserted` when no attestation. |
| `attestation_refs[]` | ids | |
| `disputed` | bool | |
| `origin` | enum | `worker_created \| resume_parsed`. `resume_parsed` requires worker confirmation before commit. |
| `superseded_by` | education id, optional | corrections are new records, never edits |

**The institution registry** is a curated table seeded from national
accreditation lists (US DAPIP, UK UKRLP, PH TESDA and equivalents), each
row carrying its source. Coverage is honest, not global: India's
UGC/AICTE and the Philippine CHED publish recognition data as documents,
not queryable registries (research/17 §8), so resolution in the target
population leans on the raw-string fallback. The registry proposes;
the worker confirms; unmatched stays raw.

**Not present, deliberately.** No grade or GPA: a score is a performance
claim, and the thesis rejects self-asserted performance. No thesis title,
no activities free text.

## 9. `credential`: a certificate, license, or attested course (PROPOSED, decision 062)

| Field | Type | Notes |
|---|---|---|
| `credential_id` | opaque id | never reissued |
| `subject_id` | `ledger_person_id` | |
| `issuer_ref` | registered party id, nullable | a certifying body may be a registered party; matched propose-and-confirm, never automatically |
| `issuer_asserted` | string | worker-typed issuer name, always stored, never mutated, authoritative when `issuer_ref` is null |
| `issuer_country` | ISO 3166-1 alpha-2 | **Required whenever `issuer_ref` is null.** |
| `credential_name` | string | raw, never mutated. No credential vocabulary exists; issuer populations are open sets like employers (decision 062). |
| `issued_on` · `expires_on` | month precision | `expires_on` null when the credential does not expire. A renewal is a new record, never an edit. |
| `document_ref` | payload-plane object id, nullable | see the document rule below |
| `provenance` | enum | `self_asserted` only in 0.2. Verification of credentials is a later layer, declared here rather than implied. |
| `disputed` | bool | |
| `origin` | enum | `worker_created \| resume_parsed` |
| `superseded_by` | credential id, optional | |

**The document rule (decision 062, discharging decision 053's gate for
this object).** A worker may attach a certificate document. The file
lives in the payload plane under the subject's DEK and dies at profile
deletion. A prior packet says "document on file, self-asserted" and
never carries the file. A document's presence never upgrades
`provenance`: an uploaded PDF read as verification is a graded claim
collapsing into a yes. What Grain asserts by accepting a document is
with counsel (brief 7) and blocks nothing here.

---

## 10. Open

0. **Employer normalization at scale.** `party_country` and `party_locality`
   exist because most chapters in the target population name businesses that never
   register, in many scripts and many spellings of one employer, and **context you
   do not collect at entry cannot be backfilled**. Resolving those strings into
   canonical employers is a real problem and is deliberately *not* modelled here:
   its first genuine consumer is cross-worker aggregation in `analytics`, and
   nothing in `v1` or `first-product` needs it (decision 040 §E, corrected). When
   it is built, two rules already stated above govern it: the raw string is never
   mutated, and clustering proposes but never asserts. The operating threshold
   is set against the **false-merge rate**, never F1, because a false merge
   attributes one worker's employer to another's.

1. **Vocabulary conflict.** Decision 028 records "ESCO for `work_kind`". Ratified
   decision 006 / interface R-1 says the vocabulary is **ledger-authored** with
   published crosswalks to O\*NET/ISCO/ESCO. This document follows the ratified
   position. **The founder should close this**; the ratified position looks
   correct, since ESCO's coverage of informal and platform work is thin and that
   is precisely this product's population.
2. **The chapter-boundary rule for dormancy.** `party_declared_dormant` exists so
   no record silently closes on a timeout, but nothing defines what a party must
   do to declare it.
3. **Volume units.** `{unit, count}` is unconstrained. Cross-party comparability
   needs a controlled unit list or it becomes free text.
4. **Whether `chapter.provenance` can regress.** If a party's registration is
   suspended, does an existing `party_attested` chapter fall back? The interface
   says suspension is never retroactive and produces a read-time flag, so
   probably no, but the chapter surface has to render that flag.
5. ~~**Public-URL projection.**~~ **Closed by decision 035.** Whole record or no
   record; no per-chapter curation on any surface. The single lever is the
   imprint, full or absent. Always indexed, with a reduced page for crawlers and
   logged-out visitors, and the imprint always behind sign-in. Field list in
   `design/06-worker-app-ia.md` §5–6.
6. **Institution registry governance.** Which national lists seed it,
   the refresh cadence, and what happens when an institution loses
   accreditation with enrollments already resolved to it. The India and
   Philippine sources need scraping or third-party data (research/17
   §8), and nothing yet rules what sourcing standard a registry row must
   meet.
7. **Credential freeze is unreachable in 0.2.** `credential.provenance`
   is `self_asserted` only, so the freeze rule in §1 never triggers for
   credentials until a verification layer gives them attestations. Stated
   so the gap reads as declared, not overlooked.
