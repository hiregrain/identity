# Adversarial threat model for a global identity + work ledger

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

*Research memo: provenance-graded claims (self-asserted / peer-attested / party-attested), worker-visible record, universal self-signup.*

---

## TLDR

The founding docs' threat model is underdeveloped in a specific, correctable way: it treats *peer attestation* as the main attack surface and *party attestation* as trustworthy by default. Evidence across adjacent systems (reputation graphs, credential markets, review platforms, credit bureaus, gig platforms) says the opposite emphasis is warranted:

1. **Peer-attestation Sybil attacks are well-studied and reasonably tractable.** Graph-based detection (SybilRank lineage) plus production controls (device/IP clustering, velocity limits, reciprocity caps) catch the cheap attacks. This is the solved-enough part of the problem.
2. **Party-attestation fraud is the underweighted risk and probably the bigger one at scale.** Diploma mills, fake training verticals, and employer collusion (both inflation and retaliation) are harder to detect because parties are institutionally credentialed rather than individually scored, and the ledger's design explicitly treats them as more trustworthy, which is exactly the property attackers will target once peer-layer defenses raise the cost of Sybil attacks. History (accreditation mills gaming CHEA/DOE recognition, fake review brokers operating at industrial scale) shows institutional-level trust is gameable at scale once there's a market for it.
3. **Universal self-signup and worker-editable self-asserted claims create a fresh-start/re-entry problem that the founding docs don't appear to address at all.** eBay, Uber, and credit bureaus all rely on friction at the *identity* layer (verified ID, SSN-equivalent anchors, device/payment fingerprinting) to prevent bad actors from re-entering under a new identity rather than on the reputation layer. A record system with "universal self-signup" and no persistent identity anchor is structurally exposed to this unless verified-identity anchoring is bolted on deliberately, which is in tension with the low-friction signup goal.
4. **A visible, gating score will be gamed (Goodhart), and the literature is unusually direct about what happens:** LinkedIn endorsements degenerated into a reciprocity game; Uber/gig five-star ratings encode measurable racial bias that shapes income (a Nature-published RCT found switching from 5-star to thumbs-up/down eliminated a 9% racial earnings gap); credit scores are piggybacked via commercial tradeline-rental services that FICO has had to patch against. The implication for the ledger: expose coarse, structural signals (tenure, attestation density, dispute history) rather than a single composite score that becomes the optimization target.
5. **Retaliation and coercion are legally and operationally live risks that regulated reference-checking has been wrestling with for decades**, and the U.S. legal answer (qualified privilege conditioned on absence of malice, defamation liability for false/retaliatory statements) has pushed many employers toward "name, rank, dates only," a chilling-effect equilibrium the ledger should study before assuming employers will attest honestly and completely.

**Confidence:** Sections 1, 3, and 4 rest on well-documented, multiply-sourced patterns (academic Sybil-detection literature, court doctrine, a peer-reviewed RCT). Section 2 (party-side fraud) and Section 5 (retaliation dynamics) are evidenced mostly by industry/practitioner sources and legal-explainer sites rather than peer-reviewed measurement, so treat those as directionally right but not quantified. I could not find the internal doc referenced in the task prompt (device/IP collusion exclusion + reciprocal-ring caps for a hospitality reputation graph) anywhere in this repository; the assessment in Section 1 is written against the *description* given, not an inspected document, so flag this gap before treating the assessment as a review of that specific artifact.

---

## 1. Sybil attacks on peer attestation

### The pattern: reference farming, reciprocal rings, collusion clusters

Peer attestation networks fail in a specific, recurring way: attackers don't need to fabricate credibility, they need to fabricate *edges*, connections that look like organic peer relationships. LinkedIn's endorsement feature is the canonical case study because it's public, long-running, and thoroughly documented as degenerating into a reciprocity game: giving an endorsement is a low-cost action that triggers a notification, and the modal response is to endorse back, regardless of actual working knowledge of the person's skill. Academic treatments have explicitly framed this as a "game of strategy" / quid-pro-quo dynamic rather than a signal of competence, and practitioner accounts describe endorsements from people with no working relationship as a frequent, low-effort abuse pattern (Pam Marketing Nut 2012; ResearchGate "Endorse me back"; ResearchGate "The LinkedIn Endorsement Game").

The general failure mode generalizes beyond LinkedIn to any peer-attestation system: cheap positive signals (upvote-style, no cost to give, notify-and-reciprocate UX) produce dense reciprocal subgraphs that are statistically distinguishable from organic ones but visually and individually indistinguishable claim-by-claim.

### Detection: what the literature says, what production systems actually do

**Academic lineage (SybilGuard → SybilLimit → SybilInfer → SybilRank → SybilBelief → SybilWalk → GNN-based):** all of these share the same core assumption, namely that Sybil identities can create unlimited accounts and unlimited edges *among themselves*, but struggle to acquire edges *to* real, established users, because real users are reluctant to accept unknown connections. This produces a sparse cut in the social graph between the Sybil region and the honest region. SybilGuard/SybilLimit/SybilInfer use specially engineered random walks to exploit this; SumUp uses max-flow; SybilRank runs a random walk seeded from a small set of manually labeled trusted (benign) nodes and ranks all other nodes by their landing probability, which is what let it scale to a real production social network (Tuenti). Known limitations reported in the literature: SybilRank doesn't tolerate label noise well and can't incorporate negative (confirmed-Sybil) labels, only positive seeds; more recent work (SybilBelief, SybilWalk, GNN-based detectors) tries to fix this by using semi-supervised or learned representations instead of pure random-walk heuristics. (arxiv.org/pdf/1106.5321, people.duke.edu SybilWalk paper, arxiv.org/pdf/1312.5035, arxiv.org/pdf/2409.08631)

**What production trust-and-safety systems actually layer on top (and lean on more heavily than pure graph theory):**
- **Device/IP fingerprinting and clustering.** Because the physical device is harder to rotate than an IP or account, fraud-detection vendors report collapsing accounts that rotate through many IPs but share a device fingerprint into a single operator cluster, which is described as the dominant practical signal for catching coordinated fake-account/fake-review/fraud-ring operations (Sardine, TrustDecision, Carousel/oncarousel.com sources).
- **Velocity limits.** Rate-limiting how many accounts/attestations can originate from one device/IP/payment instrument in a time window is described across the fraud-tech literature as a first-line, cheap, high-signal control layered before graph analysis runs.
- **Reciprocity caps.** Explicitly capping or down-weighting mutual/reciprocal attestation pairs is a direct countermeasure to the LinkedIn failure mode. If A endorses B and B endorses A within a short window, or if a user's endorsement graph is unusually reciprocal relative to the network baseline, that pair's evidentiary weight should be discounted.
- **Verified-anchor weighting.** Trust-propagation approaches (SybilRank's own design) work by seeding trust from a small set of *verified* honest nodes and propagating outward, meaning a peer attestation from an identity-verified, tenured account should carry structurally more weight than one from a brand-new account, independent of content.

### Assessment of the internal doc's approach (as described, not directly inspected)

I could not locate the internal document referenced in the task ("device/IP collusion exclusion and reciprocal-ring caps for a hospitality reputation graph") anywhere in this repository (`research/` was empty prior to this file; no other doc in the repo mentions hospitality). The assessment below is therefore of the *approach as characterized in the task prompt*, not a review of an inspected artifact, so flag this to whoever wrote the internal doc so the file can be added to this repo if it needs a direct review.

Taking the described approach at face value: device/IP exclusion + reciprocal-ring caps is a reasonable and evidence-backed *first line of defense*, since it matches what production fraud systems actually run, and reciprocity capping directly targets the documented LinkedIn failure mode. Generalizability concerns for porting it from a hospitality reputation graph (presumably review-style, single-sided, transaction-anchored, e.g., a guest stayed at a listing, which gives a hard transactional edge to check attestations against) to a work ledger:

- **Hospitality reviews are usually anchored to a verifiable transaction** (a booking, a stay, a payment). A peer attestation on a work ledger ("I worked with this person," "this person is a great engineer") frequently has *no* equivalent hard transactional anchor unless the ledger requires attestors to also have a verified employment/engagement record with the subject. Without that anchor, device/IP clustering only catches unsophisticated collusion (same household, same device). It does nothing against a genuine coworker who is paid or coerced to attest, which requires the transactional/behavioral signals described in Section 2 and Section 5, not graph structure.
- **Device/IP clustering degrades against distributed, low-cost labor markets for fake attestations** (paid-review-farm dynamics, see Section 2) where each fake attestor uses a distinct device and residential IP, precisely because review farms exist to defeat exactly this control (capitaloneshopping.com fake review statistics; arxiv.org/pdf/2410.17507 on network-structure detection of fake-review buyers on Amazon shows the effective countermeasure had to move to *product/reviewer network structure*, not device fingerprinting, once farms adapted).
- **Reciprocal-ring caps generalize well** structurally (the LinkedIn failure mode is domain-agnostic) but need calibration: in a small, dense professional network (e.g., a niche trade or a small city's hospitality workforce), organic reciprocal attestation is more common than in a large diffuse network, so a naive global cap risks false positives against legitimately tight-knit peer groups. This is a tuning problem, not a fundamental flaw.
- **Net assessment:** treat the device/IP + reciprocity-cap layer as necessary but not sufficient. It should be one layer in a stack that also includes (a) transactional anchoring of attestation claims to verifiable engagement records where possible, and (b) verified-anchor trust weighting (SybilRank-style) so that attestations from long-tenured, verified peers count for more than attestations from young accounts, which the reciprocity cap alone does not provide.

---

## 2. Attesting-party-side fraud

This is the least-examined layer in the founding docs per the task brief, and the evidence suggests it deserves more weight than peer-Sybil attacks, not less, because party attestation is designed into the system as the *high-trust* tier, making it the highest-value target.

### Diploma mills / fake training verticals

Accreditation itself is gameable at the institutional level, not just the individual credential level: "accreditation mills" are dubious bodies that sell bogus certification of institutional quality specifically so that diploma mills underneath them can claim to be "accredited" (chea.org fact sheet; learnworkecosystemlibrary.com). This means a naive "is this training provider accredited" check is insufficient, since an attacker can stand up both the fake school *and* a fake accreditor. The countermeasure the credential-evaluation industry actually uses is a **positive, closed registry**: confirm the accrediting body itself appears on a recognized federal/national list (in the U.S., the Department of Education's DAPIP database or CHEA's own recognized-accreditor list), not merely that the training provider claims accreditation from *some* body. NACES-member evaluators (e.g., WES) exist specifically because individual employers/platforms lack the capacity to verify foreign or novel credentials at this level, and they use dedicated diploma-mill guides as part of standard practice (cimea.it FRAUDOC; chea.org). Additional structural red flags used in practice: PO-box/virtual addresses, self-referential "verification services" run by the same entity issuing the credential (verifyed.org, goodhire.com).

**Implication for the ledger:** party-attestation status ("registered employer/training vertical") cannot be a one-time registration check. It needs (a) a closed allowlist of recognized accreditors/verification bodies rather than accepting self-claimed accreditation, and (b) ongoing re-verification, because accreditation-mill schemes are specifically designed to survive a single point-in-time check.

### Employer collusion, inflation and retaliation

Two distinct failure modes, evidenced differently:

- **Inflation (employer or attestor colluding to inflate a worker's record):** this is structurally the same problem as paid review farms, ported to a single high-trust attester instead of many peers. The review-farm literature is directly transferable: fake review brokers run organized networks (bots or paid humans) producing reviews at industrial scale. One documented case involved $250,000 spent on fake reviews driving over $5M in sales, and during the pandemic an estimated 4.5 million retailers purchased fake reviews via closed Facebook groups (capitaloneshopping.com; investigatetv.com). The detection research that actually worked against this at scale moved away from content/text analysis (which fake-review generators can now defeat with LLMs) toward **network structure**: Amazon-focused research found that products which buy fake reviews are *highly clustered in the product-reviewer bipartite graph*, and that network features (not textual features) were the most predictive signal (arxiv.org/pdf/2410.17507). This is the same graph-theoretic move as Section 1's Sybil detection, applied to the employer/party layer: look for statistically anomalous attestation clusters (one employer whose attestations are disproportionately positive/dense relative to comparable employers, or whose attested workers all show suspiciously correlated onward outcomes), not just individual claim content.
- **Retaliation (employer attesting badly to punish a worker):** see Section 5, which is a well-litigated area of U.S. employment law (qualified privilege, defamation, and retaliation-specific statutes), which gives usable legal and design precedent that the review-farm literature doesn't.

**Confidence note:** the review-farm evidence is strong (peer-reviewed network-detection paper + documented case sizes) but concerns retail products, not employer-worker attestations specifically. I found no direct empirical study of *employer collusion in structured work-attestation systems* because no system like this ledger currently exists at scale. The transfer from review-farm dynamics to work attestation is a reasoned analogy, not a directly measured phenomenon.

---

## 3. Fresh-start attacks (abandon-and-resignup)

This is the sharpest tension in the founding docs' design as described: universal self-signup is explicitly a goal, but every mature reputation/credit system studied here deters re-entry-under-new-identity by adding friction at the *identity* layer, not the reputation layer.

- **eBay** deliberately gives sellers a rolling fresh start on the *feedback score* itself (12-month lookback, feedback can be removed/withdrawn under specific conditions), but this fresh-start mechanism operates *within* a persistent account identity, not by re-registering. eBay does not solve the "register a new account to escape a bad record" problem via feedback design; it relies on account-level enforcement (suspensions tied to verified payment/identity details) to prevent someone banned under one identity from simply returning under another (cs.stanford.edu; ebay.com developer docs; community.ebay.com threads on feedback windows).
- **Airbnb** requires identity verification (government ID + biometric selfie match) for every host and every booking guest in an increasing number of markets, explicitly framed as a fraud/trust control, and revokes the "Identity Verified" badge if a user changes legal name or removes ID, forcing re-verification rather than allowing silent identity laundering (cnbc.com; airbnb.com help center; authme.com).
- **Credit bureaus** anchor records to a government-issued SSN-equivalent identifier precisely so that a consumer with bad history cannot simply "resignup" under a new file; the entire FCRA dispute apparatus (30-day investigation window, right to add a statement of dispute, CFPB enforcement) exists *because* the identity anchor is fixed and consumers instead need a due-process mechanism to fix errors within it (consumerfinance.gov; NCLC dispute guide). The credit system's answer to "the record is wrong or unfair" is correction rights, not identity replacement.

**Pattern across all three:** none of these systems solve fresh-start abuse by making the reputation layer forgiving to new accounts (that would invite exactly the abandon-and-resignup attack); they solve it by making the *identity* layer sticky (verified ID, government identifier, payment-instrument linkage) and making the *reputation* layer correctable through dispute/appeal rights instead. Applied to this ledger: "universal self-signup" as a growth/access goal and "hard identity anchoring to prevent re-entry" are not actually in tension if the design separates them correctly. Self-signup can stay low-friction for *account creation*, while a persistent identity anchor (ideally verified once, reusable across resignups, tied to something costlier to fabricate than an email address: government ID, phone+carrier verification, payment instrument, or a web-of-trust anchor from an already-verified party) prevents a bad record from being shed by re-registering. The risk is if the founding docs conflate "low friction to start" with "no persistent identity anchor." Those are separable design choices, and the evidence says the second one is load-bearing for every comparable system that has survived contact with real fraud.

**Confidence:** high on the pattern (three independent, well-documented systems converge on the same design), moderate on the specific mechanism recommendation (verified-identity anchor decoupled from signup friction) since that's a reasoned synthesis rather than something explicitly stated as a design principle in any one source.

---

## 4. Gaming of scored metrics (Goodhart effects)

This is the best-evidenced section in this memo, since there is a peer-reviewed, causal result directly on point.

- **LinkedIn endorsements** (Section 1) show the general pattern: a visible, cheap, gateable metric becomes a reciprocity/social-obligation game rather than a competence signal, to the point that recruiters are reported to discount them entirely and weight only endorsements from confirmed direct collaborators (researchgate.net "LinkedIn Endorsement Game"; recruitingblogs.com).
- **Gig-platform star ratings and racial bias:** a study published in *Nature* (Rice Business / Yale / University of Toronto, covered by Rice Business and HBR) found customers rate minority gig workers measurably lower under 5-star systems (4.72 vs 4.79 in the cited coverage) and that this translates into materially lower income for those workers via both fewer allocated jobs and lower tips. The critical causal finding: when a platform switched from 5-star ratings to a binary thumbs-up/thumbs-down scale, **the racial earnings gap for new workers was eliminated entirely** (business.rice.edu; hbr.org, March 2025). This is a rare case of an actual A/B-style natural experiment showing that the *granularity* of the exposed metric, not just its existence, determines how much room there is for biased/gamed inputs to compound into real economic outcomes.
- **Uber's rating system more broadly** has been analyzed (Rosenblat, "Discriminating Tastes," *Policy & Internet* 2017) as a mechanism of algorithmic worker discipline: it converts subjective, often bias-laden customer judgments into a numeric score used for deactivation decisions, with drivers facing deactivation risk below roughly 4.6/5, a threshold high enough that ordinary variance plus bias, not just genuine poor service, can end someone's ability to work the platform (ridester.com; researchgate.net Rosenblat paper).
- **Credit score gaming through piggybacking/tradeline rental:** a legal-but-adversarial industry (Tradeline Supply Co. and similar) sells "authorized user" slots on strangers' well-aged credit cards specifically to inflate a FICO score without any underlying credit behavior change. FICO's response was a defensive patch, not a ban: FICO 8 was explicitly re-engineered with "internal logic designed to reduce the impact of accounts that pattern-match commercial piggybacking" (forbes.com; experian.com; federalreserve.gov working paper 2010-23 "Credit Where None Is Due?"). This is a direct precedent for *composite-score gaming as a commercial industry* once a score gates access to something valuable (credit), and the same economic pressure will exist once a ledger score gates access to work.

**Design implication (synthesis, not directly sourced from any one citation):** the ledger should treat any single composite "trust score" as an attack surface that will attract exactly the piggybacking/tradeline-style commercial gaming FICO had to patch against, and exactly the reciprocity gaming LinkedIn suffered. The Nature RCT gives a concrete, evidence-backed design lever: coarser, structural exposure (binary/tiered signals, provenance-graded claims kept separately visible rather than collapsed into one number, tenure and dispute-history shown as distinct fields) reduces both the surface area for gaming and the surface area for bias amplification, without necessarily reducing the information available to a hiring/routing consumer who can still weight the underlying components themselves.

---

## 5. Retaliation and coercion

This is the section with the most direct, applicable *legal* precedent, because U.S. employment law has litigated exactly this tension (employer speech about a worker, worker's interest in accurate record, employer's fear of liability) for decades.

- **The core doctrine:** an employer giving a reference is protected by **qualified privilege**, meaning even a false, defamatory statement doesn't create liability unless made with malice. But that privilege has real limits: **retaliatory** references (given because a worker engaged in protected activity: filed a discrimination complaint, reported safety violations, whistleblew) are independently unlawful as retaliation, separate from defamation law, and **untruthful** statements fall outside the privilege regardless of motive (findlaw.com; justiceatwork.com; legalaidatwork.org).
- **The observed equilibrium this produces:** because employers are risk-averse about defamation exposure even though the privilege mostly protects them, many adopt a "name, rank, dates only" policy, confirming employment dates and title and refusing to say anything substantive, positive or negative (ere.net "What's Wrong With Reference Checks"; wolterskluwer.com). This is explicitly documented as a **chilling effect with a real cost**: it starves the hiring market of genuine signal, which increases reliance on negligent-hiring liability exposure for the *next* employer and, per drjohnsullivan.com/ere.net critiques, is widely regarded by HR researchers as a broken equilibrium, not a fair outcome for accurate attestation, just the risk-minimizing one for the attester.
- **What this means for a party-attestation system:** if signed employer attestations carry real evidentiary weight and are worker-visible, expect the same chilling dynamic to reproduce itself unless the ledger's design explicitly changes attester incentives, e.g., by giving attesting parties a liability shield analogous to qualified privilege *conditioned on* good-faith, non-retaliatory, factually-grounded attestation (mirroring the legal doctrine that already exists), and by building a formal, low-friction dispute/correction path so workers don't need litigation to contest a bad attestation (mirroring the FCRA dispute mechanism in Section 3, which is the one comparably mature system this research surfaced for handling exactly this problem at scale).
- **Bias in references independent of retaliation:** reference-check discrimination research also flags that even good-faith references are noisy and can encode bias from a single rater; the standard practitioner mitigation is requiring multiple independent references rather than trusting any single attestation (crosschq.com), directly analogous to the ledger's own multi-attestor / peer + party layering, which is a point in favor of the general architecture (not relying on one attester) even before considering fraud.

**Confidence:** the legal doctrine (qualified privilege, retaliation liability, defamation exceptions) is well-established and multiply sourced from legal-explainer sites; I did not find peer-reviewed empirical measurement of *how often* retaliation actually occurs or how large the chilling effect is in dollar/outcome terms. The "name, rank, dates only" equilibrium is well-documented as an industry norm but not quantified.

---

## 6. Bottom line

### Threat model summary (attacker × asset × mitigation)

| Attacker | Asset targeted | Attack | Evidence-backed mitigation |
|---|---|---|---|
| Individual worker (or ring) | Peer-attestation layer | Reciprocal endorsement rings, reference farming | Reciprocity caps, device/IP clustering, velocity limits, trust-propagation weighting from verified anchors (SybilRank lineage) |
| Individual worker + commercial fraud service | Party-attestation layer (fake employer/training vertical) | Diploma mills, fake accreditation bodies, fabricated employment history w/ VoIP-staffed fake company | Closed allowlist of recognized accreditors (DAPIP/CHEA-style registry, not self-claimed), ongoing re-verification not one-time check, cross-check against payroll/registration records |
| Attesting party (employer, training vertical) | Worker's record (inflate) | Paid attestation inflation, review-farm-style collusion | Network-structure anomaly detection on the attester/subject bipartite graph (cluster of anomalously positive attestations), not content analysis alone |
| Attesting party (employer) | Worker's record (deflate / retaliate) | Retaliatory bad attestation for protected activity or personal conflict | Qualified-privilege-style liability shield conditioned on good faith, formal low-friction dispute/correction path (FCRA-style), multi-attestor requirement so no single party controls the record |
| Worker with a bad record | Identity layer | Abandon account, re-signup clean ("fresh start" abuse) | Persistent, verified identity anchor decoupled from signup friction (government ID, phone/carrier, payment instrument, or verified web-of-trust) so self-signup stays low-friction while identity persistence does the enforcement |
| Any actor optimizing for the visible score | Scored/gated metric itself | Goodharting: tradeline-style piggybacking, endorsement reciprocity, rating-threshold gaming | Expose coarse/structural signals, not one composite score; keep provenance grades separately visible; avoid granular 1-5-star-style scores shown to gatekeepers (Nature RCT: binary scale eliminated a 9% racial earnings gap vs 5-star) |
| Worker | Own dispute process | Gaming disputes to erase true negative attestations | Mirror FCRA structure: investigation window, right to add a statement rather than unilateral deletion, distinguish "disputed" from "removed" |

### Design constraints (with evidence)

1. **Do not collapse the record into one composite score exposed to hiring/routing consumers.** The Nature RCT (5-star → thumbs-up/down eliminating a 9% racial earnings gap) is direct causal evidence that score granularity itself determines gaming/bias surface area, independent of the underlying claims.
2. **Weight attestations by attester trust, not just claim content.** SybilRank's core design insight, propagate trust from a small verified seed set, is directly transferable: a peer attestation from a long-tenured, identity-verified account should count for more than one from a fresh account, and this needs to be a first-class scoring input, not an afterthought.
3. **Treat party-attestation status as a maintained allowlist, not a one-time registration.** The diploma-mill/accreditation-mill precedent shows attackers will fake the accreditor, not just the credential, once the credential layer is hardened. Requires periodic re-verification against a closed, externally-recognized registry.
4. **Build network-structure anomaly detection on the attester side, not just the peer side.** The review-farm literature (Amazon fake-review-buyer detection via bipartite network clustering) shows content-based fraud detection is losing ground to LLM-generated fakes; structural/statistical anomaly detection on attestation clusters is the more durable approach and should apply to employer/vertical attesters, who are currently the least-scrutinized tier in the founding docs per the task brief.
5. **Decouple signup friction from identity persistence.** Universal self-signup and fresh-start resistance are not actually in tension if the design separates "how easy is it to create an account" from "how easy is it to shed a bad record by creating a new one." Every comparable system (eBay, Airbnb, credit bureaus) solves the latter with a sticky verified-identity anchor, not with reputation-layer forgiveness.
6. **Give attesting parties a conditional liability shield, modeled on employment law's qualified privilege.** Without it, expect the same "name, rank, dates only" chilling equilibrium that already exists in reference-checking. Parties will under-attest defensively, and the worker-visible record will be systematically thinner and less useful than the design assumes, especially for negative-but-true claims.
7. **Build a formal dispute/correction mechanism before launch, not after.** FCRA's structure (investigation window, right to add a statement of dispute, distinction between "corrected" and "disputed but unresolved") is the one mature, at-scale precedent this research found for handling exactly the tension between worker-editable self-asserted claims and immutable-feeling party attestations, and it exists precisely because credit bureaus learned this the hard way through litigation and regulation.
8. **Require multi-attestor corroboration before a claim gets high evidentiary weight, especially for negative claims.** Reference-check bias research explicitly recommends multiple independent references to dilute single-rater bias/retaliation risk; this also raises the cost of both inflation collusion (need multiple colluding parties) and retaliation (one bad actor can't unilaterally tank a record) at the same time, a rare case where the anti-fraud and anti-bias mitigations are the same design move.

---

## Sources

**Sybil / graph-based detection:**
- [Uncovering Social Network Sybils in the Wild](https://arxiv.org/pdf/1106.5321)
- [SybilBelief: A Semi-supervised Learning Approach for Structure-based Sybil Detection](https://arxiv.org/pdf/1312.5035)
- [Random Walk based Fake Account Detection in Online Social Networks (SybilWalk)](https://people.duke.edu/~zg70/papers/sybilwalk.pdf)
- [Structure-based Sybil Detection in Social Networks via Local Rule-based Learning](https://arxiv.org/pdf/1803.04321)
- [Sybil Detection using Graph Neural Networks](https://arxiv.org/pdf/2409.08631)
- [SybilRadar: A Graph-Structure Based Framework for Sybil Detection in Online Social Networks](https://link.springer.com/chapter/10.1007/978-3-319-33630-5_13)

**LinkedIn endorsements / reciprocity gaming:**
- ["Endorse me back" — Should recruiters be considering endorsements when using LinkedIn to recruit candidates?](https://researchgate.net/publication/341580426_Endorse_me_back_Should_recruiters_be_considering_endorsements_when_using_LinkedIn_to_recruit_candidates)
- [The LinkedIn Endorsement Game: Why and How Professionals Attribute Skills to Others](https://www.researchgate.net/publication/310811088_The_LinkedIn_Endorsement_Game_Why_and_How_Professionals_Attribute_Skills_to_Others)
- [The New LinkedIn Endorsements: Are We Being Gamed?](https://www.pammarketingnut.com/2012/11/the-new-linkedin-endorsements-are-we-being-gamed-linkedin/)
- [How to Spot a Fake LinkedIn Recommendation](https://recruitingblogs.com/profiles/blogs/how-to-spot-a-fake-linkedin-recommendation)

**Diploma mills / accreditation fraud:**
- [FRAUDOC - CIMEA](https://www.cimea.it/EN/pagina-fraudoc)
- [Important Questions About Degree Mills — CHEA](https://www.chea.org/important-questions-about-degree-mills)
- [Important Questions about Diploma Mills and Accreditation Mills (PDF) — CHEA](https://www.chea.org/sites/default/files/other-content/Fact-Sheet-Diploma-Mills-and-Accreditation-Mills.pdf)
- [Fraudulent Credentials — Learn & Work Ecosystem Library](https://learnworkecosystemlibrary.com/topics/fraudulent-credentials/)
- [Diploma Mill List: How to Check If a School Is Fake — VerifyED](https://verifyed.org/guides/diploma-mill-list-2026)
- [Diploma Mills: How to Spot Fake Degrees on Resumes — GoodHire](https://www.goodhire.com/resources/articles/what-are-diploma-mills-do-they-lead-to-resume-lies/)

**Review farms / fake reviews:**
- [Detecting fake review buyers using network structure: Direct evidence from Amazon](https://arxiv.org/pdf/2410.17507)
- [Fake Review Detection: Classification and Analysis of Real and Pseudo Reviews](https://www2.cs.uh.edu/~arjun/tr/UIC-CS-TR-yelp-spam.pdf)
- [Five Star Fakes: Fake online reviews cheating businesses and consumers](https://www.investigatetv.com/2022/06/20/five-star-fakes-fake-online-reviews-cheating-businesses-consumers/)
- [Fake Review Statistics — Capital One Shopping Research](https://capitaloneshopping.com/research/fake-review-statistics/)

**Fresh-start / identity anchoring:**
- [Reputation Systems: eBay — Stanford CS181](https://cs.stanford.edu/people/eroberts/courses/cs181/projects/2010-11/PsychologyOfTrust/rep2.html)
- [eBay Trading API — Feedback](https://developer.ebay.com/api-docs/user-guides/static/trading-user-guide/feedback.html)
- [Airbnb will soon push all vacationers and hosts to verify identity — CNBC](https://www.cnbc.com/2023/02/03/airbnb-will-soon-push-all-vacationers-and-hosts-to-verify-identity.html)
- [Verifying your identity on Airbnb — Airbnb Help Center](https://www.airbnb.com/help/article/1237)
- [How Airbnb's New Verification Policy Battles Housing Fraud — Authme](https://authme.com/blog/how-airbnbs-new-verification-policy-battles-housing-fraud/)

**Goodharting / scored metrics:**
- [Research: How Gig Platforms Can Mitigate Racial Bias in Ratings — HBR](https://hbr.org/2025/03/research-how-gig-platforms-can-mitigate-racial-bias-in-ratings)
- [Racial earning gap in gig work eliminated through new rating system — Rice Business](https://business.rice.edu/news/racial-earning-gap-gig-work-eliminated-through-new-rating-system)
- [Thumbs Up: Fixing the Bias in Gig Work Ratings — Rice Business Wisdom](https://business.rice.edu/wisdom/thumbs-fixing-bias-gig-worker-ratings)
- [Discriminating Tastes: Uber's Customer Ratings as Vehicles for Workplace Discrimination — Rosenblat, Policy & Internet 2017](https://onlinelibrary.wiley.com/doi/10.1002/poi3.153)
- [Uber Driver Ratings: How They Work and How To Improve — Ridester](https://www.ridester.com/uber-driver-ratings/)
- [Credit Where None Is Due? Authorized User Account Status — Federal Reserve working paper 2010-23](https://www.federalreserve.gov/pubs/feds/2010/201023/201023pap.pdf)
- [How Credit Card Piggybacking Works — Forbes Advisor](https://www.forbes.com/advisor/credit-cards/how-credit-card-piggybacking-works/)
- [What Is Credit Card Piggybacking? — Experian](https://www.experian.com/blogs/ask-experian/what-is-piggybacking-credit/)

**Retaliation / coercion / dispute mechanisms:**
- [Can a Former Employer Give a Bad Reference? — FindLaw](https://www.findlaw.com/employment/hiring-process/is-a-former-employer-s-bad-reference-illegal.html)
- [Is Defamation Workplace Retaliation? — Justice at Work](https://www.justiceatwork.com/is-defamation-ever-considered-retaliation/)
- [Workplace Defamation — Legal Aid at Work](https://legalaidatwork.org/factsheet/workplace-defamation/)
- [What's Wrong With Reference Checks (Part 1) — ERE](https://ere.net/whats-wrong-with-reference-checks-part-1)
- [Balancing Requirements and Restrictions When Providing Employment References — Wolters Kluwer](https://www.wolterskluwer.com/en/expert-insights/balancing-requirements-and-restrictions-when-providing-employment-references)
- [Reference Check Discrimination: How to Ensure Fair and Bias-Free Hiring — Crosschq](https://www.crosschq.com/blog/reference-check-discrimination-how-to-ensure-fair-and-bias-free-hiring)
- [What if I disagree with the results of my credit report dispute? — CFPB](https://www.consumerfinance.gov/ask-cfpb/what-if-i-disagree-with-the-results-of-my-credit-report-dispute-en-1327/)
- [Disputing Errors in a Credit Report — National Consumer Law Center (PDF)](https://www.nclc.org/wp-content/uploads/2022/09/cf_disputing-errors-in-a-credit-report.pdf)

**Production fraud detection (device/IP/velocity):**
- [Device Fingerprinting for Fraud and ATO Prevention — Sardine](https://www.sardine.ai/blog/device-fingerprinting)
- [Fraud Velocity Checks: Catching Rings Before App Three — Carousel](https://oncarousel.com/blog/velocity-signals-fraud-rings/)
- [Identity Fraud Protection with Device Fingerprinting — TrustDecision](https://trustdecision.com/articles/protecting-digital-identities-with-device-fingerprinting-solution-with-use-case)

**Reference check fraud (candidate-side):**
- [Reference Check Fraud: 7 Schemes Candidates Use to Fake Professional References](https://gcheck.com/blog/reference-check-fraud/)
- [The Rise of Fake Employment References and How to Address Them — Vervoe](https://vervoe.com/the-rise-of-fake-employment-references-and-how-to-address-them/)
