# Regulatory perimeter: global worker identity + work ledger

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Status:** Research memo, not legal advice. Not counsel-reviewed. Confidence
levels are marked inline. Written 2026-08-17.

**Scope:** FCRA (US federal + California overlay), GDPR (EU), Data Privacy Act
of 2012 (Philippines), cross-border transfer, and the schema/architecture
constraints that follow.

---

## TLDR

**1. In the United States, this product is a consumer reporting agency. Not
"at risk of being one." It is one, on the facts as described.** The company will,
for money, regularly assemble and evaluate information on workers bearing on
their character, general reputation and personal characteristics, and furnish
it to third parties who use it to decide hiring, promotion, retention and task
allocation. That is the entire statutory definition (15 U.S.C. § 1681a(f), (d),
(h)). Confidence: high.

**2. The "global recruiter / talent infrastructure" positioning does not
survive contact with § 1681a(o), and the existing Grain memo overstates how
much that exclusion can carry.** The memo correctly recites the five (o)
conditions but does not draw out that (o)(1) limits the exclusion to
communications that would be **investigative** consumer reports, meaning
character information "obtained through personal interviews." Signed employer
attestations delivered by API, assessment scores, verified training records and
task-outcome data are not obtained through personal interviews, so (o) never
reaches them at all. Worse, (o)(4) requires that the communication "is not used
by any person for any purpose other than" procuring that employee for that
employer, which forecloses the core product thesis of a durable, reusable,
multi-reader record. And (o)(2) requires the recipient be a *prospective*
employer, which excludes every partner company reading the prior packet about a
worker it already employs. Confidence: high on the statutory reading; the Grain
memo's position remains defensible **for Grain's placement business** and is not
transferable to this ledger.

**3. Contested, and the most important thing to internalize: the
worker-consented, worker-visible, worker-permissioned design does not weaken the
CRA case. It strengthens it.** The FCRA has no consent exemption. "Written
instructions of the consumer" is a *permissible purpose* under § 1681b(a)(2),
a provision that presupposes you are already a CRA. Full worker visibility into
the raw record is § 1681g file disclosure. Party-level grant/revoke is
§ 1681e(a) permissible-purpose control. The design is voluntary pre-compliance
with CRA duties, and a regulator or plaintiff will read it that way. Confidence:
high on the law; the characterization is my inference, but I can find no
authority for a consumer-permissioning escape hatch and the CFPB's 2024 position
went the other way.

**4. Two design commitments are directly illegal in the US as stated.**
"Frozen once verified, disputed by annotation, never deletion" collides with
§ 1681i(a)(5)(A), which requires a CRA to "promptly delete... or modify" any
item found inaccurate, incomplete or unverifiable after a 30-day
reinvestigation. Annotation (§ 1681i(b)-(c)) is what you do *after* a
reinvestigation fails to resolve a dispute, not instead of one. Separately,
"permanent record" collides with § 1681c(a)(5): no CRA may report "any other
adverse item of information" older than seven years, except for jobs paying
$75,000+ (§ 1681c(b)(3)). Append-only *storage* is fine. Append-only *reporting*
is not. Confidence: high on § 1681i; medium-high on § 1681c(a)(5) reaching
non-credit adverse employment items, which is less litigated.

**5. California is worse than federal and cannot be designed around the same
way.** ICRAA (Civ. Code § 1786 et seq.) covers character and reputation
information obtained "through any means," not only personal interviews, so the
one carve-out that gives § 1681a(o) any purchase federally does not exist in
California. *Connor v. First Student*, 5 Cal.5th 1026 (2018), confirms employers
and agencies must satisfy ICRAA even where FCRA/CCRAA overlap. Statutory damages
run $10,000 per violation (§ 1786.50). Confidence: high.

**6. Under GDPR, an append-only ledger is survivable but only in a specific
architecture: personal data off-ledger and erasable, with the immutable chain
holding only commitments/hashes.** This is now the EDPB's explicit
recommendation in Guidelines 02/2025 on blockchain (v2.0 adopted 7 July 2026),
which also states that encrypted and hashed data remain personal data, so
crypto-shredding alone is *not* a blessed substitute for erasure, though it is
widely used and is strong risk mitigation. GDPR Art. 16's "supplementary
statement" language is genuine textual support for the annotation model, but
only for *completing incomplete* data; Art. 16's first sentence still requires
actual rectification of inaccurate data. Confidence: high on the EDPB guidance;
medium on how aggressively DPAs will police crypto-shredding, which is unsettled.

**7. The GDPR sleeper is Article 22, not Article 17.** Under *SCHUFA*
(C-634/21, 7 Dec 2023), if you produce a score or grade and employers draw
strongly on it, **you**, not the employer, are performing the automated
individual decision. That flips a pile of obligations onto the ledger operator:
an Art. 22(2) exception plus Art. 22(3) safeguards (human intervention, right to
contest, right to express a point of view). This is the exact mirror of the US
"algorithmic score" problem and it means provenance grades and any derived
trust/reputation score are the most regulated objects in the schema, not the
least. Confidence: high.

**8. Erasure risk under GDPR is real but narrower than usually assumed, and the
right lawful basis is legitimate interests, not consent.** Consent is unreliable
in an employment-adjacent power imbalance (Art. 29 WP Opinion 2/2017). On
Art. 6(1)(f), the live exposure is the Art. 21(1) objection: you may refuse only
on "compelling legitimate grounds," which feeds Art. 17(1)(c). Art. 17(3)(e)
(establishment/exercise/defence of legal claims) is the most defensible retention
hook for dispute-relevant records, and it is narrower than "we might need this
someday." Confidence: high.

**9. Data portability is a weaker obligation than it looks, and mostly runs the
wrong way.** Art. 20 applies only to data "provided by" the subject, only where
the basis is consent or contract. Self-asserted claims: portable. Employer
attestations authored by third parties and any derived score: not portable (WP29
excludes inferred/derived data). Art. 20(4) also protects the attesting
employer's and peer referee's rights. If you build worker-controlled export
anyway, and you should because it is the product, treat it as a product commitment,
not a compliance one. Confidence: high.

**10. Philippines: the DPA reaches you from the first Philippine worker; its
erasure right looks narrower than GDPR's in the statute but the IRR makes it
broader in the one way that matters; and criminal liability runs to officers
personally.** IRR Sec. 4 makes "relates to personal data about a Philippine
citizen or resident" a stand-alone jurisdictional hook. IRR Sec. 34(e)(e) adds an
erasure trigger with no GDPR equivalent: "private information that is
**prejudicial to the data subject**", which describes an adverse employer
attestation almost exactly. Offenses under Secs. 25–32 carry imprisonment, Sec. 34
reaches responsible officers, aliens are deported after serving sentence, and
Sec. 35 auto-escalates to maximum penalties above 100 affected persons. Two
findings cut *for* the design: Sec. 16(d) **requires** that corrected and
retracted versions both stay accessible and be delivered together to recipients,
which is statutory endorsement of versioned correction, and there is **no adequacy regime
or transfer permit**, so US hosting is lawful on contractual accountability alone.
The controlling constraint is that education records, government IDs, date of
birth and criminal-proceeding data are all **sensitive personal information**
under Sec. 3(l), for which legitimate interest is unavailable and revocable
consent is the only basis. Confidence: high on statutory and IRR text; NPC
circulars verified through secondary sources; §3.9 on blacklisting is weak and
flagged.

**10a. There is no Philippine FCRA and no safe harbor to join.** RA 9510 is
credit-only. In the US the FCRA is burdensome but confers a recognized lawful
status; the Philippines offers no accreditation, no licensing, and no statutory
permission structure for employment reputation data. That asymmetry should inform
sequencing of which market gets built first.

**11. A single physical global ledger is foreclosed. Regional partition with
per-region key custody is effectively forced.** EU→US rests on the EU-US Data
Privacy Framework (Decision 2023/1795), which survived *Latombe* at the General
Court on 3 Sept 2025 but is on appeal to the CJEU (C-703/25 P, pending). Nobody
should build a schema whose legality depends on an adequacy decision under
active appeal. The Philippines has no EU adequacy decision, so EU personal data
reaching Philippine ops staff needs SCCs plus a transfer impact assessment,
and *read access by a PH-based operator is itself a transfer*. Confidence: high.

**12. Net: the regulation does not kill the product. It kills three specific
design commitments: never-delete, freeze-on-verification, and one global
table, and it forces a dispute/reinvestigation engine to be a first-class
subsystem rather than a feature.** The single highest-leverage architectural
decision is separating the *immutable evidence of an event* from the *reportable
personal-data payload of that event*, so the first can be permanent and the
second can be corrected, suppressed, aged out, or destroyed independently.

---

## 1. FCRA (United States)

### 1.1 The definition is met, and self-labeling is irrelevant

15 U.S.C. § 1681a(f) defines a consumer reporting agency as any person which,
"for monetary fees, dues, or on a cooperative nonprofit basis, regularly engages
in whole or in part in the practice of assembling or evaluating consumer credit
information or other information on consumers for the purpose of furnishing
consumer reports to third parties, and which uses any means or facility of
interstate commerce for the purpose of preparing or furnishing consumer
reports."

Every element is satisfied by the described design:

- *Monetary fees*: the revenue comes from partner companies and internal
  verticals. Fees need not come from the worker; the worker being free is
  irrelevant.
- *Regularly engages, in whole or in part*: "in part" defeats the argument
  that reporting is incidental to a recruiting business.
- *Assembling or evaluating... other information on consumers*: the ledger
  assembles; provenance grading and any score evaluates.
- *For the purpose of furnishing consumer reports to third parties*: the
  "prior packet" read by partner companies is the report; the partners are the
  third parties.

And the packet is a **consumer report** under § 1681a(d)(1): a communication
"bearing on a consumer's... character, general reputation, personal
characteristics, or mode of living which is used or expected to be used or
collected in whole or in part for the purpose of serving as a factor in
establishing the consumer's eligibility for... employment purposes."
"Employment purposes" is defined at § 1681a(h) as evaluating a consumer "for
employment, promotion, reassignment or retention as an employee", so partner
reads about existing workers are squarely inside, not outside.

**Self-labeling does not help.** The FTC's position, stated in its 2013 business
guidance and enforced in *Spokeo* (2012, $800,000 civil penalty), is that a
disclaimer that you are not a CRA and that data may not be used for FCRA
purposes does not insulate you where you market to HR, recruiting and
background-screening buyers and do not cut off users who use it that way.

**The one case that adds nuance cuts against you here.** *Kidd v. Thomson
Reuters Corp.*, 925 F.3d 99 (2d Cir. 2019), held that CRA status requires a
"particular purpose or subjective intention — namely, of providing it to third
parties for use (actual or expected) in connection with an FCRA-regulated end,
such as employment eligibility." Thomson Reuters escaped because CLEAR was a
general research tool it did not intend for employment screening. That test is
satisfied by this product *by design and by pitch deck*. Do not read *Kidd* as a
defense; it is the articulation of the standard you affirmatively meet.

**Withdrawn but analytically intact:** CFPB Circular 2024-06 (89 Fed. Reg.
88,875, Nov. 12, 2024) addressed precisely this fact pattern, "background
dossiers and algorithmic scores for hiring, promotion, and other employment
decisions", and stated that an entity "could 'assemble' or 'evaluate' consumer
information within the meaning of 'consumer reporting agency' if the entity
collects consumer data in order to train an algorithm that produces scores or
other assessments about workers for employers," and that the first-party
transaction/experience exclusion "by its own terms does not apply to a report
containing information not about transactions or experiences between the
report-maker and the consumer, such as when the report includes algorithmic
scores." The CFPB withdrew this circular on 12 May 2025 as part of a mass
guidance withdrawal (90 Fed. Reg., 12 May 2025). **Withdrawal removes the
agency's stated enforcement posture; it does not change § 1681a(f).** Private
FCRA plaintiffs (§§ 1681n, 1681o, with attorney's fees and class exposure) and
state attorneys general can and will make the identical argument, and NCLC has
published specifically on the continued vitality of the withdrawn documents.
Treat the withdrawal as a change in *enforcement probability*, not in *legal
exposure*. Confidence: high.

### 1.2 The two exclusions that actually do work and their limits

**§ 1681a(d)(2)(A)(i): first-party transactions and experiences.** A report
"containing information solely as to transactions or experiences between the
consumer and the person making the report" is not a consumer report. An internal
vertical that employs a worker and records its own experience of that worker,
for its own use, is outside the FCRA. The exclusion breaks the moment that
experience is pooled into a shared record furnished to a different reader,
because the person making the report is then no longer the party who had the
experience.

**§ 1681a(d)(2)(A)(ii)-(iii): corporate affiliates.** Transaction-and-experience
information moves freely among "persons related by common ownership or affiliated
by corporate control." *Other* information moves among affiliates only with
clear and conspicuous disclosure and a pre-communication opt-out. This is a real
and underused lane: **internal business verticals under common ownership have a
statutory path that external partner companies do not.** It is also a reason to
think hard about whether "internal verticals" and "external partners" should
share one data plane at all. Confidence: high.

### 1.3 § 1681a(o): the employment-agency exclusion, and why it cannot carry this product

The statute, verbatim on the load-bearing points. A communication is excluded if
it is a communication:

> "(1) that, but for subsection (d)(2)(D), would be an **investigative consumer
> report**;
> (2) that is made to a **prospective employer** for the purpose of — (A)
> procuring an employee for the employer; or (B) procuring an opportunity for a
> natural person to work for the employer;
> (3) that is made by a person who regularly performs such procurement;
> (4) that **is not used by any person for any purpose other than** a purpose
> described in subparagraph (A) or (B) of paragraph (2);
> (5) with respect to which — [consent before collection; consent before
> communication; written confirmation of oral consent within 3 business days; no
> EEO-violating inquiries; file disclosure within 5 business days of request]"

Four independent failure modes, in descending order of severity:

**(a) (o)(4) forecloses the product thesis.** The exclusion is conditioned on
the communication not being used by *any person* for *any purpose* other than
procuring that employee for that employer. A persistent, reusable record, read
by many parties over years, informing promotion and task allocation, feeding
scoring and matching, is by construction used for other purposes. This is not a
drafting problem you can consent your way around; it is a per-communication,
absolute limitation. The more the ledger succeeds as a ledger, the less (o) can
possibly apply. Confidence: high. This is the strongest single argument and the
Grain memo does not address it.

**(b) (o)(1) makes the exclusion partial, not global.** § 1681a(e) defines an
investigative consumer report as one in which character/reputation information
"is obtained through personal interviews with neighbors, friends, or associates
of the consumer reported on or with others with whom he is acquainted or who may
have knowledge concerning any such items of information," and expressly excludes
"specific factual information on a consumer's credit record obtained directly
from a creditor... or from a consumer reporting agency." A telephone reference
check is plausibly an investigative consumer report. A signed employer
attestation submitted through an API, a training-program credential, an
assessment score, and structured task-outcome data are not "obtained through
personal interviews" and are therefore ordinary consumer reports that (o) never
touches. Peer references collected by web form are the genuinely uncertain
middle. **Even a perfect (o) argument leaves the structured majority of the
ledger fully FCRA-covered.** Confidence: high on the statutory reading.

**(c) (o)(2) excludes every incumbent-employer read.** "Prospective employer" is
the recipient the exclusion contemplates. Partner companies reading the prior
packet about workers they already employ, for promotion, retention, reassignment
or task allocation, are not prospective employers, and § 1681a(h) puts exactly
those decisions inside "employment purposes." Confidence: high.

**(d) (o) is an exclusion from "consumer report," not from "CRA."** § 1681a(f)
requires only that you regularly furnish consumer reports "in whole or in part."
If any material slice of what you furnish is a consumer report, and per (b) it
is, you are a CRA, and CRA duties attach to your operation, including to the
file that contains the (o)-excluded material.

Note what (o)(5)(C) requires: written disclosure of "the nature and substance of
all information in the consumer's file" within 5 business days of request. The
worker-visibility design satisfies this. But that is the *price* of the
exclusion, not evidence you qualify for it.

**Epistemic caveat, stated plainly: § 1681a(o) is essentially untested in
court.** I found no reported decision construing it. The available authority is
the statutory text plus four 1998 FTC advisory opinions. That cuts both ways:
nobody can tell you the exclusion definitively fails, but it is a bad risk
trade for this product specifically, because (i) the § 1681a(o)(4) and (o)(1)
problems are textual rather than fact-dependent, and (ii) an untested exclusion
relied on in writing is precisely the posture that converts a negligent
violation (§ 1681o, actual damages) into a jury question on willfulness
(§ 1681n, statutory and punitive damages, class-wide).

**FTC boundary guidance.** The FTC's advisory opinions from 1998 mark the line
the Grain memo describes correctly: *Basting* (06-11-98) held the exclusion
unavailable to an employee-screening service that supplied reference and record
checks on candidates the client already had, because it was not procuring
employees or opportunities. *Islinger* (06-09-98) confirmed criminal-record,
education and licensing information furnished by a CRA are consumer reports;
*Lewis* and *Goeke* (June 1998) are companion opinions. These support the memo's
sourcing-vs-screening distinction, which is real, but the distinction only ever
addresses (o)(2) and (o)(3), which are the conditions this product is most
likely to satisfy anyway.

### 1.4 Does worker consent, visibility and permissioning change the analysis?

No, and this deserves to be stated bluntly because the design intuition points
the wrong way.

- **There is no consent exemption in the FCRA.** Consent appears in the statute
  as a *user-side precondition* (§ 1681b(b)(2): standalone written disclosure and
  authorization before an employer procures a report) and as a *permissible
  purpose* (§ 1681b(a)(2): furnishing "in accordance with the written
  instructions of the consumer"). Both provisions are addressed to entities that
  are already CRAs. Relying on § 1681b(a)(2) is an admission of CRA status, not a
  defense against it.
- **Worker visibility is § 1681g.** A CRA must disclose to the consumer, on
  request, all information in the consumer's file and (for employment) the
  identity of recipients over the prior two years (§ 1681g(a)(3)(A)(i)). "Workers
  see their full raw record" is that duty, performed voluntarily.
- **Party-level grant/revoke is § 1681e(a).** A CRA must maintain reasonable
  procedures to limit furnishing to permissible purposes and to verify the
  identity and intended use of each user. Access control is that duty.
- **The CFPB's 2024 rulemaking direction was to *tighten*, not loosen,
  consumer-permissioned sharing**, proposing heightened disclosure and separate
  written authorization for reliance on § 1681b(a)(2). Even the pro-permissioning
  regulatory trend treats permissioning as a permissible purpose within FCRA, not
  as an exit from it.

My inference, flagged as such: a plaintiff's expert will characterize this
architecture as a company that built a CRA, documented that it knew consumers
needed file access and dispute rights, and then declined to register the fact.
The design is good for *substantive* compliance and bad for *jurisdictional*
avoidance. Those are different goals and the product currently conflates them.

### 1.5 Duties if classified as a CRA

The ones that shape schema, in order of architectural impact:

| Duty | Cite | Architectural consequence |
|---|---|---|
| Reasonable procedures for **maximum possible accuracy** | § 1681e(b) | Provenance grading is a partial answer; furnishing unverified self-assertions to employers is the core accuracy exposure |
| **Reinvestigation** within 30 days (+15); "promptly delete... or modify" inaccurate, incomplete or unverifiable items | § 1681i(a)(1)(A), (a)(5)(A) | **Deletion/modification is mandatory. Annotation-only is non-compliant.** |
| **Consumer statement of dispute** (100 words) noted in subsequent reports | § 1681i(b), (c) | This *is* the annotation model, but only post-reinvestigation |
| **Notify prior recipients** of deletion/dispute (employers, 2 years) | § 1681i(d) | Requires a durable log of who read what, and a push-notification path |
| **Obsolescence:** no adverse item older than 7 years (except jobs ≥$75k) | § 1681c(a)(5), (b)(3) | Reportability must be time-scoped independent of storage |

**Note on § 1681c(a)(5), because I want to be precise about my confidence.** The
text, "any other adverse item of information, other than records of convictions
of crimes which antedates the report by more than seven years", is broad on its
face and, read literally, reaches an adverse employer attestation about work
outcomes. Industry practice and virtually all the commentary apply it to
*records* (arrests and other non-convictions, civil judgments, liens,
collections), and I found no caselaw testing it against non-record adverse
employment information such as a performance attestation. The 1998 amendment
removed criminal convictions from the limit entirely, so convictions are
reportable without time limit federally. The § 1681c(b)(3) carve-out is
position-specific, since it applies where the job's annual salary is reasonably
expected to be $75,000 or more. **My read: assume (a)(5) reaches adverse
attestations and build the time-scoping, because the cost of building it is low
and the cost of being wrong is a class action. Confidence in the underlying legal
question: medium-high, not high.**
| **Permissible purpose** verification, user identity, user certification of intended use | § 1681e(a), § 1681b(b)(1) | Partner onboarding must capture certifications, not just API keys |
| **File disclosure** + recipient list + summary of rights | §§ 1681g, 1681h, 1681g(c) | Largely already designed |
| **Public record** information for employment: notify consumer contemporaneously or maintain strict accuracy procedures | § 1681k | Constrains any court/criminal/licensing data ingestion |
| **Adverse action**: pre-adverse notice with report copy + rights summary, then adverse action notice | §§ 1681b(b)(3), 1681m | User duty, but you must supply the artifacts and should enforce it contractually |
| **Furnisher duties** on partner companies and verticals writing attestations | § 1681s-2 | Attesters may not report information known to be inaccurate and must investigate disputes referred by the CRA, which **forces a dispute-routing callback API back to every attester** |
| **Reseller** obligations if repackaging another CRA's report | §§ 1681a(u), 1681e(e) | Relevant if you ingest third-party background data |
| Liability | §§ 1681n, 1681o | Willful: actual damages or $100–$1,000 statutory, punitive damages, fees. Negligent: actual + fees. Class exposure is the real number |

### 1.6 State overlay (do not skip this)

**California ICRAA**, Civ. Code § 1786 et seq., is the binding constraint, not
the FCRA. ICRAA reaches "investigative consumer reports" on character, general
reputation, personal characteristics or mode of living **obtained through any
means**. The personal-interview limitation that narrows § 1681a(e) federally
does not exist. *Connor v. First Student, Inc.*, 5 Cal.5th 1026 (2018), held that
overlap with the CCRAA does not excuse ICRAA compliance and that employers must
satisfy the stricter statute. Statutory damages: $10,000 per violation
(§ 1786.50). ICRAA also carries its own 7-year obsolescence rule (§ 1786.18)
without the federal salary exemption for most items.

Also live and worth a separate memo: NYC Local Law 144 (automated employment
decision tools, bias audits), Illinois HB 3773 (AI in employment decisions,
effective 2026), and the Colorado AI Act. Flagged, not researched here.

### 1.7 Summary and critique of the internal Grain memo

**What it says.** `grain/docs/decisions/fcra-employment-agency-positioning.md`
argues that Grain's sourcing, matching and reference-collection workflow
plausibly falls inside § 1681a(o); that the exclusion is *conditioned* on
candidate consent rather than obviated by it, so Grain's `managerContactConsent`
and `network_discovery_opt_in` gates are load-bearing and must be strengthened;
that the FTC's *Basting* opinion draws the line between sourcing (protected) and
screening-on-request (not); that Title VII's employment-agency definition and
Texas Occupations Code ch. 2501 supply supporting characterization; and it lists
operational requirements (real job orders, referral records, purpose limitation)
to preserve the exclusion.

**Where it is right, and it is right about a lot.**
- The core insight, that consent is a *precondition* of (o)(5), not an alternative
  to FCRA compliance, is correct and is the opposite of the usual founder
  intuition. Removing consent gates would increase exposure.
- The *Basting* sourcing-vs-screening line is accurately drawn.
- The "what stays outside the exclusion regardless" list is sound.
- Its epistemic hygiene is good. It flags the Texas HB 3167 licensing claim as
  unverified and labels itself a working position.

**Where it is incomplete or wrong, in order of importance.**

1. **It states (o)(1) and then does not use it.** The memo lists condition 1 as
   "Would otherwise be an investigative consumer report" and moves on. That
   condition is dispositive of *scope*: the exclusion covers only
   personal-interview-derived character information. For Grain, whose product is
   substantially reference calls, this is survivable. For a structured
   attestation ledger it is fatal, because the structured record is an ordinary
   consumer report that (o) does not reach. **The memo's conclusion does not
   transfer to this product, and should not be cited as if it does.**

2. **It omits (o)(4) entirely.** The single-purpose limitation is the condition
   most directly hostile to a persistent reusable record, and it appears nowhere
   in the analysis. Even for Grain, reusing a reference across a second placement
   for a different employer is an (o)(4) problem.

3. **It omits § 1681a(h).** "Promotion, reassignment or retention" being inside
   "employment purposes" is what makes incumbent-employer reads FCRA-covered and
   (o)(2)-excluded. The memo's list of excluded activities gets to the right
   answer ("reference reports used for internal promotion, retention, or
   discipline") without citing the provision that compels it.

4. **It omits state law.** No mention of ICRAA, which is broader on exactly the
   axis ((o)(1)/§ 1681a(e)) where the federal argument has room, and which
   carries $10,000-per-violation statutory damages.

5. **It omits furnisher duties (§ 1681s-2).** If the exclusion fails, the
   employers and programs writing attestations acquire their own obligations.
   That is a partner-contracting and API-design problem the memo does not
   surface.

6. **It treats (o) as a status rather than a per-communication test.** "Grain is
   inside the exclusion" is not a thing the statute offers. Each communication
   either meets all five conditions or does not, and failing on any communication
   makes the company a CRA "in part" under § 1681a(f).

7. **Its own exclusion list forecloses most of the new product.** The memo says
   the following are outside the exclusion regardless: standalone reference
   products sold independent of a placement relationship; reference reports used
   for promotion/retention/discipline; "reputation/trust scores sold or licensed
   independent of an actual placement/referral relationship"; reuse of work-
   history data for unrelated analytics or scoring; and employer access
   unconnected to a real open role. **The identity ledger as described is on the
   wrong side of four of those five lines.** The memo is, read carefully,
   evidence against extending its own conclusion to this product.

**Net judgment.** The Grain memo is a competent working position for a
placement recruiter and should be kept for that purpose, with items 2, 3, 4 and
5 added. It is not a foundation for the ledger, and reusing it here would be the
most expensive available mistake, because it would produce a CRA that has
documented, in writing, that it considered FCRA and concluded it was exempt.
Under § 1681n that is willfulness evidence.

---

## 2. GDPR (European Union)

### 2.1 Lawful basis

**Consent (Art. 6(1)(a)) is the wrong primary basis.** Art. 29 WP Opinion
2/2017 on data processing at work concludes that given the imbalance of power in
employment, consent is "highly unlikely" to be a valid basis unless the worker
can refuse without adverse consequence. A worker who cannot get placed without a
ledger profile is not freely consenting (Art. 4(11), Art. 7(4)). Consent also
carries Art. 7(3) withdrawal, which cascades directly into Art. 17(1)(b) erasure.

**Legitimate interests (Art. 6(1)(f)) is the realistic basis** for maintaining
verified employment history, with a documented balancing test (LIA) and Recital
47's reasonable-expectations analysis. Verified employment-history attestation is
a strong legitimate interest; open-ended reputation scoring is much weaker in
the balancing.

**Contract (Art. 6(1)(b))** supports only what is objectively necessary to
deliver the service the worker asked for: enough for the worker's own profile,
not for retaining adverse attestations against their objection.

**Art. 9 special categories** should be schema-excluded by design (health, union
membership, religion, biometrics-for-identification). **Art. 10 is the harder
one:** processing of personal data relating to criminal convictions and offences
is permitted only under official authority or where authorized by Union/Member
State law providing appropriate safeguards. For a private controller this
effectively forecloses criminal-record content in the EU ledger.

### 2.2 Erasure vs. an append-only evidence record

**Art. 17(1) triggers** relevant here: (a) data no longer necessary for the
purpose; (b) consent withdrawn and no other basis; (c) the subject objects under
Art. 21(1) and there are no overriding legitimate grounds; (d) unlawful
processing.

**Art. 17(3) exemptions:** (b) compliance with a legal obligation under Union or
Member State law; (c) public interest in public health; (d) archiving/research
in the public interest; (e) **establishment, exercise or defence of legal
claims**; (a) freedom of expression and information.

Two things follow that are commonly gotten wrong:

- **"We used legitimate interests" is not itself an Art. 17(3) exemption.**
  Legitimate interests get you *in* under Art. 6; they do not get you out of
  Art. 17. Where a worker objects under Art. 21(1), you must demonstrate
  "compelling legitimate grounds which override the interests, rights and
  freedoms of the data subject", which is a higher bar than the original Art. 6(1)(f)
  balancing.
- **Art. 17(3)(e) is the workhorse but is narrower than "audit."** Retention for
  possible future audit does not qualify absent a specific statutory retention
  obligation. Retention of the specific records underpinning a live or reasonably
  anticipated dispute does.

**How append-only systems actually reconcile this.** The EDPB's Guidelines
02/2025 on processing personal data through blockchain technologies (v2.0
adopted 7 July 2026) set the reference architecture, and it is not
crypto-shredding:

- Consider the immutability/erasure conflict *at technology-selection time*,
  before building.
- **Do not write cleartext, encrypted, or hashed personal data to the immutable
  structure.** The EDPB's position is that encrypted and hashed data remain
  personal data where re-identification is reasonably likely.
- Store personal data **off-chain**, and write only a cryptographic commitment
  or reference on-chain. Erasure is effected by deleting the off-chain payload,
  after which the on-chain entry has no personal reference.

That last pattern is directly implementable for a non-blockchain append-only
ledger and is the answer for this product: **the chain records that an
attestation of a given type occurred, signed by a given party, at a given time;
the erasable payload store holds who it was about and what it said.**

**Crypto-shredding: useful, not blessed.** Destroying the key renders ciphertext
unrecoverable and is accepted in practice by many DPAs as satisfying erasure. But
the EDPB's stated position that encrypted data is personal data means
crypto-shredding is best treated as a strong technical safeguard and a
defensible *component* of an erasure workflow, not as a standalone legal answer.
Confidence: medium, since this is genuinely unsettled and practice is ahead of
guidance.

**Pseudonymization has become more useful.** *EDPS v. SRB* (C-413/23 P, 4 Sept
2025) endorsed a contextual, recipient-relative test: pseudonymized data may be
non-personal *for a recipient* who cannot reasonably re-identify. That supports
designing partner-facing reads so most recipients hold data that is not personal
data in their hands, a real architectural lever for the analytics and matching
layers, though not for the identified prior packet itself.

**Rectification, and the annotation model.** Art. 16 gives "the right to obtain
from the controller without undue delay the rectification of inaccurate personal
data" and, in its second sentence, "the right to have incomplete personal data
completed, including by means of providing a supplementary statement." The
supplementary statement is genuine textual support for dispute-by-annotation,
**but only for incompleteness**. Demonstrably inaccurate data must actually be
rectified. Art. 5(1)(d) reinforces this: inaccurate data must be "erased or
rectified without delay." The design's "frozen once verified" rule is therefore
not sustainable for verified-but-wrong data. Confidence: high.

**Storage limitation** (Art. 5(1)(e)) independently disfavors a permanent
record: personal data must be kept no longer than necessary for the purposes.
"Forever, because a work ledger is more valuable the longer it runs" is a
business rationale, not a necessity argument.

### 2.3 Article 22: the one most likely to be underestimated

*SCHUFA Holding (Scoring)*, C-634/21 (CJEU, 7 Dec 2023): producing a score is
itself an automated individual decision under Art. 22 where a third party "draws
strongly" on that score in deciding a contractual relationship. The obligation
falls on the *scoring entity*, not only on the entity making the final call.

Applied here: if provenance grades, trust scores, or match rankings are furnished
to employers who rely on them heavily, the ledger operator is doing Art. 22
processing. That requires an Art. 22(2) gateway (contract necessity, Union or
Member State law, or explicit consent, with the last being weak in employment) plus
Art. 22(3) safeguards: human intervention on the controller's side, the right to
express a point of view, and the right to contest the decision. It also engages
Arts. 13(2)(f)/14(2)(g)/15(1)(h) transparency about the logic involved.

**Adjacent and uncertain: the EU AI Act.** Annex III(4) classifies AI systems
for recruitment, selection, promotion, termination, task allocation and
performance evaluation as high-risk, with Articles 9–15 obligations. High-risk
obligations were scheduled to apply from 2 August 2026, but a "digital omnibus"
package delaying Annex III timelines was moving through the EU institutions as of
2026 and I have not verified its final status. Flagged for separate research;
do not treat the date as settled.

### 2.4 Data portability

Art. 20 applies only where processing is (i) based on consent or contract and
(ii) carried out by automated means, and covers only personal data "which he or
she has provided to" the controller. WP29's portability guidelines read
"provided" to include actively supplied data and *observed* data from use of the
service, but expressly **exclude inferred and derived data, with credit scores and
assessment outcomes as the canonical examples**.

Mapping to the schema:

- Worker self-asserted claims → clearly portable.
- Observed platform activity → likely portable.
- Third-party employer attestations *about* the worker → contested. They are not
  "provided by" the worker; they are provided by the attester about the worker.
  My inference: outside Art. 20, though a regulator could go either way.
- Provenance grades, trust scores, match rankings → not portable (derived).
- If the lawful basis is Art. 6(1)(f) legitimate interests, **Art. 20 does not
  apply at all.**

Art. 20(4) adds that portability "shall not adversely affect the rights and
freedoms of others", which is relevant because exporting a peer reference exports the
referee's personal data too.

Practical read: the obligation is thin, but worker-controlled export is the
product's whole political proposition. Build it as a product commitment and be
clear internally that it is not compelled, so it does not get scoped by legal
minimums.

---

## 3. Philippines: Data Privacy Act of 2012 (RA 10173)

**Retrieval caveat:** privacy.gov.ph returns HTTP 403 to automated fetching. The
Act and its IRR were read verbatim from LawPhil and the Supreme Court E-Library.
NPC circulars and advisories below were verified through Baker McKenzie, DLA
Piper, Linklaters and DataGuidance reporting, with the primary PDF URLs listed in
Sources for counsel to pull manually. Items marked **[unverified]** could not be
confirmed against a primary source.

### 3.1 You are in scope, from the first Philippine worker

Sec. 6 (extraterritorial application) is drafted ambiguously: it strings "and"
between the (a)/(b)/(c) limbs, which on a strict conjunctive reading would
require all three links. **The IRR resolves it disjunctively and is the operative
text.** IRR Sec. 4 applies the Act where any of the following holds, joined by
"or": the person is found or established in the Philippines; **"The act, practice
or processing relates to personal data about a Philippine citizen or Philippine
resident"**; the processing is done in the Philippines; or the entity has links
to the Philippines (equipment in-country, an office/branch/subsidiary, a contract
entered in the Philippines, carrying on business there, collecting or holding
data there).

**Having Philippine workers as data subjects is a stand-alone jurisdictional
hook.** Signing Philippine BPO employers as customers adds two more independent
hooks. Confidence: high on the IRR text; the underlying Sec. 6 drafting is
genuinely ambiguous but no one reads it conjunctively in practice.

**Enforcement against foreign identity platforms is real.** On 9 October 2025 the
NPC issued a Cease and Desist Order against **Tools for Humanity** (World App /
Orb iris verification), halting all associated processing in the Philippines. The
findings are directly transferable: offering a **monetary incentive in exchange
for consent** undermined free consent; the privacy notice failed to convey
purpose, scope, extent and duration clearly; and the collection was **not
necessary** for the stated verification purpose. A US-headquartered worker
identity network that pays or incentivizes onboarding, writes a broad
forward-looking notice, or collects more identity signal than verification
requires is exposed on all three.

**Registration and DPO.** IRR Secs. 26, 46–47 and **NPC Circular 2022-04**
(effective 11 Jan 2023, superseding 17-01) require DPO designation and
registration of data processing systems where the entity employs 250+ persons,
**or** processes SPI of 1,000+ individuals, **or** the processing is "likely to
pose a risk to the rights and freedoms of data subjects," **or** processing is
not occasional. A ledger holding government IDs and education records for
Philippine workers crosses the SPI threshold almost immediately and independently
satisfies the risk limb. **Assume mandatory registration.** Registration content
must include "proposed transfers of personal data outside the Philippines" and
the categories of recipients, so the offshore transfer is *disclosed*, not
*approved*. **[unverified]** whether a foreign entity with no Philippine office
can register under 2022-04, and whether the DPO must be Philippine-resident.

**Automated decision-making.** IRR Sec. 48 requires notifying the NPC when
automated processing becomes the sole basis for decisions significantly affecting
a data subject, and provides that **"No decision with legal effects concerning a
data subject shall be made solely on the basis of automated processing without
the consent of the data subject."** Any automated pass/fail, score or ranking the
employer acts on engages this.

### 3.2 Erasure: narrower in the statute, but the IRR closes the gap and then some

**Sec. 16(e)** gives the right to "suspend, withdraw or order the blocking,
removal or destruction" of personal information **"upon discovery and substantial
proof"** that it is "incomplete, outdated, false, unlawfully obtained, used for
unauthorized purposes or are no longer necessary for the purposes for which they
were collected." On its face this is narrower than GDPR Art. 17: no free-standing
consent-withdrawal trigger, no objection trigger, and a proof burden on the
worker.

**But IRR Rule VIII, Sec. 34(e) adds two triggers the statute does not contain,
and they are the ones that matter:**

- **34(e)(d):** "The data subject **withdraws consent or objects** to the
  processing, and there is no other legal ground or overriding legitimate interest
  for the processing", which imports the GDPR-style consequence. Build on consent
  alone and withdrawal reaches back into stored records.
- **34(e)(e):** "The personal data concerns **private information that is
  prejudicial to the data subject**, unless justified by freedom of speech, of
  expression, or of the press or otherwise authorized", which is **broader than anything
  in GDPR Art. 17, and it describes a negative employer attestation almost
  exactly.** A worker with an adverse attestation has a facially colorable
  erasure claim, and the only carve-outs are free expression or "otherwise
  authorized."

**This is the finding that kills unconditional append-only under Philippine law.**
Note the statute lists **blocking** as an alternative to removal and destruction,
so suppressing an entry from all reads is a textually supported remedy short of
physical deletion. Whether the NPC would accept hash-retention with the payload
destroyed as satisfying "destruction" is untested; blocking is the safer hook.

**Retention.** Sec. 11(e) permits retention "only for as long as necessary… or for
the establishment, exercise or defense of legal claims, or for legitimate business
purposes." A permanent ledger has no statutory anchor and invites the 34(e)(c)
"no longer necessary" trigger. **[unverified]** the three-year employment-records
baseline (Omnibus Rules Implementing the Labor Code, Rule X, Sec. 12, tracking the
three-year prescriptive period for money claims), based on secondary sources only.

### 3.3 Access and rectification: Sec. 16(d) is the best provision for this design

**Sec. 16(c) access** entitles the worker to contents processed, **sources from
which obtained**, **names and addresses of recipients**, manner of processing,
**reasons for disclosure to recipients**, information on automated processes where
they are or are likely to be the sole basis for a significant decision, **date
last accessed and modified**, and controller identity. The full-record view plus a
per-party grant/revoke log is close to purpose-built for this. Genuine compliance
asset.

**Sec. 16(d) rectification** is the most favorable text in any of the three
regimes for the annotation model, and it is worth quoting:

> "Dispute the inaccuracy or error in the personal information and have the
> personal information controller **correct it immediately**… **If the personal
> information have been corrected, the personal information controller shall
> ensure the accessibility of both the new and the retracted information and the
> simultaneous receipt of the new and the retracted information by recipients
> thereof**: Provided, That the third parties who have previously received such
> processed personal information **shall be informed of its inaccuracy and its
> rectification upon reasonable request of the data subject."

Philippine law does not merely tolerate versioned correction. It **requires**
that both the corrected and the retracted version stay accessible and be
delivered together to recipients. An append-only ledger is *closer* to Sec. 16(d)
than a mutable database is. That is a real design win.

**Two limits, both important:**

1. Sec. 16(d) addresses **inaccuracy or error**. It does not reach the worker who
   says "this is accurate but harmful", which routes to IRR 34(e)(e) erasure,
   where annotation does **not** discharge the obligation.
2. "Correct it **immediately**" plus the retraction-delivery duty means a
   *disputed flag is not a correction*. Leaving a substantiated-wrong attestation
   standing under a "disputed" badge while continuing to serve it is arguably
   non-compliance, not compliance. You need an adjudication path that can mark an
   entry **retracted**, and a **push** to prior grantees, not merely a state
   change on your side.

**NPC Advisory 2021-01** requires a documented rights-exercise procedure, no fee
beyond reasonable copying costs, and response within **30 working days**.

### 3.4 Lawful bases, and why SPI is the schema's biggest problem

**Sec. 3(l) defines sensitive personal information far more broadly than GDPR
Art. 9.** Answering the specific questions:

- **Education → SPI** (Sec. 3(l)(2)). Degrees, transcripts, and most likely formal
  training records. Assume yes for design purposes.
- **Government IDs → SPI** (Sec. 3(l)(3)): anything "issued by government agencies
  peculiar to an individual", including SSS/GSIS, TIN, PRC licenses, PhilSys, plus
  "licenses or its denials, suspension or revocation." This is a category test,
  not a closed list.
- **Health → SPI**; **criminal proceedings, including *alleged* offenses and their
  disposal → SPI** (both 3(l)(2)).
- **Age and marital status → SPI** (3(l)(1)). Date of birth in a worker profile is
  sensitive personal information. This routinely surprises foreign builders.
- **Trade union membership** is not separately enumerated (unlike GDPR) but is
  often inferable as political or philosophical affiliation, which is SPI.

**Sec. 12** bases for ordinary PI include consent (a), contract with the data
subject (b), legal obligation (c), and **legitimate interests (f), expressly
extending to the interests of "a third party or parties to whom the data is
disclosed."** That last clause is unusually well-suited to a reference-checking
product: the *recipient employer's* legitimate interest counts. **NPC Circular
2023-07** (effective 14 Jan 2024) imposes a documented three-part test: purpose,
necessity, balancing, retained as a **Legitimate Interest Assessment** for NPC
review, and critically requires the controller to **verify the third party's
legitimate interest before disclosing to them**, via its own assessment or the
third party's documented LIA. That is a per-employer LIA gate on the access-grant
flow, not just worker consent.

**Sec. 13 prohibits SPI processing except in six narrow cases**, and there is **no
legitimate-interest basis for SPI** (confirmed by Circular 2023-07). Sec. 13(f)
(legal claims) cannot cover routine business purposes (**NPC Advisory 2024-02**).
Sec. 13(d) (public-organization objectives) requires that SPI **not be transferred
to third parties**, which is fatal for a ledger.

**Consequence, and it is the sharpest design instruction in this whole memo:**
for education records, government IDs, date of birth and criminal-proceeding data,
**Sec. 13(a) specific prior consent is effectively the only available basis**, and
consent is unilaterally revocable with retroactive reach under IRR 34(e)(d).
**Segregate SPI into a separate, consent-gated, individually revocable store, and
keep employer attestation payloads SPI-free** so they can rest on Sec. 12(b)/(f).
An attestation that recites a degree, a license number, a birthdate or an
allegation converts an ordinary-PI record into an SPI record and drops it into the
Sec. 13 prohibition. **This is the single highest-leverage Philippine design
decision.**

### 3.5 Consent form and withdrawal

Sec. 3(b): consent must be "freely given, specific, informed" and **"evidenced by
written, electronic or recorded means."** Electronic is sufficient, but must be
*evidenced*: a durable, per-purpose, timestamped record versioned against the
notice text shown. A single click-through TOS will not carry Sec. 13(a)'s
"specific to the purpose, prior to the processing."

The Act has no express withdrawal right; the IRR supplies it via the right to
object (IRR Sec. 34(b)), which lists an exception for processing "necessary or
desirable in the context of an **employer-employee relationship between the
collector and the data subject**." **That exception does not help a third-party
ledger**, because you are not the worker's employer. Withdrawal then triggers IRR
34(e)(d) erasure or blocking unless a documented fallback basis exists.

### 3.6 Cross-border: accountability, not adequacy

**There is no adequacy regime, no transfer permit, and no mandatory clause set.**
The full Act and IRR contain none. **NPC Advisory 2021-02** states the ASEAN Model
Contractual Clauses are for voluntary adoption and that "the NPC does not require
or obligate parties… to adopt these and will not accept any request for contract
review." **NPC Advisory 2024-01** (30 May 2024) similarly points to ASEAN MCCs and
EU SCCs as voluntary, with no approval or filing.

What is owed instead is **Sec. 21 / IRR Sec. 50 accountability**: the controller
remains responsible for personal information "transferred to a third party for
processing, whether domestically or internationally," and must "use contractual or
other reasonable means to provide a comparable level of protection."

**US hosting is therefore lawful.** The obligations are contractual and
evidentiary:

- **IRR Sec. 44** outsourcing agreements read like GDPR Art. 28 and are
  prescriptive: subject matter, duration, nature and purpose, data types, data
  subject categories, **the geographic location of processing**, documented-
  instructions-only processing "including transfers of personal data to another
  country," no sub-processor without prior instruction, assistance with rights
  requests, audit rights, and **deletion or return of all copies at the
  controller's choice at end of service**.
- **IRR Sec. 20** governs controller-to-controller **data sharing**: private-sector
  sharing requires the data subject's consent (**even with an affiliate or mother
  company**), commercial-purpose sharing **must be covered by a data sharing
  agreement**, and DSAs are subject to NPC review on its own initiative or on
  complaint. The employer→ledger→employer flow is data sharing, not merely
  outsourcing, so assume a DSA per participating employer.
- **NPC Circular 2023-06** (security of personal data, transitory compliance to 30
  March 2025) applies by its terms "within and outside of the Philippines," and
  requires DPO and DPS registration, PIAs, a privacy management program, training
  and encryption.

**The controller-vs-processor characterization is the most consequential
structuring decision.** IRR Sec. 44's delete-or-return clause gives a Philippine
employer, as controller, a contractual right to demand deletion of all copies at
contract end, which is fatal to an immutable ledger. Positioning as an independent
controller (the worker is your data subject; employers are attestation sources)
avoids that but takes on full controller liability. Decide deliberately, not by
default.

### 3.7 Criminal penalties, the real risk driver

Every offense in Secs. 25–32 carries **imprisonment plus fine**, **Sec. 34** applies
them to "responsible officers… who participated in, or by their gross negligence,
allowed the commission of the crime," and provides that an **alien offender is
deported after serving the penalty**. **Sec. 35** escalates to the maximum penalty
where the data of **at least 100 persons** is involved, which is automatic at any real
scale. **Sec. 33** turns a combination or series of offenses into a 3–6 year,
₱1M–5M offense, which is what a systemic design flaw produces.

The four that should drive engineering priorities:

- **Sec. 25 unauthorized processing**: 3–6 years and ₱500k–4M for SPI. Holding
  government IDs or education records without a valid Sec. 13 basis is literally
  this offense.
- **Sec. 28 processing for unauthorized purposes**: 2–7 years for SPI, the longest
  sentence in the Act. Scope creep is the failure mode: attestations collected for
  verification later used for scoring, sold, or used as training data.
- **Sec. 32 unauthorized disclosure**: disclosure to a third party without
  consent. Your core function is disclosure to third parties; a revocation bug that
  leaves an employer's access live is this offense.
- **Sec. 31 malicious disclosure**: disclosing "unwarranted or false information"
  with malice or bad faith. Requires scienter, but knowingly continuing to serve an
  attestation after a substantiated dispute is where a prosecutor looks. **This is
  what makes the dispute SLA a criminal-law matter rather than a UX matter.**

Administrative fines sit on top: **NPC Circular 2022-01** sets grave infractions
(rights or general-principle violations affecting >1,000 data subjects, or repeat
infractions) at **0.5%–3% of annual gross income**, major at 0.25%–2%, capped at
₱5M per act or omission. **[unverified]** whether the NPC computes that base on
global or Philippine gross income for a foreign controller, and it is worth counsel's time.

### 3.8 No FCRA analogue, and no safe harbor

RA 9510 (Credit Information System Act) is **credit-only** and does not reach
employment reputation. Every operative definition is tied to lending: "basic
credit data" comes from a **borrower** in connection with a **credit facility**;
"credit facility" means a loan, credit line, guarantee or other financial
accommodation; "submitting entity" means entities providing credit facilities. The
statute's "credit report" definition does mention "character and general reputation
of a borrower," but only as a component of a borrower's credit report built from
credit-facility data. A work ledger is not a credit facility, its subjects are not
borrowers, and its attesters are not submitting entities.

**The corollary matters strategically.** DPA Sec. 4(e)-(f) and IRR Sec. 5 carve
CISA processing *out* of the DPA, so the fact that you are not doing CISA
processing means you get **no exemption** and remain fully DPA-governed, with no
accredited-bureau status to opt into.

**In the US, the FCRA is burdensome but it is also a recognized status: comply and
you have a lawful role as a CRA. The Philippines offers no equivalent.** There is
no accreditation, no licensing, and no statutory permission structure for
employment reputation data. Your position rests entirely on consent quality and
legitimate-interest documentation. That asymmetry should inform where the product
launches first.

### 3.9 Employment references and blacklisting: weakest section, flagged

- **[unverified]** No Philippine statute specifically prohibits private-sector
  employment blacklisting was found. The formal blacklisting mechanism under
  RA 8042 / RA 10022 and DMW rules governs *overseas* employment for foreign
  employers and recruitment agencies, and is a poor analogy. Do not lean on it.
- **DOLE Labor Advisory No. 06-20** requires a Certificate of Employment within
  three days of request, with minimum contents of date of engagement, date of
  termination, and type of work. **Reason for separation is not a required field.**
  The signal is worth reading: the Philippine statutory reference instrument is
  deliberately thin and factual. A ledger reproducing dates and role is aligned
  with local practice; one carrying performance ratings or reason-for-separation
  goes materially beyond what the law contemplates a reference containing.
  **[unverified: secondary sources only.]**
- **[unverified]** Philippine practitioner commentary asserts cross-company
  "do not hire" lists are generally unlawful under the DPA for want of lawful
  basis, notice and proportionality. Directionally consistent with the statute's
  structure, but this is blog commentary, not authority.
- **[unverified]** NPC Advisory Opinions **2018-050** and **2019-040** are cited in
  secondary sources as treating background verification for fraud prevention and
  workplace safety as legitimate interests where safeguards exist. If accurate,
  these are the best affirmative authority available. **Have counsel pull them.**
- **Residual non-DPA exposure:** false or malicious negative attestations expose
  participating employers and possibly the platform to Civil Code Arts. 19/20/21
  (abuse of rights) and Art. 26 (privacy), and to **criminal libel** under Revised
  Penal Code Arts. 353–355, with **RA 10175** raising the penalty one degree for
  online publication. There is no US analogue and no Section 230-style intermediary
  immunity. A US-hosted platform publishing employer statements about named
  Philippine workers should treat criminal libel as a first-order risk.
  **[unverified as to specific application to employment references.]**

### 3.10 Open items for Philippine counsel

Four gaps could not be closed and each has direct product consequences:
(a) whether a foreign entity with no Philippine office can register under Circular
2022-04; (b) whether the DPO must be Philippine-resident; (c) how the NPC computes
the "annual gross income" fine base for a foreign controller; (d) the text of NPC
Advisory Opinions 2018-050 and 2019-040 and any opinion touching employment
verification or blacklists.

---

## 4. Cross-border transfer for a single global ledger

**The headline: one physical global ledger is foreclosed. Regional partition
with per-region key custody is effectively forced.** Reasons, in order:

**EU → US.** The EU-US Data Privacy Framework (Commission Implementing Decision
(EU) 2023/1795, 10 July 2023) provides adequacy for US organizations that
self-certify with the Department of Commerce and are subject to FTC or DOT
jurisdiction. The General Court dismissed the challenge in *Latombe v.
Commission* (T-553/23) on 3 September 2025; Latombe appealed to the CJEU on 31
October 2025 (C-703/25 P), pending. The DPF remains in force and can be relied on
today. **It should not be the sole mechanism.** A schema whose legality depends
on an adequacy decision under active appeal is a schema with a single point of
regulatory failure, and the Privacy Shield precedent is exactly this. Standard
Contractual Clauses (Decision 2021/914, Modules 2 and 3) plus a transfer impact
assessment per *Schrems II* and EDPB Recommendations 01/2020 should be executed
as the fallback layer regardless.

Note also that DPF certification for **HR data** received from the EU carries
additional commitments, directly relevant, since worker data *is* HR data
("personal data about employees, past or present, collected in the context of
the employment relationship"). An organization wishing its DPF commitments to
cover HR data must, annually, declare its commitment to cooperate with EU DPAs
and to **comply with the advice given by those authorities**, submitting to an
informal DPA panel that can issue binding recommendations. That is a materially
heavier commitment than ordinary DPF certification, since it imports EU regulator
authority directly over the ledger's dispute and correction handling.

**EU → Philippines.** The Philippines has no EU adequacy decision. Any EU-origin
personal data reaching Philippine-based operations staff requires SCCs plus a
TIA. Critically: **remote read access by a Philippine-based operator is itself a
transfer**, so this is triggered by support tooling and admin consoles, not only
by data replication. Confidence: high.

**Onward transfers.** Every external partner company reading the prior packet is
a recipient, and where they are outside the EEA the transfer chain must be
papered: SCCs Module 1 (controller-to-controller) for independent-controller
partners, Module 2 for processors. With N partners across M jurisdictions this is
a contracting problem that scales linearly and must be automated at onboarding,
not handled bespoke.

**Philippines outbound: the easy direction.** RA 10173 has **no adequacy regime,
no transfer permit and no mandatory clause set** (NPC Advisories 2021-02 and
2024-01 both confirm voluntary use of ASEAN MCCs and EU SCCs, with no NPC review
or filing). Sec. 21 / IRR Sec. 50 accountability applies instead: the controller
stays responsible for data transferred abroad and must use "contractual or other
reasonable means to provide a comparable level of protection." What that means
operationally is IRR Sec. 44-compliant processing agreements (which specify the
**geographic location of processing** and a delete-or-return-all-copies right),
IRR Sec. 20 data sharing agreements with participating employers, and declaration
of the offshore transfer in NPC registration. Detail in §3.6.

**Asymmetry worth noting for sequencing.** EU→US is the hard leg (adequacy under
appeal, SCCs plus TIA, HR-data DPA-cooperation commitments). PH→US is the easy leg
(contractual accountability only). EU→PH is the hardest (no adequacy, SCCs plus
TIA, and triggered by read access). A product that launches US + Philippines
first and defers the EU has a materially simpler transfer posture.

**Architectural consequence.** The combination of (a) EU adequacy uncertainty,
(b) no PH adequacy, (c) US CRA obligations that attach to US-facing furnishing,
and (d) PH criminal liability for unauthorized processing, means the sane
topology is regional data planes with a thin global identity/resolution layer
holding the minimum linking data, not one ledger with row-level jurisdiction
tags. A single table with a `region` column will not survive a DPA asking where
EU data is stored and who can read it.

---

## 5. Constraints for the design session

Stated as forced (F) or foreclosed (X). Confidence noted where below high.

**Storage and lifecycle**

1. **(X) "Never deletion" is foreclosed.** § 1681i(a)(5)(A) requires deletion or
   modification of items found inaccurate, incomplete or unverifiable; GDPR
   Arts. 16–17 require rectification and, in defined cases, erasure.
2. **(F) Separate the immutable event record from the erasable personal-data
   payload.** The append-only chain holds signed commitments (who attested,
   when, of what type, hash reference). The payload store holds the identified
   content and is independently correctable, suppressible and destructible. This
   is the EDPB's own recommended blockchain pattern and it resolves most of the
   conflict.
3. **(F) Every claim needs a reportability lifecycle distinct from its storage
   lifecycle:** `stored` / `reportable` / `suppressed` / `erased`. § 1681c(a)(5)
   forces adverse items out of reports at 7 years (medium-high confidence on
   scope); GDPR Art. 5(1)(e) forces a retention justification for everything else.
4. **(F) Crypto-shredding capability, i.e. per-subject (ideally per-claim) key
   custody.** Necessary but not sufficient under the EDPB's stated position that
   encrypted data remains personal data (medium confidence). Design it as one
   layer of an erasure workflow, not the whole of it.
5. **(X) "Frozen once third-party verified" is foreclosed as an absolute.**
   Verified-but-wrong must be correctable. Replace "frozen" with "immutable
   attestation object + mutable current-state projection," where correction
   appends a superseding attestation and the projection changes.
5a. **(F) A `blocked` state distinct from `erased`.** PH DPA Sec. 16(e) lists
   *blocking* alongside removal and destruction, so suppressing an entry from all
   reads is a textually supported remedy short of physical deletion. It is the
   cheapest compliant answer to an IRR 34(e)(e) "prejudicial information" demand.
5b. **(F) A `retracted` state distinct from `disputed`.** PH Sec. 16(d) requires
   that corrected and retracted versions both remain accessible and be delivered
   **together** to recipients. A "disputed" badge on an entry you keep serving is
   not a correction. Adjudication must be able to terminate in retraction, and
   retraction must **push** to prior grantees.

**Disputes**

6. **(F) A dispute engine is a first-class subsystem, not an annotation
   feature.** It must: accept disputes on any claim; hit a 30-day clock (+15);
   route the dispute to the originating furnisher; record the reinvestigation;
   and terminate in delete / modify / verify-and-annotate. Annotation is the
   *residual* outcome, not the default.
7. **(F) A furnisher callback API.** § 1681s-2(b) puts investigation duties on
   the attesting employer or program. Partner integration contracts must include
   a dispute-response SLA, and the API must exist on day one.
8. **(F) Recipient log with notification capability.** § 1681i(d) requires
   notifying prior recipients of deletions and disputes; § 1681g(a)(3)(A)(i)
   requires a 2-year employment-recipient list. Log every read with party,
   timestamp, purpose and the exact payload version served.
9. **(F) Payload versioning / point-in-time reconstruction.** You must be able to
   prove what a specific reader saw on a specific date, for accuracy defense and
   for adverse-action disputes.

**Access and purpose**

10. **(F) Purpose is an attribute of the read, not of the party.** Permissible
    purpose (§ 1681b), GDPR purpose limitation (Art. 5(1)(b)) and § 1681a(o)(4)
    all attach to the use, not the relationship. The access grant model must
    capture *declared purpose per read* and enforce field-level scoping against
    it. Worker-facing grant/revoke at the party level alone is insufficient.
11. **(F) User certification at onboarding.** § 1681b(b)(1) certification of
    intended use and § 1681e(a) identity/use verification must be captured as
    structured data, not PDF contracts.
11a. **(F) Segregate sensitive personal information into a separate,
    consent-gated, individually revocable store, and keep attestation payloads
    SPI-free.** Under PH Sec. 3(l), education records, government IDs, date of
    birth, health and criminal-proceeding data are all SPI; legitimate interest is
    unavailable for SPI and Sec. 13(d) forbids third-party transfer, leaving
    revocable consent as the only basis. An attestation that recites a degree, a
    license number, a birthdate or an allegation converts an ordinary-PI record
    into a Sec. 13-prohibited one. This is the highest-leverage Philippine design
    decision and it maps cleanly onto the GDPR Art. 9/Art. 10 exclusions too.
11b. **(F) Per-recipient legitimate-interest assessment as a gate on the access
    grant.** NPC Circular 2023-07 requires the controller to verify the *third
    party's* legitimate interest before disclosing, via its own assessment or the
    recipient's documented LIA. Combined with FCRA § 1681b(b)(1) certification,
    this means partner onboarding produces a structured, auditable purpose record:
    the same artifact satisfies both regimes.
12. **(F) Hard separation between commonly-owned internal verticals and external
    partners in the data plane.** § 1681a(d)(2)(A)(ii)-(iii) gives affiliates a
    real statutory lane that partners do not have. Collapsing them into one
    access model throws away the only clean exclusion available.

**Scores and grades**

13. **(F) Treat any derived score/grade as the most regulated object in the
    schema.** *SCHUFA* puts Art. 22 duties on the producer of the score; the
    withdrawn CFPB circular took the same line under FCRA. Requires: human
    intervention path, contest mechanism, logic transparency, and documented
    accuracy procedures under § 1681e(b).
14. **(F) Provenance grade must be exposed to the reader, not just stored.**
    Furnishing self-asserted claims without visible provenance is the § 1681e(b)
    "maximum possible accuracy" exposure in its purest form.

**Jurisdiction**

15. **(X) A single global ledger table is foreclosed.** Regional data planes,
    per-region key custody, and a minimal global identity-resolution layer.
16. **(F) Jurisdiction must be a first-class property of the *worker*, the
    *attester*, and the *reader*: three independent axes.** A US employer
    reading about a Philippine worker whose attestation came from an EU entity
    engages all three regimes simultaneously, and the applicable rule is the
    union, not the intersection.
17. **(X) Criminal-record content in the EU ledger is effectively foreclosed**
    for a private controller (GDPR Art. 10), and is outside § 1681a(o) in the US
    regardless (per *Islinger* and the Grain memo's own exclusion list).
18. **(F) SCCs papered in parallel with DPF reliance**, given C-703/25 P pending.
18a. **(F) Decide controller-vs-processor deliberately, per jurisdiction.** PH IRR
    Sec. 44(g) gives a controller the right to demand deletion of all copies at
    contract end. If employers are controllers and you are the processor, an
    immutable ledger is contractually indefensible. Positioning as an independent
    controller (the worker is your data subject; employers are attestation
    sources) avoids that and takes on full controller liability. This is the most
    consequential legal-structuring decision in the product and it should be made
    at the schema level, not in the MSA.
18b. **(F) Registration and DPO in the Philippines, plus NPC notification for
    automated decisions** (IRR Secs. 26, 46–48; Circular 2022-04). IRR Sec. 48
    prohibits decisions with legal effects made solely on automated processing
    without the data subject's consent, the third regime, alongside GDPR Art. 22
    and the FCRA algorithmic-score problem, converging on the same requirement.

**Positioning**

19. **(F) Decide deliberately whether to register and operate as a CRA.** The
    honest reading is that the US product is one. The strategic question is not
    "how do we avoid it" but "is CRA-native compliance a moat or a tax." Given
    that the design already implements file disclosure, permissible-purpose
    control and dispute annotation voluntarily, the marginal cost of full
    compliance is lower than it looks and the marginal cost of *failed avoidance*
    (willfulness under § 1681n, plus $10,000-per-violation ICRAA exposure) is
    very high.
20. **(X) Do not cite the Grain FCRA memo as authority for this product.** Its
    conclusion is scoped to placement-recruiter reference collection and its own
    exclusion list rules out most of the ledger. A written internal conclusion of
    exemption that a court later rejects is willfulness evidence.

---

## Sources

**FCRA — statute**
- [15 U.S.C. § 1681a — Definitions (Cornell LII)](https://www.law.cornell.edu/uscode/text/15/1681a)
- [15 U.S.C. § 1681a — full text incl. subsection (o) (US House OLRC)](https://uscode.house.gov/view.xhtml?req=granuleid:USC-prelim-title15-section1681a&num=0&edition=prelim)
- [15 U.S.C. § 1681c — Requirements relating to information contained in consumer reports](https://www.law.cornell.edu/uscode/text/15/1681c)
- [15 U.S.C. § 1681i — Procedure in case of disputed accuracy](https://www.law.cornell.edu/uscode/text/15/1681i)
- [Definition: consumer reporting agency, 15 U.S.C. § 1681a(f) (Cornell LII)](https://www.law.cornell.edu/definitions/uscode.php?width=840&height=800&iframe=true&def_id=15-USC-648284895-644972389&term_occur=999&term_src=)
- [FCRA § 603(f) definition of "Consumer Reporting Agency" (NCLC Digital Library)](https://library.nclc.org/book/fair-credit-reporting/fcra-ss-603f-15-usc-ss-1681a-definition-consumer-reporting-agency)

- [FTC, Fair Credit Reporting Act, 15 U.S.C. § 1681 — consolidated text, revised March 2026 (PDF)](https://www.ftc.gov/system/files/ftc_gov/pdf/fcra-march-2026.pdf)

**FCRA — agency guidance and enforcement**
- [CFPB Circular 2024-06: Background Dossiers and Algorithmic Scores for Hiring, Promotion, and Other Employment Decisions](https://www.consumerfinance.gov/compliance/circulars/consumer-financial-protection-circular-2024-06-background-dossiers-and-algorithmic-scores-for-hiring-promotion-and-other-employment-decisions/)
- [Circular 2024-06 as published, 89 Fed. Reg. 88,875 (Nov. 12, 2024)](https://www.federalregister.gov/documents/2024/11/12/2024-26099/consumer-financial-protection-circular-2024-06-background-dossiers-and-algorithmic-scores-for-hiring)
- [CFPB, Interpretive Rules, Policy Statements, and Advisory Opinions; Withdrawal (May 12, 2025)](https://www.federalregister.gov/documents/2025/05/12/2025-08286/interpretive-rules-policy-statements-and-advisory-opinions-withdrawal)
- [CFPB Withdrawn Guidance index](https://www.consumerfinance.gov/compliance/guidance/withdrawn-guidance/)
- [NCLC, Continued Vitality of 67 Withdrawn CFPB Guidance Documents](https://library.nclc.org/article/continued-vitality-67-withdrawn-cfpb-guidance-documents)
- [FTC, What Employment Background Screening Companies Need to Know About the FCRA](https://www.ftc.gov/business-guidance/resources/what-employment-background-screening-companies-need-know-about-fair-credit-reporting-act)
- [FTC, Background screening reports and the FCRA: Just saying you're not a consumer reporting agency isn't enough (Jan. 2013)](https://www.ftc.gov/business-guidance/blog/2013/01/background-screening-reports-fcra-just-saying-youre-not-consumer-reporting-agency-isnt-enough)
- [FTC, Spokeo to Pay $800,000 to Settle FTC Charges (June 2012)](https://www.ftc.gov/news-events/news/press-releases/2012/06/spokeo-pay-800000-settle-ftc-charges-company-allegedly-marketed-information-employers-recruiters)
- [FTC, Speaking of Spokeo: Part 1](https://www.ftc.gov/business-guidance/blog/2012/06/speaking-spokeo-part-1)
- [FTC Advisory Opinion to Islinger (06-09-98)](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-islinger-06-09-98)
- [FTC Advisory Opinion to Basting (06-11-98)](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-basting-06-11-98)
- [FTC Advisory Opinion to Lewis (06-11-98)](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-lewis-06-11-98)
- [FTC Advisory Opinion to Goeke (06-09-98)](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-goeke-06-09-98)
- [FTC, Section 603(o) — Definition of Consumer Report, Exception for Employment Agencies](https://www.ftc.gov/legal-library/browse/advisory-opinions/section-603o-definition-consumer-report-exception-employment-agencies)
- [CFPB FCRA Examination Procedures (Oct. 2012)](https://files.consumerfinance.gov/f/documents/102012_cfpb_fair-credit-reporting-act-fcra_procedures.pdf)
- [CFPB Fact Sheet: Proposed Rule on Data Brokers (Dec. 2024)](https://files.consumerfinance.gov/f/documents/cfpb_fcra-nprm-fact-sheet_2024-12.pdf)
- [CFPB, Fair Credit Reporting; Background Screening advisory opinion (Jan. 2024) (PDF)](https://files.consumerfinance.gov/f/documents/cfpb_fair-credi-reporting-background-screening_2024-01.pdf)

**FCRA — case law**
- [Kidd v. Thomson Reuters Corp., 925 F.3d 99 (2d Cir. 2019) (Justia)](https://law.justia.com/cases/federal/appellate-courts/ca2/17-3550/17-3550-2019-05-30.html)
- [Kidd v. Thomson Reuters (FindLaw full text)](https://caselaw.findlaw.com/court/us-2nd-circuit/2000805.html)
- [Paul, Weiss — Second Circuit Defines "Consumer Reporting Agency" Under the FCRA](https://www.paulweiss.com/insights/client-memos/second-circuit-review-court-defines-consumer-reporting-agency-under-the-fcra)
- [Connor v. First Student, Inc., 5 Cal.5th 1026 (2018) (FindLaw)](https://caselaw.findlaw.com/court/ca-supreme-court/1948536.html)
- [Farella Braun + Martel — California Supreme Court Clarifies Background Check Laws](https://www.fbm.com/publications/california-supreme-court-clarifies-background-check-laws-in-california/)

**FCRA — staffing-agency practice**
- [myHRcounsel — Can Staffing Agencies Share Background Checks or Drug Tests with Clients?](https://myhrcounsel.com/2018-7-26-can-staffing-agencies-share-background-checks-or-drug-tests-with-clients/)
- [myHRcounsel — What Should Staffing Agencies Do When a Client Requests to See Applicant Background Check Reports?](https://myhrcounsel.com/2019-2-4-what-should-staffing-agencies-do-when-a-client-requests-to-see-applicant-background-check-reports/)

**GDPR**
- [EDPB Guidelines 02/2025 on processing of personal data through blockchain technologies (PDF)](https://www.edpb.europa.eu/system/files/2025-04/edpb_guidelines_202502_blockchain_en.pdf)
- [Bird & Bird — EDPB Adopts Final Guidelines on Blockchain and Personal Data (v2.0, July 2026)](https://www.twobirds.com/en/insights/2026/netherlands/edpb-adopts-final-guidelines-on-blockchain-and-personal-data-a-practical-guide-for-organisations)
- [CNIL — Blockchain and the GDPR: Solutions for a responsible use of the blockchain in the context of personal data](https://www.cnil.fr/en/blockchain-and-gdpr-solutions-responsible-use-blockchain-context-personal-data)
- [Art. 29 WP, Guidelines on the right to data portability (WP242 rev.01) (PDF)](https://www.bvdnet.de/wp-content/uploads/2022/03/Guidelines-on-the-right-to-data-portability.pdf)
- [Art. 29 WP Opinion 2/2017 on data processing at work](https://ec.europa.eu/newsroom/article29/items/610169)
- [Hunton — Article 29 Working Party Releases Opinion on Data Processing at Work](https://www.hunton.com/privacy-and-information-security-law/article-29-working-party-releases-opinion-on-data-processing-at-work)
- [CJEU, SCHUFA Holding (Scoring), C-634/21 (7 Dec. 2023)](https://www.julia-project.eu/database/case-law/216)
- [Bird & Bird — Key takeaways from the SCHUFA case](https://www.twobirds.com/en/insights/2023/global/key-takeaways-from-the-schufa-case-of-the-cjeu)
- [A&O Shearman — CJEU rules a credit score constitutes automated decision making under the GDPR](https://www.aoshearman.com/en/insights/ao-shearman-on-data/cjeu-rules-that-a-credit-score-constitutes-automated-decision-making-under-the-gdpr)
- [CJEU, EDPS v. SRB, C-413/23 P (4 Sept. 2025) — Clifford Chance analysis](https://www.cliffordchance.com/insights/resources/blogs/talking-tech/en/articles/2025/09/pseudonymized-data-after-edps-v-srb.html)
- [Taylor Wessing — Analysis of the CJEU judgment in C-413/23 P (EDPS v SRB)](https://www.taylorwessing.com/en/insights-and-events/insights/2025/09/analysis-of-the-cjeu-judgment)
- [Goodwin — Personal Data or Not? CJEU Weighs In on Pseudonymisation in EDPS v. SRB](https://www.goodwinlaw.com/en/insights/publications/2025/09/alerts-technology-dpc-personal-data-or-not)
- [ICO — Right to erasure](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-erasure/)

**Philippines — primary (read verbatim)**
- [RA 10173, Data Privacy Act of 2012 (LawPhil)](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)
- [RA 10173 (Official Gazette)](https://www.officialgazette.gov.ph/2012/08/15/republic-act-no-10173/)
- [Implementing Rules and Regulations of RA 10173 (Supreme Court E-Library)](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/70735)
- [IRR of RA 10173 (Official Gazette)](https://www.officialgazette.gov.ph/2016/08/25/implementing-rules-and-regulations-of-republic-act-no-10173/)
- [RA 9510, Credit Information System Act (LawPhil)](https://lawphil.net/statutes/repacts/ra2008/ra_9510_2008.html)

**Philippines — NPC issuances (primary URLs; privacy.gov.ph blocks automated fetch, retrieve manually)**
- [NPC Circular 2022-04 — Registration of DPS and DPO](https://privacy.gov.ph/wp-content/uploads/2023/05/Circular-2022-04-1.pdf)
- [NPC Circular 2023-07 — Guidelines on Legitimate Interest](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf)
- [NPC Advisory 2024-02 — Processing based on Sec. 13(f)](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf)
- [NPC Advisory 2024-01 — Contractual Clauses for Cross-Border Transfers](https://privacy.gov.ph/wp-content/uploads/2024/06/Published-NPC-Advisory-No.-2024-01-Contractual-Clauses-for-Cross-Border-Transfers_30May24.pdf)
- [NPC Advisory 2021-02 — ASEAN Model Contractual Clauses and DMF](https://privacy.gov.ph/wp-content/uploads/2021/06/Advisory-ASEAN-MCC-DMF_FINAL-signed.pdf)
- [NPC Advisory 2021-01 — Data Subject Rights](https://privacy.gov.ph/wp-content/uploads/2021/02/NPC-Advisory-2021-01-FINAL.pdf)
- [FAQs on the Guidelines on Administrative Fines (Circular 2022-01)](https://privacy.gov.ph/wp-content/uploads/2023/05/FAQs-on-the-Guidelines-on-Administrative-Fines-.pdf)
- [FAQ — NPC Circular 2023-06 (Security of Personal Data)](https://privacy.gov.ph/wp-content/uploads/2024/12/v12-19-2024_FAQ-NPC-Circular-2023-06_NNJ_JDN.pdf)
- [NPC Advisories and Circulars index](https://privacy.gov.ph/pips-and-pics/advisories-circulars/)
- [NPC Advisory Opinions index](https://privacy.gov.ph/pips-and-pics/advisory-opinions/)
- [NPC — Cease and Desist Order against Tools for Humanity (Oct. 2025)](https://privacy.gov.ph/npc-issues-cease-and-desist-order-against-tools-for-humanity/)
- [Tools for Humanity CDO, CID-CDO-25-001 (23 Sept. 2025) (PDF)](https://privacy.gov.ph/wp-content/uploads/2025/10/FINAL-2025.09.23-Cease-and-Desist-Order-CID-CDO-25-001-Application-for-Issuance-of-Cease-and-Desist-Order-for-In-the-Matter-of-World-App-Processing-of-Personal-Information_SGD.pdf)

**Philippines — secondary (used to verify NPC issuances)**
- [Baker McKenzie / GCN — NPC Circular 2023-07 on legitimate interest](https://www.globalcompliancenews.com/2024/01/22/https-insightplus-bakermckenzie-com-bm-data-technology-philippines-national-privacy-commission-issues-guidelines-on-the-processing-of-personal-information-based-on-legitimate-interest_01092024/)
- [Baker McKenzie / GCN — NPC Advisory 2024-02 on Sec. 13(f)](https://www.globalcompliancenews.com/2024/09/17/https-insightplus-bakermckenzie-com-bm-investigations-compliance-ethics-philippines-npc-issues-new-guidelines-on-the-processing-of-sensitive-personal-information-for-legal-claims_09042024/)
- [Baker McKenzie / GCN — Administrative fines under Circular 2022-01](https://www.globalcompliancenews.com/2022/08/23/philippines-administrative-fines-for-data-privacy-infractions-to-be-imposed-starting-27-august-2022-160822/)
- [Baker McKenzie / GCN — NPC Circular 2022-04 registration](https://www.globalcompliancenews.com/2023/01/14/https-insightplus-bakermckenzie-com-bm-technology-media-telecommunications_1-philippines-new-npc-circular-on-registration-of-data-protection-officers-and-data-processing-systems-takes-effect_0111202/)
- [Baker McKenzie / GCN — Minimum security requirements, Circular 2023-06](https://www.globalcompliancenews.com/2024/04/19/https-insightplus-bakermckenzie-com-bm-data-technology-philippines-minimum-requirements-for-security-of-personal-data-issued-by-the-national-privacy-commission_04032024/)
- [Baker McKenzie Connect on Tech — Data sharing agreement not mandatory per the NPC](https://connectontech.bakermckenzie.com/philippines-data-sharing-agreement-not-mandatory-per-the-npc/)
- [BCCS Law — NPC Advisory 2024-01, model contractual clauses](https://bccslaw.com/npc-advisory-no-2024-01-model-contractual-clauses-for-cross-border-transfers-of-personal-data/)
- [Linklaters — Data Protected: Philippines](https://www.linklaters.com/en/insights/data-protected/data-protected---philippines)
- [DLA Piper — Registration requirements, Philippines](https://www.dlapiperdataprotection.com/?t=registration&c=PH)
- [ACCRALAW — Staying in Control: The Rights of Data Subjects](https://accralaw.com/2021/02/23/staying-in-control-the-rights-of-data-subjects/)
- [Biometric Update — Philippines orders halt to World biometrics processing](https://www.biometricupdate.com/202510/philippines-privacy-authority-orders-halt-to-world-biometrics-processing)
- [DOLE Labor Advisory No. 06-20 — Final Pay and Certificate of Employment](https://dole.gov.ph/news/labor-advisory-no-06-20-guidelines-on-the-payment-of-final-pay-and-issuance-of-certificate-of-emplo/)
- [Credit Information Corporation — RA 9510 overview](https://cic.gov.ph/republic-act-no-9510-credit-information-system-act-cisa/)

**Cross-border transfer**
- [EDPB — EU-US Data Privacy Framework FAQ (version 2.0)](https://www.edpb.europa.eu/documents/other-guidance/eu-us-data-privacy-framework-faq-for-european-individuals-version-20_en)
- [European Commission — EU-US Data Privacy Framework](https://www.data-privacy-framework.com/European_Commission_Data_Privacy_Framework.html)
- [IAPP — European Commission adopts EU-US adequacy decision](https://iapp.org/news/a/european-commission-adopts-eu-u-s-adequacy-decision)
- [GlobalDataShield — EU-US Data Privacy Framework in 2026 (Latombe appeal status, C-703/25 P)](https://globaldatashield.com/blog/eu-us-data-privacy-framework-2026)
- [dataprivacyframework.gov — Self-Certification Information (HR data commitments, DPA panel)](https://www.dataprivacyframework.gov/program-articles/Self-Certification-Information)

**EU AI Act (adjacent, flagged for separate research)**
- [Ogletree — EU Nears Approval of Agreement to Delay Rules for AI Use in Employment Decisions](https://ogletree.com/insights-resources/blog-posts/eu-nears-approval-of-agreement-to-delay-rules-for-ai-use-in-employment-decisions/)

**Internal**
- `/Users/kylechoy/Desktop/Programming Projects/Personal/grain/docs/decisions/fcra-employment-agency-positioning.md`
