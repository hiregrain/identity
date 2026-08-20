# Person-ID issuance, deduplication, and merge under append-only rules

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Status:** Research memo, not a design doc. Confidence levels stated per claim.
**Scope:** How to issue a stable `ledger_person_id` at global self-signup, detect/merge duplicates without breaking append-only history, and grade phone/email as identity anchors.

---

## TLDR (conclusions first)

1. **Issue an opaque surrogate `ledger_person_id` at signup, immediately, decoupled from any single verification credential.** Every system reviewed here, namely Aadhaar, UNHCR PRIMES/BIMS, healthcare MPIs, and credit bureaus, separates *enrollment* (an ID gets created) from *proofing* (evidence about who holds it accumulates over time). None of them wait for high-assurance proof before issuing an identifier; they issue first and raise confidence later. This matches NIST 800-63-4's move toward modular, incremental Identity Assurance Levels (IAL). **High confidence** this is the right default shape.

2. **Merges must never edit or delete history. They must be a new event that references both prior IDs, with a durable alias/tombstone table.** This is well-established in event-sourced systems generally and is exactly how healthcare MPIs implement merge/unmerge (both directions are logged, reversible, auditable). Applying this to a "corrections supersede" ledger is a natural extension, not a novel idea. **High confidence.**

3. **No credible large-scale system merges on a single weak anchor.** Aadhaar merges/dedupes on biometrics compared against the *entire* enrolled population (1.4B), not on phone/email/name. Credit bureaus, which historically merged on partial-match demographic/SSN heuristics, are the industry's cautionary tale: "mixed files" are a well-documented, litigated, ongoing harm (FCRA suits are routine). Healthcare MPIs use weighted probabilistic matching (Fellegi-Sunter) across many fields, not one. **High confidence** that single-anchor matching (e.g., phone-only) is undersized for a global, high-stakes ledger.

4. **Phone-number-as-verified-anchor is a reasonable low-assurance signal but a poor sole basis for merge/dedup at global scale**, because phone numbers are recycled (45–90 day reassignment windows in the US; shorter/less-regulated in many emerging markets), subject to SIM swap (FBI IC3: ~$26M in reported 2024 US losses; UK SIM-swap incidents +1,055% in 2024; ~80% first-try success rate against major US carriers per a 2020 Princeton study), and commonly shared within families in parts of the Global South. It is fine as a *contact channel* and a *weak proofing signal*; it is risky as the join key for "same person." **Medium-high confidence.** The phone-specific fraud stats are well sourced; the "shared family phones in PH/global south" claim is directionally well-known but I could not find a rigorous quantitative source for it (flagged below).

5. **"Fresh start" / ban-evasion is a live, currently-unsolved-at-scale adversarial pattern in every system that allows self-signup**, from credit-repair "file segregation"/CPN fraud (illegal but persistent) to gig-platform multi-accounting after a ban (Uber and others now fight this with device fingerprints, biometric face-search 1:N, and document-reuse detection, not identity-number reissuance). The tension with "universal self-signup, worldwide, low friction" is structural, not an implementation bug. It can be mitigated but not eliminated at the ID-issuance layer alone. **Medium confidence**; gig-platform sourcing is solid, but effectiveness data on countermeasures is vendor-marketing-adjacent and should be treated skeptically.

6. **Recommended shape stated as 8 constraints** (see Section 5). Headline: opaque surrogate ID issued at signup; progressive/tiered assurance levels tracked per attestation, not per person; multi-factor probabilistic merge (never single-anchor); merge-as-event with tombstone + alias table, reversible; phone/email treated as low-assurance contact anchors, not identity anchors; explicit adversarial-abuse monitoring layered on top of (not instead of) the ID scheme.

---

## 1. ID scheme design: surrogate vs. derived, issuance timing

**Surrogate (opaque) IDs vs. derived IDs.** A derived ID (e.g., a hash or encoding of name+DOB+document number) is tempting because it's self-verifying and requires no lookup table, but it bakes PII-derived structure into a supposedly stable identifier, breaks the moment underlying data corrects (name changes, DOB corrections, document reissuance), and is deanonymizable/enumerable if the derivation is guessable. The near-universal recommendation across database design literature is: surrogate key as the actual join key, natural/derived attributes stored as separate, updatable, queryable fields with unique constraints where warranted (source: surrogate-key design literature, ScienceDirect/Matillion/Harbinger). This maps directly onto the append-only requirement: the `ledger_person_id` should carry zero embedded meaning, so nothing about a person's identity ever forces the ID itself to change.

**Issuance timing: enroll first, prove progressively.** Every large-scale system I could find issues an identifier *before* full verification and layers proofing on afterward:

- **NIST SP 800-63-4** (finalized July 2025) formalizes this as modular Identity Assurance Levels (IAL1 = self-asserted, IAL2/IAL3 = evidence-backed, now including mobile driver's licenses and verifiable credentials as valid evidence types), explicitly separating identity proofing strength from the existence of the identity record itself. [NIST SP 800-63-4](https://pages.nist.gov/800-63-4/sp800-63.html)
- **Aadhaar**: enrollment happens on collection of demographic + biometric data; a 12-digit number is issued once the enrollee clears deduplication against the *entire* Central Identities Data Repository (CIDR), not before. Verification/authentication strength is a separate, later layer (banks, subsidies, etc. each set their own reliance level). [Privacy International case study](https://privacyinternational.org/case-study/4698/id-systems-analysed-aadhaar); [UIDAI dedup platform](https://idtechwire.com/indias-uidai-deploys-ai-powered-invisible-shield-for-aadhaar-biometric-deduplication/)
- **UNHCR PRIMES/BIMS**: a unique biometric identifying number is assigned at first registration and is designed to persist "across operations," meaning it precedes and outlives any single verification event, and is explicitly built to survive undocumented, low-trust enrollment conditions (refugees frequently lack any government-issued document at all). [UNHCR PRIMES blog](https://www.unhcr.org/blogs/modernizing-registration-identity-management-unhcr/); [UNHCR registration guidance](https://www.unhcr.org/registration-guidance/chapter5/registration/)
- **World Bank ID4D Principles on Identification for Sustainable Development** frame the goal as a "trusted — unique, secure, and accurate" identity on an "interoperable platform" from inception, not as a single verification event. [ID4D Principles](https://www.id4africa.com/2019/almanac/The-World-Bank-ID4D.pdf)

**Implication for this ledger:** the `ledger_person_id` should be generated at self-signup with essentially no proofing gate (maximizes universal access), and every subsequent verification (phone-control, email-control, document scan, biometric, third-party issuer attestation) should be stored as a dated, issuer-attributed, leveled attestation *against* that ID, never as a precondition for the ID's existence. This is consistent with the "record stores attestations with issuer + level" design already stated in the task brief.

**Confidence:** High on the general pattern (enroll-then-progressively-prove is consistent across every system surveyed). Medium on specifics of exactly which NIST IAL boundaries to adopt: 800-63-4 is new (July 2025) and third-party commentary on it is still catching up, so treat IAL mappings as directional, not final.

---

## 2. Duplicate detection and merge

**Credit bureaus: the cautionary tale.** Bureaus historically matched consumers on partial fields (sometimes as few as 7 of 9 SSN digits, similar names, shared addresses, e.g., Sr./Jr. or family members at one address). The result is "mixed files": one consumer's report gets contaminated with another's tradelines. This is not a hypothetical edge case. It is common enough to sustain a specialized plaintiff's bar under FCRA, with routine litigation over wrongful credit denials caused by mixed files. [Mixed file overview](https://newyorkcreditlawyers.com/mixed-files-and-merged-files-common-credit-report-problems/); [FCRA mixed-file litigation](https://clalegal.com/mixed-credit-files-when-someone-elses-information-gets-on-your-credit-report/). **Lesson:** weak-field matching at scale produces a persistent, hard-to-reverse harm class; any merge logic for this ledger needs materially stronger matching discipline than legacy bureau practice, precisely because merge errors compound (a wrongful merge in a *work ledger* could contaminate someone's employment/performance history the same way a mixed credit file contaminates a credit history).

**Healthcare MPIs: probabilistic matching + reversible merge as the mature pattern.** Master Patient Index systems use probabilistic (not deterministic) matching, most commonly grounded in the **Fellegi-Sunter model** (1969, still the dominant framework): each field (name, DOB, address, etc.) gets a statistical weight based on how informative agreement/disagreement on that field actually is (agreeing on a rare surname is much stronger evidence than agreeing on "John"). Candidate duplicates are scored, reviewed (often by a human "data steward"), and then explicitly **merged** into one profile, with systems logging merge events and supporting **unmerge** when a merge turns out to be wrong. [Fellegi-Sunter overview](https://tomhepworth.dev/posts/record-linkage/deterministic-vs-probabilistic-linkage/); [MPI merge/unmerge](https://www.health-samurai.io/mdmbox). Duplicate rates in production healthcare systems are non-trivial even with these controls: one survey found all respondents had duplicates, and 61% estimated up to 10% of records were duplicates, mostly from data-entry error rather than adversarial behavior. [ONC/AHIMA patient matching report](https://www.healthit.gov/sites/default/files/resources/patient_identification_matching_final_report.pdf); [Patient matching errors study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8823399/).

**What merge should look like under append-only rules.** The general event-sourcing/DDD answer (well-established practitioner consensus, though I did not find one canonical named pattern with the exact phrase "tombstone + alias table") is:

- A merge is **never** an in-place edit of either person's history.
- A merge is itself a new, immutable event: `PersonMerged(survivor_id, absorbed_id, evidence, actor, timestamp)`.
- The absorbed ID is **tombstoned**, not deleted. It still resolves, but resolves *through* an alias table to the survivor ID, so every historical reference (evidence, attestations, work records) keeps working without rewriting.
- Because the absorbed ID's original event stream is untouched, a wrong merge can be reversed by writing a corresponding `PersonUnmerged` event and updating the alias table's live pointer, matching exactly how mature MPIs implement unmerge.
- This composes cleanly with the ledger's stated "corrections supersede rather than edit" philosophy: a merge/unmerge is just another correction event, scoped to identity rather than to a single fact.

**Confidence:** High on the MPI probabilistic-matching-plus-reversible-merge pattern (directly documented, mature, decades of production use). Medium-high on "merge is a new event referencing both IDs, tombstone + alias table" as the right event-sourcing implementation. This is standard practitioner knowledge in the identity/CDM space but I did not find one single canonical primary source using this exact vocabulary; treat it as synthesized best practice rather than a citation-backed named pattern.

---

## 3. Phone/email as anchors

**Strengths.** Phone-control verification (proving you can receive an OTP at a number) is cheap, near-universal in reach (higher penetration than bank accounts or government ID in many emerging markets), and gives a real-time, low-friction signal that *someone* controls that channel right now. It's a reasonable low-assurance building block, comparable to NIST IAL1/AAL1-adjacent signal strength, not identity proof.

**Failure modes, with evidence:**

- **Recycled numbers.** US carriers reassign numbers after a 45–90 day cooling-off period; a new owner inherits SMS/2FA access tied to the prior owner's accounts unless every service is proactively updated. This is a "growing fraud trend" specifically because most platforms verify a phone once at onboarding and never re-check ownership. [Telesign](https://www.telesign.com/blog/number-deactivation-and-the-recycled-phone-number-dilemma); [Prove](https://www.prove.com/blog/recycled-phone-numbers). Emerging-market carriers often have shorter or less consistently enforced cooling-off windows. While I could not find hard cross-country statistics, this plausibly makes the risk worse, not better, at global scale. *(Flag: directional inference, not directly sourced.)*
- **SIM swap.** FBI IC3 recorded 982 US complaints / ~$26M in losses in 2024; UK SIM-swap cases rose >1,000% in 2024 (Cifas Fraudscape); a 2020 Princeton study found an 80% first-attempt success rate against major US carriers' identity-verification defenses. [DeepStrike stats](https://deepstrike.io/blog/sim-swap-scam-statistics-2025); [Efani stats](https://www.efani.com/blog/sim-swap-fraud-statistics-2026). This directly undermines "phone-control-verified" as a durable anchor: control can transfer to an attacker without the legitimate holder losing physical possession of their SIM.
- **Shared family phones.** Widely understood as common practice in parts of the Global South (one phone per household, shared across multiple adult family members). This is well-known anecdotally and shows up in identity-verification vendor commentary about the Philippines specifically, but I was **not able to find a rigorous quantitative source** for prevalence. This should be treated as a plausible, high-relevance risk to flag for product design (a shared-phone household could plausibly cause multiple `ledger_person_id`s to share one phone-control attestation, or one person's phone-control attestation to be wrongly used to authenticate a family member), not as an established statistic. **Low-medium confidence**, explicitly flagged.

**Assessment of "phone-control-verified" as the anchor a worker ADR reportedly uses.** I could not locate an ADR file in this repository (only `README.md` exists under the project root as of this research). I'm relying on the task description's characterization of it, not a document I read. Given that caveat: phone-control verification is a reasonable **default low-assurance attestation** to require at signup, since it's cheap and globally available, but the evidence above says it should **not** be the sole or primary signal used for (a) merge/dedup decisions or (b) any high-stakes downstream reliance (e.g., "this person has a clean work record"). It should be one weighted field among several in a probabilistic match, exactly as MPIs treat any single demographic field, and it should be periodically re-attestable rather than treated as a permanent fact, given recycling and SIM-swap risk. Email-control has weaker failure-mode data available but shares the core issue: control of a channel is not proof of a stable, singular identity behind it, and email addresses can also be recycled or shared (less commonly than phones, but the same structural weakness applies).

**Confidence:** High on the phone recycling and SIM-swap risk data (well-sourced, quantified). Low-medium on the shared-family-phone claim specifically (plausible, directionally supported, not rigorously quantified in what I found). Explicitly noting I have not read the internal ADR directly. This assessment is against the *concept* of phone-control-as-anchor described in the task, not a verified reading of the actual document.

---

## 4. The adversarial side: "fresh start" attacks

**Pattern, cross-domain:**

- **Credit domain (illegal but persistent):** "File segregation" / Credit Privacy Number (CPN) schemes explicitly market "fresh start, new profile, new number, escape your bad credit history." CPNs have no legal basis: sellers either fabricate a number resembling an SSN or (worse) sell a stolen SSN belonging to someone with a clean file (frequently a minor or elderly person), and using one is a federal crime. This persists as an active scam despite illegality, which is itself evidence that "prevent people from re-identifying to escape a bad record" is hard to fully close off even under criminal deterrence. [Forbes on CPN-driven synthetic identity boom](https://www.forbes.com/sites/frankmckenna/2024/10/24/this-9-digit-scam-sparked-a-synthetic-identity-boom-in-the-us/); [Get Out of Debt on CPN fraud](https://getoutofdebt.org/259310/they-said-you-can-legally-buy-a-cpn-for-a-fresh-credit-file-its-a-federal-crime/).
- **Gig platforms (directly analogous to a "work ledger"):** banned drivers/couriers routinely re-register under new accounts once deactivated; this is described as "central to how large-scale abuse operates" in the space. Uber's public response is to detect signup attempts that reuse **documents, photos, or device/behavioral signals** tied to a previously deactivated account. That is, they don't rely on the identity number at all: they cross-check the *evidence* submitted at signup against evidence tied to bans. [Uber newsroom](https://www.uber.com/us/en/newsroom/courier-identity-us/); [Incognia gig fraud report](https://www.incognia.com/frontline-report-gig-economy-edition). Industry response also increasingly uses biometric face-search (1:N) across the whole user base at signup, plus device fingerprinting, specifically because document/identity-number-based checks alone are evadable. [Verosint on gig account fraud](https://verosint.com/post/account-fraud-in-the-gig-economy).

**The structural tension.** Universal, low-friction, worldwide self-signup is explicitly the goal of this ledger, and it is also exactly the condition that makes fresh-start attacks cheap. Every system that has solved this reasonably well (Aadhaar's biometric dedup against the full national population; Uber's cross-signal detection at signup) does so by adding a **second, independent detection layer that runs *at or after* signup**, not by making signup itself harder. That is, the ID-issuance layer stays permissive; a separate ongoing fraud/dedup layer (biometric 1:N search, device fingerprinting, document-reuse detection, behavioral signals) does the work of catching people who re-enroll to escape a bad record. Trying to solve this purely at the ID-scheme level (e.g., by making signup require heavy proofing) would defeat the "universal self-signup" goal and is not how any surveyed system actually does it.

**Confidence:** Medium. The credit-domain and gig-platform patterns are well documented qualitatively. Quantitative effectiveness of countermeasures (e.g., "how often does Uber's document-reuse detection actually catch ban evasion") is not publicly available in rigorous form. Most sourcing here is vendor blog / company PR, which has an incentive to overstate efficacy. Treat "these countermeasures exist and are the industry's chosen approach" as solid; treat "these countermeasures work well" as unverified.

---

## 5. Recommended shape: design constraints (not a full design)

Each stated as a constraint, with its evidence source.

1. **Issue `ledger_person_id` as an opaque, meaningless surrogate at self-signup, with no proofing gate.** *Evidence: universal pattern across Aadhaar, UNHCR PRIMES, NIST 800-63-4's modular IAL model, and standard surrogate-key design practice (Section 1).*

2. **Track assurance/attestation level per-attestation, not per-person.** A person's overall "trust" should be derivable from the set of attestations attached to their ID (issuer, method, date, IAL-equivalent level), never baked into the ID itself. *Evidence: NIST 800-63-4 modular IAL design; matches the task's own "record stores attestations with issuer + level" premise.*

3. **Never merge/dedup on a single field, and never on phone or email alone.** Require a weighted, multi-field probabilistic match (name variants, DOB, document numbers where available, phone, email, device/biometric signals where available) before treating two IDs as candidates for merge, and require human/steward review before executing a merge that affects a live work history. *Evidence: credit-bureau mixed-file harm (weak-field matching failure mode); healthcare MPI Fellegi-Sunter practice; Aadhaar's whole-population biometric dedup rather than field-matching.*

4. **Model merge as a new event, not an edit, with a permanent alias/tombstone table and a supported unmerge path.** *Evidence: healthcare MPI merge/unmerge practice; matches the ledger's own "corrections supersede rather than edit" principle extended to identity itself.*

5. **Treat phone and email as re-attestable contact/proofing signals with a decay/re-verification policy, not permanent facts.** Given recycling and SIM-swap risk, a phone-control attestation from 18 months ago should not carry the same weight as one from today; consider periodic re-attestation or at least timestamping attestation "freshness" into merge-confidence scoring. *Evidence: recycled-number fraud data, SIM-swap statistics (Section 3).*

6. **Separate the ID-issuance layer (stays permissive, low-friction) from an independent, ongoing anti-fraud/dedup layer (biometric or device-based 1:N checks, document-reuse detection) that runs at and after signup.** Do not try to solve ban-evasion/fresh-start by hardening signup itself. *Evidence: gig-platform ban-evasion countermeasures (Uber), Aadhaar's population-wide biometric dedup as the actual dedup mechanism rather than enrollment friction.*

7. **Design for undocumented/low-document populations from day one**, since a global, self-signup identity system will enroll people with no verifiable government ID at all (UNHCR's refugee population is the extreme case, but this generalizes to informal-economy workers broadly, which is this product's likely user base). The ID scheme must not implicitly require a government document to exist at all. *Evidence: UNHCR PRIMES/BIMS design explicitly built for undocumented populations.*

8. **Expect and instrument for a non-trivial duplicate rate even without adversarial intent**: data-entry variance, name transliteration, shared devices/phones, and re-enrollment by confused users will produce duplicates on their own, separate from deliberate fresh-start attacks. Healthcare MPI data (up to 10% duplicate rates, majority from data-entry error, not fraud) suggests this is a baseline operational cost to plan for, not an edge case. *Evidence: ONC/AHIMA and eHealth Initiative duplicate-rate findings (Section 2).*

---

## Notes on what I could not verify

- I could not find an ADR file in this repository (`/Users/kylechoy/Desktop/Programming Projects/Personal/identity` contains only `README.md` at present). My assessment of "phone-control-verified phone" as a worker anchor is based solely on the task's own description of that decision, not on reading the ADR text, flagged in Section 3.
- The claim that shared family phones are common in the Philippines/Global South is plausible and consistent with general development-economics knowledge, but I did not find a rigorous quantitative source; treated as low-medium confidence throughout.
- No single canonical primary source uses the exact phrase "merge is a new event referencing both prior IDs, tombstone + alias table." This is synthesized from healthcare MPI merge/unmerge practice and general event-sourcing/DDD conventions, not a direct citation. Flagged as medium-high rather than high confidence for that reason.
- Countermeasure-effectiveness claims for gig-platform anti-fraud (device fingerprinting, biometric 1:N) are sourced mostly from vendor/company communications, which have a self-interested incentive to overstate efficacy; treat as "this is the industry's approach," not "this is proven to work well."

## Sources

- [NIST SP 800-63-4](https://pages.nist.gov/800-63-4/sp800-63.html)
- [SpruceID: What Is NIST SP 800-63-4?](https://spruceid.com/learn/nist-guidelines)
- [Privacy International: ID systems analysed — Aadhaar](https://privacyinternational.org/case-study/4698/id-systems-analysed-aadhaar)
- [ID Tech Wire: UIDAI AI-powered biometric deduplication](https://idtechwire.com/indias-uidai-deploys-ai-powered-invisible-shield-for-aadhaar-biometric-deduplication/)
- [World Bank / ID4Africa: Principles on Identification for Sustainable Development](https://www.id4africa.com/2019/almanac/The-World-Bank-ID4D.pdf)
- [UNHCR: Modernizing Registration and Identity Management — Introducing PRIMES](https://www.unhcr.org/blogs/modernizing-registration-identity-management-unhcr/)
- [UNHCR: Registration as an Identity Management Process](https://www.unhcr.org/registration-guidance/chapter5/registration/)
- [New York Credit Lawyers: Mixed Files and Merged Files](https://newyorkcreditlawyers.com/mixed-files-and-merged-files-common-credit-report-problems/)
- [Consumer Litigation Associates: Mixed credit files](https://clalegal.com/mixed-credit-files-when-someone-elses-information-gets-on-your-credit-report/)
- [Health Samurai: Master Patient Index and Record Linkage](https://www.health-samurai.io/articles/master-patient-index-and-record-linkage)
- [Health Samurai: MDMbox merge/unmerge](https://www.health-samurai.io/mdmbox)
- [Tom Hepworth: Deterministic vs Probabilistic Record Linkage / Fellegi-Sunter](https://tomhepworth.dev/posts/record-linkage/deterministic-vs-probabilistic-linkage/)
- [HealthIT.gov: Patient Identification and Matching Final Report](https://www.healthit.gov/sites/default/files/resources/patient_identification_matching_final_report.pdf)
- [NCBI: Patient Matching Errors and Associated Safety Events](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8823399/)
- [Telesign: Number deactivation and the recycled phone number dilemma](https://www.telesign.com/blog/number-deactivation-and-the-recycled-phone-number-dilemma)
- [Prove: Recycled Phone Numbers](https://www.prove.com/blog/recycled-phone-numbers)
- [DeepStrike: SIM Swap Scam Statistics 2025](https://deepstrike.io/blog/sim-swap-scam-statistics-2025)
- [Efani: SIM Swap Fraud Statistics 2026](https://www.efani.com/blog/sim-swap-fraud-statistics-2026)
- [Uber Newsroom: Strengthening driver/courier identity verification](https://www.uber.com/us/en/newsroom/courier-identity-us/)
- [Incognia: 2025 Frontline Report — Gig Economy Edition](https://www.incognia.com/frontline-report-gig-economy-edition)
- [Verosint: Account Fraud in the Gig Economy](https://verosint.com/post/account-fraud-in-the-gig-economy)
- [Forbes: The 9-Digit Scam That Sparked a Synthetic Identity Boom](https://www.forbes.com/sites/frankmckenna/2024/10/24/this-9-digit-scam-sparked-a-synthetic-identity-boom-in-the-u-s/)
- [Get Out of Debt: CPN "Fresh Credit File" Is a Federal Crime](https://getoutofdebt.org/259310/they-said-you-can-legally-buy-a-cpn-for-a-fresh-credit-file-its-a-federal-crime/)
- [Liam ERD: Why Surrogate Keys Win](https://liambx.com/blog/why-surrogate-keys-win)
