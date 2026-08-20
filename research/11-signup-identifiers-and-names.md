# Signup identifiers (phone vs. email) and name modeling for a global worker-identity platform

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Status:** Research memo, not a design doc. Confidence stated per claim.
**Scope:** (A) What identifier major identity/gig platforms require at signup, and how much Sybil resistance a verified phone number actually buys over an email address in 2026. (B) How document standards, IDV vendors, and national ID systems model a person's name, and what field structure a global platform should adopt.
**Related:** `03-person-id-and-merge.md` (phone/email as merge anchors), `09-idv-vendor-landscape.md` (vendor selection), `06-adversarial-threat-model.md`.

---

## TLDR: conclusions first

### Part A: signup identifier

1. **Requiring a verified phone number is a real but modest Sybil tax, not a barrier. It raises the marginal cost of a fake account from ~$0 to roughly $0.10–$0.50, and to a few dollars for hardened targets.** That is a 1–2 order-of-magnitude increase over email (effectively free, with 120,000–160,000+ known disposable domains and ~46% of high-risk disposable domains living under 7 days). It is not a wall: a 12-month academic measurement of 29 public SMS gateways found 17,141 disposable numbers receiving 70M+ messages and confirmed OTP interception for 200+ major services including Amazon, PayPal, Uber, WhatsApp, Google and TikTok, all free, no account needed. **High confidence.**

2. **The dominant industry pattern in 2026 is *not* "phone required at signup." It is "either identifier to open an account; phone/device/document verification gated to the moment value or risk appears."** Airbnb, Login.gov, CLEAR and ID.me all accept email-or-phone at account creation. The platforms that hard-require a verified phone before *doing work*, such as Uber, Lyft, Fiverr (before publishing a Gig), and GCash/Maya (statutorily), do so at the point of earning, payout, or regulatory obligation, not at account creation. **High confidence.**

3. **Phone as the *sole* mandatory identifier is affirmatively wrong for this platform's population.** Login.gov, a US federal identity provider with an explicit inclusion mandate, deliberately supports authentication with no phone at all (backup codes, security key, authenticator app, PIV/CAC), and ID.me added landline OTP "to support digital inclusion." Requiring phone-only would exclude exactly the workers this platform targets, while the same populations (India: ~1.88 SIMs per 1.62 handsets; Philippines: 18% two-SIM, ~160M SIMs) can trivially produce multiple numbers. **Phone is a weak uniqueness constraint precisely where it is a strong access barrier, which is the wrong trade in both directions.** Medium-high confidence.

4. **Recommendation: accept email *or* phone as the account-opening identifier; require verified control of at least one; treat neither as a uniqueness key.** Layer risk scoring (VOIP/disposable/carrier reputation via a Persona-class phone-risk report), device signals, and velocity. Escalate to document/biometric proofing at the value-bearing moment (first attestation issued, first payout, first employer read). This is what the ledger's tiered-assurance design (`03-person-id-and-merge.md`) already implies. A verified phone is an *attestation of level 1*, not the identity.

### Part B: name modeling

5. **Store three name layers, never one.** (i) `display_name`: a single free-text Unicode string, the person's own profile name, no structure imposed, no validation beyond length and non-empty. (ii) `document_name`: an immutable, per-document capture of exactly what the verified document said, in ICAO's own two-part shape (`primary_identifier` / `secondary_identifier`) plus the raw MRZ line and the raw VIZ string. (iii) `name_index`: derived, non-authoritative, machine-generated normalization tokens used only for fuzzy duplicate matching, regenerable and never shown to a user. **High confidence**, since this mirrors what ICAO 9303, FHIR `HumanName`, and the major IDV vendors actually do.

6. **The correct primitive for structured names is ICAO's primary/secondary identifier pair, not first/last name.** ICAO Doc 9303 deliberately avoids "given/surname" language because the mapping is not universal; mononyms are encoded by placing the single name in the *primary* identifier and leaving the secondary empty. Adopting ICAO's vocabulary means the mononym case is the spec's normal path rather than a validation failure. **High confidence.**

7. **Never require a surname; never require two name parts; never reject non-Latin script; always keep the raw string.** Sumsub's `firstNameEn`/`lastNameEn` latinized variants and ICAO's transliteration rules (Ö → OE) both demonstrate that *transliteration is a derived field alongside the original, never a replacement for it.*

8. **Name changes are appends, not edits.** FHIR models this with `HumanName.use` (`official`, `maiden`, `nickname`, `old`) plus a validity `period`. Under the ledger's append-only rules this is free: a name change is a new `NameAsserted` event; prior names stay queryable for matching but are not surfaced as current. This is the correct handling for both marriage and gender transition, and the *only* structure that lets you match a 2019 document to a 2026 profile.

---

## Part A: what identifier do platforms require, and does phone actually work?

### A.1 Platform-by-platform survey

| Platform | Identifier at signup | SMS OTP mandatory before use? | Notes |
|---|---|---|---|
| **CLEAR** (clearme.com) | Phone or email, login by OTP "sent to your phone number or email address on file" | No, OTP to *either* channel | Phone is the "address of record" for the enrollment code in the CLEAR Verified flow (SMS code valid 10 min). Real assurance comes from in-person/biometric enrollment, not the phone. |
| **ID.me** | Email + password creates the account; MFA is then required | No, since MFA can be SMS, voice OTP, push, TOTP, or FIDO key | Explicitly offers **landline-based MFA** "to support digital inclusion" for users without mobile devices. |
| **Login.gov** | Email + password; then ≥1 authentication method | **No**, since phone is one option among authenticator app, security key, PIV/CAC, face/touch unlock, backup codes, or a code by mail | The clearest counter-example to phone-mandatory design, from a government IdP with a statutory inclusion obligation. |
| **Persona-powered flows** | Configurable by the customer, since Persona is a verification layer, not an account system | N/A | Sells **Phone Risk Report** (175+ countries) returning line type (fixed/mobile/**VOIP**) and a 1–5 risk score with flag/block recommendations. This is the real 2026 pattern: *score* the phone, don't *require* it. |
| **Uber / Lyft (driver)** | Phone **and** email both required; phone confirmed by SMS code | **Yes** | Uber advises using a number "associated with a wireless mobile provider," i.e., implicit VOIP filtering. |
| **Upwork** | Email-based account creation; phone verification available | No at signup, though **identity verification (government ID) is mandatory** before earning | Assurance moved to document/biometric, not phone. |
| **Fiverr** | Email/social signup | **Yes, before publishing a Gig,** since "all freelancers must verify their phone numbers before offering services"; one phone = one Fiverr account | Fiverr states the rationale as marketplace trust + EU **Digital Services Act** trader-verification obligations. |
| **LinkedIn** | Email or phone | No | Removes **80.6M fake accounts at registration** in a single half-year (H2 2024), 99%+ detected proactively before any user report, achieved by ML/behavioral signals, not by phone gating. Now pushing Persona-based document verification as the trust layer. |
| **Airbnb** | Phone **or** email or Google/Apple/Naver | No | Government-ID verification required of every member, but at listing/booking time. |
| **GCash / Maya (PH)** | Philippine mobile number, mandatory | **Yes** | Not a product choice. **RA 11934 (SIM Registration Act)** requires every SIM to be registered to a real identity with a government ID. The phone number is downstream of a KYC'd SIM, which is why it carries more signal in PH than almost anywhere else. |
| **Aadhaar-linked Indian platforms** | Aadhaar number + OTP to the **Aadhaar-linked** mobile number (or biometric) | Yes, for eKYC | Note the structure: the phone is not the identity, but a delivery channel for an OTP that authenticates against UIDAI. Biometric eKYC is the fallback for users whose mobile isn't linked. |

**Published rationale, where it exists (thin).** Almost nobody publishes a quantified fraud rationale. The two honest statements found: Fiverr cites regulatory (DSA) + marketplace-integrity grounds and enforces one-phone-one-account; Persona's product docs frame phone data as *risk signal*, stating "VOIP phone numbers have a higher risk associated with them since they can be created very easily online," rather than as proof of personhood. **Medium confidence** that this absence of published rationale is itself informative: phone-gating is largely inherited convention plus payout/SMS-notification convenience, not an evidence-backed anti-Sybil decision.

Sources: [CLEAR login FAQ](https://www.clearme.com/support/how-do-i-log-in-to-clearme-com) · [ID.me MFA options](https://help.id.me/hc/en-us/articles/360018113053-Multi-factor-authentication-MFA-options-for-ID-me) · [ID.me MFA for business](https://www.id.me/business/multi-factor-authentication) · [Login.gov create account](https://www.login.gov/help/create-account/how-do-i-create-an-account/) · [Login.gov limited phone access](https://help.usajobs.gov/how-to/account/limited-access) · [Persona Phone Risk Report](https://help.withpersona.com/articles/6MsSJ5GQjHhtIN0xxLLeby/index.html) · [Persona phone/email risk product](https://withpersona.com/product/reports/phone-email-risk) · [Uber SMS verification help](https://help.uber.com/riders/article/i-am-not-receiving-the-sms-to-verify-my-number?nodeId=d66bad6c-0638-4b56-9276-786b97c6196b) · [Lyft account creation](https://help.lyft.com/hc/en-us/all/articles/115012926947-How-to-create-a-Lyft-account) · [Upwork identity verification](https://support.upwork.com/hc/en-us/articles/360001176427-How-to-verify-your-identity-as-a-freelancer) · [Fiverr phone verification](https://help.fiverr.com/hc/en-us/articles/360010140357-Phone-verification-Secure-your-Fiverr-account) · [Fiverr personal/business verification (DSA)](https://help.fiverr.com/hc/en-us/articles/22582440968849-How-to-verify-your-personal-and-business-information) · [Airbnb create an account](https://www.airbnb.com/help/article/221) · [GCash SIM registration FAQ](https://help.gcash.com/hc/en-us/articles/13809239424409-SIM-Card-Registration-FAQs) · [SIM Registration Act (RA 11934)](https://en.wikipedia.org/wiki/SIM_Registration_Act) · [LinkedIn fake-account removals reporting](https://restofworld.org/2025/linkedin-job-scams/)

---

### A.2 The core question: how much better is phone than email?

#### Claim: email is free to forge at unlimited scale. **High confidence.**

Disposable-email domain lists tracked commercially run **120,000–162,000+ domains, updated daily**, and by early 2025 **46% of high-risk disposable domains were "hyper-disposable," alive under 7 days**, mass-produced to generate millions of addresses. Vendors report ~1.3% of all collected addresses are disposable across the board, but **10–30% for free-tier / freemium signups**. Marginal cost per additional email identity: effectively zero, and self-hosting a domain makes blocklists useless.
[WhoisXML disposable domain list](https://emailverification.whoisxmlapi.com/disposable-email-domains) · [Disposable email statistics 2026](https://verified.email/blog/email-marketing/disposable-email-trends)

#### Claim: a verified phone number costs an attacker roughly $0.10–$0.50 per account, not zero and not much. **High confidence on the price range; medium on the tails.**

- **Free tier:** public SMS gateways publish inbound messages with no registration at all. The IMDEA / UC3M study *"Your Code is 0000: An Analysis of the Disposable Phone Numbers Ecosystem"* (TMA 2023) monitored **17,141 disposable numbers across 29 public SMS gateways over 12 months, >70M messages**, and found OTPs for **200+ popular services**, including Amazon, PayPal, Uber, WhatsApp, Facebook, Instagram, Google, TikTok. Volume of registration-OTP traffic grew "from thousands up to millions of messages" since 2018. Cost: **$0.**
  [IMDEA writeup](https://software.imdea.org/news/2023/12-15-dpn-online-fraud/) · [arXiv:2306.14497](https://arxiv.org/pdf/2306.14497)
- **Paid, hardened tier:** commercial OTP-resale services price **US non-VOIP numbers at ~$0.25 per verification**, ~$0.50+ for "premium" (hard) services, and $1.50–$1.80 for a rented number. Lower-tier providers advertise **$0.01–$0.10** for easy targets/countries. Note SMS-Activate, long the largest such service, shut down in December 2025, so the market fragmented rather than disappeared.
  [TextVerified products](https://www.textverified.com/products) · [2026 pricing comparisons](https://verifysms.app/blog/top-10-sms-verification-services-2026/)
- **Structural cost floor is broken.** Trend Micro's *SMS PVA* research documented services built on **thousands of compromised Android phones with real SIMs** across many countries, letting buyers target country-level. Because "operators did not have to pay for the actual hardware, SIM card, and the connectivity service (the cost is covered by the unsuspecting user of an infected device), they could offer the SMS verification code service at much cheaper prices compared to those sourced from SIM boxes." **The economic assumption behind phone verification, that a number costs money, does not hold when the numbers are stolen.**
  [Trend Micro SMS PVA Part 1](https://www.trendmicro.com/en_us/research/22/b/sms-pva-cybercriminals-part-1.html) · [Part 2](https://www.trendmicro.com/en_us/research/22/b/sms-pva-cybercriminals-part-2.html)
- **Longitudinal price evidence.** Google's own study, *Dialing Back Abuse on Phone Verified Accounts* (CCS 2014), bought 4,695 Google PVAs and analyzed 300,000 more, observing a **30–40% market-wide price drop** driven by "rampant" abuse of free VOIP and short-lived Indian/Indonesian numbers tied to human verification farms, until Google penalized specific abused carriers. The finding that *carrier-level reputation*, not phone verification per se, was the effective control has held up for a decade.
  [Google Research](https://research.google/pubs/pub43134) · [ACM CCS 2014](https://dl.acm.org/doi/10.1145/2660267.2660321)
- **2026 practitioner confirmation.** Castle (May 2026), releasing an open-source list of the 1,000 most-abused disposable numbers: *"SMS verification is often treated as a strong friction mechanism against fake account creation. In practice, attackers adapted years ago."* Their conclusion is that number-based detection only works layered with other signals.
  [Castle blog, 21 May 2026](https://blog.castle.io/sms-verification-abuse-at-scale-releasing-our-open-source-disposable-phone-number-list/)

#### Claim: VOIP filtering is where most of the real defensive value sits, and it is a heuristic, not a boundary. **Medium-high confidence.**

Persona's Phone Risk Report returns line type (fixed line / mobile / VOIP) plus a 1–5 risk score across 175+ countries, with flag-or-block recommendations, and factors in traffic-pattern and velocity anomalies. Uber steers users to "a number associated with a wireless mobile provider." This is the operative filter in practice. But the paid resale market exists *specifically* to sell non-VOIP mobile numbers, priced at a premium precisely because filtering works, which tells you the filter raises cost rather than eliminating supply. **Confidence caveat:** every effectiveness figure here comes from vendors selling the control; I found no independent measurement of VOIP-filter precision/recall. Treat vendor claims skeptically.

#### Claim: SMS verification imports an *attacker-profitable* attack surface that email does not. **High confidence.**

SMS pumping / Artificially Inflated Traffic, bots hammering the OTP endpoint to route messages through networks where the attacker shares termination revenue, cost brands **$1.16B in 2023** (Enea, cited by Twilio). Email OTP has no equivalent revenue-sharing channel. Practically: adding mandatory SMS OTP means you now own an SMS fraud budget and a send-to-verify ratio to monitor.
[Twilio on SMS pumping](https://www.twilio.com/en-us/blog/sms-pumping-fraud-solutions) · [Twilio Verify toll-fraud docs](https://www.twilio.com/docs/verify/preventing-toll-fraud)

#### Counter-evidence: phone numbers are unstable and non-exclusive as identifiers.

- **Recycling.** ~**35M US numbers recycled annually** (~10% of numbers change hands per year; ~100k/day; up to 20% in high-turnover area codes), with a mandated 45-day aging period. Princeton's study of 259 recycled numbers found **66% still linked to active accounts** at the prior owner's services and **39% tied to breach-exposed credentials.** Emerging-market recycling windows are generally shorter and less regulated, though **this specific point I could not source rigorously; flagged as directional.**
  [Princeton recycled-numbers study](https://recyclednumbers.cs.princeton.edu/assets/recycled-numbers-latest.pdf) · [CITP blog](https://blog.citp.princeton.edu/2021/05/03/phone-number-recycling-creates-serious-security-and-privacy-risks-to-millions-of-people/) · [Telesign](https://www.telesign.com/blog/number-deactivation-and-the-recycled-phone-number-dilemma)
- **Multi-SIM defeats uniqueness where the platform most needs it.** India averages **1.88 SIMs per 1.62 handsets**; the legal cap is **9 SIMs per person**. Philippines: ~160M SIMs; SWS survey shows **18% of Filipino phone owners use two SIMs, 1% three or four**; DICT has proposed a 3–4 SIM cap precisely because there isn't one. A "one phone = one person" rule is enforceable only against honest users.
  [GSMA Intelligence on subscribers vs. connections](https://www.gsmaintelligence.com/research/measuring-mobile-penetration-untangling-subscribers-mobile-phone-owners-and-users) · [India SIM cap](https://www.dnaindia.com/india/report-how-many-sim-cards-a-person-can-buy-in-india-3094802) · [SWS/Inquirer PH SIM data](https://newsinfo.inquirer.net/1764467/56-of-filipino-sim-card-holders-now-registered-sws/amp) · [PH SIM cap proposal](https://manilastandard.net/news/314269259/government-to-limit-sims-per-person)
- **Access exclusion is real and gendered.** GSMA Mobile Gender Gap Report 2025: women in LMICs are **8% less likely to own a mobile** and **14% less likely to own a smartphone / use mobile internet**; **885M women remain unconnected**, ~60% of them in South Asia and Sub-Saharan Africa. For a platform whose thesis is credential portability for under-credentialed workers, a phone-mandatory gate is a direct hit on the intended population.
  [GSMA Mobile Gender Gap Report 2025 (PDF)](https://www.gsma.com/wp-content/uploads/2025/12/The-Mobile-Gender-Gap-Report-2025.pdf)
  **Caveat:** the specific "shared family phone in emerging markets" claim is widely repeated (and consistent with the ownership gap above), but I did not find a rigorous quantitative measurement of *shared-handset rates in PH/India* in 2025–26. Flagged as directional, same as in `03-person-id-and-merge.md`.
- **SIM swap.** FBI IC3 2024: **982 US complaints, $25.98M** reported losses. UK Cifas: ~3,000 unauthorised SIM swaps in 2024, described as a **1,055% surge**; telecoms now 69% of UK account-takeover filings in H1 2025. IDCARE (Australia): **+240%** year over year, **90% without victim engagement.** A phone-anchored identity is a phone-carrier-security-dependent identity.
  [FBI IC3 2024 figures via summary](https://deepstrike.io/blog/sim-swap-scam-statistics-2025) · [Cifas/UK figures](https://www.efani.com/blog/sim-swap-fraud-statistics-2026)

---

### A.3 Bottom line for Part A

**A verified phone number buys you roughly one to two orders of magnitude of attacker cost over email, from ~$0 to ~$0.10–$0.50 per identity, and essentially nothing in the way of uniqueness, permanence, or exclusivity. High confidence.**

Concretely:

1. **It is a cost multiplier, not a personhood proof.** Against a bulk adversary willing to spend $500, phone verification is the difference between ~unlimited accounts and ~1,000–5,000 accounts. That matters for spam economics; it does not establish that a person exists or is unique. **High confidence.**
2. **It is worthless as a uniqueness key** in India and the Philippines specifically, where multi-SIM is normal and legally permitted up to 9 (IN) / uncapped (PH). **High confidence.**
3. **It is unstable over time**, since recycling makes a phone number a *lease*, not an identifier. Any dedup or account-recovery logic keyed to phone will silently mis-merge people. **High confidence.** (Consistent with the conclusion already reached in `03-person-id-and-merge.md`.)
4. **The real defensive value is in the *risk score* attached to the number, not the possession of one**, meaning line type, carrier reputation, velocity, disposable-list membership. Google's 2014 finding (penalize abused carriers, not verify-or-not) and Persona's 2026 product shape agree. **Medium-high confidence**, vendor-sourced.
5. **Phone-mandatory signup is a net-negative trade for this platform's stated population**, since it excludes real workers (GSMA gender gap; Login.gov and ID.me both engineered explicit non-phone paths for exactly this reason) while barely inconveniencing adversaries. **Medium-high confidence.**

**Recommended posture:** email *or* phone at signup (verified control of at least one); phone-risk and email-risk scoring on both; neither as a uniqueness constraint or merge key; device + behavioral + velocity signals as the actual Sybil control; document/biometric proofing escalated at the first value-bearing action. Where a jurisdiction supplies a genuinely KYC'd phone, such as the Philippines under RA 11934, the standout since the SIM is already bound to a government ID, treat *that* number as a higher-assurance attestation than a generic verified phone, and record the distinction rather than flattening it.

---

## Part B: how identity systems model a person's name

### B.1 The document standard: ICAO Doc 9303

**ICAO Doc 9303 does not use "first name" and "last name." It uses `primary identifier` and `secondary identifier`.** This is a deliberate abstraction: the primary identifier is whatever the issuing State treats as the principal name component (surname, family name, maiden-plus-married name); the secondary identifier is "all remaining components." The MRZ encodes them as `PRIMARY<<SECONDARY`, with `<` as filler and `<<` as the separator.

Structural facts that matter for schema design (**high confidence**, these are in the spec, [Doc 9303 Part 3](https://www.icao.int/sites/default/files/publications/DocSeries/9303_p3_cons_en.pdf)):

- **A mononym is the spec's normal path, not an error case.** It is valid to have only a primary identifier and no secondary identifier. A system that requires two name parts is *less* permissive than the international passport standard.
- **The name field is fixed-length and will truncate.** TD3 (passport) allocates 39 characters to the whole name field in line 2; TD1 (ID card) allocates 30. Long names, extremely common in Filipino, Indian, Arabic and Spanish-convention naming, are truncated by design. **A truncated MRZ name is not evidence of fraud.**
- **The MRZ character set is A–Z, 0–9, `<` only.** No diacritics, no non-Latin script. Issuing States must transliterate national characters using ICAO's transliteration tables (Latin, Cyrillic, Arabic families), the canonical example being `Ö → OE`. So `MÜLLER` in the VIZ becomes `MUELLER` or `MULLER` in the MRZ depending on the issuing State's table.
- **Prefixes, suffixes, titles, professional/academic qualifications, honours and hereditary status are excluded from the MRZ** unless the issuing State considers them legally part of the name. So "Jr." may or may not appear, depending on jurisdiction.
- **The VIZ (visual inspection zone) carries the truthful name; the MRZ carries a lossy machine encoding of it.** They routinely disagree without any fraud. The UK's use of MRZ-derived names in digital immigration status has been the subject of a formal critique on exactly this point, per [the3million, Feb 2025](https://the3million.org.uk/sites/default/files/documents/t3m-note-UKDigitalImmigrationStatusICAOStandards-19Feb2025.pdf).

**Implication:** if you store one name from a document, store the VIZ name and keep the MRZ separately. If you match on MRZ names, expect systematic false negatives on long, accented, and non-Latin names.

---

### B.2 What IDV vendors actually return

Three incompatible architectures exist in this market. **High confidence**, all read from vendor documentation.

| Vendor | Architecture | Name fields returned | Mononym handling |
|---|---|---|---|
| **Persona** | **Parallel-script** | `name-first`, `name-middle`, `name-last`, `name-suffix` **plus** `native-name-first`, `native-name-middle`, `native-name-last`, `native-name-title` | **Undocumented.** Inferred: one field populated, other null. |
| **Sumsub** | **Transliterate-and-flatten** | `firstName`, `middleName`, `lastName`, each with an auto-transliterated Latin sibling `firstNameEn` / `middleNameEn` / `lastNameEn`; plus `aliasName` | **Only vendor that documents it**, and lossily. See below. |
| **Onfido / Entrust** | Latin-only split | applicant `first_name` + `last_name` (**both mandatory**); document report properties `first_name`, `last_name`, `full_name`, `middle_name`, MRZ data | **Structurally impossible**, since both fields are required at applicant creation; docs suggest placeholder values. |
| **Veriff** | Latin-only split, maximally nullable | `firstName`, `lastName`, `fullName`, `title`, **all nullable**; optional `nameComponents { title, middleName, firstNameOnly, firstNameSuffix }` | Tolerated by nullability. `fullName` exists **only for Indian Aadhaar cards.** |
| **Jumio** | Latin-only split, thinnest | `firstName`, `middleName`, `lastName`, `suffix` (actually a title: "Mr, Mrs, Ms"); `mrzData` with `line1`, `line2`, `format` (MRP/TD1/TD2/…), `extractionMethod` (`MRZ`/`OCR`/`BARCODE`/…) | Undocumented. Compound names arrive unsplit (`"firstName": "THOMAS JACOB"`). |
| **IDfy** (India) | **Full-name-native** | `name_on_card`, a single string, for Aadhaar OCR; `fields_match_result` carries the match outcome; separate **Name Compare API** returns a fuzzy score with a settable threshold | Non-issue: never split in the first place. |

**The sharpest finding: mononym support is near-universally undocumented, and where it exists it is lossy.** Sumsub's documentation states that when a document presents the name as a single line without clear separation, "the system returns the extracted name value in the `firstName` field only," with **no discriminator flag**. Its Indonesia non-doc verification spec makes this explicit, documenting `firstName` as **"Full name."** A consumer reconstructing `firstName + " " + lastName` therefore cannot distinguish a genuine mononym from a failed surname extraction. Onfido goes further and makes a real mononym unrepresentable by requiring both fields.
[Sumsub applicant data](https://docs.sumsub.com/reference/get-applicant-data) · [Sumsub Indonesia](https://docs.sumsub.com/reference/indonesia) · [Persona government-ID verification](https://docs.withpersona.com/api-reference/verifications/government-id-verifications/retrieve-a-government-id-verification) · [Entrust/Onfido docs](https://documentation.identity.entrust.com/api/latest/) · [Veriff decision webhook](https://devdocs.veriff.com/docs/decision-webhook) · [Jumio credential reference](https://documentation.jumio.ai/docs/developer-resources/API/References/credential-reference)

**Fuzzy matching is offered everywhere, disclosed almost nowhere.**
- **Persona** publishes six comparison methods: String Similarity, String Difference (edit distance), Nickname ("Jim"→"James"), Substring (min 3 chars), Tokenization (split on whitespace/hyphens), Date Similarity, plus named normalizations `remove_prefixes`, `remove_suffixes`, `fold_characters` (diacritic folding). [Docs](https://help.withpersona.com/articles/2zXa85BILxtncnwdIj8jge/)
- **Sumsub** names Levenshtein, phonetic matching, transliteration variants, transcription variants, hypocorisms, but scopes it to **AML screening only**, and states outright: **"fuzziness is not performed on non-Latin characters."** [Docs](https://docs.sumsub.com/docs/fuzzy-matching)
- **Onfido** exposes `data_comparison` (document vs. applicant-supplied) with configurable, **not default**, fuzzy matching on `first_name`/`last_name`, and separately `data_consistency` (MRZ vs. OCR within the same document). [Docs](https://documentation.identity.entrust.com/guide/document-report/)
- **IDfy** and Trulioo disclose nothing beyond "fuzzy."

**Consequence:** non-Latin names degrade at the *matching* layer, not the storage layer. Storage is generally fine; comparison is exact-match-or-fail. Plan accordingly.

**No vendor documents an MRZ-vs-VIZ precedence rule.** Onfido's `data_consistency` breakdown detects disagreement; Jumio's `extractionMethod` tells you the provenance; nobody says which wins. Given ICAO's 39-char truncation and diacritic stripping, disagreement is routine and benign. **This is an open question to settle in vendor diligence** and should be an explicit line item in any vendor contract review (see `09-idv-vendor-landscape.md`).

---

### B.3 What national systems do

- **Aadhaar (India): a single full-name string, stored twice, once in English, once in the local language of the enrolling State.** UIDAI does not decompose into given/family. Regional-language display is a supported update path covering the Name and Address fields specifically, because those require translation. This is why Indian IDV products (IDfy) sell a **name-comparison** API rather than a name-parsing one, and why the Aadhaar↔PAN name-mismatch problem is endemic: two full-name strings from two agencies, compared by string equality. [UIDAI FAQ on regional language](https://uidai.gov.in/en/298-english-uk/faqs/enrolment-update/enrolment-partners-ecosystem-partners/16504-is-there-any-provision-available-to-update-my-regional-language-in-aadhaar-to-display-all-fields-in-same-regional-language.html) **High confidence on the single-field structure; medium on the exact update mechanics.**
- **PhilSys (Philippines): four discrete fields, namely first name, middle name, last name, and suffix, with suffix as its own field precisely so "Jr." is not glued onto the last name.** The middle name is conventionally **the mother's maiden surname**, not a Western middle name. **This is the single most consequential naming difference for a platform serving PH workers:** a Filipino's "middle name" is a *lineage* field, and Western systems that drop or initialize it destroy information that PH institutions treat as identifying. [PhilSys FAQ](https://philsys.gov.ph/faq-frequently-asked-questions/) **High confidence.**
- **The pattern:** the two national systems this platform must serve most closely have *opposite* name architectures: one single-field, one four-field with a culturally specific middle. Any schema that privileges either will corrupt the other.

---

### B.4 Published guidance

- **GOV.UK Design System, "Ask users for names":** use single or multiple fields depending on need; "not everyone's name fits the first-name, last-name format"; "using multiple name fields means there's more risk that a person's name will not fit the format you've chosen"; a single field "can accommodate the broadest range of name types, but means you cannot reliably extract parts of a name." Label a single field **"Full name."** Support all characters "including numbers and symbols." [design-system.service.gov.uk/patterns/names](https://design-system.service.gov.uk/patterns/names)
- **USWDS "Name" pattern:** "If you don't need to parse out the separate pieces of a person's name, you should consider letting them enter it into a single text field." Explicitly calls out that "in some cultures, such as Indonesian and Icelandic, people may have only one name," and directs: **do not require users to enter something in each field**, and **do not restrict character types.** [designsystem.digital.gov](https://designsystem.digital.gov/patterns/create-a-user-profile/name/)
- **W3C, "Personal names around the world":** where possible "just use the full name as the user provides it"; if you must split, label the fields **"Family name"** and **"Other/given names"**, not first/last: "avoid using the labels 'first name' and 'last name' in non-localized forms, since these can be confusing." Also: **"don't require that people supply a family name"**; "don't assume that members of the same family will share the same family name"; **"don't assume that a single letter name is an initial"** (warn, don't block). For script variants it recommends offering two optional fields, **"Name (in your alphabet)"** and **"Latin transcription (if different)"**, which is precisely the parallel-script model Persona implements and the one recommended in B.5. [w3.org](https://www.w3.org/International/questions/qa-personal-names)
- **Patrick McKenzie, "Falsehoods Programmers Believe About Names" (2010)**, the canonical 40-item list. The operative ones here: people's first and last names are not necessarily different; people do not necessarily have family names; names change; names are not globally unique; names have no universal order. [kalzumeus.com](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
- **HL7 FHIR `HumanName`**, the best-designed reference model in production anywhere, and the one to copy: `text` (full rendered name), `family` (0..1), `given` (0..\*, ordered array, "not always 'first'", includes middle names), `prefix` (0..\*), `suffix` (0..\*), `use` (`usual | official | temp | nickname | anonymous | old | maiden`), and `period` (when this name was in use). Note the three design decisions worth stealing: **`given` is an array, not first+middle**; **`family` is optional**; **a person has many names simultaneously, each with a use and a validity window.** [FHIR R4 datatypes](https://hl7.org/fhir/R4/datatypes.html)
- **schema.org `Person`** offers `name`, `givenName`, `familyName`, `additionalName`, `alternateName`, usable for interop output but too thin to be a storage model (no `use`, no `period`, no script variants).
- **OpenSanctions, "More than a Technical Problem" (June 2025)**, the best available statement of why canonicalization fails: "Names are social constructs. They shift across time, cultures, and contexts." Romanization is **not a function**: 张 → Zhang / Chang / Cheung; 박 → Park / Pak / Bak. Any system normalizing to a single canonical Latin form gets one convention right and the rest wrong. Their conclusion: accept that an entity legitimately has *many* equally valid names, and match against the set. [opensanctions.org](https://www.opensanctions.org/articles/2025-06-24-name-matching/)
- **On matching techniques:** phonetic hashing (Soundex, Double Metaphone) encodes approximate *English* pronunciation and is useless across scripts by construction; edit distance returns maximum distance on every script boundary crossing. Practitioner consensus in sanctions screening is a hybrid: broad phonetic/transliteration recall pass, then discriminative scoring on additional attributes (DOB, document number, address history, known aliases), never name alone. [OpenSanctions](https://www.opensanctions.org/articles/2025-06-24-name-matching/) · [Babel Street on fuzzy name matching](https://www.babelstreet.com/blog/fuzzy-name-matching-techniques) **Medium-high confidence**, partly vendor-sourced.

---

### B.5 Practical recommendation

**Three layers, strictly separated by authority. Never collapse them.**

**Layer 1: `display_name` (the person's own, self-asserted).**
- One field. `TEXT`, full Unicode, NFC-normalized on write, no character-class validation, no length cap below ~200 chars, no requirement for a space or two tokens.
- Labelled "Full name" in the UI (GOV.UK/USWDS guidance).
- Optional companion fields, **never required**: `preferred_short_name` (what to call them in-product) and `display_name_script_variants[]`, an array of `{script, value}` so a worker can carry both `Иван Петров` and `Ivan Petrov`, or 张伟 and Zhang Wei, without either being "the" name.
- This is what employers see. It is self-asserted and labelled as such.

**Layer 2: `document_name` (per verified document, immutable, append-only).**
One row per verification event, never updated:
```
document_name {
  verification_id            -- FK to the attestation event
  document_type              -- passport / national ID / DL / Aadhaar / PhilID
  issuing_country
  primary_identifier         -- ICAO vocabulary, NOT "last_name"
  secondary_identifier       -- ICAO vocabulary, NOT "first_name". NULLABLE.
  is_mononym                 -- BOOLEAN, explicit. Do not infer from a null.
  native_script_name         -- raw, unnormalized, as printed in the VIZ
  native_script_code         -- ISO 15924
  latin_name_raw             -- full VIZ Latin string, exactly as printed
  mrz_line_1, mrz_line_2     -- raw, stored verbatim
  name_source                -- 'MRZ' | 'VIZ' | 'BARCODE' | 'SELF_ATTESTED'
  vendor, vendor_field_map   -- which vendor, which fields it came from
  captured_at
}
```
Four non-negotiables here. **(1)** Use ICAO's `primary/secondary identifier` vocabulary, which makes the mononym the normal path and stops engineers reasoning in Western first/last terms. **(2)** `is_mononym` is an explicit boolean, because Sumsub's overloaded-`firstName` behaviour means a null surname is ambiguous between "no surname exists" and "extraction failed," so you must record which. **(3)** Always keep the raw MRZ lines and the raw VIZ string; every derived field is regenerable from them, and vendor field mappings change. **(4)** Record `name_source`, since you will need it the first time MRZ and VIZ disagree, which will be week one.

**Special handling to build in from day one:**
- **PhilID:** capture the middle name in its own field and label it `mothers_maiden_surname` in the PH mapping, not `middle_name`. Never initialize it, never drop it.
- **Aadhaar / Indian documents:** expect a single full-name string. Populate `primary_identifier` with the whole string and set `is_mononym = false` but `name_unsplit = true`, or simpler, add a `name_structure` enum: `SPLIT | UNSPLIT | MONONYM`. **Do not guess a surname by taking the last token.** In South India the last token is frequently a patronymic or a caste/village name, not a family name.

**Layer 3: `name_index` (derived, disposable, never displayed).**
Generated from Layers 1 and 2, regenerable at will, versioned by generator version so you can rebuild when the algorithm improves:
- Token set (whitespace/hyphen/apostrophe split), order-independent, because name order is not universal.
- ICU-transliterated Latin form **as an additional token set**, not a replacement. Store *multiple* romanizations where the script admits them (Zhang/Chang/Cheung), per the OpenSanctions point that romanization is not a function.
- Diacritic-folded form, alongside (not replacing) the accented form.
- Nickname/hypocorism expansion, locale-scoped (Jim↔James is an English fact, not a universal one).
- **Never phonetic-hash non-Latin input**, since Soundex/Metaphone are English-pronunciation encoders and produce noise there.

**Matching rule: never match on name alone.** Name tokens are a *blocking/recall* mechanism to generate candidates; the decision must be a weighted score across name tokens, DOB, document number, issuing country, and phone/email, in the Fellegi-Sunter shape already adopted in `03-person-id-and-merge.md`. A high name-token overlap with no corroborating field is a candidate for human review, never an automatic merge. This matters more here than in most systems because the target populations include naming conventions with very low name entropy. A large share of Filipino, Vietnamese and Korean surnames concentrate in a handful of values, so "same surname + same first name" is far weaker evidence than the Western intuition suggests.

**Name changes (marriage, gender transition): append, never overwrite.** Copy FHIR: every name assertion carries a `use` (`current | former | maiden | legal | preferred`) and a `valid_from` / `valid_to` period. A `NameAsserted` event supersedes the prior current name without deleting it. Three reasons this is required, not optional: (1) a 2019 document will legitimately carry a name the 2026 profile no longer uses, and only retained history lets you link them; (2) an employer verifying a 2020 attestation needs the name that was current *then*; (3) for gender transition specifically, the prior name must be retained for matching but **must never surface in any employer-visible view or notification**, which is a hard access-control requirement, not a display preference, and should be enforced at the query layer rather than the UI. **Medium-high confidence** on the privacy-control framing; the structure itself is high confidence (it is exactly FHIR `HumanName.use` + `period`).

**What this buys:** mononyms are representable and explicitly flagged; non-Latin scripts survive intact with transliteration as an addition rather than a substitution; the Filipino middle name survives; name changes are queryable history rather than lost state; fuzzy matching operates on a regenerable derived index rather than on authoritative data; and no worker is ever told their real name is invalid, which, for a platform whose entire premise is being trusted by workers who are routinely failed by credential systems, is not a cosmetic concern.

---

## Open questions / gaps in this research

1. **MRZ-vs-VIZ precedence**: no vendor documents which source wins. Must be resolved in vendor diligence.
2. **Shared-handset rates in PH/India**: widely asserted, not rigorously measured in any 2025–26 source I could find. Same gap flagged in `03-person-id-and-merge.md`.
3. **VOIP-filter precision/recall**: every figure is vendor-published. No independent measurement located.
4. **Emerging-market number-recycling windows**: well documented for the US (45-day FCC aging), not for PH/IN.
5. **IDfy primary API docs were unreachable** (`api-docs.idfy.com` DNS failure); IDfy field names rest on marketing pages. Verify directly before relying on them.
6. **Persona mononym behaviour is undocumented**: worth an explicit test with a real Indonesian KTP during vendor evaluation.
