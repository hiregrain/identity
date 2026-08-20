# Record schema: schema_version 0.2 (§2, §3, §7, §8, §9 RATIFIED)

Closes `DESIGN.md` gap 4: *"no field list exists anywhere for a work-history row,
a skill, or a credential. Every surface in this document renders data that is not
yet specified."*

**Ratification state.** Decision 062 ratifies the chapter (§2), position
(§3) and envelope (§7) sections as they stood in 0.1. Decision 063
ratifies `education` (§8) and `credential` (§9) with the engineering
review's corrections applied. All five bind. Section numbers §1 through
§9 are stable because other documents cite them.

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
| `chapter` | the worker | until a verification request, then the freeze rule | one band of the imprint |
| `position` | the worker | until its chapter freezes | a division inside the band |
| `attestation` | a registered party | never, append-only | thread density on the band |
| `chapter_standing` | derived by the ledger | recomputed | lobe depth |
| `grant` | the worker | revocable | not drawn |
| `dispute` | the worker | resolvable | a mark on the chapter |
| `education` | the worker | until a verification request, then the freeze rule | undecided, owned by worker-surface |
| `credential` | the worker | until a verification request, then the freeze rule | undecided, owned by worker-surface |
| `verification_request` | the worker | state transitions only | the freeze warning moment |

**The freeze rule (decision 062, trigger amended by 063).** A
worker-created object is fully worker-owned until a verification request
is issued on it: editable with version history, and deletable. Freeze
happens at request creation, not at attestation landing, so a party
never signs a version the worker changed after asking. The edit path
closes at the API and the database, whole object, never per field. If
the request ends with no attestation, declined or expired, the object
thaws back to worker-owned; once an attestation lands, the freeze is
permanent. Corrections after permanent freeze are new objects
(`superseded_by`) or the dispute path. Prior versions live in the
payload plane under the subject's DEK, die with the profile, and stay
readable by the worker and by operators; an operator read is a
privileged-operator-action event in the trust kernel's chain, carrying
a recorded reason. Prior versions never reach a reading party, because
edit history read by a party turns pre-verification editing into a
performance signal.

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

**Named-recipient sends** (decision 057, replacing 035's expiring link):
the worker sends access to a named person, who opens it by proving
control of the address it was sent to; one click, no account, no
password. Reads are identified and revocation is per recipient. An
account is required for analytics and for depth, never to read the
record. Creation states what the recipient receives: full work-history
detail, and the ability to ask Grain to analyse it (decision 035),
written as what the recipient gets, not as a warning. Grant state is
recorded as append-only event pairs; `granted_at`, `expires_at`, and
`revoked_at` are the projection of those events (decision 067). **The
public URL is not a grant.** It is a separate
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

## 8. `education`: enrollment at an institution (RATIFIED, decisions 062/063)

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
row carrying its source. The table and its seeding belong to the
`self-asserted-record` layer (decision 063); `extraction` proposes
against it and stores nothing. It lives in the global spine, not a
regional payload database: public reference data about institutions
carries no personal data and no residency obligation, and one copy
stays consistent where regional copies would drift (decision 064). Coverage is honest, not global: India's
UGC/AICTE and the Philippine CHED publish recognition data as documents,
not queryable registries (research/17 §8), so resolution in the target
population leans on the raw-string fallback. The registry proposes;
the worker confirms; unmatched stays raw.

**Not present, deliberately.** No grade or GPA: a score is a performance
claim, and the thesis rejects self-asserted performance. No thesis title,
no activities free text.

## 9. `credential`: a certificate, license, or attested course (RATIFIED, decisions 062/063)

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

## 10. `verification_request`: the freeze trigger (decision 063)

Defined by the `self-asserted-record` layer so freeze is testable in
first-product; the `verification` layer later owns issuance flows
against it. `ingestion`'s roster firewall already presumes this object
(`verification_request_id`).

| Field | Type | Notes |
|---|---|---|
| `request_id` | opaque id | |
| `subject_id` | `ledger_person_id` | |
| `claim_ref` | chapter, education, or credential id | freeze scope is this whole object |
| `party_ref` | registered party id | who is asked |
| `state` | enum | `open \| attested \| declined \| expired \| withdrawn_before_send` |
| `requested_at` · `expires_at` | | **Expiry is mandatory**, the grant precedent: no open-ended state may exist. An unanswered request to a dissolved employer expires and the claim thaws. |

Freeze on create; thaw on `declined`, `expired`, or
`withdrawn_before_send` (a worker pulling back an unsent ask recovers
the claim; the drawn "asking cannot be undone" copy describes the sent
ask); permanent once
`attested`. The expiry default is set at task level and is copy the
worker sees at the moment of asking.

Three ingestion rules bind this table (decision 069): a request is
**pinned** the moment an attestation against it is confirmed, and the
expiry sweep skips pinned requests, so nothing expires out from under
an accepted attestation; the `attested` transition is written by
ingestion's licensed recording function when the append completes; and
an `attested` request is the standing relationship anchor, so a
follow-up attestation from the same party about the same subject
references it instead of a fresh request (decision 031's
worker-initiates-first rule, made mechanical). The request delivered
to the party carries the party's pairwise pseudonym for the subject,
which is how a party first obtains the pseudonym it signs over. Freezable claims are `chapter`,
`education`, and `credential`; a `position` freezes with its chapter
(§1) and is never a `claim_ref` itself.

**Confirmation references (decision 064).** Three writes require a
recorded worker confirmation, enforced as database constraints created
with the record tables: an imported row's commit
(`origin: resume_parsed` requires a non-null confirmation reference),
an `institution_ref` write, and an `issuer_ref` write. The confirmation
row records what was shown and when the worker accepted it.

---

## 11. Open

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

1. ~~**Vocabulary conflict.**~~ **Closed by decision 069.** The ratified
   position wins: the vocabulary is ledger-authored with published
   crosswalks (decision 006, interface R-1); decision 028's ESCO line is
   superseded on this point. Ingestion owns the vocabulary table and the
   seeded v1 term set.
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
7. **Credential freeze is unreachable in first-product.** The freeze
   trigger is a `verification_request` (§10), and nothing issues
   requests against credentials until a verification layer exists.
   Stated so the gap reads as declared, not overlooked.
