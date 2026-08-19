# Record Schema — schema_version 0.1 (PROPOSED)

Closes `DESIGN.md` gap 4: *"no field list exists anywhere for a work-history row,
a skill, or a credential. Every surface in this document renders data that is not
yet specified."*

**Scope.** This defines the ledger's own record objects — what a worker owns, what
the imprint renders, what a surface displays. It does **not** redefine the
boundary contract; `model/attestation-interface.md` (RATIFIED, 0.2) owns what
crosses to and from a vertical, and nothing here changes it.

The two documents divide as: **an attestation is what a party asserts; a chapter
is what the record holds; standing is what the ledger derives.**

---

## 1. Objects

| Object | Created by | Mutable | Renders as |
|---|---|---|---|
| `chapter` | the worker | minor edits only | one band of the imprint |
| `position` | the worker | minor edits only | a division inside the band |
| `attestation` | a registered party | never — append-only | thread density on the band |
| `chapter_standing` | derived by the ledger | recomputed | lobe depth |
| `grant` | the worker | revocable | not drawn |
| `dispute` | the worker | resolvable | a mark on the chapter |

**There is no `skill` object.** The seven responsibility dimensions replace it.
A skill list is a self-asserted claim about capability; a dimension level is an
attested claim about scope of work performed. Introducing skills would reintroduce
the self-asserted-competence model the thesis rejects.

**There is no `credential` object here** — `credentials[]` already exists in the
prior packet and stays there, carrying its provenance class.

---

## 2. `chapter` — the atom

One relationship with one party. Decision 028: tenure is the relationship, not the
activity. A task platform worked sporadically across three years is **one**
chapter. A rehire after leaving is a **new** chapter.

| Field | Type | Notes |
|---|---|---|
| `chapter_id` | opaque id | never reissued |
| `subject_id` | `ledger_person_id` | |
| `party_ref` | registered party id, nullable | null when the party is unregistered |
| `party_asserted` | string, nullable | worker-typed name, used only when `party_ref` is null. **Never mutated, and never resolved into `party_ref` automatically — a name match is not an identity.** Normalization is derived and disposable; the raw string is authoritative and must be reproducible verbatim. |
| `party_country` | ISO 3166-1 alpha-2 | **Required whenever `party_ref` is null.** Disambiguating context for later resolution. |
| `party_locality` | string, nullable | City or town as the worker gives it. Same purpose. |
| `relationship_kind` | enum | `employment \| engagement \| platform \| agency \| self_employed` |
| `started_on` · `ended_on` | month precision | **Month, never day.** Day precision is more identifying, invites exact-gap inference, and is not needed by any surface. `ended_on` null while ongoing. |
| `ended_reason` | enum, optional | `relationship_ended \| party_declared_dormant`. Never a reason for leaving — that is a performance claim wearing a metadata costume. |
| `positions[]` | array of `position` | §3 |
| `work_kind` · `work_kind_version` | `term@version` | The ledger's own vocabulary, bound immutably (interface A-1, R-1). Crosswalks to O\*NET/ISCO/ESCO are published; the crosswalk is not the binding. |
| `volume` | `{unit, count}`, optional | units completed across the chapter |
| `provenance` | enum | `self_asserted \| peer_attested \| party_attested`. Derived from the strongest attestation attached; `self_asserted` when none. |
| `corroboration` | enum | `none \| single \| multi`. Count of distinct attesting parties, coarsened. Never a number on any surface. |
| `attestation_refs[]` | ids | attestations scoped to this chapter |
| `disputed` | bool | true while any unresolved dispute references this chapter |
| `origin` | enum | `worker_created \| resume_parsed \| ingested`. `resume_parsed` requires worker confirmation before commit. |
| `superseded_by` | chapter id, optional | corrections are new chapters, never edits |

**Not present, deliberately.** No job title as a first-class comparable field —
titles are administrative acts and `THESIS.md` rejects them as a progression
signal; the title lives on `position` as an asserted string for human reading
only. No salary. No reason-for-leaving. No manager name. No performance free text.

## 3. `position` — a promotion or role change inside a chapter

| Field | Type | Notes |
|---|---|---|
| `position_id` | opaque id | |
| `title_asserted` | string | display only, never compared across parties |
| `started_on` · `ended_on` | month precision | must fall inside the chapter's bounds |
| `is_current` | bool | |

Renders as a hairline division within the band, spaced tighter than the gap
between chapters (decision 028).

## 4. `chapter_standing` — derived, never asserted

Per chapter, per dimension. The ledger computes this; no party writes it.

| Field | Type | Notes |
|---|---|---|
| `dimension` | enum of 7 | fixed slot order — the angular registration of the imprint depends on it never changing |
| `level_entry` · `level_exit` | 0–6 | 0 means *not exercised* and is a legitimate, non-pejorative score |
| `corroboration` | `single \| multi` | per dimension, not per chapter |
| `as_of` | date | |
| `supporting_attestation_refs[]` | ids | |

**Derivation rule.** The drawn level is the **exit** level. Where attesting parties
disagree, the level is the highest at which at least two parties agree; a lone
attester's claim stands at their level but carries `single`. **Disagreeing
attesters are never averaged** — averaging invents a level nobody asserted.

`level_entry` exists so slope is computable in the analytics layer. **It is not
drawn in the imprint** (`imprint/README.md` §2).

## 5. `grant` — the unit of consent

| Field | Type | Notes |
|---|---|---|
| `grant_id` | opaque id | |
| `subject_id` · `grantee_party_ref` | | |
| `scope` | enum | `read_record \| write_attestation \| both` |
| ~~`chapters`~~ | — | **Deleted, decision 029 §B3.** A grant is always the whole record. A chapter-scoped grant is claim curation wearing a grant's clothes and silently reverses founder decision 7 (`design/ledger-design-0.1.md` §7.1). |
| `granted_at` · `expires_at` | | **expiry is mandatory**; a grant with no end is a permanent disclosure the worker forgets making |
| `revoked_at` | nullable | |
| `last_read_at` | nullable | **Not surfaced to the worker, decision 029 §B4.** The worker sees the grant's *state* — issued, active, expired, revoked — and no read events. The field is retained for the disclosure record that satisfies GDPR Art. 15(1)(c) on request. |

**Share links** are grants with no `grantee_party_ref`, a 30-day default expiry,
and a statement at creation of what the recipient receives — full work-history
detail, and the ability to ask Grain to analyse it (decision 029). It is written
as what the recipient gets, not as a warning. **The public URL is not a grant** — it is a separate
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
payload shape** — they model an issuer *conferring an achievement*, which is the
credential logic the thesis attacks.

---

## 8. Open

0. **Employer normalization at scale.** `party_country` and `party_locality`
   exist because most chapters in the target population name businesses that never
   register, in many scripts and many spellings of one employer, and **context you
   do not collect at entry cannot be backfilled**. Resolving those strings into
   canonical employers is a real problem and is deliberately *not* modelled here:
   its first genuine consumer is cross-worker aggregation in `analytics`, and
   nothing in `v1` or `first-product` needs it (decision 034 §E, corrected). When
   it is built, two rules already stated above govern it — the raw string is never
   mutated, and clustering proposes but never asserts — and the operating threshold
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
   says suspension is never retroactive and produces a read-time flag — so
   probably no, but the chapter surface has to render that flag.
5. ~~**Public-URL projection.**~~ **Closed by decision 029.** Whole record or no
   record; no per-chapter curation on any surface. The single lever is the
   imprint, full or absent. Always indexed, with a reduced page for crawlers and
   logged-out visitors, and the imprint always behind sign-in. Field list in
   `design/06-worker-app-ia.md` §5–6.
