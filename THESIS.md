# Grain — Thesis

**Status: draft for founder review, 2026-08-18.** This supersedes nothing yet.
`handoff/founder-thesis.md` remains what it says it is: a record of founder
strategy thinking imported from Dispatch, evidence and not a spec. This file is
the first attempt at a binding statement of what Grain is, what it sells, where
its boundaries are, and what is still unresolved. Where it conflicts with
`decisions/LOG.md`, `model/attestation-interface.md`, or `contract/CONTRACT.md`,
those win and this file is wrong.

Gaps are marked **[GAP]** and collected in §10. They are the work queue.

---

## TLDR

**Grain is the trust layer that replaces the résumé.** A portable, worker-owned,
cryptographically verifiable record of what a person has actually done, attested
by the parties that observed it, readable by any partner the worker permits.

**The record layer is free and universal. The proprietary asset is the grading
intelligence** — how Grain measures capability, slope and potential. That
intelligence has a hard prerequisite that is not yet built: every quality score a
partner writes is measured against that partner's own bar and is therefore not
comparable to anyone else's. Grading on those inputs alone would launder other
employers' judgments rather than produce independent intelligence. **Grain needs
its own measurement instrument, and the assessment vertical is that instrument,
not an adjacent product.**

**Three businesses, one seam.** The record layer (free, universal, trust). The
grading intelligence (proprietary, paid, computed only on a partner's hiring
intent, never stored). Placement of trained specialists (later, and in structural
tension with the partners who hire from the same network). The seam between Grain
and everyone else: **Grain states what is known and how well it is known; the
partner decides what it means and owns that decision.**

**Comparability comes from standardising what is recorded, not from normalising
what is scored.** Four channels are comparable across every party — work kind,
volume, responsibility level, and outcome facts. Quality stays party-local and
labelled. Anchors are the only honest route to comparable quality, and they do
not exist yet.

**Contested, and stated here rather than buried.** Selling capability projections
to employers moves the not-a-CRA position (R1, decision 003) from theoretical to
load-bearing; counsel brief 4 is drafted and unsent. Under the EU AI Act the
analytics product is high-risk with no derogation available, because profiling
forecloses the decision-support escape. Portability itself — a capability signal
that follows a worker between employers — is what approaches the social-scoring
prohibition, and portability is the product. Workers will not see when analytics
are run on them (ruled 2026-08-18), which is the largest single departure from
the worker-ownership story and should be recorded as a deliberate cost.

**The flywheel's real risk is not regulation.** It is that no partner has an
immediate incentive to write attestations back, and nothing designed so far
addresses that.

---

## 1. What Grain is

A person's proof of competence is currently trapped inside whoever observed it.
Leave the job and it does not travel; the employer has no reason to maintain it
and no obligation to attest to it. What travels instead are portable proxies —
degrees, brand-name employers, titles — which is precisely why credential systems
advantage the credentialed over the competent.

Grain is the record that travels. Concretely, and per `model/attestation-interface.md`:
a persistent `ledger_person_id` issued at universal self-signup with no proofing
gate; claims carrying explicit provenance class; attestations signed by registered
parties over a canonical payload and hash-chain timestamped; party-level disclosure
grants the worker controls; and whole-profile deletion at any time (R2, decision 003).

Two entity types exist and only two: persons, who are subjects, and attesting
parties, who are issuers. Organisations are never subjects (decision 007). AI
executors never appear at all.

## 2. Why it must be independent

**No participant can build this alone.** An employer knows only what happened
inside their own walls. A background checker verifies discrete claims on demand,
expensively, and discards the result. A professional network holds assertions with
no provenance. The union of what many independent parties attested about one
person, across a working life, accumulating — that object exists only if something
sits outside all of them and holds it.

**Neutrality is the product, not a virtue.** Vantage can only trust an attestation
written by a competitor if the thing holding it is owned by neither. This is why
bureaus, certification bodies and clearing houses are structurally separate
entities, and it is the load-bearing reason Grain cannot also be the party making
hiring decisions on the same network without cost. See §8.

**Worker custody is the only stable arrangement.** An employer's interest in your
record ends when you leave; the worker's does not. Worker ownership here is an
argument about incentive durability, not ideology — which is also the reasoning
recorded in R1.

## 3. The three businesses and the seam

**The record layer.** Free, universal, worker-permissioned. Facts with provenance,
plus the epistemic marks: identity assurance, provenance class, corroboration,
currency. These are deterministic — the rule for each is publishable in one
sentence, and two records with identical evidence always produce identical marks.
That is what allows the ledger to compute them without becoming a scorer.

**The grading intelligence.** Proprietary, paid, sold under a recruiting-style
contract. Computed on a partner's hiring intent, delivered, logged, and **not
retained as a fact about the person**. Ephemerality is not only a compliance
posture; it satisfies the existing mechanical ban on capability-score columns in
fact tables (`plans/foundation/06-checks-port.md`) rather than fighting it.

**Placement.** Recruiting, assessing, training and placing trained specialists,
per the feeder-ladder model in `handoff/founder-thesis.md`. Later, and see §8 for
the conflict it creates.

**The seam.** Grain says what is known and how well it is known. The partner
decides what it means and bears the decision. Restated for partners in one line:
*the mark tells you how well-established the record is; it never tells you whether
to hire.* Free, universal and epistemic on one side; paid, bespoke and evaluative
on the other.

## 4. How the record becomes comparable

Standardisation is a schema problem, not an arithmetic one. Four channels are
comparable across every party:

- **Work kind.** `work_kind@version` from a ledger-authored vocabulary, pinned
  immutably at attestation time. Comparable by controlled vocabulary. **[GAP]**
  Not one term has been written.
- **Volume.** Counts of the same defined activity. Comparable by construction.
- **Responsibility level.** `dimension_standing` is comparable because the *ledger*
  defines the levels, not the parties. **[GAP]** No level definitions exist for any
  of the seven dimensions, which makes `dimensions_exercised` unusable by an
  attesting party today.
- **Outcome facts.** Completed or terminated early, extended, renewed, promoted
  during, accepted without rework, stretch held. Categorical events any party can
  report and any reader can compare. **[GAP]** Proposed 2026-08-18; no vocabulary
  exists.

**Quality stays party-local.** Every `score_summary` carries the `bar_ref` of the
rubric it was measured against, and the ledger never normalises. Packets relay no
scores finer than coarse ordinal tiers, while the issuing party keeps its own
granular data. The coarsening is deliberate: the cited evidence is that moving a
platform from five-star ratings to binary eliminated a measurable racial earnings
gap for new workers, so granularity itself drives biased inputs into economic
outcomes.

## 5. The proprietary core, and its prerequisite

The grading system — how Grain measures capability and the slope of a person's
growth — is the primary proprietary asset of this layer. It is what improves
Grain's own verticals and what a hiring partner pays for.

**It cannot be built on partners' scores.** Those are incomparable by design.
Grading on them produces a laundering of other employers' judgments, not
independent intelligence, and it would require exactly the normalisation the
interface rejects.

**Therefore the measurement instrument is the moat, and the assessment vertical is
the instrument.** Fixed items, ledger-authored, versioned, never revised, never
retired, administered regardless of what routing chose. Clearing one is a fact
rather than an estimate. This is what the research calls anchors, and it is the
only mechanism that survives the three ways naive slope displays lie: good routing
keeps raw grades flat while ability rises; frozen difficulty priors make promotions
read as decline; and graders drift in the same direction as the trend being
measured.

**Assessment data reaches the ledger by the same path as everything else** — as an
attestation from a registered party, in the same signed envelope, distinguished by
scope rather than by object type. **[GAP]** A third scope value alongside
`engagement` and `period` is required and does not exist.

**Item-level responses never cross.** Only the outcome attestation, with a
commitment to the response set. Same rule as per-unit work rows and evidence
artifacts: the ledger holds attestations about work, never the work.

**Assessment is where regulatory obligation actually bites.** Results used in
hiring are an employment selection procedure — Uniform Guidelines validity and
adverse-impact obligations in the US, Annex III 4(a) under the EU AI Act. Validity
documentation belongs from the first item written, not retrofitted.

### Meeting a customer's own leveling framework

Researched 2026-08-18, and the industry pattern is decisive: **one versioned
universal measurement, a typed crosswalk to the customer's model, customer-owned
thresholds, customer-selected reference population.** Three of those four layers
are customer-configurable; the measurement never is. SHL maintains a
112-component universal spine and expresses client competency models as views
over it. Hogan maps 21 external models onto one fixed 58-competency model. FICO
publishes one 300-850 scale, lets each lender set cutoffs, and explicitly refuses
to assert equivalence with VantageScore. Nobody credibly rebuilds the instrument
per customer, and nobody publishes a numeric equivalence table.

For Grain: the seven dimensions and their level definitions are the invariant,
ledger-authored, versioned spine. A customer's job architecture — Radford P4,
IPE class 54, an internal "Senior II" — is a **customer-authored view**, a named
and versioned artifact mapping their level to a predicate over Grain dimension
levels. Two customers with identical Grain evidence get identical Grain output;
only their views differ. That invariance is the entire basis of network value.

Mapping relations carry explicit types and cardinality with a first-class "no
match", following ESCO crosswalk practice: `exact`, `broader`, `narrower`,
`close`, `related`, `unmapped`, at most one `exact` per pair. Retain `related`
and `unmapped` rather than discarding them; they are the coverage metric and the
roadmap. Report mapping fidelity on the face of every analytic output, because
the customers who trust the number will be the ones who saw its limits disclosed
rather than discovered them.

**The threshold belongs to the customer and is written to the ledger as their
artifact**, with their name and version on it. Under the credit precedent the
vendor supplies a versioned measurement and factor codes while the customer owns
the cutoff, the decision, and the legal explanation — the CFPB has held that
disclosing a score's key factors does not satisfy the lender's own adverse-action
duty. Given the litigation position in §7, the provenance of the threshold is the
part most worth writing down.

Four constraints from the same research:

- **Levels are per-dimension, never composite.** A person is autonomy 5 and
  influence 3 simultaneously. Collapsing that is the contaminated-measurement
  failure Hogan documents in its own pre-revision model.
- **Level prose must be behavioural and observation-anchored** — "has work
  reviewed at agreed milestones", not "senior". Evidence-describing language
  survives translation into a customer's vocabulary; status language does not.
- **Publish the level definitions openly; never publish an equivalence table** to
  Radford, IPE, Hay or WTW. No authoritative public crosswalk between those
  frameworks exists, and SFIA and the e-Competence Framework — two aligned,
  well-governed frameworks — concluded that honest equivalence required merging
  rather than mapping. Claim compatibility, supply the tooling, put the
  customer's name on their own mapping.
- **Crosswalks decay even when neither endpoint changes**, because populations
  move. Version the measurement, the customer framework and the mapping
  independently, and stamp every output with the triple.

## 6. The moat

In order of durability: the **attestation graph**, which compounds and which no
single participant can replicate; **identity resolution** across a working life,
which is cumulative and genuinely hard; **cryptographic integrity**, which makes
claims falsifiable rather than merely asserted, so trust strengthens under
scrutiny; the **measurement instrument** of §5; and the **mark**, which travels
into other products carrying invariant meaning.

The strategic position is the network and the standard rather than the database or
the judge. Facts are auditable and scores are not, which is why a facts layer gets
stronger when partners check it.

## 7. Regulatory position and its live risks

**The ruling.** R1 (decision 003): not a CRA; worker-owned platform model. The
contrary analysis in `research/01-regulatory-perimeter.md` remains on record and
does not bind design.

**Why analytics make that harder rather than easier.** The professional-network
analogy survives on a worker-published-content theory. Grain's content is
third-party-authored signed attestations, which is exactly where that theory
thins. Counsel brief 4(b) already contemplates "no platform-derived scores to
readers" as a candidate condition. **[GAP]** Brief 4 is drafted and unsent.

**Mitigations that are real.** Analytics are computed on hiring intent, delivered,
and not retained; no score sits in a fact table; outputs are coarse and
citation-backed; every mark resolves to its evidence.

**EU exposure, established 2026-08-18.** The analytics product is high-risk under
Annex III point 4. The Article 6(3) derogation is unavailable, because a system
that performs profiling is always high-risk regardless of how preparatory or
human-reviewed it is, and a capability projection is profiling on the face of the
GDPR definition. Grain would be the provider; partners are deployers; an API
changes nothing. Conformity assessment is self-certification with no notified
body, and high-risk obligations apply from 2 December 2027 on a fixed date. The
binding constraints are architectural: data governance, declared accuracy, and
explainability sufficient for a deployer to answer an affected person. **An opaque
score makes every customer non-compliant.**

**Two prohibitions to design against, not merely comply with.** Inferring emotions
in the workplace is banned outright and already in force at the highest penalty
tier, so no capability signal may derive from affect, sentiment or
engagement-read-as-emotion. And social scoring is defined around detrimental
treatment in contexts unrelated to where data was generated — a capability signal
that follows a worker between employers is closer to that line than a
single-employer tool, and portability is the product. **[GAP]** Article 22 exposure
of derived scores was explicitly deferred to a counsel brief that has never been
scoped.

**The vendor is not shielded by the customer owning the decision.** In *Mobley v.
Workday* (N.D. Cal.) the court held that an AI screening service provider can be
directly liable for employment discrimination under an agent theory, and
conditionally certified an ADEA collective. The credit-industry split — vendor
scores, lender decides, lender bears liability — does not reliably hold in
employment. Any Grain output that reads as "we told the employer whom to reject"
is materially worse than "we published a measurement the employer interpreted".
Related: *Baker v. CVS Health*, ACLU complaints against HireVue and Intuit, the
Illinois AI Video Interview Act, and EEOC guidance confirming Title VII and ADA
disparate-impact analysis applies to AI hiring tools. Separately: differential
prediction is criterion-specific, so **a validity claim does not travel with a
score** — re-expressing a measurement against a different customer's criterion
can change its fairness properties even though the measurement did not change.

**Recorded as a deliberate cost.** Workers do not see when analytics are run on
them (ruled 2026-08-18). This is the largest departure from the worker-ownership
story and the thing most likely to be read as a betrayal if it surfaces later.

## 8. Strategic conflicts, recorded

**Placement competes with the network.** If Grain places trained specialists while
partners hire from the same network, Grain competes with its own customers. This is
the first-party-versus-third-party marketplace conflict, manageable with structure
and corrosive if discovered rather than designed. Dispatch is genuinely a different
category — dynamic operational work with human and AI allocation — and is not the
conflict.

**Matching is judgment.** A job-board surface means ranking candidates for roles,
which puts Grain in competition with every partner's ATS and with Dispatch's own
routing engine, and erodes the neutrality of §2. Current position: sell the
understanding, let the partner rank. **[GAP]** Not ruled.

**The write incentive is the real flywheel risk.** Attesting is work with no
immediate payoff to the manager doing it, and the graph starves without it. The
attest flow must be trivially fast, a partner's own future reads must visibly
improve because they wrote, and reciprocity probably belongs in the partner
agreement. **[GAP]** Nothing designed addresses this.

**Mark dilution.** A partner rendering the record badly, or implying completeness a
grant did not support, erodes what the mark means. Requires a rendering contract
with attribution rules and an enforcement path, not a style guide. Third-party
embeds may not re-ink; Grain's own verticals may.

## 9. What could kill this

The graph never reaches density, because nobody writes back (§8). The measurement
instrument is never built, so the grading intelligence has nothing independent to
stand on and Grain is a thin utility (§5). Counsel returns that the not-a-CRA
position cannot survive alongside sold analytics, forcing a choice between the
revenue and the posture (§7). Or portability plus capability signalling is read as
social scoring in the EU, which strikes at the product rather than a feature (§7).

## 10. Gaps — the work queue

Ordered by how much they block.

1. **The record's own schema.** No field list exists for a work-history row, a
   skill, or a credential anywhere in the repo. Everything the visual system
   renders depends on this. Prior art to draw from: W3C Verifiable Credentials 2.0,
   Open Badges 3.0, 1EdTech CLR, ESCO, Velocity Network.
2. **The work-kind vocabulary.** Governance is settled; not one term written. Must
   be drafted against two live verticals and only one exists.
3. **Responsibility dimension level definitions.** Seven dimensions, no level
   definitions, so `dimensions_exercised` cannot be populated by an attesting
   party. Closest published prior art is SFIA, whose seven levels are defined
   per-dimension in behavioural prose across autonomy, influence, complexity and
   knowledge; the verbatim definitions were retrieved 2026-08-18 and are the
   drafting template.
4. **The outcome-fact vocabulary.** Proposed here; does not exist.
5. **The measurement instrument.** Anchors and item bank; the moat's prerequisite.
6. **The marks enum.** Drafted in design sessions, blocking `plans/marks-and-embeds`
   from going ready; awaiting founder ratification.
7. **`dimension_standing`: derive or pass through.** Open founder call (N-2).
8. **Counsel brief 4**, unsent, and the **Article 22 brief**, never scoped.
9. **The packet's member fields.** Named arrays with no fields, no ordering, no
   rendering contract.
10. **A third attestation scope** for assessments.
11. **Analytics retention posture.** Ephemeral proposed; unruled.
12. **Employer visibility during an active operating agreement.** Grants are
    party-level and whole-record, so a hiring disclosure currently buys ongoing
    visibility into a worker's other engagements. Unruled.
13. **Post-selection authorization flow.** Selection is blind to work authorization
    by design; the flow around that is undesigned.
14. **The display identifier.** How a person is named to humans, distinct from the
    opaque `ledger_person_id`. Being treated as a design problem.
15. **Matching and fintech scope.** Both raised, neither ruled.
16. **Customer-framework mapping machinery.** Typed relations, versioning triple,
    and the customer-authored threshold artifact are specified in §5 and built
    nowhere.
