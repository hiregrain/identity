# Jurisdictional recordkeeping and automated-decision duties

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Companion to `research/13`.** Where 13 answers two questions in depth, namely
whether an AI Act logging duty may defeat the erasure right and whether there
is any lawful basis to retain a link across deletion to stop reset gaming,
this file records the jurisdictional sweep that ran alongside it: who actually bears a recordkeeping
duty, what regulators have and have not said, and which of the repo's premises
turned out to be stale.

Researched 2026-08-18 across four parallel threads against primary sources.
Retrieval caveats are stated at the point of use and collected in §6. Where a
thread reported a negative, it is marked as a negative *finding* only if the
source was actually retrieved; unretrieved items are marked as such.

---

## 1. The duty-holder question: almost nowhere does a scoring vendor bear it

This is the most useful single result, because Grain's regulatory exposure has
been reasoned about as though the obligations of an employment selection
procedure attach to whoever built it. Across six US regimes, they do not.

**EEOC, 29 C.F.R. §1602.14.** The preservation duty runs to "an employer" and,
in the litigation-hold sentence, to "the respondent employer", repeatedly and
exclusively. §1602.12 confirms the Commission "has not adopted any requirement,
generally applicable to employers, that records be made or kept"; §1602.14 is a
preservation rule, not a creation rule. A vendor is reached only derivatively,
through the statutory "any agent of such a person" in 42 U.S.C. §2000e(b), which is the
same agent theory that carried *Mobley v. Workday*, or by being named a
respondent itself.

**UGESP, 29 C.F.R. Part 1607.** The recordkeeping duties in §§1607.4 and 1607.15
attach to a "user", defined at §1607.16(W) as "any employer, labor organization,
employment agency, or licensing or certification board... **which uses** a
selection procedure as a basis for any employment decision." The list is closed
and the operative verb is *uses*. A vendor that scores and sells the score does
not make the employment decision. The confirmatory textual signal is
§1607.15A(3)(b), which treats "consultant reports of validity" as something the
*user* maintains, so the vendor is a source of documentation, not a duty-holder.
Note also §1607.16(S): UGESP say "should", not "shall"; they are interpretive
guidelines, which makes them a weak foundation for any argument that leans on
them as a mandatory obligation in either direction.

**This corrects `THESIS.md` §5.** The thesis states that results used in hiring
bring "Uniform Guidelines validity and adverse-impact obligations in the US" in
a way that reads as though they bind Grain. They bind the customer. Grain
supplies the validity documentation the customer needs. That is a materially
better position than the sentence implies, and it should be stated precisely
rather than conservatively.

**NYC Local Law 144, 6 RCNY §§5-300–5-304.** Every operative sentence in statute
and rule reads "an employer or employment agency." DCWP's own FAQ is explicit:
"The vendor that created the AEDT is not responsible for a bias audit of the
tool." The only retention-shaped duty is §5-303(c), which requires the *audit
summary* to stay posted for six months after last use. A posting duration over
aggregate data, not a record-retention duty and not person-level. §5-300's
independent-auditor definition disqualifies anyone with an employment
relationship with the vendor, so Grain cannot audit its own tool even
voluntarily. (There is no §5-305; the rule runs 5-300 to 5-304.)

**Illinois, 775 ILCS 5/2-102(L).** A prohibition and a notice duty, both
addressed to "an employer". No vendor duty and no retention duty. The general
IHRA preservation rule at 56 Ill. Adm. Code §2520.110 binds employers, labor
organizations, employment agencies, and, once served, respondents. IDHR
rulemaking on AI is **unverified**: law-firm secondary sources report a proposed
"Subpart J" published 15 May 2026 and postponed 2 June 2026, but no AI subpart
appears in the adopted code and IDHR's own site was unreachable.

**OFCCP, 41 C.F.R. §60-1.12.** Two-year preservation, but of records "made or
kept by the contractor" about its own applicants and employees. A vendor is
covered only as a subcontractor whose services are "necessary to the
performance" of a federal contract, which selling assessment software ordinarily
is not. Status caveat: **EO 11246 was revoked by EO 14173 (21 January 2025)**; a
rescission NPRM published 1 July 2025 with comments extended to September 2025,
and no final rule had issued as of this research. The regulation is nominally on
the books with its enforcement authority removed.

### 1.1 The exception, and it is the one that matters

**Colorado is the single US regime that binds Grain directly, and the statute
the repo would have been reasoning about no longer exists.** SB 24-205 was
delayed from 1 February 2026 to 30 June 2026 by SB 25B-004, then **repealed and
reenacted by SB 26-189, "Automated Decision-Making Technology", signed 14 May
2026**. Per the enrolled act's SECTION 5, it takes effect **1 January 2027** and
applies to consequential decisions made on or after that date.

Grain is a *developer* under §6-1-1701(8)(a), meaning a person that "develops, offers,
sells, leases, licenses, or otherwise makes commercially available a covered
ADMT", because §6-1-1701(2)(a) defines ADMT to include technology generating
"predictions, recommendations, classifications, rankings, **scores**" used to
guide a decision about an individual, and §6-1-1701(6)(b) makes employment a
covered domain.

§6-1-1702(4) verbatim: a developer "SHALL RETAIN, FOR NOT LESS THAN THREE YEARS
AFTER THE CREATION OF A RECORD... RECORDS REASONABLY NECESSARY TO DEMONSTRATE
COMPLIANCE WITH THIS SECTION. RECORDS INCLUDE SYSTEM VERSION IDENTIFIERS,
CHANGELOGS, AND DOCUMENTATION AND NOTICES OF MATERIAL UPDATES PROVIDED TO
DEPLOYERS."

**Read what the enumerated records are.** System version identifiers,
changelogs, deployer notices. Artifacts about the *system*. Nothing in
§6-1-1702 requires a developer to retain any record about a scored person. The
deployer duty at §6-1-1703 runs three years from *the date of a consequential
decision*, which is person-linked, while the developer clock runs from *creation of the
record*, which is system-linked. That asymmetry is deliberate and it is the whole
finding: **the one jurisdiction that imposes a retention duty on Grain imposes
it over system artifacts, not over people.**

California converges. 11 CCR §7101 requires 24 months of records of *consumer
requests and responses*, and §7101(e) says expressly that a business "is not
required to retain personal information solely for the purpose of fulfilling a
consumer request." §7155(c) requires risk assessments for five years, again
about the processing. Article 11's ADMT compliance date is also 1 January 2027
(§7200(b)). Whether Grain is a CCPA "business" or a "service provider" is
fact- and contract-dependent and no primary text resolves it: processing on an
employer's behalf under a §7051 contract makes it a service provider with a
§1798.105(c)(3) shield against direct consumer deletion requests; building and
retaining its own cross-employer capability graph likely makes it a business in
its own right, picking up the whole Article 11 stack.

### 1.2 The characterisation risk that changes a ruling

UGESP excludes a vendor only while it stays a vendor. **42 U.S.C. §2000e(c)
defines an "employment agency" as any person regularly undertaking "to procure
employees for an employer *or to procure for employees opportunities to work for
an employer*."**

The second limb is a precise description of a worker-facing job-suggestion
surface. Surfacing opportunities to a worker was reasoned about in this repo as
the neutrality-preserving direction. Grain ranks roles for a person, never
people for an employer. In US law it is the opposite: it is the limb that makes
Grain a covered entity in its own right, a "user" under UGESP, and a duty-holder
under §1602.14 rather than a vendor supplying documentation to one.

**This is unruled and needs to be**, because it inverts the reasoning behind a
position already taken. It does not make the surface unlawful; it makes it
expensive and changes who carries the obligations.

---

## 2. India: the one hard retention floor found anywhere

**DPDP Rules 2025, notified by G.S.R. 846(E), 13 November 2025.** Rule 8(3)
verbatim:

> "a Data Fiduciary shall retain, in respect of any processing of personal data
> undertaken by it or on its behalf by a Data Processor, such personal data,
> associated traffic data and other logs of the processing for a minimum period
> of one year from the date of such processing, for the purposes as specified in
> the Seventh Schedule, after which the Data Fiduciary shall cause such personal
> data and logs to be erased, unless further retention is required for
> compliance with any other law..."

The illustration removes any doubt about the interaction with deletion: the
platform "must retain the order details, personal data, and logs of the
processing... for at least one year from the date of the transaction, **even if
X deletes her account**." A second, independent one-year duty sits in Rule
6(1)(e) for security logs.

Rule 8(1) and the Third Schedule impose a separate three-year
inactivity-erasure regime, but only on large e-commerce, online-gaming, and
social-media intermediaries. A work-history scoring vendor falls outside the
Third Schedule and inside Rules 8(3) and 6(1)(e).

Commencement: Rules 3 and 5–16 come into force eighteen months after publication,
approximately **14 May 2027**.

**A drafting ambiguity worth flagging to counsel.** Rule 8(3)'s operative words
impose the duty on "a Data Fiduciary" generally, and its illustrations apply it
to a commercial platform and a cloud processor. Its purpose clause, however,
cross-refers to the Seventh Schedule, whose three purposes are all State-facing.
On the face of the text the duty is general and the Schedule states why the data
is held rather than who must hold it, but MeitY has not clarified.

**This vindicates decision 014's escalation #1**, which named India DPDP Rule
8(3) as creating a retention obligation in tension with R2 before the rule text
was in hand. "Delete means gone" cannot be a global invariant. It can be a
regional one.

Retrieval note: one thread reached the official MeitY gazette PDF by direct
fetch and quoted it; a second could reach only a secondary mirror it distrusted
and asked for verification. Two independently obtained texts agree. Treat as
reliable, verify before counsel.

---

## 3. Philippines and UK

**Philippines: no fixed retention floor, but the broadest erasure-refusal
grounds of any jurisdiction surveyed.** NPC Circular 16-01 is repealed; NPC
Circular 2023-06 §29 governs log retention and sets no period, requiring only
that it be "as long as deemed necessary and appropriate based on best practices
and industry standards", with NPC power to compel longer for incident logs. The
DPA 2012 IRR contains no access-log retention duty for private controllers.

Erasure refusal runs through **NPC Advisory 2021-01 §10(B)(2)**, whose grounds
include "(b) Compliance with a legal obligation which requires personal data
processing" and, notably wider than anything in the EU, "(d) Legitimate
business purposes of the PIC, consistent with the applicable industry standard
for personal data retention."

**NPC Advisory No. 2024-04 (19 December 2024)** applies the DPA to AI systems.
§2(B)(a) requires mechanisms for meaningful human intervention and for data
subjects to question and contest automated decisions where the effect poses a
significant risk. §3 requires effective mechanisms to give effect to the rights
to object, rectify, and erase, and, directly relevant, states that where a
request is not feasible the controller must say so and its reasons, and must
still carry out the intended effect of the right as far as possible. No separate
NPC AI circular exists. **NPC Circular 2022-04** carries a notification duty for
automated decision-making and profiling that a PH deployment would need to check.

**UK: Article 22 has been replaced, and it is already in force.** DUAA 2025
s.80 substituted new UK GDPR **Articles 22A–22D**, commenced **5 February 2026**
by SI 2026/82, applying only to decisions taken on or after that date. Art. 22A
defines a "significant decision" and makes meaningful human involvement the test
for "solely automated". Art. 22B restricts solely-automated significant
decisions based on special-category data. **Art. 22C is the safeguards
provision**: where a significant decision is based solely on automated
processing, the controller must provide information about the decision, enable
representations, enable human intervention, and enable contest.

DUAA adds **no new retention or logging duty**, and leaves Article 30
unamended; the DPDI Bill's lighter records-of-processing regime was dropped. ICO's final
ADM guidance is **not yet published**; a consultation ran 31 March to 29 May 2026
and the live guidance still describes the pre-DUAA regime.

**Consequence for the repo:** `THESIS.md` §10 lists an Article 22 brief as never
scoped. In the UK the article it would have been about no longer exists in that
form, and the successor imposes an inform-and-contest duty that sits awkwardly
beside the ruling that workers never see when analytics are run on them,
though the duty falls on whoever takes the decision, which is the employer.
That allocation is exactly what the brief should establish.

---

## 4. The regulator sweep: nobody has answered the question

Searched for any regulator statement that a logging obligation defeats an
erasure request. Across EDPB, EDPS, CNIL, the Irish DPC, the Spanish AEPD, the
German DSK, Hamburg, and the ICO, there is **one**: a footnote.

**DSK, *Orientierungshilfe zu... KI-Systemen*, June 2025, footnote 20**: "For
example, logging obligations and other statutory requirements may stand in the
way of erasure requests." It names no statute, cites Art. 17(2) and (3)
generically rather than 17(3)(b), and says nothing about the AI Act. The same
document sets a demanding bar on what erasure means: "technically a complete
erasure", covering inputs and outputs and the model itself where it contains the
information, and says training and log data "are to be treated like
conventional data."

**CNIL's framing cuts against the easy version of the argument, in two ways.**
Its AI Act Q&A enumerates the points where the AI Act "extends and takes over
from the GDPR", and the list is only real-time biometric ID and special-category
data for bias detection. Logging is not on it. And its guidance on AI and data
subject rights routes statutory exclusions through **Article 23 GDPR**, a
legislative-restriction channel with its own conditions, not through Art.
17(3)(b).

CNIL is nonetheless the most operationally useful source found. **Délibération
2021-122 on journalisation** recommends six months to one year for log
retention, expressly recognises "a legal obligation to retain traces for a
precise duration laid down by law" as justifying a longer period (§20–21),
recommends that data-subject rights over logs be exercised against the
controller of the *main* processing (§13), and, closest to the technique Grain
needs, §22 recommends that where source data has a shorter life, "the log may
retain only pseudonymous identifiers, or identifiers for which re-identification
is particularly difficult", **"while preserving the integrity of the logs"**.
That proviso is the constraint an unresolvable-pointer design has to answer.

**ICO** frames the escape as a lawful-basis question: erasure must be considered
"unless you are processing the data on the basis of a legal obligation or public
task". **Irish DPC** and **AEPD** have published nothing on logging versus
erasure; AEPD's 2021 AI audit guide treats logs as an Art. 22 human-oversight
control and applies ordinary storage limitation to AI-generated data.

**EDPB Opinion 28/2024 points the other way**, twice: it lists allowing erasure
beyond what Art. 17(1) requires as a mitigating measure favouring the controller
(¶102(c), ¶107(b)), and warns that an AI Act self-declaration of conformity "may
not constitute a conclusive finding of compliance under the GDPR" (¶131).

**On the pseudonymisation technique, EDPB Guidelines 01/2025 are close to
dispositive.** Pseudonymised data becomes anonymous only if the anonymity
conditions are independently met, judged against means reasonably likely to be
used "by the controller **or by another person**", including sources outside the
controller's control. Deleting the referent does not anonymise a retained
pointer. The Guidelines do flag Arts. 11(2) and 12(2) GDPR as the one route by
which pseudonymisation lawfully limits Chapter III rights, which is worth pursuing.

**CEN-CENELEC JTC 21 draft standards on logging and traceability are
unretrievable**, member-restricted, and sold rather than published once final.
Everything available is third-party commentary.

---

## 5. What this forces

- **`THESIS.md` §5's UGESP sentence is imprecise and understates Grain's
  position.** The obligations land on the user; Grain supplies documentation.
- **`THESIS.md` §7 omits Colorado**, the only US regime binding Grain directly,
  from 1 January 2027, and should note that the OFCCP obligations are in limbo.
- **Worker-facing job suggestions need a ruling** before the surface is built,
  because §2000e(c)'s second limb makes them the trigger for employment-agency
  status.
- **The run-record design has a clean answer available**: Colorado requires
  system-level artifacts, California requires request/response records and risk
  assessments, and neither requires person-level retention. A run record holding
  requester, timestamp, and instrument and model versions satisfies every duty
  identified in this research. Retaining the output satisfies none of them.
- **R2 is regional, not global.** India will compel one year of retention
  surviving deletion from ~May 2027. Either the deletion promise is scoped by
  region, or the Indian rail is structured so the obligation never attaches.
- **The Article 22 brief should be rescoped** as a UK Art. 22C / EU Art. 22 /
  PH Advisory 2024-04 §2(B) question about who owes the inform-and-contest duty,
  Grain or the deployer.

---

## 6. Retrieval caveats

- India Rule 8(3): one thread reached the MeitY gazette PDF; another could not
  and used a secondary mirror with inconsistent internal numbering. Verify
  against G.S.R. 846(E) before counsel. Rule 8's commencement inferred from Rule
  1(4), not independently confirmed. The DPDP **Act's** own commencement
  notification (reported G.S.R. 843(E)) is secondary-sourced only.
- Illinois IDHR AI rulemaking: law-firm sources only; IDHR unreachable.
- 41 C.F.R. §60-1.12: eCFR Title 41 unavailable; text taken from the govinfo
  2025 annual edition plus a Federal Register sweep confirming no intervening
  final rule.
- Colorado SB 26-189: commencement read from the signed enrolled act (SECTION 5).
  One thread reported a different effective date from the bill's summary page;
  the enrolled text governs.
- NPC Advisory 2024-04 §3(C): extraction truncated mid-sentence; re-pull before
  quoting. NPC Circular 2022-04 identified but not read.
- ICO draft ADM guidance (April 2026 consultation draft): not read.
- EDPB Guidelines 01/2025: only the "version for public consultation" was
  located; no final post-consultation version found.
- AEPD's newer AI guidance, DSK's October 2025 RAG paper, and the
  Baden-Württemberg discussion paper: not reviewed.
- Most non-legislation.gov.uk primary sources sit behind bot challenges;
  re-verification needs a real browser.
