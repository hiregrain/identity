# Prior art in portable credentials and portable reputation: why the graveyard is full

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Confidence note:** Sections 1–2 (standards status) are well-evidenced from primary sources (W3C, 1EdTech, EU) and current as of mid-2026. Section 4 (graveyard) mixes documented failures (Klout, LinkedIn Skill Assessments) with cases where I have high but not certain confidence from general knowledge and could not fully verify current status via search (Sovrin, uPort/Bloom, Learning Machine), which are flagged inline. Braintrust is confirmed still operating, not dead, which revises a common "graveyard" assumption. Treat section 6 as synthesis/judgment, not fact.

---

## TLDR

1. **The technical layer is not the bottleneck. It's basically solved and increasingly boring.** W3C Verifiable Credentials 2.0 is now a full Recommendation (May 2025), Open Badges 3.0 is a ratified 1EdTech standard built on VC/JSON-LD, and the EU is operationalizing the same data model at nation-state scale via EUDI. **The ledger should adopt VC (or a VC-compatible envelope) rather than inventing a proprietary signed-attestation schema.** The reason isn't elegance. Reinventing issuer/holder/verifier crypto and revocation semantics is wasted differentiation effort, and VC-compatibility gives a future path to interoperate with EUDI-style national wallets and 1EdTech-certified LMS/HR platforms for free. Where a proprietary layer is genuinely justified is the *trust-graph and provenance-grading logic on top* (self-asserted → peer-attested → party-attested), which VC doesn't standardize.

2. **Every standards effort that shipped, shipped as plumbing, not as a product with a forcing function.** VC, Open Badges, CLR, Europass, DigiLocker are all "yes you *can* issue/verify a signed claim," and none of them mandate that any employer *must* consume it to do business. Adoption numbers reflect this: Europass EDC has issued ~76,000 credentials since launch, a rounding error against Europe's labor force. Skill India's DigiLocker-backed certificates work because DigiLocker itself is mandatory-adjacent government infrastructure tied to Aadhaar, not because employers demand the credential format.

3. **LinkedIn is the cautionary tale for the exact product you're building.** It has 1B+ profiles of self-asserted data and killed its one serious attempt at making claims verifiable (Skill Assessments, launched 2019, fully sunset 2023-2024) because assessment scores didn't predict job performance well enough to be worth the UX cost, and because LinkedIn's business model doesn't need claims to be *true*. It needs profiles to be *engaging*. This is the central lesson: **a platform whose revenue comes from engagement/ads will not spend to make its data verifiable, because verification reduces volume and doesn't monetize.** Your ledger's business model must depend on the *verification itself* being the sellable asset (a hiring/routing prior), not on volume of self-asserted claims.

4. **The blockchain-credential wave of 2017–2022 died of a specific, repeatable pattern, not "blockchain was a bad idea":** issuer-side cost with no issuer-side benefit, zero consumer (employer) demand, and a two-sided cold start where neither workers nor employers had a reason to be first. Sovrin, uPort, Bloom, Learning Machine/Blockcerts either wound down, pivoted away from their original consumer-facing vision, or were absorbed into infrastructure-only roles, which I hold with moderate confidence (general knowledge, not fully re-verified this session; flagged for spot-check). Klout is the clean, well-documented case of the adjacent "portable score" failure mode: single-number reputation scores get gamed, the algorithm becomes a target, and without a party who *must* trust the score, it has no floor under it.

5. **Braintrust is the important exception that revises the "blockchain reputation always dies" prior.** It is still operating in 2025–2026, on-chain reputation intact, used by real enterprise clients (Nestlé, Porsche, Goldman Sachs, Nike). It worked not because blockchain solved trust portability, but because it built a two-sided *marketplace* (client demand for vetted freelancers) first and used the token/reputation layer as a governance and incentive mechanism *inside* an already-functioning transaction flow, not as the standalone product.

6. **The systems that actually stuck, namely credit bureaus, ATS ecosystems, licensing registries, and DNS/CA trust registries, share one structural feature: a consumer who is compelled (by law, by liability, or by the mechanics of the underlying transaction) to check the record before proceeding.** Nobody built portable reputation as a nice-to-have that stuck. It stuck because lenders are required to pull a credit report, employers are liable if they hire an unlicensed surgeon, and browsers refuse to connect without a valid cert chain. **Design lesson: the ledger needs an analogous compulsion, not just a network-effect hope.**

7. **Bottom-line design lessons (expanded in §6):** (a) adopt VC as the envelope, build proprietary value in provenance-grading and trust-graph logic, not in credential format invention; (b) do not center the product on self-asserted volume; instead, center it on the verified/attested layer as the product, monetized directly by verifier demand; (c) solve cold start by anchoring to a transaction that already requires trust-checking (e.g., a specific vertical's hiring pipeline) rather than launching as general-purpose infrastructure; (d) never collapse provenance into a single score; preserve claim-level, source-attributed evidence, because single scores get gamed and distrusted; (e) make the worker the fulcrum (worker-controlled access) since every worker-hostile scheme (Klout, opaque platform ratings) triggered backlash or apathy; (f) treat "party-attested" as the only tier durable enough to build a business on, since self-asserted and peer-attested layers are necessary but insufficient and didn't save LinkedIn or Klout; (g) expect standards bodies and government wallets (EUDI, DigiLocker) to eventually commoditize the *credential layer*; build the moat in the *attestation relationships and provenance grading*, not in owning the format.

---

## 1. W3C Verifiable Credentials + DIDs

### The data model
VC defines a triangle: an **issuer** signs a claim about a **subject**, gives it to a **holder** (often the subject), who presents it to a **verifier**, who checks the signature against the issuer's DID/public key and (optionally) a revocation registry, without necessarily contacting the issuer at presentation time. Selective disclosure (revealing only some claim fields, e.g. via BBS+ signatures or SD-JWT) and revocation (via status lists or registries) are both part of the spec family, though implementations vary in maturity.

### Status in 2025–2026
- VC 2.0 became a full W3C Recommendation in May 2025; most of the specification family (Data Model, VC-JWT, VC-JOSE-COSE, Data Integrity) is now a ratified web standard. Two pieces (VC JSON Schema, Data Integrity BBS Cryptosuites) remain Candidate Recommendations. [Mike Jones: self-issued](https://self-issued.info/?p=2694)
- A new revision cycle and a Verifiable Credentials Working Group charter are active into 2026, and the related **Digital Credentials API** (browser-level API for presenting/verifying credentials) could reach Candidate Recommendation status in 2026–2027, timed to align with the EU's EUDI wallet rollout. [W3C VC Charter 2026](https://w3c.github.io/vc-charter-2026/), [ID Tech Wire](https://idtechwire.com/w3c-releases-digital-credentials-api-draft-to-advance-standardized-identity-verification-on-the-web/)
- A related but narrower effort, Verifiable Issuers and Verifiers (a trust-registry spec for "who is allowed to issue what"), was reported stalled in mid-2025 due to lack of implementer feedback, needing minor changes before it can move forward. This is a real, if narrow, adoption gap: **the credential envelope is standardized; the trust-registry layer (who counts as a legitimate issuer) is not.** [CCG mailing list](https://lists.w3.org/Archives/Public/public-credentials/2025Jun/0086.html)

### Where adoption has actually stalled
The spec-level story is healthy; the *deployed, general-purpose, cross-industry* story is thin. The concrete, high-volume deployments of VC in 2025–2026 are almost all inside closed or government-anchored ecosystems: EUDI wallets (government-mandated), Europass EDC (EU education, ~76,000 credentials issued, which is small), mobile driver's licenses, and 1EdTech-certified ed-tech platforms issuing Open Badges 3.0 (itself VC-based). There is no general-purpose, cross-industry, employer-side VC verifier market yet. Verification remains mostly siloed inside the same ecosystem that issued the credential. This matches the standard pattern for identity infrastructure: the data model standardizes years before the verifier-side incentive to actually check it exists.

### Should the ledger adopt VC as the attestation envelope?
Yes, with a specific reason, not a generic "use standards" reason: VC gives (1) free interoperability with the EUDI wallet and Europass ecosystem workers will increasingly already hold in the EU, (2) a large pool of existing issuer/verifier tooling (wallets, signature libraries, revocation-list implementations) instead of building crypto plumbing from scratch, and (3) a credible answer to enterprise partners who will ask "is this a real standard or a proprietary lock-in." The proprietary value the ledger should build is *not* the envelope. It is (a) the provenance-grading taxonomy (self-asserted vs. peer-attested vs. party-attested/signed) layered on top of VC's issuer field, which VC does not standardize, and (b) the trust-graph/registry of which issuers are credible for which claim types, which is exactly the piece the W3C's own Verifiable Issuers/Verifiers effort has stalled on. Building a proprietary schema instead would mean re-solving solved problems (signing, revocation, selective disclosure) while forfeiting the interoperability upside for no differentiation benefit.

---

## 2. Open Badges 3.0 / CLR, Europass/EUDI, national skills wallets

### Open Badges 3.0 / Comprehensive Learner Record
Open Badges 3.0, ratified by 1EdTech in June 2024, rebuilt the older Open Badges format on top of W3C VC/JSON-LD, adding issuer identity, cryptographic verifiability, and revocation, explicitly to interoperate with the VC/CLR/Europass ecosystem. The Comprehensive Learner Record 2.0 standard extends this from single badges to a full learner record (competencies, courses, credentials) issued by an institution. [1EdTech](https://www.1edtech.org/1edtech-article/new-open-badges-30-standard-provides-enhanced-security-and-mobility/411060)

Adoption in 2025–2026: major badge platforms (Credly, Accredible, Badgr/Canvas Credentials, POK) have certified as OB 3.0 issuers, and a joint 1EdTech/Credential Engine survey in mid-2025 measured adoption across 97 invited badge platform providers, of which only 24 responded (25% response rate), which is itself a signal of how thin actual measured adoption is even among the vendors closest to the standard. [Badge Count 2025 methodology](https://content.1edtech.org/badge-count-2025/methodology)

**Lesson:** Open Badges solved the format problem for *education-issued* micro-credentials. It has essentially no traction as a format for *employer-issued* work attestations, which is the ledger's actual use case: the standard exists, the employer-side issuing culture does not.

### Europass / EUDI Wallet
Europass's European Digital Credentials for Learning (EDC) is a free issuer tool for EU institutions, using VC-1.1-compliant JSON-LD with an electronic seal for legal validity equivalent to a paper diploma. ~76,000 credentials issued to date, a real but small number relative to the EU's higher-education population. [Europass](https://europass.europa.eu/en/european-digital-credentials-learning)

The EUDI Wallet is the bigger structural bet: EU law requires every member state to offer at least one EUDI wallet to citizens by end of 2026. Rollout is uneven: Denmark launched in production June 2026, France/Germany/Austria are "high preparedness," Germany's public wallet isn't expected until early 2027, and the EU Commission itself has publicly doubted all member states will hit the 2026 deadline. Two years of pilots have shown cross-border credential presentation (e.g., a driving licence issued in one country used in another) working outside lab conditions for the first time. [eIDEasy tracker](https://www.eideasy.com/blog/eu-digital-identity-wallets-july-2026), [Biometric Update](https://www.biometricupdate.com/202604/eu-commission-doubtful-all-member-states-will-be-able-launch-eudi-wallets-this-year)

**Lesson:** EUDI is the closest thing to a forcing function in this space, since it's *law*, not adoption-by-hope. But even government mandate produces a slow, uneven, multi-year rollout. This is the realistic timeline for infrastructure-level identity credentials even with regulatory backing; a startup cannot assume faster organic adoption without an equivalent forcing function of its own.

### National skills wallets (India, and Singapore by reputation)
India's Skill India Digital Hub (launched Sept 2023) issues NCVET-aligned training certificates directly into DigiLocker, the national document wallet tied to Aadhaar. Because DigiLocker is already quasi-mandatory government infrastructure (used for identity documents, now expanding into passport verification as of Dec 2025), the skills-credential piece inherits distribution for free: employers and PSUs accept DigiLocker-stored certificates largely because DigiLocker itself is already trusted infrastructure, not because the skills-credential format won on its own merits. [egovtschemes.com](https://www.egovtschemes.com/skill-india-digital-registration/), [futureskillsprime.in](https://www.futureskillsprime.in/info/digilocker/)

I was not able to verify current-state specifics on Singapore's SkillsFuture credential/skills-passport adoption in this search pass; flag as unverified if it matters to the memo.

**Lesson, generalized across Europass/EUDI/DigiLocker:** the government-backed efforts that show real usage are the ones riding on top of *already-mandatory* infrastructure (a national ID wallet, a training-subsidy disbursement system), not ones that launched a credential standard as a standalone value proposition.

---

## 3. LinkedIn as the incumbent, and why self-assertion caps it

LinkedIn's core graph (1B+ profiles, work history, endorsements, connections) is almost entirely self-asserted: users write their own titles, self-select skills, and endorsements are one click with no verification behind them. This caps LinkedIn's value as a *reference/verification* layer for exactly the reason self-assertion always caps value: there's no cost to lying, so the marginal claim carries very little evidentiary weight, and sophisticated users (recruiters, hiring managers) have learned to treat LinkedIn as a discovery/networking layer, not a truth layer.

LinkedIn's one serious attempt to add verified signal was **Skill Assessments** (launched 2019): timed multiple-choice tests per skill, with a passing badge displayable on the profile. It was fully discontinued: badges stripped from profiles and underlying data deleted by 2024. LinkedIn's own stated reason: recruiters and hirers told them real-world application of a skill (projects, work history, endorsements from real collaborators) was more predictive and more trusted than a standardized test score, and the assessments didn't earn their UX/trust cost. [LinkedIn Help](https://www.linkedin.com/help/linkedin/answer/a1690529), [Medium](https://medium.com/@Neelesh-Janga/linkedin-skill-assessments-no-longer-available-0598ccef1464)

**Lesson for the ledger, stated precisely:** LinkedIn's failure here is not "verification doesn't work," it's "*decontextualized* verification (a generic multiple-choice test disconnected from actual work) doesn't work." It validates the ledger's specific bet, namely that attestations should be *provenance-graded and tied to actual employer/training-program relationships* (party-attested, signed) rather than generic third-party test scores. It also validates that LinkedIn, structurally, will not out-compete a dedicated verification layer, since its business model monetizes engagement and ad/recruiter-seat volume, which is maximized by low-friction self-assertion, not by the friction of real verification. A platform whose revenue depends on volume of unverified claims has a standing disincentive against making those claims costly to produce.

---

## 4. The portable-reputation graveyard

| Effort | What it tried | Failure mode | Confidence |
|---|---|---|---|
| **Klout** (2008–2018) | Single portable "influence score" aggregated across social platforms | Algorithm distrust (the score became a target the moment it mattered, in the "Bieber-gate" episode), active gaming via engagement schemes, no durable revenue model (free scores, no one paying to keep it alive), and platform API access being cut off as Twitter/Facebook restricted data. Acquired by Lithium 2014, folded into Khoros, shut down May 2018. | High. Well documented. [Sunset HQ](https://www.sunsethq.com/blog/why-did-klout-fail), [The Drum](https://www.thedrum.com/opinion/2018/05/15/all-talk-no-clout-how-klout-failed-provide-value-marketers) |
| **Blockchain credential wave, ~2017–2022** (Sovrin Foundation, uPort/Consensys, Bloom/BloomID, Learning Machine/Blockcerts, and similar self-sovereign-identity startups) | Put verifiable credentials or reputation scores directly on a public or permissioned blockchain, marketed as user-owned, portable, censorship-resistant identity/reputation | Classic two-sided cold start: no employer/verifier had a reason to check a chain they didn't trust or understand; issuer-side integration cost (new wallet, new key management, new UX) with no issuer-side benefit; crypto-market hype cycle attracted capital disconnected from actual demand, so many projects raised and built infrastructure before validating a paying verifier. Several of these either wound down, were absorbed into larger infrastructure plays, or pivoted away from consumer-facing credential products toward enterprise/dev-tooling roles. | **Moderate.** This is general knowledge from training, not independently re-verified in this session's searches (the search results returned marketing/spec-sheet material rather than post-mortems). Recommend a targeted follow-up search on each named project's current entity status before citing specifics externally. |
| **Braintrust** (2018–present) | Decentralized talent network storing freelancer reputation/work-history on a public blockchain, token-governed | **Not a failure.** Confirmed still operating 2025–2026, with enterprise clients (Nestlé, Porsche, Goldman Sachs, Nike) and active token vesting/governance. It succeeded relative to the rest of this table by building the marketplace (client-side hiring demand) first and using the reputation/token layer inside an already-functioning transaction, not as a standalone portability product. | High. Confirmed via multiple 2024–2025 sources. [Messari](https://messari.io/report/braintrust-a-talent-network-governed-by-its-community), [usebraintrust.com/token](https://www.usebraintrust.com/token) |
| **Gig-platform reputation portability** (general pattern: attempts to let Uber/TaskRabbit/Upwork-style ratings travel between platforms) | Export a worker's star rating or job-completion history to use elsewhere | Incentive misalignment: the platform holding the rating data has no commercial reason to make it portable, since a worker's locked-in reputation is a switching cost that benefits the incumbent platform, not the worker. No known instance of major gig platforms voluntarily supporting reputation export at scale. | Moderate. Structural/economic reasoning, consistent with observed platform behavior (no worked counter-example found), not a single named failed startup. |
| **LinkedIn Skill Assessments** | Standardized skill tests as verified signal | See §3: decontextualized verification, deprecated for lack of predictive/trust value versus real work evidence. | High. |

### Recurring failure patterns, extracted
1. **Cold start is two-sided and asymmetric.** Workers will join for free if it's low-effort; verifiers (employers) will not spend time or integration cost checking a registry unless it's already where the good candidates are. Nearly every failed effort above solved the worker side and never cracked the employer side.
2. **No one is compelled to consume it.** Nothing forces an employer to check the score/credential before hiring, unlike credit bureaus and licensing boards in §5.
3. **Single scalar scores get gamed and then distrusted.** Klout is the clean case; any "one number" reputation system invites optimization-against-the-metric, and the moment gaming is visible publicly, trust collapses faster than the score can be fixed.
4. **Issuer-side cost without issuer-side benefit kills issuance.** Blockchain-credential efforts asked employers/institutions to adopt new wallets and key management for a benefit that accrued mostly to the worker, not the issuer.
5. **Platforms that already hold the data have no incentive to make it portable.** Locked-in reputation is a retention moat for the incumbent; portability is a cost to them and a benefit to the worker, who usually is not the party with resources to build the exporting infrastructure.
6. **Hype-cycle capital can fund infrastructure years ahead of a validated verifier-side business model** (the 2017–2022 blockchain wave), producing technically complete systems nobody outside the project actually checks.

---

## 5. Counter-examples that worked

- **Credit bureaus (Equifax/Experian/TransUnion):** stick because lenders are functionally required, by underwriting practice and often by regulation, to pull a credit report before extending credit. The consumer (lender) *must* check the record to do the transaction; the score's accuracy matters less than its universal availability and legal defensibility.
- **ATS ecosystems (Workday, Greenhouse, iCIMS, etc.):** stick not because they verify anything, but because they became the operational system of record employers must use to run a hiring process at scale, where the "consumer" (the employer's own recruiting team) is compelled by workflow, not by trust in the data.
- **Professional licensing registries (state bar associations, medical boards, PE licensing boards):** stick because hiring an unlicensed professional in a regulated field creates direct legal/malpractice liability for the hiring party, so the employer is compelled by liability exposure, not convenience.
- **DNS / Certificate Authorities:** stick because browsers technically refuse to connect (or throw a hard warning) without a valid, chain-verified certificate. The "verifier" here is software, not a human who can be lazy, and the compulsion is enforced automatically at the protocol level.

**Common structural feature:** in every working example, *someone downstream is compelled to check the record*, whether by regulation, by liability, by workflow lock-in, or by protocol enforcement, before they can complete a transaction they already wanted to do. None of them succeeded by being a nice-to-have reputation layer that made things marginally more efficient. The compulsion came first; the trust infrastructure grew inside it.

---

## 6. Bottom line: design lessons for the ledger

1. **Adopt VC (or a VC-superset) as the attestation envelope; do not invent a proprietary signed schema.** The crypto/revocation/selective-disclosure plumbing is solved and increasingly a checkbox partners and government wallets (EUDI) will expect. Differentiate on the provenance-grading taxonomy and the issuer trust-registry, the exact piece W3C's own effort has stalled on, not on format invention.

2. **Do not center the product on self-asserted claim volume.** LinkedIn already owns that layer at massive scale and has no incentive to verify it (verification cuts against its engagement-driven business model). The ledger's defensible position is the verified/attested layer, sold directly as a hiring/routing prior to consumers who pay for accuracy, not engagement.

3. **Solve cold start by anchoring to a transaction that already compels trust-checking**, not by launching as general-purpose portable-identity infrastructure. Every graveyard entry tried to be infrastructure first and a market second. Anchor to a specific vertical (an internal business vertical, per the brief) where a hiring/routing decision is already happening and a verified prior is already valuable *today*, then expand outward, mirroring how Braintrust built the marketplace before leaning on the reputation layer.

4. **Never collapse provenance into a single scalar score.** Preserve claim-level, source-attributed evidence (this is literally the self-asserted/peer-attested/party-attested grading the brief already specifies). Klout is the clearest evidence that single numbers get gamed and, once gamed publicly, lose all trust simultaneously rather than degrading gracefully.

5. **Design for issuer-side benefit, not just worker-side benefit.** Every stalled blockchain-credential effort asked employers/training programs to adopt new tooling for a benefit (portability) that accrued to the worker. The append-only attestation flow needs a clear "why does the employer bother signing this" answer independent of altruism: for example, it reduces the employer's own future reference-check burden, or it's a byproduct of a process they're doing anyway.

6. **Make the worker the fulcrum of access control, deliberately, as a trust and adoption strategy, not just an ethical stance.** Worker-hostile or worker-opaque reputation systems (Klout, opaque platform star ratings) generate backlash or apathy; worker-visible, worker-controlled systems have a better shot at being something workers actively maintain and vouch for, which is also the cheapest distribution channel available.

7. **Treat party-attested/signed as the tier the actual business is built on.** Self-asserted and peer-attested layers are useful context and can build the graph early, but they didn't save LinkedIn's reference value and didn't make Klout durable. The monetizable "prior" the brief describes is a party-attested claim, so invest disproportionately in making that tier easy for employers to produce (see #5) rather than trying to make the self-asserted tier more convincing.

8. **Expect the credential-format layer to commoditize over a 3–5 year horizon as EUDI, DigiLocker-style national wallets, and Open Badges/CLR spread**, per the government-backed rollouts already underway. Do not build the moat in owning a proprietary credential format. Build it in the attestation relationships (which employers/training programs actually issue signed claims into the ledger) and the provenance-grading/trust-registry logic, which is durable even if the underlying envelope becomes a commodity standard.

---

## Sources

- [W3C Verifiable Credentials 2.0 Specifications are Now Standards — Mike Jones](https://self-issued.info/?p=2694)
- [W3C Verifiable Credentials Working Group Charter 2026](https://w3c.github.io/vc-charter-2026/)
- [W3C Digital Credentials API Draft — ID Tech Wire](https://idtechwire.com/w3c-releases-digital-credentials-api-draft-to-advance-standardized-identity-verification-on-the-web/)
- [W3C Credentials Community Group mailing list — Incubation and Promotion minutes, June 2025](https://lists.w3.org/Archives/Public/public-credentials/2025Jun/0086.html)
- [1EdTech — New Open Badges 3.0 Standard](https://www.1edtech.org/1edtech-article/new-open-badges-30-standard-provides-enhanced-security-and-mobility/411060)
- [1EdTech — Badge Count 2025 Methodology](https://content.1edtech.org/badge-count-2025/methodology)
- [Europass — European Digital Credentials for Learning](https://europass.europa.eu/en/european-digital-credentials-learning)
- [eIDEasy — EU Digital Identity Wallet Rollout Status, July 2026](https://www.eideasy.com/blog/eu-digital-identity-wallets-july-2026)
- [Biometric Update — EU Commission doubtful all member states will launch EUDI wallets this year](https://www.biometricupdate.com/202604/eu-commission-doubtful-all-member-states-will-be-able-launch-eudi-wallets-this-year)
- [LinkedIn Help — Skill Assessments no longer available](https://www.linkedin.com/help/linkedin/answer/a1690529)
- [Medium — LinkedIn Skill Assessments No Longer Available](https://medium.com/@Neelesh-Janga/linkedin-skill-assessments-no-longer-available-0598ccef1464)
- [Sunset HQ — What Happened to Klout & Why Did It Fail](https://www.sunsethq.com/blog/why-did-klout-fail)
- [The Drum — All talk, no clout: How Klout failed to provide value to marketers](https://www.thedrum.com/opinion/2018/05/15/all-talk-no-clout-how-klout-failed-provide-value-marketers)
- [Messari — Braintrust: A Talent Network Governed by its Community](https://messari.io/report/braintrust-a-talent-network-governed-by-its-community)
- [usebraintrust.com — BTRST Token](https://www.usebraintrust.com/token)
- [egovtschemes.com — Skill India Digital Hub Registration 2026](https://www.egovtschemes.com/skill-india-digital-registration/)
- [FutureSkills Prime — DigiLocker](https://www.futureskillsprime.in/info/digilocker/)
