# Counsel engagement brief 1: data residency and erasure architecture opinion

**Jurisdictions:** United States, European Union, Philippines, India
**Horizon:** 12 months forward-looking (with a 24-month probability assessment on one question)
**Date prepared:** 2026-08-17
**Status of this document:** Instructions to counsel. Internal research memos are cited throughout; they are not legal advice and have not been counsel-reviewed. Source URLs are provided so every proposition can be independently checked.

---

## 1. Background: what the company and product are

The company operates a **persistent worker identity and work-attestation ledger**: a platform on which a worker holds a permanent identity (`ledger_person_id`, an opaque surrogate issued at self-signup) and accumulates **signed attestations** about work performed, such as employment engagements, training completions, credentials, and verified skills, issued by registered "attesting parties" (initially the company's own operating verticals; later external partner companies such as a datacenter operator whose technicians are trained and supplied through the platform). Attestations are cryptographically signed (Ed25519/JWS) by the issuing party and carry an explicit provenance grade: self-asserted, peer-attested, or party-attested. Workers grant and revoke read access to their record at the party level; permitted readers receive a generated-at-read "prior packet." The initial markets are the US and the Philippines (large ops/BPO workforce), with the EU and India on the roadmap.

Two founder rulings shape the legal posture and are fixed inputs, not open questions:

- **R1: worker-owned platform model.** The worker owns the record; the product is positioned as the worker's portable verified resume and identity platform (LinkedIn-style worker-published-profile theory), *not* as a consumer reporting agency. Internal research reaching the contrary FCRA conclusion is on record as a counsel agenda item (it is the subject of a separate brief, No. 4), but it does not govern design.
- **R2: whole-profile deletion, never record-editing.** A worker may delete their entire profile at any time (a first-class operation), but cannot edit individual verified records while the profile exists. Whole-profile erasure is the designed answer to most jurisdictional-erasure exposure.

**The architecture this opinion must evaluate.** The system is split into two planes (ratified engineering rulings, 2026-08-17):

1. **A global, append-only "integrity spine"**, a single worldwide dataset containing *no readable personal data*: object IDs, object types, opaque subject/issuer references (the surrogate `ledger_person_id`), **salted cryptographic commitments** of attestation payloads (HMAC over the canonical payload with a per-record random key held only in the erasable plane, never bare hashes), signature hashes, timestamps, and supersession pointers. The spine is append-only at the database-privilege level and is replicated globally. Merkle checkpoints over it are anchored to write-once storage every ≤5 minutes.
2. **Regional, erasable "payload stores"**: the actual claim content and all PII, partitioned by `residency_region` on every row, with per-person envelope encryption. Erasure = an orchestrated deletion saga across the payload plane plus crypto-shredding of the per-person keys and the per-record commitment salts, leaving the spine's retained commitments unlinkable.

On R2 profile deletion: reads stop immediately, the payload plane for the person is purged within a fixed published window, and the spine retains only the tombstoned ID, commitments (now salt-destroyed), issuer references, and timestamps.

Our working legal position, which this engagement tests: **the spine is treated as personal data** (pseudonymized, not anonymized, while the person exists) and is **replicated globally under Standard Contractual Clauses** plus, for EU→US, the EU-US Data Privacy Framework as a parallel mechanism; the payload plane satisfies residency and erasure obligations regionally.

## 2. Questions presented

1. **Spine defensibility.** Is the global replication of the pseudonymized integrity spine defensible in each of the four jurisdictions over the next 12 months, on the working assumption that spine rows are personal data of the worker while the profile exists? Specifically: (a) EU: SCCs (Modules 1/2 as applicable) plus DPF-in-parallel given the pending CJEU appeal in *Latombe* (C-703/25 P); (b) Philippines: Sec. 21/IRR Sec. 50 contractual accountability; (c) India: under the DPDP Act 2023 and DPDP Rules 2025 as in force; (d) US: any state-law constraint we have missed.
2. **Post-deletion status of retained commitments.** After R2 deletion (payload purged, per-person keys and per-record salts destroyed), are the retained salted commitments on the spine still "personal data" in each jurisdiction, such that erasure obligations continue to attach to them? Our working analysis says destruction of the salt renders the commitment an unlinkable random value; EDPB Guidelines 02/2025 treat hashed data as personal where re-identification is reasonably likely. (This question is examined in cryptographic detail in Brief 2; here we need the *residency* consequence: if the answer is "still personal data," does the spine's global replication of post-deletion tombstones become a transfer problem?)
3. **Erasure sufficiency of the R2 design.** Does whole-profile deletion as designed (immediate read cutoff, payload purge within a published window, crypto-shred, retained unlinkable commitments, no recall of already-delivered prior packets) discharge: (a) GDPR Art. 17 where a trigger fires; (b) PH DPA Sec. 16(e) "blocking, removal or destruction"; (c) India DPDP Sec. 12 erasure? Which jurisdiction, if any, requires more than this?
4. **Selective erasure vs. append-only.** PH IRR Sec. 34(e)(e) creates an erasure trigger for "private information that is prejudicial to the data subject", which describes an adverse work attestation almost exactly. R2 offers whole-profile deletion but deliberately not per-record deletion. (a) Can a Philippine worker compel erasure or blocking of a *single* adverse attestation while keeping the rest of the profile? (b) Is read-suppression ("blocking" under Sec. 16(e)) a sufficient remedy short of destruction, so the spine entry and a suppressed payload may be retained? (c) Same question under GDPR Art. 17(1)(c) following an Art. 21 objection to one attestation: can we lawfully answer "your remedies are dispute, counter-statement, or whole-profile deletion, not line-item erasure"?
5. **India DPDP exposure.** (a) Does the DPDP Act's extraterritorial provision reach the platform before it has any India entity, if it processes data of workers in India in connection with offering them the service? (b) What is the current state of transfer restriction under DPDP Sec. 16 / Rule 12 (negative-list / government-designated-country mechanism), and does anything in force or reasonably foreseeable within 24 months restrict replicating the spine or storing India payloads outside India? (c) Does the DPDP Rules 2025 Consent Manager regime (India-incorporated entity, ₹2 crore net worth, Data Protection Board registration as specified in Schedule I-A, https://www.dpdpa.in/dpdpa_rules_2025/schedule1-A.htm) capture an attestation platform that brokers worker-consented disclosures between parties in India, and if so at what activity threshold?
6. **The switch-trigger probability assessment (the deliverable with an engineering consequence).** For each of the four jurisdictions: what is counsel's written probability assessment that, within 24 months, that jurisdiction will require **in-territory primary storage of spine-class data** (pseudonymized, no readable PII, deliberately minimized), or mandate **synchronous atomic cross-plane erasure**? Regional payload mandates do not matter for this question. Regional payload databases are already the design. This assessment is a ratified, contractual switch-trigger: if counsel assesses in-territory spine primaries as probable in ≥1 roadmap jurisdiction within 24 months, the company migrates its system of record from managed PostgreSQL to a geo-partitioned distributed SQL engine. Precision matters; "possible" and "probable" have different million-dollar consequences.
7. **PH-specific structuring items** carried from our research: (a) can a foreign entity with no Philippine office register a data processing system and DPO under NPC Circular 2022-04, and must the DPO be Philippine-resident; (b) how does the NPC compute the "annual gross income" administrative-fine base (Circular 2022-01) for a foreign controller, using global or Philippine income?

## 3. Relevant facts and our current working analysis

Counsel should treat everything below as our position to be confirmed or corrected, with confidence as marked in the underlying memos.

**EU.** The EDPB's Guidelines 02/2025 on blockchain (v2.0 adopted 7 July 2026) recommend exactly our pattern of personal data off the immutable structure, with only commitments on it, while stating that encrypted and hashed data remain personal data where re-identification is reasonably likely (https://www.edpb.europa.eu/system/files/2025-04/edpb_guidelines_202502_blockchain_en.pdf; practitioner summary: https://www.twobirds.com/en/insights/2026/netherlands/edpb-adopts-final-guidelines-on-blockchain-and-personal-data-a-practical-guide-for-organisations). *EDPS v. SRB* (C-413/23 P, 4 Sept 2025) endorsed a recipient-relative test for pseudonymized data (https://www.cliffordchance.com/insights/resources/blogs/talking-tech/en/articles/2025/09/pseudonymized-data-after-edps-v-srb.html), which we read as supportive of the spine being non-personal in the hands of infrastructure recipients who cannot re-identify. EU→US transfer rests on the DPF (Decision 2023/1795), which survived *Latombe* at the General Court (T-553/23, 3 Sept 2025) but is on appeal (C-703/25 P, pending; https://globaldatashield.com/blog/eu-us-data-privacy-framework-2026); our design principle is that no architecture may depend solely on an adequacy decision under active appeal, hence SCCs papered in parallel (Decision 2021/914) with transfer impact assessments. EU→Philippines has no adequacy path at all; remote read access by PH-based operations staff is itself a transfer requiring SCCs plus TIA. Our research concluded a single physical global ledger of *readable* personal data is foreclosed and regional partition is effectively forced (internal memo `research/01-regulatory-perimeter.md` §4, TLDR-11). The spine is the deliberate, minimized exception whose defensibility we are asking you to assess.

**Philippines.** IRR Sec. 4 makes "relates to personal data about a Philippine citizen or resident" a stand-alone jurisdictional hook (Act: https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html; IRR: https://www.officialgazette.gov.ph/2016/08/25/implementing-rules-and-regulations-of-republic-act-no-10173/). There is no adequacy regime, transfer permit, or mandatory clause set. NPC Advisories 2021-02 and 2024-01 confirm ASEAN MCCs and EU SCCs are voluntary (https://privacy.gov.ph/wp-content/uploads/2024/06/Published-NPC-Advisory-No.-2024-01-Contractual-Clauses-for-Cross-Border-Transfers_30May24.pdf); what is owed is Sec. 21/IRR Sec. 50 contractual accountability, so US hosting of PH payloads is lawful on contract alone. The sharp edge is erasure: Sec. 16(e) grants blocking/removal/destruction on substantial proof of enumerated defects, but IRR Sec. 34(e) adds triggers with no statutory GDPR equivalent, namely 34(e)(d) consent-withdrawal reach-back and 34(e)(e) "private information prejudicial to the data subject." Note that the statute lists **blocking** as an alternative remedy to destruction, which is our textual hook for read-suppression short of deletion. Criminal liability runs to responsible officers personally (Secs. 25–35), and Sec. 35 escalates to maximum penalties above 100 affected data subjects. NPC enforcement against foreign identity platforms is live: the October 2025 Cease and Desist Order against Tools for Humanity / World App (https://privacy.gov.ph/npc-issues-cease-and-desist-order-against-tools-for-humanity/).

**India.** Our research on DPDP is the thinnest of the four jurisdictions and rests partly on commentary rather than direct statutory pulls (flagged in `research/08-kyc-regulatory-triggers.md`): DPDP Act 2023 treats employment-purpose processing as a ground independent of consent (favorable, unverified against primary text); DPDP Rules 2025 were notified 13 Nov 2025; Rule 12-class transfer restriction is a discretionary designation mechanism that is observable before it binds; the Consent Manager regime is the closest analogue to an attestation broker. We are asking counsel to do the primary-source work here, not to check ours.

**US.** No federal residency mandate is known to us for this data class. State-law overlays flagged but not researched for residency purposes: California ICRAA/CCPA, Oregon SB 619 and Delaware's act treating immigration/citizenship status as sensitive data. The FCRA/CRA classification question is deliberately excluded here (Brief 4).

**Engineering context for Question 6.** The ratified D1 ruling (`design/stack-litigation/d1-verdict.md` §3.3, §5) prices the residency-forcing scenario as the strongest surviving argument for distributed SQL and converts it into a trigger: counsel's written assessment that in-territory spine primary storage is *probable on a 24-month roadmap* fires the migration. The design intuition, for what it is worth: the spine is pseudonymous, unreadable, and deliberately minimized, which makes it the hardest data class to justify localizing, and Schrems-III-style developments would pressure the transfer basis rather than mandate in-territory primaries. Counsel should confirm or demolish that intuition per jurisdiction.

## 4. What the answer will drive, and when it is needed

- **Question 6 drives a ratified database-architecture switch-trigger** (PostgreSQL vs. geo-partitioned distributed SQL). The founder has already committed to commissioning this opinion for US + EU + PH + India (`design/stack-litigation/docket-rulings-0.1.md`, founder-call 3). Needed: **within one quarter**, refreshed annually.
- Questions 1–3 gate the **launch posture** in each jurisdiction and the drafting of partner data-transfer paper (SCC automation at partner onboarding). Needed **before EU or India data subjects are onboarded**; the US/PH answers are needed **before launch**.
- Question 4 determines whether the R2 "whole-profile-or-nothing" deletion model survives PH and EU contact, or whether a per-record blocking/suppression remedy must be built. A suppression state is cheap to add now and expensive to retrofit. Needed **before launch in the Philippines**.
- Question 7 gates PH registration mechanics and entity structuring. Needed **before the first Philippine worker signs up**.

## 5. What we are explicitly not asking

- **Not** whether the product is a US consumer reporting agency, or any FCRA/ICRAA question. See Brief 4.
- **Not** the anonymization status of salted commitments as a cryptographic/legal matter in depth. See Brief 2 (Question 2 here asks only the residency consequence of Brief 2's answer).
- **Not** attester liability, defamation, or the liability-shield contract structure. See Brief 3.
- **Not** worker-agreement drafting or consent-instrument design. See Brief 4.
- **Not** KYC/AML, sanctions, or right-to-work perimeter questions (researched separately; no counsel engagement yet).
- **Not** an opinion on GDPR Art. 22 / automated-decision exposure of derived scores (flagged internally; will be scoped separately).

## Internal research corpus available to counsel on request

`research/01-regulatory-perimeter.md` (FCRA/GDPR/PH DPA perimeter, with full source list), `research/07-synthesis.md`, `research/08-kyc-regulatory-triggers.md` (India DPDP notes), `design/ledger-design-0.1.md` (architecture), `design/stack-litigation/d1-verdict.md` and `docket-rulings-0.1.md` (ratified rulings and trigger definitions).


---

## Addendum (2026-08-17): post-erasure retention and retention *obligations*

Added after `research/12`. Three questions supplement those above.

**Q-A1. Post-erasure safety markers.** We propose retaining, after a
worker deletes their profile, a single severity-gated marker: a hash of a
verified document identifier, a closed-enum safety/fraud category, filing
party, filing date, fixed expiry, and challenge state, with no payload
and no narrative. Filed only by the party that made the finding, on attestation
that it "could confidently report to the police." On a re-registration
match it triggers human review, never automatic denial. Is this
defensible under GDPR Art. 17(1) necessity (noting Art. 17(3) contains no
fraud exemption and Recital 47 is a legal-basis statement only), CCPA
§1798.105(d)(2), PH NPC Advisory 2021-01 §10(B)(2), and India DPDP
§17(1)(a)/(c)? Specifically: (i) does joint controllership with the
filing party improve or worsen our position; (ii) does the AEPD Goldcar
decision (€80,000; flag "does not refer with certainty to a fraud
committed by the claimant") distinguish our evidential floor; (iii) does
CNIL's exclusion of *mutualised* registers bar a cross-party marker
outright, and if so does joint controllership or a Cifas-style structure
cure it; (iv) what maximum expiry is defensible per jurisdiction.

**Q-A2. Retention obligations in tension with the deletion right.**
Seattle's app-based worker deactivation ordinance and India DPDP Rule
8(3) appear to *require* retention of records our product promises to
erase. Enumerate, for our target jurisdictions, every regime that
mandates retention of worker records, for how long, and how that
reconciles with a product commitment to whole-profile deletion. This must
resolve before the worker agreement is finalised. The agreement cannot
promise unconditional erasure if law forbids it.

**Q-A3. Blacklist characterisation risk.** Independent of data-protection
compliance: does a cross-employer worker record carrying any exclusion or
safety marker risk characterisation as an unlawful blacklist under UK,
EU, US, or PH law (cf. the UK Consulting Association enforcement)? What
structural features most reduce that risk?
