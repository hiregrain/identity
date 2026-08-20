# Grain: thesis

**Status: draft, 2026-08-18.** This is the topline vision for the identity
layer. Where a plan disagrees with it, the plan is flagged: usually the plan
changes, occasionally the thesis does. It is early and much is not fleshed out;
gaps are marked **[GAP]** and collected in §10, and they are the work queue.

Scope is the identity layer. Dispatch holds its own thesis, aligned with this
one. `handoff/founder-thesis.md` is stale and superseded on the points where
the two differ.

The rulings behind this file are recorded as decisions **021–026**. Where a
statement here supersedes ratified material, the assessment argument in §5,
the attester-trust mechanism in §4, the superseding entry is named at the
point of use. Items left open are marked **[GAP]** and are ruled nowhere; do
not cite them as settled.

---

## TLDR

**Grain is the trust layer that replaces the résumé.** A portable,
worker-owned, cryptographically verifiable record of what a person has
actually done, attested by the parties that observed it, visible to whoever
the worker permits.

**Identity is the platform.** The résumé is a summary statistic. It transmits
employer, title and dates, and it abstracts away the particulars that
determine the specific decision a reader is making: what the conditions were,
what this person's surface actually was, how much of the work was theirs, how
it ended. Grain's function is that those particulars survive transmission,
recorded by the party that observed them, at the time they observed them.
Legibility follows from that, and where the two conflict the particular wins.
Endpoints let partners and
internal verticals read and write against it. An internal training program
should be able to see where someone starts and write back how they performed.
Everything else is secondary to that core.

**The record layer is free to everyone, permanently**, candidates and
employers alike (decision 024). The compiled data is the asset, not access to
it.

**Analytics on a person's work history and trajectory is the first product,
and it ships from day one** (decision 022). It runs on partially verified history plus
whatever else exists: skills assessments, course performance, structured
references, and observable meta-signals like tenure in role, described
responsibility, and seniority. Every input is weighted by its provenance
class. Early output is weak, and says so. Below a trust threshold it returns
insufficient data and suggests an assessment rather than a number.

**Comparability comes from standardising what is recorded, not from
normalising what is scored.** Four channels are comparable across every party:
work kind, volume, responsibility level, and outcome facts. Quality stays
party-local and labelled. Grading never runs on other parties' quality scores,
because those are incomparable by construction and grading on them would
launder other employers' judgments rather than produce independent
intelligence.

**Contested, and stated here rather than buried.** Selling capability
projections to employers moves the not-a-CRA position (R1, decision 003) from
theoretical to load-bearing; counsel brief 4 is drafted and unsent. Under the
EU AI Act the analytics product is high-risk with no derogation available,
because profiling forecloses the decision-support escape, Grain builds with
that in mind but does not build for it first. Portability itself is what
approaches the social-scoring prohibition, and portability is the product.
Workers do not see when analytics are run on them, which is the largest single
departure from the worker-ownership story and is recorded here as a deliberate
cost.

**The flywheel's real risk is not regulation.** It is that no partner has an
immediate incentive to write attestations back. The answer is to make
attesting a byproduct of work the partner already does, and that is designed
nowhere yet.

---

## 1. What Grain is

A person's proof of competence is currently trapped inside whoever observed
it. Leave the job and it does not travel; the employer has no reason to
maintain it and no obligation to attest to it. What travels instead are
portable proxies (degrees, brand-name employers, titles), which is precisely
why credential systems advantage the credentialed over the competent.

Grain is the record that travels. Concretely, and per
`model/attestation-interface.md`: a persistent `ledger_person_id` issued at
universal self-signup with no proofing gate; claims carrying explicit
provenance class; attestations signed by registered parties over a canonical
payload and hash-chain timestamped; party-level disclosure grants the worker
controls; and whole-profile deletion at any time (R2, decision 003).

**On proxies, honestly.** Grain's first analytics product uses signals from
the same families it criticises: seniority, tenure, described responsibility.
The difference is not that Grain avoids proxies; it is that every proxy here
carries its provenance class and resolves to the evidence underneath it, and
that the proxy is displaced as attested facts accumulate. A title with nothing
beneath it reads as a title with nothing beneath it. That is the whole claim,
and it is a smaller claim than "we replaced proxies with truth."

**On what cannot be attested, and the frontier that follows.** Part of what
makes a worker valuable is knowledge of people, of local conditions and of
particular circumstances, and some of that can never be stated by anyone,
including the person who holds it. Nothing moves that: it is not a
data-collection problem.

**But the knowledge does not have to be transmitted for its magnitude to be
estimated.** Unstatable expertise leaves a footprint in outcomes across
repeated instances, which is why volume, cadence and outcome facts carry more
of this than any description ever will. Nobody can write down what the
arbitrageur knows. Everybody can observe that he is right more often than the
market. Grain measures the footprint, not the content, and does not pretend
the two are the same thing.

**This is also why the residue is the asset rather than a limitation.** Hayek
separates scientific knowledge, which a body of suitably chosen experts can
command, from knowledge of the particular circumstances of time and place,
which only the person on the spot holds. AI is the first credible completion
of the first category. It leaves the second untouched, and Hayek's whole
argument is that the second is the larger problem. A worker's edge over a
general intelligence layer is precisely the category Hayek said could never be
centralised, and estimating that edge against a standard the employer
supplies, whether that standard is AI or a bar of their own, is what makes the
reading worth paying for. **[GAP]** That use is a capability projection about
a person and belongs in counsel brief 4 as a named use rather than as a
general statement about analytics (§7). An AI-relative baseline is also
non-stationary, which is a fourth way trajectory lies alongside §5's three,
and it is disclosed nowhere.

**Visibility is the worker's** (decision 024). The record is private by
default and the
worker controls who sees it: they consent to sharing with a specific party,
they can publish a public record, and they can use it to apply for work.
"Universally accessible" describes the right to hold a record, not default
readability of its contents.

**The worker controls who sees the record and never what it says.**
Attestations are append-only and immutable once written
(`model/record-schema.md` §1), grants are revocable, and the exit is deletion
of the whole profile rather than removal of a line. The one exception is
accuracy. A worker who believes a fact is wrong raises a `dispute`, which is
resolved with the attesting party and renders on the chapter until it is. A
correction is a new record and never a mutation of the old one, so the trail
of what was asserted, disputed and settled survives the correction. A record
that could be edited into shape would be a résumé with a signature on it, and
a record that could not be corrected would be worse than one.

Two entity types exist and only two: persons, who are subjects, and attesting
parties, who are issuers. Organisations are never subjects (decision 007). AI
executors never appear at all.

## 2. Why it must be independent

**No participant can build this alone.** An employer knows only what happened
inside their own walls. A background checker verifies discrete claims on
demand, expensively, and discards the result. A professional network holds
assertions with no provenance. The union of what many independent parties
attested about one person, across a working life, accumulating. That object
exists only if something sits outside all of them and holds it.

**Neutrality is the product, not a virtue.** A partner can only trust an
attestation written by a competitor if the thing holding it is owned by
neither. Grain today is a single company that both holds the record and
operates verticals on it, so neutrality is maintained by contract, published
rules and audit rather than by corporate separation (decision 024). That is a weaker
guarantee than a bureau's and should be described as what it is. **[GAP]** No
trigger has been set for when structural separation becomes necessary.

**Worker custody is the only stable arrangement.** An employer's interest in
your record ends when you leave; the worker's does not. Worker ownership here
is an argument about incentive durability, not ideology, which is also the
reasoning recorded in R1.

## 3. The record layer and the seam

**The record layer.** Free, universal, worker-permissioned. Facts with
provenance, plus the epistemic marks: identity assurance, provenance class,
corroboration, currency. These are deterministic. The rule for each is
publishable in one sentence, and two records with identical evidence always
produce identical marks. That is what allows the ledger to compute them
without becoming a scorer.

**Each level must be worth holding on its own.** A chapter with one
attestation must be worth keeping before the second arrives, and a record with
one chapter must be worth showing before the second. A design whose value
appears only at graph density asks partners to fund the density first, which
is the condition §8 names as the write incentive and §9 names as a way this
dies. The test is not whether a level can be sold once, it is whether the same
buyer comes back to it.

**The analytics layer.** Built on top of the record, sold to partners and used
by internal verticals. Computed on a partner's request, delivered, and **not
retained as a fact about the person**; a run record is retained separately
(§7). Ephemerality is not only a compliance posture. It satisfies the
existing mechanical ban on capability-score columns in fact tables
(`plans/foundation/06-checks-port.md`) rather than fighting it.

**Adjacent businesses.** Skills assessment on demand is a likely second
product and a possible vertical in its own right. Placement of trained
specialists is a further possibility, and it carries a real cost: Grain would
be selling candidates in competition with the partners whose attestations fill
the graph. Both are company decisions, tracked outside this file; identity
depends on neither.

**The seam.** Grain says what is known and how well it is known. The partner
decides what it means and bears the decision. Restated for partners in one
line: *the mark tells you how well-established the record is; it never tells
you whether to hire.*

### Why the seam is not a choice

Hayek, "The Use of Knowledge in Society" (1945), §VII: the value of a factor of
production does not follow from the valuation of what it produces, because it
depends also on the conditions of supply and on the ends of the party
deciding. Implication is a relation between propositions present to one and
the same mind, and no such mind holds all three terms.

That is the argument under the seam. Two of the three terms live inside the
hiring party and move with their situation. Grain holds the third. A number
claiming to state what a person is worth is therefore not merely presumptuous,
it is not determined by the inputs any ledger can hold.

What follows is not that Grain declines to compute. Grain computes, and the
quality of what it computes is the commercial edge. What follows is that every
reading is stated against an end the partner supplies. **No absolute
person-level score is ever emitted.** A reading answers: against this role,
under these conditions, here is what this record establishes and how well. The
same record reads differently for different partners, and that is correct
rather than an inconsistency to be normalised away.

This is also the strongest available form of the answer to §7's social-scoring
question, since a reading that cannot exist independently of a stated purpose
is not a general-purpose score of a person. It is an argument, not counsel's
opinion, and it goes in brief 4.

## 4. How the record becomes comparable

Standardisation is a schema problem, not an arithmetic one. Four channels are
comparable across every party:

- **Work kind.** `work_kind@version` from a ledger-authored vocabulary, pinned
  immutably at attestation time. Comparable by controlled vocabulary. **[GAP]**
  Not one term has been written.
- **Volume.** Counts of the same defined activity. Comparable by construction.
- **Responsibility level.** `dimension_standing` is comparable because the
  *ledger* defines the levels, not the parties. **[GAP]** No level definitions
  exist for any of the seven dimensions, which makes `dimensions_exercised`
  unusable by an attesting party today.
- **Outcome facts.** Completed or terminated early, extended, renewed,
  promoted during, accepted without rework, stretch held. Categorical events
  any party can report and any reader can compare. **[GAP]** No vocabulary
  exists.

**Quality stays party-local.** Every `score_summary` carries the `bar_ref` of
the rubric it was measured against, and the ledger never normalises. Packets
relay no scores finer than coarse ordinal tiers, while the issuing party keeps
its own granular data. The coarsening is deliberate: the cited evidence is
that moving a platform from five-star ratings to binary eliminated a
measurable racial earnings gap for new workers, so granularity itself drives
biased inputs into economic outcomes.

**Party quality scores do not feed grading.** They are incomparable by
construction, so grading on them would launder other employers' judgments
rather than produce independent intelligence. They exist so the issuing party
can read back its own judgments and so a reader can see that evaluation
occurred at all. The long-term prize is calibrating a party's `bar_ref`
against a fixed instrument so its scores become interpretable without being
normalised, that is years out and is not assumed anywhere in the current
product.

### Structured references

Decision 025. Candidates solicit references from people who managed them. **Grain designs
the form and the fields**; the response is structured throughout, with no free
response, because free text adds noise to every downstream use. A reference is
tied to a real person profile and carries its own provenance, which is what
distinguishes it from the unverifiable reference of the incumbent system.

**No trust follows the referrer.** A mechanism tracking each attester's
veracity across the network was ruled in and then withdrawn (decision 025,
superseding 023): it required falsification history to outlive a profile
deletion, which decision 014 had already ruled against, and which AEPD
PS-00176-2024 fined a controller for doing. Serious falsification routes to
014's severity-gated safety marker. Below that bar the evidence is deletable
by either party, and that is a cost taken deliberately rather than a hole.
What actually addresses reference farming is the Sybil apparatus (reciprocity
caps, velocity limits, device clustering, anchored weighting), which never
depended on any of this.

## 5. Grading, and what it stands on

Analytics on a person's work history and trajectory is the first product. It
produces a score and a read on slope, and it works from day one on partially
verified history.

**What it consumes.** Work history at whatever verification level exists;
skills assessment results where there are any; performance in Grain's own
courses or others'; structured references; and observable meta-signals:
average tenure in a role, described responsibility, seniority. Every input is
weighted by its provenance class, so a self-asserted history and a
party-attested one do not carry the same weight even when they say the same
thing.

**It is weak early, and says so.** The output carries its own confidence, and
below a threshold it declines to produce a score at all: insufficient data,
with a suggestion to take an assessment. **[GAP]** The threshold is not
defined and should be published rather than tuned quietly.

**Slope is the hard part.** There are three known ways a naive trajectory
reading lies: good routing keeps raw grades flat while ability rises; frozen
difficulty priors make promotions read as decline; and graders drift in the
same direction as the trend being measured. None of these are solved by more
history. They are solved by a fixed instrument (ledger-authored items, never
revised, never retired, administered regardless of what routing chose), which
does not exist. Until it does, **slope claims ship with those three limits
disclosed on the face of the output**, the same way §5's mapping fidelity is
disclosed. This is a rewrite of an earlier position that treated the
instrument as a precondition for shipping; it is not (decision 022).

**Assessment is one candidate instrument, not the answer.** On-demand skills
assessment is a likely second product and could become a vertical or a
service. It is not the moat, and identity does not depend on it.

**Assessment data reaches the ledger by the same path as everything else.**
It arrives as an attestation from a registered party, in the same signed envelope,
distinguished by scope rather than by object type. **[GAP]** A third scope
value alongside `engagement` and `period` is required and does not exist.

**Item-level responses never cross.** Only the outcome attestation, with a
commitment to the response set. Same rule as per-unit work rows and evidence
artifacts: the ledger holds attestations about work, never the work.

**Assessment is where regulatory obligation actually bites, but on whom.**
Results used in hiring are an employment selection procedure. In the US those
Uniform Guidelines obligations attach to the *user*. §1607.16(W)'s list is
closed at employer, labor organization, employment agency, and licensing board,
and the operative verb is *uses*. Grain supplies the validity documentation its
customer needs; the customer carries the duty (`research/14` §1). That is a
better position than it sounds, and it holds only while Grain stays a vendor,
see §8. Under the EU AI Act this is Annex III 4(a) and the duty is Grain's.
Validity documentation belongs from the first item written, not retrofitted.

### Meeting a customer's own leveling framework

Researched 2026-08-18, and the industry pattern is decisive: **one versioned
universal measurement, a typed crosswalk to the customer's model,
customer-owned thresholds, customer-selected reference population.** Three of
those four layers are customer-configurable; the measurement never is. SHL
maintains a 112-component universal spine and expresses client competency
models as views over it. Hogan maps 21 external models onto one fixed
58-competency model. FICO publishes one 300-850 scale, lets each lender set
cutoffs, and explicitly refuses to assert equivalence with VantageScore.
Nobody credibly rebuilds the instrument per customer, and nobody publishes a
numeric equivalence table.

For Grain: the seven dimensions and their level definitions are the invariant,
ledger-authored, versioned spine. A customer's job architecture (Radford P4,
IPE class 54, an internal "Senior II") is a **customer-authored view**, a
named and versioned artifact mapping their level to a predicate over Grain
dimension levels. Two customers with identical Grain evidence get identical
Grain output; only their views differ. That invariance is the entire basis of
network value.

Mapping relations carry explicit types and cardinality with a first-class "no
match", following ESCO crosswalk practice: `exact`, `broader`, `narrower`,
`close`, `related`, `unmapped`, at most one `exact` per pair. Retain `related`
and `unmapped` rather than discarding them; they are the coverage metric and
the roadmap. Report mapping fidelity on the face of every analytic output,
because the customers who trust the number will be the ones who saw its limits
disclosed rather than discovered them.

**The threshold belongs to the customer and is written to the ledger as their
artifact**, with their name and version on it. Under the credit precedent the
vendor supplies a versioned measurement and factor codes while the customer
owns the cutoff, the decision, and the legal explanation. The CFPB has held
that disclosing a score's key factors does not satisfy the lender's own
adverse-action duty. Given the litigation position in §7, the provenance of
the threshold is the part most worth writing down.

Four constraints from the same research:

- **Levels are per-dimension, never composite.** A person is autonomy 5 and
  influence 3 simultaneously. Collapsing that is the contaminated-measurement
  failure Hogan documents in its own pre-revision model.
- **Level prose must be behavioural and observation-anchored**: "has work
  reviewed at agreed milestones", not "senior". Evidence-describing language
  survives translation into a customer's vocabulary; status language does not.
- **Publish the level definitions openly; never publish an equivalence table**
  to Radford, IPE, Hay or WTW. No authoritative public crosswalk between those
  frameworks exists, and SFIA and the e-Competence Framework, two aligned,
  well-governed frameworks, concluded that honest equivalence required
  merging rather than mapping. Claim compatibility, supply the tooling, put
  the customer's name on their own mapping.
- **Crosswalks decay even when neither endpoint changes**, because populations
  move. Version the measurement, the customer framework and the mapping
  independently, and stamp every output with the triple.

## 6. The moat

In order of durability: the **attestation graph**, which compounds and which
no single participant can replicate; **identity resolution** across a working
life, which is cumulative and genuinely hard; **cryptographic integrity**,
which makes claims falsifiable rather than merely asserted, so trust
strengthens under scrutiny; the **decomposition of the hiring decision into
independently checkable parts**, which is what the analytics product actually
sells, because a reader who can confirm one dimension at a time, each carrying
its own provenance and corroboration, runs a far cheaper search than one
weighing a whole candidate at once, the saving grows with the number of parts
checked, and a single composite score would destroy the thing being sold; and
the **mark**, which travels into other products
carrying invariant meaning.

The strategic position is the network and the standard rather than the
database or the judge. Facts are auditable and scores are not, which is why a
facts layer gets stronger when partners check it.

## 7. Regulatory position and its live risks

**The ruling.** R1 (decision 003): not a CRA; worker-owned platform model. The
contrary analysis in `research/01-regulatory-perimeter.md` remains on record
and does not bind design.

**Why analytics make that harder rather than easier.** The professional-network
analogy survives on a worker-published-content theory. Grain's content is
third-party-authored signed attestations, which is exactly where that theory
thins. Counsel brief 4(b) already contemplates "no platform-derived scores to
readers" as a candidate condition. **[GAP]** Brief 4 is drafted and unsent.

**Mitigations that are real.** No derived score sits in a fact table about a
person; outputs are coarse and citation-backed; every mark resolves to its
evidence; and an output below the confidence threshold is withheld rather than
softened.

**Run records hold the run, never the output** (decision 026, superseding the
run-record ruling in 022). Every analytics run is logged: requesting party,
timestamp, input references, and instrument and model versions, and nothing
attributable to a person. The earlier position, that the output is retained
under a survives-deletion carve-out, does not survive the law. The AI Act
prescribes no log content for an Annex III point 4 system at all: Art. 12(3),
the only provision itemising content, covers biometric identification, and
Art. 19's six-month floor expressly yields to "Union law on the protection of
personal data", so it cannot be the legal obligation that displaces erasure.
No other regime asks for it either. Colorado's three-year duty on Grain as
developer covers system version identifiers and changelogs, not people
(`research/13`, `research/14`). The record is reachable by regulator and audit,
and by no read path that touches ranking or a worker's packet.

**EU exposure, per research dated 2026-08-18.** A research conclusion, not a
ruling. The analytics product is high-risk under Annex III point 4. The
Article 6(3) derogation is unavailable, because a system that performs
profiling is always high-risk regardless of how preparatory or human-reviewed
it is, and a capability projection is profiling on the face of the GDPR
definition. Grain would be the provider; partners are deployers; an API
changes nothing. Conformity assessment is self-certification with no notified
body, and high-risk obligations apply from 2 December 2027 on a fixed date.
The binding constraints are architectural: data governance, declared accuracy,
and explainability sufficient for a deployer to answer an affected person. **An
opaque score makes every customer non-compliant.** Grain's posture is to build
with these constraints in mind and not to build for the EU market first.

**Two prohibitions to design against, not merely comply with.** Inferring
emotions in the workplace is banned outright and already in force at the
highest penalty tier, so no capability signal may derive from affect,
sentiment or engagement-read-as-emotion. And social scoring is defined around
detrimental treatment in contexts unrelated to where data was generated. A
capability signal that follows a worker between employers is closer to that
line than a single-employer tool, and portability is the product. The attester
trust mechanism in §4 sits nearer this line than anything else in the design,
which is why its effect is scoped to the weight of what that person attests.
**[GAP]** Article 22 exposure of derived scores was deferred to a counsel
brief that has never been scoped.

**The vendor is not shielded by the customer owning the decision.** In *Mobley
v. Workday* (N.D. Cal.) the court held that an AI screening service provider
can be directly liable for employment discrimination under an agent theory,
and conditionally certified an ADEA collective. The credit-industry split
(vendor scores, lender decides, lender bears liability) does not reliably hold
in employment. Any Grain output that reads as "we told the employer whom to
reject" is materially worse than "we published a measurement the employer
interpreted". Related: *Baker v. CVS Health*, ACLU complaints against HireVue
and Intuit, the Illinois AI Video Interview Act, and EEOC guidance confirming
Title VII and ADA disparate-impact analysis applies to AI hiring tools.
**Colorado is the one US regime that binds Grain directly.** SB 24-205 was
repealed and reenacted as SB 26-189, effective 1 January 2027, and Grain is a
*developer* owing three years of system-level records. Conversely the OFCCP
obligations are in limbo: EO 11246 was revoked in January 2025 and the
rescission rule is not final.
Separately: differential prediction is criterion-specific, so **a validity
claim does not travel with a score.** Re-expressing a measurement against a
different customer's criterion can change its fairness properties even though
the measurement did not change.

**Recorded as a deliberate cost** (decision 022). Workers do not see when
analytics are run on them. They see their raw work history and facts, and, later, not first,
occasional job-match suggestions. This is the largest departure from the
worker-ownership story and the thing most likely to be read as a betrayal if
it surfaces later.

## 8. Strategic conflicts, recorded

**The write incentive is the real flywheel risk.** Attesting is work with no
immediate payoff to the manager doing it, and the graph starves without it.
The answer is that attesting must be embedded in a workflow the partner
already runs, so the write is a byproduct rather than a task; contractual
reciprocity is the backstop, and Grain's own verticals seed the graph in the
meantime. **[GAP]** Nothing designed addresses this.

**Worker-facing job suggestions are a matching surface.** Ranking roles for a
person is not ranking people for a role, and only the first is compatible with
§2: Grain may surface opportunities to a worker, and never transmits a
ranking of candidates to a partner. This is a longer-term surface: build
compatibility, do not build it first.

**The direction that looked safest is the one US law names.** 42 U.S.C.
§2000e(c) defines an employment agency as anyone regularly undertaking "to
procure **for employees opportunities to work for an employer**", which is a
description of a worker-facing suggestion surface. Building it would make Grain
a covered entity in its own right, a "user" under the Uniform Guidelines rather
than a vendor supplying documentation to one, and would move the §5 obligations
onto Grain. It does not make the surface unlawful; it changes who carries the
duties and what it costs. **[GAP]** Unruled, and it inverts the reasoning that
put worker-side ranking on the safe side of §2. Employer-side matching also
remains unruled.

**Charging for analytics over a free record layer.** The objection that Grain
profits from knowledge others could have gathered themselves is the objection
historically levelled at the arbitrageur and the estate agent, and Hayek
answers it directly: making dispersed knowledge reach the decision is the
service, and it is as socially useful as producing the thing being decided
about. Whether the price is right is a commercial question; whether the
activity is legitimate is not an open one.

**Placement.** If Grain ever places trained specialists, it competes with the
partners who hire from the same network and whose attestations fill the graph.
A company-level decision, noted here for its neutrality cost.

**Mark dilution.** A partner rendering the record badly, or implying
completeness a grant did not support, erodes what the mark means. Requires a
rendering contract with attribution rules and an enforcement path, not a style
guide. **Nobody re-inks, third-party embeds and Grain's own verticals
alike** (decision 024).

## 9. What could kill this

The graph never reaches density, because nobody writes back (§8). The
analytics product stays weak indefinitely, because no instrument is ever built
and history alone will not carry slope (§5). Counsel returns that the
not-a-CRA position cannot survive alongside sold analytics, and since the
record layer is free forever, analytics carries all the revenue, which makes
this the single largest risk rather than one of four (§7). Or portability plus
capability signalling is read as social scoring in the EU, which strikes at
the product rather than a feature (§7).

**And one that was outside every frame used so far.** A cross-employer
performance register is a labour-market information exchange under the January
2025 DOJ/FTC guidelines, in which being a neutral third-party intermediary is
**expressly not a defence**. That is an antitrust exposure attaching to the
shape of the network itself rather than to any feature of it, and nothing in
this document or the plan tree has been designed against it. **[GAP]** Unscoped.

**And one that lives in the schema rather than in the market.** A `chapter`
binds one subject to one party (`model/record-schema.md` §2), so every fact
must hang off exactly one party relationship. Work spanning several parties
has no home, and work attached to none has no home either: open-source
contribution, a consortium, a founder before incorporation, cross-functional
work that never produced a title change. That is the population whose résumé
carries the least signal, which is where the record's advantage over one
should be largest. The exclusion is made by omission rather than by decision,
and it does not announce itself in any output, because nothing in a record
shows what the format could not hold. **[GAP]** Either `chapter` gains a
multi-party or no-party form, or that population is out of scope in writing.

## 10. Gaps: the work queue

Ordered by what gates the first sale, with one correction: **items 11 and 12
belong immediately after item 2 and are not renumbered**, because
`counsel/brief-6` and other documents cite these numbers and a renumbering
would break them. Milestone `first-product` in `plans/ORDER.md` is the
corresponding build path.

1. **The record's own schema.** No field list exists for a work-history row, a
   skill, or a credential anywhere in the repo. Nothing ships without it, and
   everything the visual system renders depends on it. Prior art: W3C
   Verifiable Credentials 2.0, Open Badges 3.0, 1EdTech CLR, ESCO, Velocity
   Network.
2. **The structured reference form.** Field set and solicitation flow. Day-one
   input, designed nowhere.
3. **The confidence threshold** below which analytics returns insufficient
   data rather than a score, and how it is published.
4. **The disclosure text for slope**, carrying the three known failure modes
   on the face of every trajectory output.
5. **The run-record pseudonym.** It cannot be the `ledger_person_id`, which
   decisions 013 and 020 make permanent and spine-referenced forever, a
   retained means of singling out. Undesigned (decision 026).
6. **The run-record spine/payload fork.** Inside the subject's key envelope a
   run record dies at deletion and breaches AI Act Art. 19; outside it, it
   survives readable. No task owns the split (decision 026).
7. **The marks enum.** Drafted in design sessions, blocking
   `plans/marks-and-embeds` from going ready; awaiting founder ratification.
8. **Worker-facing job suggestions**, and whether building them is worth
   employment-agency status (§8).
9. **Antitrust.** The labour-market information-exchange exposure in §9, never
   scoped and outside every frame used so far.
10. **Is R2 regional?** India's DPDP Rule 8(3) compels a year of retention
    surviving account deletion from around May 2027. Either the deletion
    promise is scoped by region or the Indian rail is built so the obligation
    never attaches. Counsel, long lead.
11. **Responsibility dimension level definitions.** Seven dimensions, no level
    definitions, so `dimensions_exercised` cannot be populated by an attesting
    party. **Gates the first sale.** `chapter_standing` is the only object that
    makes an attested chapter different in kind from a résumé line, and it
    cannot be populated without these definitions, so a chapter with one
    attestation today carries provenance and corroboration and nothing else.
    Closest published prior art is
    SFIA, whose seven levels are defined per-dimension in behavioural prose
    across autonomy, influence, complexity and knowledge; the verbatim
    definitions were retrieved 2026-08-18 and are the drafting template.
12. **The work-kind vocabulary.** Governance is settled; not one term written.
    Must be drafted against two live verticals and only one exists.
13. **The outcome-fact vocabulary.** Does not exist.
14. **`dimension_standing`: derive or pass through.** Open founder call (N-2).
15. **Counsel brief 4**, unsent. And **the Article 22 brief, rescoped**: in the
    UK that article no longer exists in the form it was named for. DUAA 2025
    replaced it with Arts. 22A–22D, in force 5 February 2026, and Art. 22C
    requires inform, representations, human intervention and contest. The
    question is now who owes that duty, Grain or the deployer.
16. **The packet's member fields.** Named arrays with no fields, no ordering,
    no rendering contract.
17. **A third attestation scope** for assessments.
18. **Employer visibility during an active operating agreement.** Grants are
    party-level and whole-record, so a hiring disclosure currently buys ongoing
    visibility into a worker's other engagements. Unruled.
19. **The measurement instrument.** Anchors and item bank. Hardening, not a
    precondition, it is what moves slope from disclosed-weak to defensible.
20. **Post-selection authorization flow.** Selection is blind to work
    authorization by design; the flow around that is undesigned.
21. **The display identifier.** How a person is named to humans, distinct from
    the opaque `ledger_person_id`. Being treated as a design problem.
22. **The neutrality-separation trigger** (§2). No condition has been set for
    when contract-and-audit neutrality stops being sufficient.
23. **Customer-framework mapping machinery.** Typed relations, versioning
    triple, and the customer-authored threshold artifact are specified in §5
    and built nowhere.
24. **Matching and fintech scope.** Both raised, neither ruled.
25. **The shape of a chapter.** One subject, one party, so work spanning
    parties and work attached to no party are unrepresentable (§9). That is
    the population the record should beat the résumé by the widest margin,
    and it is currently excluded by omission. Either the object gains a
    multi-party or no-party form, or the population is ruled out in writing.

## 11. Naming

"Grain" is the working name for the identity layer throughout this document.
`hiregrain.com` currently hosts a hospitality product; that product may
relocate, or the domain may prove compatible with several verticals. The
analytics surface and the identity core are distinct things and may not
ultimately carry the same name. Unsettled.
