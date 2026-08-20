# Pre-claim employer-provided records in the United States

**Status:** Research memo, 2026-08-19. **Evidence tier: binds nothing.**
Produced by a background research agent against primary sources; not
counsel-reviewed and not read line-by-line by the session that filed it.
Its conclusions are indexed in `decisions/LOG.md#031`; where this memo and a
decision differ, the decision governs.

**Subject.** FCRA classification, state privacy statutes, and rights over
employer-supplied employment history held about a non-user. Written against
the employer-push design that decision 031 has since replaced. Its FCRA
analysis is the direct evidence for that ruling and its state-law survey,
antitrust finding and § 1681h(e) observation remain live under the new design.

**The agent was instructed not to defer to founder ruling R1** and did not.
Its conclusion that the employer-push mechanic creates consumer-reporting-agency
status at high confidence is the reason decision 031 exists.

**Known gaps**, recorded by the agent: the FTC TALX action details, *OOIDA v.
USIS* (10th Cir. 2008), and the status of the January 2025 DOJ/FTC worker
antitrust guidelines are unverified; the capacity-versus-subject-matter reading
of state employment-context exclusions is unsettled with no case law or agency
guidance anywhere. The session web-search budget was exhausted mid-research.

---

# Pre-claim employer-provided records in the United States

**Status:** Research memo, not legal advice. Not counsel-reviewed. Written 2026-08-19.
**Scope:** US federal and state law on the hospitality-vertical mechanic in which employers
transmit active roster data, meaning identifiers plus employment facts, about workers who are not
Grain users, have not consented, and do not know Grain exists.
**Relationship to the corpus:** builds on `research/01-regulatory-perimeter.md` §1 (FCRA),
`research/14` §1 (duty-holder analysis), `THESIS.md` §5 and §7. Where it disagrees, it says so.

---

## TLDR

**1. The mechanic is not barred anywhere in the United States. It is regulated everywhere,
and the regulation attaches at the moment of receipt, not at the moment of claim.** No federal
or state statute prohibits a third party from receiving employment history about a
non-consenting individual from that individual's employer. Every applicable regime instead
imposes duties, including status registration, notice, rights, and retention limits, that begin when
Grain holds the record, not when the worker claims it. Confidence: high.

**2. Pre-claim collection converts Grain from a hard FCRA case into an easy one.** Grain's
own corpus already concluded the ledger is a consumer reporting agency (`research/01` TLDR-1).
Pre-claim collection removes the last non-frivolous argument against that conclusion. Every
sitting entity that does exactly this mechanic, where the employer pushes roster/payroll records
about all employees and the platform furnishes them to third parties, operates as a registered CRA: Equifax's
The Work Number, Truework, Pinwheel. Every entity that credibly claims non-CRA status in the
adjacent market, Argyle being the clean example, rests that claim on the consumer initiating
and permissioning the connection to their own data. Pre-claim collection is definitionally the
first pattern and definitionally not the second. Confidence: high.

**3. Direct answer on the CRA question, without hedging: on the mechanic as described, Grain
is a consumer reporting agency and the roster attestation is a consumer report. Confidence:
high.** § 1681a(f) requires assembling information on consumers, for fees, for the purpose of
furnishing consumer reports to third parties. Grain assembles employment history; the analytics
product evaluates it; employers pay; the intended and marketed use is hiring. § 1681a(d)(1)(B)
covers any communication bearing on a consumer's character, general reputation or personal
characteristics used or *expected to be used* as a factor in eligibility for employment
purposes, and § 1681a(h) puts promotion, reassignment and retention inside "employment
purposes." Nothing in the FCRA conditions coverage on the consumer having a relationship with
the agency; § 1681a(c) defines "consumer" as "an individual," and § 1681a(g) defines "file" as
all information "recorded and retained" on a consumer "regardless of how the information is
stored." A never-claimed record is a file. R1 does not survive this mechanic.

**3a. The transaction-and-experience exclusion, the last structural argument, is closed by
direct FTC interpretation, not by inference.** FTC 2011 staff report comment 603(d)(2)(A)(i)-1E
addresses this fact pattern by name: an employer's reference communication to a CRA is excluded,
"**however, a communication of such information from a CRA to a potential employer is a consumer
report because the transactions or experiences referred to in the communication are not between
the job applicant and the CRA.**" The exclusion is defined by privity, protects the source, and
does not travel with the data. The Islinger opinion letter adds that an intermediary that
**retains and resells** is a CRA rather than a mechanical go-between. Confidence: high.

**3b. There is one provision the entire corpus has missed, and it describes the record layer
rather than the analytics product.** § 1681a(x)(4) makes an agency that "compiles and maintains
files on consumers on a nationwide basis relating to… **employment history**" a **nationwide
specialty consumer reporting agency**, owing free annual file disclosure under § 1681j(a)(1)(A)
and a streamlined request process including a **toll-free telephone number** under
§ 1681j(a)(1)(C). The FTC has charged this provision against TALX, the entity behind The Work
Number, on the identical mechanic. Confidence: high on the statute; medium on the TALX
enforcement details, which need verification. Note also that the widely repeated claim of a
*CFPB* action against The Work Number appears to be unsupported and should not be cited.

**4. R1's worker-publication theory is structurally unavailable for the pre-claim window, and
that window is the whole product.** The LinkedIn analogy requires a worker who authored or
directed the publication of content about themselves. During pre-claim there is no worker act
at all: the content is third-party-authored, platform-solicited, employer-transmitted, and the
subject is unaware. The theory cannot be repaired by a later claim, because CRA status is
determined by what the entity does, not by what the subject subsequently ratifies, and because
a worker who never claims never ratifies anything. Confidence: high on the reasoning; medium-high
that no court would entertain a retroactive-ratification argument, which is untested.

**5. Worker-controlled disclosure does not defeat CRA status and never has.** The corpus
already states this (`research/01` §1.4) and pre-claim collection strengthens it: consent
appears in the FCRA as a permissible purpose (§ 1681b(a)(2)) and as a user-side precondition
(§ 1681b(b)(2)), both of which presuppose CRA status. The FTC's position since *Filiquarian*
and *Instant Checkmate* (2013) is that self-labelling and disclaimers do not defeat the
definition. Confidence: high.

**6. California is the binding constraint on collection, and it has written two compliance paths
for this exact fact pattern.** The CPRA's employee and B2B exemptions became inoperative by their
own terms on 1 Jan 2023, though they were not repealed, and § 1798.145(m)(4) and (n)(3) still say
so, so employee data is fully in scope. "Consumer" is any California resident (§ 1798.140(i)); no
relationship is required. 11 CCR § 7012(d) makes a missing notice at collection a **bar on
collecting**, not a curable defect. § 7012(h) excuses only a business that neither collects
directly nor sells or shares, and Grain does both. That leaves two routes: **§ 7012(i)**, which
excuses a **registered data broker** collecting indirectly, and **Civ. Code § 1798.100(b)**, a
route the corpus would not have found, which lets a business that "acting as a third party,
controls the collection" satisfy the duty by a prominent, conspicuous **homepage notice**. The
second requires no registration and no employer cooperation and should be built regardless.
Confidence: high.

**6a. Grain is a CCPA third party, not a service provider, and the disqualifier is one sentence
that describes the product.** 11 CCR § 7051(a)(5) requires a service-provider contract to
prohibit "combining or updating personal information that it collected pursuant to the written
contract… with personal information that it received from another source." **A cross-employer
portable record is that combination.** No drafting fixes it. Two consequences: every employer's
transfer to Grain is a *sale or sharing* that the employer must disclose and opt-out-enable,
which is the objection every design partner's privacy counsel will raise, and § 1798.115(d)
independently **bars a third party from selling personal information it acquired unless the
consumer received explicit notice and an opportunity to opt out**, which is a flat prohibition
aimed at the resale leg. Confidence: high.

**7. Grain cannot escape both FCRA and the Delete Act; it must pick which one it is in.**
Civ. Code § 1798.99.80(c) excludes from "data broker" an entity "to the extent that it is
covered by" the FCRA. So the two regimes are near-alternatives on the same activity. Being a
CRA buys partial Delete Act relief and costs the full §§ 1681b/e/g/i/k/s-2 stack. Not being a
CRA buys nothing and costs Delete Act registration, DROP polling every 45 days, and deletion
within 45 days, which is a direct hit on the permanent-record thesis. There is no third door.
Confidence: high on the statutory structure; medium on how cleanly the "to the extent"
scoping partitions Grain's mixed activity, which is genuinely unsettled.

**8. The Delete Act path, if taken, is the single largest product collision in this memo.**
Since 1 Jan 2026 any California resident can file one DROP request that reaches every
registered broker; from 1 Aug 2026 brokers must poll DROP at least every 45 days and delete
within 45 days. A worker who has never heard of Grain can therefore delete their Grain record
without ever learning it existed. That is not compatible with "the record layer is permanent."
Penalties are $200/day for non-registration and $200/day per consumer for non-deletion, and
the CPPA has already shut a broker down entirely (Background Alert, 2025). Confidence: high.

**9. The employer's side is the most permissive part of the analysis, for the employment facts.
The contact identifiers are the exposed element, and they are the ones the mechanic needs.**
Dates, title, role and employment status are the least protected employment facts in American
law: Connecticut, the strictest state verified, requires written employee authorisation for
third-party disclosure of personnel-file information but exempts disclosure "limited to the
verification of dates of employment and the employee's title or position and wage or salary."
**Personal phone and email fall outside that carve-out**, since they are individually identifiable
personnel-file information that is neither dates, title, nor wage. Since the identifiers are what
makes a future claim possible, Connecticut's carve-out shelters the part of the payload Grain
cares least about and not the part the mechanic depends on. Michigan and Illinois reach
disciplinary records only, so they are dormant on this payload and activate the instant it
thickens. **Any enrichment beyond dates/title/role (outcomes, scores, terminations,
`dimensions_exercised`) leaves every shelter at once.** Confidence: high on Connecticut,
Michigan and Illinois (text verified); medium on the remaining personnel-record states.

**10. Reference-immunity statutes probably do not cover this, and that matters for partner
recruitment more than for Grain.** Those statutes are almost uniformly conditioned on a
disclosure made *to a prospective employer* *upon request* about a *former* employee. Bulk
transmission of a live roster to a platform matches none of the three conditions. The employer
therefore gives up statutory immunity when it connects its HRIS, and retains only common-law
qualified privilege whose "common interest" element is strained by a broadcast-to-many-future-readers
architecture. This is a sales objection as much as a legal one. Confidence: medium-high on the
statutory conditions; medium on the qualified-privilege outcome, which is state-specific and
unlitigated in this posture.

**11. An unclaimed subject has full statutory rights, all eight CCPA deletion exceptions fail,
and the product's natural design violates a specific statutory prohibition.** Access, deletion,
correction and opt-out rights attach to residents regardless of relationship. Every
§ 1798.105(d) exception was checked against the text and none covers the model; exception (7),
solely internal uses aligned with the consumer's expectations based on the consumer's
*relationship* with the business, is the statute's own answer to the pending-claim theory, and
the answer is no. Verification of a no-account requestor runs through 11 CCR § 7062, whose
sliding standard at § 7062(d) does defensibly permit lighter verification for deletion than for
disclosure, because erroneous deletion harms the business rather than the consumer. But two traps
are exact: **§ 7060(b) forbids verifying an opt-out request at all**, so the one request Grain must
honour blind is the one that removes the record's revenue, and the CPPA's *Honda* ($632,500) and
*Todd Snyder* ($345,178) orders both turned on precisely this, and **Civ. Code
§ 1798.130(a)(2)(A) prohibits requiring account creation to make a request**, which means
**Grain's "claim your record" flow cannot be the gateway to exercising rights.** That is exactly
the default a claim-based product will build. Confidence: high.

**11a. Grain's weak identifiers create an FCRA accuracy problem on top of a CCPA one.** Grain
holds employer-supplied name, phone and possibly email and nothing else, so verification
collapses into "does the claimant know their own name and phone." That is the weak matching
`research/03` §1 warns produces mixed files, now on a population that cannot self-correct
because it does not know the record exists. Demanding an ID scan to fix it fails § 7060(c)(1),
(c)(2), (d) and § 7002(d)(1) simultaneously, **and would convert a dataset with no § 1798.150
private-right-of-action exposure into one that has it.** The correct design is challenge-response
against the identifier already held, plus a penalty-of-perjury declaration for specific pieces.
Confidence: high.

**12. Indefinite "pending claim" retention is not defensible, and the consent cure is
structurally unreachable.** § 1798.100(a)(3) requires a retention period or criteria and forbids
retention "for longer than is reasonably necessary." "Indefinite" is neither a period nor a
criterion, and "until she claims it" is circular. A condition the subject does not know exists
produces a functionally infinite period. **All five 11 CCR § 7002(b) reasonable-expectations
factors run against the pre-claim population**, and § 7002(e)'s consent cure cannot be reached:
the employer cannot consent for the worker, and § 7063 requires the consumer's own signed
permission. Maryland's MODPA is harder still. § 14-4607(b)(1)(i) measures necessity against "a
specific product or service **requested by the consumer**," and no disclosure or employer
contract can satisfy a test anchored to a request that does not exist. If Grain is a CRA,
§ 1681c(a)(5)'s seven-year rule independently caps *reportability* of adverse items. Confidence:
high that indefinite retention as described is non-compliant; medium-high on the bounded-period
cure.

**13. The antitrust exposure is real, materially underrated in the corpus, and structurally
unfixable without changing the product.** A neutral intermediary collecting current,
person-level, non-anonymised employment data from competing employers in one metropolitan labour
market and selling capability analytics back to them matches every structural factor in
*Todd v. Exxon*, 275 F.3d 191 (2d Cir. 2001), where third-party administration did not save the
exchange at the pleading stage. DOJ and FTC withdrew the 1996 Statement 6 safety zones in 2023,
so there is no harbour to design into, and the **May 2026 proposed final judgment in
*United States v. Agri Stats*** now states the agencies' current remedy set: no company-level
data, information at least 45 days old on average, symmetric availability, and a monitoring
trustee. **Grain can satisfy none of those without ceasing to be Grain. Re-identification is
not a risk to be mitigated, it is the product.** The one genuine defence is that no located
authority treats non-wage employment data as a § 1 problem; that is unlitigated territory, not
safe territory. Confidence: medium-high that the theory survives a motion to dismiss; medium on
ultimate liability; low-medium on how the agencies treat non-wage worker data, where nothing
exists.

**14. Automated-employment-decision law bites the customer, not Grain, with one exception the
corpus underweights: California FEHA makes Grain the defendant.** `research/14` §1's duty-holder
finding holds for NYC LL 144, Illinois, UGESP and EEOC recordkeeping. Colorado is now smaller
than the corpus records: SB 24-205 was repealed and reenacted as **SB 26-189, effective 1 January
2027**, which **dropped the algorithmic-discrimination duty and the impact assessments** and left
a disclosure-and-process regime. The real vendor exposure is California: the **FEHA ADS
regulations effective 1 October 2025** define "agent" to include a person exercising an employer
function "through the use of an automated decision system" and make that agent a statutory
employer, which, together with *Raines*, 15 Cal.5th 268 (2023), and *Mobley v. Workday* (ADEA
collective certified May 2025, applicant coverage upheld March 2026), gives three independent routes to
direct vendor liability. Pre-claim collection does not change any of this; it worsens the Title
VII input-quality problem underneath it. Confidence: high.

**15. The mechanic contradicts a ratified internal contract.** `model/attestation-interface.md`
(schema_version 0.2, RATIFIED, decision 006) states: "A person without a ledger ID cannot be
attested for; the attestation waits until the reference exists." The hospitality mechanic
requires attesting about people with no ledger ID. Either the interface amends, or the mechanic
does not ship as described. Nothing else in the corpus addresses pre-claim collection at all;
this memo is greenfield against it.

---

## 1. Legal basis and permissibility of collection

**Conclusion: permissible, conditioned. No US statute bars the receipt. Four regimes impose
conditions that attach at receipt.**

### 1.1 There is no federal collection bar

The United States has no general-purpose data protection statute and no federal law
conditioning the collection of employment history on subject consent. The FCRA, the closest
federal analogue, is deliberately a *use and disclosure* statute, not a collection statute.
This is why The Work Number lawfully ingests payroll records for roughly 190 million records
without employee consent: the statute does not regulate the intake, it regulates who may pull
the file and what the consumer may do about it
([15 U.S.C. § 1681b](https://www.law.cornell.edu/uscode/text/15/1681b);
[CFPB, The Work Number](https://www.consumerfinance.gov/consumer-tools/credit-reports-and-scores/consumer-reporting-companies/companies-list/work-number/)).

This is the single most important structural fact in the memo and it cuts both ways. Collection
is lawful. Collection is also what makes you a CRA.

Confidence: high.

### 1.2 California reaches Grain from the first record

**"Consumer" means resident, not customer.** Cal. Civ. Code § 1798.140(i): "a natural person who
is a California resident, as defined in Section 17014 of Title 18 of the California Code of
Regulations… however identified, including by any unique identifier." Residency is the only
criterion. The unclaimed-record population is a full rights-holder population from day one
([§ 1798.140](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.140)).

**California employee data is fully in scope, with one precision.** The HR and B2B exemptions
at former § 1798.145(m) and (n) were **not repealed**. They remain printed in the code and are
self-executing: "This subdivision shall become inoperative on January 1, 2023" appears at
§ 1798.145(m)(4) and (n)(3). Same practical result, but cite it correctly. A narrow residual
survives at § 1798.145(m)(1) for emergency-contact and benefits-administration purposes only,
which does not reach a portable-record product. Confidence: high.

### 1.3 Notice at collection: the duty attaches, and there are two escape routes

Cal. Civ. Code § 1798.100(a)(1)–(3) requires categories, purposes, sale/share status, and
retention period-or-criteria, "at or before the point of collection." The regulations then
address indirect collection, and **11 CCR § 7012(d) makes the consequence severe rather than
curable**: "If a business does not give the Notice at Collection to the consumer at or before
the point of collection… the business shall not collect personal information from the consumer."
That is a prohibition on collecting, not a duty to notify late.

Three subsections then define the available positions:

- **§ 7012(h)**, verbatim: "A business that neither collects nor controls the collection of
  personal information directly from the consumer does not need to provide a Notice at
  Collection to the consumer **if it neither sells nor shares** the consumer's personal
  information." **Unavailable to Grain.** Disclosing a worker's record to employers for monetary
  or other valuable consideration is a "sale" under § 1798.140(ad).
- **§ 7012(g)**: where more than one business controls collection, **both** must give notice,
  and they "may provide a single Notice at Collection that includes the required information
  about their collective information practices." This is the "rely on the employer's notice"
  route, and it is worse than it sounds, since it requires every connected employer's HR notice to
  carry *Grain's* own § 7012(e)(1)–(6) disclosures. It fails silently at scale, on the day one
  partner's HR team updates a template.
- **§ 7012(i)**, verbatim: "A data broker registered… pursuant to Civil Code section 1798.99.80
  et seq. that collects personal information from a source other than directly from the consumer
  does not need to provide a Notice at Collection to the consumer **if it has included in its
  registration submission a link to its online privacy policy that includes instructions on how
  a consumer can submit a request to opt-out of sale/sharing.**"

**There is a fourth route the corpus would not have found, and it is the only one entirely
within Grain's control.** Cal. Civ. Code § 1798.100(b): a business that, "acting as a third
party, controls the collection of personal information about a consumer may satisfy its
obligation under subdivision (a) by providing the required information prominently and
conspicuously on the homepage of its internet website." Grain is a third party (§ 1.4 below) and
does control the collection. **A conspicuous homepage notice-at-collection is therefore a
statutory compliance path that requires neither data-broker registration nor employer
cooperation.** It should be built regardless of which status Grain elects.

**Contractual attestation from the employer is not notice.** Attestation appears at 11 CCR
§ 7053(a)(4) as the *disclosing* party's diligence right, not as a notice-satisfaction mechanism
for the recipient. Any plan that says "the employer warrants it told its employees" solves a
different problem than the one § 1798.100 poses.

Note the operative regulation version: the OAL-approved package effective **1 January 2026**
(adopted 24 July 2025, OAL-approved 22–23 September 2025). § 7012 still runs (a)–(i) and the
indirect-collection subdivisions are textually unchanged from the 2023 text
([CPPA approved text](https://cppa.ca.gov/regulations/pdf/ccpa_updates_cyber_risk_admt_appr_text.pdf);
[rulemaking page](https://cppa.ca.gov/regulations/ccpa_updates.html)).

Confidence: high, since all three subsections were verified against the approved regulatory text.

### 1.4 Third party vs service provider vs contractor

This is the classification that determines whether Grain carries CCPA obligations in its own
right, and `research/14` already flagged it as unresolved and contract-dependent. The pre-claim
mechanic resolves it against Grain.

- A **service provider** (§ 1798.140(ag)) or **contractor** (§ 1798.140(j)) processes personal
  information *on behalf of* a business under a contract carrying the ten terms at 11 CCR
  § 7051(a).
- **The dispositive term is § 7051(a)(5)**, which requires that a service provider "shall be
  prohibited from combining or updating personal information that it collected pursuant to the
  written contract with the business with personal information that it received from another
  source." **A cross-employer portable worker record is that combination.** Service-provider
  posture and the product thesis are mutually exclusive, and no drafting fixes it.
- § 7050(a)(3)'s "improve the quality of services" safe harbour does not rescue it; its own
  example forbids compiling addresses received from businesses to sell onward.
- § 7050(e): a person without a compliant § 7051(a) contract "is not a service provider or a
  contractor," and the business's disclosure to it "may be considered a sale or sharing."
- § 7050(d): a service provider that is itself a business must comply with the CCPA in full "with
  regard to any personal information that it collects, maintains, or sells outside of its role."

**Grain is a third party with respect to employer-supplied roster data, and a business in its
own right with respect to the ledger it builds from it. Confidence: high**, since the
disqualification is textual, not judgmental.

Three consequences, in order of how much they hurt:

1. **The employer's transfer to Grain is a sale or sharing.** The employer must disclose it, post
   a "Do Not Sell or Share My Personal Information" link, honour opt-out preference signals
   (§ 7025), and forward opt-outs to Grain. **This is the objection every design partner's
   privacy counsel will raise**, and it is a sales problem before it is a legal one.
2. **§ 1798.115(d) is a flat bar on the resale leg.** A third party may not sell personal
   information it acquired unless the consumer received explicit notice and an opportunity to opt
   out. Aimed squarely at a business that receives data from one party and monetises it toward
   others. This provision alone requires the notice route in § 1.3 to be solved before launch,
   not after.
3. Grain cannot shelter behind § 1798.105(c)(3), which shields a service provider from direct
   consumer deletion requests.

Note the asymmetry that makes the third-party path workable: the third-party contract terms at
11 CCR § 7053(a) are six terms: specific non-generic purpose, use limited to those purposes,
CCPA compliance and equivalent protection, a right to take reasonable steps to verify compliance
including attestation, a right on notice to stop and remediate, and a duty to notify on inability
to comply. **§ 7053 contains no no-sale, no-combining and no-secondary-use terms.** Third-party
status is compatible with the product thesis in a way service-provider status structurally is
not. Grain should paper the ingest as a third-party arrangement deliberately, rather than
attempting service-provider language the facts contradict, since a contract contradicted by the
facts is worse than no contract in an enforcement posture.

*Citation hygiene:* there is no 11 CCR § 7052; the article runs 7050 → 7051 → 7053.

### 1.5 The other comprehensive states

**The single highest-leverage open legal question in this memo is whether the other states'
employment-context exclusions reach Grain at all.** It determines whether roughly nineteen states
apply or only California, and it is genuinely unsettled.

Every non-California comprehensive law excludes individuals acting in a commercial or employment
context. **The exclusion is framed by the capacity in which the individual acts, not by the
subject matter of the data:**

- **Va. Code § 59.1-575:** "a natural person who is a resident of the Commonwealth **acting only
  in an individual or household context**. It does not include a natural person acting in a
  commercial or employment context."
  ([text](https://law.lis.virginia.gov/vacode/title59.1/chapter53/section59.1-575/))
- **C.R.S. § 6-1-1303(6):** an individual "acting only in an individual or household context,"
  and not one "acting in a commercial or employment context, **as a job applicant**, or as a
  beneficiary of someone acting in an employment context." Colorado's express job-applicant
  exclusion is the most adverse text located.
- **Md. Com. Law § 14-4601(h)(2):** excludes an individual acting in a commercial or employment
  context, or acting as an employee or contractor of a company **"whose communications or
  transactions with a controller occur only within the context of the individual's role."**

Maryland's second clause makes the capacity framing explicit, and it cuts Grain's way: **a worker
who has no communications or transactions with Grain at all cannot be excluded by a clause about
communications within a role.** The argument generalises. The worker is not "acting" in any
capacity toward Grain, because she is not acting toward Grain at all, so she is a consumer and
the employment exclusion does not reach her.

The contrary reading, that the exclusion attaches to employment *subject-matter* data wherever
it travels, is available on Virginia's and Colorado's bare text and is harder to square with
"acting." No AG guidance or case law resolves it. **Plan for the adverse reading, which is the
one that produces nineteen-state exposure.** Confidence: low-medium either way. This is the
question most worth an outside opinion.

The other statutory features that engage:

- **Maryland (MODPA), effective 1 October 2025, is the hardest standard in the country and
  probably a categorical bar.** § 14-4607(b)(1)(i) requires a controller to "limit the collection
  of personal data to what is reasonably necessary and proportionate to provide or maintain **a
  specific product or service requested by the consumer to whom the data pertains**." Unlike
  California, Colorado and Virginia, which measure necessity against the *controller's disclosed
  purposes*, Maryland measures it against **a consumer request**. Grain's pre-claim subjects
  requested nothing. **There is no disclosure Grain can write and no employer contract Grain can
  sign that satisfies a test anchored to a request that does not exist.** § 14-4607(a)(3) also
  imposes a flat prohibition on selling sensitive data with no consent cure. If the capacity
  question above goes against Grain, Maryland forecloses the mechanic in Maryland.
- **Oregon, ORS § 646A.574**, uniquely entitles a consumer to a list of the **specific third
  parties**, not merely categories, to which the controller disclosed their personal data.
  Grain would have to name every employer that read a record.
- **Profiling opt-outs.** The Colorado/Connecticut/Virginia/Oregon family gives a right to opt out
  of profiling in furtherance of decisions producing legal or similarly significant effects,
  which expressly includes employment. Grain's analytics product is that profiling, and the right
  belongs to a person who does not know Grain exists.
- **Universal opt-out mechanisms.** Colorado, Connecticut, Texas, Montana, Oregon, Delaware,
  Nebraska, New Hampshire, New Jersey and others require honouring browser-level opt-out signals.
  A subject with no account cannot transmit one, which is another instance of the §4.3 mechanism
  gap.

Not verified: the complete state-by-state effective-date table, the definitive universal-opt-out
list, and whether any 2025–26 enactment removed an HR exemption. The working assumption that
California remains the only comprehensive law expressly covering employee data is stated at
medium confidence and should be re-checked.

### 1.6 What Grain would have to be true for this to be low-risk

Nothing available. The mechanic is lawful only inside one of two disclosed statuses, CRA or
registered data broker, and both carry deletion and rights machinery that contradict the
permanent-record commitment.

---

## 2. The employer's side

**Conclusion: the employer may lawfully disclose the thin payload without consent in nearly
every state, loses its reference-immunity statutes by doing it this way, and acquires FCRA
furnisher duties if Grain is a CRA. Employer liability and platform liability diverge sharply,
and the employer's exposure is smaller than Grain's.**

### 2.1 The default is permission

At common law an employer may disclose truthful employment facts about an employee. There is no
general US consent requirement for employment references, and dates/title/role is the payload
American law treats as least protected, since it is the residue that survived the defamation-driven
collapse of substantive references, a dynamic already documented in
`counsel/brief-3-attesting-party-liability-shield.md` §3.

### 2.2 Personnel-record statutes: a small number of real consent requirements, and the thin
payload clears them

The sharpest located constraint is **Connecticut Gen. Stat. § 31-128f**, which bars disclosure
of "individually identifiable information contained in the personnel file or medical records of
any employee ... to any person or entity not employed by or affiliated with the employer without
the written authorization of such employee," subject to exceptions including:

1. where "the information is limited to the verification of dates of employment and the
   employee's title or position and wage or salary"; and
2. where the disclosure is made "to a third party that maintains or prepares employment records
   or performs other employment-related services for the employer."
   ([Conn. Gen. Stat. § 31-128f](https://law.justia.com/codes/connecticut/title-31/chapter-563a/section-31-128f/))

**The payload splits, and the split is instructive.** Name, title, role and dates sit inside
exception 1. **Personal phone and email do not**, since they are individually identifiable
personnel-file information that is neither dates, title, nor wage. The identifiers Grain needs
in order to match a pre-claim record to a future account are precisely the part of the payload
that Connecticut's carve-out does not cover. That is an uncomfortable finding, because the
identifiers are load-bearing for the whole claim mechanic.

Exception 2 is Grain's best argument at ingest, framed as a vendor performing employment-related
services for the employer, but it is drafted around a service relationship running *to the supplying
employer*. Once Grain re-uses the same records to serve other employers and to build analytics,
it is no longer performing services for the employer that supplied them. This is the same
service-provider-versus-third-party problem as §1.4, arriving through a different statute, and
it fails for the same reason. No Connecticut case tests the boundary; this is analysis, not
holding.

**Michigan and Illinois are dormant on this payload and activate the moment it thickens.**
Bullard-Plawecki, MCL § 423.506, and the Illinois Personnel Record Review Act, 820 ILCS 40/7,
are substantively identical: an employer may not divulge **a disciplinary report, letter of
reprimand, or other disciplinary action** to a third party outside the organisation without
written notice to the employee by first-class mail, mailed on or before the day of disclosure.
Both reach disciplinary records only, so neither bites on dates/title/role. Both bite
immediately if separation-for-cause, "do not rehire," or write-up data ever enters the pipe,
which is exactly what `score_summary` and outcome facts would be. Illinois carries a three-year
limitations period and a private action under § 12.
([MCL § 423.506](https://www.legislature.mi.gov/documents/mcl/pdf/mcl-423-506.pdf);
[820 ILCS 40](https://law.justia.com/codes/illinois/chapter-820/act-820-ilcs-40/))

For completeness: **Cal. Lab. Code § 1198.5 is an inspection right, not a disclosure
restriction**, and imposes no consent requirement on transmission to a platform. The same is
true of Pennsylvania's Inspection of Employment Records Act, 43 P.S. §§ 1321–1324. Builders
routinely confuse the two categories; they should not be cited as consent statutes.

Confidence: high on Connecticut, Michigan and Illinois (primary text verified); medium on the
remaining personnel-record states (Wisconsin, Iowa, Maine, Oregon, Delaware, Rhode Island),
which were not verified and are believed to be inspection-only.

### 2.3 Reference-immunity statutes almost certainly do not cover this

Roughly forty states have employer reference-immunity statutes creating a presumption of good
faith for job-performance disclosures. Five were verified to primary text and every one shares
the same two-part trigger, **disclosure to a *prospective employer*, *upon request***, which
the mechanic satisfies neither half of:

| Statute | Recipient | Request | Rebuttal standard |
|---|---|---|---|
| [Tex. Lab. Code § 103.004](https://texas.public.law/statutes/tex._labor_code_section_103.004) | "a prospective employer" | on request of prospective employer or employee | clear and convincing: known falsity, malice, reckless disregard |
| [Fla. Stat. § 768.095](https://www.flsenate.gov/Laws/Statutes/2021/768.095) | "a prospective employer" | upon request | clear and convincing: knowingly false, or ch. 760 violation |
| [Colo. Rev. Stat. § 8-2-114](https://codes.findlaw.com/co/title-8-labor-and-industry/co-rev-st-sect-8-2-114/) | "a prospective employer" | upon request | preponderance: false and employer knew or should have known |
| [Ohio Rev. Code § 4113.71](https://codes.ohio.gov/ohio-revised-code/section-4113.71) | "a prospective employer of that employee" | requested by employee or prospective employer | preponderance: knowing falsity, bad faith, malice, or § 4112.02 discrimination |
| [Cal. Civ. Code § 47(c)](https://codes.findlaw.com/ca/civil-code/civ-sect-47/) | one the employer "reasonably believes is a prospective employer" | "and upon request of" | malice; also requires "credible evidence" |

California is the cleanest no: a data platform that is not hiring is not a prospective employer,
and a standing API feed is not a request. The employer falls back to the general § 47(c)
common-interest privilege for a communication "to a person interested therein," which is a
weaker, fact-bound argument because the platform's interest is commercial rather than the
shared employment interest the privilege contemplates.

**Colorado adds a hazard worth flagging separately.** The same section that creates the
immunity, § 8-2-114, also prohibits an employer from maintaining "a blacklist, or … notify[ing]
any other employer that any current or former employee has been blacklisted." A cross-employer
capability score sits uncomfortably close to that language, and it sits in the same statute an
employer's counsel will read when evaluating the integration.

`counsel/brief-3` Q3(i) already asks counsel whether these statutes cover platform-delivered
attestations and has not received an answer. This memo's position is that the answer is no, and
that it is not close. What survives is the common-law qualified privilege, available but
weaker, because its common-interest element is strained where publication is to a platform
serving an open-ended set of future readers rather than to one interested inquirer.

Confidence: high on the statutory conditions (five statutes verified to text); medium-high that
no authority extends reference immunity to disclosures to background-check or verification
services, since the search located none either way, so treat this as genuinely untested rather than
resolved; medium on the qualified-privilege outcome, which is state-specific and unlitigated in
this posture.

**The practical consequence is commercial, not just legal.** A hospitality employer's counsel,
asked to approve an HRIS connection, will notice that the company is giving up a statutory
immunity it currently enjoys. Grain's partner agreement has to answer that, and
`counsel/brief-3`'s indemnity structure is the place to do it.

### 2.4 Defamation

Low exposure for the thin payload. Dates and title are verifiable facts and truth is a complete
defence. Note the doctrinal tell inside *Lewis v. Equitable Life Assurance Society*, 389 N.W.2d
876 (Minn. 1986) itself: Equitable's policy was to release only dates of employment and final
job title absent written authorisation. That triad has been the market's defamation-safe
disclosure set for forty years, and Grain's pre-claim payload is a deliberate copy of it
([Lewis](https://law.justia.com/cases/minnesota/supreme-court/1986/c8-84-1065-2.html)).

Compelled self-publication, meaning publication satisfied where the plaintiff was compelled to
repeat the statement and the compulsion was foreseeable to the defendant, is recognised in a minority
of states, Minnesota being the first. The current state split was not verified and should not be
relied on.

**The score, not the record, is where defamation exposure actually lives.** A capability or
trajectory number is not true-or-false in the way a date is, which cuts both ways: pure opinion
is non-actionable, but a number presented as derived from proprietary data implies undisclosed
defamatory facts, which is the classic *Milkovich* exception to opinion protection. The
compelled-self-publication theory is also stronger against a score than against dates, because a
low score is exactly what a candidate is forced to explain. And note that every employer
immunity statute above protects *information the employer disclosed*. **A Grain-generated score
is not information the employer disclosed, so employer immunity does not travel to it, and Grain
has no immunity statute of its own.**

Confidence: high on the thin payload being low-risk; medium-high on the score analysis, which is
doctrinal inference; low on the state split for compelled self-publication, unverified.

### 2.5 Service-letter statutes

Missouri (Mo. Rev. Stat. § 290.140), Minnesota (§ 181.933), Kansas, Indiana, Nevada and Texas
require an employer, on request, to furnish a departing employee a statement of dates, title
and sometimes cause of separation. These are duties *toward the worker*, not restrictions on
disclosure to third parties, and they cut mildly *for* Grain: they establish that the exact
payload Grain wants is the payload the state considers the worker's own. Confidence: high on
irrelevance as a bar; the affirmative argument is weak and should not be leaned on.

### 2.6 Where employer and platform liability diverge

| | Employer | Grain |
|---|---|---|
| Lawfulness of disclosure | Permitted in nearly all states for thin payload | N/A |
| Statutory reference immunity | **Lost** by using this channel | N/A |
| CCPA employee-data exemption | Retains it (own employees, employment context) | **Does not have it** |
| Notice to the worker | Owed as employer under CCPA notice at collection | Owed separately as a business/third party |
| FCRA | **Becomes a furnisher** under § 1681s-2 if Grain is a CRA | Becomes the CRA |
| Defamation | Primary author | Republisher; § 230 argument, see `counsel/brief-3` Q4 |

The furnisher point deserves emphasis because it reaches into the partner contract, and it needs
one clarification that is easy to get backwards.

**The employer does not become a CRA by supplying roster data.** § 1681a(d)(2)(A)(i) excludes
from "consumer report" a communication containing information solely as to transactions or
experiences between the consumer and the person making the report. An employer reporting its own
employees' dates and role is reporting exactly its own experience, so that transmission is not
itself a consumer report and the employer is not assembling reports for third parties. **The
exclusion protects the employer at the input stage and does nothing for Grain at the output
stage**, because Grain has no transactional relationship with the worker and is reporting other
parties' experiences. This is the same asymmetry as § 3.4 below, seen from the other end.

**The employer does become a furnisher.** § 1681s-2 duties attach to any entity that furnishes
information to a CRA, notwithstanding that the individual transmission is not a consumer report.
§ 1681s-2(a) bars furnishing information known or reasonably believed inaccurate and is
**enforceable only by regulators and state officials** (§ 1681s-2(c)–(d)). § 1681s-2(b) requires
a reasonable investigation on receipt of a CRA-forwarded dispute and **is privately
enforceable**, and it is the workhorse of furnisher litigation. So if Grain is a CRA, **every
connected hospitality employer acquires a privately enforceable federal investigate-on-dispute
obligation, and Grain must build the callback API that routes disputes to them.** `research/01`
§1.5 identified this as contingent; pre-claim collection makes it certain, because the disputes
will come from people who never agreed to be in the system.

Separately, the *using* employers, Grain's customers, pick up § 1681b(b): standalone written
disclosure, written authorisation, certification to Grain, and pre-adverse-action notice with a
copy of the report and the summary of rights. **§ 1681b(b)(3) pre-adverse-action failure is the
single most litigated FCRA employment claim**, and Grain would be selling a product whose
correct use requires customers to execute a workflow they routinely get wrong.

---

## 3. FCRA: the central question

**Conclusion, stated first and without hedging: on the mechanic as described, Grain is a
consumer reporting agency and the roster attestation is a consumer report. Confidence: high.
R1 does not survive contact with pre-claim collection.**

`research/01` reached the CRA conclusion already, on the general ledger design. This section
addresses only the delta introduced by pre-claim collection. The delta is that the mechanic
removes the one defence R1 was built on and adds an aggravating fact.

### 3.1 The statutory elements, applied to the pre-claim record specifically

§ 1681a(f): a CRA is any person which, "for monetary fees, dues, or on a cooperative nonprofit
basis, regularly engages in whole or in part in the practice of assembling or evaluating
consumer credit information or other information on consumers for the purpose of furnishing
consumer reports to third parties"
([15 U.S.C. § 1681a](https://www.law.cornell.edu/uscode/text/15/1681a)).

- *Assembling*: receiving roster feeds from multiple employers and consolidating them into a
  per-person record is the paradigm case of assembly. It is a stronger fit than the ledger's
  general design, because assembly is exactly what the platform does and the worker does none
  of it.
- *Evaluating*: the capability and trajectory analytics evaluate. The withdrawn CFPB Circular
  2024-06 said so specifically for worker scores, and withdrawal changed enforcement
  probability, not the statute (`research/01` §1.1).
- *For monetary fees*: employers pay for analytics and for the vertical. The record layer being
  free to workers is irrelevant; § 1681a(f) asks whether the agency is paid, not by whom.
- *For the purpose of furnishing consumer reports to third parties*: the stated intent is that
  future employers read the claimed record. *Kidd v. Thomson Reuters Corp.*, 925 F.3d 99 (2d
  Cir. 2019), made subjective purpose the test; here purpose is documented in the thesis, the
  pitch and the product roadmap.

§ 1681a(d)(1)(B): a consumer report is a communication bearing on character, general reputation,
personal characteristics or mode of living, used or **expected to be used** as a factor in
establishing eligibility for employment purposes. § 1681a(h) defines employment purposes to
include evaluating a consumer for "employment, promotion, reassignment or retention." Verified
employment history furnished to a hiring employer is the core case, not the edge.

**The pre-claim record is a "file."** § 1681a(g) defines file as "**all** of the information on
that consumer recorded and retained by a consumer reporting agency regardless of how the
information is stored." § 1681a(c) defines "consumer" as "an individual." Neither definition
contains a relationship element. A record about a person who never signs up is a file about a
consumer, and § 1681g file-disclosure and § 1681i dispute duties run to it.

**The controlling standard is specific intent, and it is the one doctrinal escape, closed
here.** *Kidd v. Thomson Reuters Corp.*, 925 F.3d 99 (2d Cir. 2019): "A 'consumer reporting
agency' is an entity that intends the information it furnishes to constitute a 'consumer
report.'" But the court added that purpose "can… be established in all the ways intent can be
found in our law, including explicit attestation, concrete evidence, or, in some circumstances,
**inference from the foreseeable and logical consequences of a course of conduct**." Thomson
Reuters escaped on an elaborate anti-FCRA-use apparatus, namely subscriber vetting, contractual
prohibitions, purpose certification on *every single search*, training, auditing, and misuse
investigation, against which misuse was "miniscule" across 144 million searches. *Zabriskie v.
Federal National Mortgage Ass'n*, 940 F.3d 1022 (9th Cir. 2019), is the same shape: the court
assumed Desktop Underwriter assembles and evaluates, and resolved the case on purpose alone.

**Grain is the mirror image of both.** Its purpose is to supply an eligibility input to a third
party; that is the product, the pitch and the roadmap. The *Kidd* off-ramp requires a defendant
whose purpose is something other than employment screening, and Grain has no such purpose to
point to.

Confidence: high. Statutory text plus two circuit opinions applied to conceded facts.

### 3.2 (a) Does worker-controlled disclosure defeat CRA status? No, and the market has
already answered

The corpus states the doctrinal answer (`research/01` §1.4) and I agree with it entirely. What
pre-claim collection adds is a market-structure argument that is more persuasive to a founder
than the doctrinal one.

The income and employment verification market has sorted itself on precisely the axis the
pre-claim mechanic crosses:

| Entity | Collection model | Stated FCRA posture |
|---|---|---|
| Equifax / The Work Number | Employers push payroll and employment records for all employees; no employee consent at intake | Operates as a CRA; consent enters only at the pull ([theworknumber.com/fair-credit-reporting-act](https://theworknumber.com/fair-credit-reporting-act)) |
| Truework | Mixed: employer records, payroll API, manual outreach | "A fully FCRA-compliant Consumer Reporting Agency" ([truework.com](https://www.truework.com/consumer-reporting-compliance)) |
| Pinwheel | Payroll connectivity | Registered CRA, and markets that fact as a differentiator ([pinwheelapi.com](https://www.pinwheelapi.com/fcra/consumer-reporting-agency)) |
| Argyle | **Consumer connects their own payroll account, at their direction** | Claims non-CRA status, resting explicitly on consumer direction: consumers "offer their information willingly and directly," in contrast to entities that "buy, aggregate, and sell data without consumers' knowledge or consent" ([argyle.com](https://www.argyle.com/blog/using-non-fcra-data-for-income-employment-verifications)) |

Argyle's non-CRA argument is the closest thing in the market to R1, and it is available only
because the consumer initiates. Grain's pre-claim mechanic is Argyle's own description of what
a CRA does, collection without the consumer's knowledge or consent, quoted back at it. Note
also that Argyle's position is a self-serving commercial statement, not an adjudication; no
court or regulator has blessed it. It is the *best case* for R1 and Grain does not qualify for
it.

**The FTC's position on self-labelling.** *Filiquarian Publishing / Choice Level* (consent order,
January 2013): a disclaimer does not defeat the definition, particularly where it contradicts the
company's own marketing. The FTC's framing is unimprovable: "If a company meets the legal
definition of a 'consumer reporting agency,' it's a consumer reporting agency. Including a
disclaimer that says, in effect, 'But we're not a CRA!' won't change that"
([FTC](https://www.ftc.gov/business-guidance/blog/2013/01/background-screening-reports-fcra-just-saying-youre-not-consumer-reporting-agency-isnt-enough)).

***United States v. Spokeo, Inc.***, No. CV12-05001 (C.D. Cal. 2012), $800,000 civil penalty, is
the closest enforcement analogue to the pre-claim window and it deserves more weight than the
corpus gives it. Spokeo assembled information "from hundreds of online and offline sources" into
profiles of **people who had never used Spokeo, built substantially from material those people
had themselves published**. That did not defeat CRA status. Charges ran under §§ 1681e(a),
1681e(b), 1681e(d) and 1681b. Spokeo had amended its terms in 2010 to disclaim CRA status; the
FTC charged it anyway, noting Spokeo "failed to revoke access to or otherwise ensure that
existing users… did not use the company's website or information for FCRA-covered purposes"
([complaint](https://www.ftc.gov/sites/default/files/documents/cases/2012/06/120612spokeocmpt.pdf);
[case page](https://www.ftc.gov/legal-library/browse/cases-proceedings/1023163-spokeo-inc)).
Note that the case name is *United States v. Spokeo*, DOJ suing on FTC referral for civil
penalties, not *FTC v. Spokeo* as `research/01` §1.1 and `counsel/brief-4` both have it.

**On LinkedIn specifically, correcting the record, because R1 rests on this.** LinkedIn *has*
been sued as a CRA. ***Sweet v. LinkedIn Corp.***, No. 5:14-cv-04531 (N.D. Cal.), filed 9 October
2014, targeted LinkedIn's **Reference Search** product under the FCRA; the motion to dismiss was
granted and the case terminated 21 May 2015
([docket](https://www.courtlistener.com/docket/4181264/sweet-v-linkedin-corporation/)). So the
premise that worker-published-profile platforms have "survived FCRA challenge" is literally true
and is one district-court dismissal deep.

That is thinner support than R1 needs, for three reasons. First, one unpublished district-court
dismissal is not a doctrine. Second, the product at issue, Reference Search, was a search over
member-authored profiles, not employer-transmitted records about non-members. Third, and
decisively, LinkedIn does not receive bulk employer-authored records about people who are not
members. **Absence of successful enforcement against a differently-structured company is weak
evidence about Grain, and the one case on point was resolved on facts Grain does not have.**
Confidence: high that the analogy fails. The dismissal order's reasoning could not be retrieved
and should be pulled before anyone relies on it in either direction.

### 3.3 (b) The pre-claim window is the fatal fact

This is the heart of the memo.

Every consent-based or worker-publication theory requires a worker act. In the pre-claim window
there is none:

- the worker did not author the content (the employer did);
- the worker did not direct its publication (the employer's HRIS integration did);
- the worker did not select the platform (Grain's BD did);
- the worker does not know the record exists;
- and for the population that never claims, no worker act ever occurs.

Grain in that window is doing exactly what a credit bureau does: holding a file assembled from
furnisher feeds about a person who has no relationship with it, awaiting a permissible-purpose
pull. There is no legal theory under which that is a "worker-published profile," because there
is no publication by the worker.

A retroactive-ratification argument, that the claim event cures the pre-claim window, fails for
three reasons. First, CRA status under § 1681a(f) is assessed by what the entity regularly does,
and the entity regularly assembles unclaimed files. Second, "in whole or **in part**" in the
definition means that even if claimed records were somehow outside, the unclaimed ones make
Grain a CRA. Third, the never-claimed population is by construction unratified, and it is
plausibly the majority.

Confidence: high on the reasoning. Medium-high that no court would entertain ratification,
which is untested because no one has tried it.

### 3.4 (c) The analytics product makes it worse, in a specific way

Two effects, distinguishable:

**Effect one, on CRA status: it supplies "evaluating."** § 1681a(f) reaches assembling *or*
evaluating. Analytics independently satisfies the second verb. The withdrawn Circular 2024-06
addressed exactly this: "background dossiers and algorithmic scores for hiring, promotion, and
other employment decisions", and stated that collecting consumer data to train an algorithm
producing worker scores can be assembling or evaluating, and that the first-party
transaction-and-experience exclusion does not reach algorithmic scores because a score is not a
transaction or experience between the report-maker and the consumer. The circular was withdrawn
12 May 2025; `research/01` §1.1's treatment of the withdrawal as a change in enforcement
probability rather than legal exposure is correct and I adopt it.

**Effect two, on the transaction-and-experience exclusion: it forecloses a lane that was already
closed by direct authority.** § 1681a(d)(2)(A)(i) excludes a report containing information
*solely* as to transactions or experiences between the consumer and the person making the report.
A single employer's own roster facts about its own employee are within it. **The exclusion does
not travel to Grain, and this is settled agency interpretation rather than inference.**

The FTC's **2011 staff report, comment 603(d)(2)(A)(i)-1E**, addresses this exact fact pattern:

> "**Reference checks.** A communication from a former or current employer to a CRA or other
> third party, involving only transactions between the consumer (the employee or applicant) and
> the person making the report… is not a consumer report because it is based on the 'experiences
> between the consumer and the person making the report.' **However, a communication of such
> information from a CRA to a potential employer is a consumer report because the transactions or
> experiences referred to in the communication are not between the job applicant and the CRA.**"
> ([40 Years of Experience with the FCRA](https://www.ftc.gov/sites/default/files/documents/reports/40-years-experience-fair-credit-reporting-act-ftc-staff-report-summary-interpretations/110720fcrareport.pdf))

**The exclusion is defined by privity. It protects the source, not the intermediary, and it does
not travel with the data.** The employer has an employment relationship with the worker; Grain
does not.

The **FTC's Islinger opinion letter (9 June 1998)** draws the operative line and puts Grain on the
wrong side of it: "The 'transactions or experiences' exception does not apply to the intermediary
because the intermediary does not perform the analysis… If an intermediary contributes to (or
takes any action that determines) the content of the information conveyed to an employer, we
believe it is 'assembling or evaluating' the information and thus qualifies as a CRA…
**an intermediary that retains copies of tests performed by drug labs and regularly sells this
information to third parties for a fee is a CRA**"
([Islinger](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-islinger-06-09-98)).
The distinction is between a go-between performing "only mechanical services" (*Hodge v. Texaco*,
975 F.2d 1093 (5th Cir. 1992)) and an entity that **retains and resells**. Grain retains and
resells; that is the whole product.

Two further FTC comments close the remaining gaps. **Comment 603(f)-3C:** "A third party that
provides oral or written reports to prospective employers about the prior work experience of
applicants is a CRA." **Comment 603(d)-6B:** "The term 'consumer report' includes numerical or
other evaluation of data by a CRA, such as a credit score." And **comment 603(d)-4**: if
information from a consumer report is added to a report that is not otherwise a consumer report,
**that report becomes a consumer report**, meaning a single regulated product sitting on the
same data pulls the rest of the platform in.

Separately, the word "solely" does independent work: a single non-experience field, such as a
score or a cross-employer standing derivation, contaminates the whole communication even before the privity
point is reached.

Confidence: high. This rests on published FTC staff interpretation directly on the fact pattern,
not on inference.

**The best counter-authority, stated fairly, because it is the strongest thing on R1's side of
the ledger.** FTC 2011 staff report **comment 603(f)-4E**:

> "An entity acting as an intermediary on behalf of the consumer who has initiated a transaction
> does not become a CRA when it furnishes information to a prospective creditor to further the
> consumer's application… An entity does not become a CRA solely because it conveys, with the
> consumer's consent, information about the consumer to a third party in order to provide a
> specific product or service that the consumer has requested."

This is live FTC staff interpretation and it is the doctrinal home of Argyle's position and of
the Financial Technology Association's agency theory. **Grain fails it on three independent
grounds, all of which are created by pre-claim collection:** the consumer did not initiate
anything, since the data arrives from the employer before the worker has any relationship with
the platform; the furnishing is not to further the consumer's own application but to sell an
analytics product to employers; and "a specific product or service that the consumer has
requested" cannot describe a score the employer buys about a person who has requested nothing.

**This is the precise sentence in which the pre-claim mechanic destroys R1.** Post-claim,
worker-initiated, worker-directed sharing has a colourable home in 603(f)-4E. Pre-claim
collection is outside it by construction, and because § 1681a(f) reaches an entity that furnishes
reports "in whole or **in part**," the pre-claim population alone is sufficient to confer CRA
status on the whole enterprise.

`THESIS.md` §7 already concedes that analytics move R1 "from theoretical to load-bearing." The
correct statement after this memo is stronger: **with pre-claim collection, analytics is not
what breaks R1; pre-claim collection breaks R1, and analytics removes the fallback.**

### 3.5 The provision nobody in the corpus has raised: nationwide specialty CRA

**§ 1681a(x)(4)** defines a "nationwide specialty consumer reporting agency" to include an agency
that "compiles and maintains files on consumers on a nationwide basis relating to…
**employment history**." That is a literal description of Grain at scale, and it is a description
of the *record layer*, not of the analytics product.

The consequences are specific and product-shaping: § 1681j(a)(1)(A) requires a **free annual file
disclosure** on request, and § 1681j(a)(1)(C) requires a **streamlined request process including
a toll-free telephone number**. Equifax Workforce Solutions runs exactly this, plus a security
freeze.

**The FTC has charged this provision in this market.** Its action against **TALX**, the entity
behind The Work Number, later Equifax Workforce Solutions, reached employer-furnished employment
history held as a nationwide specialty CRA. That is the closest enforcement precedent to Grain's
mechanic that exists: employers push employment records about all employees, the platform holds
files on people who never contacted it, and the FTC's response was to enforce CRA duties rather
than to question the collection.

*Verification note:* the TALX action was reported by the research thread as an FTC matter with a
$350,000 penalty; the year and docket were not independently confirmed here, and the widely
repeated claim of a **CFPB** action against The Work Number appears to be unsupported. A search
of the CFPB enforcement database returns nothing for TALX, Equifax Workforce Solutions or The
Work Number. Do not cite a CFPB Work Number action. Counsel should pull the FTC matter directly.

There is also one appellate case squarely on the ingestion model that could not be retrieved and
should be: ***OOIDA v. USIS Commercial Services***, 537 F.3d 1184 (10th Cir. 2008), on
employer-furnished employment-history files. Everything else on this specific question is staff
guidance or district court.

Confidence: high on the statutory text and its application; medium on the TALX enforcement
details pending verification.

### 3.6 § 1681a(o) is closed by pre-claim collection, textually

`research/01` §1.3 analysed the employment-agency exclusion at length and found four failure
modes. Pre-claim collection adds a fifth that is shorter than all of them and does not require
any of the contested reasoning. **§ 1681a(o)(5)(A)(i)** conditions the exclusion on the consumer
consenting "orally or in writing to the nature and scope of the communication, **before the
collection of any information** for the purpose of making the communication."

Grain collects first and seeks consent later, if ever. The exclusion fails at the threshold, on
its face, for every pre-claim record. `research/01` was right that (o) could not carry the
ledger; it is now unnecessary to reach (o)(1), (o)(2) or (o)(4) at all. Confidence: high.

### 3.7 (d) What CRA status would require

`research/01` §1.5 tabulates this and I do not repeat it. Five obligations change character
under pre-claim collection and are worth restating:

- **§ 1681b permissible purpose.** Every furnishing needs one. § 1681b(a)(2) (written
  instructions of the consumer) is unavailable pre-claim, by definition. § 1681b(a)(3)(B)
  (employment purposes) is available, but it is conditioned on § 1681b(b)(1)–(2): the *user*
  must certify the purpose and must have obtained the consumer's standalone written
  authorisation. **So the pre-claim record is not furnishable to anyone until an employer
  obtains the worker's FCRA disclosure and authorisation.** That is a hard architectural gate:
  Grain may hold pre-claim records but must not serve them without a certified employer pull.
  This is the single most actionable finding in the memo.
- **§ 1681e(b) maximum possible accuracy.** Applied to records matched to people by
  employer-supplied name and phone, with no subject able to correct them. `research/03`'s
  mixed-file analysis becomes an FCRA accuracy problem, and mixed-file claims are the
  most-litigated FCRA theory in existence.
- **§ 1681g file disclosure.** On request, all information in the file plus, for employment
  reports, recipients over the prior two years. Grain must be able to disclose an unclaimed
  file to the person it is about, which requires identity verification of a stranger.
- **§ 1681i reinvestigation.** 30 days (+15), and § 1681i(a)(5)(A) requires deletion or
  modification of items found inaccurate, incomplete or unverifiable. **This is R2's
  never-edit rule colliding with federal law**, a collision `research/01` TLDR-4 already
  identified; pre-claim collection guarantees the collision is exercised, because unclaimed
  records are the most error-prone records in the system.
- **§ 1681k.** If any public-record information ever enters, contemporaneous notice to the
  consumer or strict accuracy procedures. Currently barred by the schema's sensitive-data ban
  (A-4), which should stay barred.

### 3.8 Two things that cut *for* becoming a CRA

The memo has been one-directional so far. Two considerations run the other way and belong in the
decision.

**§ 1681h(e) is a qualified immunity that only CRAs get.** It bars consumer claims "in the nature
of defamation, invasion of privacy, or negligence" with respect to reporting information, except
on a showing of malice or wilful intent to injure. An entity that successfully argues it is *not*
a CRA forfeits that immunity while remaining fully exposed to state tort and UDAP claims, often
with punitive damages. **This bears directly on `counsel/brief-3`, whose entire purpose is
constructing a liability shield for honest negative attestations.** Brief 3 is trying to build by
contract something the FCRA hands to CRAs by statute, and the covenant-not-to-sue architecture it
proposes is void or restricted in several states while § 1681h(e) is not. **Brief 3 and Brief 4
are answering the same question and do not know it.** That connection is not made anywhere in the
corpus and should be, before either brief is sent.

**The structural precedent is Plaid, not Argyle.** Plaid did not argue its way out of § 1681a(f);
it incorporated a separate entity, Plaid Consumer Reporting Agency, Inc., so that the conduit
business and the regulated business have different corporate skins. Truework, Pinwheel, Truv,
Finicity and Experian Verify all concede CRA status and run § 1681g and § 1681i processes. **Every
company in the adjacent market that took the question seriously restructured around the
definition rather than litigating it.** The live question for Grain is probably not "am I a CRA"
but "which entity is, and what does conceding do to my employer-side data sources," who become
§ 1681s-2 furnishers on the same day.

Note also what conceding buys commercially: FCRA compliance is a moat. The dispute engine, file
disclosure, read logging and party-level grants are already designed. `research/01` TLDR-3 is
right that the architecture is voluntary pre-compliance. **Grain is roughly two subsystems from
being a compliant CRA and zero subsystems from being a non-compliant one.**

### 3.9 The willfulness problem, restated

`counsel/brief-4` Q5(c) already raises it. Pre-claim collection sharpens it: a documented
internal conclusion of non-CRA status, adopted after a written internal analysis concluding the
opposite, in a design that assembles files on non-consenting strangers, is the fact pattern
§ 1681n was written for. Statutory damages of $100–$1,000 per consumer, punitive damages and
fees, class-wide across an unclaimed population that Grain itself enumerated, is a number that
does not need modelling to be alarming.

I record the disagreement with R1 once, here, and then defer: **R1 is wrong on this mechanic.**
Not defensible-but-risky; wrong. If the founder wants the hospitality mechanic, the honest move
is to build CRA-native and treat FCRA compliance as a moat. The dispute engine, file
disclosure, and read logging are already designed, which is why `research/01` TLDR-3 is right
that the architecture is voluntary pre-compliance. Grain is roughly two subsystems from being a
compliant CRA and zero subsystems from being an uncompliant one.

---

## 4. Rights of an unclaimed subject

**Conclusion: full rights, no practical exercise mechanism, and California has built the
mechanism anyway. The gap between the rights and their exercisability is Grain's exposure, not
its shelter.**

### 4.1 The rights, and that they do not depend on a relationship

For a California resident whose record Grain holds pre-claim:

| Right | Cite | Applies pre-claim? |
|---|---|---|
| Know / access, incl. categories, sources, purposes, third parties | § 1798.110, § 1798.115 | Yes. § 1798.115 specifically covers information *sold or shared* and its recipients |
| Delete | § 1798.105 | Yes, subject to the § 1798.105(d) exceptions |
| Correct | § 1798.106 | Yes, and this is the one R2 forbids |
| Opt out of sale/sharing | § 1798.120 | Yes |
| Limit use of sensitive PI | § 1798.121 | Only if sensitive categories are held; the schema ban (A-4) should keep this inapplicable |
| Non-retaliation | § 1798.125 | Yes |

Note the § 1798.106 collision explicitly: **CCPA gives an unclaimed subject a right to correct
inaccurate personal information, and R2 forbids editing a verified record.** The corpus has
analysed this collision under GDPR Art. 16 and the Philippine DPA but not under CCPA. The
existing answer, supersession by a new issuer attestation, is probably adequate if the
*served* value changes, since the statute cares about the information the business maintains
and discloses, not about the storage layer. That is the same architecture `research/01` §2.2
landed on for GDPR. Confidence: medium-high; no CCPA guidance addresses versioned correction.

**All eight § 1798.105(d) deletion exceptions were checked against the text and none covers the
model.** (1) complete a transaction or perform a contract *with the consumer* is unavailable,
because a contract with the employer is not one with the consumer; (2) security and integrity is
narrow; (3) debugging does not apply; (4) free speech or another legal right is the only
non-trivial argument and still weak, because the data is privately transmitted rather than
public; (5) CalECPA does not apply; (6) research is unavailable, since it requires the consumer's
informed consent; (7) **solely internal uses aligned with the consumer's expectations based on
the consumer's relationship with the business** is unavailable, and instructively so: "solely
internal" excludes a sold product, the relationship is null, and the consumer never provided the
data; (8) legal obligation applies only for genuine retention mandates, and § 5.3 finds none.

**Exception (7) is the statute's own answer to the pending-claim theory, and the answer is no.**

One textual friction worth knowing but not relying on: § 1798.105(a) speaks of personal
information "collected **from the consumer**," and 11 CCR § 7001(y) tracks that phrasing. A
literal reading might exclude employer-sourced data from the deletion right entirely. I would not
assert it. DROP is built on the opposite premise, and raising it against a worker is a poor
posture that invites the regulator's attention. But it is a genuine open question and counsel
should know it exists. Confidence: high that (d)'s exceptions fail; low-medium on the § 1798.105(a)
"from the consumer" argument, which is untested and strategically unattractive.

### 4.2 Verification of a requestor with no account

The governing section is **11 CCR § 7062, "Verification for Non-Accountholders,"** on top of
§ 7060:

- **§ 7062(b)**, right to know *categories*: "reasonable degree of certainty," may include
  matching **at least two data points**.
- **§ 7062(c)**, right to know *specific pieces*: "reasonably high degree of certainty," may
  include matching **at least three pieces** together with a **signed declaration under penalty
  of perjury**, which must be retained.
- **§ 7062(d)**, deletion and correction: a **sliding** standard, the business's choice
  "depending on the sensitivity… and the risk of harm **to the consumer** posed by unauthorized
  deletion or correction."
- **§ 7062(f)–(g)**: deny specific-pieces requests that cannot be verified; if no reasonable
  verification method exists, say so in the privacy policy and revisit annually.
- **§ 7060(b): opt-out and limit requests may NOT be verified**, and the information requested
  must not be burdensome.
- § 7060(c)(1) match against information already held wherever feasible; § 7060(c)(2) avoid
  Civ. Code § 1798.81.5(d) categories (SSN, driver's licence, financial account, medical) unless
  necessary; § 7060(d) new information collected for verification may be used only for
  verification, security and fraud and must be deleted as soon as practical; § 7060(e) no fee and
  no notarised affidavit unless the business pays for it.

**Three findings follow, and two of them are product-blocking.**

**First, the sliding standard in § 7062(d) resolves the asymmetry in Grain's favour.** Because
erroneous deletion of an unclaimed employment record harms the *business*, not the consumer,
Grain may defensibly use the lower verification tier for deletion and the higher tier for
disclosure. That judgment call must be documented under § 7060(a). This is the answer to the
design question and it is better than I expected before checking the text.

**Second, § 7060(b) is the trap, and it is exact.** The one request Grain must honour **without
any verification** is the opt-out of sale and sharing, the request that removes the record's
revenue. Both the CPPA's *Honda* order ($632,500, March 2025) and *Todd Snyder* ($345,178, May
2025) turned substantially on imposing verification on opt-outs. A product that treats "prove who
you are" as the front door to every request will violate this on day one.

**Third, and this is the sharpest single product constraint in the memo, Civ. Code
§ 1798.130(a)(2)(A) prohibits requiring a consumer to create an account in order to make a
request.** It also sets the 45-day response deadline. **Grain's "claim your record" flow therefore
cannot be the gateway to exercising rights.** That is precisely the default a claim-based product
will build, because claiming is the conversion event the whole mechanic exists to produce. Rights
exercise must run on a separate path that requires no account.

**The over-collection trap.** Demanding an ID scan to verify a five-field record fails
§ 7060(c)(1), (c)(2), (d) and § 7002(d)(1) simultaneously, and would convert a dataset with **no
§ 1798.150 private-right-of-action exposure** into one that has it, since driver's licence and
similar identifiers are the categories that trigger the data-breach private right. The correct
design is challenge-response against the email or phone already in the record, plus a
penalty-of-perjury declaration for the specific-pieces tier. Confidence: high on the regulatory
text; high on the § 1798.130(a)(2)(A) constraint; medium-high on the § 7062(d) asymmetry, which
is a documented judgment call rather than a safe harbour.

### 4.3 The mechanism gap, and DROP as the answer California already built

The obvious objection, which asks how a person can exercise rights over a record they do not know
exists, is not a defence. It is the reason California created a centralised deletion mechanism
that does not require the consumer to know which brokers hold their data.

**DROP status, verified against Civ. Code § 1798.99.86:**

- **1 January 2026**: CPPA established the accessible deletion mechanism; consumers began
  submitting requests. Registration through DROP ran 1–31 January 2026.
- **1 August 2026, live as of the date of this memo**: brokers must "access the accessible
  deletion mechanism… at least once every 45 days," process verified deletions within 45 days,
  **process unverified requests as opt-outs of sale and sharing**, direct service providers and
  contractors to delete, and re-delete newly collected data on the same 45-day cycle.
- **1 January 2028** and every three years thereafter: independent third-party audit.
- Penalty: **$200 per day per deletion request** for failure to delete, plus fees and costs.
  SB 361 (Stats. 2025, ch. 466) doubled the daily fine from $100 and expanded the registration
  disclosures to include whether the broker has shared or sold data to a foreign actor, to
  government or law enforcement, or **to a developer of a generative AI system**.
- Registration is annual on or before **31 January**; the fee is **$6,000**.

More than 300,000 Californians had submitted requests before the August 2026 processing deadline
([§ 1798.99.86](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.99.86);
[CPPA data broker registry](https://cppa.ca.gov/data_broker_registry/)).

For Grain the consequence is concrete and immediate: **if Grain registers as a data broker, a
worker who has never heard of Grain can and will delete their unclaimed record via a single-click
state platform, and Grain will learn of it only by polling.** Enrolment in DROP is enrolment in
bulk, automated, subject-initiated erasure of exactly the population the mechanic depends on.
And, per SB 361, an unverifiable request that Grain declines still becomes a permanent opt-out
from sale and sharing, which for an unclaimed record is functionally the same as deletion.

### 4.4 Does Grain meet the data-broker definition?

**California.** Civ. Code § 1798.99.80(c): a data broker is "a business that knowingly collects
and sells to third parties the personal information of a consumer with whom the business does
not have a direct relationship." Pre-claim, Grain has no direct relationship with the subject,
which is the defining feature of the mechanic, and it discloses the record to employers for
consideration. **Grain meets the definition on its face.**

The exclusions matter: the definition does not include an entity "to the extent that it is
covered by" the FCRA, GLBA, the Insurance Information and Privacy Protection Act, or HIPAA-scope
processing under § 1798.146
([Civ. Code § 1798.99.80](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.99.80)).

This produces the fork in TLDR-7. Registering as a CRA and operating FCRA-compliantly takes the
FCRA-covered activity out of the Delete Act. Declining CRA status leaves Grain squarely inside
it. **There is no configuration in which Grain is neither.** The "to the extent" language means
a mixed entity may be partly in each, which is the worst of both and should be avoided
deliberately rather than arrived at by drift. Confidence: high on the structure; medium on how
the partition works in practice, which is unsettled and is a genuine counsel question.

**Enforcement is active, escalating, and has already been fatal to one broker.** The CPPA
launched a dedicated **Data Broker Enforcement Strike Force in November 2025**, and a December
2025 advisory now requires brokers to disclose all trade names and websites and to register
independently rather than under a parent:

| Entity | Date | Outcome |
|---|---|---|
| Growbots, Inc. | Nov 2024 | $35,400 |
| UpLead LLC | Nov 2024 | $34,400 |
| Key Marketing Advantage, LLC | Jan 2025 | $55,800 |
| Jerico Pictures / National Public Data | Feb–May 2025 | $46,000 (statutory maximum; 230 days late) |
| **Background Alert, Inc.** | Feb 2025 | **Shut down operations through 2028 or pay $50,000** |
| Accurate Append, Inc. | Jul 2025 | $55,400 |
| **ROR Partners LLC** | Dec 2025 | $56,600 |
| Rickenbacher Data (Datamasters) | Jan 2026 | $45,000 + ordered to cease selling Californians' PI |
| S&P Global, Inc. | Jan 2026 | $62,600 |

A registration failure is a strict-liability, per-day violation requiring no showing of consumer
harm. It is the cheapest available way for Grain to acquire a public enforcement record.

**ROR Partners is the case most directly on point, and it forecloses the framing Grain is most
likely to reach for.** ROR compiled behavioural profiles into audience segments and sold them as
part of a marketing *service*. The CPPA held: **"A sale is a sale. A business cannot bypass the
CCPA's and the Delete Act's requirements by selling personal information as part of a larger
suite of products and services it offers."** That is the answer to "we don't sell data, we sell
analytics." Grain should assume the regulator will look through the packaging
([CPPA announcements](https://www.cppa.ca.gov/announcements/2025/20251203.html)).

**Does the "sale" limb split?** Probably, and the split matters. Genuinely aggregate or
deidentified analytics fall outside "personal information" under § 1798.140(v)(3) and therefore
outside "sale", but this requires real deidentification with the § 1798.140(m) commitments and
no reasonable linkability, which most analytics products fail in practice. **Disclosing individual
worker records back to employers for monetary or other valuable consideration is squarely a sale
under § 1798.140(ad), and that leg alone triggers registration.** Confidence: high.

**The other registration states, with citations corrected.**

- **Texas, Bus. & Com. Code ch. 510**, not ch. 509; the chapter was redesignated by HB 1620,
  effective 1 September 2025, and amended by SB 2121 the same day
  ([text](https://tcss.legis.texas.gov/resources/BC/htm/BC.510.htm)). § 510.001 defines a data
  broker as an entity that "collects, processes, or transfers personal data that the business
  entity did not collect directly from the individual"; SB 2121 removed the old
  principal-source-of-revenue test. § 510.003 thresholds are disjunctive and **Grain clears the
  second easily**: either >50% of revenue from processing or transferring such data, **or**
  revenue from processing or transferring the personal data of **more than 50,000 individuals**
  not collected directly. That prong is a headcount, not a revenue share. Registration with the
  Secretary of State, $300, plus a website notice and a mandatory comprehensive information
  security program; penalties $100/day capped at $10,000 per 12 months.

  **The employee-data carve-out does not protect Grain.** "Personal data" excludes "employee
  data," but employee data is defined as information collected, processed or transferred **by an
  employer** for hiring, professional-capacity, emergency-contact or benefits purposes, and only
  when handled **"solely for"** those purposes. Grain is not the employer and a portable record
  plus analytics is not "solely for" those purposes. Confidence: medium-high.
- **Oregon, ORS § 646A.593** (HB 2052), not § 646A.560; registration required since 1 January
  2024. The definition, "a business entity… that collects and sells or licenses brokered
  personal data to another person", **contains no direct-relationship element at all**, making
  Oregon facially broader than California, Vermont and Texas. Registration with DCBS, $600
  initial and $600 renewal, penalties to $500 per violation per day, $10,000 annual cap. The
  exclusion list could not be retrieved verbatim and should be checked.
- **Vermont, 9 V.S.A. § 2446.** § 2430(4) uses the direct-relationship formulation, and its
  examples of a direct relationship include a "past or present customer, client, subscriber, user,
  or registered user… **or employee, contractor, or agent of the business**." **That last clause
  is the trap, since the worker is an employee of the employer, not of Grain**, so no direct
  relationship exists. Annual registration by 31 January, $100 fee, $50/day capped at $10,000/year,
  plus a detailed mandatory information security program under § 2447
  ([§ 2446](https://legislature.vermont.gov/statutes/section/09/062/02446)).

**Practical read: Grain plausibly trips California, Texas, Oregon and Vermont.** Vermont is the
cheapest at $100; California is the expensive and consequential one at $6,000 plus DROP.

### 4.5 What the CCPA enforcement record does and does not show

The AG's cure period is gone: "As of January 1, 2023, the CCPA no longer requires notice of a
violation or an opportunity to cure before filing an enforcement action"
([oag.ca.gov](https://oag.ca.gov/privacy/ccpa/enforcement)). Seven AG settlements exist:
Sephora ($1.2M, 2022, establishing that sharing data with third parties for analytics and
advertising is a "sale"), DoorDash ($375K, 2024, marketing co-op participation is a sale for
"other valuable consideration"), Tilting Point ($500K), Healthline ($1.55M, 2025), Sling TV
($530K), Jam City ($1.4M), and **Disney ($2.75M, February 2026, the largest to date)**. CPPA
orders add Honda ($632,500), Todd Snyder ($345,178), and **Tractor Supply ($1.35M, September
2025)**.

**Tractor Supply is the one to read.** Among its findings was **failure to notify California job
applicants of their privacy rights**. The CPPA described it as "the first to address the
importance of CCPA privacy notices and privacy rights of job applicants." The regulator has
already crossed into employment-context notice. Separately, the AG ran an **employer sweep in
July 2023**, sending inquiry letters to large California employers about HR-data compliance.

**Now the finding that matters most, stated precisely: there is no enforcement action premised on
(a) failure to give notice at collection where the data came from a third party rather than the
consumer, or (b) holding data on non-customers.** Every CCPA action to date is a *first-party
interface* case: opt-out mechanics, GPC handling, verification friction, missing contract terms.
The Delete Act actions are **registration** cases, not notice cases.

**Read that carefully, because the natural inference is the wrong one.** The absence of precedent
is not comfort. It means the theory is untested in both directions, that the Strike Force is
actively expanding into this space, and, per ROR Partners and 11 CCR § 7012(i), that the
question the regulator will ask is **"are you a registered data broker?"**, not "did you post a
notice?" Grain's exposure is most likely to arrive as a registration action, which is
strict-liability and per-day, rather than as a contested notice case.
Confidence: high on the enforcement record; medium on the prediction about how exposure arrives.

---

## 5. Retention of never-claimed records

**Conclusion: indefinite retention is disclosable, and not defensible for the never-claimed
population. Grain needs a pre-claim expiry, and it should choose one rather than have one
chosen for it.**

### 5.1 The disclosure duty is satisfiable

Cal. Civ. Code § 1798.100(a)(3) requires a business to inform consumers of "the length of time
the business intends to retain each category of personal information, or if that is not
possible, the criteria used to determine that period." 11 CCR § 7012(e)(4) carries the same
requirement into the notice at collection. "Retained until claimed by the subject or until
[period], whichever is earlier" is a criterion and is disclosable. So the disclosure limb is a
drafting problem, not a design problem.

### 5.2 The necessity limb is where it fails, and "indefinite" fails twice over

§ 1798.100(a)(3) continues: "**provided that a business shall not retain a consumer's personal
information… for longer than is reasonably necessary for that disclosed purpose.**"
§ 1798.100(c) adds that collection, use, retention and sharing "shall be reasonably necessary and
proportionate."

**First failure: "indefinite" is neither a period nor a criterion.** "Until she claims it" is
circular. A condition the data subject does not know exists produces a functionally infinite
period for nearly every record. Confidence: high that this violates § 1798.100(a)(3) on the face
of the policy.

**Second failure: 11 CCR § 7002(b) is where it really breaks.** The regulation sets five
reasonable-expectations factors, and every one runs against the pre-claim population:

| § 7002(b) factor | Pre-claim record |
|---|---|
| (1) relationship between consumer and business | None |
| (2) type, nature and amount of personal information | Identifiers plus employment history |
| (3) source and method of collection | The employer; invisible to the subject |
| (4) specificity, prominence and clarity of disclosures **to the consumer** | None |
| (5) whether third-party involvement is **apparent to the consumer** | Not apparent |

**And the § 7002(e) consent cure is structurally unreachable**: § 7002(e) permits a purpose
failing the (a) test only with consent under § 7004, the employer cannot consent on the worker's
behalf, and § 7063 requires the consumer's own signed permission. There is no path from
"indefinite pending-claim retention" to compliance that runs through consent.

**What would make it defensible**, and this is actionable rather than aspirational: a bounded,
criteria-based rule per category; automatic deletion or irreversible deidentification triggers
that fire **without consumer action**; documented periodic review; pushing notice upstream by
contract to improve the (b)(4) analysis (which improves the factor without manufacturing
consent); and the real § 7002(d)(1) minimisation answer: **splitting the pools, because the
claim-matching function needs only a hashed matching key, not the full employment record.** That
last point converges with the identifier problem in § 2.2 and should be the same piece of
engineering.

Useful corollary: 11 CCR § 7060(g) imposes no obligation to provide, delete or re-identify
deidentified information. Irreversible deidentification is therefore a genuine terminal state,
not a deferral.

Confidence: high that indefinite retention as described is non-compliant; medium-high on the
bounded-period cure, which is textual inference plus regulator posture rather than settled law.
No enforcement action has yet tested speculative-future-use retention.

### 5.3 The other retention constraints

- **Maryland** (Online Data Privacy Act, effective 1 Oct 2025) sets a collection-limitation
  standard tied to what is reasonably necessary to provide a product the consumer *requested*.
  A non-user requested nothing. Maryland is the state where indefinite pre-claim retention is
  least defensible, and unlike California it is not curable by better disclosure.
- **If Grain is a CRA**, § 1681c(a)(5) caps *reporting* of adverse items at seven years
  (§ 1681c(b)(3) excepts jobs at $75,000+). `research/01` TLDR-4 rates the application to
  non-record adverse employment items at medium-high confidence and I adopt that rating. Note
  the constraint is on reportability, not storage, which is exactly what the two-plane
  architecture was built for.
- **No statute compels retention of an unclaimed record.** Colorado's developer duty under
  SB 26-189 § 6-1-1702(4) is system-level (version identifiers, changelogs, deployer notices),
  not person-level (`research/14` §1.1). 11 CCR § 7101(e) expressly says a business "is not
  required to retain personal information solely for the purpose of fulfilling a consumer
  request." There is no legal-obligation hook to set against erasure.

### 5.4 What a defensible retention rule looks like

A pre-claim record should carry a hard expiry measured from the last employer write, with a
disclosed period, automatic destruction of the payload plane on expiry, and no revival path.
The two-plane architecture supports this directly: the integrity spine keeps the unlinkable
commitment, the payload plane holds the identifiers and facts and can be destroyed. Choosing
the number is a business decision informed by observed claim latency; choosing *whether* there
is a number is not really open.

---

## 6. Other US hazards

### 6.1 Automated employment decision law, the corpus is right, and pre-claim does not change it

`research/14` §1 established, against primary sources, that NYC Local Law 144 (6 RCNY
§§ 5-300–5-304), Illinois (775 ILCS 5/2-102(L)), UGESP (29 C.F.R. pt. 1607), EEOC recordkeeping
(29 C.F.R. § 1602.14) and OFCCP (41 C.F.R. § 60-1.12) all run to employers, employment agencies
and users, not to vendors. DCWP's FAQ says outright that the AEDT vendor is not responsible for
the bias audit. I adopt that analysis without re-deriving it, and note only that pre-claim
collection does not move any of these duties onto Grain.

**NYC Local Law 144.** Duties run to "an employer or employment agency"; DCWP's own FAQ states
that the vendor that created the AEDT is not responsible for the bias audit. The "independent
auditor" definition excludes anyone involved in *using or developing* the tool, so Grain could
not audit its own product even voluntarily. Vendor exposure is contractual, needing Grain's
cooperation and data, not statutory. One development worth tracking: in **December 2025
the NY State Comptroller found DCWP's enforcement ineffective** (75% of 311 test calls
misrouted; of 32 disclosures reviewed DCWP flagged one likely non-compliance where the
Comptroller found at least 17 potential issues). Expect enforcement to tighten
([DCWP AEDT page](https://www.nyc.gov/site/dca/about/automated-employment-decision-tools.page);
[OSC audit](https://www.osc.ny.gov/state-agencies/audits/2025/12/02/enforcement-local-law-144-automated-employment-decision-tools)).

**Colorado: the statute most commentary references no longer exists, and the replacement is
materially different.** SB 24-205 (effective 1 Feb 2026) was delayed to 30 June 2026 by **SB
25B-004** (signed 28 Aug 2025); **xAI then sued Colorado in April 2026, the DOJ intervened, and
on 27 April 2026 the court granted a joint motion temporarily suspending enforcement**; the
legislature **repealed and reenacted the Act as SB 26-189, "Automated Decision-Making
Technology," signed 14 May 2026, operative 1 January 2027**
([SB 25B-004](https://leg.colorado.gov/bills/sb25b-004);
[SB 26-189](https://leg.colorado.gov/bills/sb26-189);
[Norton Rose on the suspension](https://www.nortonrosefulbright.com/en/knowledge/publications/de3ad9de/xai-sues-doj-intervenes-enforcement-of-colorado-ai-act-suspended)).

What changed matters more than the date. **SB 26-189 dropped the duty of reasonable care to
avoid algorithmic discrimination, the impact assessments, and the risk-management program.**
What remains is disclosure and process: developer duties to furnish deployers statements of
intended and harmful uses, training-data descriptions, known limitations and monitoring
instructions; deployer duties of pre-use notice, adverse-outcome explanation within 30 days,
three-year records, meaningful human review where commercially reasonable, and a consumer right
to instructions for correcting inaccurate data. AG-only, no private right of action, 60-day cure
except for knowing or repeated violations.

Grain is a **developer**: ADMT expressly includes technology generating "rankings, scores," and
employment is a covered domain. `research/14` §1.1's finding that the developer retention duty
covers system artifacts rather than people survives the reenactment and remains correct. **This
is still the one US regime binding Grain directly, but it is now a documentation regime, not an
anti-discrimination regime.** The corpus should be updated to say so: Colorado is a smaller
problem than `THESIS.md` §7 implies. The federal government actively litigating to invalidate
state AI laws makes this entire section unstable.

**California FEHA automated-decision-system regulations: the most dangerous regime for Grain
specifically, and the corpus underweights it.** Civil Rights Council, approved 27 June 2025,
effective **1 October 2025**. Three provisions matter:

- **Four-year recordkeeping**, expressly including ADS data, meaning data provided by or about
  individual applicants and employees, and data reflecting employment decisions and outcomes.
  This is a *person-level* retention duty, unlike Colorado's, and it runs to whoever qualifies as
  a statutory employer.
- **Anti-bias testing is relevant evidence**, including its quality, scope, recency, and the
  response to results, and its *absence* is probative. The asymmetry matters: testing and then not acting on
  adverse results is worse than never testing. This should govern how Grain sequences any
  validity work.
- **Agent liability.** "Agent" includes any person acting on behalf of an employer to exercise a
  function traditionally exercised by the employer, **"including when such activities and
  decisions are conducted in whole or in part through the use of an automated decision system."**
  Such an agent is itself an employer under FEHA.

That codifies and extends ***Raines v. U.S. Healthworks Medical Group*, 15 Cal.5th 268 (2023)**,
which held FEHA's employer definition reaches business-entity agents with five or more employees
carrying out FEHA-regulated activities. **The consequence is that a vendor selling capability
scores used in California hiring is directly liable under FEHA as a statutory employer, not as
an indemnitor.** `THESIS.md` §7 reaches this through *Mobley*; the FEHA regulations are the
sharper instrument and should be named alongside it.

**Mobley v. Workday**, No. 3:23-cv-00770-RFL (N.D. Cal.), has advanced further than the corpus
records. July 2024: agent liability allowed under Title VII, ADEA, ADA and FEHA. **16 May 2025:
nationwide ADEA disparate-impact collective conditionally certified** for applicants 40+ who
applied through Workday since 24 September 2020; notice period closed 7 March 2026. **6 March
2026: the court rejected Workday's argument that ADEA disparate-impact protection does not
extend to job applicants**, its strongest remaining dismissal theory. Title VII and
intentional-discrimination claims were dismissed; the ADEA disparate-impact collective is the
live vehicle, potentially spanning millions of applicants across hundreds of employer-customers.
Docket posture verified through secondary sources only.

**Illinois HB 3773** (P.A. 103-0804) amends the IHRA effective **1 January 2026** and is
**effects-based**. It prohibits AI that "has the effect of" subjecting employees to
discrimination, requires notice, and expressly bars ZIP code as a proxy. Duties run to
employers. IDHR's implementing rules ("Subpart J") were temporarily withdrawn and remained in
draft as of early 2026: the statutory duty is live, the contours of compliant notice are not
settled. The **AI Video Interview Act (820 ILCS 42)** is scoped to AI analysis of video
interviews and is not engaged by this mechanic.

**Texas TRAIGA (HB 149)**, effective 1 January 2026, is close to a non-event here: § 552.056(b)
requires *intent* to discriminate and § 552.056(c) states expressly that "a disparate impact is
not sufficient by itself to demonstrate an intent to discriminate." AG-only, 60-day cure.
**The Illinois/Texas divergence, effects-based versus intent-based, with an express
disparate-impact disclaimer, is the sharpest inter-state split in this area, and it means a
single national scoring product cannot be tuned to one standard.**

Confidence: high on duty-holder allocation (inherited from `research/14`'s primary-source work);
high on Colorado's current posture and the FEHA regulations; medium-high on *Mobley*'s docket
posture, which rests on secondary sources. Utah, Maryland, California SB 7, New York State,
Virginia HB 2094 and the status of EEOC AI guidance were **not verified** and should not be
relied on.

### 6.2 Title VII and EEOC: where disparate impact actually attaches

Disparate-impact liability attaches to the entity that *uses* a selection procedure. That is the
employer. Grain's exposure runs through two doors, both narrow but neither closed:

1. **Agent liability.** 42 U.S.C. § 2000e(b) includes "any agent of such a person" in the
   definition of employer. This is the *Mobley* theory and the *Raines* theory. A vendor that
   performs a screening function delegated by the employer can be reached.
2. **Employment agency status.** 42 U.S.C. § 2000e(c) reaches anyone regularly undertaking "to
   procure for employees opportunities to work for an employer." `THESIS.md` §8 already flags
   that a worker-facing job-suggestion surface would make Grain an employment agency in its own
   right, converting it from a vendor supplying validity documentation into a "user" under
   UGESP. That flag is correct and remains unruled.

**What pre-claim collection adds is an input-quality argument that plaintiffs will use.** A
capability score computed partly on records the subject never saw, never corrected, and whose
coverage depends on which employers happened to integrate their HRIS, has a structural coverage
bias: workers at integrated employers accumulate records, workers at non-integrated employers do
not, and integration correlates with employer size, formality and sector, which correlate with
protected characteristics. A worker with a thin record is disadvantaged by an artefact of
Grain's sales pipeline. That is a clean disparate-impact story and it does not require anything
wrong with the model. Confidence: medium, since the mechanism is well-grounded, the empirical
magnitude is unknown, and I found no case on this theory.

The mitigation is already half-designed: `THESIS.md` §5's below-threshold-return-insufficient-data
rule is the right instinct. It should be extended so that record *sparsity* is never scored as a
negative signal, and so that the analytics output declares its coverage basis.

### 6.3 Biometric statutes

Not engaged by the mechanic as described. The schema's sensitive-data ban (A-4) keeps biometric
identifiers out of attestations, and `research/09`'s IDV analysis already handles the
verification path. **The one way biometrics enter is through §4.2's verification problem.** If
Grain ever uses face-match to verify an unclaimed subject's rights request, BIPA (740 ILCS 14)
private right of action, Texas CUBI and Washington's statute all engage, and BIPA is the most
expensive privacy statute in the country per violation. Flagged, not researched. Confidence:
high that it is currently out of scope; high that the verification problem is the route in.

### 6.4 Antitrust: the underrated one

**The exposure is real and the hospitality vertical is the worst case.** Grain is a neutral
intermediary collecting current, person-level employment data from competing employers in a
concentrated local labour market and selling analytics back to them.

**The safety zones were deliberately removed and nothing replaced them.** DOJ withdrew the 1996
Statements of Antitrust Enforcement Policy in Health Care on 3 February 2023 as "overly
permissive"; the FTC followed on 14 July 2023
([FTC](https://www.ftc.gov/news-events/news/press-releases/2023/07/federal-trade-commission-withdraws-health-care-enforcement-policy-statements)).
The withdrawn Statement 6 safety zone was the only concrete numerical guidance in US antitrust
for wage and cost information exchange: third-party management, data more than **three months
old**, at least **five contributors** per statistic, no contributor exceeding **25%**, and
aggregation preventing identification of contributors. Practitioners still design to those
numbers because nothing else exists, **but they now buy a reasonableness argument, not immunity,
and the agencies withdrew them because they thought them too generous.**

The 2016 **Antitrust Guidance for Human Resource Professionals** was **superseded on 16 January
2025 by the Antitrust Guidelines for Business Activities Affecting Workers**, adopted 3–2 with
dissents from Commissioners Holyoak and Ferguson. Ferguson subsequently became FTC Chair.
**Whether the January 2025 Guidelines survive intact under the current administration could not
be verified and is a live open question counsel should check first.**

***Todd v. Exxon Corp.*, 275 F.3d 191 (2d Cir. 2001)** (Sotomayor, J.) remains the leading
labour-market information-exchange decision and the facts map onto Grain with uncomfortable
precision: fourteen oil and petrochemical companies comprising 80–90% of the industry exchanged
salary data for managerial, professional and technical employees, **compiled, analysed and
disseminated by a third-party consultant**, then used to set salaries. The Second Circuit
vacated dismissal, holding a § 1 information-exchange claim adequately pleaded under the rule of
reason, and confirmed that buyer-side (monopsony) labour-market exchanges are fully cognizable.
**The critical lesson is that third-party administration, a classic Statement 6 safeguard, did
not save the exchange at the pleading stage**
([275 F.3d 191](https://law.justia.com/cases/federal/appellate-courts/F3/275/191/592358/)).
*Caveat:* the opinion text itself could not be retrieved; the factor list below is drawn from
secondary description and should be checked against the opinion before it is relied on.

**The best available template is very recent and nobody in the corpus has seen it.** In
***United States v. Agri Stats, Inc.*** (D. Minn.), DOJ and six state AGs filed a **proposed
Final Judgment on 7 May 2026**
([Federal Register, 5 June 2026](https://www.federalregister.gov/documents/2026/06/05/2026-11329/united-states-et-al-v-agri-stats-inc-proposed-final-judgment-and-competitive-impact-statement);
[DOJ case page](https://www.justice.gov/atr/case/us-v-agri-stats-inc)). DOJ's theory: Agri Stats
supplied **"comprehensive, granular, current"** information exclusively to processors while
denying it to purchasers and workers. **Agri Stats claimed to aggregate and anonymise, and DOJ
alleged recipients could re-identify contributors anyway**, and that allegation is the heart of the
case. The remedy is entirely structural, no fine, and reads as the agencies' current statement
of what a compliant intermediary looks like:

1. no sharing of non-public pricing information among competitors;
2. no sharing of most data at facility or company level;
3. information at least **45 days old on average**;
4. most information available for **public purchase on reasonable and non-discriminatory terms**,
   destroying the one-sided informational advantage;
5. compliance program plus an **independent monitoring trustee**.

The algorithmic-intermediary line confirms the direction. ***In re RealPage***, MDL No. 3071
(M.D. Tenn.): motion to dismiss substantially denied December 2023; **DOJ settlement announced
24 November 2025** limiting RealPage's use of **active lease data** to train predictive models;
private settlements exceeding $359.9M with final approval set for 15 October 2026.
***Duffy v. Yardi Systems***, No. 2:23-cv-01391 (W.D. Wash.): motion to dismiss denied 4 December
2024, FTC amicus filed, first defendant settled September 2025 with three years of restrictions
on revenue-management tools.

On the criminal side, ***United States v. Lopez*** (D. Nev.) produced DOJ's **first criminal
wage-fixing trial conviction on 14 April 2025**, involving a home-healthcare staffing executive who
agreed by text with competitors to cap Las Vegas nurse wages, with a **40-month custodial
sentence and $550,000 in fines**. That resets a decade in which DOJ lost every contested
labour-market criminal trial. **It does not reach Grain**: criminal exposure requires an express
agreement, and a data platform is a civil rule-of-reason problem unless participating employers
agree to act on the outputs. It matters as context for how seriously this area is now taken.

**Applied to Grain, every *Todd* factor is present and every historical safeguard is
structurally unavailable:**

| *Todd* / Statement 6 / Agri Stats factor | Grain hospitality |
|---|---|
| Plausible labour market | Metro hospitality FOH/BOH is a textbook narrow labour market |
| Susceptible to collusion | Local hospitality is concentrated among a small number of groups and franchisees |
| Third-party administration | Present, but *Todd* shows this is necessary, never sufficient |
| Data aged ≥3 months (Agri Stats: ≥45 days average) | **Absent**: active roster data, current by design; a lagged employment verification is worth much less |
| Aggregated, ≥5 contributors, none >25% | **Absent**: person-level, individually identified |
| Non-attribution / anonymised | **Structurally impossible.** Agri Stats teaches that claimed anonymisation fails if recipients can re-identify. Here re-identification is not a risk; **it is the product**. The value proposition is that an employer learns about a specific named worker |
| Output is historical fact, not forward-looking | **Absent**: trajectory projection is forward-looking by name |
| Symmetric access | **Absent**: employers see the pool, workers do not, and pre-claim workers do not know it exists. This is precisely the asymmetry Agri Stats remedy 4 targets |

**Grain's genuine defences, stated fairly.** No compensation data is exchanged, and wage data is
the sensitive category in every authority above, and the plus factors that push toward per se
treatment all involve agreement on compensation. The output is a score about an individual
worker, not a recommended price or wage; RealPage and Yardi both involved outputs that were
recommendations *on the competitively sensitive term itself*, and that distinction is real and
strong. There is no allegation-shaped fact of agreement among employers to adhere to outputs.
And **no case was located anywhere treating pooled employment-history or performance data, as
opposed to wages, as a § 1 violation.** This is genuinely unlitigated territory.

That last point is a risk, not a comfort. RealPage and Agri Stats show the agencies will treat a
novel intermediary as a hub without waiting for precedent.

**The exposure concentrates in the analytics product, not the verification record.** Verification
is defensible as an efficiency, since it reduces fraud in employment claims. A cross-employer score
that ranks workers in a shared labour market, derived from competitors' pooled data, is much
closer to a common intermediary coordinating an input market. **`dimension_standing` is the most
dangerous single object in the schema**, since it is a cross-employer *normalised seniority signal*,
derived by Grain rather than by any party, and published back to competing employers.
Functionally that is a levelling benchmark, which is the artefact the agencies have been most
hostile to.

**Facts that would move the analysis.** Toward liability: employer-customers discussing Grain's
outputs with each other; Grain surfacing competitor-identified data; any field bearing on a
rival's compensation or staffing plans; high metro concentration; any marketing that positions
Grain as a way to avoid bidding up wages. Toward safety: worker-mediated consent with worker
access to their own record and score; a hard schema bar on compensation; outputs derived only
from the inquiring employer's decision context rather than rivals' evaluations; broad
availability including to workers.

Confidence: medium-high that a § 1 information-exchange theory survives a motion to dismiss on
the mechanic as described, since *Todd*'s structural factors are all present. Medium on ultimate
liability, which would turn on effects evidence that does not exist. Low-medium on how the
agencies would treat non-wage worker data specifically, because no authority addresses it. What
would raise confidence: an enforcement action or private suit against a cross-employer
worker-data platform, and confirmation of the January 2025 Guidelines' current status.

### 6.5 Two smaller hazards worth naming

- **§ 5 FTC Act unfairness, independent of FCRA.** The FTC has repeatedly treated collection and
  retention of personal data without notice, in a manner consumers cannot avoid, as an unfair
  practice. Pre-claim collection is a paradigm "consumers cannot reasonably avoid" fact pattern.
  This theory survives even if the FCRA analysis were somehow wrong. Confidence: medium-high.
- **State UDAP.** Every state has an unfair-or-deceptive-practices statute, most with private
  rights of action and fee shifting. A public "worker-owned, worker-controlled" positioning
  alongside a pre-claim ingest the worker did not authorise is a deception claim on the face of
  the marketing, not the data practice. **This is the risk most directly created by R1's
  branding rather than by its legal conclusion**, and it is cheap to avoid by describing the
  mechanic honestly in public copy. Confidence: medium-high.

---

## What this forces the product to do

Ordered by how much they constrain architecture rather than policy.

1. **Amend or abandon the ratified interface.** `model/attestation-interface.md` (schema_version
   0.2, RATIFIED) states that a person without a ledger ID cannot be attested for. The
   hospitality mechanic requires the opposite. Pick one: amend the interface with an explicit
   pre-claim record type carrying its own rules, or do not ship pre-claim ingest. Do not let
   this drift.

2. **Gate service of pre-claim records on a certified employer pull.** A pre-claim record must
   not be furnishable on a worker-grant theory, because there is no worker. Under § 1681b(b)(1)
   the only available permissible purpose is employment purposes with a user certification, and
   § 1681b(b)(2) requires the *employer* to have obtained the worker's standalone written
   authorisation. Build the certification capture into partner onboarding, not the API key
   issuance. This is the highest-leverage single constraint in the memo.

3. **Cap the pre-claim payload at dates, title, role and employment status.** No outcome facts,
   no `score_summary`, no `dimensions_exercised`, no termination reasons, no free text, until
   the record is claimed. This keeps the employer inside Connecticut's carve-out, keeps Michigan
   and Illinois dormant, keeps defamation exposure near zero, keeps the record close to what
   service-letter statutes already treat as the worker's own, and keeps the antitrust profile as
   thin as possible. Enforce it at ingestion, the same way A-4's sensitive-data ban is enforced.

   **Then handle the identifiers separately, because they are the exposed element.** Phone and
   email sit outside Connecticut's dates/title/wage carve-out and are the part of the payload the
   claim mechanic actually needs. Two mitigations are worth pricing: hold the contact identifiers
   only as salted commitments sufficient to recognise a later signup, rather than in cleartext,
   which the two-plane architecture already supports and which converts an identifiable
   personnel-file disclosure into something much closer to a matching token; or obtain the
   employer's warranty of authorisation, which moves risk but does not reduce it. The first is
   architecture and is better. It does cost the ability to notify the subject, which collides
   directly with constraint 10, and that tension should be resolved deliberately rather than by
   whichever team ships first.

4. **Never compute or serve analytics on an unclaimed record.** Scoring a stranger is the fact
   that converts every marginal argument in this memo against Grain: CRA "evaluating," the
   transaction-and-experience "solely" problem, the profiling opt-out, the Title VII coverage
   bias, the antitrust benchmark. Make it a hard architectural gate, not a policy.

5. **Set and disclose a pre-claim expiry.** Hard TTL from the last employer write, destroying the
   payload plane, no revival. This is what makes § 1798.100(a)(3) and § 7002 answerable and what
   makes the Maryland problem survivable.

6. **Decide the status question deliberately: CRA or registered data broker.** These are the only
   two doors. Drifting into "partly both" is the worst outcome and is the default if nothing is
   decided. The decision gates the Delete Act analysis, the partner contract, the dispute engine
   and the retention rule. **Note that the adjacent market has already answered it structurally
   rather than doctrinally**: Plaid incorporated a separate CRA entity rather than litigating
   § 1681a(f), and Truework, Pinwheel, Truv, Finicity and Experian Verify all concede. The
   question to put to counsel is not "am I a CRA" but "which entity is." Weigh in the § 1681h(e)
   qualified immunity from state defamation, privacy and negligence claims, which **only CRAs
   get**, and which is a large part of what `counsel/brief-3` is trying to build by contract.

6a. **Paper the ingest as a CCPA third-party arrangement, not a service-provider one.** 11 CCR
   § 7053(a)'s six terms are compatible with the product; § 7051(a)'s ten terms, and the
   no-combining rule at § 7051(a)(5) in particular, are not. Attempting service-provider language
   the facts contradict is worse than no contract. Tell partners plainly that their transfer is a
   sale or sharing on their side, because their privacy counsel will work it out anyway and it is
   better to arrive with the answer than to be caught by it.

7. **If data broker: build DROP polling before launch.** Account creation, registration by the
   annual deadline, polling at least every 45 days from 1 August 2026, deletion within 45 days,
   and treatment of denied or unverifiable requests as opt-outs. And accept, in writing, that
   unclaimed records will be deleted in bulk by people who never heard of Grain.

8. **If CRA: build the § 1681i deletion path and accept that R2 has a federal exception.**
   § 1681i(a)(5)(A) requires deletion or modification of items found inaccurate, incomplete or
   unverifiable. The corpus already identified this; pre-claim collection guarantees it is
   exercised. R2's never-edit rule needs a stated carve-out for reinvestigation outcomes, and
   the dispute engine needs a furnisher callback API so connected employers can discharge their
   § 1681s-2(b) duties.

9. **Solve verification for a stranger before holding the first record, and build rights exercise
   on a path that requires no account.** Civ. Code § 1798.130(a)(2)(A) forbids requiring account
   creation to make a request, so the claim flow and the rights flow must be separate surfaces.
   This is the constraint a claim-based product is most likely to violate by default. No
   specific-pieces disclosure on employer-supplied identifiers alone; challenge-response against
   the held identifier plus a penalty-of-perjury declaration. Use the § 7062(d) sliding standard
   deliberately and document it: thinner proof for deletion than for disclosure. And **never
   verify an opt-out.** § 7060(b) forbids it, and it is what the *Honda* and *Todd Snyder*
   orders punished.

9a. **Build the § 1798.100(b) homepage notice at collection now.** It is cheap, entirely within
   Grain's control, requires no employer cooperation and no data-broker registration, and
   § 7012(d) makes the alternative a bar on collecting rather than a curable defect. There is no
   argument for deferring this one.

10. **Notify the subject, even though no statute clearly requires it here.** A message to the
    employer-supplied contact at first write, reading "your employer recorded your role and dates
    with Grain; here is how to claim, see, or delete it", collapses most of this memo's exposure at
    once. It converts unclaimed to claimed (fixing the CRA-adjacent consent posture, though not
    CRA status), discharges the notice-at-collection duty without relying on § 7012(i),
    forecloses the FTC § 5 unavoidability theory, kills the UDAP deception theory, and makes the
    rights mechanism real. It costs conversion friction and some employer resistance. **It is
    the single highest-value product change identified in this memo.**

11. **Design the antitrust posture against the Agri Stats remedy set, not against the withdrawn
    safety zones.** Concretely: never publish or expose a cross-employer aggregate, benchmark,
    distribution, percentile or market-level view to any party; keep compensation out of the
    schema permanently, at schema level rather than by policy; bar use of Grain output for wage
    setting or hiring coordination in the party agreement; and give workers access to their own
    record and to any score computed on them, because the **one-sided informational advantage is
    what Agri Stats remedy 4 attacks and what `THESIS.md` §7 already records as a deliberate
    cost.** That deliberate cost now has an antitrust price tag attached to it, which is new
    information for the decision. Treat `dimension_standing`, a Grain-derived, cross-employer
    normalised seniority signal served back to competing employers, as the highest-risk object
    in the schema and get a dedicated opinion on it.

12. **Fix the public copy.** "Worker-owned" alongside a pre-claim ingest the worker did not
    authorise is the UDAP exposure. Describe the mechanic in the words this memo uses.

---

## Questions for counsel

These genuinely require an outside opinion. They are additions to `counsel/brief-4`, which
should be amended before it is sent, since it does not currently describe the pre-claim mechanic
at all.

1. **The fork.** CRA or registered data broker? Specifically, how does Civ. Code
   § 1798.99.80(c)'s "to the extent that it is covered by" the FCRA partition a mixed entity, and
   is there a configuration in which Grain is a CRA for record furnishing and a data broker for
   analytics, and is that worse than being wholly one or the other?

2. **Retroactive ratification.** Does a worker's later claim of a pre-claim record have any legal
   effect on Grain's status, its lawful basis, or its notice obligations for the pre-claim
   window? My view is no. I want it tested.

2a. **The capacity question, and it is the highest-leverage unresolved item in this memo.** Do the
   other states' "acting only in an individual or household context" exclusions turn on the
   *capacity in which the individual acts toward the controller*, in which case a worker who has
   no dealings with Grain at all is a full consumer in ~19 states, or on the *subject matter* of
   the data, in which case only California applies? Colorado's express "job applicant" exclusion
   and Maryland's "communications or transactions with a controller… within the context of the
   individual's role" clause point in opposite directions. No AG guidance or case law resolves it.
   The answer changes the compliance surface by an order of magnitude.

2b. **Maryland.** If the capacity question resolves against Grain, does MODPA § 14-4607(b)(1)(i)'s
   "specific product or service requested by the consumer" standard categorically bar pre-claim
   collection in Maryland? If so, is per-state geofencing of the ingest workable, and what does
   that do to the portability proposition?

3. **§ 7012(i) reliance.** Confirm the operative text of 11 CCR § 7012(i) and whether data-broker
   registration genuinely discharges notice at collection for indirect collection at this scale,
   or whether the CPPA would expect direct notice regardless.

4. **The § 1798.105(d) deletion exceptions applied to a stranger.** Does any exception survive
   where the subject has no relationship and no expectations? My reading is that they are at
   their weakest exactly here.

5. **Verification thresholds for an unclaimed subject.** What satisfies 11 CCR §§ 7060–7063 when
   the only data Grain holds is the data a requestor would supply? Is an asymmetric threshold,
   deletion on less proof than disclosure, defensible?

6. **Reference-immunity statutes and bulk platform disclosure.** `counsel/brief-3` Q3(i) asks
   this and it is unanswered. Add the specific question: does a hospitality employer connecting
   its HRIS to Grain forfeit statutory reference immunity it would otherwise have, and what does
   the party agreement need to say about that?

7. **Personnel-record consent statutes, state by state.** Connecticut is confirmed. Michigan,
   Illinois, Pennsylvania and any others: does the thin payload clear their disclosure
   provisions, and does the "third party that performs employment-related services for the
   employer" concept survive Grain's cross-employer use of the data?

8. **Antitrust opinion.** A dedicated § 1 information-exchange opinion on a cross-employer
   worker-data platform in a concentrated local labour market, addressing specifically whether
   `dimension_standing` functions as a levelling benchmark and what safeguards restore
   defensibility absent the withdrawn safety zones. This is not covered by any existing brief and
   is the largest unaddressed exposure in the corpus.

9. **Willfulness discipline.** `counsel/brief-4` Q5(c) already asks. Sharpen it: given that R1 is
   a written internal ruling adopted over a written internal contrary analysis, and that this
   memo adds a second contrary analysis on a more adverse fact pattern, what is the § 1681n
   exposure of the decision record itself, and what should change about how these documents are
   produced and retained?

10. **Title VII coverage bias.** Is the "record sparsity correlates with employer integration
    correlates with protected characteristics" theory one plaintiffs have run, and what
    validity documentation would answer it?

11. **FEHA agent status.** Does selling capability scores used in California hiring make Grain a
    statutory employer under the 1 October 2025 ADS regulations and *Raines*? If so, the
    four-year person-level ADS recordkeeping duty lands on Grain directly and collides with both
    the retention rule in §5 and the ephemeral-analytics posture in `THESIS.md` §3. **This is a
    conflict between two of Grain's own compliance commitments and it is not currently visible
    anywhere in the corpus.**

12. **Bias-testing sequencing.** The FEHA regulations make the existence, quality and *response
    to* anti-bias testing relevant evidence, and make its absence probative. What is the right
    order of operations so that testing does not manufacture discoverable admissions, and what
    privilege structure applies (the question now being litigated in *Mobley*)?

---

## Sources

Statutes and regulations
- [15 U.S.C. § 1681a: definitions](https://www.law.cornell.edu/uscode/text/15/1681a)
- [15 U.S.C. § 1681b: permissible purposes](https://www.law.cornell.edu/uscode/text/15/1681b)
- [15 U.S.C. § 1681i: disputed accuracy](https://www.law.cornell.edu/uscode/text/15/1681i)
- [15 U.S.C. § 1681c: information contained in consumer reports](https://www.law.cornell.edu/uscode/text/15/1681c)
- [15 U.S.C. § 1681s-2: furnisher duties](https://www.law.cornell.edu/uscode/text/15/1681s-2)
- [FCRA consolidated text, FTC (May 2023)](https://www.ftc.gov/system/files/ftc_gov/pdf/fcra-may2023-508.pdf)
- [Cal. Civ. Code § 1798.140: CCPA definitions](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.140)
- [Cal. Civ. Code § 1798.99.80: data broker definition, Delete Act](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.99.80)
- [15 U.S.C. § 1681a: full text incl. (c), (g), (h), (o), (x)](https://uscode.house.gov/view.xhtml?req=granuleid:USC-prelim-title15-section1681a&num=0&edition=prelim)
- [Cal. Civ. Code § 1798.99.86: DROP](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.99.86)
- [11 CCR § 7012: notice at collection](https://www.law.cornell.edu/regulations/california/11-CCR-7012)
- [CPPA: approved regulatory text effective 1 Jan 2026 (7002, 7012, 7050–7053, 7060–7063, art. 11)](https://cppa.ca.gov/regulations/pdf/ccpa_updates_cyber_risk_admt_appr_text.pdf)
- [CPPA: CCPA updates rulemaking page](https://cppa.ca.gov/regulations/ccpa_updates.html)
- [Va. Code § 59.1-575: "consumer" definition](https://law.lis.virginia.gov/vacode/title59.1/chapter53/section59.1-575/)
- [Tex. Bus. & Com. Code ch. 510: data brokers (redesignated from ch. 509)](https://tcss.legis.texas.gov/resources/BC/htm/BC.510.htm)
- [ORS § 646A.593: Oregon data broker registration](https://oregon.public.law/statutes/ors_646a.593)
- [9 V.S.A. § 2446: Vermont data broker registration](https://legislature.vermont.gov/statutes/section/09/062/02446)
- [Conn. Gen. Stat. § 31-128f: employee's consent required for disclosure](https://law.justia.com/codes/connecticut/title-31/chapter-563a/section-31-128f/)

Agency material
- [CPPA: data brokers and DROP](https://cppa.ca.gov/data_brokers)
- [CPPA: DROP system requirements](https://cppa.ca.gov/regulations/drop.html)
- [CPPA: enforcement action, Jerico Pictures / National Public Data (Feb 2025)](https://www.cppa.ca.gov/announcements/2025/20250220.html)
- [CPPA: order, Florida data broker (May 2025)](https://www.cppa.ca.gov/announcements/2025/20250508.html)
- [FTC: "Just saying you're not a consumer reporting agency isn't enough" (Jan 2013)](https://www.ftc.gov/business-guidance/blog/2013/01/background-screening-reports-fcra-just-saying-youre-not-consumer-reporting-agency-isnt-enough)
- [FTC: final order, criminal background screening marketers (May 2013)](https://www.ftc.gov/news-events/news/press-releases/2013/05/ftc-approves-final-order-settling-charges-against-marketers-criminal-background-screening-reports)
- [FTC: Filiquarian analysis to aid public comment](https://www.ftc.gov/sites/default/files/documents/cases/2013/01/130110filquariananalysis.pdf)
- [CFPB: consumer reporting companies list, The Work Number](https://www.consumerfinance.gov/consumer-tools/credit-reports-and-scores/consumer-reporting-companies/companies-list/work-number/)
- [CFPB: enforcement action, Equifax (Jan 2025, $15M)](https://www.consumerfinance.gov/enforcement/actions/equifax-inc-and-equifax-information-services-llc/)
- [FTC: 40 Years of Experience with the FCRA, staff report (2011)](https://www.ftc.gov/sites/default/files/documents/reports/40-years-experience-fair-credit-reporting-act-ftc-staff-report-summary-interpretations/110720fcrareport.pdf), comments 603(f)-3B, 603(f)-3C, 603(f)-4E, 603(d)-4, 603(d)-6B, 603(d)(2)(A)(i)-1E
- [FTC: Islinger advisory opinion (9 June 1998), intermediaries and the transaction-or-experience exclusion](https://www.ftc.gov/legal-library/browse/advisory-opinions/advisory-opinion-islinger-06-09-98)
- [United States v. Spokeo: complaint](https://www.ftc.gov/sites/default/files/documents/cases/2012/06/120612spokeocmpt.pdf) · [case page](https://www.ftc.gov/legal-library/browse/cases-proceedings/1023163-spokeo-inc)
- [CFPB: Protecting Americans From Harmful Data Broker Practices, NPRM, 89 FR 101402 (13 Dec 2024)](https://www.federalregister.gov/documents/2024/12/13/2024-28690/protecting-americans-from-harmful-data-broker-practices-regulation-v)
- [CFPB: withdrawal of the data broker NPRM, 90 FR 20568 (15 May 2025)](https://www.federalregister.gov/documents/2025/05/15/2025-08644/protecting-americans-from-harmful-data-broker-practices-regulation-v-withdrawal-of-proposed-rule)
- [CFPB: list of consumer reporting companies (2025)](https://files.consumerfinance.gov/f/documents/cfpb_consumer-reporting-companies_list_2025.pdf)
- [Cal. AG: CCPA enforcement](https://oag.ca.gov/privacy/ccpa/enforcement)
- [Cal. AG: employer HR-data sweep (July 2023)](https://www.oag.ca.gov/news/press-releases/attorney-general-bonta-seeks-information-california-employers-compliance)
- [CPPA: ROR Partners enforcement (Dec 2025)](https://www.cppa.ca.gov/announcements/2025/20251203.html)
- [DOJ/FTC: Antitrust Guidance for Human Resource Professionals (2016)](https://www.justice.gov/atr/file/903511/download)

Employer-side statutes
- [Tex. Lab. Code § 103.004: reference immunity](https://texas.public.law/statutes/tex._labor_code_section_103.004)
- [Fla. Stat. § 768.095](https://www.flsenate.gov/Laws/Statutes/2021/768.095)
- [Colo. Rev. Stat. § 8-2-114: immunity and anti-blacklisting](https://codes.findlaw.com/co/title-8-labor-and-industry/co-rev-st-sect-8-2-114/)
- [Ohio Rev. Code § 4113.71](https://codes.ohio.gov/ohio-revised-code/section-4113.71)
- [Cal. Civ. Code § 47(c)](https://codes.findlaw.com/ca/civil-code/civ-sect-47/)
- [MCL § 423.506: Bullard-Plawecki](https://www.legislature.mi.gov/documents/mcl/pdf/mcl-423-506.pdf)
- [820 ILCS 40: Illinois Personnel Record Review Act](https://law.justia.com/codes/illinois/chapter-820/act-820-ilcs-40/)
- [Mo. Rev. Stat. § 290.140: service letter](https://revisor.mo.gov/main/OneSection.aspx?section=290.140)

Automated-decision law
- [Colorado SB 25B-004: delay](https://leg.colorado.gov/bills/sb25b-004)
- [Colorado SB 26-189: repeal and reenactment, operative 1 Jan 2027](https://leg.colorado.gov/bills/sb26-189)
- [NYC DCWP: automated employment decision tools](https://www.nyc.gov/site/dca/about/automated-employment-decision-tools.page)
- [NY State Comptroller: audit of LL 144 enforcement (Dec 2025)](https://www.osc.ny.gov/state-agencies/audits/2025/12/02/enforcement-local-law-144-automated-employment-decision-tools)
- [Texas HB 149 (TRAIGA), enrolled text](https://capitol.texas.gov/tlodocs/89R/billtext/html/HB00149F.htm)

Antitrust
- [FTC: withdrawal of health care enforcement policy statements (July 2023)](https://www.ftc.gov/news-events/news/press-releases/2023/07/federal-trade-commission-withdraws-health-care-enforcement-policy-statements)
- [DOJ/FTC: Antitrust Guidance for Human Resource Professionals (2016), superseded Jan 2025](https://www.ftc.gov/system/files/documents/public_statements/992623/ftc-doj_hr_guidance_final_10-20-16.pdf)
- [United States v. Agri Stats: proposed final judgment and competitive impact statement (Fed. Reg., 5 June 2026)](https://www.federalregister.gov/documents/2026/06/05/2026-11329/united-states-et-al-v-agri-stats-inc-proposed-final-judgment-and-competitive-impact-statement)
- [DOJ: U.S. v. Agri Stats case page](https://www.justice.gov/atr/case/us-v-agri-stats-inc)
- [FTC: amicus brief, Duffy v. Yardi Systems](https://www.ftc.gov/legal-library/browse/amicus-briefs/duffy-v-yardi-systems-inc)

Case law
- [Todd v. Exxon Corp., 275 F.3d 191 (2d Cir. 2001)](https://law.justia.com/cases/federal/appellate-courts/F3/275/191/592358/)
- [Kidd v. Thomson Reuters Corp., 925 F.3d 99 (2d Cir. 2019)](https://law.justia.com/cases/federal/appellate-courts/ca2/17-3550/17-3550-2019-05-30.html)
- [Lewis v. Equitable Life Assurance Soc'y, 389 N.W.2d 876 (Minn. 1986)](https://law.justia.com/cases/minnesota/supreme-court/1986/c8-84-1065-2.html)
- [Zabriskie v. Federal National Mortgage Ass'n, 940 F.3d 1022 (9th Cir. 2019)](http://cdn.ca9.uscourts.gov/datastore/opinions/2019/10/08/17-15807.pdf)
- [Sweet v. LinkedIn Corp., No. 5:14-cv-04531 (N.D. Cal.): docket](https://www.courtlistener.com/docket/4181264/sweet-v-linkedin-corporation/)
- *OOIDA v. USIS Commercial Services*, 537 F.3d 1184 (10th Cir. 2008): **not retrieved; the only
  appellate authority located on employer-furnished employment-history files. Pull before relying
  on §3 in either direction.**

---

## Verification status

**Verified against primary text:** all FCRA provisions cited; *Kidd* and *Zabriskie*; the
*Spokeo* complaint; the Islinger opinion letter; the FTC 2011 staff report comments quoted; all
Federal Register citations and withdrawal notices; the CFPB Equifax order; Cal. Civ. Code
§§ 1798.100, .105, .110, .115, .130, .140, .145, .99.80, .99.82, .99.86; 11 CCR §§ 7002, 7012,
7050–7053, 7060–7063, art. 11; Conn. Gen. Stat. § 31-128f; MCL § 423.506; 820 ILCS 40; five
reference-immunity statutes; Tex. ch. 510; ORS § 646A.593; 9 V.S.A. § 2446; Colorado SB 25B-004
and SB 26-189; Md. Com. Law §§ 14-4601, 14-4607; Va. Code § 59.1-575.

**Citation corrections to the existing corpus.** *United States v. Spokeo*, not *FTC v. Spokeo*
(`research/01` §1.1, `counsel/brief-4` §3). The CPRA HR and B2B exemptions went **inoperative by
their own terms**, not repealed. Texas data brokers are **ch. 510**, not ch. 509. Oregon is
**ORS § 646A.593**, not § 646A.560. There is no **11 CCR § 7052**. The no-account-creation rule
is **Civ. Code § 1798.130(a)(2)(A)**, not a regulation. Colorado SB 24-205 no longer exists.

**Explicitly unsupported, do not cite:** any **CFPB** enforcement action against TALX, Equifax
Workforce Solutions, or The Work Number. A search of the CFPB enforcement database returns
nothing. The on-point action is an **FTC** matter.

**Not verified, flagged in place:** the TALX FTC action's date, docket and penalty; the reasoning
of the *Sweet v. LinkedIn* dismissal; *OOIDA v. USIS*; the current status of the January 2025
DOJ/FTC Antitrust Guidelines for Business Activities Affecting Workers under the present
administration; the *Todd* factor list as stated in the opinion itself; the compelled
self-publication state split; the 2023 labour-market criminal case outcomes (*Jindal*, *DaVita*,
*Manahe*, *Patel*); the FTC actions against HireRight, RealPage, InfoTrack, AppFolio, Instant
Checkmate and Sterling; personnel-record statutes outside Connecticut, Michigan and Illinois;
Utah, Maryland AEDT, California SB 7, New York State, Virginia HB 2094, and the status of EEOC AI
guidance; the complete state-by-state privacy effective-date and universal-opt-out tables.

Both research threads exhausted the session's web-search budget, and ftc.gov and CourtListener
returned intermittent 403s late in the work. The unverified list above is a consequence of that,
not a judgement that the items are doubtful.

Market positions (secondary; these are companies' own commercial statements, not adjudications)
- [The Work Number: FCRA and employment verification](https://theworknumber.com/fair-credit-reporting-act)
- [Truework: FCRA compliance](https://www.truework.com/consumer-reporting-compliance)
- [Pinwheel: consumer reporting agency](https://www.pinwheelapi.com/fcra/consumer-reporting-agency)
- [Argyle: using non-FCRA data for income and employment verifications](https://www.argyle.com/blog/using-non-fcra-data-for-income-employment-verifications)

Practitioner commentary (secondary, labelled as such)
- [Alston & Bird: DROP is coming due](https://www.alstonprivacy.com/drop-is-coming-due-what-californias-delete-act-means-for-data-brokers-in-august/)
- [Cozen O'Connor: California Delete Act enforcement sweep](https://www.cozen.com/news-resources/publications/2025/california-delete-act-enforcement-sweep)
- [Hunton: CPPA enforces Delete Act against data brokers](https://www.hunton.com/privacy-and-cybersecurity-law-blog/cppa-enforces-delete-act-against-data-brokers)

Internal corpus relied on
- `research/01-regulatory-perimeter.md` §1 (FCRA analysis; adopted and extended)
- `research/03-person-id-and-merge.md` (mixed-file risk; now an FCRA accuracy problem)
- `research/14-jurisdictional-recordkeeping-and-adm-duties.md` §1 (duty-holder analysis;
  adopted without re-derivation)
- `model/attestation-interface.md` (the ratified contract this mechanic contradicts)
- `counsel/brief-3-attesting-party-liability-shield.md`, `counsel/brief-4-worker-agreements.md`
- `THESIS.md` §5, §7, §8
