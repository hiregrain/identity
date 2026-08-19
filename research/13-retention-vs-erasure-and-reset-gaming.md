# Retention of AI-System Records Against the Erasure Right; and Reset Gaming

**Evidence tier — binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Status:** Research memo, not legal advice. Not counsel-reviewed. Written
2026-08-18. Companion to `12-deletion-vs-reputation-evasion.md` (which supplies
the erasure-law baseline this memo builds on), `08-kyc-regulatory-triggers.md`,
and `01-regulatory-perimeter.md`. Confidence is flagged inline; statutory text,
regulator guidance, court judgments, published practice, and my own inference
are labeled separately throughout.

**What this memo takes as given.** Decision `014` settled the erasure-law
groundwork and it is not re-argued here: GDPR Art. 17(3) is a closed list of
five with no fraud carve-out; Recital 47 is an Art. 6(1)(f) lawful-basis
statement, not an erasure exemption; *EDPS v SRB* (C-413/23 P) protects a
recipient who cannot re-identify, not a controller who retains the matching
capability; AEPD PS/00215/2024 (Goldcar, €80,000) is the one enforcement action
on adverse customer lists; CNIL délibération 2021-130 authorises single-
controller exclusion registers and expressly excludes mutualised ones; and
California §1798.105(d)(2), PH NPC Advisory 2021-01 §10(B)(2) and India DPDP
§17(1)(a)/(c) name fraud and physical safety while naming performance nowhere.
This memo uses those findings; it does not restate them as new.

**Two questions.** (1) What do the EU AI Act's record-keeping obligations
actually require a provider to retain, and does that obligation defeat a
worker's erasure request over a capability projection? (2) Is there any lawful
basis anywhere for retaining a link across a deletion in order to stop a worker
resetting an unfavourable *performance* assessment — and if not, what designs
reduce the gain from resetting without retaining anything?

**Jurisdictions:** EU/EEA, UK where it diverges, US federal and California,
Philippines, India.

---

## TLDR — all conclusions

**1. The AI Act requires Grain to keep a log of *runs*, never the *output*, and
never anything attributable to a person.** Art. 12(1) is a design duty ("shall
technically allow for"), not a retention duty. Art. 12(2) states three purposes
and all three are system-level: risk identification, post-market monitoring,
operational monitoring. **Art. 12(3) is the only provision in the Act that
itemises log content — including input data — and it applies only to Annex III
point 1(a) remote biometric identification. Grain is Annex III point 4, so no
minimum content is prescribed at all.** Art. 16(e) merely signposts; Art. 19 is
the sole retention duty. Confidence: high on the text; medium on durability,
because no harmonised standard specifying log content exists yet.

**2. The period is risk-based with a six-month floor, and the floor expressly
yields to data protection law.** Art. 19(1): logs kept "for a period appropriate
to the intended purpose of the high-risk AI system, of at least six months,
unless provided otherwise in the applicable Union or national law, **in
particular in Union law on the protection of personal data**." Confidence: high.

**3. That closing clause is close to fatal to the Art. 17(3)(b) argument, and
it is the finding to put in front of counsel first.** A provision that expressly
yields to the GDPR cannot be the "legal obligation which requires processing"
that displaces a GDPR right. Art. 17(3)(b) is also calibrated — "to the extent
that processing is necessary" — and Art. 6(3) requires the retaining law to
determine the purpose and be proportionate, with Recital 41 requiring it to be
clear, precise and foreseeable. *Digi* (C-77/21) holds that a secondary technical
database gets no independent retention life; *SS SIA* (C-175/20) holds that a
mandate does not displace Art. 5(1) and that the period must not exceed what is
strictly necessary. Confidence: high on the textual argument; medium-high on
outcome.

**4. So: no. Grain may not lawfully retain a readable, attributable capability
projection about a worker who has deleted their profile.** Consent fails (Art.
7(3), Art. 17(1)(b)); contract fails (Goldcar); legal claims requires a specific
claim; archiving/statistics requires Art. 89(1) minimisation and statistics do
not need a name. **This directly contradicts decision `022`'s ruling that run
records retain the *output*.** Confidence: high.

**5. There is no regulator guidance and no case law on AI Act logging versus
erasure. This is genuinely unsettled and is stated as such**, not resolved. The
Commission's own Art. 19 page carries no interpretive guidance; no harmonised
standard exists; the high-risk obligations are not yet in application. What
exists is strong text pointing one way and no adjudication. EDPB Opinion 28/2024
para. 131 adds a caution that runs Grain's way only in one direction: an AI Act
self-declaration of conformity "may not constitute a conclusive finding of
compliance under the GDPR."

**6. Pseudonymised run records work — but only if the pseudonym is not the ledger
id, which it currently would be.** Decisions `013`/`020` make a tombstoned ledger
id permanent and never reissued. That is a retained means of singling out, which
is exactly what decision `014`'s *SRB* analysis identifies as making a token
personal data. A per-run random identifier with no stored mapping works. This is
a schema decision, and it is the line between compliance and theatre. Unresolvable
input references **do** satisfy Art. 19 — the Act never requires a log to remain
resolvable — but they defeat any promise to reconstruct a decision, and that
should be said in the conformity documentation rather than discovered in an audit.

**7. There is an unresolved architectural fork that no plan or decision covers.**
Under `foundation/05`, a payload row about a person is encrypted under that
person's DEK alone. If the run record is inside that envelope it dies at deletion
and Art. 19 is breached; if it is outside, it survives readable and §4 says that
is unlawful. **The run record must be split: a spine-side non-attributable log
row that survives, a payload-side DEK-wrapped part that dies.** That also makes
run records a named input to `foundation/09`'s spine linkage threat model.

**8. On reset gaming: there is no lawful basis in any surveyed jurisdiction to
retain a link across a deletion for performance reasons, and there is now a
decided case on these facts.** AEPD **PS-00176-2024 (Iberia Cards)**, €20,000
reduced to €16,000: the controller confirmed erasure, then eleven months later
used a retained minimal link to deny a returning applicant a new-customer
promotion. The controller's defence was verbatim the "we keep only what is
necessary to tell they are not new" argument. Held: Art. 6(1) infringement. **No
fraud, no safety — pure commercial detriment applied at re-registration.**
Decision `014` was right and is now better supported than when it was made.
Confidence: high.

**9. The regime that has thought hardest about reset gaming polices the resetter
and never licenses the register to retain more.** FCRA gives no erasure right —
Congress says so in a mandated disclosure, §1679c(a) — but imposes a seven-year
obsolescence clock (§1681c(a)(5)) that expires adverse records by operation of
law. And CROA §1679b(a)(2) prohibits altering one's identification "for the
purpose of concealing adverse information that is **accurate and not obsolete**."
Congress criminalised identity-reset-to-conceal while leaving the expiry rule
intact. That is exactly the line this memo draws, drawn in 1996.

**10. Every private cross-company adverse register in existence is a fraud or
loss register, is regulated as an FCRA consumer reporting agency, and is
statutorily time-limited.** MIB, Early Warning, NCTUE, Certegy, TeleCheck. The
registers carrying judgments about how well someone did their job — NPDB, FINRA
CRD, the OIG exclusion list — are all statutory, permanent, compulsory to file
and query, and deletable only by an authority outside the operator. **Grain is
proposing the one combination with no precedent anywhere: a performance register
by private contract.** The Uber/Lyft/HireRight ISSP is scoped to five NSVRC
sexual-violence categories plus assault fatalities and covers no performance.

**11. Seattle has legislated directly against both halves of the product.** SMC
Ch. 8.40 (not 8.37) §8.40.050.A.2 lists as unreasonable any deactivation "based
solely on a quantitative metric derived from aggregate customer ratings" (e) or
"based on the results of a background check, consumer report, driver record, or
record of traffic infractions" (h), while §§8.40.080.F and 8.40.110 impose
three-year retention duties whose purpose is to let the *worker* contest. The
retention pressure in this field is worker-protective and it runs against, not
with, a platform-held blocklist.

**12. Designs that reduce the gain from resetting without retaining anything are
real but bounded, and the bound is a theorem.** Friedman & Resnick (2001) prove
that where identities are cheap, no equilibrium sustains materially more
cooperation than "dues-paying" — newcomer distrust *is* the equilibrium, not a
policy choice — and the remedy they name is "free but unreplaceable pseudonyms,"
i.e. the retained link §4 forbids. So: making record age, density, provenance mix
and continuity legible **fully** defeats reset for a worker with a valuable
record, and is **near-useless** against a worker with a thin record and one bad
result. That is the honest accounting.

**13. Decision `022`'s confidence gating already is the mitigation, and its
provenance is what makes it lawful.** A threshold designed as a *measurement*
property, applied identically to every account, is defensible. The same threshold
re-motivated as an anti-reset control is not. **Do not re-describe it**, and
publish the threshold — the OPEN item in `022` is now load-bearing for a legal
argument, not only a product one.

**14. Thin-record signalling can be attacked as an indirect penalty, and the
attack is strongest in California.** Civ. Code §1798.125(a)(1) bars discriminating
"because the consumer exercised any of the consumer's rights," expressly
including "providing a different level or quality of goods or services" and
(D) merely "**suggesting**" it, and (E) reaching independent contractors — and
§1798.145(m)(4) made the employment exemption inoperative on 1 January 2023, so
workers are covered consumers. 11 C.C.R. §7080(a) supplies a but-for test with the
burden on the business. The defence — the deleter is treated identically to a
never-registered user, and a contrary reading would require preserving the
benefits of erased data — probably holds, but **nothing was found applying
§1798.125 to a data-derived output degrading after deletion, and nothing anywhere
addresses whether inferring adverse meaning from the absence of data is itself a
detriment. Unsettled.** The design response is indistinguishability, enforced by
test. India runs the opposite way and is the most favourable jurisdiction found:
DPDP §6(5) provides that "the consequences of the withdrawal … shall be borne by
the Data Principal."

**15. Two things outside the brief that change the risk picture.** The AI Act's
Art. 10(5) was **repealed** by Regulation (EU) 2026/1744 (OJ 24 July 2026) and
relocated to a new Art. 4a — the 2 December 2027 date is now adopted law, and any
repo citation to Art. 10(5) is stale. And a cross-employer performance register is
a **labour-market information exchange**: the DOJ/FTC guidelines of 16 January
2025 say such exchange "may be illegal even if companies use a third party or
intermediary — including a third party using an algorithm," and the 2016 safe
harbour was withdrawn in February 2023. The intermediated structure that research/12
recommends for the safety marker is expressly not a defence here.

---

## 1. What the AI Act record-keeping obligations actually require

### 1.1 Three different articles are doing three different jobs, and conflating them is where the error lives

The founder's framing put Articles 12, 19 and 16 together. They are not one
obligation. Verified against the Commission's own AI Act Service Desk and
cross-checked against two independent article mirrors:

**Article 12 is a product-design duty, not a retention duty.** Art. 12(1):

> "High-risk AI systems shall technically allow for the automatic recording of
> events (logs) over the lifetime of the system."

"Shall technically allow for" is a capability requirement addressed to how the
system is built. It obliges nobody to keep anything.

**Article 12(2) states the purposes the logging capability must serve**, and
every one of them is a *system*-level purpose, not a person-level one:

> "In order to ensure a level of traceability of the functioning of a high-risk
> AI system that is appropriate to the intended purpose of the system, logging
> capabilities shall enable the recording of events relevant for:
> (a) identifying situations that may result in the high-risk AI system
> presenting a risk within the meaning of Article 79(1) or in a substantial
> modification;
> (b) facilitating the post-market monitoring referred to in Article 72; and
> (c) monitoring the operation of high-risk AI systems referred to in
> Article 26(5)."

Risk detection, post-market monitoring, operational monitoring. None of these is
"so that an individual decision can be reconstructed against the individual."

**Article 12(3) is the only place the Act itemises log *content*, and it does
not apply to Grain.** It opens: "For high-risk AI systems referred to in point
1 (a), of Annex III, the logging capabilities shall provide, at a minimum" —
then lists recording of the period of each use, the reference database against
which input data has been checked, the input data for which the search led to a
match, and the identification of the natural persons involved in verifying the
results per Art. 14(5). **Annex III point 1(a) is remote biometric
identification. Grain is Annex III point 4.** The itemised list — the one that
expressly includes input data — is confined to biometric systems and does not
reach employment systems. Confidence: high; this is the plain reading and both
mirrors carry the same chapeau.

**Article 16 is a signposting article.** Art. 16(e): providers shall "when under
their control, keep the logs automatically generated by their high-risk AI
systems as referred to in Article 19." It adds no content requirement. Art.
16(d) points at Art. 18 (documentation), which is a different obligation with a
different object — see §1.4.

**Article 19 is the retention duty, and it is the only one.** Art. 19(1), quoted
verbatim from the Commission's Service Desk:

> "Providers of high-risk AI systems shall keep the logs referred to in Article
> 12(1), automatically generated by their high-risk AI systems, to the extent
> such logs are under their control. Without prejudice to applicable Union or
> national law, the logs shall be kept for a period appropriate to the intended
> purpose of the high-risk AI system, of at least six months, unless provided
> otherwise in the applicable Union or national law, in particular in Union law
> on the protection of personal data."

Two limitations sit in that sentence and both matter enormously. "To the extent
such logs are under their control" — an API provider controls its own run logs;
a deployer's downstream records are the deployer's problem under Art. 26(6). And
the closing clause, which is the single most important sentence in this memo:
**the retention floor is expressly subordinated to data protection law.** §2.2
does the work on that.

### 1.2 The fact of the run, or the output? The Act never says "output"

This was the sharp question and the answer is clean: **for Annex III point 4
systems the AI Act nowhere requires the output to be retained, and nowhere
requires the log to be attributable to a named person.**

The chain is: Art. 19 requires keeping "the logs referred to in Article 12(1)";
Art. 12(1) refers to "events"; Art. 12(2) defines which events by reference to
three system-level purposes; Art. 12(3) itemises content only for biometrics.
There is no other content-specifying provision in Chapter III. The Commission's
own Service Desk page for Article 19 offers no content specification either.

What the three Art. 12(2) purposes actually need is: enough to detect that the
system is drifting, malfunctioning, or producing risk; enough to feed post-market
monitoring; enough for a deployer to monitor operation. That is satisfied by
model version, instrument version, timestamp, requesting party, input *class*
and count, confidence band, and output *distribution* — none of which requires
naming the subject or storing the subject's score in readable form.

Confidence: high on the statutory reading. Medium on durability, for one
reason: **no harmonised standard specifying log content exists yet.**
CEN-CENELEC JTC 21 has not published a record-keeping standard; CEN and CENELEC
resolved in October 2025 to accelerate and expect first harmonised standards in
2026, with a drafting group finalising the most delayed drafts. If a harmonised
standard eventually specifies per-inference logging with subject linkage, the
analysis above weakens — not because the Act changed, but because presumption of
conformity would attach to a richer log. **This is a watch item, not a present
constraint.**

### 1.3 The period is risk-based with a floor, and the floor bends

"For a period appropriate to the intended purpose of the high-risk AI system, of
at least six months." So: **risk-based, with a six-month statutory floor** — not
a fixed period. The provider sets the period by reference to the intended
purpose and must justify it; six months is the minimum, not the answer.

And the floor is not absolute. It applies "unless provided otherwise in the
applicable Union or national law, in particular in Union law on the protection
of personal data." The Act anticipates that data protection law can *shorten*
it. That is not an inference; it is the text naming data protection law
specifically as the thing that can displace the six months.

### 1.4 Four adjacent duties that people mistake for a duty to keep the output

- **Art. 18 (documentation keeping, 10 years).** Real, and long — but its object
  is the *technical documentation* under Art. 11, the QMS documentation under
  Art. 17, notified-body documents, and the EU declaration of conformity. It is
  documentation about the *system*. It contains no personal data about subjects
  and creates no retention hook for a person's score. Ten years is the number
  people quote at this problem; it is the wrong number for this object.
- **Art. 72 (post-market monitoring).** Providers must "actively and
  systematically collect, document and analyse relevant data" on performance
  throughout the lifetime, per a documented plan. This is an argument for keeping
  *aggregate* performance data, and if anything it argues against per-person
  retention: monitoring for drift and adverse impact is a statistical exercise
  that works on distributions.
- **Art. 73 (serious incident reporting).** Creates a duty to report, and by
  necessity to preserve evidence of, a *specific* incident. This is a genuine
  Art. 17(3)(b) hook — but it is incident-scoped and event-triggered, not a
  standing licence to retain every run. It is also, note, the same shape as
  decision 014's severity-gated marker: a specific finding, filed, bounded.
- **Art. 86 (right to explanation).** The obligation runs to the **deployer**,
  not the provider, and it is owed to "any affected person subject to a decision
  which is taken by the deployer on the basis of the output." Art. 86 is a
  reason for the *employer* to keep the output; it is not a provider retention
  duty, and Art. 86(3) disapplies it where Union law already provides the right.
  Grain's Art. 13 transparency duty is to make the system explicable to the
  deployer — not to retain a per-person record so it can explain later.

Together: **the AI Act gives Grain a duty to keep system-level logs, and a
duty to preserve evidence when a specific serious incident occurs. It gives
Grain no standing duty to retain a person-attributable capability projection.**

### 1.5 When the obligation attaches to Grain at all — and the date moved

Two corrections to the founder's premise.

**The date, and the amending instrument the repo does not yet know about.** The
Digital Omnibus on AI is **adopted law**: **Regulation (EU) 2026/1744**,
published in the Official Journal on **24 July 2026** and in force from
**27 July 2026**, amending Reg. (EU) 2024/1689. It is not a proposal. Its
amending item (40)(b) replaces Art. 113, third paragraph, point (c):

> "(c) Chapter III, Sections 1, 2, and 3, with the exception of Article 6(5),
> shall apply from: (i) **2 December 2027** as regards AI systems classified as
> high-risk pursuant to Article 6(2) and Annex III; and (ii) 2 August 2028 as
> regards AI systems classified as high-risk pursuant to Article 6(1) and
> Annex I."

Arts. 12 and 19 sit in Chapter III Sections 2 and 3, so both bite for Grain on
**2 December 2027**. Three verified negatives that matter: **Reg. 2026/1744 does
not amend Art. 12 or Art. 19** — no amending item touches them, and the string
"six months" does not appear anywhere in the Omnibus — and **Annex III point 4 is
unamended**. The founder's date is therefore right, and now rests on adopted law
rather than on a proposal.

**What the Omnibus did change and this repo should note.** Art. 10(5) is
**deleted** (item (9)(b)) and its content relocated near-verbatim to a new
**Article 4a** in Chapter I, converting it from a data-governance provision into
a standalone legal basis for processing special categories for bias detection,
now extended to other AI systems and models at Art. 4a(2). Art. 2(7) was amended
(item (2)(b)) so its cross-reference points to Art. 4a. **Anywhere in this repo
that cites AI Act Art. 10(5) is now citing a repealed provision** — see §7.

Separately: the **broader Digital Omnibus amending the GDPR itself remains a
Commission proposal only** as of August 2026, contested in trilogue, with the
personal-data-definition change reportedly dropped in Council compromise text.
Nothing in this memo relies on it, and nothing in the repo should.

**The territorial hook.** Art. 2(1)(a) catches providers "placing on the market
or putting into service AI systems … in the Union, irrespective of whether those
providers are established or located within the Union or in a third country."
Art. 2(1)(c) catches third-country providers and deployers "where the output
produced by the AI system is used in the Union." Decision `024` set the posture
"build with the constraints in mind, do not build for the EU market first." That
posture is coherent — but 2(1)(c) means the obligation attaches the moment a
partner *uses* a Grain capability projection in the Union, which is a customer's
act, not Grain's. **Grain cannot keep itself out of scope by declining to sell
into the EU; it can only do so by contractually restricting where partners use
the output, and enforcing it.** Confidence: high on the text; my inference on the
consequence.

---

## 2. Does the logging obligation defeat the erasure right?

### 2.1 Art. 17(3)(b) needs an obligation that *requires the processing*

Art. 17(3)(b) disapplies erasure to the extent processing is necessary "for
compliance with a legal obligation which requires processing by Union or Member
State law to which the controller is subject." Read with Art. 6(3) — which
requires the legal basis to be laid down in Union or Member State law and the
purpose to be determined in that legal basis — the exemption covers **the
processing the obligation actually requires, and no more.**

Two words in Art. 17(3) do most of the work: "**to the extent that** processing
is necessary." The exemption is calibrated, not all-or-nothing. It exempts the
data the obligation compels and not a byte more.

So the question is never "is there a logging obligation?" It is "does the
logging obligation require *this* personal datum to be retained?" §1.2 answered
that for Grain: the Act requires system-level logs and does not require a
person-attributable output. **The exemption therefore reaches the run record's
non-identifying content and stops there.**

Three supports, none of which is about AI:

- **Art. 6(3) itself lists "storage periods" among the things the legal basis
  "may contain."** So the Regulation contemplates that a retaining law states its
  own periods. Art. 19 states six months and then subordinates it to data
  protection law (§2.2). Art. 6(3) further requires that the law "meet an
  objective of public interest and be proportionate to the legitimate aim
  pursued," and Recital 41 requires it to be "clear and precise" with
  "foreseeable" application. Recital 45 is the counter — a general law can serve
  several operations — but it still requires the law to determine the purpose,
  and Art. 12(2) determines a *system-monitoring* purpose, not an
  individual-record purpose.
- **C-77/21 *Digi* (EU:C:2022:805)**, operative ruling 2, is close to on point.
  Art. 5(1)(e) storage limitation "precludes the storage by the controller, in a
  database created for the purposes of carrying out tests and correcting errors,
  of personal data previously collected for other purposes, for longer than is
  necessary for the conducting of those tests and the correction of those
  errors." A secondary technical database does not acquire an independent
  retention life; it lives exactly as long as its own stated purpose requires.
  Grain's run record is that database.
- **C-175/20 *SS SIA* (EU:C:2022:124)**, operative rulings 2 and 3: a public
  authority "may not derogate from the provisions of Article 5(1)" absent an
  Art. 23(1) legislative measure, and even then the data must be necessary for
  the specific purposes and the period must not "exceed the period strictly
  necessary." The general data-retention line (*La Quadrature du Net* C-511/18
  para. 164, on the *Digital Rights Ireland* / *Tele2* authority) is to the same
  effect.

Confidence: high on the structure; medium-high on the read-across, since none of
these cases concerns AI logging.

### 2.2 Art. 19(1)'s closing clause is dispositive, and it cuts against Grain

This is the finding I would put in front of counsel first.

Art. 19(1) requires logs to be kept for at least six months "**unless provided
otherwise in the applicable Union or national law, in particular in Union law on
the protection of personal data**." Art. 2(7) reinforces it: "Union law on the
protection of personal data, privacy and the confidentiality of communications
applies to personal data processed in connection with the rights and obligations
laid down in this Regulation."

A provision that expressly yields to the GDPR cannot simultaneously be the
"legal obligation which requires processing" that displaces a GDPR right. The
circularity is fatal: Grain would be arguing that Art. 19 overrides Art. 17
while Art. 19 says it does not override data protection law. **The AI Act
logging duty is not an Art. 17(3)(b) shield for person-attributable content.**
It is a shield for the log qua log, discharged in whatever form data protection
law permits.

Confidence: high-medium. High on the textual argument, which I regard as strong
and hard to answer. Medium on outcome, because no regulator or court has said
it, and a controller will certainly try the opposite argument.

### 2.3 May Grain retain a readable, attributable capability projection about a deleted worker? No.

Stated plainly, because the founder asked plainly.

A capability projection is (i) personal data — it is information relating to an
identified or identifiable natural person, and it is *profiling* on the face of
Art. 4(4), which THESIS §7 already concedes; (ii) not required to be retained by
the AI Act in attributable form (§1.2); (iii) not covered by any of the five
Art. 17(3) grounds on its own facts. It is a derived opinion about a person's
capability, retained after the person asked to be forgotten, whose only readable
function is to be about them.

Every additional argument fails on its own terms:

- **Art. 17(3)(b) legal obligation** — fails on §2.2 and on Art. 6(3).
- **Art. 17(3)(e) legal claims** — available, but only for a *specific*,
  identified, live or reasonably anticipated claim. It is not a standing basis
  for retaining every run against the possibility that someone might one day
  sue. This is the route research/12 §4.2 recommends for the safety marker, and
  the reason it works there is that a marker follows a *finding*; a run record
  follows nothing.
- **Art. 17(3)(d) archiving/research/statistics** — available for genuinely
  statistical use, and it is the honest home for aggregate model-monitoring
  data. But Art. 89(1) requires safeguards including data minimisation and, where
  the purpose can be met by data which does not permit identification, that it be
  met that way. Statistics do not need a name.
- **Consent at signup** — cannot work. Art. 7(3) makes consent withdrawable, and
  Art. 17(1)(b) makes withdrawal itself a *ground* for erasure. A worker cannot
  contract out of Art. 17 in advance.
- **Contract, Art. 6(1)(b)** — cannot work. The AEPD's Goldcar reasoning is
  exactly this point: retention that "does not end with the expiry of the
  contract but continues for a different purpose … requires another legal basis
  to legitimise it."

**Verdict: no.** A readable, attributable capability projection about a deleted
worker cannot lawfully survive that worker's erasure request in the EU, and the
AI Act does not change that. Confidence: high.

**Direct consequence for decision `022`.** That entry rules "Run records are
retained. Requesting party, timestamp, input references, instrument and model
versions, **output**; held for the compliance period." The word *output*, if it
means a readable per-person score surviving deletion, is the part that does not
survive this analysis. See §7.

### 2.4 Is there guidance or case law on AI Act logging versus erasure? Genuinely unsettled

I searched for, and did not find, any of the following: an EDPB opinion or
guideline addressing Art. 12/19 logs as an Art. 17(3)(b) ground; a national DPA
decision on retaining AI audit logs against an erasure request; a CJEU judgment
on the AI Act at all (the Act's high-risk obligations are not yet in
application, so there could not be one); or Commission guidance specifying log
content. The Commission's own Article 19 page carries no interpretive guidance.
No harmonised standard exists.

**The nearest thing to guidance is EDPB Opinion 28/2024 on AI models (17 Dec
2024), and it points away from Grain's hoped-for position on every limb it
touches.** Para. 34: "AI models trained on personal data cannot, in all cases, be
considered anonymous." Para. 43 sets the test — both the likelihood of extraction
and the likelihood of obtaining personal data from queries must be "insignificant
for any data subject," assessed on "all the means reasonably likely to be used."
Para. 102(c) lists, among measures that *help* a controller win the legitimate-
interest balance, "[a]llowing the data subjects to exercise their right to erasure
even when the specific grounds listed in Article 17(1) GDPR do not apply," and
para. 107(b) says the same for measures facilitating erasure "beyond what is
required by law." **The EDPB treats generous erasure as a compliance asset, not a
risk.** And para. 131 warns that an AI Act declaration of conformity, which
includes a statement of data-protection compliance, "may not constitute a
conclusive finding of compliance under the GDPR" — i.e. Grain's own conformity
self-declaration buys it nothing against a supervisory authority.

**This is unsettled, and I am saying so rather than manufacturing a
conclusion.** What exists is: strong statutory text pointing one way (§2.2), a
general CJEU line that retention mandates must be strictly necessary and
proportionate (Digital Rights Ireland C-293/12; Tele2 C-203/15; La Quadrature du
Net C-511/18), and no adjudication on these facts. Treat §2.2 as a
well-supported prediction, not a ruling. Confidence in the characterisation
"unsettled": high. Confidence that a regulator would agree with §2.2 if asked
today: medium-high.

---

## 3. Techniques that discharge the logging duty without person-attributable content

The question was whether these actually work or merely look like they do. Both
happen, and the line between them is precise.

### 3.1 What has to survive, restated as a requirement

From §1.2, an Art. 12/19-compliant log for an Annex III point 4 system must let
someone later establish: that the system ran; when; under which instrument and
model version; on what class and volume of input; with what confidence and
output distribution; and whether that pattern indicates risk, drift, or a
substantial modification. That is the whole requirement. **Nothing in it needs a
subject's name, a subject's stable identifier, or the subject's own score.**

### 3.2 Pseudonymised run records: works, but only if Grain genuinely cannot resolve them

Decision 014 already imported the controlling test from *EDPS v SRB* and
decision 020 applied it to the safety marker: a value is personal data in the
hands of a party that retains the means to re-identify. Applied here:

- A run record keyed to the person's **ledger id** is personal data for as long
  as that id resolves to a person. After deletion, whether it remains personal
  data depends entirely on whether Grain retains anything that resolves it.
- Decision `013`/`020` rule that a tombstoned ledger id is **never reissued** and
  that spine signatures reference it forever. That is a durable, unique,
  person-specific token that Grain deliberately keeps. It is the same structural
  fact that decision 014 identified as what makes a hashed token personal data:
  *retaining the key in order to match is what makes it personal data*. A run
  record keyed to a tombstoned id is therefore **still linked to a singled-out
  individual**, even with the payload shredded — singling out is the Recital 26
  test and Grain satisfies it by construction.
- A run record keyed to a **per-run random identifier** with no stored mapping is
  a different object. It supports every Art. 12(2) purpose, and Grain cannot
  resolve it. This one works.

**So: pseudonymisation works if and only if the pseudonym is not the ledger id.**
That is a schema decision, not a policy decision, and it is the difference
between compliance and theatre. Confidence: high-medium — high on the reasoning,
medium because the EDPB's Guidelines 01/2025 on pseudonymisation are still a
consultation draft and are in open tension with C-413/23 P (already noted in
research/12).

### 3.3 Input references that become unresolvable: works for the log, but ask what you are proving

The proposal is to retain references to input records which stop resolving once
the underlying identifiers are tombstoned and the DEKs destroyed.

**This satisfies Art. 19.** The Act requires the log to be kept; it does not
require the log to remain *resolvable against source data*, and it could not
sensibly do so, because Art. 19's own six-month floor is far shorter than any
plausible source-data lifetime and the Act expects data protection law to
shorten it further.

**But it does not satisfy an auditor's intuition, and Grain should not pretend
otherwise.** A log of dangling pointers proves that a run happened and what
version produced it. It does not let anyone reproduce the run. If Grain's
compliance story to a partner or a regulator is "we can reconstruct any
decision," that story dies at the first deletion. The honest posture is: *runs
are auditable in the aggregate and reproducible only while the subject's record
exists.* Say it in the conformity documentation rather than discovering it in an
audit.

Confidence: high that the technique satisfies Art. 19; high that it is commonly
oversold.

### 3.4 The architectural fork nobody has resolved yet

This is the finding that most affects the build, and it is not in any decision
entry.

`foundation/05` rules that a payload row about a person is encrypted under **that
person's DEK alone**, never dual-wrapped, so `destroy(person)` makes it
unreadable to everyone including the issuing party. `foundation/08` makes that a
documented legal position resting on the ledger's inability to re-identify. Now
apply it to a run record:

- **If the run record is encrypted under the subject's DEK**, it dies at
  deletion. That is the correct GDPR answer and it discharges Art. 19 for
  everything that is *not* subject-specific — but only if the non-subject-specific
  fields (version, timestamp, confidence band, party) live *outside* the
  encrypted envelope. If the whole row is encrypted, deletion destroys the log
  and Art. 19 is breached.
- **If the run record is not encrypted under the subject's DEK**, it survives
  deletion in readable form, and §2.3 says that is unlawful for its
  subject-attributable content.

**So the run record must be split at the schema level: a spine-side, non-
attributable, non-encrypted log row that survives, and a payload-side,
DEK-wrapped, subject-attributable part that dies.** No plan currently says this.
`plans/analytics/LAYER.md` is undecomposed; decision 022's run-record ruling
predates the DEK-ownership ruling in decision 017 and does not engage with it.

Note also that this pushes person-adjacent metadata onto the **spine**, which is
exactly the correlation risk `foundation/09` (spine linkage threat model) exists
to review. A run-record row carrying party, timestamp and confidence band is a
correlation surface even with no readable columns — `foundation/09` should get
this as a named input.

### 3.5 What is theatre

Called out so nobody builds it thinking it counts:

- **Hashing the ledger id and keeping the hash.** Decision 014 already killed
  this reasoning for the enrollment token; it dies the same way here. If Grain
  can compute the hash, Grain can match, and matching is what makes it personal
  data.
- **"Retention for the compliance period" as a blanket phrase.** There is no
  single compliance period. Art. 19 is six months minimum, risk-calibrated. Art.
  18 is ten years for a different object. India's DPDP retention floor is one
  year for a third object. A single configured number satisfying "the compliance
  period" is three obligations wearing one trenchcoat.
- **Keeping the output "for explainability."** Art. 86 binds the deployer. If a
  partner needs to explain a decision later, the partner should hold the output
  — which they do, since they received it. Grain retaining a second copy adds
  nothing to the partner's compliance and adds a controller-side liability.
- **Restricting rather than erasing (Art. 18 GDPR restriction).** Legitimate as a
  holding measure during a dispute; not a substitute for erasure, and not
  available as a standing state.

### 3.6 One textual point that cuts the whole way through

Where the AI Act *does* authorise retaining personal data, it attaches an
express deletion trigger. Art. 4a(1) (formerly Art. 10(5), relocated by Reg.
(EU) 2026/1744) permits providers to process special categories for bias
detection and correction only where, among five other conditions, "the special
categories of personal data are deleted once the bias has been corrected or the
personal data has reached the end of its retention period, whichever comes
first" (Art. 4a(1)(e); the wording is unchanged from the repealed Art.
10(5)(e)).

That is the Act's own model of how personal data in a high-risk AI system is
handled: narrowly permitted, purpose-bounded, deleted at the earlier of purpose
exhaustion and retention expiry. A reading of Arts. 12/19 that licenses
open-ended retention of person-attributable output would be the one place in
Chapter III where the Act abandoned that model, and it would do so by
implication rather than by words. Confidence: medium-high — this is a structural
argument, not a holding.

---

## 4. Reset gaming: is there any lawful basis to retain a performance link?

The founder asked for adversarial treatment. Here it is.

### 4.1 The answer is no, in all four jurisdictions, and the reasons are not close

Decision `014` already established the statutory mapping: fraud and physical
safety appear in the text of California §1798.105(d)(2)/§1798.140(ac), PH NPC
Advisory 2021-01 §10(B)(2) and India DPDP §17(1)(a)/(c); performance appears
nowhere. This memo re-examined the question as instructed and found **no new
basis, and no basis that was missed**. What it adds is the closure of the
remaining routes:

**EU/EEA.** Art. 17(3) is closed at five. The only two that could be argued are
(b) legal obligation and (e) legal claims. (b) requires a Union or Member State
law requiring the processing; there is no law anywhere in the EU requiring a
private party to retain a link across a deletion to preserve a performance
assessment, and §2.2 shows the AI Act is not one. (e) requires a specific claim,
not a standing posture. Falling back to Art. 17(1)(c)/Art. 21(1) balancing,
Grain's asserted interest is, stated honestly, *"continued ability to
disadvantage this person with strangers who never employed them"* — which is the
interest the AEPD condemned in Goldcar and the category CNIL 2021-130 excludes
by declining to authorise mutualised registers.

**UK.** UK GDPR Art. 17(3) is materially identical. The DPA 2018 Sch. 1 Pt. 2
para 14 "preventing fraud" condition and the Sch. 2 Pt. 1 para 2 crime-and-
taxation exemption (which disapplies Art. 17(1)–(2)) are both keyed to fraud and
crime, not performance. Divergence runs the wrong way for Grain: the Employment
Relations Act 1999 (Blacklists) Regulations 2010 exist because Parliament
legislated *against* the category of cross-employer worker vetting databases.

**US federal.** There is no federal erasure right to defeat, so the question
inverts: nothing *requires* Grain to delete, and nothing *authorises* the
retention either — it is simply unregulated at the federal level unless Grain is
a consumer reporting agency, which decision `003` R1 asserts it is not. The
constraint is contractual and reputational, not statutory. Note the direction of
travel is the opposite of helpful: the one federal statute that speaks to
identity-reset-to-escape-an-adverse-record — the Credit Repair Organizations Act
— prohibits *facilitating* it, and prohibits nothing about retention.

**California.** §1798.105(d) is a closed list of nine. (d)(2) security and
integrity is defined by §1798.140(ac) and reaches "malicious, deceptive,
fraudulent, or illegal actions" and "physical safety" — not competence. (d)(7)
"solely internal uses reasonably aligned with the expectations of the consumer"
fails because a worker who deleted their profile has precisely the opposite
expectation. (d)(8) "comply with a legal obligation" has no obligation to point
at. And §1798.125(a)(1) affirmatively prohibits discriminating against a
consumer *because* they exercised a right — see §6.4.

**Philippines.** NPC Advisory 2021-01 §10(B)(2) enumerates the grounds for
refusing erasure and performance is not among them. NPC AO 2023-026 blessed a
*shared employee fraud database* via the legal-claims route — the regulator that
went furthest toward permitting a cross-employer negative register did so
expressly on a fraud theory.

**India.** DPDP §8(7) requires erasure on withdrawal of consent or when the
purpose is no longer being served, subject only to legal-retention requirements;
§17(1) exemptions run to legal rights and claims, offences, and contraventions.
Performance has no home in a closed list.

**Confidence: high.** This is a negative finding across four regimes with
converging statutory structures, and it is the second time the question has been
researched independently and come back the same way (research/12 §1.3 was the
first). Decision `014` was right.

### 4.2 The routes that look like they might work, and why each fails

Stated because they will be proposed:

- **"The worker consents at signup that a reset marker survives."** Fails. GDPR
  Art. 7(3) makes consent withdrawable; Art. 17(1)(b) makes withdrawal itself a
  ground for erasure. India DPDP §6(4)–(6) is the same shape. A pre-commitment to
  not exercise a statutory right is not a lawful basis; it is the thing the right
  exists to defeat.
- **"It is contractual, under Art. 6(1)(b)."** Fails on the AEPD's Goldcar
  reasoning: processing that "does not end with the expiry of the contract but
  continues for a different purpose … requires another legal basis."
- **"We keep no marker, only refuse to serve a second profile to a matched
  document."** This is a marker. The match key is the retained personal datum;
  refusing service is the processing. Renaming it does not change the analysis
  and decision 014 already reached this conclusion for the enrollment token.
- **"The employer, not Grain, keeps the link, and Grain merely reads it."**
  Structurally cleaner — it is the joint-controllership shape decision 014 uses
  for the safety marker, and the shape the ISSP uses. But it does not create a
  lawful basis where none exists; it relocates the controller. A party filing a
  *performance* marker faces the same Art. 17 analysis on its own copy, and the
  UK Blacklists Regulations bite on "compiling, using, selling, or supplying"
  regardless of who holds the file.
- **"It is a legal claim under Art. 17(3)(e)."** Available only for a specific,
  identified, live or reasonably anticipated claim. A performance assessment
  generates no claim. This route is genuinely open for fraud (research/12 §4.2
  recommends it) and genuinely closed for performance.
- **"AI Act Art. 15 accuracy obliges us to keep the history."** No. Accuracy and
  robustness are properties of the system, demonstrated on datasets, not a
  licence to retain individuals' records.

### 4.3 The strongest argument the founder could make, stated fairly

There is one, and it deserves to be on the record rather than dismissed.

**The integrity-of-the-record argument.** Grain's product is not a judgment about
a worker; it is a *measurement over a record*. If the record can be reset at
will, then the measurement measures nothing — a person with five years of
attested history and a person who deleted four of them are indistinguishable,
and the analytic output is systematically biased toward whoever most recently
deleted. Under the AI Act this is arguably not a commercial preference but an
**Art. 10 data governance and Art. 15 accuracy problem**: a provider knowingly
building a system whose training and inference data can be adversarially pruned
by the data subject has an accuracy claim it cannot substantiate.

**Why it still fails as a retention basis, and what it actually argues for.** The
argument establishes that resettable records degrade measurement quality. It does
not establish a legal basis for retaining personal data against an erasure
request, because the remedy it points at is *disclosing the limitation*, not
defeating the right. Art. 13(3)(b)(ii)–(iv) requires the provider to state the
system's characteristics, capabilities and limitations of performance,
including known circumstances that may lead to risks; "the input record is
subject-controlled and may be incomplete" is exactly such a limitation. THESIS
§5 already commits to this pattern for slope, disclosing three failure modes on
the face of every trajectory output. **Resettability is the fourth, and it should
be disclosed the same way.** That is the whole of what this argument wins.

Confidence: high that the argument fails as a retention basis; high that it
succeeds as a disclosure obligation.

### 4.4 There is now an enforcement decision squarely on this fact pattern, and Grain loses it

Decision `014` rested the adverse-list analysis on AEPD Goldcar. There is a
second, closer AEPD decision that the repo does not have, and it is the most
important new authority in this memo.

**AEPD, PS-00176-2024 (Iberia Cards). €20,000, reduced to €16,000 on voluntary
payment. Infringement of Art. 6(1) GDPR, typified under Art. 83.5(a).**

The facts are Grain's facts with the labels changed. On 28 November 2022 the
controller confirmed *supresión y bloqueo* of the complainant's data. Roughly
eleven months later he applied again and was refused a new-customer promotion on
the ground that he was not a new customer. The controller's defence is, almost
word for word, the "minimal link" argument this memo was asked to test:

> "la recepción de una nueva solicitud o detección de coincidencia con un
> cliente reciente no implica el tratamiento de datos de las demás categorías de
> datos que puedan estar guardados y bloqueados, **salvo los que son
> necesariamente necesarios para determinar que no se trata de un cliente
> nuevo**."

The AEPD rejected it:

> "se trataron los datos después de la supresión y bloqueo de los mismos **para
> conocer el contrato que tenía la parte reclamante antes de la solicitud de
> supresión y en base a los mismos negarle la promoción por alta nueva**."

**No fraud. No safety. Pure commercial detriment applied at re-registration via a
retained minimal link.** That is the exact mechanism a performance-reset block
would be.

The doctrinal sting is that Spain is the jurisdiction that *mandates* post-erasure
retention. LOPDGDD Art. 32 requires *bloqueo* rather than destruction — but Art.
32(3): "Los datos bloqueados no podrán ser tratados para ninguna finalidad
distinta de la señalada en el apartado anterior" (courts, prosecutors, DPAs,
liability arising from the processing). **Mandatory retention plus prohibited
use. The block does not open a door; it makes explicit that the door is shut.**
Anyone reaching for "but Spain requires us to keep it" gets the opposite of what
they wanted.

Goldcar supplies two holdings that generalise and should be quoted to counsel:
contract performance dies with the contract ("no finaliza con el vencimiento de
la relación contractual, sino que prosigue con una finalidad distinta; y
requiere de otra base jurídica"), and covert or post-hoc legitimate interest is
fatal ("Es difícil aceptar que un tratamiento se base en el interés legítimo del
responsable cuando ese tratamiento se lleva a cabo de forma oculta").

Two further nails in the Art. 6(1)(f) route. **Necessity is autonomous and
strict** — *Rīgas satiksme* (C-13/16) para. 30, applied in Goldcar — and
realistic less-intrusive alternatives exist here (probation periods, trial
tasks, a fresh assessment), which defeats necessity on its own. And **CNIL has
said the hash point directly**: "ces données hachées restent des données
personnelles."

**Confidence: high.** This is a decided case, on these facts, against the
controller. Decision `014` was right and is now better supported than when it
was made.

---

## 5. How comparable regimes handle reset and identity change

### 5.1 Consumer credit and background screening: no erasure right, a mandatory obsolescence clock, and a criminal prohibition on resetting

Consumer credit is the regime that has thought hardest about this, and it
resolves the tension in a way Grain should study rather than copy. Background
screening is treated here rather than separately, because FCRA governs both and
the employment-specific provisions (§1681k public-record reporting, §1681b(b)
adverse action) hang off the same definitions.

**There is no consumer right of erasure in FCRA, and Congress says so in a
mandated disclosure.** 15 U.S.C. §1679c(a) requires every credit repair
organisation to hand the consumer this text: "neither you nor any 'credit
repair' company or credit repair organization has the right to have accurate,
current, and verifiable information removed from your credit report."

**What exists instead is a statutory obsolescence clock.** §1681c(a) bars
reporting: bankruptcies after 10 years; civil suits, judgments and arrest records
after 7 years "or until the governing statute of limitations has expired,
whichever is the longer period"; paid tax liens and charged-off accounts after 7
years; and, in the catch-all §1681c(a)(5), "[a]ny other adverse item of
information, other than records of convictions of crimes which antedates the
report by more than seven years." **The adverse record expires by law rather than
by request.** Note §1681c(b): those limits fall away for credit transactions of
$150,000 or more, life insurance of $150,000 or more face amount, and employment
at annual salary of $75,000 or more — a band in which the seven-year cap simply
evaporates. It removes a prohibition rather than creating a register, and no one
has built a permanent private performance register in the exempt space, but it
should be confronted rather than discovered by a reviewer.

**Deletion is possible, but only through accuracy, and it is anti-evasion in the
opposite direction.** §1681i(a)(5) deletes what cannot be verified; §1681i(a)(5)(B)(i)
permits reinsertion only if the furnisher "certifies that the information is
complete and accurate"; (B)(ii) requires consumer notice within five business
days; and (a)(5)(C) requires "reasonable procedures designed to prevent the
reappearance" of deleted information. The machinery exists to stop *furnishers*
gaming deletion, not to stop consumers.

**The closest thing to an erasure right is gated on fraud.** §1681c-2 blocks
information "that resulted from an alleged identity theft" on receipt of an
identity theft report — and §1681c-2(c) permits the CRA to decline or rescind the
block where it "was requested by the consumer, on the basis of a material
misrepresentation of fact," or where "the consumer obtained possession of goods,
services, or money as a result of the blocked transaction." Fraud opens the door
and fraud closes it. Performance is not in the conversation.

**And US federal law criminalises identity-reset-as-evasion — of the consumer's
conduct, not the register's retention.** CROA §1679b(a)(2) prohibits any credit
repair organisation from:

> "make any statement, or counsel or advise any consumer to make any statement,
> **the intended effect of which is to alter the consumer's identification to
> prevent the display of the consumer's credit record, history, or rating for the
> purpose of concealing adverse information that is accurate and not obsolete**"

Read the qualifier: "accurate **and not obsolete**." Congress prohibited
identity-reset-to-conceal while leaving the seven-year obsolescence rule fully
intact. **That is precisely the line this memo is drawing, drawn by Congress in
1996.** Enforcement exists — the FTC's "Operation New ID – Bad IDea" (21 October
1999) produced sixteen settlements against sellers of the technique, with
settlements requiring defendants to notify victims that "using a false
identification number to apply for credit is a felony," the criminal hook being
18 U.S.C. §1028(a)(7). Representative cases: *FTC v. Mehmet Akca*, No. 99-S-204
(D. Colo.); *LSQ International*, No. 99-302 (S.D. Fla.).

**Stated plainly as a negative finding:** no FTC or CFPB enforcement action was
found against a *furnisher or CRA* for identity-change-as-evasion. All the
enforcement runs against people selling the technique to consumers. **The regime
that cares most about reset gaming polices the resetter and never licenses the
register to retain more.** That asymmetry is the single most transferable lesson
in this section.

**One trap that reaches back into decision `003` R1.** §1681a(d)(1) defines a
consumer report as information bearing on "credit worthiness, credit standing,
credit capacity, **character, general reputation, personal characteristics, or
mode of living**" used or expected to be used for eligibility for credit,
**employment purposes**, or any other §1681b purpose; §1681a(f) makes anyone who
"regularly engages … in the practice of assembling or evaluating … information on
consumers for the purpose of furnishing consumer reports to third parties" a
consumer reporting agency. A cross-company register of worker performance sits
inside both definitions on their face. If that characterisation ever lands, the
consequences include §1681e(b) maximum-possible-accuracy, §1681i reinvestigation,
§1681k and §1681b(b) for employment use — **and §1681c(a)(5)'s seven-year cap on
the whole record**, since worker earnings will generally fall below the
§1681c(b)(3) $75,000 threshold. That is not a new argument (research/01 carries
it and decision 003 R1 ruled it does not bind design), but it is a new
*consequence*: **in the world where R1 is wrong, the law itself imposes a reset
every seven years, and Grain's retention question is answered against it by
statute.** Worth putting in front of counsel as a scenario, not as a change of
position.

Two directional asymmetries worth carrying: FCRA is a **ceiling, not a floor** —
CRAs have no duty to include a tradeline and no liability for omitting adverse
information — and merging identities is treated as an accuracy **risk**, not a
duty, with mixed-file cases such as *Williams v. First Advantage LNS Screening
Solutions* (11th Cir.) producing substantial compensatory and punitive awards for
wrongly attributing another person's record.

**Correction to a claim that circulates and should not be relied on:** no federal
statute or regulation requires alias or prior-name searching in background
screening, and California's ICRAA (Civ. Code §§1786.16, 1786.18) contains no such
requirement. The CFPB's name-only-matching advisory opinion, 86 Fed. Reg. 62468
(10 Nov. 2021), holds that "name-only matching is not a procedure that assures
maximum possible accuracy" (86 FR 62471) — but it addresses **false positives**
and does not discuss prior names or aliases at all. Every source asserting an
alias-search mandate traces to vendor marketing.

### 5.2 Gig-platform deactivation registers: the register is safety-only, and the retention duty runs the other way

**The Industry Sharing Safety Program** (launched 11 March 2021, Uber/Lyft, later
HopSkipDrive, administered by HireRight as a third-party FCRA consumer reporting
agency) is the only existing cross-platform worker exclusion register. Scope is
closed and enumerated: the five most critical categories of the NSVRC Sexual
Misconduct and Sexual Violence Taxonomy, plus physical assault fatalities.
HireRight "receives only that data strictly needed for cross-platform matching"
and "does not have access to the complaints or report details."

**No performance, ratings, fraud, or service-quality coverage.** One honesty
caveat: that conclusion is construction from an enumerated list. **No primary
document containing an express negative exclusion clause was found.** If a
sentence saying "this program does not cover performance" is needed, it may not
exist publicly.

**Seattle is the one that matters most for Grain's design, and the repo has its
chapter number wrong.** Ordinance 126878 (CB 120580) adds a new **Chapter 8.40**
to the Seattle Municipal Code — **not SMC 8.37**, which is the separate App-Based
Worker Minimum Payment Ordinance. Retention is real and doubled: **§8.40.080.F**
requires three years for records substantiating the deactivation decision, and
**§8.40.110.A–B** three years for a per-deactivation compliance file with nine
enumerated contents. Both carry rebuttable presumptions of violation, expressly
declared substantive (§§8.40.080.G, 8.40.110.C). Notice is 14 days in advance
under §8.40.070 and must include "[a]ny and all records relied upon to
substantiate deactivation."

And the provision that most directly supports the position this memo reaches:
**§8.40.050.A.2** lists policies not reasonably related to safe and efficient
operations, including **(e)** deactivation "based solely on a quantitative metric
derived from aggregate customer ratings," and **(h)** deactivation "based on the
results of a background check, consumer report, driver record, or record of
traffic infractions, except in cases of egregious misconduct or where required by
other applicable law." **A US municipality has legislated directly against both
ratings-driven and consumer-report-driven deactivation.** Grain's analytics
product is the thing (e) describes, sold to the party that (h) restrains.

Corrections to research/12's provisional article numbering for **Platform Work
Directive (EU) 2024/2831**, now verified against the EUR-Lex HTML: Art. 7 is the
prohibited-processing list; Art. 9 transparency; **Art. 10(5)** is the human-decision
rule — "Any decision to restrict, suspend or terminate the contractual
relationship or the account of a person performing platform work or any other
decision of equivalent detriment shall be taken by a human being"; **Art. 11** is
human review (explanation, review request, two-week response, rectification
within two weeks). Transposition deadline 2 December 2026. **There is no
article-level retention period** comparable to Seattle's three years.

**California Prop 22**: the deactivation provision is B&P Code **§7452**, not
§7451, and it requires only a contract-specified ground and the existence of an
appeals process — no retention obligation, no notice period, no agency
enforcement. **New York**: no enacted state law; NYC Int. 1332-2025 reportedly
passed December 2025 with a 17 January 2027 effective date, but the primary text
could not be retrieved and its retention duties are unconfirmed.

**The pattern across all of these is the pattern research/12 §4.2 already
identified and it has strengthened:** the legal pressure to keep deactivation
records is worker-protective, its purpose is to let the worker contest, and it is
the worker's evidence rather than the platform's weapon.

### 5.3 Professional licensing and private adverse registers: the thesis needs restating, and the restatement is stronger

The intuition put to me — "persistent adverse registers are always statutory
creations, never private-contract ones" — **is false as stated.** MIB Group,
Early Warning Services, NCTUE, and the check-acceptance databases (Certegy,
TeleCheck) are all persistent, cross-company, individual-level adverse registers
created by private contract among competitors.

What survives is more useful:

- **Private contract can create the register; only statute can make it
  permanent.** MIB's seven years and Early Warning's five are not business
  choices, they are §1681c(a) compliance. The NPDB by contrast is permanent —
  NPDB Guidebook Ch. E: information reported "is maintained permanently … unless
  it is corrected or voided" — and, notably, no CFR provision sets that period;
  permanence rests on agency practice documented only in the Guidebook, which is
  itself a fragility worth naming.
- **Statute is required for compelled contribution and compelled query.** 42
  U.S.C. §11131(c): a "civil money penalty of not more than $10,000 for each such
  payment" unreported. §11133(c): loss of HCQIA immunity. §11135(b): on failure to
  query, "the hospital is **presumed** to have knowledge of any information
  reported."
- **Statutory registers move deletion authority outside the operator.** FINRA
  Rule **2080(a)** requires a court order or a judicially confirmed arbitration
  award to expunge customer dispute information (Rule 13805 sets panel procedure
  only). NPDB 45 C.F.R. §60.21: "The Secretary will only review the accuracy of
  the reported information, and will not consider the merits or appropriateness of
  the action or the due process that the subject received."
- **Identity-keying is by identifier, not name.** 45 C.F.R. §60.7 requires SSN,
  date of birth, licence number and state, and DEA registration number, and the
  Guidebook is explicit that a subject "may not submit changes to a report,
  including their Social Security Number or other identifiers." A name change does
  not detach a practitioner from their reports.
- **The sharpest empirical finding: every verifiable private cross-company
  register is a fraud, loss, or misrepresentation register. None is a performance
  or competence register.** MIB detects application misrepresentation; Early
  Warning detects account abuse; the check databases detect bad cheques. The
  registers that carry judgments about how well someone did their job — NPDB,
  FINRA CRD, the HHS OIG exclusion list — are all statutory. BrokerCheck looks
  like a counterexample (a private association's register) but Exchange Act §15A(i),
  15 U.S.C. §78o-3(i), statutorily requires it to exist.

**Restated, the thesis holds and is worth writing down:** *when society wants an
adverse record to be permanent, compulsory to file, compulsory to consult, and
deletable only by an authority outside the register's operator, it legislates one.
Private contract has repeatedly produced cross-company adverse registers — but
every one is a fraud or loss register, every one is regulated as an FCRA consumer
reporting agency, and every one is statutorily time-limited.* Grain is proposing
the fourth thing on that list — a performance register — by private contract, and
there is no precedent for it in any surveyed market. Confidence: high on the
individual registers; medium-high on the exhaustiveness of "none is a performance
register," since the search was thorough but not provably complete.

### 5.4 Regulator decisions on identity change as evasion

**On point:** AEPD Iberia Cards, §4.4 — the only decision found anywhere on
retaining a link across an erasure for a non-fraud, non-safety reason, and it
went against the controller.

**Adjacent and important:** The Consulting Association (ICO, 2009) is a better
citation than research/12 gave it credit for, and better than the Blacklists
Regulations, **because it was decided under the general DPA 1998.** The ICO's own
account records that the indexes held "evaluations of their character such as
'ex-shop steward, definite problem' and 'Irish ex-army, bad egg'," that "[p]eople
on the database were prevented from work," and that enforcement notices were
served on **17 construction firms that used the list**, not merely on its
operator. Content was character-and-conduct evaluation, not fraud finding, and it
was unlawful under ordinary data protection law without any special instrument.

**A correction to how research/12 and decision 014 lean on the Blacklists
Regulations.** SI 2010/493 Reg. 3(2) joins its two limbs with "**and**", not
"or": a prohibited list must contain details of trade-union membership or
activities **and** be compiled with a view to discriminatory use. **A performance
register with no union nexus falls entirely outside the Regulations.** Citing them
as authority against one invites an easy rebuttal. Their value is architectural —
Parliament legislated because general data protection law was seen as an
inadequate *deterrent*, not because it was an inadequate *prohibition*.

**Framework:** Art. 29 WP Working Document on Blacklists (WP 65, 3 October 2002)
places "professional misconduct" and "employment records" in the unregulated,
highest-risk, most-complained-about category, and observes that the widespread
lawful blacklists "are records of debts and criminal offences or relate to fraud
prevention, and they all have some kind of legal basis in different national
regulations."

**Negative findings, stated as such:** no Garante, NAIH or UODO decision on
private conduct or performance *liste nere* was obtained; the Datatilsynet
"nej tak-liste" decision text was not retrieved; and the ICO's 2009 enforcement
notices themselves were not retrieved, only the ICO's retrospective account.

### 5.5 What the suppression-list precedent actually permits, restated with the US text

Research/12 §3 established that suppression lists are blessed because they serve
the data subject's own request. Two texts nail the boundary and both are worth
having in the file, because they are the precise shape of a *permitted* residue:

- **ICO** (right-to-object guidance): suppression "involves retaining just enough
  information about them to ensure that **their preference** not to receive direct
  marketing is respected in future," with the entry "clearly marked so that it is
  not processed for purposes the individual has objected to."
- **11 CCR §7022(e)**: a business "may retain a record of the request **for the
  purpose of ensuring that the consumer's personal information remains deleted**
  from its records" — and **§7101(d)** forbids using those records "for any other
  purpose except as reasonably necessary for the business to review and modify its
  processes for compliance."
- **CNIL**: the *liste repoussoir* "ne peut en aucun cas servir à une autre
  finalité"; three-year minimum; hashes permitted but "ces données hachées restent
  des données personnelles."

**Both regimes authorise a link that *enforces* the deletion. Neither authorises a
link that *reverses* it.** That is the sentence to give counsel.

---

## 6. Designs that reduce the gain from resetting without retaining anything

### 6.1 There is a theorem here, and it says the honest thing

Friedman and Resnick, "The Social Cost of Cheap Pseudonyms," *Journal of
Economics & Management Strategy* 10(2) (2001), is the canonical result and it is
directly on this design. Their finding, in a repeated random-matching game with
many players, finite lives, free identity change and a small non-vanishing
probability of mistakes: **no equilibrium sustains significantly more cooperation
than the "dues-paying" equilibrium**, in which newcomers are distrusted and must
accept poor treatment until they establish a reputation. They call that distrust
the *social cost* of cheap pseudonyms — it is not a policy choice by the platform,
it is what emerges.

Three things follow, and they are unusually clean for a design question:

1. **A newcomer penalty is not something Grain would be introducing.** It is the
   equilibrium of any market where identity is free and replaceable. Employers
   already discount unverifiable histories; Grain merely makes the discount
   legible.
2. **The penalty is also the ceiling.** The theorem says you cannot recover the
   lost cooperation by cleverness. A design that retains nothing across deletion
   cannot do better than dues-paying, and no amount of UI work changes that.
3. **The paper names the alternative and it is exactly the rejected design.**
   Friedman and Resnick's remedy is entry fees (excludes the poor) or **"free but
   unreplaceable pseudonyms."** An unreplaceable pseudonym is a link that survives
   deletion. So the trade-off the founder is facing is not a gap in the research;
   it is the known trade-off, and §4 says one of the two branches is unlawful.

Confidence: high — this is a published formal result, and its assumptions
(cheap identity change, occasional mistakes, many players) match this market.

### 6.2 Record age and continuity as first-class, legible facts

The design that works within the constraint is to make *the record's own
properties* legible rather than to make *the person's history* persistent:

- **Age of the earliest attested engagement**, and the span it covers.
- **Density**: attestations per unit of covered time, and gaps.
- **Provenance mix**: how much is party-attested versus self-asserted (decision
  `022` already weights every input by provenance class, so this number exists).
- **Continuity**: whether covered periods are contiguous or the record is a set
  of islands.

None of these requires retaining anything across a deletion, because they are all
computed from what is currently in the record. A profile created yesterday has
age zero and density zero **as a present fact**, not as a memory of a prior
profile. That distinction is the whole legal argument for this design and it is
worth stating exactly that way in the product copy.

**Is it effective?** Partially, and the honest accounting is:

- It **fully** defeats a reset by a worker with a long, dense, party-attested
  record. They cannot reproduce five years of countersigned attestations, so
  resetting costs them everything they had. For this population — which is the
  population Grain's product is *for* — reset is self-defeating without any
  retention.
- It is **nearly useless** against a worker with a thin record and one bad
  assessment. They lose little by resetting because they had little. This is the
  irreducible case, and it is precisely the case where the Friedman–Resnick
  ceiling binds.
- It **does not** distinguish a resetter from a genuine new entrant, which is the
  feature, not the bug: the legal defensibility of the whole design rests on that
  indistinguishability.

So: effective where the record is valuable, cosmetic where it is not. That is
the true answer and it should not be dressed up. Confidence: high — this follows
from the mechanics, not from any authority.

### 6.3 Confidence gating (decision 022) does the work, and it does it for the right reason

Decision `022` already rules that "below a threshold the product returns
insufficient data and suggests an assessment rather than producing a number."
A freshly created profile falls below any sane threshold on day one. **The
reset-gaming mitigation is therefore already built and already ruled**, and — this
is the important part — it was ruled for a *measurement* reason, not an
anti-evasion reason. Its stated purpose is that the output is weak early and says
so.

That provenance matters legally. A confidence threshold designed as a measurement
property, applied identically to every account regardless of how it came to exist,
is a very different object from a threshold tuned to punish deleters. The first is
defensible; the second is §6.4's problem wearing a disguise. **Do not re-motivate
the threshold as an anti-reset control** in any document, roadmap, or sales
deck — the motivation is discoverable and it is the entire difference.

Two consequences:

- **The OPEN item in decision 022 — the threshold value and whether it is
  published — is now load-bearing for a legal argument, not only a product one.**
  A published threshold, set before and independently of any reset concern, is the
  strongest available evidence that the gate is a measurement property. Publishing
  it is now recommended rather than merely considered.
- The suggested remedy on a below-threshold result ("take an assessment") is
  itself the anti-reset mechanism that actually works: it offers a resetter a
  legitimate route back to a score, at the cost of sitting a fresh instrument.
  That is a *cure*, and cures are what regulators like — CNIL 2021-130 requires
  48-hour deletion on cure, and Cifas's fixed expiry does the same job.

### 6.4 Could thin-record signalling be attacked as an indirect penalty on exercising an erasure right? Yes, and this is the real risk in Q2

This is the sharpest legal exposure in the design section, because it is where
the founder's preferred answer and the law actually meet.

**California is the strongest, and it now reaches workers.** Civ. Code
§1798.125(a)(1): "A business shall not discriminate against a consumer because
the consumer exercised any of the consumer's rights under this title,
**including, but not limited to**, by: (A) Denying goods or services… (B)
Charging different prices or rates… (C) Providing a different level or quality of
goods or services… **(D) Suggesting that the consumer will receive** a different
price or rate … or a different level or quality … (E) Retaliating against an
employee, applicant for employment, or **independent contractor**…" Three points:
the enumeration is illustrative, not exhaustive; **(D) prohibits *suggesting***,
which a deletion-derived signal surfaced into a servicing decision plausibly
trips before any differential materialises; and **(E) expressly covers
independent contractors**. And the coverage point that makes it bite —
§1798.145(m)(4) provides "This subdivision shall become inoperative on January 1,
2023," so the employment/contractor exemption has been dead for three years and
**gig workers and contractors are covered consumers**.

**The implementing regulation supplies a pure but-for test with the burden on
the business.** 11 CCR §7080(a): a difference "is discriminatory … if the
business **treats a consumer differently because the consumer exercised a
right**." §7080(b): if the business "cannot show that the … difference is
reasonably related to the value of the consumer's data, that business **shall not
offer** it." The clean exit is §7080(g) — differences that are "the direct result
of compliance with a state or federal law."

**The adversarial case against Grain, at its strongest.** A worker exercises the
§1798.105 deletion right; the immediate and foreseeable consequence is that Grain
provides them a materially worse level of service — no score, an "insufficient
data" result, a visibly thin record shown to employers — than it provided the day
before; Grain designed and disclosed that consequence; therefore Grain provides
"a different level or quality of goods or services" because the consumer
exercised a right, and arguably "suggests" it in advance under (D).

**The defence, which I think holds, but not comfortably.** The statute prohibits
discrimination *because* the consumer exercised the right. Grain's output is a
function of the data present, and the data is absent because the consumer asked
for it to be absent. The rule applied is identical to the rule applied to a
person who never had a record: there is no comparison in which the deleter is
treated worse than an identically-situated non-deleter — the deleter is treated
*the same as* a new user. A contrary reading would make the deletion right
self-defeating, requiring businesses to preserve the *benefits* of data they were
ordered to erase. §1798.125(a)(2) also permits differences "reasonably related to
the value provided to the business by the consumer's data," which is what a
data-derived score is, and §7080(g) is available to the extent the erasure itself
was compelled.

**GDPR has no equivalent, and that should be said plainly rather than assumed.**
Art. 12(5) is a *fee* rule, not a treatment rule. Art. 7(4) and Recital 42
("unable to refuse or withdraw consent **without detriment**") go to whether
consent was ever freely given — a mechanism that retroactively invalidates
consent, which is no remedy where processing rested on contract or legitimate
interests. EDPB Guidelines 05/2020 §3.1.4 paras. 46–48 develop detriment but scope
it to consent; EDPB Guidelines 01/2022 on the right of access contain no general
non-detriment statement. In the EU the work is done by Art. 5(1)(a) fairness,
Art. 5(1)(b) purpose limitation, and the Art. 6(1)(f) balancing test.

**India runs the other way, explicitly.** DPDP §6(5): "The consequences of the
withdrawal referred to in sub-section (4) **shall be borne by the Data
Principal**." That is an affirmative statutory allocation of the downside of a
rights exercise onto the data subject — the single most favourable provision to
Grain's design found anywhere. **Philippines: none** — RA 10173 §16 has no
non-discrimination provision, and §16(e) erasure is conditional on "discovery and
substantial proof" rather than being an on-demand right.

**Worth knowing even though it is outside the surveyed jurisdictions**, because
it is the only provision anywhere that reaches the *flag itself* rather than the
downstream decision: **LGPD (Brazil) Art. 21** — "Os dados pessoais referentes ao
exercício regular de direitos pelo titular não podem ser utilizados em seu
prejuízo." A system that merely stores and scores "this user deleted their data"
is arguably in breach before any differential treatment occurs. If Brazil is ever
a market, this provision alone forecloses the whole category. Also confirmed as
having non-discrimination clauses: Va. Code §59.1-578(A)(4); Conn. Gen. Stat.
§42-520(a)(6); C.R.S. §6-1-1308(1)(c)(II) — and Colorado separately bars
requiring "a consumer to create a new account in order to exercise a right"
(§6-1-1308(1)(c)(I)).

**Confidence: medium.** No regulator decision, CPPA enforcement action, or court
judgment was found applying §1798.125 to a data-derived output degrading after
deletion, in either direction. No EDPB or ICO guidance addresses whether inferring
adverse meaning from the *absence* of data after erasure is itself a detriment;
the EDPB's 2025 Coordinated Enforcement Action report on erasure (32 DPAs, 764
controllers) identifies operational failures, not signalling effects. **This is
genuinely unsettled, and no case law will save a design that gets it wrong.**

**What makes the difference is design discipline, and it is testable:**

- The rule applied to a deleted-and-re-registered account must be
  **byte-identical** to the rule applied to a never-registered account. Not
  "equivalent" — identical code path, provably, with a test.
- Grain must hold **nothing** that lets it or a reader distinguish the two. If a
  reader can tell "this person deleted a prior profile," the defence collapses,
  because the detriment then attaches to the exercise of the right rather than to
  the state of the record. **This is an argument against ever surfacing that a
  ledger id was tombstoned**, and against any UI, packet field, or API response
  that leaks it. It is also the design the absence-inference gap independently
  argues for: since no authority will rescue a distinguishable design, make it
  indistinguishable.
- Grain must never *describe* the gating as targeting resetters (§6.3).

Note the tension with decision `013`/`020`'s never-reissued tombstoned id and
decision `014`'s live-marker path, which produces a "usable-but-restricted
account" and a steward flag on a match. That path is justified for the
safety/fraud category and disclosed at collection; it must not bleed into the
performance case, and AC-PI4a ("unmarked deletion — truly clean") is the criterion
that keeps it separate. *[The AC codes were retired on 2026-08-19 (decision 042);
AC-PI4a is now `person-identity` criterion 4.]* **It is now doing legal work as well as mechanical work.**

### 6.5 What is cosmetic, and should not be built

- **A visible "new profile" badge.** It signals nothing that age and density do
  not already carry, and it invites the §6.4 argument by naming the state rather
  than describing the record.
- **Rate-limiting or cooling-off on re-registration.** A friction that delays
  reset by days is defeated by waiting days, and it is the clearest possible
  evidence that the design targets deleters. It also collides with R2.
- **Requiring a fresh assessment before any score.** This is only non-cosmetic if
  it applies to *all* thin records, in which case it is §6.3 and is already ruled.
- **Device or IP correlation as a soft signal.** Research/12 §2.3 established that
  no platform uses device or IP as a match key; EDPB Guidelines 2/2023 put
  fingerprinting inside Art. 5(3) ePrivacy consent; and using it as a "signal"
  rather than a "key" is a distinction with no legal content. Do not.

### 6.6 One finding outside the brief that bears on the whole category: antitrust

Raised because it surfaced and it matters, not because it was asked.

A cross-platform register of worker performance, contributed to by competing
employers, is an **information exchange in a labour market**. The DOJ/FTC
*Antitrust Guidelines for Business Activities Affecting Workers* (16 January
2025), which replaced the 2016 HR guidance, say:

> "Exchanging such information with competitors may be illegal **even if
> companies use a third party or intermediary — including a third party using an
> algorithm — to share such information.**"

The 2016 safe harbour — third-party administered, data more than three months
old, at least five contributors, none above 25%, aggregated only — was
**withdrawn by DOJ in February 2023.** The ISSP likely survives, because
safety-incident data is not "terms and conditions of employment" and has a strong
procompetitive justification. **A performance register does not have that
shelter, and the intermediated structure that research/12 §4.2 recommends for the
safety marker is expressly not a defence here.**

This does not change the erasure analysis. It does mean that the retention
question is not the only thing standing between Grain and a cross-employer
performance register, and it should be surfaced to counsel alongside it.
Confidence: high on the guidelines text; my inference on the read-across, flagged
as inference.

---

## 7. What this changes in `decisions/LOG.md`

Listed by entry, with the specific defect.

**`022` — "Run records are retained … requesting party, timestamp, input
references, instrument and model versions, **output**; held for the compliance
period."** Two defects. (i) The word *output*, if it means a readable per-person
score surviving the subject's deletion, does not survive §2.3 — no AI Act
obligation requires it and no Art. 17(3) ground covers it. (ii) "The compliance
period" is not a single period: Art. 19 is six months minimum and risk-calibrated;
Art. 18 is ten years for a different object; CPPA risk assessments are five years
for a third; India DPDP Rules Rule 8(3) is one year for a fourth. This entry
needs amending. It also does not engage decision `017`'s DEK-ownership ruling,
which forces the schema split in §3.4.

**`022` — the OPEN threshold item is now load-bearing beyond product.** §6.3:
publishing the confidence threshold, set independently of any reset concern, is
the best available evidence that the gate is a measurement property rather than a
penalty on deleters. This raises "publish it" from a preference to a
recommendation.

**`023` — the OPEN counsel item on attester falsification history.** Falsification
by an attester is a **veracity/integrity** finding, not a performance finding.
It therefore sits on the *fraud* side of decision `014`'s line, not the
performance side, and the candidate shape "a minimal veracity record keyed to a
salted identity commitment" should be re-examined against decision `020`'s ruling
that the safety-marker key must be a **keyed hash with the key in the KMS** — a
salted commitment was already rejected there for the same reason. This memo does
not resolve 023; it narrows it.

**`014` — no change to the ruling; two strengthenings and one correction.**
Strengthened by AEPD Iberia Cards PS-00176-2024 (§4.4), which is closer to these
facts than Goldcar and reaches the same result, and by the finding that no private
cross-company adverse register anywhere is a performance register (§5.3). The
correction: the UK Blacklists Regulations Reg. 3(2) limbs are **conjunctive**, so
a performance register with no union nexus falls outside them entirely. Decision
014's escalation (2) — that the exposure attaches to the product — survives, but
it should rest on The Consulting Association under the general DPA 1998 (§5.4)
rather than on the Regulations.

**`024` — "build with the constraints in mind, do not build for the EU market
first."** Unchanged as posture, but AI Act Art. 2(1)(c) means the obligation
attaches where "the output produced by the AI system is used in the Union" —
which is a *customer's* act. The posture is only real if the partner agreement
restricts and the restriction is enforced (§1.5).

**`003` R2 — "whole-profile deletion at any time."** Confirmed against a second
independent research pass: there is no lawful basis to qualify it for performance
reasons in any surveyed jurisdiction. The only genuine qualifications are
`014`'s severity-gated marker, and per-jurisdiction retention floors — India DPDP
Rules Rule 8(3)'s one-year minimum on personal data, traffic data and processing
logs, which research/12 already flagged and which this memo confirms.

**`003` R1 — "not a CRA."** Not challenged here, but §5.1 adds a consequence
worth recording: in the world where R1 is wrong, §1681c(a)(5) imposes a
seven-year expiry on every adverse item, i.e. **the law would mandate a reset**.
A counsel brief on R1 should ask what the product looks like under that
constraint, not only whether the constraint applies.

**Repo-wide citation defect (not a decision, but it will be cited as one).**
AI Act **Art. 10(5) has been repealed** by Reg. (EU) 2026/1744 and relocated to
new Art. 4a. Any reference in `THESIS.md`, plans, or future briefs must move.
`THESIS.md` §7's EU paragraph should also be updated: the 2 December 2027 date is
now adopted law rather than a fixed date in the original regulation, and it
arrived via an amending instrument.

**Two plans need edits that no decision covers.**
`plans/foundation/09-spine-linkage-threat-model.md` should receive analytics run
records as a named input (§3.4) — a spine row carrying party, timestamp and
confidence band is a correlation surface with no readable columns.
`plans/analytics/LAYER.md` is undecomposed and will inherit the §3.4 schema split
as a constraint before it is written.

---

## What this forces

- **Split the analytics run record at the schema level**: a spine-side,
  non-attributable, unencrypted log row that survives deletion, and a
  payload-side, DEK-wrapped, subject-attributable part that dies with the person.
- **Key the surviving run record to a per-run random identifier with no stored
  mapping**, never to the tombstoned ledger id, because a never-reissued ledger id
  is a retained means of singling out.
- **Amend decision `022`** to strike the retention of person-attributable output
  across deletion, and to replace "the compliance period" with four named,
  separately configured periods.
- **Stop treating "delete means gone" as a global invariant** and make
  per-jurisdiction retention floors first-class schema, with India's one-year log
  floor as the first instance.
- **Do not build any performance-based retention path**, and record that it was
  re-examined on the founder's instruction and refused on a decided case (AEPD
  Iberia Cards) rather than on inference.
- **Make the deleted-and-re-registered code path byte-identical to the
  never-registered one, and prove it with a test**, because the §1798.125 defence
  and the absence-inference gap both depend on indistinguishability.
- **Never surface, log, or expose that a ledger id was tombstoned** in any UI,
  packet field, API response, or steward view outside decision `014`'s
  severity-gated marker path.
- **Publish the decision `022` confidence threshold**, set and dated before any
  reset-gaming concern is recorded in a product document.
- **Never describe confidence gating, record age, or density as anti-reset
  controls** in any roadmap, sales deck, or internal document.
- **Disclose resettability as a stated limitation of the analytic output**,
  alongside the three slope failure modes THESIS §5 already discloses.
- **Add an AI Act log-content watch item** on CEN-CENELEC JTC 21, since a
  harmonised standard specifying per-inference subject-linked logging would
  weaken §1.2.
- **Restrict in the partner agreement where analytic output may be used**, since
  Art. 2(1)(c) attaches the AI Act on a customer's act, not Grain's.
- **Route the labour-market information-exchange question to counsel with the
  erasure question**, not after it.

---

## Sources

**EU AI Act and its amendment**
- Regulation (EU) 2024/1689 (AI Act), Arts. 2, 10, 12, 16, 18, 19, 26, 72, 73, 86, 113; Annex III; Recitals 9, 10, 69, 71 — https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32024R1689
- European Commission, AI Act Service Desk, Article 19 — https://ai-act-service-desk.ec.europa.eu/en/ai-act/article-19
- **Regulation (EU) 2026/1744 (Digital Omnibus on AI), OJ 24 July 2026, in force 27 July 2026** — https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=OJ%3AL_202601744
- European Commission, *Draft guidelines on the classification of high-risk AI systems*, 19 May 2026 (consultation draft, not final) — digital-strategy.ec.europa.eu
- CEN-CENELEC, decision to accelerate AI standards development, 23 October 2025 — https://www.cencenelec.eu/news-events/news/2025/brief-news/2025-10-23-ai-standardization/

**GDPR, UK, and EU worker instruments**
- Regulation (EU) 2016/679, Arts. 5(1)(a)/(b)/(e), 6(1)(c), 6(3), 7(3)–(4), 12(5), 17, 21, 89(1); Recitals 41, 42, 45, 47 — https://eur-lex.europa.eu/eli/reg/2016/679/oj
- Directive (EU) 2024/2831 (Platform Work), Arts. 7, 9, 10(5), 11; transposition 2 Dec 2026 — https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32024L2831
- Employment Relations Act 1999 (Blacklists) Regulations 2010, SI 2010/493, Reg. 3(2) — https://www.legislation.gov.uk/uksi/2010/493/contents/made
- Spain, LOPDGDD (Ley Orgánica 3/2018) Art. 32 — https://www.boe.es/buscar/act.php?id=BOE-A-2018-16673

**Case law**
- CJEU, C-77/21 *Digi* (EU:C:2022:805)
- CJEU, C-175/20 *SS SIA* (EU:C:2022:124)
- CJEU, C-13/16 *Rīgas satiksme* (EU:C:2017:336), para. 30
- CJEU, C-511/18 *La Quadrature du Net* (EU:C:2020:791), para. 164; and the C-293/12 / C-203/15 / C-793/19 data-retention line
- CJEU, C-413/23 P *EDPS v SRB* (4 Sept 2025) — via decision `014`
- Amsterdam Court of Appeal, 4 April 2023, *Drivers v Uber* and *Drivers v Ola* (Art. 22 GDPR; fraud-probability scoring and deactivation held to be automated decision-making; "humans in the loop" rejected as "not much more than a purely symbolic act") — secondary reporting; primary judgments not retrieved
- *Williams v. First Advantage LNS Screening Solutions* (11th Cir.) (mixed files)

**Regulator decisions and guidance**
- **AEPD, PS-00176-2024 (Iberia Cards), €20,000 reduced to €16,000 — retained link used to deny a new-customer promotion after erasure**
- AEPD, PS-00215-2024 / EXP202400905 (Goldcar), €100,000 reduced to €80,000 — https://www.aepd.es/documento/ps-00215-2024.pdf
- EDPB, Opinion 28/2024 on AI models (17 Dec 2024), paras. 34, 43, 102(c), 107(b), 131 — https://www.edpb.europa.eu/system/files/2024-12/edpb_opinion_202428_ai-models_en.pdf
- EDPB, *2025 Coordinated Enforcement Action: right to erasure* (published Feb 2026) — https://www.edpb.europa.eu/system/files/2026-02/edpb_cef-report_2025_right-to-erasure_en.pdf
- EDPB Guidelines 05/2020 on consent, §3.1.4 paras. 46–48; Guidelines 01/2022 on the right of access; Guidelines 5/2019 (RTBF); Guidelines 2/2023 (Art. 5(3) ePrivacy technical scope)
- Art. 29 WP, Working Document on Blacklists, WP 65 (3 Oct 2002)
- ICO, *Right to object* (suppression lists) — https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-object/
- ICO, The Consulting Association enforcement (2009); enforcement notices on 17 construction firms — ICO retrospective account; notices themselves not retrieved
- CNIL, *Comment utiliser une liste repoussoir* — https://www.cnil.fr/fr/comment-utiliser-une-liste-repoussoir-pour-respecter-lopposition-la-prospection-commerciale
- CNIL, délibération n° 2021-130 — via decision `014`
- CFPB advisory opinion on name-only matching, 86 Fed. Reg. 62468 (10 Nov 2021), at 62471

**US federal and state**
- FCRA, 15 U.S.C. §§1681a(d)(1), 1681a(f), 1681c(a), 1681c(b), 1681c-2, 1681e(b), 1681i(a)(5), 1681k, 1681b(b)
- CROA, 15 U.S.C. §§1679b(a)(2), 1679c(a); 18 U.S.C. §1028(a)(7)
- FTC, "Operation New ID – Bad IDea," 21 Oct 1999; *FTC v. Mehmet Akca*, No. 99-S-204 (D. Colo.); *LSQ International*, No. 99-302 (S.D. Fla.)
- HCQIA, 42 U.S.C. §§11101 et seq., 11131(c), 11133(c), 11135(b); 45 C.F.R. §§60.7, 60.21; NPDB Guidebook Ch. E
- FINRA Rule 2080(a); Exchange Act §15A(i), 15 U.S.C. §78o-3(i)
- 29 C.F.R. §1602.14 (addressed to "any personnel or employment record made or kept by an **employer**"; one year); 29 C.F.R. §1607.4 (UGESP, "**each user** should maintain")
- California Civ. Code §§1798.105, 1798.125, 1798.140(ac), 1798.145(d), 1798.145(m)(4); 11 C.C.R. §§7022(e), 7080, 7081, 7101(d)
- CPPA ADMT / risk-assessment / cyber-audit regulations, approved by OAL 23 Sept 2025; ADMT compliance 1 Jan 2027; risk assessments retained minimum five years or as long as processing continues; first submissions to the Agency by 1 Apr 2028
- Colorado AI Act, SB 24-205 as amended by SB 25B-004 (28 Aug 2025) and **SB 189 (signed 14 May 2026)** — effective **1 Jan 2027**, with the duty of care, deployer risk-management programmes and impact assessments removed
- Va. Code §59.1-578(A)(4); Conn. Gen. Stat. §42-520(a)(6); C.R.S. §§6-1-1308(1)(c)(I)–(II)
- Seattle Municipal Code **Ch. 8.40** (Ord. 126878 / CB 120580), §§8.40.050.A.2(e),(h), 8.40.070, 8.40.080.F–G, 8.40.110.A–C
- California B&P Code §7452 (Prop 22)
- DOJ/FTC, *Antitrust Guidelines for Business Activities Affecting Workers* (16 Jan 2025); DOJ withdrawal of the 2016 HR safe harbour (Feb 2023)

**Philippines, India, and comparative**
- India, DPDP Act 2023, §§6(4)–(5), 8(7)–(8), 17(1)
- India, DPDP Rules 2025, G.S.R. 846(E) (13 Nov 2025), Rule 8(1)–(3) and Third Schedule (e-commerce ≥2 crore users, online gaming ≥50 lakh, social media ≥2 crore; three years from last engagement; **Rule 8(3): minimum one year retention of personal data, traffic data and processing logs**)
- Philippines, RA 10173 §16; NPC Advisory 2021-01 §10(B)(2); NPC AO 2023-026 — via decision `014` and research/12
- Brazil, LGPD Art. 21 (outside the surveyed markets; flagged because it is the only provision reaching the flag itself)

**Platform practice and academic**
- Industry Sharing Safety Program (Uber/Lyft/HireRight, 11 Mar 2021); NSVRC taxonomy scope — https://www.uber.com/us/en/newsroom/industry-sharing-safety/ · https://support.hireright.com/en-US/articles/what-is-the-industry-sharing-safety-program
- MIB Group, Early Warning Services, NCTUE, Certegy, TeleCheck (private cross-company registers; all fraud/loss, all FCRA-regulated, all time-limited)
- Friedman & Resnick, "The Social Cost of Cheap Pseudonyms," *J. Econ. & Mgmt. Strategy* 10(2) (2001) — https://www.freehaven.net/anonbib/cache/cheap-pseudonyms.pdf

---

## Coverage gaps and verification caveats

- **AEPD PS-00176-2024 (Iberia Cards) is the load-bearing new authority and it
  was read in the Spanish original by a research subagent, not by me directly.**
  The quotes are represented as verbatim. Given how much §4.4 rests on it,
  spot-check the PDF on aepd.es before it goes to counsel.
- **Reg. (EU) 2026/1744's amending items were read from the OJ HTML.** The
  "does not amend Art. 12 or Art. 19" finding was established by text search of
  the Omnibus, which is a strong negative but not a substitute for a
  consolidated-text check. No consolidated version of the AI Act was available.
- **EDPB Opinion 28/2024's legitimate-interest paragraphs were not extracted
  verbatim.** Paras. 34, 43, 102(c), 107(b) and 131 were; the three-step-test
  discussion at §3.3.2 was not.
- **AI Act Recital 9 was retrieved only in summary form.** Quote from EUR-Lex
  before relying on it.
- **"C-77/24" in the commissioning brief could not be verified to exist.** C-77/21
  (*Digi*) is almost certainly the case intended. Do not cite C-77/24.
- **The regulator sweep for AI-Act-logging-versus-erasure guidance is incomplete.**
  Nothing was retrieved from EDPS TechDispatch, CNIL *recommandations IA*, the
  Irish DPC, AEPD's AI guidance, the German DSK, or the ICO's AI guidance. §2.4's
  "nothing found" is therefore an unsuccessful search across those bodies, not a
  proven absence. The Commission/AI Office negative on Art. 12 log content **was**
  searched directly and is a firmer negative.
- **No express negative-scope clause for the ISSP was found.** The "does not cover
  performance" conclusion is construction from an enumerated list.
- **NYC Int. 1332-2025 primary text unavailable** (Legistar cross-host redirect);
  retention duties unconfirmed. Legistar ID 7480055 if it becomes relevant.
- **Not retrieved:** Garante, NAIH and UODO decisions on private conduct or
  performance registers; Datatilsynet's *nej tak-liste* decision text; the ICO's
  2009 Consulting Association enforcement notices; 45 C.F.R. §60.20 verbatim
  (eCFR returned 503); 42 U.S.C. §11132; FINRA Rule 8312(c) enumerated categories;
  NPC Advisory Opinion 2018-039 (privacy.gov.ph returned 403); the Amsterdam Court
  of Appeal judgments in primary text; UK Data (Use and Access) Act 2025 changes to
  automated decision-making.
- **India DPDP Rules Rule 8(3)'s scope is ambiguous on the sources retrieved.**
  It is presented in some readings as general to all Data Fiduciaries and in others
  as tied to the Third Schedule classes. That distinction decides whether Grain has
  an India retention floor at all. **Resolve against the gazette text before
  building to it.**
- **11 C.C.R. §§7080–7081 text is from the 2023 adopted regulations.** The 2025
  ADMT and risk-assessment rulemakings may have renumbered Articles 7–8; verify
  against the current CCR. Note §7080(f) contains a typographical error in the
  official adopted text ("section 1798.145, subdivision (i)(h)(3)") — reproduce it
  with a footnote rather than silently correcting it.
- **Corrections to prior repo material, consolidated:** Seattle is SMC **8.40**,
  not 8.37 (research/12 §1.5 implies the ordinance without a chapter; the founder
  brief used 8.37). Platform Work Directive human-decision rule is **Art. 10(5)**
  and human review **Art. 11**, discharging research/12's flagged
  article-numbering caveat. Prop 22 deactivation is B&P **§7452**, not §7451.
  There is **no** Civ. Code §1798.125(a)(4) and **no** 11 C.C.R. §7082. India's
  withdrawal-consequences provision is DPDP **§6(5)**, not §6(6). FINRA's judicial
  expungement gate is Rule **2080(a)**, not 13805. The CFPB name-only-matching
  opinion concerns **false positives**, not aliases.
- **The 2026 CFPB Regulation B rewrite** (final rule reported 22 April 2026,
  removing disparate impact from ECOA enforcement) surfaced during research and is
  **secondary-sourced only**. It is not relied on anywhere in this memo. If ECOA
  disparate impact ever becomes load-bearing for the analytics product, verify it
  first.
