# Pre-claim employer-provided records: EU/UK

**Status:** Research memo, 2026-08-19. **Evidence tier: binds nothing.**
Produced by a background research agent against primary sources; not
counsel-reviewed and not read line-by-line by the session that filed it.
Its conclusions are indexed in `decisions/LOG.md#031`; where this memo and a
decision differ, the decision governs.

**Subject.** The legal boundaries on holding employer-supplied employment
history about a person who has not signed up, for that person to claim later.
Written against the employer-push design that decision 031 has since replaced
with worker-initiated verification. It is retained because its analysis of
lawful basis, controller allocation, Art. 14 and retention is the evidence
base for that ruling, and because the UK divergence it records (DUAA 2025
s.77) remains live.

**Known gaps**, recorded by the agent: several enforcement decisions are cited
at reference level, meaning identifier and proposition rather than decision text; EDPB
Guidelines 1/2024 exist only as the October 2024 consultation version; the
Art. 9 special-category fork is unresolved; the proposed retention period is
reasoned, not authority-backed. The session web-search budget was exhausted
mid-research.

---

# Pre-claim employer-provided records: EU/UK

**Status:** Research memo, not legal advice. Not counsel-reviewed. Written 2026-08-19
against primary sources retrieved this session plus two parallel research threads.
Confidence is stated on every substantive conclusion. Settled law, regulator guidance
and my own inference are labelled separately throughout, per this repo's standard.

**Scope:** the hospitality-vertical mechanic only: Grain ingests an employer's active
roster and records verified employment attestations about people who are not Grain
users, have not consented, and may not know Grain exists. Companion to
`research/01-regulatory-perimeter.md` §2, which this memo extends rather than restates.

**Retrieval caveats, stated up front.** (a) EDPB Guidelines 1/2024 on Art. 6(1)(f) exist
only as **version 1.0, adopted 8 October 2024, footer-stamped "Adopted – version for
public consultation."** No final version could be verified. Every paragraph number cited
is v1.0 and must be re-checked if a v2.0 appears. (b) Several enforcement decisions
below (Garante *Limit Call* doc. web 9971433; APD *Black Tiger* 87/2024; AP *Experian*;
Datatilsynet *SSI* 2021-432-0070; NAIH-5802-9/2022; DPC *WhatsApp* IN-18-12-2 with EDPB
Binding Decision 1/2021; CNIL SAN-2021-010, SAN-2024-002, SAN-2024-014/015) are held at
**reference level**: I have the case identifiers and the proposition each is cited for,
but did not read the decision text myself. They are marked `[ref-level]` at each use and
should not be quoted to a regulator or a counterparty without verification. (c) Fashion
ID, Wirtschaftsakademie and Jehovan todistajat paragraph numbers were verified via
EUR-Lex by the research thread, not by me directly.

---

## TLDR: conclusions in full

**1. There is no lawful basis for the mechanic as specified. Not "a weak basis," but none.**
Consent is unavailable (the employer cannot consent for the worker: Art. 4(11) requires
*the data subject's* affirmative action, and Art. 7(1) puts the burden on Grain to
*demonstrate* each individual consented, and a contractual warranty from the employer is not
that proof). Contract is unavailable on the face of Art. 6(1)(b), which reaches only "a
contract to which the data subject is party." Legitimate interests is the only candidate
and it fails the **necessity** limb before the balancing is even reached, because
*C-621/22 KNLTB* ¶52–53 holds that where the controller could instead "inform its members
beforehand and ask them whether they want their data to be transmitted," the processing
is not necessary. Grain can ask first. That it would rather not is a commercial
preference, not a necessity argument. **Confidence: high on consent and contract;
medium-high on the LI necessity failure** (KNLTB is a Ninth Chamber judgment on
disclosure-for-consideration, not on record-keeping, so the analogy is strong but not
exact). What would raise it: a decided case on an employment-data intermediary rather
than a marketing one.

**2. A narrower version of the mechanic survives, and it is the only version that does.**
An Art. 6(1)(f) basis is arguable for holding an employer-supplied record **solely to
enable the named worker to claim it**: minimal fields, no employer-side read of any
kind before the claim, no analytics input, a short fixed fuse, and active individual
notice at ingestion. The interest is then "enabling a worker to obtain a portable record
of their own work," which is an interest of the *data subject* pulled through as Grain's
interest, not a pure commercial interest in a database. The moment the pre-claim record
is readable by any employer, feeds analytics, or is held open-endedly, the balancing
collapses. **Confidence: medium.** This is my inference; no authority blesses it.

**3. The processor-until-claim hypothesis fails, and it fails at the first row, not at
the margin.** Grain determines all four of the essential means EDPB Guidelines 07/2020
¶40 enumerates: type of personal data, duration, categories of recipients, categories
of data subjects. The processing *is* the key element of Grain's service (¶82). And
Grain's stated purpose from the outset, a record that outlives the employment
relationship, travels to other employers, and feeds an analytics product Grain sells,
is Grain's own purpose, which is exactly the **MarketinZ** fact pattern at ¶81 and
Art. 28(10). Labels do not decide the question (¶12, ¶29). **The claim event changes
nothing about role allocation**; it only changes which lawful bases become available for
the worker-facing service. **Confidence: high.**

**4. The correct allocation is stage-specific: joint controllership with the employer at
ingestion and attestation creation, Grain sole controller for everything downstream.**
Employer and Grain take converging decisions that are "inextricably linked" and each
necessary for the processing to occur (EDPB 07/2020 ¶54–55; *C-683/21 Nacionalinis*
¶43). Per *Fashion ID* ¶74/76 and EDPB ¶57 that joint control is confined to the
operations for which they jointly determine purposes and means: ingestion, matching,
attestation creation. It does not extend to Grain's later cross-employer record,
disclosure to other employers, or analytics, for which Grain is sole controller. Two
consequences bite immediately: *C-683/21* ¶44–45 holds joint controllership arises
**without any arrangement**, so Grain is in Art. 26(1) breach from the first ingestion if
it ships without one; and *Wirtschaftsakademie* ¶41–42 and *Fashion ID* ¶83 both hold
responsibility is **greater** where the affected people are non-users. **Confidence: high
on the sole-controllership downstream; medium-high on joint controllership at ingestion**
(it depends on facts not yet fixed, such as how much the employer specifies about what is
recorded).

**5. Art. 14 applies in full and the disproportionate-effort exception is not available.**
WP260 rev.01 ¶61 states the exception "should not be routinely relied upon by data
controllers who are not processing personal data for the purposes of archiving in the
public interest, for scientific or historical research purposes or statistical purposes."
The Polish NSA in *III OSK 2538/21* (19 September 2023) upheld exactly that reading and
added the anti-paradox point: scale and cost are irrelevant, because otherwise "an entity
processing personal data on a large scale could rely on the exception... whereas an
entity doing so on a small scale would have to perform it." CNIL in *KASPR*
(SAN-2024-020, 5 December 2024) found the controller "capable of informing persons from
deployment" precisely because it **possessed email addresses**. Grain will possess the
employer-supplied phone and email. **Confidence: high.**

**6. The employer's own staff privacy notice does not discharge Grain's Art. 14 duty, but
an employer-delivered claim invitation can, if it carries Grain's content and Grain can
evidence delivery.** Each controller owes its own transparency duty; a generic "we may
share your data with partners" clause in an HR notice does not name Grain, its purposes,
its legal basis, its retention, or the Art. 21 objection right, and so does not
constitute Art. 14 information. `[ref-level: Garante, Limit Call, doc. web 9971433,
cited for the proposition that the source's notice does not discharge the recipient
controller's duty; verify before relying.]` What works is delegated **delivery**: the
employer is the messenger, the content is Grain's, and Grain retains proof of dispatch
per worker. **Confidence: high on the principle; medium on delegated delivery being
accepted**, which is my inference from the fact that Art. 14 prescribes content and
timing but not channel.

**7. A worker for whom the employer supplies no deliverable contact channel must not be
ingested.** Art. 14(5)(b)'s impossibility must, per WP260 ¶62, be "directly connected to
the fact that the personal data was obtained other than from the data subject." Where
Grain could have required a contact channel as a condition of ingestion and chose not to,
the impossibility is self-inflicted and the exception is not made out. **Confidence:
medium-high.** This is inference from ¶62 applied to a fact pattern nobody has decided.

**8. Every right in Arts. 15–22 is exercisable from the moment of ingestion, and the
Art. 21(1) objection is effectively unanswerable.** Because the basis is Art. 6(1)(f),
Art. 21(1) is available, and on objection Grain must demonstrate "compelling legitimate
grounds which override the interests, rights and freedoms of the data subject", which is a
higher bar than the Art. 6(1)(f) balancing it has already lost. Against a person who has
never used Grain, never consented, and whose objection is precisely that they do not want
a commercial third party holding their employment history, that showing is not winnable
on a business interest. **Confidence: high.** This mirrors and extends
`research/12-deletion-vs-reputation-evasion.md` conclusion 4: where nothing went wrong
there is no interest to balance.

**9. Identity verification for a non-user rights request must be by control of the
identifier the employer supplied, and must never require account creation.** Art. 12(6)
permits additional information only where there is reasonable doubt; demanding ID
documents from someone whose record contains only a name, phone and dates collects more
sensitive data than the record itself and breaches Art. 5(1)(c). Requiring signup to
exercise a right converts a rights request into a customer acquisition, which is the
same defect the Greek HDPA punished in *PwC Business Solutions* (Decision 26/2019,
EUR 150,000) as transferring the burden of compliance onto the data subject.
**Confidence: high on the Art. 5(1)(c) point; medium on the PwC analogy**, which
concerned mislabelled legal basis rather than DSAR friction.

**10. Indefinite retention pending a claim that may never come is indefensible, and CNIL
has already decided the precise point.** In *KASPR* the CNIL held that a retention period
that auto-renewed on each data refresh was disproportionate **specifically because the
data subjects had no active relationship with the controller and therefore could not
determine when they would become "inactive"**, producing indefinite retention with no
meaningful exit. It capped retention at five years with no automatic extension. Grain's
unclaimed population is in exactly that position. **Confidence: high** that indefinite is
unlawful; **medium** on what the correct number is.

**11. The concrete retention rule: twelve months, from ingestion, non-renewable by
employer re-sync, hard-deleted automatically.** Reasoned in §5. **Confidence: medium**,
because the shape is well-supported, the number is a judgment call.

**12. The UK is materially more permissive on notice and on automated decisions, and
materially more dangerous on employment-agency law.** DUAA 2025 s.77 replaces UK GDPR
Art. 14(5)(b) with a free-standing disproportionate-effort exception at new Art. 14(5)(e),
untethered from the archiving/research framing that kills the EU argument, but new
Art. 14(7) makes public notice mandatory. DUAA s.80 replaces Art. 22 with Arts. 22A–22D
in force 5 February 2026 (SI 2026/82 reg 2), inverting the default: solely automated
significant decisions are now permitted on any lawful basis subject to Art. 22C
safeguards, restricted only where Art. 9(1) data is involved. Neither DUAA Annex 1
(recognised legitimate interests) nor Annex 2 (compatible purposes) contains anything
commercial, so Grain gains nothing there. **The larger UK finding is not data protection
at all**: Employment Agencies Act 1973 s.13(2) defines an employment agency as a business
"providing services (**whether by the provision of information or otherwise**) for the
purpose of finding persons employment with employers or of supplying employers with
persons for employment," and DBT guidance says online platforms are in scope. If Grain's
purpose is found to be helping employers find workers, it *is* an employment agency, and
s.6(1)(a) makes any fee charged to a work-seeker a **criminal offence**. **Confidence:
high on the DUAA text; medium-high on the EAA exposure**, which turns on marketing
positioning that is not yet fixed.

**13. Outside the six questions, three things would be negligent to omit.** (a) **EU AI
Act**: the analytics product is Annex III point 4(b) high-risk with **no Art. 6(3)
derogation available**, because the final subparagraph makes any Annex III system that
performs profiling "always" high-risk. The deadline moved to **2 December 2027** by the
AI Omnibus (in force 27 July 2026), which is runway, not relief. Art. 5(1)(f)'s ban on
emotion inference in workplace and recruitment contexts is in force **now**. And
Art. 26(7) requires employer-deployers to inform workers' representatives and affected
workers **before** using a high-risk system, which is flatly incompatible with a
pre-claim population that does not know Grain exists. (b) **Competition law**: 2023
Horizontal Guidelines ¶368 expressly catches information exchanged "indirectly, by or
through a third party (such as a service provider, platform, online tool or algorithm)";
¶408 confines a lawful data pool to participants seeing "**only their own information and
the final, aggregated, information of other participants**." Grain's product is
individualised by design. The Commission's first labour-market cartel decision
(*Delivery Hero/Glovo*, AT.40795, 2 June 2025, EUR 329m) and the CMA's *Competing for
talent* guide put concentrated local employer sets, exactly hospitality's shape, in the
danger zone. (c) **The mechanic breaks Grain's own ratified schema.**
`model/attestation-interface.md` (schema_version 0.2, RATIFIED, decision 006) states:
"A person without a ledger ID cannot be attested for; **the attestation waits until the
reference exists.**" The hospitality mechanic is that rule inverted. Either the contract
changes by ratified amendment or the mechanic does not ship.

**14. Two internal positions do not survive contact with a pre-claim population.**
THESIS §7 records as a "deliberate cost" that *workers do not see when analytics are run
on them*. For a claimed user that is a product-ethics choice. For an unclaimed subject it
is a straightforward Art. 14(2)(f)/(g) and Art. 15(1)(h) breach, and under the AI Act it
is also an Art. 26(7) breach by the customer. Separately, decision 028's "**Partners
write freely. No worker countersign**" is defensible when the subject is a user who can
see and dispute the write; applied to a non-user it means an identifiable person acquires
a permanent adverse-capable record authored by a party with no counterparty and no
notice. **Confidence: high** that these need re-ruling before the vertical ships in
EU/UK.

---

## 1. Lawful basis

### 1.1 Consent: unavailable twice over

The employer route fails on the identity of the consenting party before it fails on
freedom. Art. 4(11) defines consent as an indication of "**the data subject's** wishes by
which **he or she**, by a statement or by a clear affirmative action, signifies
agreement." Art. 7(1) requires the controller to "be able to **demonstrate** that the
data subject has consented." The GDPR contains exactly one mechanism by which one person
consents for another: Art. 8(2), parental responsibility for a child. There is no
employer analogue.

Even repaired to point at the right person, the worker's own consent is presumptively
invalid. WP29 Opinion 2/2017 on data processing at work (WP249, 8 June 2017) states at
p. 3 that "consent is highly unlikely to be a legal basis for data processing at work,
unless employees can refuse without adverse consequence," at p. 5 that "**employers
cannot usually provide valid consent for the processing of personal data of their
employees**," and at p. 23 that employees "can only give free consent in exceptional
circumstances, when no consequences at all are connected to acceptance or rejection."
EDPB Guidelines 05/2020 on consent (v1.1, 4 May 2020) ¶21 repeats this and ¶33
(Example 6) addresses the closest analogue, a bank seeking consent "to allow **third
parties** to use their payment details", holding consent unfree where refusal costs the
service. ¶38: "a consent relying on an alternative option offered by a third party fails
to comply with the GDPR."

Enforcement confirms it is not theoretical. The Greek HDPA fined **PwC Business Solutions
SA EUR 150,000** (Decision 26/2019, 30 July 2019) for presenting consent as the basis for
employee processing when another basis in fact applied, for the unfairness of giving
employees "the false impression" that consent governed, and for **Art. 5(2)
accountability**, because the company "transferred the burden of proof of compliance to the data
subjects." The Italian Garante fined a school EUR 4,000 (27 March 2025, Istituto
"P. Galluppi" Tropea) holding that "consent is not a valid legal basis... in the
employment context, both in the public and private sector", **even though the workers
had actually consented and preferred the method**.

**Practical read.** The strongest lever against a warranty-based design is Art. 7(1), not
Art. 4(11). Even a vendor who somehow wins the argument that employer-relayed consent
counts must still *demonstrate*, per person, that the individual consented. A contractual
warranty from the employer is not that evidence, and Grain would be liable for the gap.

**Confidence: high.** Gap to note honestly: no EDPB, WP29 or DPA text states in terms
that "an employer may not consent on behalf of an employee to a third party's
processing." The proposition is built from Art. 4(11), Art. 7(1) and the freedom
authorities. Do not attribute a sentence to guidance that does not contain it.

### 1.2 Contract: unavailable on the face of the text

Art. 6(1)(b) covers processing "necessary for the performance of a contract **to which
the data subject is party**." A rostered employee who has no relationship with Grain is
not a party to Grain's contract with the employer. That is the whole answer, and it comes
from the statute rather than from guidance.

EDPB Guidelines 2/2019 (v2.0, 8 October 2019) corroborate the strictness without holding
the point: ¶22 and section heading 2.5 both read "with the data subject"; ¶30 requires
the processing to be "objectively necessary for a purpose that is **integral** to the
delivery of that contractual service **to the data subject**"; ¶31 says "a contract cannot
artificially expand the categories of personal data or types of processing operation";
¶37 says that where processing is "necessary for the controller's **wider business
model**... Article 6(1)(b) will not be a legal basis." *Meta v Bundeskartellamt*
(C-252/21, 4 July 2023) ¶98 requires processing to be "**objectively indispensable** for a
purpose that is integral to the contractual obligation intended for the data subject."

**Verification note, stated because a reader will check.** There is **no paragraph** in
Guidelines 2/2019 expressly saying Art. 6(1)(b) cannot cover third parties who are not
party to the contract. The nearest hook is ¶47, on the pre-contractual limb not covering
processing "at the request of a third party." Argue from Art. 6(1)(b)'s own words.

**Confidence: high.**

### 1.3 Legitimate interests: the only candidate, and it fails as designed

**Step 1 (legitimate interest) is passed.** *KNLTB* ¶48–49 confirms a commercial interest
can be a legitimate interest "provided that it is not contrary to the law." EDPB
Guidelines 1/2024 ¶17 requires the interest to be lawful, "clearly and precisely
articulated," and "real and present, not speculative." Grain's interest, maintaining a
verified employment record and building a portable cross-employer record, is
articulable. CNIL in *KASPR* ¶41 similarly accepted the commercial interest at step 1.
Note EDPB ¶18: Recital 47's "relevant and appropriate relationship" is an *indicator*,
not a step-1 condition, so the absence of a relationship should be argued in the
balancing, not here.

**Step 2 (necessity) fails, and this is the decisive finding.** *KNLTB* ¶52–53 held the
federation's disclosure was not necessary because it could instead "**inform its members
beforehand and ask them whether they want their data to be transmitted**." An available
opt-in defeats necessity. Grain's whole design premise is that asking first is
commercially inconvenient: the flywheel needs the record to exist before the worker
arrives. That is not a necessity argument; it is the opposite of one. EDPB ¶28: necessity
is "not simply what is useful." Guidelines 2/2019 ¶25, applied by analogy: "if there are
realistic, less intrusive alternatives, the processing is not 'necessary'." A claim-first
flow (employer invites; worker signs up; employer then attests) is a realistic
alternative, and it is, in fact, what decision 028 already ruled for the general product
("the party registers, not the person... signed link and one click").

**Step 3 (balancing) also fails, on reasonable expectations.** EDPB ¶54 lists as the
first contextual element "the **very existence of a relationship** with the data subject
(e.g., one should distinguish between customers and non-customers)." ¶52: sectoral
common practice does not create expectation. ¶53 forecloses the obvious repair: "the mere
fulfilment of the information obligations set out in Articles 12, 13 and 14 GDPR is not
sufficient in itself to consider that the data subjects can reasonably expect a given
processing." So publishing a notice does not manufacture the expectation. ¶120 is the
sharpest line for the analytics side: the balancing test "would hardly yield positive
results for intrusive profiling and tracking practices."

*KNLTB* ¶55–56 is the closest judicial statement: particular importance attaches to
whether the subjects "could reasonably expect, **at the time when their personal data were
collected**... that those data would be disclosed, **for consideration**, to third
parties," and the transfer occurred "in a context which, **contrary to what follows from
recital 47**... does not appear to be characterised by a **relevant and appropriate
relationship**."

*Meta* ¶117 holds that even for a free service the user "cannot reasonably expect"
profiling for advertising; ¶122–123 leave product improvement open in principle but doubt
it survives balancing at scale.

**The enforcement analogue is exact.** CNIL, **KASPR, SAN-2024-020, 5 December 2024,
EUR 240,000**, a B2B contact-enrichment tool holding ~160 million records about people
who were not its customers and selling access to businesses. CNIL accepted the commercial
interest (¶41) and then found at **¶46 that the targeted persons had "no relevant and
appropriate relationship" with the company**, and at ¶50 that their interests and
fundamental rights **prevailed**. It further held (¶43) that where individuals had
restricted the visibility of their contact details, that was an **implicit objection**
that expectations must account for. Every structural feature of KASPR is present in
Grain's pre-claim design: no relationship, contact data about non-users, retention that
renews without the subject's ability to exit, and a business selling access to records
about people who never engaged with it.

Two companion decisions matter for the employer-supplied posture. CNIL,
**HUBSIDE.STORE, SAN-2024-004, 4 April 2024, EUR 525,000** (of which EUR 325,000 for
Arts. 6 and 14) held at ¶45 that a "simple contractual commitment" from the upstream
supplier is **insufficient**: the recipient, as controller, must itself verify the
upstream lawfulness, and at ¶71–77 rejected legitimate interests because prospects
"could not reasonably expect contact from a company whose name was absent from the
partner lists supplied at collection." Read across: an employer warranty that "our staff
notice covers this" is worth nothing, and Grain being unnamed in the employer's HR notice
is itself a reason the LI fails. WP29 Opinion 06/2014 (WP217) p. 26 is the ancestral
statement, and it describes Grain's category by name: controllers cannot rely on Art. 7(f)
to combine vast amounts of data from different sources "and create — and, for example,
with the intermediary of **data brokers**, also trade in — complex profiles... without
their knowledge, a workable mechanism to object, let alone informed consent."

**Confidence: medium-high that the LI fails as designed.** The necessity failure rests on
a Ninth Chamber judgment about disclosure-for-consideration rather than about record
custody, so a counterparty could distinguish it; the balancing failure rests on KASPR,
which is a national decision. What would raise confidence: an EDPB opinion or a CJEU
reference on employment-data intermediaries, or a decided case on a professional-network
"unclaimed profile" model.

### 1.4 The narrow version that survives, and what it costs

My inference, labelled as such. A defensible Art. 6(1)(f) exists for a materially
different mechanic:

- The interest is stated as **enabling the named worker to obtain and control a portable
  record of their own work**, an interest that runs *to* the data subject, not merely to
  Grain and the employer. EDPB ¶19–26 permits third-party interests; ¶30 warns they are
  "generally less expected," which cuts the other way when the third party is the data
  subject.
- **No employer may read an unclaimed record. Ever. Including the employer that supplied
  it**, since that employer already holds the underlying facts in its own HR system and gains
  nothing but a competitive window into rivals' rosters (see §7 on competition law).
- **No unclaimed record is an input to analytics**, or to any model, ranking, aggregate
  statistic, or benchmark. EDPB ¶34 is the constraint that makes this count: measures the
  GDPR already requires do not qualify as mitigating measures; only measures going beyond
  the baseline do. Excluding a lawful-to-hold record from a lawful product is such a
  measure.
- **Active individual notice at ingestion**, per §3.
- **A short fixed fuse**, per §5.

Under those conditions the interest is real, the necessity argument becomes coherent
(you cannot let a worker claim a record that does not exist), and the balancing has
something to weigh on the subject's side. It is still not certain. **Confidence: medium.**

The cost is that this version deletes the commercial reason for building it. The
flywheel value of pre-claim ingestion is that employers can see rosters and analytics can
run early. Strip both and what remains is a pre-provisioned invitation. That is the
honest trade and it should be ruled on as a trade, not discovered later.

### 1.5 Special-category risk in roster data: real, and currently unhandled

The ratified interface bans sensitive data at the *attestation* boundary
(`model/attestation-interface.md`, amendment A-4: "government ID numbers, DOB, health
data, criminal proceedings, nationality/immigration detail... are schema-invalid in every
attestation field, including free text. Enforced at ingestion"). **The hospitality
mechanic opens a second pipe, bulk HR/roster sync, that A-4 was not written against.**
That is a gap, not a defence.

What a real hospitality roster carries: sickness and injury absence codes; maternity
leave; disability accommodations expressed as reduced hours or adjusted duties; standing
Friday/Saturday exclusions or Ramadan adjustments; trade-union representative role codes
and union-negotiated shift blocks.

The inference threshold is the problem. *OT v Vyriausioji tarnybinės etikos komisija*
(C-184/20, Grand Chamber, 1 August 2022) holds at ¶119 that data not inherently sensitive
fall in Art. 9(1) where they permit **deduction**, and at ¶127 that excluding indirectly
revealing processing would compromise the regime's "**effectiveness**." *Meta* ¶69 removes
both available excuses: the prohibition applies "independently of whether the revealed
information is correct" and "independently of whether the controller acts with the aim of
obtaining" it. ¶68 extends the analysis to information about "**any other natural
person**," not just users, directly on point for a non-user population.

EDPB Guidelines 8/2020 on targeting of social media users (v2.0, 13 April 2021) set the
operative test at **p. 33**; note the document has **no numbered paragraphs**, so cite by
page: a single data point that reveals a pattern "will generally not in and of itself" be
special-category data, "**However, it may be considered as processing of special
categories of data if these data are combined with other data or because of the context
in which the data are processed or the purposes for which they are being used.**" And the
safe harbour, which is a **two-limb** test: Art. 9 is not triggered if the processing
"**does not result in inference** of special categories of data **and** the [controller]
**has taken measures to prevent** that such data can be inferred or used for targeting."
Holding the data while merely declining to look fails the second limb.

WP251rev.01 p. 15: "Profiling can create special category data by inference from data
which is not special category data in its own right but becomes so when combined with
other data." EDPB Guidelines 8/2020 fn 102 quotes this, so it is current doctrine.

**A genuine doctrinal fork you must argue rather than assume.** ICO guidance (UK GDPR;
persuasive only in EU) says "a simple absence record, without any details of a worker's
health condition is **not likely to be** special category data." That sits uneasily with
C-184/20 ¶127. My read: the ICO line is defensible for an isolated absence flag and gets
weaker as duration, frequency and cross-employer pattern accumulate, which is precisely
what a portable record accumulates. **Treat the ICO position as a floor, not a safe
harbour, in EU analysis.**

**Art. 9(2)(b) is very likely unavailable to Grain.** The gateway asks whose employment-law
obligations are being discharged. An unrelated commercial vendor processing for its own
product purposes has none toward these workers; the obligations belong to the employer.
CNIL's HR référentiel treats work-accident declarations, *arrêts de travail* and
*inaptitude* findings as **the employer's** Art. 9(2)(b) processing, which reinforces the
point. Art. 9(2)(a) explicit consent is the only fallback and is unreliable for the
reasons in §1.1. Art. 9(4) means health, genetic and biometric data may attract *further*
national conditions, so **there is no single EU-wide answer**: a market-by-market check
is required for every jurisdiction the vertical sells into. **Confidence: medium-high on
the 9(2)(b) conclusion, since it is textual inference; no authority squarely on point was
found.**

**Design consequence.** The roster ingestion pipe needs A-4-equivalent enforcement, and
it needs the *preventive* limb of the EDPB 8/2020 test, not just the *non-inference*
limb: an allow-list of ingestible roster fields, rejection (not silent dropping) of
anything outside it, no free-text field of any kind, and no derivation of shift-pattern
regularities. Pattern derivation over shift times is the specific thing that converts
lawful roster data into religious-belief inference.

---

## 2. Controller allocation pre-claim

### 2.1 The hypothesis, tested

> *Grain is a processor acting for the employer until the worker claims the record, and
> becomes an independent controller at the moment of claim.*

**It does not survive. Confidence: high.**

**(a) Grain determines the essential means, all four of them.** EDPB Guidelines 07/2020
(v2.1, 7 July 2021) ¶40 enumerates essential means as **type of personal data, duration,
categories of recipients, and categories of data subjects**. Grain sets the schema and the
`work_kind@version` vocabulary; it sets retention; it defines who may receive a prior
packet and on what grant model; and it defines who is a subject (persons only,
decision 007). The employer supplies rows into a structure Grain authored. ¶84 permits a
processor to offer a pre-defined service, but the controller must **actively approve the
essential means**, and the employer does not: it cannot change the schema, the
vocabulary, the retention, or the disclosure model.

The **accountant** worked example at ¶39–41 is the closest fit in the guidance: the
accountant is a controller in its own right precisely because it decides what data, which
categories of persons, retention, and technical means.

**(b) The processing is the core service, not incidental to it.** ¶82: where the service
"is not specifically targeted at processing personal data or where such processing does
not constitute a key element of the service," the provider may be a **separate
controller**. Grain's service *is* the processing of personal data about workers. There
is nothing else in the box.

**(c) Grain's purpose differs from the employer's from the first row, and Grain has said
so in writing.** THESIS §1: "Grain is the record that travels." §2: "the union of what
many independent parties attested about one person, across a working life, accumulating."
§3: analytics "sold to partners." The employer's purpose is workforce administration in
its own business. Grain's purpose is a cross-employer asset and a product sold to third
parties. Art. 28(10) is the provision: a processor that determines its own purposes and
means "shall be considered to be a controller in respect of that processing." EDPB ¶81
illustrates it with the **MarketinZ** example, a processor reusing a client's customer
database for its own business development becomes a controller and infringes. **That is
Grain's fact pattern with the nouns changed.**

**(d) Intended durability past the employment relationship is dispositive on its own.** A
processor's authority is bounded by the controller's instructions and ends with the
engagement. Data designed from the outset to outlive the relationship and travel to the
controller's *competitors* cannot be held on the controller's instructions, because the
controller has no authority to instruct that and no interest in it. This is my inference,
but it is a short one.

**(e) The label is irrelevant.** ¶12: the concepts are functional and allocation "is not
negotiable." ¶29: "**If one party in fact decides why and how personal data are processed
that party will be a controller even if a contract says that it is a processor.**"
*C-683/21* ¶34: even being *named* as controller in a privacy policy matters only if the
entity consented to the designation: labels create nothing in either direction.

**(f) The "becomes a controller at claim" half is backwards.** Grain's controllership
begins at ingestion. The claim event does not change role; it changes which lawful bases
become available for the *worker-facing* service (a contract with the worker appears, and
Art. 6(1)(b) becomes usable for the profile the worker asked for). Framing the claim as
the controllership trigger would leave the highest-risk period, the period when the
person does not know and cannot object, as the one Grain disclaims responsibility for.
A regulator will read that as designed avoidance, and *Wirtschaftsakademie* ¶41–42 and
*Fashion ID* ¶83 both hold responsibility is **greater**, not lesser, where the affected
people are non-users.

### 2.2 The fallback allocation

**Stage-specific, per *Fashion ID* ¶74 and EDPB ¶57.**

| Stage | Allocation | Basis |
|---|---|---|
| Employer's internal HR/roster processing | Employer sole controller | Its own workforce administration |
| Transmission to Grain; identity matching; creation of the attestation record | **Joint controllers (employer + Grain)** | Converging decisions, each necessary, inextricably linked: EDPB ¶54–55; *C-683/21* ¶43 |
| Holding the unclaimed record; notice; rights handling | **Grain sole controller** | Grain alone determines duration, recipients, schema |
| Disclosure to any other employer | **Grain sole controller** | Employer has no say and no interest |
| Analytics computed on the record | **Grain sole controller** (provider under the AI Act) | Grain's own product purpose |
| Post-claim worker profile and grants | **Grain sole controller** | Plus a contract with the worker |

*Fashion ID* ¶76 is the model: the website operator was joint controller for **collection
and disclosure by transmission** only, and it was "impossible" that it determined the
purposes of Facebook's subsequent processing. Here the employer is joint controller for
supply and record creation and nothing after.

**Joint controllership exists whether or not anyone papers it.** *C-683/21* ¶44–45: no
formal arrangement is required for joint controllership to arise; the Art. 26(1)
arrangement is "not a precondition" but an **obligation arising once** the parties are so
classified. Ship without one and you are in breach from row one. ¶81 sets a low bar for
the fault element in Art. 83: a controller can be penalised where it "could not have been
unaware of the infringing nature of its conduct", which, once this memo exists in the
repo, Grain cannot be.

### 2.3 What each allocation requires, concretely

**Contractual (joint-controller layer, employer ↔ Grain).** An Art. 26(1) arrangement,
not a DPA. It must allocate, per EDPB ¶164–166 and ¶179–181: who answers Arts. 15–22
requests and within what internal SLA; who delivers the Art. 14 notice, when, and how
delivery is evidenced; who is the single **point of contact** (¶179); and the essence
made available to data subjects must cover "**at least all Art. 13/14 information
elements, saying for each which joint controller is responsible**" (¶180). It must state
that Art. 26(3) applies: the data subject may exercise rights against **each** controller
regardless of the allocation, and is not bound by it (¶186–191). Grain cannot contract
out of receiving requests.

Alongside it: employer warranties on the lawfulness of the supply (worthless as a defence
per *HUBSIDE.STORE* ¶45, but necessary for indemnity); a field allow-list annexed and
technically enforced; a contractual prohibition on supplying any worker without a
deliverable contact channel; an obligation to name Grain in the employer's own staff
privacy notice (necessary but not sufficient; see §3.3); an obligation to inform workers'
representatives where required by AI Act Art. 26(7) and by national works-council law;
and a suppression obligation: the employer must not re-supply a worker who has objected.

**Technical.** Pre-claim records in a physically separable partition with no read path to
any employer surface, any analytics job, or any aggregate. Grain's existing architecture
helps here: `plans/foundation/06-checks-port.md` already carries a mechanical ban on
capability-score columns in fact tables; the same class of check should mechanically
prohibit any join from an analytics or packet-read path to the unclaimed partition. A
per-record `claim_state` that is a hard gate at the query layer, not an application-level
filter. Notice-dispatch proof stored per record as a first-class field, not a log line,
because Art. 5(2) puts the burden of demonstration on Grain.

**Confidence: high on the sole-controllership conclusion; medium-high on joint
controllership at ingestion.** The latter turns on how much the employer specifies about
what is recorded. If the employer merely dumps a roster into Grain's fixed pipeline with
no discretion, an argument exists that they are **successive independent controllers**
(EDPB ¶68–72) rather than joint. That would be *worse* for Grain, not better, since it would
mean Grain alone owns every duty from ingestion, with no shared notice mechanism. Either
way the processor framing is gone.

---

## 3. Notice under Article 14

### 3.1 What must be provided

Art. 14(1): identity and contact details of the controller (and its representative);
DPO contact; **purposes**; **legal basis**; **categories of personal data**; recipients or
categories of recipients. Art. 14(2): **retention period or the criteria for it**; where
the basis is Art. 6(1)(f), **the legitimate interests pursued**; and per EDPB Guidelines
1/2024 ¶67 the specific interest must be "precisely identified and communicated," not
gestured at; the existence of the rights of access, rectification, erasure, restriction,
objection and portability; the right to lodge a complaint with a supervisory authority;
**the source from which the data originate** (Art. 14(2)(f)); and the existence of
automated decision-making including profiling, with meaningful information about the logic
and consequences (Art. 14(2)(g)).

EDPB ¶68 adds that the information should make clear the data subject can obtain
**information on the balancing test** on request.

Art. 14(2)(f), the source, is the one an aggregator habitually gets wrong. WP260 ¶60: the
exemption for source information applies only where different pieces of data cannot be
attributed to a particular source, and "the mere fact that a database... has been compiled
using more than one source is **not enough** to lift this requirement"; transparency
mechanisms "should be built into processing systems from the ground up so that all
sources... can be tracked and traced back to their source at any point." CNIL in *KASPR*
¶105 held that access responses citing only "public sources" were inadequate and sources
must be "as precise as possible." For Grain the source is a **named employer**, which
means the notice necessarily discloses to the worker that a specific named employer put
them into Grain. That is a product fact, not just a legal one.

### 3.2 Timing

Art. 14(3) sets three deadlines and the earliest governs:
- **(a)** within a reasonable period after obtaining, and **at the latest one month**;
- **(b)** if the data are used to communicate with the data subject, **at the latest at
  the time of the first communication**;
- **(c)** if disclosure to another recipient is envisaged, **at the latest when the data
  are first disclosed**.

**14(3)(c) is the one that binds Grain hardest.** The first time an unclaimed record is
made visible to any employer other than the source, notice is already owed and overdue if
not given. Under the narrow design in §1.4 no such disclosure occurs pre-claim, which
removes the tripwire, another reason that design is the only sustainable one.

*HUBSIDE.STORE* ¶96 applied the equivalent point to first contact by phone: the obligation
arises **at first contact**, and ¶113 characterised the failure as "**structural**":
none of dozens of recorded calls complied. Structural failures attract structural
remedies.

### 3.3 Does the employer's own privacy notice discharge Grain's duty?

**No. Confidence: high on the principle.**

Each controller owes its own Art. 13/14 duty. A generic HR clause, such as "we may share your
data with third-party service providers", supplies none of the Art. 14 content: it does
not name Grain, state Grain's purposes, state Grain's legal basis or the specific
legitimate interest, state Grain's retention, or explain the Art. 21(1) objection right
against Grain. `[ref-level: Garante, Limit Call, doc. web 9971433, cited for the
proposition that the source's notice does not discharge the recipient controller's
duty; verify before relying.]` The reasoning is independently available from
*HUBSIDE.STORE* ¶71–77, where legitimate interests failed **because the company's name was
absent from the partner lists supplied at collection**: an unnamed downstream recipient
is precisely the situation the employer's notice creates.

`[ref-level: DPC WhatsApp, IN-18-12-2, with EDPB Binding Decision 1/2021, cited for the
proposition that pseudonymisation of non-user data does not switch off the transparency
duty. If that is the holding, it forecloses the obvious architectural dodge of hashing
the non-user identifiers and claiming Art. 11. Verify.]` Independently: Art. 11 only
relieves a controller that cannot identify the subject, and Grain's whole purpose is to
be able to match this person when they arrive. `research/12` conclusion 2 already settled
the equivalent point internally: a retained hash whose function is to single out one
human is personal data in Grain's hands, and *EDPS v SRB* (C-413/23 P) does not help the
party that deliberately retains the matching capability.

**What the employer's notice must nonetheless do.** Name Grain, state the transfer, and
link to Grain's own notice. It is a necessary condition of the LI balancing (per
*HUBSIDE.STORE*) even though it is not sufficient for Art. 14.

### 3.4 Is Art. 14(5)(b) available? No.

Three independent reasons, in descending order of strength.

**(i) The exception is characterised by its archiving/research context.** WP260 ¶61:
given the emphasis in Recital 62 and Art. 14(5)(b) on archiving, research and statistics,
"this exception **should not be routinely relied upon by data controllers who are not
processing personal data for those purposes**." The Polish **NSA in III OSK 2538/21**
(19 September 2023) reached the same conclusion independently and more forcefully: the
listed purposes are all processing "w celach ogólnych, w interesie publicznym," so the
exemption "**does not cover activity consisting in data processing which does not realise
a public interest**." Grain's purpose is a commercial product.

**(ii) Cost and scale are irrelevant: the anti-paradox holding.** NSA, same judgment:
"**For the application of the exception in Art. 14(5)(b), the scale as such and the costs
of performing the information obligation are irrelevant. Otherwise this would lead to a
peculiar paradox: an entity processing personal data on a large scale could rely on the
exception and not perform the information obligation, thereby freeing itself of the
associated costs, whereas an entity doing so on a small scale would have to perform it
and bear those costs in full.**" This is the strongest European authority that a
commercial aggregator holding records on non-customers cannot buy its way out of Art. 14
by pleading delivery costs.

The underlying UODO decision (**ZSPR.421.3.2018**, March 2019, **PLN 943,470**, Bisnode
Polska) held that publishing a privacy clause on a website "cannot be regarded as
sufficient" where the controller holds address data enabling post or telephone, and that
posting a letter "is not an 'impossible' act and does not require 'disproportionate
effort'" where the address is already held. Two corrections to the received version of
this case, from the court records: UODO's *legal* line was **sole traders vs. company
officers** (public registers hold no contact details for the latter), not email-known vs
postal-only; and the **WSA annulled the fine in its entirety** (II SA/Wa 1030/19,
11 December 2019, point 2), an annulment that became final because UODO did not
cross-appeal. **The fine was not upheld. The interpretation was.** Cite the doctrine, not
the penalty.

**(iii) Grain will hold a deliverable channel.** *KASPR* ¶81: the company was "capable of
informing persons from deployment" because it **possessed email addresses**. Grain's
premise is that the employer supplies phone and possibly email. `[ref-level: Datatilsynet,
SSI, 2021-432-0070, cited for the proposition that active individual contact is required
where the controller holds a channel. Verify.]`

WP260 ¶62 also requires that any impossibility be "**directly connected to the fact that
the personal data was obtained other than from the data subject**." A shortfall Grain
could have prevented by requiring a channel at ingestion is not so connected.

**And even if it were available, it does not remove the duty.** Art. 14(5)(b) requires
the controller to "take appropriate measures to protect the data subject's rights,
freedoms and legitimate interests," and WP260 ¶64 states that one measure controllers
"must **always** take is to make the information publicly available," alongside a
documented balancing exercise, and possibly a DPIA, pseudonymisation, minimised data and
storage period. So the ceiling of the exception is "publish a notice and document why you
did not send one", which is precisely the posture UODO fined and NSA condemned.

**Confidence: high.**

### 3.5 The compliant design: what a claim invitation must be

**Yes, an actively delivered claim invitation can discharge Art. 14, and it is the only
mechanism that plausibly can. Confidence: medium-high** (the principle is sound; no
authority blesses this specific artifact).

Conditions, all of them:

1. **Actively delivered to the individual**, by email or SMS, to the channel the employer
   supplied. Not a poster in a break room, not a page on grain's website, not a line in
   the employer's handbook. Passive availability is what UODO fined.
2. **Delivered within one month of ingestion**, and before any disclosure of any kind
   (Art. 14(3)(a) and (c)). Under the §1.4 design there is no pre-claim disclosure, so
   (a) governs.
3. **Carries the complete Art. 14(1)–(2) set**; see §3.1. Not a link to a notice: the
   substance may be layered, but the first layer must state, in plain language, at
   minimum: who Grain is; that Grain holds a record of the person's employment; **which
   named employer supplied it**; what the record contains; that the legal basis is
   legitimate interests and what that interest specifically is; how long it will be kept
   and that it will be **automatically deleted** if unclaimed; that the person may object,
   access, correct or erase **without creating an account**; and the right to complain to
   their national supervisory authority.
4. **Every right is exercisable from inside the message**, by a one-click link that does
   not require signup. An "object and delete" link that works in one action is the single
   highest-value control in the design, since it converts Art. 21(1) from a legal liability into
   an implemented feature, and it is exactly the kind of above-baseline measure EDPB
   Guidelines 1/2024 ¶34 and ¶57 recognise as a genuine mitigating measure (¶57 names
   "allowing the data subject to exercise the right to object without any of the
   limitations in Article 21" as an example).
5. **In the language of the worker's country.** *KASPR* ¶88: CNIL rejected the argument
   that EU professionals universally understand English, and fined English-only notice
   under Art. 12. In hospitality this is not a marginal point, since the workforce is
   multilingual by construction and English-only notice will fail.
6. **Delivery is evidenced per record**, stored as a field, because Art. 5(2) puts the
   burden on Grain.

**Who sends it.** The duty is Grain's and is non-delegable, but the *channel* may be the
employer, and there are two reasons to use the employer as messenger. First, deliverability
and trust: a message from the worker's own employer is opened; a cold SMS from an unknown
company is not. Second, and more important, the **ePrivacy/PECR trap**: a "claim your
record, sign up here" message sent by Grain to an individual subscriber who has no
relationship with Grain is arguably unsolicited direct marketing by electronic mail,
requiring consent under UK PECR reg. 22 and the national implementations of ePrivacy
Art. 13, with the soft opt-in unavailable because there was no prior sale. **Separate the
two artifacts**: an Art. 14 legal notice, containing no promotional content and no signup
CTA, sent as a legal notification; and, distinctly, an invitation from the employer to
its own staff, which is a communication inside an existing relationship. **Confidence:
medium-high on the PECR risk; this is my analysis, not something a regulator has decided
on these facts, and it is the kind of point that gets discovered by a complaint rather
than by review.**

### 3.6 Workers with no deliverable contact channel

**Do not ingest them. Confidence: medium-high.**

If the employer supplies a name and dates but no email or phone, Grain has a record it
cannot lawfully notify, held under a basis whose balancing already assumed notice. The
Art. 14(5)(b) route is closed by §3.4(iii) and WP260 ¶62. The alternatives, hold it
silently, or hold it and publish a website notice, are the exact conduct UODO fined and
the NSA condemned.

The design rule is a **hard ingestion precondition**: a roster row without a validated
deliverable channel is rejected at the boundary with a typed error to the employer, not
accepted-and-flagged. This has to be a rejection rather than a warning, because a
warning becomes a backlog and a backlog becomes a silent population. Grain's existing
ingestion discipline (A-4 sensitive-data enforcement at ingestion) is the pattern to
copy.

Where the employer wants those workers in, the answer is the ordinary decision-028 flow:
the employer invites, the worker signs up, the employer attests. That flow already exists
and is already ruled.

---

## 4. Rights of an unclaimed subject

All of Arts. 15–22 are live from ingestion. Not knowing a controller exists suspends
nothing.

**Art. 15 access.** Must return the record, the purposes, the categories, the recipients,
the retention period, the rights, **the source** (Art. 15(1)(g)) and the existence of
automated decision-making with meaningful information about the logic (Art. 15(1)(h)).
*KASPR* ¶105: sources must be identified "as precise as possible", for Grain, the named
employer, the ingestion timestamp, and the specific field set supplied. *Criteo*
(SAN-2023-009, 15 June 2023, EUR 40,000,000) ¶106–121 found an Art. 15 breach for
withholding internal matching tables from access responses; the read-across is that
Grain's identity-matching artifacts (name index tokens, match confidence, alias closure)
are within scope of an access request, not internal plumbing outside it. **Confidence:
medium-high.**

**Art. 16 rectification.** Applies fully, and decision 028's "partners write freely, no
worker countersign" creates the exposure: a non-user has no notice, no countersign, and
no dispute surface. `research/01` §2.2 already ruled that "frozen once verified" is not
sustainable for verified-but-wrong data, because Art. 16's supplementary-statement
language covers *incompleteness* only while its first sentence and Art. 5(1)(d) require
actual rectification of inaccuracy. For an unclaimed record the position is worse: there
is nobody to annotate. **The dispute path must be reachable from the claim invitation
itself, pre-account.**

**Art. 17 erasure.** 17(1)(a) is made out on its face for a never-claimed record once the
retention period runs. 17(1)(c) is made out on any successful Art. 21(1) objection. Note
`research/12` conclusion 1: Art. 17(3) is a closed list of five with no fraud carve-out,
and "we used legitimate interests" is not an exemption from Art. 17. Nothing here
qualifies for 17(3)(e) (legal claims) absent a live or reasonably anticipated dispute
about this specific worker.

**Art. 21(1) objection: the load-bearing one.** Available precisely because the basis is
Art. 6(1)(f). On objection, processing must stop unless Grain "demonstrates compelling
legitimate grounds which override the interests, rights and freedoms of the data
subject." That is a **higher** bar than the Art. 6(1)(f) balancing Grain has already
struggled to win. Against a person with no relationship to Grain, objecting to a
commercial third party holding their employment history, the grounds available are the
grounds that lost the first balancing. **My conclusion: an unclaimed-subject objection
should be treated in the product as automatically successful.** Fighting it costs more
than the record is worth and generates the complaint that becomes the enforcement action.
**Confidence: high.**

**Art. 22 / UK Arts. 22A–22D.** Not engaged pre-claim under the §1.4 design (no analytics
input). Engaged the moment an unclaimed record feeds a score. `research/01` conclusion 7
and *SCHUFA* (C-634/21) already establish that the scoring entity, not only the
decision-maker, bears the Art. 22 obligations where the recipient draws strongly on the
score.

**Art. 20 portability.** Does not apply where the basis is Art. 6(1)(f); `research/01`
§2.4 already settled this. Irrelevant pre-claim.

### 4.1 What Grain must build

1. **A public, unauthenticated rights portal** reachable without an account, linked from
   every claim invitation and from the site footer. This is not a nice-to-have: requiring
   signup to exercise a right is the defect the Greek HDPA characterised as transferring
   the compliance burden onto the data subject.
2. **`source` as a mandatory, non-null field on every ingested record**: attesting party
   id, ingestion timestamp, field set, and the employer's own reference. Retrofitting
   source lineage after the fact is what WP260 ¶60 says must be built "from the ground
   up."
3. **A one-click object-and-erase path** that executes Grain's existing deletion saga
   (decision 017: DEK shred, salt destruction, `PayloadPurged` event) on a single record
   rather than a whole profile. The machinery exists; the granularity does not.
4. **A suppression decision that is itself ruled.** If Grain retains anything to stop the
   employer re-supplying an objecting worker on the next sync, that retained thing is
   personal data in Grain's hands (`research/12` conclusion 2). The cleaner design pushes
   suppression to the employer contractually: the employer maintains the exclusion list,
   because the employer already lawfully holds the identifiers. **Confidence: medium-high
   that this is the right split; it has not been ruled internally.**
5. **A dispute intake that works pre-account**, per decision 028's authenticity-only
   adjudication rule.

### 4.2 Identity verification with no account

Art. 12(6) permits requesting additional information only "where the controller has
reasonable doubts concerning the identity of the natural person making the request."
Recital 64 requires reasonable measures to verify, and EDPB Guidelines 01/2022 on the
right of access are explicit that verification must not become a pretext for collecting
excessive data. `[ref-level for the specific paragraph numbers in 01/2022; the principle
is safe from Art. 5(1)(c) and Recital 64.]`

**The correct mechanism is control of the identifier already in the record.** If the
record contains a phone number, an OTP to that number is proportionate, sufficient, and
collects nothing new. If it contains an email, a signed one-time link. This is exactly
proportionate because the identifier is the record's own key: proving control of it proves
as much as the record itself asserts.

**What Grain must not do:** demand a government ID document (collecting Art. 9-adjacent
and A-4-banned data to answer a request about a name and some dates fails Art. 5(1)(c) on
its face, and would breach Grain's own sensitive-data ban); require account creation;
require the requester to route through their employer.

**Edge case worth ruling now.** A requester who says "I think you hold a record about me"
but whose supplied identifier does not match. Grain cannot confirm or deny without
risking disclosure to an impostor, and cannot refuse without risking an Art. 12(2)
breach. `research/11` already establishes phone and email are weak anchors. The
defensible answer is a neutral response that does not confirm existence, plus a documented
policy, and Art. 11(2) is the textual hook where Grain genuinely cannot identify the
person from the information supplied. **Confidence: medium. This is genuinely unsettled
and deserves a counsel view.**

---

## 5. Retention of never-claimed records

### 5.1 The law

Art. 5(1)(e): personal data must be kept "no longer than is necessary for the purposes
for which [they] are processed." `research/01` §2.2 already recorded the internal
position: "forever, because a work ledger is more valuable the longer it runs" is a
business rationale, not a necessity argument. For an *unclaimed* record the argument is
weaker still, because the purpose, enabling a claim, is one the subject has not
engaged with and may never engage with.

**CNIL has decided the exact point.** In *KASPR* the retention period auto-renewed each
time a target's contact data was updated (e.g. on a job change). CNIL found this
"dynamic" renewal disproportionate **specifically because the target persons have no
active relationship with the controller and cannot determine when they become
"inactive"**, producing indefinite retention with no meaningful exit. It enjoined a cap
of five years with **no automatic extension**, on penalty of EUR 10,000 per day.

Two features of that reasoning transfer exactly. First, **the clock cannot run from "last
activity"** where the subject has no activity, which forecloses the natural design
("keep it until 24 months of inactivity"), because an unclaimed record is inactive from
birth. Second, **an employer re-sync must not restart the clock**, because that is the
dynamic renewal CNIL condemned.

The recruitment analogue points the same way and shorter. `[ref-level: CNIL guidance on
retention of unsuccessful applicants' files, commonly cited as two years from the last
contact with the candidate; ICO and German DSK guidance to similar effect, with shorter
periods where no consent to a talent pool exists. Verify the exact periods before citing;
I hold this at general-knowledge level, medium confidence.]` The direction of travel is
that even a *candidate who applied*, someone with more relationship to the controller
than Grain's non-user has, gets a short, fixed, non-renewing period.

**Is there authority on holding data pending a possible future relationship?** Directly,
no, and that is why *KASPR* is the closest thing and why this is the weakest-evidenced
section of the memo. The nearest structural precedent is **LOPDGDD Art. 20** (Spain,
*sistemas de información crediticia*), which is worth studying because it is a legislature
answering Grain's exact question: what conditions attach when an entity holds records
about people who are not its users, supplied by third parties. Spain's answer is
individual notification; the entry **blocked for thirty days** after notification so the
subject can exercise Arts. 15–22 rights **before** the record does any damage; a
**five-year** retention cap; query restricted to entities with a contractual relationship
or a financing request; and **joint controllership** between system operator and data
supplier under Art. 26. `[Obtained via summarisation; verify wording before quoting.]`
Every one of those five features maps onto a design constraint in §8 below. The thirty-day
blocking window in particular is a better answer than anything Grain has designed, and it
is available off the shelf.

### 5.2 The concrete rule

Stated so it can be implemented and tested. EDPB Guidelines 4/2019 on Art. 25 data
protection by design and by default requires deletion to be a built-in, verifiable
capability rather than a policy. `[ref-level for the specific paragraph; the substance of
Art. 25(1)–(2) is safe.]`

```
UNCLAIMED RECORD RETENTION RULE

R1. ttl_expires_at = ingested_at + 365 days.
    Set once, at write. Column is write-once (Grain's existing write-once
    column pattern with transition tables).

R2. The clock NEVER restarts. Not on employer re-sync, not on roster
    refresh, not on a corrected field, not on a failed notice delivery,
    not on a partial match to an existing profile.
    An employer re-supplying the same person is a no-op against ttl.

R3. A re-supply after expiry is a NEW ingestion: new record, new ttl,
    and a NEW Art. 14 notice is owed and dispatched. The notice cost is
    the deliberate friction that stops re-supply becoming renewal.

R4. Notice must be dispatched within 30 days of ingested_at. If
    notice_dispatched_at is null at ingested_at + 30 days, the record is
    deleted immediately, not flagged, not queued for review. A record
    that cannot be notified cannot be lawfully held (§3.6).

R5. At ttl_expires_at, automatic hard delete via the existing deletion
    saga: payload destroyed, per-person key destroyed, per-record salt
    destroyed, PayloadPurged event emitted. No grace period, no
    soft-delete, no archive copy, no analytics-side residue.

R6. Claim converts the record: claim_state -> claimed, ttl_expires_at
    -> null, lawful basis moves to the worker-facing basis, and the
    record enters the ordinary lifecycle. Claim is the ONLY thing that
    clears the ttl.

R7. Objection under Art. 21(1) deletes immediately, ahead of ttl, on the
    same path (§4).

TESTS THAT MUST EXIST AND RUN IN CI

T1. Property test: for every unclaimed record, ttl_expires_at ==
    ingested_at + 365d. No exceptions, no config override.
T2. Time-travel test: advance the clock past ttl; assert payload row
    gone, key destroyed, salt destroyed, PayloadPurged emitted, and
    no readable trace in any derived table, cache or index.
T3. Adversarial re-sync test: re-supply an unclaimed person daily for
    400 simulated days; assert deletion still occurs on day 365 of the
    ORIGINAL ingestion.
T4. Notice-gate test: ingest without dispatching notice; assert deletion
    at day 30.
T5. Isolation test: assert no query path from any employer-facing read,
    any packet generation, any analytics job, or any aggregate reaches
    a record with claim_state = unclaimed. This is a mechanical check
    in the same class as the existing capability-score column ban.
T6. Deletion-completeness test reusing the decision-017 evidence set.
```

**Why 365 days rather than 5 (KASPR's cap) or 2 (recruitment practice).** The purpose
here is narrower than KASPR's: enabling a specific person to claim a specific record,
not maintaining a commercial contact database, and a narrower purpose supports a shorter
period, not a longer one. Hospitality tenure is short and turnover is high; a worker who
has not claimed within a year of being told about it has effectively declined. A shorter
period is also the strongest single mitigating measure available in the Art. 6(1)(f)
balancing, and under EDPB Guidelines 1/2024 ¶34/¶57 it only counts as a mitigating
measure because it goes beyond what the GDPR minimally demands.

**Confidence: high** that indefinite retention is unlawful and that the clock cannot run
from inactivity or restart on re-sync. **Medium** on 365 days specifically, since it is a
judgment call within a defensible range, and counsel may prefer to align to the shortest
national recruitment-retention guidance across Grain's target markets. What would raise
confidence: a DPA decision on retention of pre-registration or invitation records, which
I could not find.

---

## 6. UK divergence

The UK is **more permissive on notice, on access and on automated decisions**, **identical
on lawful basis for Grain's purposes**, and **materially more dangerous on
employment-agency law**. Commencement for the provisions that matter: **5 February 2026**,
verified against the Data (Use and Access) Act 2025 (Commencement No. 6 and Transitional
and Saving Provisions) Regulations 2026, **SI 2026/82**, reg. 2 (made 29 January 2026),
which brings ss. 70, 71, 76, 77, 80 and Schedules 4, 5, 6 into force.
https://www.legislation.gov.uk/uksi/2026/82/made

### 6.1 Recognised legitimate interests: Grain gets nothing

DUAA s. 70(2)(b) inserts Art. 6(1)(ea); s. 70(4) inserts Art. 6(5), which says processing
is necessary for a recognised legitimate interest "**only if it meets a condition in
Annex 1**." Schedule 4 inserts Annex 1, and its five conditions are: disclosure in
response to a public-task request (¶1); national security, public security, defence (¶2);
emergencies (¶3–4); crime (¶5); safeguarding vulnerable individuals (¶6–8).
https://www.legislation.gov.uk/ukpga/2025/18/schedule/4/enacted

Nothing commercial, and nothing commercial can be added: new Art. 6(9) restricts the
Secretary of State's power to cases "necessary to safeguard an objective listed in
Article 23(1)(c) to (j)."

What Grain does gain is **new Art. 6(11)**, a non-exhaustive list of examples of *ordinary*
Art. 6(1)(f) interests: direct marketing; **intra-group transmission** "(whether relating
to clients, employees or other individuals)... necessary for internal administrative
purposes"; and network and information system security. **Note the trap**: Grain's
employer customers are not a group of undertakings, so the intra-group example does not
reach employer-to-Grain transfer. Grain is on the full ordinary balancing test, which is
the same test it fails in §1.3.

ICO guidance published 23 March 2026 confirms the closed-list reading ("you can only use
this basis for the pre-approved purposes listed in its five conditions") and adds an
operational reading of Art. 22B(4): "**You can't use recognised legitimate interest as
your lawful basis if you want to make significant decisions about someone based solely on
automated processing.**"
https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/lawful-basis/a-guide-to-lawful-basis/recognised-legitimate-interest/

### 6.2 Purpose limitation, and a new problem for the employer

DUAA s. 71 rewrites Art. 5(1)(b), deletes old Art. 6(4) and inserts Art. 8A. New Art. 5(3)
decouples compatibility from lawfulness: "processing is not lawful by virtue only of
being processing in a manner that is compatible with the purposes for which the personal
data was collected." Schedule 5 inserts Annex 2, twelve paragraphs, **again nothing
commercial**. https://www.legislation.gov.uk/ukpga/2025/18/schedule/5/enacted

**This lands on the employer, not on Grain, and it is the sharper UK point.** An employer
that collected roster data to run payroll and rotas and then ships it to Grain for
attestation and scoring is doing further processing for a new purpose with **no Annex 2
condition available**. It falls back to the Art. 8A(2) multi-factor test, where
Art. 8A(2)(b), which reads "the context in which the personal data was collected, including the
relationship between the data subject and the controller", is the employment
power-imbalance context. And Art. 8A(4) is worse: where the employer collected on the
basis of consent, further processing is compatible only in narrow cases or where "the
controller cannot reasonably be expected to obtain the data subject's consent", which,
for an employer that sees its own staff daily, is not arguable.

**Confidence: high on the text; medium-high that this is the practical blocker on the UK
employer side.**

### 6.3 Notice: the one real liberalisation, and it is significant

**DUAA s. 77 is the most important UK divergence for this mechanic and it was not on the
original question list.** It **deletes old Art. 14(5)(b)** and inserts:
- new **Art. 14(5)(e)**: the duties do not apply to the extent that "providing the
  information is impossible or would involve a **disproportionate effort**";
- new **Art. 14(5)(f)**: where notification "is likely to render impossible or seriously
  impair the achievement of the objectives of the processing";
- new **Art. 14(6)**: disproportionate effort depends on "the number of data subjects,
  the age of the personal data and any appropriate safeguards";
- new **Art. 14(7)**: a controller relying on it "**must take appropriate measures to
  protect the data subject's rights... including by making the information available
  publicly**."

https://www.legislation.gov.uk/ukpga/2025/18/section/77/enacted

**Why this matters.** The EU argument in §3.4 is built primarily on the archiving/research
framing of the current Art. 14(5)(b): WP260 ¶61 and the NSA's public-interest reading.
The UK provision is **untethered from that framing**: disproportionate effort now stands
free. The NSA's anti-paradox reasoning remains persuasive (and the ICO's own guidance has
not blessed commercial aggregation) but it is not binding in the UK and it is no longer
supported by the same statutory architecture.

**Do not overread it.** Art. 14(7) makes public notice **mandatory**, not optional, when
the exception is used. And where Grain holds a deliverable channel, the KASPR logic still
bites at the level of ordinary reasonableness, since it is hard to call an SMS to a number you
already hold a disproportionate effort. My read is that s. 77 gives the UK operation a
real fallback for the residual population, not a licence for the main flow. **Confidence:
medium-high on the reading; low-medium on how the ICO will apply it, because it is new
and untested.**

### 6.4 Access: helpful

DUAA s. 78 inserts Art. 15(1A): entitlement is limited to what the controller can provide
"based on a **reasonable and proportionate search**." Note two things the original brief
would have missed: s. 78 came into force on **Royal Assent, 19 June 2025** (s. 142(2)(b)),
and s. 78(5) **deems it in force from 1 January 2024**, retrospective.
https://www.legislation.gov.uk/ukpga/2025/18/section/78/enacted

DUAA s. 76 inserts Art. 12A: one month from the **latest** of receipt of the request,
receipt of identity-verification information, or payment of any fee; two-month extension
for complexity on notice; and Art. 12A(5) **stop-the-clock** where the controller
"reasonably requires further information in order to identify the information or
processing activities to which a request under Article 15 relates." New Art. 12(6)(b)
permits delaying "until the identity is confirmed." Saving: s. 76 does not apply to
requests received before 5 February 2026 (SI 2026/82 reg. 4).
https://www.legislation.gov.uk/ukpga/2025/18/section/76/enacted

For a non-user DSAR this is genuinely useful: the clock does not start until identity is
verified.

### 6.5 Automated decisions: Arts. 22A–22D, in force 5 February 2026

DUAA s. 80. https://www.legislation.gov.uk/ukpga/2025/18/section/80/enacted

- **Art. 22A(1)**: a decision is based solely on automated processing "if there is **no
  meaningful human involvement**"; a decision is significant if it "produces a legal
  effect... or has a similarly significant effect."
- **Art. 22A(2)**: in assessing meaningful human involvement "a person must consider,
  among other things, the extent to which the decision is reached by means of
  **profiling**."
- **Art. 22B(1)**: the restriction now applies only to significant decisions "based
  entirely or partly on processing described in **Article 9(1)**", meaning special category data,
  with conditions of explicit consent (22B(2)) or contract/law plus Art. 9(2)(g)
  (22B(3)).
- **Art. 22B(4)**: a significant decision may not be taken solely automatically where the
  processing relies on Art. 6(1)(ea).
- **Art. 22C**: safeguards required for **any** solely automated significant decision:
  information about the decision, the ability to make representations, human intervention,
  and the ability to contest.

**What changed.** The old Art. 22 prohibited solely automated significant decisions
subject to three gateways. The new regime **inverts the default**: such decisions are now
permitted on any lawful basis with Art. 22C safeguards, and the old-style restriction
survives only for Art. 9(1) data. For a non-special-category capability score this is a
substantial liberalisation relative to the EU position under *SCHUFA*.

**Two things that pull the other way.** Art. 22A(2) makes profiling-heavy decisions harder
to characterise as human-involved, which is the whole of Grain's analytics product. And
§1.5 above concludes that roster-derived records realistically carry Art. 9(1) inference
risk; if they do, Art. 22B applies after all and the liberalisation evaporates.

**A live gap to plan around: the ICO's updated ADM guidance is still in draft.** The
consultation closed 29 May 2026 and final guidance had not published as of August 2026.
https://ico.org.uk/about-the-ico/ico-and-stakeholder-consultations/2026/03/ico-consultation-on-the-draft-guidance-about-automated-decision-making-including-profiling/
Worse, the ICO's live "in brief" page on ADM rights **still describes the pre-DUAA Art. 22
regime**, listing the three old gateways as though they govern:
https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/rights-related-to-automated-decision-making-including-profiling/
**Nobody at Grain should rely on that page.** The ICO has also announced work on a
statutory code of practice on AI and ADM.

### 6.6 ICO employment guidance: hostile, and still draft

ICO recruitment and selection guidance (draft; consultation closed, final not published):
https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/employment/recruitment-and-selection/

The **vetting/verification distinction is the sharpest doctrinal threat to the employer
side of Grain's product**. Verification is "the process that employers or recruiters use
to check the information a **candidate provides** in support of their job application."
Vetting is "where employers make their own enquiries from third parties about a
candidate's background" and is "particularly intrusive and goes beyond verification."
Because Grain supplies employer-sourced records the candidate did not submit, an
employer's use of Grain sits in the **vetting** bucket, where the ICO says employers
"**should** only do pre-employment vetting where you are under a legal obligation... or
you can identify significant and particular risks," and "**should not** routinely vet all
candidates."

And directly against the network effect, in the criminal-records passage: employers
"**should** ensure that you do not share the information you obtain with other third
parties (**eg other employers**)."

The ADM-in-recruitment page requires a mandatory DPIA ("you **must** do a DPIA... as
**both activities are high risk**") and, for procured tools, "**If you cannot mitigate the
risk, you should not use the software.**"

**Confidence: medium, since the guidance is draft and the vetting/verification line may soften.
It is also the single most consequential thing to watch.**

---

## 7. Beyond the six questions

### 7.1 EU AI Act: the analytics product

Regulation (EU) 2024/1689. **Annex III point 4(b)** covers AI systems "intended to be used
to make decisions affecting terms of work-related relationships... **to allocate tasks
based on individual behaviour or personal traits or characteristics or to monitor and
evaluate the performance and behaviour of persons in such relationships**." A
capability/trajectory score sold to employers is squarely inside it, and 4(a) also
applies at hiring. Recital 57 confirms the scope reaches "persons providing services
through platforms."

**No derogation is available.** Art. 6(3)'s final subparagraph: "**Notwithstanding the
first subparagraph, an AI system referred to in Annex III shall always be considered to
be high-risk where the AI system performs profiling of natural persons.**" This confirms
THESIS §7's existing position and closes it.

**The date moved.** Annex III high-risk obligations now apply from **2 December 2027**,
per the AI Omnibus (political agreement 7 May 2026; in force 27 July 2026;
https://digital-strategy.ec.europa.eu/en/news/ai-omnibus-enters-force). That supersedes
the 2 August 2026 date and the uncertainty flagged in `research/01` §2.3. It is runway,
not relief.

**Two things that bind today, not in 2027.**
- **Art. 5(1)(f)**: inferring emotions in the workplace is prohibited, in force since
  2 February 2025, at the highest penalty tier. The Commission's Guidelines on prohibited
  practices (approved 4 February 2025) extend "workplace" to recruitment: "Using emotion
  recognition AI systems during the recruitment process is prohibited." THESIS §7 already
  has this; it needs to bind the assessment stack now.
- **Art. 4** AI literacy, in force since 2 February 2025.

**Art. 5(1)(c) social scoring: the design rule.** THESIS §7 records that portability is
what approaches this line. The Commission Guidelines give a workable answer at ¶176:
systems that score "for a specific purpose **in the related context as that in which the
personal data used for the score were collected**" are not prohibited, provided any
detrimental treatment is justified and proportionate; ¶175 names "**specific employee
evaluations**" among legitimate practices. **The rule that follows: employment data in,
employment decisions out.** The prohibition risk arrives if Grain widens either end:
ingesting social, consumer, financial or behavioural signals, or permitting the score to
be used for tenancy, credit or insurance. ¶171 puts the burden on Grain to demonstrate
"only data related to the social context in which the score is used" are processed.
¶169 adds that preferential treatment counts too, so a positives-only score is not
outside the prohibition.

**Art. 26(7) is the collision with the pre-claim mechanic.** "Before putting into service
or using a high-risk AI system at the workplace, deployers who are employers shall
**inform workers' representatives and the affected workers** that they will be subject to
the use of the high-risk AI system." An employer that syncs its roster into Grain and buys
analytics must tell its workers and their representatives. That obligation is
incompatible with a design premised on the workers not knowing. It also means the
employer's own compliance forces the notice Grain was trying to avoid, which is an
argument for building the notice properly rather than a reason to worry.

**Art. 25(1)**: Grain's customers can inadvertently become providers by white-labelling
(a), substantially modifying (b), or changing intended purpose (c). Contract for it.

### 7.2 Competition law: architectural, and cheapest to fix now

**The intermediary is expressly covered.** Horizontal Guidelines 2023/C 259/01 ¶368:
information may be exchanged "**indirectly, by or through a third party (such as a service
provider, platform, online tool or algorithm)**... This Chapter applies to direct and
indirect forms of information exchange."
https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:52023XC0721(01)

**Labour markets are in scope.** ¶279 treats coordination of purchase parameters
"including, for example, agreements to fix wages" as a by-object buyer cartel. ¶396:
unilateral disclosure suffices and can occur via "**input in a shared algorithmic tool**."
¶397 presumes the recipient takes it into account absent public distancing.

**The safe architecture is spelled out.** ¶408: participants in a data pool "should in
principle **only have access to their own information and the final, aggregated,
information of other participants**"; management can be assigned to a **trustee** subject
to strict confidentiality; and "only information that is necessary for the implementation
of the legitimate purpose of the data pool is collected."

**Enforcement is now real.** *Delivery Hero/Glovo*, AT.40795, 2 June 2025, **EUR 329
million**, the Commission's **first labour-market cartel decision**, covering no-poach,
exchange of commercially sensitive information, and market allocation, by object.
https://ec.europa.eu/commission/presscorner/detail/en/ip_25_1356 In the UK, CMA Case
50757 (21 March 2025) fined sports broadcasters **£4,240,356** over 15 instances of pay
information sharing, all by object. The CMA's *Competing for talent* guide (9 September
2025) contrasts a lawful benchmark (200 companies, anonymised, non-reverse-engineerable)
with an unlawful one turning on "the **small number of employers involved**."
https://www.gov.uk/government/publications/competing-for-talent

**Grain's exposure.** Hospitality in one city is a concentrated set of employer groups
competing for one labour pool. Grain's product is **individualised by design**, the
opposite of the ¶408 safe harbour. If an employer can see that a named worker was
employed by a named rival at a named time, that is individualised, current, confidential
information moving between competitors through a hub.

**The mitigation is one product decision, and it is the same decision §1.4 already
forces**: an employer never sees a record it did not itself supply unless **the worker**
discloses it. Worker-mediated disclosure is not a competitor-to-competitor exchange at
all. This is why the narrow design in §1.4 is not merely the compliant option. It is the
one that solves the data-protection problem and the competition problem with the same
constraint.

`[Note: AC-Treuhand (C-194/14 P) on facilitator liability and Eturas (C-74/14) on
presumed awareness of messages sent through a shared platform are directly on point for a
hub, but were cited by the research thread from background knowledge, not from the
judgments. Verify before relying.]`

### 7.3 UK Employment Agencies Act: the finding most likely to be missed

EAA 1973 **s. 13(2)**: an employment agency is the business "of providing services
(**whether by the provision of information or otherwise**) for the purpose of finding
persons employment with employers or of supplying employers with persons for employment
by them." https://www.legislation.gov.uk/ukpga/1973/35/section/13

Unlike the EU Temporary Agency Work Directive 2008/104/EC, which turns on *employing* and
*assigning* workers and therefore does **not** reach Grain (**confidence: high**), the UK
test requires only that a service be provided, by supplying information, for a
work-finding purpose. DBT/EAS guidance says the Act reaches "**online platforms**."
https://www.gov.uk/government/publications/conduct-regulations-2003-guidance-for-employment-agencies-and-employment-businesses/overview-of-the-conduct-regulations-2003

**The consequence Grain must record now, before someone proposes it.** EAA **s. 6(1)(a)**
prohibits an employment agency from requesting or receiving "any fee from any person for
providing services... for the purpose of finding him employment," and s. 6(2) makes
contravention a **criminal offence**. Grain charges employers today, so s. 6 is not
breached. But **any future worker-side monetisation, paid profile boosting, priority
visibility, featured placement, would be criminal**, and Conduct Regulations 2003 reg. 26
disapplies the prohibition only for the Schedule 3 occupations (performers and models).
**Hospitality is not in Schedule 3.** Reg. 5 separately bars making work-finding services
conditional on the worker taking other paid services, including from a connected entity.

This intersects with THESIS §8's already-recorded finding that 42 U.S.C. §2000e(c) makes a
worker-facing suggestion surface an employment agency in the US. **The same surface
triggers agency status on both sides of the Atlantic, by different routes.** That is now
two independent regimes pointing at the same unruled item, which should raise its
priority.

**Confidence: high on the statutory text; medium-high on application**, because it turns
on marketing positioning that is not yet fixed, which is exactly why it should be decided
before positioning hardens.

### 7.4 Smaller flags

- **ePrivacy / PECR on the claim invitation**; see §3.5. Separate the legal notice from
  the signup invitation.
- **EU Platform Work Directive 2024/2831**, transposition deadline 2 December 2026. Grain
  is probably not a "digital labour platform" (it does not organise or allocate work), but
  the algorithmic-management chapter, human oversight of significant decisions,
  explanation rights, limits on intrusive processing, will bind hospitality customers
  that do, and Grain's outputs will be inside their scope. **Confidence: low-medium; not
  researched in depth.**
- **Conduct Regulations reg. 19 as an opportunity.** An employment business may not supply
  a work-seeker without confirming identity and that they have "the experience, training,
  qualifications and any authorisation which the hirer considers are necessary." Grain's
  attestation product is a clean way to discharge reg. 19, good positioning, but it also
  strengthens the argument that Grain operates in the regulated space. Both at once.
- **The US comparator that does not exist in Europe.** Equifax's The Work Number: employer
  payroll feeds, ~2.5 million contributors, records on roughly a third of the US
  workforce, most of whom do not know, is the closest existing analogue to the pre-claim
  mechanic. It operates as a **regulated CRA under the FCRA**, and it has **no European
  equivalent**. That absence is a signal about what the EU regime permits, not an
  opportunity. **Confidence: medium; this is my inference from the absence.**

---

## 8. What this forces the product to do

Constraints, in order of how much they cost to retrofit.

**Architecture and schema.**

1. **A pre-claim record is a distinct object with its own lifecycle**, not an attestation
   with a null subject. `model/attestation-interface.md` (RATIFIED, decision 006) states a
   person without a ledger ID cannot be attested for. Either amend the contract by ratified
   decision or do not ship the mechanic. Silently violating a ratified interface is the
   worst of the three options.
2. **Physical isolation of the unclaimed partition.** No read path from any employer
   surface, packet generation, analytics job, aggregate, benchmark or model training set.
   Enforced mechanically, in the same class as the existing capability-score column ban,
   not by application-level filters.
3. **`source` is mandatory and non-null on every ingested record**: attesting party,
   ingestion timestamp, field set, employer reference. Retrofitting lineage is what WP260
   ¶60 says cannot be done later.
4. **A deliverable contact channel is a hard ingestion precondition.** Roster rows without
   one are rejected at the boundary with a typed error. Not warned. Not queued.
5. **A field allow-list for roster ingestion**, enforced like A-4, with no free-text field
   of any kind, and an explicit ban on deriving shift-pattern regularities. The preventive
   limb of EDPB Guidelines 8/2020 p. 33 requires measures that *prevent* inference, not
   merely abstention from looking.
6. **Retention rule R1–R7 and tests T1–T6 from §5.2**, implemented before the first EU or
   UK row is ingested.
7. **Per-record deletion granularity** on the existing decision-017 saga (DEK shred, salt
   destruction, `PayloadPurged`). The machinery exists; the granularity does not.

**Notice and rights.**

8. **Art. 14 notice dispatched within 30 days of ingestion**, actively, to the individual,
   in their language, containing the full §3.1 content set including the named source
   employer, with `notice_dispatched_at` stored as a first-class field.
9. **A public, unauthenticated rights portal**, linked from every notice. Access,
   rectification, objection, erasure: all exercisable with no account.
10. **One-click object-and-erase.** The single highest-value control in the design, and a
    genuine mitigating measure under EDPB Guidelines 1/2024 ¶57.
11. **Identity verification by OTP to the identifier already in the record.** Never a
    government ID document; never account creation.
12. **A pre-account dispute path**, consistent with decision 028's authenticity-only
    adjudication rule.
13. **Separate the Art. 14 legal notice from the signup invitation**: the PECR/ePrivacy
    split in §3.5.

**Commercial and contractual.**

14. **An Art. 26 joint-controller arrangement with every roster-supplying employer**,
    executed before the first ingestion, with the essence published per EDPB ¶180 (all
    Art. 13/14 elements, each attributed to a named controller) and a single point of
    contact.
15. **The employer must name Grain in its own staff privacy notice**: necessary for the
    LI balancing per *HUBSIDE.STORE* ¶71–77, not sufficient for Art. 14.
16. **The employer maintains the objection suppression list**, not Grain, because Grain
    retaining a suppression key is Grain retaining personal data across a deletion
    (`research/12` conclusion 2).
17. **No employer reads a record it did not supply unless the worker discloses it.** This
    is the single constraint that answers both the Art. 6(1)(f) balancing and the
    Horizontal Guidelines ¶408 data-pool problem.
18. **No worker-side fees, ever, in the UK**, and record why in the pricing roadmap: EAA
    s. 6(1)(a) makes it criminal and Conduct Regs reg. 26 offers no route for hospitality.
19. **AI Act Art. 26(7) obligation flowed down**: the employer must inform workers'
    representatives and affected workers before using the analytics.

**Positions that need re-ruling.**

20. **THESIS §7's "workers do not see when analytics are run on them" cannot survive in
    EU/UK.** For an unclaimed subject it is an Art. 14(2)(f)/(g) and Art. 15(1)(h) breach;
    for the employer it is an AI Act Art. 26(7) breach. The "deliberate cost" framing is
    a US-market framing.
21. **Decision 028's "partners write freely, no worker countersign" needs a pre-claim
    carve-out.** Free writing about a person who has notice and a dispute surface is
    defensible. Free writing about a person who has neither is not.
22. **THESIS §11's naming problem is now a legal problem.** `hiregrain.com` hosting a
    hospitality product while Grain is the identity layer means the employer's staff
    notice, the Art. 14 notice and the Art. 26 essence must all name the same legal entity
    consistently, or the transparency chain breaks at the first link.

---

## 9. Questions for counsel

Ordered by how much turns on the answer.

1. **Is the narrow pre-claim design in §1.4 defensible under Art. 6(1)(f), or is any
   pre-consent ingestion of employer roster data unlawful in the EU regardless of
   safeguards?** This determines whether the hospitality vertical has an EU/UK shape at
   all. The specific question is whether *KNLTB* ¶52–53's opt-in-defeats-necessity holding
   is confined to disclosure-for-consideration or is general. Ask for a view on at least
   France, Germany, Spain and Ireland separately: Art. 88 national employment rules and
   Art. 9(4) national conditions mean there is no single EU answer.

2. **Confirm the controller allocation and, specifically, whether the ingestion stage is
   joint controllership or successive independent controllership.** Both are worse for
   Grain than "processor," but they require different papers and different notice
   mechanics. If successive independent, Grain owns the entire Art. 14 duty alone and the
   employer-as-messenger route needs a different legal footing.

3. **Can the Art. 14 duty be discharged by an employer-delivered notice carrying Grain's
   content?** If not, Grain must send cold SMS to people who have never heard of it, which
   is both a deliverability problem and a PECR/ePrivacy problem. Ask the ePrivacy question
   in the same instruction: is a "claim your record" message direct marketing?

4. **UK: does DUAA s. 77's new Art. 14(5)(e) actually change the answer for a commercial
   aggregator holding a deliverable contact channel?** This is a new, untested provision
   and the ICO has not spoken. If it does, the UK operation can run a materially different
   notice model from the EU one, which is a real strategic asset. If it does not, do not
   let anyone believe otherwise.

5. **UK: is Grain an employment agency under EAA 1973 s. 13(2)?** Ask this before
   go-to-market positioning hardens, because the positioning determines the answer. Ask
   for the criminal-liability perimeter under s. 6(1)(a) explicitly, and pair it with the
   unruled US §2000e(c) item in THESIS §8: the same product surface triggers agency
   status in both jurisdictions by different routes.

6. **Does the roster ingestion pipe put Grain into Art. 9?** Specifically: is a
   cross-employer accumulation of absence codes and shift patterns special-category data
   under *C-184/20* ¶127, notwithstanding the ICO's "simple absence record" line? And is
   Art. 9(2)(b) genuinely unavailable to a third-party vendor? The second is textual
   inference in this memo with no authority located.

7. **What retention period would counsel defend for a never-claimed record?** §5.2 proposes
   365 days on reasoning, not authority. Ask specifically whether there is any national
   guidance on retention of pre-registration or invitation records, and whether the
   LOPDGDD Art. 20 thirty-day blocking window is worth importing voluntarily as a
   mitigating measure.

8. **Competition: does a hospitality-vertical Grain in a single city create Chapter I /
   Art. 101 exposure for Grain itself, and does worker-mediated disclosure fully cure it?**
   Ask for the hub-and-spoke analysis (*AC-Treuhand*, *Eturas*) explicitly, and ask whether
   the analytics product, even aggregated, reintroduces the problem.

9. **The identity-verification edge case in §4.1**: how should Grain respond to a rights
   request from someone whose supplied identifier does not match any record, without
   either confirming existence to a possible impostor or breaching Art. 12(2)?

10. **AI Act Art. 25(1)**: confirm the contractual language needed to stop an employer
    customer inadvertently becoming a provider by white-labelling or by retuning the
    scoring.

**Brief-integration note.** Counsel brief 1 (residency and erasure) and brief 4 (worker
agreements, drafted and unsent per THESIS §7) both need this fact pattern added before
they go out. Brief 4 in particular contemplates "no platform-derived scores to readers"
as a candidate condition; questions 1, 5 and 8 above bear directly on it. Adding the
pre-claim mechanic to an existing engagement is cheaper than a fifth brief.
