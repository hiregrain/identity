# Deletion vs. reputation evasion: can anything survive an erasure request?

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

**Status:** Research memo, not legal advice. Not counsel-reviewed. Written
2026-08-18. Companion to `01-regulatory-perimeter.md` (FCRA/GDPR/DPA
perimeter), `06-adversarial-threat-model.md` (Sybil/fresh-start attacks), and
`08-kyc-regulatory-triggers.md`. Confidence is flagged inline; settled statute,
regulator guidance, published platform practice, journalism, and my own
inference are labeled separately throughout.

**Relationship to a standing decision.** Decision `009` already ruled: *"No
salted document-hash survives profile deletion — R2's spirit controls; the
Uber-style retain-and-flag alternative is rejected. Revisit trigger: fresh-start
fraud materializing at measurable rates."* This memo was commissioned to test
the reasoning behind that ruling, not to assume it. **The research substantially
vindicates 009 for the general case and identifies one narrow category where it
is probably wrong.** See §4. Treat this as a revisit input, not a settled
restatement.

**Scope:** GDPR/UK GDPR, EU Platform Work Directive, CCPA/CPRA, Philippine DPA,
India DPDP. Platform practice across rideshare, delivery, marketplace, and
freelance verticals. The specific question is narrow: **may a platform retain a
one-way hash of an identifier (phone, government-document number, device),
after honoring an erasure request, solely to flag re-registration, and does the
answer turn on why the account ended?**

---

## TLDR: all conclusions

**1. Deletion is not absolute anywhere, but the fraud carve-out is not in the
exemption list, and that changes everything about how you have to argue it.**
The instinct is to look for a fraud-prevention exemption in GDPR Art. 17(3).
There isn't one. Art. 17(3) is a closed list of five: freedom of expression,
legal obligation/public task, public health, archiving-research-statistics, and
establishment/exercise/defence of legal claims. Recital 65 mirrors it exactly
and omits fraud. Recital 47's fraud sentence states: *"The processing of
personal data strictly necessary for the purposes of preventing fraud also
constitutes a legitimate interest of the data controller concerned"*. That is a
**legal-basis** statement about Art. 6(1)(f), not an erasure exemption. The
consequence is
procedural and severe: fraud-prevention retention has to defeat the erasure
right at **Art. 17(1)**, by showing the data are still *necessary* under
17(1)(a) and that there are *overriding legitimate grounds* under 17(1)(c) →
Art. 21(1). That is a case-by-case balancing test the controller bears the
burden on, not a checkbox. Confidence: high, given the plain structure of the
text.

**2. A retained one-way hash is personal data in your hands, and the 2025 CJEU
pseudonymisation ruling does not save you.** The hash's entire function is to
single out one human on re-registration; Recital 26's identifiability test is
satisfied by singling-out alone. *EDPS v SRB* (C-413/23 P, 4 Sept 2025) did
establish a relative, recipient-dependent test for pseudonymised data, but it
helps a recipient who *cannot* re-identify. You are the party who deliberately
retains the matching capability. The EDPB's 2025 coordinated enforcement report
says the quiet part out loud: some controllers *"only apply basic
pseudonymisation or partial masking, although such a process would not fulfil
the requirements of the GDPR regarding deletion."* Hashing is not a way around
the erasure right; it is a data-minimisation measure applied to data you have
already justified keeping. Confidence: high.

**3. The hypothesis is correct, and California states it in statutory text.**
Retaining identifiers to block re-registration is defensible where the exit was
**fraud** or **safety/misconduct**, and is not defensible where the exit was
**poor performance**. CCPA §1798.105(d)(2) exempts retention needed to "help to
ensure security and integrity," and §1798.140(ac) defines that term as the
ability to "resist malicious, deceptive, fraudulent, or illegal actions and to
help prosecute those responsible" and to "ensure the physical safety of natural
persons." Fraud is named. Physical safety is named. **Performance is nowhere in
the statute**, and the only plausible alternative hook, §1798.105(d)(7)'s
"solely internal uses reasonably aligned with the expectations of the consumer",
fails precisely because a worker who deletes their profile has the opposite
expectation. GDPR reaches the same place by a different route: the Art. 21(1)
balancing that fraud can win (Recital 47 pre-weights it) is one that "we want to
keep telling employers you were slow" loses, because there is no recognised
countervailing interest of comparable weight and the harm to the data subject is
the entire point of the retention. **The pattern repeats in all four
jurisdictions.** The Philippine NPC's express list of grounds for refusing
erasure (Advisory 2021-01 §10(B)(2)) runs to legal claims and legitimate
business purposes; India's DPDP Sec. 17(1) exemptions run to enforcing a legal
right or claim and to offences and contraventions of law. Every regime surveyed
has somewhere for fraud and safety to attach, and none has anywhere for
performance to attach. The Philippines even supplies a near-exact precedent for
this product: NPC Advisory Opinion 2023-026 (2023) blessed an IT-BPO company
building a **shared employee fraud database**, and reached it through the legal
claims route, "processing for the purpose of establishing, exercising or
defending a legal claim involving a fraudulent act," with a mandatory retention
policy attached. Fraud, framed as a legal claim. Not performance. Confidence:
high on the California, Philippine, and Indian statutory text; high-medium on
the GDPR balancing prediction (no adjudication on these exact facts anywhere).

**4. Voluntary exit gets no retention at all. That is the cleanest line in the
whole analysis.** Where nothing went wrong, there is no interest to balance
against the erasure right, so 17(1)(a) is made out on its face because the data
are no longer necessary for any purpose. Any retention here is indefensible in every
regime surveyed. Confidence: high.

**5. Industry converged on a narrow, severity-gated, intermediated answer, and
it is a better model than the one this design was reaching for.** The single
most on-point precedent is the Uber/Lyft **Industry Sharing Safety Program**
(2021, later HopSkipDrive). It is exactly a cross-platform negative-signal
network for deactivated workers, and every one of its design choices is a
concession: scope limited to the five most critical categories of the NSVRC
sexual violence taxonomy plus physical assaults resulting in fatality
(incidents Uber says are "less than one-thousandth of one percent of all
trips"); administered by a **third party, HireRight, which is an FCRA consumer
reporting agency**, not by the platforms; and HireRight *"receives only that data
strictly needed for cross-platform matching"* and *"does not have access to the
complaints or report details."* The industry did not build a general reputation-
portability layer with a fraud exception bolted on. It built a matching index
for a handful of catastrophic categories and routed it through a regulated
intermediary that carries the dispute duty. Confidence: high, published by all
parties.

**5b. Uber has already drafted the model clause, and it gates on exactly the line
this memo defends.** Uber's privacy notice is the only one of nine surveyed that
states the purpose outright: "**if you are banned from Uber's services because of
serious fraudulent or unsafe behavior, Uber will retain your data after an
account deletion request to prevent you from re-obtaining access to Uber's
platform**," against a 90-day default deletion. Fraud and safety, named;
performance, absent. Lyft reserves the right to refuse deletion entirely "if
there is an issue with your account related to trust, safety, or fraud." Etsy
tells users plainly that "closing your account may not free up your email
address, username, or shop name … for reuse." The remaining six platforms
enforce re-registration bans while disclosing only a generic fraud-prevention
retention basis, with Airbnb being the sharpest anti-pattern, contractually
prohibiting re-registration (Terms §12.5) with **no** matching carve-out in its
privacy policy. Also notable: **no platform names device or IP as the
re-registration key.** The convergence is on identity documents and face
biometrics. Confidence: high, all quoted from live policy text.

**6. The suppression-list pattern is genuinely regulator-blessed, and it is
being misread. The ICO blesses it because it serves the data subject's own
request, which is exactly the property a re-registration blocklist lacks.** The
ICO is unusually direct: *"keeping a suppression list isn't for direct marketing
purposes. You are keeping this list so that you can comply with your statutory
obligations (ie to comply with their objection),"* and therefore *"there is no
automatic right for people to have their information on such a list deleted."*
CCPA §1798.105(c)(2) contains the same structure: a business may keep a
"confidential record of deletion requests" *solely* to stop the data being sold,
for legal compliance, or "for other purposes, solely to the extent permissible
under this title." Both instruments authorise a minimal residue **whose function
is to honour what the person asked for**. A ban-evasion blocklist inverts the
polarity, since it is a residue that operates *against* the person who asked. Citing
suppression-list precedent for it is a category error, and I expect a regulator
to say so. Confidence: high on the guidance text; medium-high on how a regulator
would treat the analogy, since none has ruled on it.

**6b. There is one enforcement action squarely on the adverse-list question, and
it turns on precisely the fraud/not-fraud distinction.** The Spanish AEPD fined
Goldcar €100,000 (reduced to €80,000) for refusing a rental on the basis of an
internal flag from a prior contract, holding that this "amount[s] to the creation
of a '**customer blacklist**' — processing which is not covered by the
contractual relationship, inasmuch as it does not end with the expiry of the
contract but continues for a different purpose; and it **requires another legal
basis to legitimise it**." The aggravating fact the AEPD singled out: "the
information retained **does not refer with certainty to a fraud committed by the
claimant**." The AEPD expressly did *not* condemn exclusion lists as such.
Instead, it contrasted them with statutorily grounded credit-information systems
having objective published entry criteria and prior notice. That is the
checklist. And CNIL's exclusion référentiel (2021-130) authorises a
single-controller exclusion register with a five-year cap and 48-hour deletion on
cure, while **expressly excluding mutualised sharing with third parties from its
scope**, which is a direct warning for a cross-vertical design. Confidence: high
on the decisions; my inference on the read-across to a worker ledger.

**7. The most dangerous precedent in this file is not a privacy case. It is the
UK construction blacklist.** The Consulting Association held cross-employer
negative records on 3,213 construction workers, sold to 40+ firms; the ICO
raided it in 2009, its operator was prosecuted, Parliament passed the
Employment Relations Act 1999 (Blacklists) Regulations 2010 to prohibit
compiling, using, selling, or supplying such lists, and the participating firms
settled for roughly £75 million. The Regulations are formally narrow, biting only
on trade-union grounds, but the political and regulatory reflex they encode is
not narrow at all. A durable cross-employer negative-performance record on
workers is, in the UK and EU, the most disfavoured category of database that
exists. This should weigh on the product, not just on the deletion policy.
Confidence: high on facts; my inference on the read-across, flagged as such.

**8. Recommendation: hold decision 009 as the default, and carve exactly one
exception: a severity-gated safety/fraud flag, intermediated, time-boxed, and
disclosed pre-collection.** Voluntary exit and performance-based exit: full
erasure, no residue, no exceptions. Termination for **verified fraud against the
ledger's own integrity** (forged documents, identity substitution, attestation
collusion) or for **a serious safety finding** in a defined, published taxonomy:
retain, for a fixed period, a salted hash of the government-document number
only, excluding phone, device, and name, holding *no* payload about what
happened,
producing only a "manual review required" signal on re-registration rather than
an automatic block, disclosed at collection time rather than at deletion time,
with a human-reviewable appeal. **Note this is narrower than Uber's published
practice** (which matches on "information, documents, and photos") and narrower
than eBay's (phone, address, bank details, device, IP). The strongest
counter-argument to my own recommendation is in §4.3, and it is a good one: the
fraud/performance line I am relying on is clean in law and filthy in operations,
because the platform's own classification of an exit is unreviewed, self-serving,
and exactly the thing an employer with a retaliation motive will manipulate.

**9. The framing in the prompt, that ledger deletion only removes cross-vertical
portability and not the original employer's own knowledge, is correct, and it
is the single strongest argument for permissive deletion.**
Deleting from the ledger destroys no evidence. The employer who fired the worker
still knows, still holds their own records, and is still free to answer a
reference call. What deletion removes is only the *amplification*: the ability
to broadcast a negative signal to parties who have no relationship with the
worker. That is precisely the interest that regulators protect most and platforms
justify least. It also means the marginal safety cost of permissive deletion is
much lower than the intuition suggests. Confidence: high on the structural
point.

---

## 1. The legal position

### 1.1 Erasure is not absolute, but the exemption you want is not in the exemption list

Article 17 has a two-layer structure that most commentary blurs, and the
distinction is decisive here.

**Layer one, Art. 17(1)**: the right is *triggered* only where one of six
grounds applies. Verbatim, the two that matter:

> "(a) the personal data are no longer necessary in relation to the purposes for
> which they were collected or otherwise processed;"
>
> "(c) the data subject objects to the processing pursuant to Article 21(1) and
> there are no overriding legitimate grounds for the processing, or the data
> subject objects to the processing pursuant to Article 21(2);"

**Layer two, Art. 17(3)**: where the right *is* triggered, it is disapplied "to
the extent that processing is necessary" for one of five things: exercising
freedom of expression and information; compliance with a legal obligation or
performance of a public-interest task; public-health reasons; archiving in the
public interest, scientific/historical research, or statistics; and
"establishment, exercise or defence of legal claims."

**Fraud prevention appears in neither list.** Recital 65 confirms this is
deliberate rather than an oversight. It recites the permitted grounds for
"further retention" in the same five categories and does not mention fraud.

The fraud language people reach for is Recital 47, and it is doing a different
job:

> "The processing of personal data strictly necessary for the purposes of
> preventing fraud also constitutes a legitimate interest of the data controller
> concerned."

Recital 47 is about **Art. 6(1)(f)**: whether you had a lawful basis to process
in the first place. It says nothing about whether an erasure right, once
triggered, can be resisted.

**Why this matters operationally.** It means fraud-prevention retention cannot
be asserted as a clean exemption. It has to win at Art. 17(1), which requires
one of two arguments:

- **17(1)(a):** the data are *still necessary* for a live purpose (fraud
  prevention), so the trigger never fires. This is the strongest available
  route, and it is a necessity test that is genuinely contestable, and it
  collapses the moment the retention outlives the fraud risk it was justified by.
- **17(1)(c) → Art. 21(1):** the subject objects, and you must show *overriding
  legitimate grounds*. Recital 47 pre-weights fraud favourably in this balance,
  which is its real utility. But the burden is on the controller, and it is
  case-by-case.

There is a third, underused route: **Art. 17(3)(e)**, "establishment, exercise
or defence of legal claims." Where the worker's exit was for conduct that
generates foreseeable litigation exposure, such as a safety incident or a fraud
loss, this is a real hook and it is a genuine *exemption* rather than a
balancing test. It is narrower than it looks (it does not cover speculative future claims
against unrelated parties) but where it applies it is the cleanest ground in
Art. 17. Confidence: medium-high; it is the ground I would expect counsel to
lead with for the safety category.

**Regulators are actively policing exactly this reasoning.** The EDPB's
Coordinated Enforcement Framework action for 2025 was on the right to erasure;
32 supervisory authorities participated, 9 opened or continued formal
investigations, and the report was adopted and published in February 2026. Its
Issue 4 findings are a direct warning:

> "Several controllers demonstrated uncertainty or inconsistency in applying the
> exceptions under Article 17(3) GDPR. The verification of conditions for
> exceptions varies widely among controllers, and in some cases, exceptions are
> treated as automatically applicable without conducting a case-by-case
> assessment."

and, precisely on point:

> "erasure requests are sometimes refused on the grounds of legitimate interest
> without proper assessment or documentation of the balancing test."

The report also establishes the compliance posture required *when a refusal is
lawful*, which is the design-relevant part:

> "In cases where erasure requests are lawfully denied under Article 17(3) GDPR,
> some controllers do not consistently implement measures to ensure continued
> compliance with the principles laid out in Article 5 GDPR, such as data
> minimisation, storage limitation, and integrity and confidentiality.
> Appropriate technical and organisational measures — such as restriction of
> processing (Art. 18 GDPR), or segregation of data within specific systems —
> are not always applied."

Read as design requirements: a lawful residue must be **minimised** (hash, not
identifier), **time-boxed** (storage limitation, not indefinite), **segregated**
(its own store, not a flag on the live record), **access-controlled**, and
**documented in writing at the time of the refusal**. The EDPB's explicit
recommendation is to *"[d]ocument legal reasonings and justifications in writing
when relying on exceptions to erasure (e.g. through a record of requests)."*

One further finding is useful ammunition for the product: the EDPB flags a need
to raise awareness *"on the distinction between the right to erasure and the
deletion of a user account."* Deleting an account and erasing all personal data
are, as a matter of law, different operations. A design that offers both, and
labels them honestly, is ahead of the field.

### 1.2 A retained hash is personal data, and the 2025 CJEU ruling does not rescue it

This has to be settled before the rest of the analysis means anything, because
if a hash were not personal data the erasure right would simply not reach it.

It is personal data. Recital 26's identifiability test is met by the ability to
**single out** an individual, and singling out on re-registration is the hash's
entire and only purpose. A controller who keeps a salted hash *specifically so
that it can recompute the hash from a document presented later and match* has,
by construction, retained the means of identification.

The tempting counter is *EDPS v SRB*, Case C-413/23 P, decided 4 September 2025.
The CJEU did hold, in a significant departure from long-standing DPA orthodoxy,
at para 86 that "**pseudonymised data must not be regarded as constituting, in
all cases and for every person, personal data**." But read paras 76 and 77, and
the ruling closes on exactly the party that wants to rely on it. Para 76:

> "as is usually the case for controllers who have pseudonymised data, the SRB
> does, in the present case, have additional information enabling the comments
> transmitted to Deloitte to be attributed to the data subject, with the result
> that, in its view, **those comments are, in spite of pseudonymisation, still
> personal in nature**."

And the operative two-limb test at para 77 requires that the recipient "**is not
in a position to lift those measures**" and that the measures "**in fact be such
as to prevent [the recipient] from attributing those comments to the data
subject including by recourse to other means of identification such as
cross-checking with other factors**." A platform that keeps the salt so it can
recompute and match fails both limbs by design.

Two further paragraphs matter for the architecture. Para 85 runs the test in the
adverse direction: where "it cannot be ruled out that those third parties have
means reasonably allowing them to attribute pseudonymised data to the data
subject… the data subject must be regarded as identifiable." And para 82 sets
the threshold: a means of identification is not reasonably likely to be used
"where the risk of identification appears in reality to be insignificant… for
example because it would involve a disproportionate effort in terms of time,
cost and labour."

Note also the disposition: the Court **set aside** the General Court's judgment
and referred the case back. The SRB did not win outright, and the Court held the
controller's transparency obligation applied at collection regardless of the
recipient's position.

Confidence: high that SRB does not assist the retaining controller; medium on
whether it assists a *downstream vertical* receiving a match signal without the
salt or the candidate list. That second reading is architecturally interesting
and worth counsel time, because it is roughly what the HireRight structure
achieves.

**The regulator position is still formally the opposite and has not been
revised.** EDPB Guidelines 01/2025 on Pseudonymisation (adopted 16 January 2025,
still a consultation version, predating the judgment by eight months) para 22:

> "Even if all additional information retained by the pseudonymising controller
> has been erased, the pseudonymised data becomes anonymous only if the
> conditions for anonymity are met."

And the EDPB's own February 2026 erasure report says weak pseudonymisation is
not deletion:

> "in some cases, they only apply basic pseudonymisation or partial masking,
> although such a process would not fulfil the requirements of the GDPR
> regarding deletion."

**On hashing specifically, the technical guidance is unhelpful to this design.**
Article 29 WP Opinion 05/2014 (WP216) states that "if the range of input values
the hash function are known they can be replayed through the hash function in
order to derive the correct value for a particular record," gives *hashing the
national identification number* as its worked example of exactly this failure,
and warns that even a salted hash "may still be feasible with reasonable means."
The AEPD/EDPS joint paper on hash functions (October 2019) sets the bar for
treating hashing as *anonymisation* at high entropy, single-use salts, "zero
links with identifiers, pseudoidentifiers and other information," and
organisational removal of any re-identifying information. A re-registration
index cannot meet that standard, because a single-use salt would make matching
impossible, since the salt must be stable for the mechanism to work at all. **That
tension is fundamental, not an implementation detail: the property that makes
the hash useful is the property that keeps it personal data.**

**Design consequence:** hashing is not a legal argument. It is a mitigation you
apply *after* you have independently justified the retention. Any design memo
that treats "but it's only a hash" as the justification is wrong.

### 1.3 The reason for exit determines the answer

This is the core question, and the hypothesis holds. Three cases:

**(a) Voluntary exit: no retention is defensible.** Where nothing went wrong,
there is no live purpose the data serves and no interest to weigh against the
subject's. Art. 17(1)(a) is satisfied on its face, since the data are no longer
necessary for the purpose for which they were collected. No Art. 17(3) exemption
is in play. Under CCPA no §1798.105(d) exemption is in play either. This is the
one case where every regime surveyed gives the same unambiguous answer.
Confidence: high.

**(b) Termination for fraud or a serious safety finding: retention is
defensible, on conditions.** GDPR: Recital 47 pre-weights fraud in the Art. 21(1)
balance; Art. 17(3)(e) is available where litigation exposure is real. CCPA:
§1798.105(d)(2) plus the §1798.140(ac) definition names both limbs expressly:
"resist malicious, deceptive, fraudulent, or illegal actions" and "ensure the
physical safety of natural persons." The conditions are the EDPB's Article 5
package from §1.1: minimised, time-boxed, segregated, documented. Confidence:
high that the basis exists; medium on how far it stretches, because "fraud"
here must mean fraud against the system's integrity, not "we think this worker
is bad."

**The EDPB has set the bar for fraud-based processing, and it is high, but it
is a bar a severity-gated design clears and a catch-all design does not.**
Guidelines 1/2024 on Art. 6(1)(f) (adopted 8 October 2024; still a consultation
version) para 100:

> "This does not mean, however, that it is automatically possible to rely on
> Article 6(1)(f) GDPR as a legal basis to engage in any processing of personal
> data for the purpose of fraud prevention"

Para 101: "the requirements for data processing for the purpose of fraud
prevention **are strict** against the backdrop of the impact that such
processing can have on data subjects." Para 105 gives the design rule directly:
"**The fraud the controller is trying to prevent should be of substantial
importance**, otherwise, the balancing of interests will most likely turn out in
favour of the data subject." Para 106 forecloses lazy drafting: "a generic
reference to the purpose of 'combating fraud' … in the privacy policy, **is not
sufficient**." Para 104 ties retention expressly to Art. 5(1)(e) storage
limitation.

Read together, 105 and 106 argue *for* the severity-gated, published-taxonomy
design in §4.2 rather than against a residue as such. A narrow, named, serious
category is what the EDPB is asking for; "fraud and abuse" as a catch-all is
what it is refusing.

**(c) Termination for poor performance: retention is not defensible.** The
hypothesis is correct, and California is the clearest evidence because the
statute is a closed list:

- §1798.105(d)(2)'s "security and integrity" ground fails. The §1798.140(ac)
  definition covers security incidents, malicious/deceptive/fraudulent/illegal
  actions, and physical safety. Slow, unreliable, or unskilled is none of these.
- §1798.105(d)(1)'s "perform a contract" ground fails. The contract with the
  worker ended.
- §1798.105(d)(7)'s "solely internal uses that are reasonably aligned with the
  expectations of the consumer based on the consumer's relationship with the
  business" ground fails, and fails for an instructive reason. A worker who
  deleted their profile has demonstrated the *opposite* expectation, and the
  retention is not an internal use, since its purpose is to shape what third-party
  verticals see.
- §1798.105(d)(8)'s "comply with a legal obligation" ground fails absent a
  specific retention mandate (see §1.5 for where one actually exists).

Under GDPR the same result arrives via the Art. 21(1) balance. Recital 47's
weighting is unavailable. The countervailing interest, a hiring party's
interest in knowing about past performance, is real but not weighty in the
Art. 21 sense, while the detriment to the data subject is not a side effect of
the retention but its designed function. A controller arguing that "continued
ability to disadvantage this person in the labour market" overrides their
erasure right is making an argument I would not expect to survive contact with a
supervisory authority. Confidence: high on the California statutory reading;
medium-high on the GDPR prediction, since it is a balancing test and no
regulator has ruled on these facts.

**A caution about the boundary.** In operations these three categories are not
crisply separable, and the classification is made by the party with an interest
in the outcome. See §4.3, which raises the strongest objection to my own
recommendation.

### 1.4 UK: the ICO position

The UK GDPR text is identical, so §1.1 carries over. Two additions from ICO
guidance are load-bearing.

**Scope of the right.** *"The right only applies to data held at the time the
request is received. It does not apply to data that may be created in the
future."* This is more useful than it looks, since it means a hash *created at the
moment of deletion* is squarely within scope of the request that triggered it,
and cannot be characterised as new data outside the right.

**"Beyond use."** The ICO's backup guidance supplies the concept most useful to
this design, even though its stated context is backups:

> "The key issue is to put the backup data 'beyond use', even if it cannot be
> immediately overwritten. You must ensure that you do not use the data within
> the backup for any other purpose, ie that the backup is simply held on your
> systems until it is replaced in line with an established schedule."

The operative test is **non-use for any other purpose**. A retention that is
genuinely inert except for one narrowly defined check is closer to "beyond use"
than a live record; a retention that becomes a general-purpose identity graph is
not. That is a design constraint, not a slogan.

The ICO suppression-list guidance is treated separately in §3, because it is the
most cited and most misapplied authority in this area.

### 1.5 US: CCPA/CPRA, and a retention *obligation* nobody expects

The statutory text is quoted in §1.3. Two further points.

**§1798.105(c)(2) expressly authorises a suppression list**, in terms:

> "The business may maintain a confidential record of deletion requests solely
> for the purpose of preventing the personal information of a consumer who has
> submitted a deletion request from being sold, for compliance with laws or for
> other purposes, solely to the extent permissible under this title."

Note the double limitation: "solely for the purpose of" and "solely to the
extent permissible under this title." This authorises the honour-the-request
residue. It does not independently authorise a ban-evasion index; that has to
find its own home in §1798.105(d).

**The unexpected finding: US law is starting to *require* retention of
termination-for-cause records.** Seattle's App-Based Worker Deactivation Rights
Ordinance (Ord. 126878, effective 1 January 2025) requires network companies to
base deactivations on reasonable policies, give notice and records, and provide
human review; **records supporting a deactivation must be retained for at least
three years**, workers get access to them, a 90-day challenge window, and a
14-day review. Uber and Instacart challenged it on First Amendment grounds and a
divided Ninth Circuit panel rejected their appeal of a denied preliminary
injunction on 4 March 2026.

This cuts *against* deletion, and cleanly, for the termination-for-cause
category, since it is a §1798.105(d)(8) "comply with a legal obligation" hook, and in
the EU an Art. 17(3)(b) analogue would arise from any equivalent Member State
transposition. It is worth noting the direction of travel: the legal pressure to
keep deactivation records is coming from **worker-protective** legislation, and
its purpose is to let the worker contest the deactivation. That is a very
different retention than a blocklist, and it should be built as a different
thing: the worker's evidence, not the platform's weapon. Confidence: high on
the ordinance; medium on how many jurisdictions follow, though California,
Washington State, and several others have live proposals.

### 1.6 Philippines and India

These two turned out to be the most informative jurisdictions in the file, and
in opposite directions. **Correcting a prior assumption:** `07-synthesis.md`
treated the Philippines as the most hostile jurisdiction to any residue. On
primary reading that is wrong. The Philippines is the *most permissive* of the
four, since it is the only one with an express, enumerated list of grounds on which a
controller may refuse erasure, and the only one with a published regulator
opinion blessing a shared cross-employer fraud database. India is the opposite:
structurally hostile, but with a binary exemption that is stronger than anything
in GDPR when it applies.

#### Philippines (RA 10173): permissive, but with mandatory machinery

**The erasure right is proof-gated, not at-will.** Sec. 16(e) grants the right
to "[s]uspend, withdraw or order the blocking, removal or destruction" of
personal information, but only "**upon discovery and substantial proof**" that
the data are incomplete, outdated, false, unlawfully obtained, used for
unauthorized purposes, or no longer necessary. IRR Rule VIII Sec. 34(e) expands
the grounds to seven, adding the withdrawal/objection ground, but builds the
override into the text: erasure follows withdrawal or objection only where
"**there is no other legal ground or overriding legitimate interest for the
processing**." There is no free-standing "delete my account" entitlement in
Philippine law at all.

**NPC Advisory No. 2021-01 (Data Subject Rights), 29 January 2021, §10(B)(2)
answers this memo's question directly**, with an express list of grounds for
refusing erasure:

> "**A request for erasure or blocking may be denied, wholly or partly, when
> personal data is still necessary in any of the following instances:**
> a) Fulfillment of the purpose/s for which the data was obtained;
> b) Compliance with a legal obligation which requires personal data processing;
> c) Establishment, exercise, or defense of any legal claim;
> d) Legitimate business purposes of the PIC, consistent with the applicable
> industry standard for personal data retention; […]"

Two features matter for design. First, **"wholly or partly"** expressly
contemplates the exact shape proposed here: delete everything except a defined
minimum. Second, ground (d), "legitimate business purposes … consistent with the
applicable industry standard," is materially broader than anything in GDPR
Art. 17(3), and an industry standard is precisely what the ISSP precedent in
§2.1 supplies.

**And there is a direct precedent for this product.** NPC Advisory Opinion
No. 2023-026 (29 December 2023) addressed the creation of a **shared employee
fraud database** by an IT-BPO company with CIBI, a cross-employer negative
worker database, in a core market for this design. The NPC's conclusion:

> "the proposed sharing of data by an IT-BPO Company with CIBI can be considered
> processing for the purpose of establishing, exercising or defending a legal
> claim involving a fraudulent act."

with the retention condition stated as an obligation:

> "CIBI must retain only such personal data for as long as necessary or once the
> fulfillment of the declared purpose has been achieved, unless such retention is
> required by other laws. This means that there must be a retention policy
> regarding the personal data stored in the database."

Note the framing: **fraud**, characterised through the *legal claims* route, the
same Art. 17(3)(e) analogue identified in §1.1. Not performance.

**Fraud prevention is settled as a legitimate interest** under Sec. 12(f). NPC
Advisory Opinion No. 2021-026 (12 July 2021), addressing a BSP-proposed shared
database of blacklisted mule accounts, applied a three-part test: the processing
must be strictly for resolving or preventing fraud; only necessary and
proportionate data may be processed; and the data subject's rights must not be
overridden, assessed partly by whether the subject "had a reasonable expectation
at the time and in the context of the collection" that fraud-investigation
processing might occur. That last limb is a direct argument for **disclosure at
collection**, not at deletion.

**The constraints are real and are stated as obligations, not best practice:**

- **Blacklists carry mandatory rights machinery.** NPC AO 2017-063, importing
  the Article 29 Working Party's *Working document on Blacklists* (WP65), holds
  that "it is mandatory for an organization to clearly establish procedures that
  allow data subjects to exercise their right to access, rectification, erasure
  or blocking." A banned person must still be able to see and contest the record.
- **No indefinite retention.** IRR §19: "Personal data shall not be retained in
  perpetuity in contemplation of a possible future use yet to be determined."
- **You must explain the refusal.** Advisory 2021-01 §14 requires the data
  subject be "clearly and fully informed of the reason for the limitation or
  denial."
- **Doubt resolves against you.** §16: "Any doubt in the reasonableness of
  denying or limiting the exercise of data subject rights shall be liberally
  interpreted in a manner that would uphold the rights and interests of the data
  subject." And the NPC enforces §10(B)(2) as an exhaustive checklist with the
  burden on the controller, per *JBA v. FNT and NNT*, NPC 20-026 (22 Sept 2022):
  "none of the circumstances that would warrant a denial … are present. Thus,
  there is no reason for FNT to deny the request for erasure."
- **Do not rely on the investigation exemption.** Sec. 19 / IRR §37 disapply the
  rights chapter for "investigations in relation to any criminal, administrative
  or tax liabilities," but Advisory 2021-01 §13 conditions this on the
  investigation being "conducted by persons or entities duly authorized by law or
  regulation." A private operator's internal fraud review will not qualify. Use
  §10(B)(2)(c)/(d) instead.

**One genuine advantage: the Philippines has a de-identification pathway the
other regimes lack.** Sec. 3(g)/IRR §2 define personal information by reference
to identity being "reasonably and directly ascertained **by the entity holding
the information**", a controller-relative test narrower than the GDPR/India
"identifiable" standard. And IRR §19 states that "[p]ersonal data which is
aggregated or kept in a form which does not permit identification of data
subjects may be kept longer than necessary." NPC Advisory No. 2025-02 sets a
demanding bar for anonymisation, requiring data "irreversibly altered … either by
the PIC alone or in collaboration with any other party", which a hash of a
national ID number does not meet if anyone can recompute it. But the pathway exists on paper, which
is more than GDPR or DPDP offer.

Confidence: high on the statutory and IRR text; high on the advisory quotes,
with one process caveat: NPC PDFs were retrieved through a text-extraction
proxy because privacy.gov.ph blocks direct fetches, so spot-check in a browser
before relying on any of these quotes in a filing. **Important status point:
per NPC Circular 18-01, advisory opinions are expressly non-binding and not
precedent**, showing the regulator's thinking, not the rule.

#### India (DPDP 2023 + Rules 2025): no balancing, but a binary exemption

**There is no legitimate-interest basis to argue from.** Sec. 7 is a closed
enumerated list of "certain legitimate uses," and fraud prevention does not
appear in it. The nearest analogue, Sec. 7(i), processing "for the purposes of
employment or those related to safeguarding the employer from loss or liability,
such as prevention of corporate espionage, maintenance of confidentiality of
trade secrets…", is textually confined to the employment relationship with
employer-side examples. It will not carry a platform's anti-fraud processing
against its users. **The entire GDPR/PH-style balancing argument is structurally
unavailable in India.** This is the sharpest jurisdictional difference in the
memo.

**The erasure right.** Sec. 12(3): the fiduciary "shall erase her personal data
**unless retention of the same is necessary for the specified purpose or for
compliance with any law for the time being in force**." Sec. 8(7) imposes a
parallel erasure duty on withdrawal of consent, with a *narrower* exception:
only "compliance with any law," not "necessary for the specified purpose." Note
also Sec. 12(1): the right attaches only to data processed on consent (including
Sec. 7(a) deemed consent), so data processed under a Sec. 17 exemption is outside
the erasure right at the threshold.

**Sec. 17(1) is the escape, and it is unusually powerful.** It provides that
Chapter II (except ss. 8(1) and 8(5)), **all of Chapter III**, and s.16 "shall
not apply" where, among others:

> "(a) the processing of personal data is necessary for enforcing any legal
> right or claim;"
>
> "(c) personal data is processed in the interest of prevention, detection,
> investigation or prosecution of any offence or contravention of any law for
> the time being in force in India;"

Chapter III is sections 11–15, **which contains Sec. 12**. So where 17(1)(a) or
17(1)(c) applies, the erasure right does not yield to a balancing test; **it does
not apply at all.** That is more binary than anything in GDPR, and unlike the
Philippine equivalent it carries no express minimisation proviso. Two limits:
17(1)(c) requires a contravention of *Indian* law (though "contravention of any
law" is broader than criminal offence and reaches much regulatory and civil
fraud), and 17(1)(a) requires a genuine legal right or claim, not a general risk
posture.

**The Rules 2025 add a retention *floor* that survives account deletion.**
Notified 13 November 2025 (G.S.R. 846(E)). Rule 8(3) requires a fiduciary to
retain personal data, associated traffic data, and processing logs "**for a
minimum period of one year** from the date of such processing, for the purposes
as specified in the Seventh Schedule," expressed "without prejudice" to the
erasure duties. Its own illustration is explicit that this survives deletion:
the platform "must retain the order details, personal data, and logs … for at
least one year from the date of the transaction, **even if X deletes her
account.**" Scope it correctly, though: the Seventh Schedule lists **State**
purposes (sovereignty, integrity, security, State statutory functions), and the
floor exists to preserve data for Central Government information-calling powers
under Rule 23. It is a State-access preservation duty, not a general
business-records rule, but it is a hard floor, and it means "we erased
everything immediately" is not a lawful posture in India.

Rule 8(1) plus the Third Schedule impose an *inactivity* erasure clock (three
years) on large e-commerce, online gaming, and social media intermediaries, with
48 hours' advance notice under Rule 8(2). **Commencement:** Rules 3, 5–16, 22 and
23 come into force eighteen months after publication, i.e. around 13 May 2027;
Rule 4 (consent managers) around 13 November 2026. Rule 8 is not yet live.

**No de-identification safe harbour.** Sec. 2(t) defines personal data as data
"about an individual who is identifiable by or in relation to such data", broad
and not controller-relative. Full-text search of both the Act and the Rules
returns **zero** occurrences of "pseudonym," "anonymis/anonymiz," or "hash."
The Rules treat these techniques as *security measures*, not scope exits:
Rule 6(1)(a) requires "encryption, obfuscation, masking or the use of virtual
tokens **mapped to** that personal data." A token that maps back is still in
scope. A one-way hash of a phone number or ID number, trivially reversible by
dictionary attack over a small domain, will almost certainly remain personal
data in India.

Confidence: high, all quotes verified verbatim against the MeitY gazette PDFs
for both the Act and the Rules.

#### What the two jurisdictions imply together

The asymmetry is worth designing around. **India gives a stronger, more binary
exemption but no legitimate-interest basis and no de-identification safe harbour,
so anything retained must sit squarely inside Sec. 17(1)(a)/(c), and "it's
only a hash" is worth nothing.** **The Philippines gives an express denial ground
including a broad "legitimate business purposes … consistent with industry
standard" limb, plus a real de-identification pathway, but attaches mandatory
access/rectification machinery to any blacklist, forbids indefinite retention,
requires the refusal to be explained, and resolves doubt against the
controller.**

In both, the ground that works is fraud or a legal claim. In neither is there
anything a "poor performance" retention could attach to. The hypothesis holds in
all four jurisdictions surveyed.

### 1.7 The overlay nobody costs in: worker-specific instruments

Two instruments sit above general privacy law and are more dangerous to this
design than Art. 17 is.

**UK Employment Relations Act 1999 (Blacklists) Regulations 2010 (SI 2010/493).**
Enacted directly in response to the Consulting Association: a vetting service
holding records on over 3,200 construction workers, accessed by 40+ firms,
raided by the ICO in February 2009; its operator Ian Kerr was prosecuted for
failing to register as a data controller and fined £5,000 plus costs;
participating firms reportedly settled from 2014 for a total in the region of
£75 million. (Figures are as reported in the House of Commons Library briefing
and contemporaneous coverage; I could not retrieve the briefing PDF directly, so
treat the precise numbers as approximate, though the shape of the episode is not
in doubt.) The Regulations prohibit
compiling, using, selling, or supplying blacklists, and create employment
tribunal rights for refusal of employment or employment-agency services on
blacklist grounds.

The Regulations are formally confined to trade-union grounds, so they do not
directly prohibit a performance ledger. But treating that as reassurance is a
mistake. The instrument exists because a cross-employer negative-record database
on workers, sold as a vetting service, was found so objectionable that
Parliament legislated against the category. My inference, flagged as inference:
the reputational and political exposure here exceeds the legal exposure, and it
attaches to the *product*, not to the deletion policy. Confidence: high on
facts; my own read on the implication.

**EU Platform Work Directive (EU) 2024/2831**, transposition deadline 2 December
2026. It restricts what platforms may process about people performing platform
work via automated systems, including data on emotional or psychological state,
private conversations, data collected while the person is not working or seeking
work, and inference of protected characteristics, and requires human oversight
plus **reasons given for restricting access to an account**. That last
requirement bears directly on any automatic re-registration block: an automated
"you are flagged, application denied" is close to the paradigm case the Directive
targets. **Confidence: medium.** I could not reach the EUR-Lex primary text
(repeated fetch failures) and secondary sources disagree on article numbering.
Verify article numbers and exact wording before citing.

---

## 2. What platforms actually do

### 2.1 The best precedent: the Industry Sharing Safety Program

Launched March 2021 by Lyft and Uber, later joined by HopSkipDrive. It is the
closest existing thing to what this ledger proposes, a cross-platform negative
signal about deactivated workers, and every design choice in it is a
concession worth copying.

**Scope is severity-gated and tiny.** The founding companies share deactivation
information related to "the five most critical safety issues within the National
Sexual Violence Resource Center's Sexual Misconduct and Sexual Violence
Taxonomy, along with physical assault fatalities." Uber characterises these
incidents as "comprising less than one-thousandth of one percent of all trips."
There is no performance tier, no service-quality tier, no low-rating tier.

**It is intermediated by a regulated third party.** HireRight, an FCRA consumer
reporting agency, "collect[s] and manage[s] the data from individual companies,
match[es] and share[s] information between the companies, and ensures that each
company is abiding by best practices and industry standards." The platforms do
not hold each other's data.

**The intermediary holds a matching index, not a record.** Per HireRight's own
candidate-facing page, HireRight "receives only that data strictly needed for
cross-platform matching" and "does not have access to the complaints or report
details." A driver seeking the substance must "contact the contributing company
directly."

This is, structurally, the exact minimisation the EDPB's Article 5 package
demands: the matching capability and the narrative are held by different parties,
and the party that can match cannot explain. Confidence: high; published by all
three parties.

**Read-across for this design:** the industry's answer to cross-platform
reputation evasion was not "retain hashes for everyone and let purpose govern
use." It was "define a catastrophic-harm taxonomy, share only within it, hold
only the match key, and put a party with dispute obligations in the middle."

### 2.2 Same-platform re-registration blocking

Uber states it "has built technology to stop people who've been banned from Uber
from creating new accounts by detecting signups that use information, documents,
and photos connected to a deactivated account." Note the breadth: documents and
photos, not just a document hash. Uber has separately been reported to
fingerprint devices to detect fraud patterns including sign-up-bonus gaming, on
the logic that a device previously associated with fraud should raise a flag on
new sign-up.

eBay and Amazon both operate "related account" enforcement, suspending a second
account linked to an already-suspended one, and both permit multiple accounts
for legitimate purposes while prohibiting them for circumventing restrictions.
The prohibition is on *evasion*, not on multiplicity. **Confidence on mechanism:
low, and deliberately so.** The detailed linking-signal lists circulating for
both platforms (hardware IDs, MAC addresses, browser fingerprints, cookies, bank
details) come almost exclusively from suspension-appeal law firms and seller
consultancies marketing their own services, a genre with a direct commercial
incentive to overstate platform surveillance. Neither company's own policy text
confirms them. Do not build a threat model on those numbers.

### 2.3 What the privacy policies actually say

Every quote below was pulled from the live policy text. The striking finding is
how few platforms disclose the purpose they plainly pursue.

**Uber is the outlier that says it plainly, and its clause is the closest thing
to a drafted model in existence.** Privacy notice §II.F, identical in the rider
and driver notices:

> "Following an account deletion request, we delete your account and data,
> except as necessary for purposes of safety, security, fraud prevention or
> compliance with legal requirements… **For example, if you are banned from
> Uber's services because of serious fraudulent or unsafe behavior, Uber will
> retain your data after an account deletion request to prevent you from
> re-obtaining access to Uber's platform.**"

with the scope stated:

> "if we retain your data due to fraudulent behavior, we will retain the data
> relating to such behavior, and the data that we need to prevent you from
> further accessing Uber's platform, **which may include your account
> information, identity verification information, transaction data, and user
> content and communications data.**"

and a default: "We generally delete data within 90 days of an account deletion
request, except where retention is necessary for the above reasons." **This is
the only policy in the set that distinguishes voluntary from for-cause exit by
name, and note it gates on "serious fraudulent or unsafe behavior," not on
performance.** That is the §1.3 hypothesis, drafted into a shipped policy.

**Uber also documents the mechanism, and it is not device.** Driver notice
§II.B.2.b lists "**Cross-comparing user-submitted ID documents, profile photos
and selfies to detect for duplicate accounts and prevent previously deactivated
users from regaining access to our platforms**," and §II.C.3 describes automated
checks that a licence "is valid, unaltered, and **not associated with any other
account**." Device data appears in Uber's collection lists but is never named as
the re-registration key.

**Lyft refuses the deletion outright rather than retaining a residue**, a
different and arguably more honest architecture: "**we will be unable to delete
your account, such as if there is an issue with your account related to trust,
safety, or fraud.**… When we retain such data, we do so in ways designed to
prevent its use for other purposes." Again the gate is trust/safety/fraud, not
performance. No mechanism disclosed.

**Etsy discloses the tombstone to the user in plain language:** "**Please note
that closing your account may not free up your email address, username, or shop
name (if any) for reuse on a new account.**" Etsy also makes an unusual
disclosure about cross-marketplace signal sharing: fraud information "is
collected by us and/or our fraud vendors **who may also share fraud insights
with other companies, including other online marketplaces**", and names
Mastercard's Ekata as a vendor. Etsy's retention keys off "account closure"
generically, with customer-support records retained six years post-closure.

**DoorDash pushes the biometric gallery to a vendor**, which is architecturally
the most interesting choice in the set. Its Dasher notice describes Persona
comparing a new selfie's facial geometry "**to the biometric data generated from
other images or videos**" and performing "ongoing identity-verification and
fraud-prevention screenings," with deletion "within two years, whichever is
sooner." The 1:N re-registration search happens at Persona, not at DoorDash, and
carries a hard ceiling. DoorDash's own deactivation policy names the match keys
in the conduct rules: "creating multiple accounts for the same individual, or
**using the same personal information, such as a phone number**, as an account
already in use", and states that screening is re-run "whether at the time of
account creation or any time thereafter."

**The rest reserve a fraud hook without stating the purpose.** Fiverr is the
only one to name closed accounts as a retention category, retaining "personal
information from closed accounts **to comply with applicable laws, prevent
fraud**, collect any fees owed, resolve disputes… and **enforce our Site
terms**." Upwork names "**ongoing fraud prevention**" as a standing retention
purpose. eBay's erasure section carves out data "**no longer required for
overriding legitimate grounds, such as the detection/prevention of fraud**," and
notably describes restriction-in-place as its substitute for deletion: "As far
as legally permissible or required, **we restrict the processing of your data
instead of deleting it** (e.g. by restricting access to it)." Amazon's EU notice
(the US notice is materially thinner) retains data post-closure "for the
establishment, exercise, or defence of legal claims, and **for preventing
fraud/ensuring security**," keeping "limited personally identifying account
information following account closure in order to administer these rights and
obligations," with transactional data held ten years.

**Airbnb is the anti-pattern, and it is instructive.** Its Terms §12.5 state
that a suspended or terminated user "**may not register a new account**," and
§11.1 prohibits "creating a duplicate account." But its privacy policy §10
(Retention) contains no re-registration carve-out, no mention of banned users,
and no voluntary/for-cause distinction at all. Enforcing §12.5 necessarily
requires retaining something after termination. **A contractual ban on
re-registration with no matching disclosure in the privacy notice is precisely
the transparency gap that generates complaints**, and, per EDPB Guidelines
1/2024 para 106 and the NPC's reasonable-expectations limb (§1.6), it is the gap
that defeats the legal basis.

**Three conclusions from the comparative read:**

1. **The disclosure gap is the norm.** Eight of nine platforms enforce a
   re-registration ban, or plainly must to make their terms operative, while
   disclosing only a generic "fraud prevention" retention basis. Uber's §II.F is
   the model clause; Airbnb's §12.5-without-a-retention-clause is the anti-model.
2. **The durable match key is converging on identity documents and face
   biometrics, not device or IP.** Uber says so; DoorDash routes it through
   Persona; Etsy and Airbnb both collect facial geometry from ID and selfie.
   Device fingerprints and IPs appear in collection lists but are never named as
   the re-registration key, consistent with them being cheap to evade and
   legally exposed (device fingerprinting falls within Art. 5(3) ePrivacy per
   EDPB Guidelines 2/2023). **This vindicates the document-hash-only
   recommendation in §4.2 as industry-aligned, not merely conservative.**
3. **"Keep but neutralise" is the shape everyone converges on.** eBay restricts
   processing instead of deleting; Lyft retains "in ways designed to prevent its
   use for other purposes"; Amazon states the retained data is not used for
   marketing. Purpose isolation, not deletion, is the operative compliance
   mechanism.

Confidence: high on all quoted policy text (retrieved from live pages).
**Gaps:** Etsy's Persona help article, Amazon's Seller Central related-accounts
policy, and the Upwork/Fiverr suspension help pages are behind bot challenges
and were not read; reported figures circulating for Etsy biometric retention
(1 year) and ID retention (6 years post-closure) are **unverified**. Claims
about Amazon's linking mechanisms come exclusively from suspension-appeal
consultancies marketing their services and should not be relied on.

### 2.4 Cifas: the fully-worked version of this architecture

The UK's National Fraud Database is the most mature instance of what this ledger
would become, and its answer to the erasure problem is the most transferable
finding in the memo.

**Legal footing.** Cifas is a "specified anti-fraud organisation" under s.68 of
the Serious Crime Act 2007, which unlocks DPA 2018 Sch. 1 Pt. 2 para 14
("Preventing fraud") as the condition for the criminal-offence data a fraud
marker constitutes. Note that DPA 2018 s.11(2) extends Art. 10 to "the
**alleged** commission of offences," so a marker is Art. 10 data. Erasure is
switched off, where it is, by DPA 2018 Sch. 2 Pt. 1 para 2, whose "listed GDPR
provisions" expressly include **Art. 17(1) and (2)**, but only "**to the extent
that** the application of those provisions would be likely to prejudice" crime
prevention or detection. Prejudice-tested and purpose-limited, not blanket.

**Retention is a fixed clock, not a discretion.** Fraud markers: up to six years.
Victim-of-impersonation markers: 13 months. Protective Registration: two years.
Intelligence Service: 18 months.

**The evidential standard is the part worth copying.** NFD Principle 4
(Lawfulness / Standard of Proof) requires "reasonable grounds to believe that a
Fraud or Financial Crime has been committed or attempted"; that "the evidence
must be **clear, relevant and rigorous**"; and, critically, that the member
"must have **rejected, withdrawn or terminated a Product on the basis of
Fraud**." The internal handbook formulation, surfaced through Financial
Ombudsman decisions, is that the evidence must be such that "the member could
**confidently report the conduct of the subject to the police**." That is a
severity gate with teeth, and it is exactly the corroboration requirement §4.3
identifies as load-bearing.

**And the structural answer to erasure is architectural, not doctrinal.** Cifas
never pleads an Art. 17(3) exemption for the NFD. Instead: *Kunle Abayomi v
CIFAS* [2024] EWHC 3060 (KB) records at para 154 that "CIFAS… is the **joint
controller with the filing member** in relation to each marker that is filed,"
and Cifas routes challenges to the filing member: "First you must contact the
organisation/s that registered the warning… **If they uphold your complaint,
they can remove your details from our system.**" Cifas's own review "confirm[s]
whether it followed the right procedures." **Erasure is converted into an
accuracy challenge against the party that actually knows the facts, and the
discretionary deletion right is substituted with a guaranteed expiry clock.**

*Abayomi* also accepted at para 155 that, given Recital 47 and the Handbook rules
that "seek to balance the members' legitimate interests with the rights of data
subjects," the marker "constituted a **lawful processing of his data**." Weight
that carefully, since it was a strike-out of a poorly pleaded litigant-in-person claim
in which the Art. 6(1)(f) point was effectively unopposed, and the court
addressed neither Art. 10, nor the Schedule 1 conditions, nor Art. 17. **No
reported case squarely decides an Art. 17 claim against Cifas on the merits.**
An ICO FOI response (IC-377734-V6S1, 9 May 2025) records three ICO cases
involving Cifas, all resolved by "informal action taken", with no formal
enforcement.

**Read-across:** joint controllership with the attesting party, challenge routed
to that party, a fixed expiry clock instead of a deletion discretion, and a
"could confidently report to the police" evidential floor. That combination is
more defensible than anything this design could construct from Art. 17(3) alone.

---

## 3. The suppression-list pattern

### 3.1 What regulators actually blessed

The ICO's direct-marketing guidance is the canonical source, and it is
unambiguous that the pattern is permitted:

> "If someone no longer wants you to use their information for direct marketing,
> you should put their details onto a suppression or 'do not contact' list,
> instead of deleting them."

and it pre-empts the obvious objection:

> "Sometimes organisations are concerned that the law stops them from putting
> someone on a suppression list when they object. This is not correct. While you
> must not keep using someone's information for direct marketing purposes when
> they object, keeping a suppression list isn't for direct marketing purposes.
> You are keeping this list so that you can comply with your statutory
> obligations (ie to comply with their objection) and not for direct marketing
> purposes."

and it resolves the interaction with the erasure right explicitly:

> "Because we don't consider that a suppression list is used for direct marketing
> purposes, there is no automatic right for people to have their information on
> such a list deleted."

The ICO's worked example is a company that "stops using their information for
direct marketing and deletes all of it, apart from a small amount that it keeps
on its suppression list."

### 3.2 The distinction that kills the analogy

Read the ICO's reasoning carefully and the load-bearing element is not
minimisation and not hashing. It is **whose interest the residue serves**. The
suppression list survives the erasure right because its function is to *carry out
what the data subject asked for*. It is the mechanism of compliance, not an
exception to it. That is why there is no right to delete from it: deleting from
it would defeat the subject's own instruction.

A re-registration blocklist has the opposite polarity. Its function is to
frustrate what the data subject wants, on behalf of the controller and third
parties. It is minimal in the same way and hashed in the same way, and neither of
those similarities touches the ICO's actual reasoning.

CCPA §1798.105(c)(2) has the identical structure: the confidential record of
deletion requests is authorised "solely for the purpose of preventing the
personal information … from being sold," i.e. to honour the request.

**Conclusion, stated at high confidence on the guidance and medium-high on the
prediction:** suppression-list precedent does not carry over to ban evasion, and
a design memo that leans on it will be leaning on nothing. The ban-evasion case
has to be argued on its own merits: necessity under Art. 17(1)(a), overriding
grounds under Art. 21(1), the Art. 17(3)(e) legal-claims hook, and the
§1798.105(d)(2) security-and-integrity exemption. Those arguments are available.
The suppression analogy is not one of them.

### 3.3 Implementation shape, if you do it

Synthesising the EDPB Article 5 package (§1.1), the ICO "beyond use" test
(§1.4), and the HireRight structure (§2.1):

- **Stored:** a salted one-way hash of a single identifier. Not a set of
  identifiers: every additional identifier converts a check into an identity
  graph and makes the "beyond use" argument harder.
- **Not stored:** any payload. No reason code, no narrative, no employer, no
  date beyond what the retention clock needs. The HireRight design is the proof
  that match-without-narrative works.
- **Duration:** fixed, short, and justified against the specific risk. Indefinite
  retention fails storage limitation outright, and the EDPB called this out.
- **Segregation:** its own store with its own access control, not a flag on a
  tombstoned record, as the EDPB names segregation as an expected measure.
- **Access:** write-on-termination and read-on-registration only. No query
  interface, no export, no analytics, no vertical-facing read.
- **Purpose isolation, enforced structurally.** This is the single invariant
  across every instrument surveyed in §3.4: CPPA §7101(c)–(d), Colorado Rule
  6.11(F), CAN-SPAM, TCPA, CNIL, ICO all protect the residue *only* while it is
  used for nothing else. The store must not be joinable to production data. This
  is a stronger constraint than hashing and it is the one most likely to erode
  silently as the product grows.
- **Output:** a review signal, not an automatic denial. This is what keeps the
  Platform Work Directive's human-review requirement satisfiable and gives the
  worker something to appeal.
- **Disclosure:** at collection, in the privacy notice, in terms, not disclosed
  for the first time in the deletion confirmation. The Art. 13 duty runs at
  collection, and a residue the user learns about only when they try to leave is
  the fact pattern that generates complaints.
- **Documentation:** a written balancing assessment per the EDPB recommendation,
  produced at the time and retained.

### 3.4 The suppression pattern is legally distinct from an exclusion list, and regulators have said so with money

Two clusters of authority exist, and they are not the same object.

**Cluster A: suppression lists (pro-subject).** Regulators mandate, encourage, or
immunise them.

- **TCPA, 47 C.F.R. §64.1200(d)(6)** is a retention *mandate*: "A person or
  entity making artificial or prerecorded-voice telephone calls… **must maintain
  a record of a consumer's request not to receive further calls. A do-not-call
  request must be honored for 5 years from the time the request is made.**"
  National DNC registrations "must be honored indefinitely."
- **Colorado CPA Rules** are the cleanest US drafting. Rule 4.06(D) directs a
  controller to comply with deletion by "**retaining a record of the deletion
  request and the minimum data necessary for the purpose of ensuring the
  Consumer's Personal Data remains deleted… and not using such retained data for
  any other purpose**." Rule 6.11(F) then immunises it: such data "**shall not be
  subject to Data Rights requests.**"
- **CPPA regulations** split the duties: §7101(a) makes a 24-month request log
  *mandatory*; §7022(e) makes suppression use *permissive*: "may retain a record
  of the request for the purpose of ensuring that the consumer's personal
  information remains deleted from its records", and imposes a duty to **tell
  the consumer** you are keeping it. §7101(c)–(d) protect the record only "where
  that information is not used for any other purpose."
- **CNIL** endorses a hash-only implementation: keep "**que les empreintes de
  l'adresse ou du numéro**" rather than a nominative list, with a **three-year
  minimum**, a floor, not a cap. And it states the obvious corollary: "**ces
  données hachées restent des données personnelles.**"
- **Germany's DSK** supplies the most articulate legal theory anywhere: a
  *Werbesperrdatei* is permissible under "**Art. 21(3), Art. 6(1)(f) in
  conjunction with Art. 17(3)(b)**", meaning the Art. 17(3)(b) legal-obligation
  limb, because honouring the objection *is* the legal obligation. Note the DSK
  narrowed this between its 2018 and 2022 editions from "are permissible" to
  "can be permissible."

**Cluster B: exclusion and fraud blacklists (adverse). Here regulators impose
hard caps, mandatory DPIAs, sectoral confinement, and fines.**

**The on-point enforcement action is Spanish.** AEPD, PS/00215/2024: €100,000
reduced to €80,000, Art. 6(1) infringement, against Goldcar for refusing a car
rental in 2021 on the basis of an internal alert flag from a 2018 contract:

> "Goldcar's actions amount to the creation of a '**customer blacklist**' —
> processing which **is not covered by the contractual relationship, inasmuch as
> it does not end with the expiry of the contract but continues for a different
> purpose; and it requires another legal basis to legitimise it**, as well as
> compliance with all GDPR principles and safeguards (transparency, purpose
> limitation, data minimisation, storage limitation, etc.)."

and, decisively for the §1.3 hypothesis:

> "Particular account is taken of the fact that **the information retained does
> not refer with certainty to a fraud committed by the claimant**, and of the
> harm or discriminatory effects the processing causes him."

The AEPD did **not** hold exclusion lists unlawful per se. Instead, it
contrasted Goldcar's with statutorily grounded credit-information systems, "whose
regulation
expressly establishes the objective factual circumstances that determine the
entry… as well as the need to inform in advance about the possibility of
recording the data." **Read that as the checklist: objective published entry
criteria, prior notice, and certainty that the triggering conduct actually
occurred.** A flag that does not "refer with certainty to a fraud" is what got
fined.

**CNIL's exclusion référentiel (délibération 2021-130, unpaid commercial debts)**
authorises "**l'identification des personnes en situation d'impayé aux fins
d'exclusion pour toute transaction à venir**", but caps retention at **five
years**, requires deletion "**dans les 48 heures**" once the debt is settled,
requires a contract basis if the exclusion is fully automated (Art. 22(2)(a)),
and **expressly excludes from its scope "le partage ponctuel et/ou la
mutualisation des données… avec des tiers"**. The French regulator authorised a
single-controller exclusion register and specifically declined to authorise a
mutualised one. That is a direct warning for a cross-vertical design. CNIL's
older banking anti-fraud instrument, AU-054, set 12 months to qualify an alert
and **five years** from entry on a confirmed-fraudster list (status post-2018
unverified, so do not cite as currently binding).

**Denmark's Datatilsynet** (Coolshop.dk, J.No. 2020-31-3060) held that a retailer
"**cannot omit to delete** the complainant's customer account based on Article
17(3)(b)". Only the statutorily mandated bookkeeping records could remain, and
the account had to be genuinely destroyed. That cuts against convenience-based
tombstoning.

**The doctrinal conclusion.** Regulators treat suppression lists and exclusion
lists as different legal objects: the first pro-subject, minimum-floor,
hashing-encouraged; the second adverse, hard-capped, DPIA-mandatory,
sectorally confined, requiring prior notice and objective entry criteria. **A
ledger retaining a record to enforce a ban will be assessed as the second.**
Confidence: high, given the consistent shape across AEPD, CNIL, DSK, and the
Danish decision.

**And the single invariant across every instrument in both clusters is purpose
isolation, not retention length.** CPPA §7101(c)–(d); Colorado Rule 6.11(F)–(G);
CAN-SPAM 15 U.S.C. §7704(a)(4)(A)(iv) ("for any purpose other than compliance
with this chapter"); TCPA §64.1200(c)(2) (National DNC data used "for no purpose
except compliance"); CNIL ("ne peuvent en aucun cas être utilisées à d'autres
fins"); ICO ("clearly marked so you don't use it"). **A suppression or exclusion
store that is joinable to production data loses its protection under all of them
simultaneously.** That is the hardest architectural constraint in this memo, and
it is stricter than "hash it."

**Verified negatives.** The EDPB has never addressed suppression lists: a
full-text search of Guidelines 1/2024 and 01/2025 for *suppress*, *do not
contact*, *opt-out list*, and *blacklist* returns zero hits, and the February
2026 erasure report has no substantive hits for *suppress*, *re-registration*,
*blacklist*, *ban*, or *hash*. The Irish DPC's published erasure case-study index
contains nothing on re-registration blocking. No decision was found anywhere
squarely adjudicating a post-erasure *re-registration* blocklist specifically.
Goldcar is the closest, and it is about refusing service, not about resisting an
erasure request. **Coverage caveat:** GDPRhub was inaccessible throughout
(proof-of-work bot wall), so DPA case-law coverage is materially incomplete and
the "no decision found" finding is weaker than it would otherwise be.

---

## 4. Bottom line for this design

### 4.1 The structural fact that should drive the answer

The prompt's framing is correct and is the strongest argument in the file:
verticals keep their own local work records regardless, so ledger deletion
removes only **cross-vertical portability of a negative signal**, never the
original employer's own knowledge.

This means deletion destroys no evidence. The employer who terminated the worker
still knows, still holds their records, and can still answer a reference call.
What deletion removes is *amplification*: the broadcast of a negative signal to
parties who have no relationship with the worker and no ability to assess it in
context.

That reframing matters for two reasons. **Legally**, amplification is the
interest regulators protect most fiercely and controllers justify least well;
Art. 21 balancing goes badly for a controller whose asserted interest is
"continued ability to disadvantage this person with strangers." **Practically**,
it means the marginal safety cost of permissive deletion is far lower than
intuition suggests: the worker who deletes and re-registers has not escaped
their history with the employer who holds it, only with employers who never knew
it.

### 4.2 Where the line should sit

**Hold decision 009 as the default. Carve exactly one exception.**

**Full erasure, no residue, no exceptions: voluntary exit and
performance-based exit.** This covers the overwhelming majority of deletions. It
is the right answer in every regime surveyed, it is the answer the worker-owned
positioning (ruling R1) commits to, and it is the answer the amplification
analysis supports. Do not build a "poor performance" retention path; there is no
legal basis for it in California's closed list, it loses the Art. 21 balance, and
it is the fact pattern the Blacklists Regulations were written about.

**A narrow, gated residue: verified fraud against the ledger's integrity, or a
serious safety finding.** Specifically:

- **Trigger taxonomy is published and closed.** Forged documents, identity
  substitution, attestation collusion; and a defined serious-safety category.
  Follow the ISSP precedent and borrow an external taxonomy rather than writing
  your own: an external taxonomy is a defence, a self-written one is an
  admission of discretion.
- **One identifier only**: a salted hash of the government-document number.
  Not phone (changes, shared, reassigned), not device (over-broad, catches
  households and shared equipment, and is the mechanism most likely to be
  characterised as covert tracking).
- **No payload.** Match key only, HireRight-style.
- **Fixed retention**, set against the specific risk, not indefinite.
- **Output is manual review, never automatic denial.**
- **Disclosed at collection**, not at deletion.
- **Human-reviewable appeal**, and the worker can see that they are flagged.

Note this is **narrower than Uber's published practice**, which matches on
"information, documents, and photos" and retains "account information, identity
verification information, transaction data, and user content and communications
data." But it is *aligned* with the industry's actual match key: no platform in
§2.3 names device or IP as the re-registration signal. The convergence is on
identity documents and face biometrics. Excluding device is therefore
conservative on paper and conventional in practice, and it avoids the Art. 5(3)
ePrivacy exposure that device fingerprinting attracts under EDPB Guidelines
2/2023. The remaining restraint relative to Uber is intentional: those platforms
are first-party marketplaces protecting their own transactions; this ledger is a
cross-vertical identity layer whose entire value proposition is that the worker
owns the record. The asymmetry of trust it is asking for should be matched by an
asymmetry of restraint.

**Copy four things from Cifas, which has run this architecture longest.** (i)
**Joint controllership with the attesting vertical** for each flag, so the party
that knows the facts carries the accuracy duty. (ii) **Route challenges to that
party**, converting an erasure fight into an accuracy fight the ledger is not
positioned to win or lose. (iii) **A fixed expiry clock instead of a deletion
discretion**: Cifas's six years for fraud markers, thirteen months for
impersonation. A guaranteed expiry is worth more to a worker than a contestable
right, and it satisfies storage limitation by construction. (iv) **An evidential
floor stated as a rule**: Cifas requires "clear, relevant and rigorous" evidence
such that the member "could confidently report the conduct of the subject to the
police," and requires that the member actually terminated on the basis of fraud.
That is the corroboration requirement §4.3 identifies as load-bearing, already
drafted.

**And satisfy the Goldcar checklist explicitly**, because it is the only
enforcement action on point: objective published entry criteria; prior notice at
collection; and certainty that the triggering conduct occurred. The AEPD fined
Goldcar in significant part because the retained flag "does not refer with
certainty to a fraud committed by the claimant."

**Strongly consider the intermediated variant.** The ISSP structure, in which a
third party holds the match key, the platforms hold the narrative, and the third
party cannot explain what it matched, solves several problems at once: it keeps
the
ledger out of the position of holding a covert negative index, it makes the
*EDPS v SRB* relative-identifiability argument available to the verticals
receiving the signal, and it puts dispute obligations somewhere they can be
discharged. It is more expensive and slower. It is also what the only comparable
system in existence actually did, after presumably better legal advice than this
memo.

**Frame the justification as a legal claim, not as fraud prevention.** This is a
drafting point with real consequences. "Establishment, exercise or defence of
legal claims" is a genuine *exemption* in GDPR Art. 17(3)(e), an enumerated
denial ground in NPC Advisory 2021-01 §10(B)(2)(c), and a wholesale
Chapter III disapplication in India's DPDP Sec. 17(1)(a), and it is the route
the Philippine regulator itself chose when blessing a shared employee fraud
database (AO 2023-026). "Fraud prevention," by contrast, is a *legal basis*
statement (GDPR Recital 47, PH Sec. 12(f)) that still has to win a balancing
test, and has no home at all in India's closed Sec. 7 list. The same retention,
justified two ways, has materially different survival odds across the four
markets. Confidence: high on the statutory mapping; this is exactly the point
to put to counsel first.

**Three things to build regardless of where the line lands.** First,
deactivation records for the worker's benefit: the Seattle ordinance requires
three-year retention with worker access and a challenge window, and that trend
is running toward you, not against you. Build it as the worker's evidence.
Second, an honest distinction in the UI and the policy between "delete my
account" and "erase my personal data," which the EDPB specifically flagged as
poorly understood. Third, **a retention floor, because "we erase everything
immediately" is not a lawful posture everywhere.** India's DPDP Rule 8(3)
imposes a one-year minimum on personal data, traffic data, and processing logs
that expressly survives account deletion, for State-access preservation under
the Seventh Schedule; it commences around May 2027. The design needs a
per-jurisdiction retention floor as first-class schema, not a global "delete
means gone" invariant.

### 4.3 The strongest counter-argument to my own recommendation

**The fraud/performance line is clean in law and filthy in operations, and I am
relying on it to do work it may not be able to do.**

The recommendation turns entirely on classifying why an account ended. But that
classification is made by the platform or the vertical, the party with an
interest in the outcome, and is not independently reviewed. Three failure modes
follow, and they compound:

**Relabelling.** If "fraud" retains and "performance" does not, every
termination a vertical wants to make sticky will be labelled fraud. This is not
speculative; it is the observed behaviour of every system that attaches
consequences to a severity label, and `06-adversarial-threat-model.md` already
identifies employer collusion and retaliation as the top underweighted risk. The
legal distinction I am relying on becomes a naming convention.

**The category genuinely blurs.** A worker who consistently misreports hours is
performing badly and defrauding. A safety incident arising from negligence is a
performance failure and a safety finding. The taxonomy does not carve reality at
its joints, and adversarial parties will exploit exactly the seam.

**And the honest version of the objection is stronger still: the case I am
carving out is the case where a wrongly-terminated worker most needs deletion.**
A fraud or safety label is the most damaging thing that can attach to a worker,
the hardest to disprove, and the most likely to be applied in retaliation. By
scoping the residue to precisely those labels, I have built a mechanism that is
least escapable exactly where escape is most often justified, and I have done it
in a system whose stated premise (ruling R1) is that the worker owns the record.

The disciplined response is that this is an argument for **procedural
constraints on the label**, not for abandoning the carve-out: the trigger
taxonomy should be closed and external, a fraud or safety designation should
require corroboration rather than a single vertical's assertion, the flag should
produce review rather than denial, and the worker should be able to see and
contest it. But I should be straight that those constraints are load-bearing
rather than decorative: **if they cannot be built and enforced, the correct
answer is decision 009 unamended: no residue at all, ever, and accept the
fresh-start losses.** Given that the amplification analysis in §4.1 shows those
losses are smaller than they feel, that fallback is more defensible than it
first appears, and I would not fight hard against a founder who chose it.

---

## Sources

**Primary law**
- GDPR Art. 17 — https://gdpr-info.eu/art-17-gdpr/
- GDPR Recital 47 — https://gdpr-info.eu/recitals/no-47/
- GDPR Recital 65 — https://gdpr-info.eu/recitals/no-65/
- GDPR Art. 21 — https://gdpr-info.eu/art-21-gdpr/
- CCPA/CPRA Cal. Civ. Code §1798.105 — https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.105.
- Cal. Civ. Code §1798.140(ac) ("security and integrity") — https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.140.
- Employment Relations Act 1999 (Blacklists) Regulations 2010, SI 2010/493 — https://www.legislation.gov.uk/uksi/2010/493/contents/made
- Philippines, RA 10173 (Data Privacy Act 2012) — https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html
- DPA Implementing Rules and Regulations — https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/70735 · https://www.officialgazette.gov.ph/2016/08/25/implementing-rules-and-regulations-of-republic-act-no-10173/
- India, Digital Personal Data Protection Act 2023 (MeitY gazette) — https://www.meity.gov.in/static/uploads/2024/06/2bf1f0e9f04e6fb4f8fef35e82c42aa5.pdf
- India, DPDP Rules 2025, G.S.R. 846(E), 13 Nov 2025 (MeitY gazette) — https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf
- Directive (EU) 2024/2831 (Platform Work) — https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX:32024L2831 *(primary text unreachable at time of writing; article numbering unverified)*
- Seattle Ordinance 126878, App-Based Worker Deactivation Rights — https://www.seattle.gov/laborstandards/ordinances/app-based-worker-ordinances

**Regulator guidance and enforcement**
- EDPB, *2025 Coordinated Enforcement Action: Implementation of the Right to Erasure* (adopted; published Feb 2026) — https://www.edpb.europa.eu/system/files/2026-02/edpb_cef-report_2025_right-to-erasure_en.pdf
- EDPB press release on the same — https://www.edpb.europa.eu/news/edpb-identifies-challenges-hindering-the-full-implementation-of-the-right-to-erasure_en
- ICO, *Right to erasure* — https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-erasure/
- ICO, *Direct marketing guidance: Respect people's preferences* (suppression lists) — https://ico.org.uk/for-organisations/direct-marketing-and-privacy-and-electronic-communications/direct-marketing-guidance/respect-peoples-preferences/
- NPC (PH) Advisory No. 2021-01, *Data Subject Rights*, 29 Jan 2021 — https://privacy.gov.ph/wp-content/uploads/2026/05/SGD-Advisory-DS-Rights-29-Jan-2021.pdf
- NPC (PH) Advisory Opinion No. 2021-026 (shared database of blacklisted mule accounts) — https://privacy.gov.ph/wp-content/uploads/2022/01/Redacted-Advisory-Opinion-No.-2021-026.pdf
- NPC (PH) Advisory Opinion No. 2017-063 (blacklists; imports A29WP WP65) — https://privacy.gov.ph/wp-content/uploads/2022/01/NPC_AdvisoryOpinionNo._2017-063.pdf
- NPC (PH) Advisory Opinion No. 2018-039 (right to erasure vs. retention, former employees), 2018 Compendium pp. 164–168 — https://privacy.gov.ph/wp-content/uploads/2023/05/compendium_2018_1519.pdf
- NPC (PH) Advisory Opinion No. 2023-026 (shared employee fraud database, IT-BPO/CIBI) — via privacy.gov.ph advisory opinions index
- NPC (PH) Advisory No. 2025-02, *Privacy Engineering in Systems Life Cycle Processes* — https://privacy.gov.ph/wp-content/uploads/2025/12/NPC_Advisory2025-02.pdf
- NPC (PH) decision, *JBA v. FNT and NNT*, NPC 20-026, 22 Sept 2022
- *Status note:* per NPC Circular 18-01, NPC advisory opinions are expressly non-binding and are not precedent. privacy.gov.ph blocks automated fetches; the NPC PDFs above were read through a text-extraction proxy, verbatim but worth a manual browser spot-check before any load-bearing use.

- EDPB Guidelines 1/2024 on Art. 6(1)(f) legitimate interest (consultation version, adopted 8 Oct 2024; no final published) — https://www.edpb.europa.eu/system/files/2024-10/edpb_guidelines_202401_legitimateinterest_en.pdf
- EDPB Guidelines 01/2025 on Pseudonymisation (consultation version, adopted 16 Jan 2025; predates and is in tension with C-413/23 P) — https://www.edpb.europa.eu/system/files/2025-01/edpb_guidelines_202501_pseudonymisation_en.pdf
- EDPB Guidelines 2/2023 on the technical scope of Art. 5(3) ePrivacy (device fingerprinting) — https://www.edpb.europa.eu/system/files/2023-11/edpb_guidelines_202302_technical_scope_art_53_eprivacydirective_en.pdf
- Art. 29 WP Opinion 05/2014 on Anonymisation Techniques (WP216) — https://ec.europa.eu/justice/article-29/documentation/opinion-recommendation/files/2014/wp216_en.pdf
- AEPD–EDPS, *Introduction to the hash function as a personal data pseudonymisation technique* (Oct 2019) — https://www.edps.europa.eu/sites/default/files/publication/19-10-30_aepd-edps_paper_hash_final_en.pdf
- ICO, *Right to object* — https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/individual-rights/right-to-object/
- ICO, *Deleting personal data* (DPA 1998-era; "put beyond use" four conditions; withdrawn from the live site) — https://web.archive.org/web/20220120094421if_/https://ico.org.uk/media/1475/deleting_personal_data.pdf
- CNIL, *Comment utiliser une liste repoussoir* (hash-only suppression, 3-year minimum) — https://www.cnil.fr/fr/comment-utiliser-une-liste-repoussoir-pour-respecter-lopposition-la-prospection-commerciale
- CNIL, délibération n° 2021-130, référentiel *gestion des impayés dans une transaction commerciale* — https://www.cnil.fr/sites/default/files/atoms/files/referentiel_traitements-donnees-caractere-personnel_gestion-impayes_transaction_commerciale.pdf
- CNIL, délibération n° 2017-217 (AU-054, banking anti-fraud; post-2018 binding force unverified) — https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000035268554
- DSK (Germany), *Orientierungshilfe … Direktwerbung*, Feb 2022, §5.1 — https://www.datenschutzkonferenz-online.de/media/oh/OH-Werbung_Februar%202022_final.pdf
- CPPA regulations, 11 C.C.R. div. 6 (§§7022(e), 7025(c)(2), 7101) — https://cppa.ca.gov/regulations/
- Colorado Privacy Act Rules, 4 C.C.R. 904-3 (Rules 4.06(D), 6.11) — https://coag.gov/app/uploads/2023/03/FINAL-CLEAN-2023.03.15-Official-CPA-Rules.pdf
- TCPA implementing rules, 47 C.F.R. §64.1200 — https://www.ecfr.gov/current/title-47/chapter-I/subchapter-B/part-64/subpart-L/section-64.1200
- CAN-SPAM, 15 U.S.C. §7704(a)(4)(A)(iv) — https://uscode.house.gov/view.xhtml?req=granuleid:USC-prelim-title15-section7704&num=0&edition=prelim
- Spain, LOPDGDD (Ley Orgánica 3/2018) Arts. 20, 23 — https://www.boe.es/buscar/act.php?id=BOE-A-2018-16673

**Enforcement decisions and case law**
- CJEU, Case C-413/23 P, *EDPS v SRB*, 4 September 2025 (CELEX 62023CJ0413) — https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:62023CJ0413 · press release https://curia.europa.eu/site/upload/docs/application/pdf/2025-09/cp250107en.pdf
- General Court, T-557/20, *SRB v EDPS*, 26 April 2023 (partially set aside)
- **AEPD, PS/00215/2024 (Goldcar), €100,000 reduced to €80,000 — customer blacklist** — https://www.aepd.es/documento/ps-00215-2024.pdf
- Datatilsynet (DK), J.No. 2020-31-3060 (Coolshop.dk), 18 Nov 2020 — https://www.edpb.europa.eu/system/files/2021-08/dk_2020-11_right_to_erasure_decisionpublic_redacted.pdf
- *Kunle Abayomi v CIFAS* [2024] EWHC 3060 (KB), 29 Nov 2024 — https://caselaw.nationalarchives.gov.uk/ewhc/kb/2024/3060
- Commentary on SRB: https://fpf.org/blog/rethinking-personal-data-the-cjeus-contextual-turn-in-edps-vs-srb/ ; https://www.twobirds.com/en/insights/2025/eu-the-srb-decision-a-new-era-for-personal-data-and-data-processing-agreements

**Cifas / UK National Fraud Database**
- Cifas Fair Processing Notice (retention periods) — https://www.cifas.org.uk/fpn
- Cifas National Fraud Database Legitimate Interests Assessment — https://www.cifas.org.uk/national-fraud-database-legitimate-interests-assessment
- Cifas NFD Principles (Principle 4, standard of proof) — https://www.cifas.org.uk/fraud-prevention-community/member-benefits/data/nfd/nfd-principles
- DPA 2018 Sch. 1 Pt. 2 para 14 ("Preventing fraud") — https://www.legislation.gov.uk/ukpga/2018/12/schedule/1/part/2/enacted
- DPA 2018 Sch. 2 Pt. 1 para 2 (crime and taxation; disapplies Art. 17(1)–(2)) — https://www.legislation.gov.uk/ukpga/2018/12/schedule/2/part/1/enacted
- DPA 2018 s.11(2) (alleged offences) — https://www.legislation.gov.uk/ukpga/2018/12/section/11/enacted
- ICO FOI response IC-377734-V6S1, 9 May 2025 (three Cifas cases, informal action only) — https://ico.org.uk/media2/fc1nkmtm/our-response-to-ic-377734-v6s1.pdf

**Platform practice**
- Industry Sharing Safety Program launch — https://www.businesswire.com/news/home/20210311005782/en/
- Lyft on the ISSP — https://www.lyft.com/blog/posts/lyft-and-uber-launch-industry-sharing-safety-program-in-the-us
- Uber on the ISSP — https://www.uber.com/us/en/newsroom/industry-sharing-safety/
- HireRight candidate FAQ on the ISSP — https://support.hireright.com/en-US/articles/what-is-the-industry-sharing-safety-program
- Uber on background checks and blocking banned-user re-registration — https://www.uber.com/us/en/newsroom/background-checks/
- Uber device fingerprinting reporting — https://the-parallax.com/uber-device-fingerprinting/
- eBay account restrictions and suspensions — https://www.ebay.com/help/account/account-holds-restrictions-suspensions/account-holds-restrictions-suspensions?id=4190

**Platform privacy policies (retention sections; all quoted from live text)**
- Uber, Drivers/Delivery People privacy notice — https://www.uber.com/global/en/privacy-notice-drivers-delivery-people/
- Uber, Riders/Order Recipients privacy notice — https://www.uber.com/global/en/privacy-notice-riders-order-recipients/
- Lyft privacy policy — https://www.lyft.com/privacy
- Airbnb privacy policy — https://www.airbnb.com/help/article/3175 · Terms of Service §12.5 — https://www.airbnb.com/help/article/2908
- eBay User Privacy Notice §§7, 8 — https://www.ebay.co.uk/help/policies/member-behaviour-policies/user-privacy-notice-privacy-policy?id=4260
- Etsy privacy policy (PDF mirror) — https://storage.googleapis.com/etsy-extfiles-prod/Privacy%20Policy_en_US.pdf
- DoorDash Dasher privacy policy — https://help.doordash.com/en-us/legal/article/dx-privacy-policy · Deactivation policy — https://help.doordash.com/en-us/legal/article/dx-deactivation-policy
- Upwork privacy policy — https://www.upwork.com/legal#privacy
- Fiverr privacy policy — https://www.fiverr.com/legal-portal/privacy/privacy-policy
- Amazon (EU) privacy notice, data retention section — https://www.amazon.ie/gp/help/customer/display.html?nodeId=GX7NJQ4ZB8MHFRNJ *(the US notice has no equivalent retention section)*

**Blacklisting precedent**
- House of Commons Library, *Trade unions: blacklisting* — https://commonslibrary.parliament.uk/research-briefings/SN06819/

**Academic**
- Friedman & Resnick, "The Social Cost of Cheap Pseudonyms," *Journal of Economics & Management Strategy* 10(2) (2001) — https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1430-9134.2001.00173.x

---

## Coverage gaps and verification caveats

Stated plainly so the next reader knows what this memo does not cover.

- **GDPRhub was inaccessible throughout** (proof-of-work bot wall). DPA case-law
  coverage is materially incomplete, which weakens the "no decision found on
  post-erasure re-registration blocklists" finding in §3.4 from a negative
  finding to an unsuccessful search.
- **EUR-Lex primary text was unreachable** for the Platform Work Directive.
  §1.7's article numbering and wording are from secondary sources that disagree
  with each other. Verify before citing.
- **privacy.gov.ph blocks automated fetches.** All NPC quotes in §1.6 came
  through a text-extraction proxy reading the official PDFs, verbatim but
  machine-extracted. Spot-check in a browser before any load-bearing use. Note
  also that NPC advisory opinions are expressly non-binding (Circular 18-01).
- **Cloudflare-gated and unread:** Etsy's Persona identity-verification help
  article (reported to state 1-year biometric and 6-year ID retention with an
  explicit multiple-account-blocking rationale, **unverified**), Amazon Seller
  Central's related-accounts policy, and the Upwork/Fiverr suspension help pages.
- **Not researched:** the Amsterdam Court of Appeal 2023 rulings against Uber on
  automated deactivation (Art. 22), which are the most likely place to find a
  platform defending fraud-detection retention on deactivated drivers in
  litigation. Flagged as the highest-value next thread.
- **Not retrieved:** the Italian Garante's SIC Code of Conduct retention annex;
  the FTC's 2008 CAN-SPAM Statement of Basis and Purpose; the NPC 2020–2021
  Compendium (text extraction failed).
- **Draft-status instruments relied on:** EDPB Guidelines 1/2024 and 01/2025 are
  both still public-consultation versions with no final published text, and
  01/2025 para 22 is now in open tension with C-413/23 P. The ICO's "put beyond
  use" four conditions are DPA 1998-era and not reproduced in current UK GDPR
  guidance. CNIL AU-054's post-2018 binding force is unverified.
- **Consultancy-sourced claims deliberately excluded:** detailed account-linking
  mechanism lists for eBay and Amazon circulate widely but originate almost
  entirely from suspension-appeal firms marketing their services. They are not
  relied on anywhere in this memo.
