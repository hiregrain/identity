# Decisions Log

Append-only, numbered. Reversing a decision means a new entry, never an
edit. Each entry links the evidence live at the time. Convention inherited
from Dispatch per `handoff/HANDOFF.md`.

---

## 001 — Repo seeded from the Dispatch handoff package (2026-08-17)

The company is the ledger; Dispatch is the first vertical (founder,
2026-08-17, closing Dispatch decision 46 via Dispatch decision 49). Handoff
package committed at `handoff/`. The ledger is the system of record for the
person; each vertical is the system of record for its work.

## 002 — Founder grilling: ten settled decisions (2026-08-17)

Recorded in `research/00-founder-grilling-2026-08-17.md`: internal-first
with day-one external compatibility; partners read AND write; universal
self-signup identity; worker as first-class user seeing all raw facts;
provenance grades on every claim; self-asserted claims editable until
verified then frozen; party-level disclosure control; recruiter-not-CRA
positioning assumption; no economics embedded; grain as context not
constraint.

## 003 — Founder rulings R1 and R2 after research review (2026-08-17)

R1: not a CRA; worker-owned platform model governs design (contrary FCRA
analysis in `research/01` stays on record as evidence and counsel input).
R2: whole-profile deletion at any time; verified records never editable.
Recorded in `research/00`, "Founder rulings" section.

## 004 — Independent design 0.1 adopted as the working design (2026-08-17)

`design/ledger-design-0.1.md`, produced clean-context per the handoff
protocol. Diff against Dispatch positions is `design/dispatch-diff-0.1.md`:
nine of eleven positions independently re-derived; positions 3 and 8
modified by rulings 003/002; one genuine disagreement (see 007).

## 005 — Stack litigation rulings ratified (2026-08-17)

`design/stack-litigation/docket-rulings-0.1.md` (ratification header):
D1 managed Postgres with four launch-blocking obligations; D2 Go core +
TS surfaces + generated contract layer, gated on the T1 spike; D3 day-one
WORM-anchored ≤5-min Merkle checkpoints launch-blocking, witnessed tile log
by registry-enforced first-external-party-or-1M deadline; D4 party-held
registry-grade keys, hosted worker/peer keys. Sub-rulings: countersignatures
contractually mandatory; bootstrap tier deferred to first external party;
"zero loss of acknowledged attestations" adopted as a party-facing
contractual promise; residency counsel opinion commissioned for
US + EU + PH + India; first external party NOT confirmed within ~2 quarters.

## 006 — Interface contract RATIFIED with amendments; ownership transfers here (2026-08-17)

Per `design/interface-verdict-0.1.md`: the two-object boundary, never-crosses
list, and no-shadow rules ratified as-is; open items resolved R-1..R-4;
amendments A-1..A-5 applied; binding interpretations N-1..N-3 adopted. The
amended contract is `model/attestation-interface.md`, schema_version 0.2.
Per `handoff/HANDOFF.md`, ownership of the standard transfers to this repo;
Dispatch's `model/attestation.md` becomes the conforming copy
(notice: `handoff/ratification-notice-for-dispatch.md`).

## 007 — Organizations are never subjects; any org may register as an attesting party (2026-08-17)

Founder ruling on the one genuine Dispatch disagreement (Dispatch open
question 9, Dispatch leaned customers-as-identities). Ledger-native entity
types remain exactly two: persons (subjects) and attesting parties
(issuers). A customer organization, e.g., an in-person electrician
training program a worker is routed to, registers as an attesting party
and writes performance attestations back; it never holds a subject profile.
Approval-authority needs are met by party-registry entries or
vertical-local records.

## 008 — Work-authorization attestations, post-selection-only (2026-08-17)

Founder ratified the `research/08` proposal: work-authorization status may
live in the ledger as a jurisdiction-scoped, expiring verification
attestation carrying only a boolean + coarse basis-class, never documents,
visa type, or nationality, and readable only AFTER candidate selection.
Access is architecturally incapable of influencing routing/selection
(the eTeam/§1324b constraint expressed as access control). Reflected in
`model/attestation-interface.md` §work-authorization.

## 009 — No identity-evidence retention across deletion; reportability hook stays (2026-08-17)

(a) No salted document-hash survives profile deletion. R2's spirit
controls; the Uber-style retain-and-flag alternative is rejected. Revisit
trigger: fresh-start fraud materializing at measurable rates. (b) The
policy-configurable reportability window on adverse content (default: no
limit applied) is retained as a read-path hook. Recorded as the founder's
"4. a" ruling interpreted as adopting the recommended defaults on both;
flagged for correction if misread.

## 010 — KYC posture (2026-08-17)

Per `research/08`/`research/09`, adopted as working posture (not all items
founder-ratified individually; 008 is the ratified core): sanctions
screening is bought like verification and only signed pass/fail is stored;
document images never enter the ledger (results-only vendor integration);
vendor pilots Sumsub (global primary) + Persona (US primary), India-native
rail at India launch; KYB for party vetting is manual registry checks +
notarized UBO self-attestation at current volume. OPEN (not yet ruled):
formalizing the no-money-movement red line at the entity level.

## 011 — Foundation/trust-kernel grilling rulings (2026-08-17)

Founder rulings from the first per-layer grilling (the grill-before-ready
protocol now recorded in `plans/ORDER.md`):

- **Code lives in this repo** beside plans/model/decisions (Dispatch
  pattern). The plan gate only self-enforces when code and plans share CI.
- **Physical spine/payload split from day one**: two databases (global
  spine + `payload-us`) from the first migration, so the residency seam is
  real from hour zero.
- **No standing staging environment.** Founder override of the
  recommendation; add later if needed. Consequence accepted: D1 game-day
  drills (durability-and-launch) run on ephemeral environments spun up for
  the drill and torn down after, not a standing copy.
- **Key custody in development**: software keys for local/CI through a
  provider interface; real KMS in production; outside opinion sought as
  needed.
- **Root-key ceremony: the founder is the sole keyholder for now.**
  Third-party keyholder revisited at the witnessed-log / first-external-
  party milestone (the registry gate already forces that review).
- **T1 authorized**, run as a supervised operation: a supervising agent
  orchestrates implementer subagents under differing tech-stack
  instructions; the first operations are manually overseen.
- **The two TLA+ specs stand** (merge/unmerge concurrency; deletion vs.
  read path), with executable property-based suites as the recorded
  fallback if agent competence measured in T1 argues for it.
- **OPEN: cloud provider.** The founder ruled it deserves full treatment;
  the AWS-vs-GCP mini-litigation awaits explicit go. Until ruled,
  foundation tasks stay provider-neutral and provisioning is gated.

## 014 — Severity-gated safety marker; supersedes 013's enrollment token (2026-08-17)

Founder ruling after `research/12` (deletion vs. reputation evasion).
Supersedes the universal contentless enrollment token in entry 013.
Entry 009(a)'s original instinct, no retention by default, is restored
and refined.

**Legal correction on the record.** The argument that carried 013's
universal token was wrong in a specific way: **GDPR Art. 17(3) contains
no fraud exemption.** The list is closed at five items. Recital 47
establishes fraud prevention as an Art. 6(1)(f) *legal basis for
processing*, not an erasure carve-out; post-erasure retention must win on
necessity at Art. 17(1) with the burden on the controller. Hashing does
not rescue it: *EDPS v SRB* (C-413/23 P) protects only a recipient that
cannot re-identify, and retaining the salt in order to match is what
makes the token personal data.

**Two findings aimed at 013's design.** AEPD fined Goldcar €80,000 over a
customer blacklist, reasoning that the retained flag "does not refer with
certainty to a fraud committed by the claimant", which is definitionally
true of a universal contentless token. CNIL authorises exclusion
registers for a single controller but **expressly excludes mutualised
(cross-party) sharing**, which is this ledger's architecture. California
§1798.105(d)(2), PH NPC Advisory 2021-01 §10(B)(2), and India DPDP
§17(1)(a)/(c) all name fraud and physical safety in statutory text;
**performance appears nowhere**.

**The ruling.**
- **Default: nothing survives deletion.** Voluntary exits and
  performance-based exits leave no token, no hash, no marker.
- **Exception: a severity-gated safety/fraud marker**, with all of:
  filed by the **party that made the finding** (a party act, not a ledger
  act, which is also what defeats the delete-before-the-finding race,
  since the party holds its own records and can file after the fact);
  keyed to the **document identifier only** (industry convergence, no
  platform uses device or IP as a match key); **no payload**; an
  evidential floor (Cifas standard: "could confidently report to the
  police"); a **fixed expiry clock**, not retention discretion; **joint
  controllership** with the filing party, with challenges routed to that
  party; **review, never denial**, on a match; disclosed at collection.
  Scope discipline follows the Uber/Lyft Industry Sharing Safety Program:
  the most critical safety/fraud categories only, never a general
  exclusion list.
- Re-registration mechanics from 013 survive unchanged where they do not
  depend on the token: a tombstoned ledger id is **never reissued** (spine
  signatures reference it forever); a re-registration is a new id;
  matching triggers steward review, never an automatic block.

**Escalations recorded, outside this decision.** (1) "Delete means gone"
cannot be a global invariant. Seattle's deactivation ordinance and India
DPDP Rule 8(3) create retention *obligations* in tension with R2; counsel
brief 1 must carry this before the worker agreement is drafted. (2) The
reputational exposure attaches to the **product**, not the policy: a
cross-employer worker record carrying any exclusion flag is structurally
a blacklist (UK Consulting Association precedent) and will be read that
way regardless of scoping. Founder-level strategic risk, not a schema
question.

## 013 — Person-identity grilling rulings; supersedes 009(a) (2026-08-17)

Founder rulings from the person-identity grilling. Entry 009(a) (no
identity evidence retained across deletion) is **superseded** by the
enrollment-token ruling below.

**Signup and authentication.**
- **Email-primary signup**, verified control of one contact channel;
  phone optional. Rationale: `research/11` found phone raises attacker
  cost only ~$0.10–0.50/account (SMS-PVA services run on malware-infected
  real handsets; 200+ major services' OTPs intercepted in a 12-month
  academic study), buys almost no uniqueness in target markets (India
  ~1.88 SIMs/person; PH 18% multi-SIM), and email is materially cheaper
  at scale. Industry pattern (Airbnb, Login.gov, CLEAR, ID.me) is
  email-or-phone; phone-mandatory platforms gate at payout, not signup,
  matching the founder's point that KYC lands at task completion/payout.
  **The real anti-Sybil control is risk scoring** (VOIP line-type,
  carrier reputation, velocity), not channel possession.
  Recorded exception: PH SIMs are government-ID-bound under RA 11934, so
  a verified PH mobile is a higher-assurance signal and is captured as
  such rather than flattened.
- Minimum to create an identity: one verified contact channel. No name,
  no date of birth, nothing else.
- **Passkeys preferred, one-time codes an always-available equal path.**
- **Recovery must re-clear the account's derived assurance level**, plus
  a **7-day post-recovery freeze** on deletion and grant changes with
  notification to every channel on file (defeats takeover-then-destroy).

**Names** (three strictly separated layers, per `research/11`; vendor
practice is NOT the standard to copy. Three of six major IDV vendors
corrupt mononyms): worker-owned free-text `display_name`; immutable
per-verification `document_name` in ICAO 9303 vocabulary
(primary/secondary identifier, mononym flag, raw MRZ + raw visual zone,
native script + ISO code, source); derived regenerable `name_index` for
fuzzy matching (transliterations alongside originals, never phonetic
hashing of non-Latin, candidates only, never auto-merge). Name changes
are appends with use-type and validity periods; prior names are
queryable for matching but withheld from employer-visible views at the
query layer. PhilID middle name (mother's maiden surname) gets its own
field, never initialized; Aadhaar-style single strings are UNSPLIT.

**Duplicates and merges.**
- Detection runs at signup **and continuously**; signals include contact
  data, biographic data, document identifiers, IP and device. IP/device
  are triage evidence only, never identity proof (grain prior art:
  cafés, offices, VPNs, shared households produce false matches).
- Workers may **report their own duplicates** (pull). Suspected
  duplicates are **never proactively surfaced** to a worker. Founder
  ruling; proactive disclosure leaks the existence of a matching account
  and teaches detection thresholds.
- No automatic merge touches attested history. **Two stewards** required
  where both records carry verified attestations; one otherwise.
- Concurrent multi-accounting: **flag for steward review only**, no
  visible enforcement, no automatic consequence.

**Deletion and re-registration (supersedes 009a).**
- **You can delete your record; you do not get a second identity.**
- A **universal, contentless enrollment token** survives every deletion:
  a one-way hash of verified document identifiers (primary strength),
  plus phone/email if present (weak). It carries **no outcome tag, no
  cause label, no reputation content**. This is what keeps it lawful
  (fraud prevention is the named legitimate interest; retaining a
  judgment about a person is not) and simple (no cause classification, no
  adjudication surface, no race condition where a bad actor deletes
  before a finding lands).
- **Never expires**, until counsel says otherwise.
- Re-registration matching a token: **new ledger ID, internally linked**,
  a tombstoned ID is never reissued (spine signatures reference it
  forever). First re-registration: usable, flagged for review. Repeat
  velocity: created but **restricted** (no verification, attestations, or
  grants) pending steward decision. **No automatic hard block.**
  Matching after erasure is defensible fraud prevention; denying service
  on it is the sharpest legal exposure, and a contentless token cannot
  distinguish fraud from a change of mind.
- **Disclosed plainly at deletion**, not buried: the record is
  unrecoverable, and the identity remains known. Re-signup with the same
  documents will be recognized and may require review.
- Open: `research/12` (deletion vs. reputation evasion) is in flight and
  counsel brief 1 carries the retention/restriction question. A contrary
  finding gets its own entry.

## 012 — T1 gate discharged; D2 (Go core) stands (2026-08-17)

Founder ruling. The T1 spike ran tasks 1–3 across a 10-cell matrix
(2 languages × {Fable, Opus, Sonnet}), blind-first-submission protocol,
every artifact independently re-judged: **10/10 cells green on first
submission, zero defect separation by language or model tier**, including
deliberately Go-hostile canonicalization terrain and cheap-model cells.
Evidence: `log/2026-08-17-t1-interim-results.md`.

The gate is discharged on this interim evidence by founder ruling. The
pre-committed rule was defect-rate-based and showed no separation; the
undischarged discriminator tasks (state machines, folds,
underspecification) tested ergonomics the rule would not have flipped on.
Recorded honestly: T1 found *no evidence against* Go, not affirmative
confirmation; the D2 verdict's switch-triggers (agent-defect-rate
inversion, bounded kernel-port exits, FIPS mandate) **carry forward as the
ongoing guard during real kernel development**, which supersedes synthetic
evaluation. Consequences: `trust-kernel` ungated, task files authored in
Go. The T1 scratch artifacts were lost to temp-directory cleanup after
measurement; the seven normative contract-ambiguity resolutions survive
verbatim in `contract/CONTRACT.md` and vector regeneration is a
deliverable of `trust-kernel/01` (lesson recorded: spike artifacts worth
keeping go in the repo, not the scratchpad). Secondary finding for the
executive loop: model tier showed no reliability cliff under the
blind-first + differential-self-test discipline, routine kernel-adjacent
tasks may dispatch to cheaper models.

## 015 — Party-registry grilling rulings; D4 confirmed with an operator carve-out (2026-08-18)

Founder rulings from the party-registry grilling (grill-before-ready,
`plans/ORDER.md`). Third per-layer grilling after 011 (foundation +
trust-kernel) and 013/014 (person-identity).

**D4 confirmed, not reversed.** The round surfaced an apparent founder
answer that the ledger could sign on a partner's behalf; on restatement
the founder ruled **partner-held keys stand**. External parties hold
their own registry-grade signing keys; the ledger ships the installer
that provisions the key inside the partner's own environment; **no code
path signs as a partner**. The dispositive reasoning in
`design/stack-litigation/d4-verdict.md` §II(a), that the ledger is never
a disinterested third party in a dispute about its own record, so
"who could have produced this signature?" must answer *only the partner*,
is reaffirmed as the controlling argument. Recorded because the
question was put and answered, not assumed.

**Amendment to the D4 invariant (narrow).** D4 §2 read "no tier in which
the operator can invoke a registry-grade party key." The operator signs
`ledger_invalidated` records and checkpoints, and those signatures must
verify through the same registry lookup as any other. The invariant is
restated: **no code path invokes a registry-grade key other than the
operator's own**, with the operator holding a single self-entry
(`custody_model: ledger_kms`) enforced unique by a partial index, one
row, structurally. The alternative (operator keys in a table outside the
registry) was rejected: it duplicates key-lifecycle machinery and hides
the operator's own rotations from the public status history, which is the
part of the transparency posture that costs most if absent.

**Verification vendors are listed but keyless.** Decision 010's "only
signed pass/fail is stored" is resolved: the **ledger** signs
verification attestations, recording the vendor as `evidence_source`.
Vendors hold registry entries (so accreditation re-checks and status
machinery reach them) with `custody_model: none`. Rationale: no
realistic KYC vendor will run the ledger's signing SDK, and requiring it
would block the `verification` layer on an integration the ledger does
not control. The claim as signed is also the truthful one. *The ledger
obtained this result from that vendor*.

**Vetting tier and capability are orthogonal.** `vetting_tier`
(`internal | external_probationary | external_standard | vendor`) drives
internal trust weighting only. Capabilities, `may_attest(scope)`,
`may_request_packet`, `may_file_safety_marker`, are **granted
individually as append-only events**, revocable, never implied by tier.
Safety-marker filing additionally **requires a signed addendum on file**,
referenced by the grant record: decision 014 attaches joint
controllership and routes worker challenges to the filing party, and a
party cannot be handed that obligation without accepting it. Given the
AEPD/CNIL exposure, "which parties could file, and since when" must be
answerable from a grant log rather than reconstructed from historical
tier membership.

**Lifecycle gains `withdrawn`.** `pending → active → suspended | revoked
| withdrawn`. `withdrawn` is an ended relationship with no finding
against the party; `revoked` retains its meaning. Without the split, a
partner that simply shut down is marked on a public status page as though
the ledger caught it at something.

**Suspension reasons are a closed category list, no free text.** Bare
"suspended" invites readers to assume the worst of every record that
party ever wrote; a specific reason is a defamation surface. Broad
categories from a fixed enum. **No free-text column adjacent to
suspension anywhere.** A text box eventually gets typed into and read
back in a deposition.

**Party principals are not ledger entities.** Partner console logins are
`party_users`: WebAuthn-bound auth records scoped to a party, carrying no
`ledger_person_id` and no path to one. Decision 007's two-entity rule is
untouched. A console login is not a ledger entity. The founder noted the
same human may separately hold a worker record; therefore **duplicate
detection is barred from linking `party_users` to persons**, enforced, not
merely unimplemented.

**Activation gates are computed, never stored.** Two limbs, both required
at transition and re-asserted by a check: (1) the witnessed transparency
log exists and is accepting, queried live from the kernel, no cached
boolean, which is one UPDATE away from being flipped under deadline
pressure; (2) the conditional liability-shield instrument
(`design/ledger-design-0.1.md` §3.1) is executed and recorded as a
precondition row. The **1M-attestation limb of decision 005 is a build
deadline for the log, not a second route to activation.** Recorded
explicitly so it is not later read as an escape hatch.

**Countersignature cadence: monthly**, or at each registry event, per
`d4-verdict.md` §5. `plans/party-registry/LAYER.md` said quarterly; that
was drift and is corrected. Monthly bounds the "the party never noticed"
window to 30 days, matching the 30–90-day key validity window rather
than cutting across it.

**Probation caps: declared here, enforced at ingestion, never cached.**
Default cap ≈10× the party's stated expected volume, reviewed at 90 days.
**Accreditation re-checked every 90 days** and on any registry event.
One scheduled job shared with the key-renewal rhythm. Falling off an
external allowlist **flags a human and freezes new writes; it never
auto-suspends** (name changes and data errors in external registries are
common enough that automation would take legitimate parties offline).
**Public per-party status pages live at plain, guessable URLs.** The
transparency claim is void if checking a party's standing requires
asking us.

**Layer boundary, as a rule rather than a list:** code that runs on
ledger infrastructure belongs to `party-registry`; code shipped to a
partner belongs to `integration-surface`; signing and canonicalization
logic belongs to `trust-kernel` and is packaged by others, written once.
Stated as a rule so the next boundary question resolves without a ruling.

**Recorded as an executive judgment call, not a founder ruling:**
`ledger_invalidated` **authority** (which registry state permits it)
lives in `party-registry`; the **mechanism** lives in `ingestion`, which
already owns supersession-authority enforcement (AC-I3). Surfaced to the
founder, who left it as scoped.

Consequences: `party-registry` promoted to `ready` with seven task files;
`person-identity/07`'s dangling `party-registry/01` dependency is
discharged; party core lands as migration `0009` (the one free slot below
`0014-safety-markers`, which references `filing_party_id`).

## 016 — party-registry engineering review; twelve hardening rulings (2026-08-18)

Founder rulings from `/plan-eng-review` over the seven task files authored
under decision 015, scoped to the files plus their dependency seams into
`foundation`, `trust-kernel`, `ingestion`, and `person-identity`. Outside
voice: Codex, high reasoning effort, sixteen findings, most sustained.
Recorded because several rulings amend 015 and one amends the D4 verdict's
open enforcement question.

**Found by the seam review.**
- **Spine readable-column exemption, narrow and documented.** A party's
  legal name is text on a plane whose lint forbids readable columns
  (foundation/04). Granted by column, in `0009-party-core`, citing the
  reason: the ban protects *person* data across residency boundaries, and a
  party's name is public by construction. The exemption licenses nothing
  else, and a test asserts the lint still fails on any other readable spine
  column.
- **Party principals are erasable; their actions are not.** A party admin is
  a natural person with erasure rights, and the reason worker records are
  append-only, attestations must survive to stay verifiable, does not
  apply to a console login. Actions carry an opaque `actor_id` that outlives
  the principal row. Requires a table-scoped exemption under foundation/03's
  documented license. **This is a gap in decision 015, not merely in a task
  file**: 015 settled that principals are not ledger entities and never
  addressed that they remain data subjects.
- **Per-party issuance root, added to the kernel surface.** Task 07 assumed
  a per-party Merkle root that no task in the graph produced;
  `trust-kernel/04` builds one global tree over stream heads. A party must
  countersign something it can recompute from its own records. Signing the
  global root would attest to the ledger's arithmetic instead. Recorded as
  an extension `trust-kernel`'s own grilling round did not anticipate.
- **`person-identity/07` corrected.** Written before 015 created
  `may_file_safety_marker`, its acceptance said only "the filing party."
  Now binds 015, requires a live grant, and tests that a fully vetted
  `external_standard` party without the grant is refused, tier confers
  nothing.
- **Ingestion halt is derived, not stored.** A party is halted exactly when
  no key's validity window covers now. No `halted` column exists, matching
  the computed-not-stored rule 015 set for the activation gate.
- **Transactional projections on the write path.** Status, name, freeze, and
  capability reads on ingestion's hot path resolve against projections
  written in the same transaction as their events. Not a cache: no staleness
  window, nothing to invalidate, which satisfies 015's no-cached-copy
  ruling rather than working around it.

**Found by the outside voice.**
- **Key-loss recovery ceremony, written now.** ACME renewal assumes the
  current key still signs, so missed expiry, cloud lockout, or admin
  compromise had no path. Recovery is **re-registration**: fresh key,
  ordinary proof-of-possession challenge, operator review, registry event.
  No privileged bypass is created. An unwritten ceremony is not an absent
  one, it is one improvised under pressure in the single place where
  improvisation destroys the D4 argument.
- **The D3 deadline clock starts at `pending`.** Gating activation alone
  left "park the party in `pending` forever" as a silent bypass, converting
  a launch-blocking obligation into an aspiration. Both limbs are tracked;
  crossing either without a witnessed log requires a **signed governance
  event** naming who accepted the slip. Slipping stays possible; silence
  does not.
- **Read-time status derives from evidence source, not only signer.** Under
  015 the ledger signs verification attestations with the vendor as
  `evidence_source`. Signer-only status would flag *the operator* on every
  verification record when a vendor is suspended, and leave the vendor's
  results rendering clean. Both inputs now feed the computation.
- **Freeze is an orthogonal condition, not a lifecycle state.** A frozen
  party stays `active`, carries valid history, and is under no finding
  (015). Adding `frozen` to the enum would render it as a mild suspension,
  precisely what 015 forbids.
- **Legal name is an append-only rename event.** "What was this party called
  when it signed that record" is the question a dispute asks; prior names
  render on the public status page so a party cannot shed a suspension
  history by rebranding.
- **Countersignature enforcement: graduated, never silent.** D4 left
  advisory-versus-mandatory open; the task files had quietly chosen advisory
  forever. First miss notifies and queues; consecutive misses escalate to a
  registry event and review, which may apply the freeze. **This closes D4's
  open enforcement question.**
- **The party-visible issuance feed ships in v1** as `party-registry/08`.
  D4 adopted it as a control separate from the countersignature, and the two
  are not substitutes: the root says a record is wrong, the feed says which.
- **Unlinkability restated and structurally enforced.** The prior wording
  ("no person-identifying column") contradicted its own tests and the
  erasure ruling above. An admin login needs an email. The invariant is: no
  foreign key to a person, no shared identifier, and **no role that can read
  both `party_users` and the person tables**, with the pair in separate
  schemas and a lint on cross-schema queries. Intent is not enforcement.
- **Instrument and addendum references are validated, not merely present.**
  A non-null pointer is satisfiable by garbage. Both the liability-shield
  instrument and the safety-marker addendum now check party identity,
  version, execution, effective date, revocation, and applicability, each
  refusal tested independently.
- **The no-party-key rule is a structural boundary, with a regression
  test.** A non-operator `kid` is unrepresentable at the signing boundary;
  the test proves the boundary has not widened. Partial disagreement with
  the outside voice recorded: it proposed replacing the test with the
  boundary. The boundary is the control, the test is the alarm, and both
  are kept.
- **Operator uniqueness needs three constraints, not one.** A partial unique
  index on `is_operator` proves only "at most one operator." Added: a check
  binding `is_operator ⇔ custody_model = 'ledger_kms'` in both directions,
  and a seeded existence invariant.
- **The free-text ban is scoped to reason and detail fields** adjacent to
  adverse lifecycle events, not to text being reachable at all. The name
  exemption above made the original wording unsatisfiable.
- **Countersignature acceptance proves the protocol against a harness, not
  the shipped kit.** "A partner runs one install and it works" is
  `integration-surface` AC-IS1; this layer cannot assert it without
  depending on a layer that depends on it.

Consequences: eight task files in `party-registry` (08 added);
`person-identity/07` amended; `party-registry/08` declares a dependency on
`ingestion/01`, which is not yet authored, a known dangling reference of
the same class as 07's, discharged when `ingestion` is decomposed.

## 017 — foundation engineering review; layer re-decomposed 6 → 9 tasks (2026-08-18)

Founder rulings from `/plan-eng-review` over `foundation`. Outside voice:
Codex, high reasoning effort, 33 findings; 9 more from the seam pass. The
volume was the finding: roughly a third were not defects in what the tasks
said but concerns **no task covered**, which is a different failure from
party-registry's (decision 016, all patches). Founder ruled the layer is
**re-decomposed rather than patched**. The missing concerns become tasks
with their own acceptance criteria and verifiers, because a missing rule for
what happens when a two-database write half-fails costs every layer that
writes, while a missing acceptance criterion costs one PR.

**Cross-plane write consistency: spine-first transactional outbox**
(`foundation/07`, new). There is no shared transaction across two physical
databases (decision 011), so every spine+payload write could commit one side
and lose the other, and nothing said what happens next. The spine write and
an outbox row commit together, the spine is the ordering authority, so its
commit is what "recorded" means, then a worker applies payload
idempotently, a reconciler surfaces stragglers, and acknowledgment waits for
both planes. **No compensation path**: the spine is append-only, so
"undoing" a spine write means writing a retraction, which would put an
infrastructure hiccup permanently into the record a dispute reads. Retry
forward only. FDW/dblink banned, which is what makes foundation/04's
"no cross-plane SQL joins" structural rather than aspirational. This is also
what makes `ingestion`'s acknowledgment watermark keepable.

**DEK ownership: subject-scoped, single owner.** A payload row about a
person is encrypted under **that person's key alone**, even when it records
an attestation another party wrote; rows concerning more than one person are
keyed to the subject and **never dual-wrapped**. Deleting the person makes
the row unreadable to everyone, the issuing party included. Grounded in
decision 014, whose reasoning already depends on parties holding their own
work records outside the ledger. A dual wrap would leave a readable copy of
a deleted person's record, the structure 014 rejected on AEPD and CNIL
reasoning. Consequence for the partner agreement: it must state plainly that
the ledger-side copy does not survive the subject's deletion.

**Deletion mechanics** (`foundation/08`, new). Three gaps closed at once.
(1) **Backups defeated deletion and nothing addressed it.** A backup holds
the wrapped key, so a restore resurrects a deleted person. Ruling: bounded,
stated backup retention plus a **mandatory restore-time deletion replay**
that gates traffic; a restored system that has not replayed does not serve.
The per-person-managed-key alternative (destruction global the instant it
happens, no window at all) was preferred in principle and rejected on
practicality: per-key cost and quota limits are unverifiable before the
cloud ruling and worker-scale volume is where they bite. The residual window
is **disclosed**, and a check fails if the number in worker-facing copy
drifts from the number in config. (2) **Scheduled physical purge** of
shredded rows, with the purge role the only role holding DELETE on payload
tables. This is also the concrete rule replacing foundation/04's
placeholder exemption "where deletion requires it." (3) **Crypto-shredding
is recorded as a documented legal position, not a mechanical proof**, citing
014's *EDPS v SRB* analysis: the ledger cannot re-identify, and that is the
load-bearing fact.

**One shared migration numbering sequence across both chains.** Task 06
checked "collisions and gaps across both chains" while task 04 created two
independent chains, two different models, both asserted. Ruling: numbers
are globally unique across spine and payload; each chain has gaps where the
other's fall. Only a shared sequence can express a cross-plane ordering
constraint, and the constraint is live rather than hypothetical:
`0014-safety-markers` references the party table created in
`0009-party-core`. A new `checks/migration-order.mjs` enforces it.
Collisions and gaps do not catch reference ordering.

**AC-F3 narrowed to what it can prove, with the rest made explicit.** The
criterion claimed no spine column holds readable personal data and enforced
it with a type lint. A lint blocks a `text` column; it cannot prove an
opaque `bytea` or an id does not encode a name, and it says nothing about
the harder direction: stable ids, timestamps, and issuer patterns identify
people by **correlation** with zero readable columns present. Ruling: an
**exhaustive allow-list** of permitted spine types (the term
"readable-content type" was never defined, so implementers would have
invented the boundary), a **written justification** in-migration for
anything outside it reviewed by a human, and the correlation risk as its own
deliverable, `foundation/09`, the **spine linkage threat model**, new, a
document task with no code, because every layer above adds spine columns and
needs something to review them against.

**Append-only had holes; the claim is now scoped and the boundaries are
operational.** The unqualified "cannot UPDATE or DELETE any table" would
have gone false the moment the first exemption landed, and a test trained to
ignore exceptions is worse than no test. The exemption list is now
enumerated in the test. Beyond the grant: serving processes hold no owner or
migration credentials, and **SECURITY DEFINER recording functions may only
INSERT** (asserted by inspecting bodies). `ingestion` writes through them
by design, which was a legitimate path around the restriction. Default-
privilege inheritance is proven across both databases, multiple schemas, and
a second owner role, because Postgres default privileges are per granting
role and per schema and a single-schema test proved far less than claimed.
The inherited derived/cache exemption clause is **dropped**. Imported from
Dispatch before this repo has derived/cache semantics, it was an unused
escape hatch.

**Smaller rulings applied.** Typegen output is **namespaced per plane** so a
payload type cannot satisfy a spine-typed parameter. Accidental cross-plane
type reuse violates the split in application code while every database check
passes. CI is a **dependency graph, not a linear slogan**: metadata checks
(frontmatter, plan graph, numbering, ordering, decisions) run before any
database boots. Red-path CI acceptance uses **excluded fixtures**, not
genuinely broken committed files, which would make the tree permanently red.
`make check` **never requires cloud credentials**. Local Docker and managed
D1 were conflated. The DEK registry's derived state is specified: at most
one active DEK per person by constraint, one documented resolution rule,
idempotent destruction. `destroy(person)` is defined for **merged
identities** (every id in the alias closure) and under concurrency (fail
closed, never partial plaintext). Encryption evidence is **stronger than a
dump grep**, which only proves one planted literal is absent. The provider
invariant is corrected: **business logic is provider-agnostic; operational
code may know**. Observability and incident response legitimately need to.
The **KMS verification gap** created by decision 011's no-staging ruling is
named and mitigated with a provider conformance suite the real KMS must pass
in an ephemeral environment before first production use. Layer `binds`
extended to 011, 012, 016, 017; acceptance extended with AC-F5 through
AC-F7, since AC-F1..F4 omitted envelope encryption entirely and the layer
could have been marked accepted with DEK plumbing broken.

**Applied without an explicit ruling, flagged for reversal:** managed
Postgres provisioning removed from foundation's scope, on the grounds that
no task performs it and ORDER.md already lists it as a founder gate. The
founder had dismissed this question in an earlier round; it is applied here
because the outside voice raised it independently and the re-decomposition
ruling covered patches. Reversible on request.

**Still open, not decided:** the general schema-separation posture decision
016 requires for `party_users` (a table-scoped erasure exemption landed in
foundation/03; the role/schema boundary that makes the unlinkability claim
enforceable did not), and whether the payload database or the
`residency_region` column is authoritative for residency.

Consequences: `foundation` is 9 tasks; migrations `0020-cross-plane-outbox`
and `0021-deletion-journal` added; `checks/migration-order.mjs` added to
`foundation/06`; layer stays `ready`.

## 018 — foundation review: three deferred items closed (2026-08-18)

Closes the items decision 017 recorded as open or applied-without-ruling.

- **Provisioning stays out of foundation's scope.** Founder confirmed the
  change 017 flagged for reversal. No foundation task provisions anything
  and none can before the cloud ruling, so the scope line described work
  nobody held; ORDER.md's founder-gate table is the single place it lives.
  `make check` requiring no cloud credentials is now an acceptance
  criterion rather than an assumption.
- **Schema boundaries become a general posture in `foundation/03`.** Named
  schemas, per-schema role grants, a declared list of incompatible schema
  pairs, and a lint failing any query touching both members of a pair.
  Decision 016's `party_users`-versus-persons boundary is its first user
  and `party-registry/04` now depends on `foundation/03` accordingly.
  Chosen over a one-off grant because a second boundary is likely
  (verification evidence, safety markers) and when the mechanism is
  schemas plus grants, the general version costs almost nothing more,
  while a second one-off would give one invariant two expressions and the
  cross-schema lint would be written twice.
- **The payload database is authoritative for residency; the column is a
  checked assertion.** Two records of one fact needed a governing rule. The
  column stays because it is what survives a dump or restore, which is
  precisely when the database name is lost, and a check now fails any row
  whose `residency_region` disagrees with the database holding it. Dropping
  the column was rejected. It would make a separated payload dump
  unidentifiable and reverse AC-F4. Demoting the database to a naming
  convention was rejected as undoing decision 011's physical seam.

## 019 — trust-kernel engineering review; 5 → 7 tasks (2026-08-18)

Founder rulings from `/plan-eng-review` over `trust-kernel`. Outside voice:
Codex, high reasoning effort, 12 findings, all sustained; 7 more from the
seam pass. This layer was authored before decisions 015–018, so several of
its statements had gone stale rather than being wrong when written.

**The key identifier moves into the signed payload.** The layer and design
§3.2 both said `kid` is a JWS header field; `contract/CONTRACT.md` rule 3
freezes the protected header to **the exact 15 bytes** `{"alg":"EdDSA"}`,
compared byte-for-byte. There is nowhere in the header for it. Ruling: the
key identifier is a **signed payload field**, which places key identity
inside the signed bytes. Nobody can change which key a record claims
without breaking the signature. Amending the contract to admit a two-field
header was rejected: it invalidates every golden vector and the byte-
exactness is deliberate (seven ambiguity resolutions were recorded to reach
it). An unprotected header was rejected outright. Unsigned key identity is
the substitution attack the registry lookup exists to prevent.
**Consequence requiring separate action:** `model/attestation-interface.md`
(schema_version 0.2, ratified in decision 006) must carry the field. Not
amended here; flagged as an interface change needing its own ratification.

**Signing takes no key parameter.** `sign(kid, bytes)` made "no non-operator
key is invokable", a runtime string check, the exact regression decision 016
wanted structurally prevented. Ruling: `sign(bytes)` returns the signature
plus the key identifier used; key selection and rotation are internal to the
operator provider. With no key parameter, the wrong key is **unexpressible
rather than rejected**. A typed-handle variant was rejected as a
handle-producing function one careless addition away from producing a handle
for anything, and as a parameter whose only valid value is always the same.

**Chains cover every governing event, not only attestations.** D3's anchored
contents are broader than the attestation record, and **D4's dispositive
argument depends on registry manipulation being visible in the log**, which
is false if registry events are unchained. Added streams: registry and party
lifecycle events, key events, privileged operator actions, deletion journal
entries. An audited-but-unanchored operator action is alterable by the
operator, and the operator is the party a dispute distrusts.

**Chain membership is fixed at write time and never re-keyed.** "Chain
integrity holds on every stream" was untestable because nothing said what a
subject chain is keyed to after a merge. Ruling: a record stays forever in
the chain keyed to the `ledger_person_id` live when it was written; merge
adds alias resolution *above* the chains and moves nothing. Re-keying the
absorbed chain was rejected because it rewrites records already hashed into
published checkpoints, breaking every existing inclusion proof and
contradicting the append-only foundation. A single chain over the alias
closure was rejected because chain identity would then depend on merge
state, making verification time-dependent and unmerge a chain split. Cost
accepted: a merged person's history is a multi-chain walk combined at the
resolution layer; unmerge is trivially correct in exchange.

**Anchoring and acknowledgment are two different moments, stated.** A spine
row whose payload apply is still in flight (decision 017's outbox) **is
anchored**. Coupling the ≤5-minute cadence to a background worker would let
a retry loop stall a launch-blocking commitment. The signed receipt to a
party fires on the acknowledgment watermark instead. Anchoring proves
ordering; acknowledgment proves durability. Anchoring only acknowledged
records was rejected on the cadence-coupling ground; issuing receipts at
spine commit was rejected as reversing decision 017's acknowledgment rule.

**D3's checkpoint requirements were mostly unwritten, and the layer split on
the cloud-ruling line.** `trust-kernel/04` specified the tree and a local
WORM stand-in; D3 also requires each checkpoint to **name its predecessor**,
a **continuous reconciliation job**, signed receipts at ingest, a dedicated
compliance-mode object-lock account, and a second-cloud mirror, so AC-TK3
could not be met by what the task described. Predecessor chaining and
reconciliation are pure logic and stay in `04` (the predecessor is a format
decision: deferring it means the first checkpoints are written in a format
that must change). The real publisher, mirror, and anchoring drill become
**`trust-kernel/07`**, founder-gated on the cloud ruling. Noted for that
ruling: D3's text names AWS compliance-mode Object Lock specifically, so a
GCP outcome must address the equivalent control and any capability gap
explicitly rather than silently.

**The independently-authored reference model becomes `trust-kernel/06`.** The
layer promised it and AC-TK1 referenced it; no task created it. Golden
vectors cannot substitute. **The vectors are generated by the implementation
they test**, so a contract misreading baked into the generator produces
vectors that agree with the bug. The task is dispatched with explicit
instruction not to read `core/kernel/`: independence is enforced by
assignment, because one author writing both shares the misreading twice.
Folding it into `01` was rejected for that reason.

**The 3k line budget holds; orchestration moves out.** The budget bounds what
gets two-human review, fuzzing, and formal specs. It does not measure the
layer. Frozen core: canonicalization, sign/verify, chain append/verify, tree
construction and proofs. Kernel-adjacent, ordinary review: scheduler,
publisher, reconciliation, per-party root assembly. Raising the cap was
rejected because strict review over a two-thirds larger surface becomes
perfunctory, and a budget that moves when inconvenient is not a budget.

**Corrections applied.** AC-TK5 narrowed to **non-operator** party keys
(decisions 015/016 gave the operator a self-entry it signs with; the old
absolute wording was false). Layer and task `binds` extended to 012, 015,
016, 017, 019. `0007-stream-heads` re-licensed as a **named, role-scoped**
exemption. Decision 017 dropped foundation/03's blanket derived/cache
clause, so the table can no longer claim it; foundation/03's exemption list
now names it alongside `party_users` erasure and the payload purge role.
Layer no longer claims inclusion *receipts* (kernel provides proofs;
`ingestion` issues receipts) and no longer says "KMS-only" custody, which
contradicted decision 011's software provider for local/CI. Two-human review
acceptance now checks the **host branch-protection policy**. CODEOWNERS
requests reviewers, it does not require them, and a synthetic PR in local CI
cannot prove a rule living in the host's settings. The **per-party issuance
root relocated** from `party-registry/07` to `trust-kernel/04` under decision
015's boundary rule; party-registry consumes the API. `trust-kernel/05`'s
dependencies corrected: Spec B models deletion, purge, restore replay, and
alias-closure key destruction, so it can no longer depend on
`trust-kernel/03` alone. It now declares `foundation/08`,
`person-identity/06`, and `consent-and-deletion/01`, and its invariants gain
decision 017's surface (alias-closure key destruction, purge never partially
observable, an unreplayed restore cannot serve a read).

Consequences: `trust-kernel` is 7 tasks; AC-TK6 and AC-TK7 added;
`foundation/03`'s exemption list extended; `party-registry/07` amended;
`model/attestation-interface.md` needs a key-identifier field, tracked as an
open interface amendment.

## 020 — person-identity engineering review (2026-08-18)

Founder rulings from `/plan-eng-review` over `person-identity`, the last
decomposed layer. Outside voice: Codex, high reasoning effort, 16 findings.
This layer was authored before decisions 015–019, so most of its defects were
staleness rather than error at authoring.

**The safety-marker match key must be a keyed hash.** `person-identity/07`
said `document_identifier_hash` and stopped. Document identifiers are
**low-entropy and follow published per-country formats**, so a plain hash is
enumerable: generate every valid number for a jurisdiction, hash each,
compare. The marker table would become a de-anonymizable list of who has
been flagged. The structure the AEPD fined Goldcar over, and exactly the
re-identification capability decision 014's *EDPS v SRB* analysis identifies
as what makes a value personal data. Ruling: keyed hash with **the key in
the key management service, never in the database**, plus the parts that
were missing entirely: issuer and document-type canonicalization (one
document written two ways must yield one key, or matching does not work),
a key-rotation and re-derivation story with a stated window, a collision
policy, and a written brute-force analysis against the weakest
jurisdiction's format. A stored salt was rejected: a salt sitting beside the
data does nothing against an attacker holding the table.

**The recovery freeze had a time bomb.** A deletion requested during the
7-day freeze was to execute automatically at expiry. So an attacker
recovers the account, requests deletion, waits a week, and the system
destroys the record for them. The exact attack the freeze exists to stop,
merely delayed, and the task's own outside check would have passed. Ruling:
the queued deletion **requires fresh authenticated confirmation after
expiry**. A legitimate owner is never permanently blocked, which was the
reason for queueing rather than rejecting; an attacker who has lost access
by day seven cannot finish. Notifications at request, at expiry, and before
execution.

**One-time-code sessions get step-up on a closed sensitive set.** The code
path is first-class by design, but nothing said what such a session may do.
If it can enroll a passkey, change channels, create grants, request a
packet, or start a deletion, then AC-PI2 is performative. An attacker never
needs the hardened recovery path when ordinary login reaches everything.
Ruling: those five operations require a session whose assurance **matches
the account's derived level**, reusing the concept recovery already uses
rather than running two systems with a gap between them. Credential
enrollment is on the list deliberately: it is the takeover primitive, since
it converts a temporary session into permanent access. Everything else stays
frictionless from a code session.

**AC-PI4 was false and is split into four cases.** It promised a clean
cold-start with "no linkage artifact" after deletion; decision 014 creates a
usable-but-restricted account on a live marker match plus internal linkage
and a steward flag. New criteria: unmarked deletion (truly clean), live
marker (restricted pending review, never denial), **expired marker (clean,
marker inert)**, the case where an expiry bug would otherwise hide forever,
and prior-merge history. The layer's "never fresh-start prevention" line and
its `decisions/LOG.md#009` binding are both corrected; 009(a) was superseded
twice over.

**The merge event appends to both subject chains.** It was recorded only in
the survivor's chain, leaving the absorbed identity's chain with no evidence
of the event that changed its resolution. Decision 019 made chain membership
permanent, which makes this final: a merge absent from the absorbed chain
would never be recorded there. An auditor walking either chain alone must
see a complete story. Unmerge likewise appends to both.

**Names get explicit generous bounds.** "No length cap" is not an
implementable instruction: a column, a rendered packet, a search index, and
an abuse check on worker-submittable free text each need a bound, and absent
one the first oversized input decides the behavior in whichever component
fails first. The model's principle was that no *cultural structure* is
imposed, not that no limit exists. Bounds are stated with reasoning at the
schema site, and over-length input is **rejected loudly, never truncated
silently**. Silent truncation is the precise harm the model exists to
prevent.

**Corrections applied.** Layer `binds` moved from `#009` alone to 013, 014,
016, 017, 019, 020. `person-identity/01` gains `foundation/07` (signup
writes both planes) and defines "instantly" as spine commit, with payload
following through the outbox. Three different claims were hiding in one
word. `person-identity/06`'s "permanent alias table" with a flipped pointer
becomes **append-only alias events plus a named, role-scoped projection
exemption**, since decision 017 removed the blanket derived/cache license.
`06` also gains the deletion-under-merge obligation: it owns the alias
closure, so it owns proving the deletion subsystem receives the correct one
under a merge-or-unmerge racing a deletion. `07`'s `challenge_state` becomes
**append-only challenge events**, a mutable field on an append-only marker
row is a contradiction, and marker filings and steward approvals join the
chained and anchored governing-event set from decision 019. `07`'s raw-dump
deletion assertion is replaced by decision 017's full evidence set.

**Recorded disagreement with the outside voice.** It called tasks declaring
dependencies on unauthored layers "fake readiness." Rejected: `plans/ORDER.md`
computes blocked from `depends_on` and never stores it, so `ready` with an
unmet dependency is the model working, not a defect. The dangling references
are tracked and discharge when those layers are decomposed.

Consequences: `person-identity` stays 7 tasks; AC-PI4 replaced by AC-PI4a–d;
AC-PI5 added.

## 021 — THESIS.md adopted as the identity layer's topline vision (2026-08-18)

Founder rulings from the thesis grilling. `THESIS.md` rewritten the same day;
prior draft's self-description was wrong and is superseded.

- **Authority.** The thesis is the topline vision for the identity layer.
  Where a plan disagrees with it the plan is flagged, and usually the plan
  changes. It does not silently override ratified mechanics. A conflict with
  `model/attestation-interface.md` or `contract/CONTRACT.md` is a defect
  resolved by a decision entry, not by whichever file was written last.
- **The draft header claiming it "supersedes nothing" is struck.** It was
  attempting to encode drafting immaturity and instead encoded a false
  authority ordering.
- **Scope is the identity layer.** Dispatch holds its own thesis, aligned.
  Identity is the platform; adjacent businesses are secondary to it.
- **`handoff/founder-thesis.md` is stale**, marked as such in its own header,
  and superseded on every point where the two differ: notably its placement
  of commodity assessments on the buy-don't-build list, and its framing of the
  four verticals as the primary object.
- **Correction of record.** The prior draft cited three rulings dated
  2026-08-18 that this log does not contain (worker analytics visibility, EU
  high-risk status, outcome facts). None had been recorded. The EU material is
  a research conclusion and is now labelled as one; the remainder are ruled in
  entries 022–024 or left explicitly open.

## 022 — Analytics is the first product; grading rulings (2026-08-18)

Supersedes the draft thesis position that an independent measurement
instrument is a precondition for selling grading.

- **Analytics on work history and trajectory ships from day one** and is
  likely the first thing sold. It runs on partially verified history.
- **Input set**: work history at whatever verification level exists; skills
  assessment results where any exist; performance in Grain's courses or
  others'; structured references (entry 023); and observable meta-signals:
  average tenure in role, described responsibility, seniority.
- **Every input is weighted by provenance class.** A self-asserted history and
  a party-attested one never carry equal weight.
- **Party quality scores do not feed grading.** They are incomparable by
  construction; grading on them would launder other employers' judgments.
  They persist so the issuing party can read back its own judgments and so a
  reader can see that evaluation occurred.
- **Confidence gating.** Early output is weak and says so. Below a threshold
  the product returns insufficient data and suggests an assessment rather than
  producing a number. **OPEN: the threshold itself**, and whether it is
  published.
- **Slope ships with its limits disclosed.** The three known failure modes
  (routing flattens raw grades while ability rises; frozen difficulty priors
  read promotions as decline; grader drift tracks the trend being measured)
  are stated on the face of every trajectory output. The fixed instrument is
  hardening, not a gate.
- **Assessment is demoted** from "the instrument" to one candidate instrument
  and a likely second product. Identity depends on neither it nor placement.
- **Run records are retained.** Requesting party, timestamp, input references,
  instrument and model versions, output; held for the compliance period,
  reachable by regulator and audit, and by no read path touching ranking or a
  worker's packet. Nothing derived becomes a fact about the person, which
  keeps the `plans/foundation/06-checks-port.md` ban intact.
- **Workers do not see when analytics are run on them.** They see raw work
  history and facts. Recorded as a deliberate cost and the largest departure
  from the worker-ownership story.
- **Worker-facing job-match suggestions** are permitted in principle: ranking
  roles for a person, never candidates for a partner, and no Grain-computed
  ranking is transmitted to a partner. Longer-term surface: build
  compatibility, do not build first. **OPEN: employer-side matching.**

## 023 — Structured references and attester trust (2026-08-18)

New day-one mechanism, absent from the interface and every plan.

- **Candidates solicit references** from people who managed them. Grain
  designs the form and the fields; responses are structured throughout with
  **no free response**, because free text adds noise to every downstream use.
- **A reference is tied to a real person profile** and carries its own
  provenance.
- **Attester trust is tracked over time.** Veracity **events** are stored as
  facts: this attestation was found falsified, this one corroborated, and
  the trust weight is **derived at read time** from those events. Storing the
  events rather than a computed score is what keeps this compatible with the
  interface rule that derived estimates never enter as fact.
- **Blast radius.** The weight's primary effect is to down-weight the
  provenance of what that person attests, then and in future. It may
  eventually surface in secondary scores; never a primary one.
- **OPEN, and a counsel item: what survives profile deletion.** The mechanism
  requires falsification history to outlive a deletion, or falsification is
  erasable by re-registering. That collides with R2 (entry 003) and with entry
  013. Candidate shapes considered and not ruled: a minimal veracity record
  keyed to a salted identity commitment, or nothing surviving about the person
  at all with only the counterparty's own flagged attestations persisting.
  Until ruled, this mechanism is not buildable.

## 024 — Record-layer and posture rulings (2026-08-18)

- **The record layer is free to everyone, permanently**, candidates and
  employers alike. The compiled data is the asset, not access to it. Consistent
  with entry 002's "no economics embedded": the thesis states the layer is free
  and carries no pricing.
- **Visibility is worker-controlled.** Private by default; the worker consents
  to sharing with a specific party, may publish a public record, and may use
  the record to apply for work. "Universal" describes the right to hold a
  record, not default readability of its contents.
- **Write incentive: embedded in the partner's workflow.** Attesting must be a
  byproduct of work the partner already does. Contractual reciprocity is the
  backstop; Grain's own verticals seed the graph meanwhile. Nothing is designed
  yet.
- **Nobody re-inks the mark**, third-party embeds and Grain's own verticals
  alike. Supersedes the draft thesis's asymmetry, which justified Grain's own
  re-inking by ownership and thereby undercut the neutrality argument it sits
  beside.
- **EU posture: build with the constraints in mind, do not build for the EU
  market first.** Same posture for worker-facing job suggestions.
- **Neutrality is contractual, not structural.** Grain both holds the record
  and operates verticals on it, so neutrality rests on contract, published
  rules and audit rather than corporate separation. Stated as the weaker
  guarantee it is. **OPEN: the trigger** at which structural separation becomes
  necessary.
- **Not ruled, carried forward:** whether "has listed references" is scored as
  capability or reported as record completeness. Omitted from the §5 input list
  pending a ruling.

## 025 — Attester trust withdrawn; decision 023 superseded (2026-08-18)

Supersedes entry 023 in full. 023 is restated here rather than partially
amended, because a supersession that leaves half an entry standing is what
misreads an append-only log.

**Attester trust is withdrawn.** 023 required a person's falsification history
to outlive their profile deletion, so that a manager who falsified a reference
would be trusted less across the network afterwards. Entry 014 had already
ruled against exactly this shape and the reasoning was not revisited when 023
was written: default is that nothing survives deletion, and **performance-based
exits leave no token, no hash, no marker**. Attester trust does not fit 014's
severity-gated carve-out on four counts: the marker is keyed to a document
identifier with no payload, carries a fixed expiry, requires an evidential floor
of "could confidently report to the police", and produces **review, never
denial**, whereas attester trust produces automatic network-wide down-weighting
with no expiry. 014's own escalation #2 anticipated the structure: a
cross-employer record carrying an exclusion flag is a blacklist and will be read
as one.

`research/13` closes the remaining argument. **AEPD PS-00176-2024 (Iberia
Cards)** fined a controller that retained precisely the minimal link needed to
recognise a returning applicant and used it against them, an Article 6(1)
infringement, with no fraud and no safety involved.

**Consequences.**
- `peer-references` keeps its Sybil apparatus: reciprocity caps, velocity
  limits, device/IP clustering, verified-anchor weighting, `excluded` grading,
  the shadow/promotion gate, which already addresses the abuse case that
  motivated attester trust. It loses veracity events and read-time trust
  derivation.
- Serious falsification routes to entry 014's existing safety marker. Below that
  bar, evidence of a bad reference is deletable by either party. Accepted.
- `operator-console` AC-OC4 returns to its pre-023 wording; the conflict it was
  provisionally reworded around no longer exists.
- The `foundation/06` schema-grep addition for trust scores stays. It costs
  nothing and the failure it catches is now unlicensed rather than merely
  bounded.

**Restated and still binding from 023: the reference form.** Candidates solicit
references from people who managed them. **Grain designs the form and the
fields**; responses are structured throughout with **no free-response field**,
because free text adds noise to every downstream use and is unusable as an
analytics input. A reference is tied to a real person profile and carries its
own provenance.

## 026 — Analytics run records hold the run, never the output (2026-08-18)

Supersedes the run-record ruling in entry 022. The rest of 022 stands.

022 ruled that an analytics run record retains "requesting party, timestamp,
input attestation refs, instrument and model versions, and **the output**" for
"the compliance period". `research/13` and `research/14` establish that the
output may not lawfully be retained about a person who has deleted, and that no
regime surveyed requires it.

**The AI Act does not compel it.** Art. 12(1) is a design duty, the system
"shall technically allow for" logging, not a retention duty. Art. 12(3) is the
only provision itemising log content, including input data, and it applies only
to Annex III point 1(a) biometric identification. Grain is Annex III point 4, so
**no minimum log content is prescribed at all**. Art. 19 is the sole retention
duty: a six-month floor, risk-based, expressly subordinated, "unless provided
otherwise in the applicable Union or national law, **in particular in Union law
on the protection of personal data**". A provision that yields to the GDPR
cannot be the Art. 17(3)(b) legal obligation that displaces a GDPR right. Art.
17(3)(b)'s "to the extent that", Art. 6(3) with Recital 41, and *Digi* (C-77/21)
and *SS SIA* (C-175/20) each independently confine it further.

**No other regime asks for it either.** Colorado SB 26-189 §6-1-1702(4) imposes
a three-year retention duty directly on Grain as developer, but over **system
version identifiers, changelogs, and deployer notices**, system artifacts, not
person records. California 11 CCR §7101(e) says expressly that a business is not
required to retain personal information to fulfil a consumer request; §7155(c)'s
five-year duty covers risk assessments about the processing. US federal
recordkeeping binds the employer, not the vendor.

**The ruling.** A run record holds the **requesting party, the timestamp, the
instrument and model versions, and the input references**, and **not the
output**, and nothing else attributable to a person. It is reachable by
regulator and by audit and by no read path that touches ranking or a worker's
packet. Retention is six months minimum per Art. 19, with the period stated as a
number rather than as "the compliance period", which resolved to four different
periods across the regimes surveyed.

**Two open items this creates.**
- **OPEN: the pseudonym.** Pseudonymised run records work only if the pseudonym
  is not the `ledger_person_id`. Entries 013 and 020 make tombstoned ids
  permanent and referenced in spine signatures forever, which is a retained
  means of singling out (EDPB Guidelines 01/2025). What identifier a run record
  carries is undesigned.
- **OPEN: the architectural fork.** Under `foundation/05` a run record either
  sits inside the subject's DEK envelope, dying at deletion and breaching Art.
  19, or outside it, surviving readable and unlawful. It must be split
  spine-side and payload-side, and no task owns that.

**Recorded, not ruled.** Two findings from `research/13` and `research/14` that
belong to the founder and are not decided here: worker-facing job suggestions
match 42 U.S.C. §2000e(c)'s definition of an employment agency, "to procure for
employees opportunities to work for an employer", which would make Grain a
covered entity in its own right rather than a vendor supplying documentation to
one; and a cross-employer performance register is a labour-market information
exchange under the January 2025 DOJ/FTC guidelines, where third-party
intermediation is expressly not a defence. Both are in `ORDER.md`'s gate table.

## 027 — Mark, pointer and imprint constraints settled (2026-08-18)

Recorded in `mark/README.md` and `DESIGN.md` §3; generator and assets in `mark/`.

**The mark.** Three concentric threaded bands, seven lobes, unequal band widths,
one lobe deliberately deepened. Provisional. The lobe count may change and the
generator is parameterised accordingly. Four purpose-drawn size tiers; scaling
the master is what fails below ~40px. Dark renders stronger than light under
~120px.

**The verification mark is a POINTER, not a badge.** It says "this person has a
record you can inspect", never "this person is verified". A badge collapses a
graded epistemic claim into a yes, which is the credential logic this product
exists to replace. Permanently prohibited: filled disc, shield, ring, container,
checkmark, lobed disc at badge scale, any rendering larger than the adjacent
name's cap height. On third-party surfaces the pointer must carry a count; on our
own surfaces context does that work and it may stand alone.

**Two binding laws added to `DESIGN.md` §1**, reasons recorded in the text so they
survive editing: size never scales with career length (footprint that grows with
tenure is an age proxy, and an age proxy on a hiring surface is a discrimination
exposure); absence of attestation is never drawn as diminished magnitude (pale and
thin read as *lesser*, not *unconfirmed*).

**Open.** The lobe count; the break angle, which should be locked to the top; and
the collision between the no-centre rule and the imprint's identity core, which is
inked at signup and carries the empty state (`imprint/README.md` §7).

**Unverified.** A second independent pass could not confirm the Smart Seal
registration (Reg. 7142020) recorded in earlier research. Verify against the
register before relying on it.

## 028 — Founder grilling: next-block rulings (2026-08-18)

Thirty-two questions across five rounds. Design proceeds; the two unruled legal
findings in entry 026 stay open and are not treated as blocking. Order of work:
**schema, then wordmark, then the worker core screen and the grant flow.**

**Identity and access.**
- **Login with Grain is an identity provider**, behaving like Login with Google or
  LinkedIn. A separate consent screen appears only if the service also wants the
  record. Same button on partner sites and on our own verticals, with no
  privileged access for the verticals.
- **Partners receive a per-partner pairwise pseudonym**, never `ledger_person_id`.
  This also closes the pseudonym open item in entry 026: the ledger id never
  leaves the system, so it cannot become a cross-service correlation key.

**The record.**
- **The chapter is the atom, and tenure is the relationship with the party.** A
  task platform worked sporadically is one chapter spanning the whole
  relationship. A chapter ends when the relationship ends, not when activity
  pauses. Rehire starts a new chapter.
- **Promotions and position changes sit inside the chapter**, drawn as a division
  within the band, spaced tighter than the gap between chapters.
- **Résumé upload auto-creates chapters as self-asserted**, reviewable before
  commit.
- **Once work history is added, only minor edits are possible.** Removal requires
  contacting support with a justification. Coherent with decision 003: the worker's
  exit is all-or-nothing, whole-profile deletion remains available at any time,
  but individual chapters cannot be quietly excised.

**Attestation.**
- **Partners write freely. No worker countersign.** Founder ruling: the employer is
  inherently more trustworthy. Consequence to design for: GDPR Art. 16 gives a
  right of rectification regardless, so a correction path must exist, it moves
  from a countersign gate to a post-hoc dispute.
- **The party registers, not the person.** Attesting from a registered party's
  verified domain is a signed link and one click, no account. An individual with no
  registered party must create an account and attests as `peer_attested`, carrying
  less weight. Friction lands where trust is lower. Supersedes the account-required
  shape carried over from the hospitality product.
- **Unregistered former employers are permanent `peer_attested`**, so workers with
  informal employment history are not locked out of having a record.

**Disputes.**
- **Grain adjudicates authenticity, never substance.** Whether an attestation was
  genuinely signed by that party, whether it is a duplicate or spam: yes. Whether
  a performance claim is fair: never. Reason: FCRA §611 requires a consumer
  reporting agency to conduct reasonable reinvestigation of disputed information;
  performing substantive reinvestigation voluntarily is a defining CRA duty and
  cuts against the R1 posture in decision 003.
- **Disputed claims stay visible and marked**, with the worker's statement attached,
  never silently removed.

**Sharing.**
- **Public URL**: verification status and work history, social-profile shaped,
  worker-customisable.
- **Custom share link**: full record including the imprint. Sensitive, carries a
  warning, expires by default, revocable, and the worker can see every link issued.

**Verification tiers.** Four internally: recorded, contact, document, biometric.
**Only two surface to partners: identity verified, or not.** Document is the line;
contact tier is the most likely to be misread as meaning more than an email
round-trip. Biometric stays opt-in for a stated reason, given BIPA, the EU AI Act
and separate regimes across target markets.

**Schema standards.** W3C Verifiable Credentials 2.0 for the envelope, our own
payload, ESCO for `work_kind` vocabulary. Open Badges 3.0 and 1EdTech CLR rejected
as payload: they are shaped around achievements conferred by an issuer, which is
the credential model the thesis attacks. Known weakness: ESCO's coverage of
informal and platform work is thin and will need an extension mapped back to it.

**Design.** Light by default, dark fully supported. Core screen order: imprint,
outstanding verification, work history, sharing, identity.

*Numbers 029 and 030 were never assigned. They were consumed in the 2026-08-19
two-checkout collision and lost in the reconciliation (entry 042). The gap is
permanent; do not fill it.*

## 031 — Ingestion is worker-initiated; the employer-push shape is withdrawn (2026-08-19)

Ruled while designing the seam between the identity layer and the hospitality
vertical. **Supersedes the design considered earlier the same day**, in which
employers connected their HR systems and Grain held verified employment records
about people who had not signed up, for those people to claim later.

**The mechanic.** A worker creates a Grain identity themselves. They assert a
chapter: employer, role, dates, which enters the record as `self_asserted`.
They then request verification from that employer; the request is timestamped
and carries a `verification_request_id`. The employer confirms against its own
roster, through a connected system or a human, and signs an attestation. The
attestation enters the ledger; the employer's roster row never does.

**Why the earlier shape was withdrawn.** Research filed the same day as
`research/15` (EU/UK) and `research/16` (US), evidence tier:

- **US, high confidence: the employer-push shape makes Grain a consumer
  reporting agency.** Pre-claim collection removes the last non-frivolous
  argument. FTC comment 603(d)(2)(A)(i)-1E holds that a reference communication
  from an employer is excluded but the same information from a CRA to a
  potential employer *is* a consumer report. Privity runs to the source and
  does not travel with the data. The market has sorted on this axis: the
  employer-pushed platforms are CRAs and the one consumer-initiated platform is
  the only non-CRA claimant. The founder ruled against accepting that
  classification. **R1 (decision 003) is preserved by changing the mechanic, not
  by argument.**
- **EU: no lawful basis for the employer-push shape.** Consent fails twice:
  sought from the wrong person under Art. 4(11), and unfree in the employment
  context. Contract fails on the face of Art. 6(1)(b). Legitimate interests
  fails at the *necessity* limb before balancing, under *KNLTB* C-621/22
  ¶52–53: a controller who could ask first is not processing out of necessity,
  and Grain can ask first.
- **The value was unavailable in any case.** Data protection, competition law,
  AI Act Art. 26(7) and this repo's own ratified schema independently converge
  on the same constraint: no employer may read a record it did not supply
  unless the worker discloses it, and nothing unclaimed may feed analytics.
  The employer-side flywheel the mechanic existed to create could not have been
  built from it.

**Consequences.** The ratified rule at `model/attestation-interface.md`, *"A
person without a ledger ID cannot be attested for; the attestation waits until
the reference exists"*, is correct as written and needs no amendment. The
retention question for unclaimed records is moot. Art. 14 becomes ordinary
Art. 13 notice to a user. Maryland's minimisation standard (Com. Law
§ 14-4607(b)(1)(i)), which benchmarks collection against a service *requested by
the consumer to whom the data pertains*, is satisfied rather than fought.

**This narrows decision 028, which is recorded here rather than left implicit.**
028 ruled that partners write freely with no worker countersign, on the founder's
reasoning that the employer is inherently more trustworthy. A required
`verification_request_id` means a party may no longer originate an attestation
about a subject unprompted. The narrowing is confined to what it must be: **the
worker initiates the first attestation from a given party; that party writes
freely thereafter**, within the relationship the worker opened. The countersign
is still absent. A worker never approves the content of what is written about
them, only whether the relationship enters their record at all. 028's dispute
path remains the correction mechanism.

**One tension put before counsel rather than resolved here.** Decision 022
records that workers do not see when analytics are run on them, as a deliberate
cost. That is the inverse of the FCRA § 1681g(a)(3)(A)(i) recipient-disclosure
duty, and if the CRA question is ever litigated it cuts against the
worker-initiation story. Brief 5 carries it.

**What this does not fix**, and which stands regardless of the mechanic:
antitrust exposure on multi-employer pooling (brief 6, new); the CPPA ADMT
compliance date of 1 January 2027 for the ranking surface; Colorado 4 CCR 904-3
Rule 4.06(D)(4) against R2; and the counsel-brief overlap at 15 U.S.C.
§ 1681h(e), whose qualified immunity runs only to CRAs. Briefs 3 and 4 are
answering one question without knowing it.

**Open, surfaced this session and unruled.** The two marks collide: the
hospitality product renders a badge-position glyph whose rings encode trust tier
("Top trust tier (Mark 2)"), which `mark/README` §4 and decision 027 prohibit
permanently. The vertical distinguishes four evidence states against the
interface's three provenance classes. The hospitality trust computation is a
damped PageRank over a mutable graph, where the interface requires a published
deterministic rule producing identical marks from identical evidence. The
production reference questionnaire carries free text, which decision 025 bans.
The `work_kind` vocabulary conflict between decisions 028 and 006 is still
unruled and still blocks the vocabulary work.

## 032 — The roster firewall (2026-08-19)

`model/roster-firewall.md` 0.1-PROPOSED, adopted as the working boundary
document under decision 031. Not ratified.

**The rule.** Roster data serves the employer's operations. It becomes a
worker's record only when the worker pulls it. What crosses is an attestation,
never a copy.

Two planes: the vertical plane, where the employer is controller and Grain is a
processor for the employer's own staffing purpose; and the ledger plane, where
the worker is subject and Grain is controller. One crossing, at the worker's
request, carrying a `verification_request_id` that is the auditable evidence of
initiation.

**Grain may not prompt the crossing from roster knowledge.** Surfacing "this
employer is connected. Is this you?" requires knowing the worker appears on
that roster. The worker names the employer unprompted, or from a list shown
identically to everyone. This is the constraint that makes the boundary hold,
and it is the one most likely to be removed later as a usability improvement.

**Enforcement is mechanical**, five CI checks (RF-1..RF-5), following the
precedent of Dispatch's AC-04.3 schema-grep and the hospitality product's
shadow-log promotion gate. A firewall enforced by convention is not a firewall.

**Open**, recorded in the document's §9: the negative-answer case; stale and
partial rosters, which are probably the common case in hospitality and would
otherwise read a truthful worker as a liar; the two production schema values
`method: 'employer_roster'` and `confirmedVia: 'roster_attestation'`, which now
mean the opposite of what their names imply.

## 033 — Interface amendments 0.2 → 0.3, PROPOSED (2026-08-19)

Two amendments to the ratified contract at `model/attestation-interface.md`.
**Proposed, not ratified.** Ratification is a founder act and has not occurred.

**A-6: the packet delivers a pairwise pseudonym, not `ledger_person_id`.**
Decision 028 ruled that partners receive a per-partner pairwise pseudonym and
that the ledger id never leaves the system, precisely so it cannot become a
cross-service correlation key. The contract was never updated and still lists
`ledger_person_id` in the down direction. 028 is later and stronger; the
contract catches up.

**A-7: a third `scope` value, `evaluation`.** `scope` currently admits
`engagement` and `period`, both of which describe work performed. Two objects
need a scope that does not exist: a manager's structured reference, and a skills
assessment result. THESIS §5 already records the assessment gap. Both are
statements of *judgment about a person* rather than records of work, which makes
them a scope problem and not a fourth provenance class. The source is already
covered by `party_attested` or `peer_attested`. `evaluation` carries a required
`evaluation_kind` discriminator (`reference | assessment`) and the same signing,
supersession and sensitive-data rules as every other attestation.

Rationale for one scope rather than two: the ledger's reason to distinguish them
is identical, a reader must know that a claim is evaluative before weighing it,
while the difference between a reference and an assessment is a property of
the instrument, which the discriminator carries.

## 034 — Dispatch conventions bind; standardization pass (2026-08-19)

Three read-only audits compared this repo against Dispatch across structure and
documents, the plans and checks system, and git history. The binding
declaration below is **proposed and awaits founder ratification**; everything
else in this entry is already applied.

**The contradiction, resolved.** `handoff/HANDOFF.md` offered Dispatch's
conventions as "offered, not mandated"; `plans/ORDER.md` recorded the protocol
as "adopted from Dispatch verbatim". Nothing stated which governed, and no
`CLAUDE.md` or `AGENTS.md` existed to say. **They bind. ORDER.md governs.**
Divergence from Dispatch remains legitimate, several existing ones are
improvements, but an unrecorded divergence is drift, and a deliberate one now
requires an entry stating its reason.

**`CLAUDE.md` written, `AGENTS.md` symlinked to it**, matching Dispatch's
arrangement. It carries the product test, the constraint that outranks
convenience, the plan gate, the counts rule, and, the thing this repo most
lacked, **a source-of-truth precedence list**: CLAUDE.md, then
`decisions/LOG.md`, then `model/`, then `THESIS.md`, then code. An agent
holding a draft thesis, a draft design system, a `model/` mixing RATIFIED with
PROPOSED, and a 1,600-line log previously had no rule for which wins.

**`plans/ORDER.md`'s naming section was a lossy copy and is now complete.** It
had the branch pattern, the commit form and the type vocabulary; it dropped
names-are-derived-never-invented, "no descriptive words", lowercase/present
tense/no period, "a change with no clear type is two changes", the log-file
rule, the migration rule, and all three verbatim PR-body headers, which existed
nowhere in this repo. Added alongside them: the status fence (a tool may
rewrite `status`, `evidence`, `verified_by` and nothing else) and the
verification-record form, which was undefined and would have been invented by
whoever verified first.

**The grammar binds from today forward.** History conforms on 2 of 25 commits;
Dispatch runs 95.3% across 193. The 22 non-conforming subjects are **not**
being rewritten. That means force-pushing a published branch, and evidence
cites SHAs rather than subjects, so nothing depends on them.

**Applied elsewhere.** Every `research/` memo now carries the evidence-tier
statement; thirteen lacked one and the rest used six different forms.
`handoff/attestation-interface.md` is labelled superseded, as its sibling
`founder-thesis.md` already was. `README.md` was the word "identity" three
times and is now the repository map. The hand-written count in `mark/README.md`
said three objects above a five-row table. `foundation/06` gains
`verbatim-copies.mjs`, in Dispatch the precondition for quoting any constraint
into a plan file, and its absence is what makes quoting look free, and a new
counts check.

**Six acceptance criteria repaired** (AC-V2, AC-V3, AC-TK3, AC-IS4, AC-PW2,
AC-F3), each of which was neither mechanical nor adjudicable and so was not a
criterion. AC-F3 is split: its mechanical half stays, and the judgment half
becomes **AC-F8**, adjudicated, so the lint can no longer be reported as
discharging the correlation review.

**Open, and each needing a call rather than a fix.** Five criteria cite
artifacts this repo does not contain: AC-DL4's SLOs, AC-AN4's slope
disclosures, AC-ME4's conformance annex, AC-IS1's dependency on another repo's
team, and worker-surface's, untouched here because a concurrent session holds
that layer. `satisfies:` is absent from all 55 plan files, so no task claims
any acceptance criterion and nothing computes whether a layer is discharged.
This is the largest remaining gap. Also open: whether `decisions/LOG.md` splits into
one file per entry as Dispatch does, which is what produced two numbering
collisions in one day; whether a `model/invariants.md` promotes the fourteen
unnumbered binding claims stranded in `plans/`; whether `design/` stays a
catchall; and whether `contract/` should be renamed, since it collides with the
boundary contract in `model/`.

## 035 — Worker app information architecture; twelve amendments (2026-08-19)

Founder grilling across nine rounds, closing the app's structure end to end:
home, first open, page inventory, settings, the public profile and its handle,
and private full-record sharing. Full IA in `design/06-worker-app-ia.md`.
Several rulings **amend or reverse earlier entries**; those are enumerated in
§B and the affected files are amended in the same commit.

### A. New rulings

**Structure.** No tab bar at v1. The record is the app, and sharing is a
section inside it, not a destination. There is no Activity surface: every event
already has a home (a read is grant state in Sharing, an attestation blooms the
chapter and leaves outstanding verification, a dispute marks the chapter).
Unseen changes surface as the record's own changed state, the plate footer's
last-entry line, and an OS push deep-linking to the changed object. No badges,
no counts. **Work and Earnings are reserved as the third and fourth
destinations**; the bottom bar appears when they do. The record's edge index is
intra-record navigation and is unaffected by that later addition.

**Earnings and the money perimeter.** Earnings, when it exists, is a read-only
view over a vertical's or a licensed partner's payment records. `research/08`
§5.2 C1 ("no funds, ever, in the ledger entity") is recorded as **current
posture, not a ruling.** Decision 010's entity-level open item stands. Nothing
is designed into the slot until it is closed.

**First open.** Identifier (email or phone, verified control of one) → full
name, one free-text Unicode field → the consent instrument, six mechanics as
ledger rows with the deletion control linked → account exists → empty record →
first chapter, added or imported → handle claimed, prefilled by transliteration.
Document proofing never appears in signup; it is gated to the first
value-bearing action. Per `research/11`, neither identifier is a uniqueness key.

**Someone arriving from a shared link runs the same flow and unlocks at account
creation.** They land on the profile they came for, and the empty canvas is
what they meet on leaving it.

**Safety is expressed structurally, not in copy.** `DESIGN.md` §12 forbids the
usual instrument, so: permanence is shown before commitment and never after;
commitment is progressive (no document at signup); the person's name renders at
full size in their own script, which `research/11` argues is not cosmetic for a
population credential systems routinely fail; and the deletion control is linked
from the consent instrument so the exit is seen once at the start.

**The record page.** Identity and the imprint compose as one hero, name and
portrait with the figure, per `DESIGN.md` §8's existing pairing rule. Audience
lives on the object: a chapter carries a mark **only while a live grant covers
it**, and shows nothing when nobody can see it.

**The expanded imprint closes `imprint/README.md` §7.1** (the missing angular
anchor). Full-screen, interactive: dimension slots light one at a time under
touch with name and attained level; tapping a ring walks that dimension outward
across the career. The small figure stays unlabelled. Labels earned by
interaction are not a legend, and the ban in `design/01-banned-patterns.md`
stands for printed ones.

**Dimension standing** is pushed from chapter detail, one deliberate step past
the figure, never a tab, never a landing surface (`design/05` §2).

**The handle.** `hiregrain.com/u/<handle>`; a dedicated identity domain is
recorded as a possible pre-launch requirement, with the never-reissue rule
making a later 301 free. Latin-only `[a-z0-9-]`, prefilled by auto-
transliteration and never rejected; claimed in onboarding **after** the record
exists (no handle without a record). **Changeable but never released**: retired
handles redirect permanently to the same person and are never reissued to
anyone. Reasons: the consumer precedent (LinkedIn, X, Instagram, GitHub all
release handles back to the pool) is wrong here because the handle points at a
permanent work record used in hiring, so release is an impersonation vector; and
immutability is wrong because `research/11` requires name changes be appends
with prior names never surfacing in employer-visible views, which an immutable
handle would violate permanently. Collision alternates are non-numeric.

**The public page.** Whole record or no record. No per-chapter curation on any
surface. The only lever is the imprint, full or absent, nothing between.
**Always indexed**, but crawlers and logged-out visitors receive a reduced page
(name, verification status, chapter list without detail); **the imprint is
always behind sign-in** even when published, because an indexable imprint is the
seven-dimension exposure at its widest. Viewing requires an account. The worker
sees a recent view count and never viewer identities. Naming viewers turns the
page into a social product and creates the coercion hazard `design/05` §3
records for Dubai and Bengaluru.

**Private sharing.** A grant is whole-record, always. The public page and a
grant divide by **depth, not selection**: the page carries what is true
(chapters, parties, dates, provenance, optionally the imprint); a grant carries
that plus what each party attested, dimension standing, dispute state and
superseded versions. Expiry mandatory, revocation one action.

**At grant creation the worker is told plainly that the recipient receives full
work-history detail and may ask Grain to analyse it.** Stated as what the
recipient gets, not as a warning, and not framed as a hazard.

**Settings** is a header sheet, not a destination: Account (name, phone, email,
identity tier, handle), Notifications, Language, Your data (export, disclosure
record, delete everything), About. Deletion runs a grace window: access ends at
the request, data at the end of the window, signing back in cancels.

**Accounts.** One account type for everyone. A basic account is required to
view; document tier remains the worker's own identity-verified status.

**The attester ladder.** Attester weight derives from relationship and verified
employment, not from identity tier: **coworker · manager · partner employer
account**, where a manager verifies employment at the party with a work email.
That verification is the same event as employment-verifying **their own chapter**
at that party. Vouching for someone verifies you, which is the product's
primary growth loop.

**The imprint geometry is unchanged.** Three thread densities stand; the finer
ladder lives in the rows and the expanded view. The figure states how well
something is known; the record states who said it. This protects the one channel
`imprint/README.md` §7.4 records as never tested with humans at size.

**No dispute UI in the worker app.** The chapter renders its `disputed` field
because that is a record value. Intake and adjudication sit outside the app.

**The guidance surface is out of v1** (`DESIGN.md` gap 14). Outstanding
verification already does the only prospective work v1 needs.

### B. Amendments to earlier entries

1. **028's core-screen order.** Was imprint · outstanding verification · work
   history · sharing · identity, on the reasoning that identity is settled once
   and then irrelevant. Now **identity + imprint (composed) · outstanding
   verification · work history · sharing**. Reason: the returning-user argument
   was right and the new-user one was not. Landing on an abstract figure with
   your name at the foot of a scroll is the coldest possible opening for someone
   already nervous about recording their information anywhere.
2. **028's attestation line.** *"Attesting from a registered party's verified
   domain is a signed link and one click, no account"* is **reversed**. Every
   attester holds an account with verified identity. The friction argument
   survives in a different form: friction now scales with the attester ladder in
   §A, not with account-versus-no-account.
3. **`model/record-schema.md` §5**: `grant.chapters: all | [chapter_id]` is
   **deleted**; a grant is `all`. Chapter-scoped grants are claim curation
   wearing a grant's clothes and silently reverse founder decision 7
   (`design/ledger-design-0.1.md` §7.1). With per-chapter hiding also gone from
   the public page, the record is now uncurated on every surface and the
   decision-7 tension is closed rather than balanced.
4. **The read log narrows.** `design/ledger-design-0.1.md` §7.1 ("every packet
   issuance is logged and visible to the worker") and §8.1 ("the full read
   log"), `model/record-schema.md` §5 (`grant.last_read_at`), and `design/05` §3
   ("the worker sees every grant issued, and whether it was opened") are
   **superseded**: the worker sees the grant's **state**: issued, active,
   expired, revoked, and no read events. Public-profile views are counted;
   full-record reads are not surfaced. Reason: a read stream during a live
   application is an anxiety feed and surveillance of the employer. **GDPR Art.
   15(1)(c) is satisfied by a disclosure record available on request**, which is
   a required consequence of this ruling, not an optional one.
5. **`plans/worker-surface/LAYER.md` AC-WS1** ("a side-by-side against a raw API
   dump shows nothing hidden") is narrowed by 4 and by the no-dispute-UI ruling.
6. **`DESIGN.md` gap 11** (identity core versus the no-centre rule), **closed:
   the core is dropped.** The empty state is carried by the graticule ground
   clipped to the fixed canvas, which is `DESIGN.md` §9's own primitive. Recorded
   as design, not as a ratified decision, and rendered in the canvas below.
7. **`DESIGN.md` gap 9** (first-run teaching sequence), **closed by deletion.**
   There is no tutorial; the first chapter landing is the teaching.
8. **`DESIGN.md` gap 3** (the display identifier), **still open, and now
   entangled**: the handle exists and nothing here decided whether it becomes the
   human-facing identifier.

### C. Evidence consulted

`research/08` §5.2 (C1, the money perimeter), `research/11` Parts A and B
(signup identifier, name modelling, the three name layers), `research/12` §1–3
(deletion and reputation evasion), `research/14` §1 (recordkeeping duties attach
to the employer as user of a selection procedure, not to the scoring vendor,
the vendor is reached only through the agent theory that carried *Mobley v.
Workday*), and the shipped worker app in `hiregrain/grain` (`mobile/src/app`,
`server/src/lib/publicCandidateHandle.ts`) as precedent, not as inheritance.

### D. Still open after this entry

The identity domain. Money at entity level (010). Whether the handle becomes the
display identifier (gap 3). Employer surfaces (gap 8). Companion typeface (gap
7). Dark mode (gap 6). The marks enum (gap 5). A party has no visual identity
beyond its name and registry state, which is a deliberate restraint recorded
here rather than a gap.

## 036 — Support-mediated account actions; the identity flow (2026-08-19)

Follow-on rulings to 035, settled the same day. They move every account mutation
out of the app and add the identity-verification surface 035 left undesigned.

**Every account change is handled by customer support.** Name, phone, email and
the public handle are read-only in the app; changing any of them is a support
request. This supersedes 035 §A's implication that the handle is changed in-app,
and it narrows `design/06-worker-app-ia.md` §7 (Settings) to a read-only surface
with a support route.

**Deletion has no in-app control.** It is a support request. Access stops when
the request is filed; erasure follows a grace period. **Signing in during the
grace period resets the request.** The worker must file a new one to continue.
Recorded consequence, not a challenge to the ruling: this supersedes 035 §7's
in-app deletion with grace, and it is the pattern GDPR Art. 12(2) ("the
controller shall facilitate the exercise of data subject rights") is most often
read against. It stays lawful if honoured inside Art. 12(3)'s one month and not
made burdensome. Settings still *names* the right and routes to support, because
the consent instrument promises it at signup (`ledger-design-0.1.md` §8.2 item
5) and a promised right that cannot be found is worse than one never offered.

**Export is requested in the app and delivered within 24 hours**, by email. The
screen states the commitment rather than "soon". Well inside the Art. 15(3) /
Art. 20 one-month clock.

**Identity verification (the KYC flow).** Two entry points: **self-serve from
Settings at any time**, and **triggered by an employer's request at application**.
It is therefore *not* gated to the first grant, which was the recommendation in
the grilling; the ruling is broader and puts the worker in front of it earlier.

Storage is unchanged and already ruled (decision 010, `research/08`): results-only
vendor integration, no document images ever in the ledger, Sumsub global primary
with Persona for the US, sanctions screening bought with only a signed pass/fail
stored, no hit detail. Four internal tiers: recorded, contact, document,
biometric, of which **only two surface to partners: identity verified, or not**
(decision 028). The worker sees the internal tier, per the settled
worker-sees-all-raw-facts position.

**Surface shape: designed, not ruled (flagged to the founder as the designer's
call).** Grain's own chrome wraps the vendor's capture step, with the vendor
named plainly on the screen where the document is taken, so the worker is never
handed to a stranger mid-flow. **Liveness is a separate step after the document
passes and is declinable**, so refusing it costs nothing the worker already has.
This is what decision 028's "biometric stays opt-in for a stated reason" needs
in practice, given BIPA and the EU AI Act.

**Amendments.** 035 §7 (settings inventory and the deletion grace window) is
superseded by this entry. `design/06-worker-app-ia.md` §7 is rewritten and a §8a
added for the identity flow.

## 037 — Platform target, and four app-shell gates closed (2026-08-19)

Grilling on the gates raised in `design/08-app-inventory.md` §0. The framework
choice (Q5) is **not** settled here. It is under independent evaluation and
gets its own entry.

**Native supersedes "PWA before native."** `plans/worker-surface/LAYER.md`
scoped responsive web first with an installable PWA before native; the target is
now native iOS and Android, with the PWA remaining first-class from the same
codebase rather than becoming a fallback. `design/06-worker-app-ia.md` §3 makes
an arriving link the most common first session, and a link must never require an
install. **The public web app is built in parallel**, not after.

**Intra-record navigation survives Android by two changes, not one.** Android
10+ takes a back-swipe from *both* screen edges, and the edge index, the app's
only navigation, since there is no tab bar, sits on the right one. The app
declares `setSystemGestureExclusionRects` over the index, which Android budgets
at 200dp per edge against the index's ~248px, so the index is **capped to fit
that budget**. And the index becomes an *accelerator*: the record is one scroll,
so no destination may depend on hitting a 40px strip. The second change is
load-bearing on its own, because the PWA cannot call that API at all.

**Dark mode ships at v1, as a second palette rather than a mechanical
inversion.** This closes `DESIGN.md` gap 6's decision half; the drawing is still
outstanding. §5's inversion rule, "the ink becomes the ground", is a sentence
and does not survive arithmetic: `--rule` at 3.35:1 on paper is a different ratio
inverted, and the imprint's hairlines *bloom* on dark ground where they *fade* on
light. The dark palette is therefore derived from §12's contrast floors
independently, and every state must be distinguishable in both appearances or in
neither.

**Archivo is paired with Noto Sans Devanagari**, closing `DESIGN.md` gap 7 for
the first non-Latin cohort. SIL OFL, purpose-built, matching weights. Noto
siblings follow for Bengali, Arabic and CJK as those cohorts land, under the same
rule. **Recorded consequence, not a detail:** Noto has no width axis, and §6's
two display registers are Expanded 125%. In Devanagari the display hierarchy must
come from weight and size alone, so **the type system is genuinely weaker in
non-Latin scripts than in Latin**. That is a real asymmetry in a product whose
population is largely non-Latin, and it is recorded here rather than discovered
at localisation.

**The public page ships from a separate server-rendered web app**, not from
`react-native-web`. Decision 035 requires it be always indexed with a reduced
view for crawlers and logged-out visitors; a client-painted render ranks badly
and cannot cleanly serve a distinct crawler payload. `public-web` is already its
own layer. The two share design tokens and the generated contract client, never
the component tree.

**The imprint is computed on-device from the record**, never rendered
server-side to an image. Law 1, no mark without a fact, and the figure must
stay recomputable from the ledger; a server-rendered image is a cache that can go
stale and an endpoint that leaks figures. The renderer is a framework question
and waits on Q5.

**Open after this entry:** the app framework (Expo/React Native versus native
Swift and Kotlin twins), under independent evaluation. It carries a live tension
with ratified decision 012 / D2, which fixes surfaces as TypeScript.

## 038 — Deletion control restored; attestation is a web surface (2026-08-19)

Five rulings. Two amend entries made earlier the same day.

**A deletion control returns to the app, and it files rather than executes.**
Amends decision 036's "no button". Apple App Review Guideline 5.1.1(v) requires
an app supporting account creation to offer in-app account deletion, so 036's
support-only route does not ship on iOS. The control **files the support
request.** It does not perform the deletion. Everything else in 036 stands:
access stops the moment the request is filed, support executes the erasure after
the grace period, and signing in during that period resets the request and
requires a new one. This also closes the hole `design/07` found independently:
the consent instrument promises the right at signup, and a promised right that
cannot be found is worse than one never offered.

**The app unlocks with biometrics or the device passcode**, declinable and
defaulting to on. `research/11` records shared handsets in the Philippines and
India as a real and unmeasured pattern, and the record is the thing worth
protecting on a shared phone. It cannot gate the public page, which is public by
construction.

**Client telemetry ships, on a hard boundary.** Screen views, funnel steps and
crash traces, on a rotating client id: **never keyed to `ledger_person_id`, and
never carrying record content**. The line: telemetry may know *that* a chapter
was added, never *what* was added. This is a different category from decisions
022 and 026, which govern operator analytics *on the record*; it is recorded here
so the two are not conflated later. The onboarding drop-off that cannot be seen
cannot be fixed, and the population most likely to drop off is the one this
product exists for.

**Attestation is a web surface, not an app surface.** Decision 035 gave every
attester an account with verified identity, which `design/08-app-inventory.md` §1
scoped as six screens inside the mobile app, roughly a fifth of the remaining
work. That scoping is **withdrawn**. An invitation link opens the web attestation
flow; the attester creates their account and attests there; the native app is
where they later hold their own record, if they choose to. Consequences: section
E of the inventory moves to `public-web`, `plans/worker-surface/LAYER.md` loses
the attester-onboarding paragraph added earlier today, and the attestation form
itself stays `peer-references` (ledger-authored, no free-response field, decision
025). This also removes the app's dependency on the scarcest action in the
product being completable on a phone.

**A worker may grant to a registered party or to an email address, and the two
are visibly different objects.** A grant to a registered party is addressed to an
identity Grain can vouch for. A share link sent to an email is a URL, and anyone
holding it can open it, so a forwarded link is a disclosure the worker never
made, and the creation flow says so. Both remain whole-record (decision 035) with
mandatory expiry.

## 039 — Record surfaces, and the unowned employer-normalization problem (2026-08-19)

**Chapter detail shows all seven measures, including the zeros.** A party choosing
"not part of this work" is a statement about the job; hiding it turns absence into
a gap the reader fills in themselves. It is also what the worker-sees-all-raw-facts
position requires. The worker sees exactly what was sent.

**Push notifications name the fact, never the content.** "Sunrise Foods signed
your work record", not what was said. A lock screen is read by whoever is holding
the phone, which on a shared handset is not always the worker, the same reasoning
that put biometric unlock on the app in decision 038.

**The app icon is the mark.** No separate icon design. Consequence: it inherits
`DESIGN.md` gap 1's three open items: the lobe count, the break angle, and
silhouette agreement between the largest and smallest tiers. The icon gate
therefore collapses into the mark gate rather than disappearing, and it is a
store-submission asset.

**Offline is read-only.** The whole record readable, the imprint computed on
device, nothing queued for later write. A queued attestation request firing days
later against a changed registry is a correctness problem, and this population's
connectivity makes those days real. Recorded consequence from the platform
research: on iOS this promise only holds for an **installed** Home Screen web app.
WebKit's ITP deletes IndexedDB, LocalStorage, Cache API and the service-worker
registration after seven days without interaction, and exempts installed web apps
explicitly. Installation is the storage model, not a distribution preference.

### The employer-normalization gap: raised, not closed

**Party search at entry is rejected.** Founder ruling: search is not effective at
global scale. The real problem it was papering over is **normalizing and
standardizing employer data**, named as a major data-cleanliness issue.

**Nothing in the repo owns this.** `plans/party-registry` (status `ready`) is
scoped entirely to *registered* parties: lifecycle, keys, vetting, capability
grants. `model/record-schema.md` gives `chapter.party_asserted` a rule that a
worker-typed name is **never** resolved into a `party_ref` automatically, because
"a name match is not an identity", and stops there. No layer addresses what
happens when many workers type many spellings of one business, across scripts, and
most of those businesses never register. In this population that is the majority
of chapters, not the tail.

**The shape of the answer is already in the repo, for people.** `research/03`
solves person identity with Fellegi-Sunter scoring: candidate generation by
blocking, a weighted match across several fields, human review, and never an
automatic merge. The same discipline applies here, **clustering proposes, it
never asserts**, which is what the schema rule already requires.

**What this changes in the app, and it is the opposite of what was proposed.**
Adding a chapter captures the raw employer string faithfully, plus enough
disambiguating context for later central resolution, country and city at minimum,
and never forces a match against a search result. A smaller and more honest
screen than a search box.

**Open, and needing an owner.** Whether employer entity-resolution extends
`party-registry` (which would mean widening a layer already at `ready`), lands in
`ingestion`, or becomes its own layer. Raised for the founder rather than decided
here, because altering a `ready` layer's scope is exactly what the plan protocol
exists to prevent.

## 040 — App framework ratified; D2 narrowed; IDV inverted (2026-08-19)

Four rulings, after an independent evaluation: an advocate's brief for Expo/React
Native, an advocate's brief for native Swift + Kotlin twins, an adversarial risk
audit, and four verification agents. Evaluation record: `design/09-app-framework-evaluation.md`.

### A. The framework

**Expo SDK 57, React Native 0.86, React 19.2.3, with CNG and config plugins,
expo-router, and `@shopify/react-native-skia` as the imprint renderer.** One
codebase for iOS, Android and the installable PWA. Pin SDK 57; take 58
deliberately. The New Architecture is not a decision: RN 0.82 made it the only
architecture and 0.84 removed the legacy one on iOS.

**The advocate for the opposing position scored its own case at ~40%**, and the
two arguments native is normally sold on did not survive primary sources:
**Android Chrome *is* Skia**, so there is no native rendering advantage on the
platform that matters most to this population; and decision 037 had already
neutralised the gesture-exclusion argument by demoting the edge index to an
accelerator.

**The decisive evidence is about this repo's execution protocol, not about
performance.** Kotlin and Compose have published agent benchmarks: JetBrains'
105-task Kotlin benchmark, Google's Android Bench where 41% of tasks are Compose,
verified by instrumentation tests. **Swift and SwiftUI have neither a benchmark
nor a Linux-hosted verify loop**: there is no Linux→Apple build path, snapshot
tests are simulator-identity-bound, and macOS CI costs roughly 10× Linux per
minute. `plans/ORDER.md` runs entirely on cheap clean-context verifier sessions
re-running mechanical criteria, and iOS is the one runtime where that loop does
not work. Cost estimate: **~10.5 engineer-months against ~22**, with a standing
~2× multiplier on all post-v1 surface work under twins.

**`react-native-svg` is disqualified from source, not by benchmark.** It
rasterizes via `Bitmap.createBitmap` + `new Canvas(bitmap)`, which is never
hardware-accelerated on Android, and invalidates the whole bitmap on any child
prop change. Decisively, `RenderableView.setupStrokePaint` returns early when
`strokeWidth == 0`, so it **cannot express hairline mode at all**. And hairline
mode is what `DESIGN.md` gap 10a requires. Skia reaches `SkPaint::setStrokeWidth(0)`,
documented as "always exactly one pixel wide in device space… thickness does not
change as the canvas is scaled."

**A constraint discovered during the evaluation and recorded here because nothing
else states it: at 4× zoom the imprint's fixed 760-sample polyline produces
8.3-device-pixel chords, and the guilloché visibly facets into polygons.** The
figure must be re-tessellated per zoom level, which a static SVG DOM cannot do.
This makes the adaptive-sampling change to `imprint/imprint.py` a **correctness
fix, not an optimisation**. Sampling by radius at ~1.5px per segment also cuts
total vertices 2–3× invisibly, and Bézier fitting to `r(t)` would cut ~10×.

**Measured, correcting a figure used throughout this session:** the imprint is
**5,327 vertices at first attestation, 15,981 at a median mature record, and
24,352 worst case** (364 KB of path data) across the repo's own 14 reference
renders. The "~5,000" used in earlier briefs was the sparse case.

**Open, not ruled:** whether the Go core ships to the client via gomobile and
wasm. It matters because `contract/CONTRACT.md` fixes canonicalization as RFC 8785
JCS with ECMAScript `Number::toString` semantics and UTF-16 code-unit key
ordering; if the client verifies its own record offline it is in the verification
path, which is the hazard D2 ruled Go for. Reimplementing JCS in TypeScript is
the thing not to do.

**Live defect in the existing TS plan:** openapi-generator marks the plain
`typescript` generator **experimental**; `typescript-fetch` and `typescript-axios`
are the stable ones. Pin explicitly before it reaches `integration-surface`.

### B. D2 is narrowed, not overturned

**D2 now reads: TypeScript owns *web* surfaces.** Native clients are a separate
category and are TypeScript by this ruling rather than by D2's.

Grounds. D2 was ratified 2026-08-17; native became the target on 2026-08-19
(decision 037), so **D2 could not have adjudicated a category that did not exist
when it was ruled.** This is narrowing by construction. D2's own text says "TS
owns worker **web** surface." Its dispositive evidence is entirely about the
kernel: the npm supply-chain record, FIPS 140-3, the partner wire boundary, and
the ruling itself records that "the TS agent-fluency evidence did not survive
verification," so TS took the surfaces by elimination and never on affirmative
evidence. Decision 012's carried-forward switch-triggers are all kernel triggers
and none fires on a surface change.

**Recorded against this narrowing:** D2's trigger register names **codegen-chain
rot**, and that trigger sits closer to firing with more client targets. Mitigation
is a single codegen toolchain with pinned generators and AC-IS2's byte-identical
regeneration check extended to every target.

### C. Identity verification: decision 010 inverts

**Persona becomes the primary vendor; Sumsub secondary.** Both briefs and two
verification agents independently established that **neither vendor permits the
capture step to be hosted inside the host app's own chrome.** Persona's docs:
"If you want to provide your own identity verification UI, you need to use a
'Transactions-based' integration… contact the customer support engineering team."
Sumsub offers theming only, in four buckets, and requires modal presentation
because "SDK contains its own navigation stack."

**Decision 036's F3 is therefore relaxed, and this is the ruling it flagged as
"designed, not ruled."** "Grain's chrome wraps the vendor's capture step" now
means **our screen hands off, with the vendor named on it**, not our viewfinder
around their camera. That is framework-independent and true of native twins too.

**Recorded exposure, for counsel before contracting:** Persona lists 16 US
subprocessors including **Anthropic, OpenAI and Groq** for "data extraction and
analysis". Identity documents and selfies reaching three model providers.
Decision 010 forbids document images in the *ledger*; it says nothing about the
vendor's onward processing. Sumsub's posture is materially stronger (German data
centres by default, adequacy decisions and SCCs). **India DPDP residency is
unproven for both** and must be answered in writing during procurement.

### D. Deletion: both fixes

**A web deletion URL is added to `public-web` scope.** Google Play requires
**both** an in-app path and "a web link resource where users can request app
account deletion". The second is a requirement no in-app change satisfies, and
decision 038 only closed the first half.

**Cancelling a deletion becomes an explicit affirmative act**, not a side effect
of signing in. Amends decision 038. The EDPB's deceptive-design guidelines name
"dead ends" that interrupt a deletion process, and a worker who opens the app to
check on their deletion currently cancels it. The coercion protection decision 038
was buying survives; only the mechanism changes.

### E. Employer entity-resolution gets its own layer

`plans/employer-resolution/`, the nineteenth layer, depending on
`party-registry` and `ingestion`. It reuses `research/03`'s Fellegi-Sunter
discipline: **clustering proposes, it never asserts**, which is what
`model/record-schema.md`'s "a name match is not an identity" already requires. A
new layer rather than widening `party-registry`, which is already `status: ready`.

### F. Raised for counsel, out of scope for this entry

**`imprint/README.md` §8's patent clearance has lost one of its three limbs.** It
clears SAP US 10712908 B2 partly on the ground that the patent's independent
claims require "receiving input activating a portion" while "the figure is
generated non-interactively." Decision 035 specified an expanded imprint where
dimension slots light under touch and tapping a ring walks a dimension outward,
which is input activating a portion. The transpose argument (radius = time, angle
= dimension) and the ratings-source argument stand independently, so this is not
fatal, but **counsel was told the non-interactivity limb held and it no longer
does.**

**`DESIGN.md` §10's premise that reduced motion suppresses haptics is unverified
on both platforms** and should be restated as product policy rather than platform
behaviour. Relatedly, the seat's haptic now has names: **`.rigid`
(`UIImpactFeedbackGenerator.FeedbackStyle`) on iOS**, literally the seat's
semantics, **and `HapticFeedbackConstants.CONFIRM` on Android**, closing the gap
`design/08` §3 recorded.

## 041 — Employer-resolution layer withdrawn (2026-08-19)

**Corrects decision 040 §E, ruled hours earlier the same day.** The layer created
there is deleted. The recommendation behind it was mine and it did not survive
its own test.

**It is neither `v1` nor `first-product`.** `plans/ORDER.md` defines `v1` as the
round trip: signup, verification, control, deletion, a party reading a packet
under grant and writing an attestation back. Employer clustering appears nowhere
in it. `first-product` is "a worker signs up, imports a resume, and a partner buys
a read on their history and trajectory". A read on **one** worker, where a
free-text employer name is entirely sufficient. Normalization pays only when
aggregating *across* workers. The layer was filed at `milestone: v1`, which was
wrong on its face.

**The urgent part is not a layer.** Context that is not collected at entry cannot
be backfilled, so `chapter` gains **`party_country` (required when `party_ref` is
null) and `party_locality`**, `self-asserted-record` populates them in both CRUD
and résumé import, asking rather than inferring, since an LLM guessing a country
from an employer name is the silent resolution the schema forbids, and
`worker-surface`'s add-a-chapter screen asks for them. Three layers that already
exist.

**The rest is a recorded future concern, not a plan.** Employer normalization is
scoped as a note on `analytics`, where its first genuine consumer is. Every layer
costs a founder grilling before it can go `ready`, plus decomposition and a
verifier protocol; spending that on machinery nothing is building is the
speculation the plan protocol exists to prevent.

**Two rules survive the withdrawal**, now stated in `model/record-schema.md`
beside the "a name match is not an identity" rule they belong to: the raw
`party_asserted` string is **never mutated** and normalization is derived and
disposable; and when resolution is eventually built, its operating threshold is
set against the **false-merge rate**, never F1. A false merge attributes one
worker's employer to another's, and that is the harm the threshold exists to
price.

## 042 — Execution discipline: worktrees, two mandatory reviews, readable criterion identifiers (2026-08-19)

Prompted by a day that went wrong in three ways, and by reading how
`hiregrain/dispatch` and `hiregrain/grain` actually run rather than how this
repo says it does.

### What the two repos do that this one does not

**Dispatch's `checks/` is real and it is the keystone.** Seven programs behind
`run.mjs`; `plan-graph.mjs` validates every frontmatter block, walks the
dependency graph, and prints what is workable now. Its executive loop states
the consequence plainly: *"`node checks/run.mjs` is the only source of what is
workable. The executive never re-derives status from prose."* **This repo has
no `checks/`, so it has no queue, so its executive loop is a paragraph nobody
can run.** The port is `plans/foundation/06` and it gates everything.

**Dispatch tasks join to criteria.** A real task carries `satisfies: [AC-FND-4]`
and `layer:`; the checker requires both. **All 31 task files here carry
neither.** A divergence that predates today and that the checks port will fail
on. Recorded rather than fixed: guessing which criteria an existing task
delivers is authoring, not inference, and belongs with whoever next touches
each layer. `layer:` was added mechanically, since it is derivable from the
directory.

**Dispatch has two escape hatches this repo lacks.** `gated_criteria`: criteria
a `ready` layer knowingly cannot reach because the only satisfying task is
still `draft`, where *"declaring it is the point: the check fails on the
undeclared case, which is the one that drifts."* And `discharged_at_layer`:
an adjudicated criterion with no implementation, because a task carrying one
would be a PR containing nothing. Both are adopted.

Recorded honestly: this entry first claimed `foundation` had declared eight
criteria and written seven, as a live example of that drift. That was wrong.
Criterion 8 was written, an *adjudicated* criterion, that a clean-context
verifier finds no spine column from which a person could be re-identified
without the payload plane. The acceptance sweep earlier the same day mangled it,
because the pattern that rewrote criterion definitions matched only
`(mechanical)` and this is the repo's single `(adjudicated)` one. It is
restored. The escape hatches are still adopted, on Dispatch's reasoning rather
than on a defect that turned out to be self-inflicted.

**grain runs six worktrees and forbids code work in the main checkout.**

### The rulings

**The main checkout is a planning desk.** Plans, decisions, model and design
edits only. All feature and code work happens in its own worktree. Adopted from
grain, for the reason grain has it: today a second session checked out a branch
in this checkout while another was mid-edit, and this log ended up with three
duplicate entry numbers (030, 031, 032) that had to be reconciled by hand
against a `main` that had renumbered them differently again. **Also adopted:
grain's divergence check**: fetch, then read the log both ways, and surface a
divergence rather than pivoting silently.

**`/plan-eng-review` is mandatory before a layer goes `ready`, and again when
its task files are authored.** Grill-before-ready settles what a layer is for;
the engineering review settles whether its criteria can be executed and
verified. `app-shell`, written today without one, carried **six criteria this
repo's own verifier protocol could not check**: "verified on real hardware",
"evidenced by a recorded session", against `plans/ORDER.md`'s rule that
*"mechanical criteria are re-run, not re-read"*, plus **three scope items with
no criterion at all** (haptics, push, launch identity). All six were rewritten
as assertions on the layout tree, the token pairs and the call site; the two
that genuinely need a device are now named as the exception rather than hidden
among them.

**`/code-review` runs on every PR after it is posted and before it may merge.**
Verification proves the criteria are met; code review is the only step that
reads the diff for what the criteria did not think to ask. Merge gates now run
in order: CI green → verification recorded → code review resolved → human
merge.

**The executive loop is written out.** It was one sentence; it is now seven
steps with the worktree rule, both review gates, and an explicit list of what
the executive never does. Adapted from Dispatch's, which is battle-tested.

**Criteria are identified by position, not by code.** Inside a layer, the
number. Across layers, `<layer>-<n>`, `worker-surface-3`. The `AC-XX<n>`
codes were stripped from all 19 layers and 96 criteria today on the founder's
instruction, because a reader could not tell what `AC-PI4a` meant. **The
identifier they carried was load-bearing**, it is the `satisfies` join, and
survives in this readable form. Recorded as a divergence from Dispatch with its
reason, per `CLAUDE.md`'s rule that an unrecorded divergence is drift.

Recorded against this ruling: the intermediate state, where the codes were
replaced with a bare `acceptance_count:` integer in frontmatter, was **worse
than the codes**. It named nothing and served no reader. It is gone; criteria
are numbered in the body and every one now leads with a plain-English sentence
saying what it requires.

**Running state does not belong in a plan.** grain keeps a per-plan
`PROGRESS.md`: PR checklist, decisions taken during execution, blockers,
worktree path, so plans stay stable while progress churns. Adopted in
principle; the file appears when a layer goes `ready`, not before.

### Consequences

`plans/ORDER.md` gains a frontmatter section and a written executive loop.
`CLAUDE.md` (and `AGENTS.md`, its symlink) gain the worktree rule, the
divergence check, both mandatory reviews, and the criterion-identifier
convention. Every task file gains `layer:`. `satisfies:` remains unwritten
across all 31 and is the first thing the checks port will surface.

## 043 — Foundation execution run: fork deferred, merge authority delegated (2026-08-19)

Two founder rulings settling the last open items before `foundation` executes.

**The run-record spine/payload fork (decision 026, AI Act Art. 19) is
deferred to `analytics`.** ORDER.md's gate table carried it as "a
`foundation` task nobody owns". Its first genuine consumer is the analytics
run record; building the fork before anything writes a run record is the
speculation the plan protocol exists to prevent. `foundation` may close
without it. The deferral is this entry; `analytics` inherits the item and
cannot go `ready` without owning it.

**Merge authority is delegated to the executive for the foundation run, and
only for it.** ORDER.md gate 4 makes merging a human act. For this run the
founder pre-authorizes the executive to merge a PR once the three prior
gates are green: CI, clean-context verification recorded, review findings
resolved, with judgment-call summaries posted per PR for after-the-fact
audit. The delegation is scoped: it covers `foundation/01`–`08` and expires
when the layer closes. Any PR carrying an unresolved judgment call still
waits for the founder. Raises park the task and the run continues where
dependencies allow; they batch to the founder rather than pausing the run.

## 044 — The imprint's density channel: relative, adaptive, and two states at small sizes (2026-08-19)

Gap 10a asked where the imprint's drawn size tiers fall. Measuring the
question dissolved it and exposed a larger one underneath, in the channel
rather than the drawing.

**The pitch rule was correct in a unit that never reaches the screen.**
`imprint.py`'s `PITCH_RATIO = 2.2` is asserted against `STROKE` in viewbox
units, and it passes: the dense reference record's outermost band carries ten
threads at 1.67 units of pitch against a required 1.54. At the 296 px the
core screen actually renders, that pitch is **0.82 CSS px** with a 0.35 px
stroke. Adjacent threads less than one pixel apart is why the band
paints as a dark ring rather than as threads. This is the defect gap 10a
already found in the *stroke*, one level up, and fixing the stroke alone
makes it worse: crisper strokes at sub-pixel spacing merge sooner than pale
ones do. Measured across the same record at 296 px, the four bands draw
2 / 7 / 4 / 10 threads into budgets of 1 / 5 / 5 / 8 at dpr 2 and
0 / 2 / 2 / 4 at dpr 1.

**Thread density is a contrast, never a count.** §2 assigns density to
corroboration tier. Nobody counts ten hairlines, `imprint/README.md` §7.4
records that no human has ever been tested on this channel at size, and no
absolute reading has ever had evidence behind it. Density is therefore read
*relatively*, a band against its neighbours inside one figure, and
`TIER_FRACTION`'s 1.0 / 0.5 / 0.18 is preserved as a ratio of whatever budget
the size allows. A thread count is not a claim and never travels between
figures or between sizes.

**Recorded consequence, because it degrades an epistemic channel:** below a
four-thread budget the low tier (0.18) and the mid tier (0.5) both round to
one thread. Corroboration goes from three distinguishable states to two, on
small surfaces, silently. Nothing in the encoding announces this and nothing
yet decides what should. It is named here so it is not discovered again.

**Thread count follows the rendered size, and there are no drawn tiers.**
Decision 037 computes the imprint on-device from the record, and 040 renders
it through Skia, whose `setStrokeWidth(0)` is one device pixel at any scale.
The renderer knows the size at draw time and sets the count from a pitch
budget. This supersedes gap 10a's call for purpose-drawn tiers in §3's sense:
§3's tiers exist because the mark carries no data, so a band may be dropped;
every band of the imprint is an engagement, and dropping one drops a person's
job from their own record. One rule at every size.

**Pitch is floored at two device pixels, and the figure is drawn as densely
as the hardware can carry.** Two candidate floors were rendered through the
Skia harness. Fixing pitch in *apparent* size (two CSS pixels) makes one record
identical on every screen, at the cost of leaving most of the available
resolution unused on the 2x and 3x hardware this population actually holds.
Fixing it at two *device* pixels, the tightest pitch that can resolve as two
threads at all, draws 9 / 17 / 27 threads at dpr 1 / 2 / 3 for the same 320 px
on screen, and the rendered figure reads as engraving at 2x and 3x where the
CSS-floored one reads as contour lines. **The founder call is density: the
device floor.** Under this entry's own rule that is honest. Density is a
contrast between bands within one figure, never a count, so it does not have to
be equal across devices to mean the same thing. Two people comparing phones see
different richness of the same record, and that is the accepted cost.

**The one-period phase sweep stays, and it is what caps density.** `mark.py`
sweeps two lobe periods and records that m=2 gives 1.56a of radial spread
against m=1's 0.87a, nearly twice the threads. Rendered for the imprint, the
extra period braids threads across the lobe peaks: a lobe stops being a
readable contour and becomes an envelope wider than the depth it encodes. The
mark can afford this because it carries no data; **lobe depth is level attained**
and the imprint cannot. §2's one-period rule is protecting a channel, not a
taste, and this entry declines the 1.8x. The ceiling on the imprint's density
is the depth channel, not the pixel grid.

**Threads are cubic Beziers fitted to `r(t)`, closing decision 040's faceting
item and its remedy together.** `thread_path` sampled at a fixed 760 points,
which 040 measured as 8.3-device-pixel chords at 4x zoom with the guilloche
visibly faceting into polygons; it called re-tessellation a correctness fix
rather than an optimisation and estimated Bezier fitting at a further ~10x.
Both are built. Segment count follows arc length, floored at eight segments per
lobe because no fit recovers a wave it never sampled, and the tangents are
analytic. `profile()` now returns `dL/dt` alongside `L`, since a numeric
tangent spends the accuracy the fit exists to buy.

**Verified, not asserted.** Every emitted curve was compared against the
analytic thread at 180 combinations of band radius, level profile, phase and
density: **worst deviation 0.062 device pixels** against a 0.25 budget. The
per-lobe floor is load-bearing. At four segments per lobe the same test fails
at 0.53 px.

**Measured outcome.** A mature nine-chapter record at 320 px now costs 504 /
1,410 / 3,011 curve segments and **21 / 59 / 124 KB** of path data at dpr
1 / 2 / 3. The polyline at the same density cost 682 KB at 3x, and decision
040's own worst-case baseline was 24,352 points and 364 KB. Maximum density is
therefore cheaper than what the repo measured before this entry, not dearer.

**The imprint is the same figure everywhere; `Expanded` explains it.** An
earlier form of this entry made the core screen a portrait and `Expanded` the
instrument. It is simpler and truer that both draw the real figure at the
best their budget allows, and that `Expanded`'s work is annotation: the
angular anchor, the axis controls, what each channel means, not resolution.
`Expanded` carries more threads only because it is larger. Extends 035.

**§9's person-mark is deleted, not replaced.** §9 requires every human to be
drawn as their own mini-imprint rather than a photo or initials. At the
20–28 px such a glyph occupies, each band is about two pixels of radius and
seven lobes cannot separate at any device density; a unique but unreadable
figure implies a legible identity it cannot deliver. **A person is their name
and their imprint**, composed as one hero on the core screen, as already
drawn. Attestor and party rows carry the name alone, which decision 007
independently requires: those parties are frequently organisations, and
organisations are never subjects, so no imprint exists for them.

**Two code divergences closed with this entry.** `imprint.py`'s `STROKE`
remained a viewbox-unit value emitting no `vector-effect`, contradicting the
rule §13 had already resolved; and `render()` still concatenated `_core()` on
every call, though 035 §B6 dropped the identity core and `imprint/README.md`
§7.0 states no surface emits it.

**The mark is sound, and §3 described it wrongly.** Taken to the same harness,
`mark.py` does not carry the imprint's defect: `stroke_for(px)` derives the
viewbox stroke from the render size, so it lands at 1.00 CSS px at every tier
and pitch at 2.2–2.8 CSS px, arriving independently at roughly the floor this
entry sets. `PITCH_RATIO` being a viewbox number is harmless there because the
weight it is asserted against is already size-derived. **But `DESIGN.md` §3 was
stale:** it specified dropping the outer and inner band from 40 to 79 px, where
`tier_for()` reduces the *weave* and never the band count, on the argument,
written in source, that dropping a band is what makes the mark unrecognisable.
The code is right; §3 is rewritten to it. Left open: `tier_contour`'s docstring
claims 24–149 px where the router gives it 24–95.

**What this entry does not settle.** Every budget above is arithmetic.
Whether two adjacent device-pixel threads *read* as two threads to a person
holding a phone is untested, and §7.4 stands. The figures here come from a
browser render; `design/10-worker-app-screens` is SVG, which 040 disqualified
from the product precisely because it cannot express hairline mode, so those
artboards are not evidence about the imprint and are recorded as such. The
CanvasKit harness built for this entry is the venue for the next imprint
question; it is a scratch tool and is not committed.

## 045 — Sharing becomes a destination; the plate footer leaves the record (2026-08-19)

Two founder rulings from reviewing the drawn record screen, both amending
earlier entries.

**Sharing is its own destination, superseding 035's fourth core-screen slot.**
035 put sharing on the record as its fourth section, below identity, outstanding
verification and work history. Drawn, that puts the one surface where worker
custody is actually exercised at the bottom of a scroll, which is where a
product puts things that do not matter. It becomes a destination reached from
the record's header, and it owns what the section could not hold: the public
page and what it shows, visibility, live grants and their expiry, and
revocation. The founder's words: *does not belong with the record, buried.*

**Consequences.** The record's header gains a second control beside the menu,
and the `Public page on · N parties hold a grant` readout under the figure
becomes the link into the destination rather than an anchor to a section
below. The employer grant view (`DESIGN.md` gap 8) and the two-tier share model
(gap 13) now have somewhere to live; neither is drawn.

**The plate footer is removed from the record surface, amending `DESIGN.md`
§9.** §9 gives the plate a footer carrying append-only status, drawn as
`47 entries · last 12 Aug 2026`. Raised against removal on the ground that it is
the only surface making *nothing can be deleted* checkable rather than a claim,
and the founder reaffirmed: the bar is not earning a permanent 26px band across
every record screen, and the app needs that room for ordinary navigation
chrome.

**Append-only status is relocated, not dropped.** It moves to the account
surface, which decision 036 already made read-only and support-mediated. The
guarantee stays findable and stops being decoration; what is lost is its
constant presence, and that loss is the point of this entry rather than an
oversight. A record that cannot show what it refuses to delete is a weaker
object, and this entry says so plainly rather than pretending the move is free.

**Not settled here.** What replaces the band. "Traditional app UI components"
names a direction, a bottom navigation bar, and this repo has never decided
whether the worker app has one, what destinations it carries, or how that
squares with 035's single-scroll record. That is the next decision, and drawing
a tab bar before it is made would be the failure `CLAUDE.md` describes.

## 046 — WCAG 2.2 AA and the EAA are the accessibility target (2026-08-19)

`DESIGN.md` §12 carried contrast ratios, a 44px target floor and a focus ring,
with **no standard named**. Floors without a standard leave "is this
accessible" unanswerable at the moment a partner, a regulator or a worker asks,
and they let a gap look like a choice.

**The target is WCAG 2.2 AA, with the European Accessibility Act named as the
reason.** The EAA has applied to consumer-facing digital services since June
2025; a portable worker record an EU employer may be handed is in scope, so AA
is an obligation rather than a preference. Naming it also fixes which version
governs, which matters because 2.2 added the target-size and focus-appearance
criteria this design touches.

**What the existing floors already clear.** 7:1 record text, 4.5:1 secondary,
3:1 for meaning-bearing lines, and a 44px target against AA 2.5.8's own 24×24,
stricter, and it stays stricter.

**What the audit found missing, and it is not nuance.** Text scaling to 200%
(1.4.4) against ten fixed 360×800 artboards of absolutely positioned bands,
none tested at any scale factor; screen-reader order and naming for a figure
whose meaning is geometric, where an `aria-label` on an SVG is not a reading of
it; reduced motion as a question about whether the ceremony is essential (2.3.3)
rather than only about duration; target *spacing* under 2.5.8, where the section
index's stops sit 14px apart; and RTL, claimed in §12 and never rendered.

**Recorded honestly: none of it is drawn.** This entry sets the target and
names the holes. It does not close them, and no screen in
`design/10-worker-app-screens` has been audited against the standard it now
declares.

**Platform insets, measured the same day.** iOS leaves 759 pt of 852 once the
59 pt status/Dynamic Island band and the 34 pt home indicator are taken; a
common Android viewport leaves 728 dp of 800 against a 24 dp status bar and
48 dp three-button navigation. Every screen here is drawn 360×800, so the record
is **41 pt too tall for iOS and 72 dp too tall for Android**, and its header sits
under the status bar on both. `design/08` §3 recorded this and nothing acted on
it; removing the plate footer (045) made the bottom worse by running scrollable
content to the gesture-bar edge. Two verification frames now carry the
measurements on the canvas. Reflowing the screens is not done.

**Left open deliberately: how native the components should be.** Platform
*mechanics*: safe areas, back, gesture zones, font scaling, screen readers,
haptics, deep links, are not in question and must be honoured. Platform
*components* collide with this system as ratified: §8 deletes containers and
forbids boxed fields, §7 forbids elevation, §5 forbids anyone theming states,
§6 admits one typeface. Adopting Material and HIG components means the record
renders differently per operating system, which is the thing §5 exists to
prevent. The founder's instruction is that the app must be **highly intuitive**
and that the call may be case by case. That is a decision this entry does not
make.

## 047 — Grain-native components on both platforms (2026-08-19)

Closes the question 046 left open. Decided against three drawn variants of the
same screen, `design/10-worker-app-screens/Handle{Grain,Platform,Split}`, with
identical logic and an identical palette, so the comparison isolated component
form and nothing else.

**The component language stays Grain's own, on iOS and Android alike.** §5's
prohibition on anyone theming states, §7's radius and depth rules, §8's deleted
containers and ruled-line inputs, and §6's single family all stand as ratified.
Material and HIG components are not adopted. The record renders identically on
both platforms, which is what §5 exists to protect: a pending record must not be
able to pass as a verified one because it is being read on a different phone.

**Platform mechanics are not the same question and are not optional.** Safe
areas, back and the gesture zones that own the screen edges, font scaling to
200%, screen-reader order and naming, haptics named per platform, deep links.
046 measured the current state: every screen is drawn 360×800, which is 41 pt
too tall for iOS and 72 dp too tall for Android, with the header under the
status bar on both. None of that is loosened by this entry; all of it is owed.

**What this decision costs, since it is the losing case that has to be answered.**
The population this product is for has been taught what an input is by every
other app on their phone, and a hairline they type on is not it. Choosing an
unfamiliar component language means intuitiveness has to be bought somewhere
else, and this entry makes that an obligation rather than a hope:

- **Form may be unconventional; placement and behaviour may not.** A primary
  action sits where the platform puts a primary action. Back goes where back
  goes. A field commits on the platform's own keyboard action.
- **Anything tappable must read as tappable without motion or colour**, which is
  the harder half of having neither. A ruled input at rest currently looks like
  a rule.
- **The claim is testable and untested.** Nobody in the target population has
  been put in front of these screens. Until they have, "intuitive" is an
  assertion, and this entry records it as one.

**Kept as evidence, not as work.** The three variants stay on the canvas under a
page marked settled. They are the record of how this was decided and should not
be re-litigated without a superseding entry; they are not screens to build.

## 048 — No bottom navigation in v1; the masthead stops implying one (2026-08-19)

Closes the item 045 left open when the plate footer was removed: what replaces
the band, and whether the worker app has a bottom navigation bar.

**It does not, in v1.** Not on system grounds. A tab bar is placement and
behaviour rather than an imported component, so 047 permits one drawn in Grain's
own language, and it would not hit the Android back-gesture conflict that killed
the section index, which was an edge-anchored control inside the ~24 dp side
strip rather than a horizontal band above the navigation inset. It is refused on
arithmetic and on traffic.

**The destination count is two, not five.** `Expanded` is a pushed detail view
reached from the figure, which a tab bar does not carry. `Account` is settings,
and settings is behind a menu in every convention worth following because it is
visited twice a year. `Public` is a preview of something else. What remains are
**the record and sharing**. gap 14 reserves a third, **Work**, which 035 put out
of v1. A two-destination tab bar is a segmented control given a permanent band.

**The cost, measured on the binding device.** Android leaves 728 dp of safe box.
A 56 dp tab bar on top of the 52 dp masthead is **108 dp of app chrome, and
180 dp of 800, 22% of the display, before any record shows**. The record's hero
is a 320 dp figure, so figure plus masthead plus tab bar is 428 of 728, leaving
300 dp for outstanding verification and work history together: the sections the
product exists for, squeezed to buy navigation between two places. On iPhone 17
the same bar costs 6.7% of remaining content height, on Android 8.3%.

**Tabs are paid for by switching, and there is none here.** A worker opens Grain
to look at their record. Sharing is reached when somebody asks them for it, which
is rare and always prompted from outside the app. Permanent chrome for rare
traffic is the trade a tab bar is worst at. Adding one would also partially
reverse 035's deliberate single-scroll record, for no reason that arose tonight.
Sharing leaving the scroll (045) *reduced* what the record holds.

**What was actually wrong is the masthead lying.** Its right-hand control is a
hamburger, which is the universal glyph for *a menu of places to go*, and it
opens one screen. That is why a bar carrying no navigation reads as a navigation
bar that does nothing. **The glyph becomes an account glyph and stops implying a
menu.** The record is the app; sharing and account are reached from the masthead;
the space the plate footer vacated stays with the record.

**Revisit when a third peer destination exists.** If **Work** lands, the count is
three, the traffic pattern changes, and this entry should be reopened rather than
worked around. Scoped to v1 deliberately.

## 049 — Warm ground, cool ink; §9's texture primitives put to work (2026-08-19)

The drawn record read as stale and cold. Diagnosed rather than restyled: roughly
half of that is the thesis working: no accent, no elevation, square record
surfaces, hairlines and an institutional voice are what make this an instrument
rather than a social product, and `DESIGN.md`'s own summary calls it a banknote
engraver's system. Banknotes are cold deliberately. The other half was ours.

**The grounds were cool, and are now warm. The ink does not move.** `paper`
`#F5F6F3` and `page` `#E6E6E4` both carried a red-minus-blue of +2, faintly
green, which put every surface on the cold side of neutral. They become
`#F8F5EE` and `#E9E5DE`, at +10. **Ink, `secondary`, `rule` and `hairline` are
untouched**, so warm paper sits under cool ink, which is what printed paper
actually looks like. No accent is introduced and the state grammar is unchanged.

**Measured against §12's floors, it costs nothing:** ink on paper 13.25 → 13.20,
secondary 5.22 → 5.20, `rule` 3.35 → 3.34, `hairline` still pure separation at
1.33. Every floor holds with the same headroom it had.

**§9's texture primitives were specified and never drawn.** §9 defines dividers
carrying a faint sine modulation at the figure's own frequency, and a graticule
ground; the record screen used the plate and nothing else, which is most of why
it read as bare. Both are now generated, the divider is a real sine at seven
lobes, the figure's own frequency, emitted by `gen.py` rather than approximated
in CSS, and the graticule sits under the figure inside the plate frame at low
opacity. Nothing new was invented: this is the vocabulary the system already
had, finally used.

**The demo record stays sparse, deliberately.** It draws eight threads because
two of its five chapters are unattested, and the founder declined to enrich it:
a typical worker's record *is* thin, and designing against the best case is how
a product lies to itself about what it will feel like in a stranger's hand. The
figure looking faint here is the encoding telling the truth, and the fix for that
is more attestation, not a better demo.

**Not addressed here, and still open.** The record has no moment that
acknowledges the person. §10's celebration economy fires on the seat and on an
attestation landing, and the record at rest has none of it. And `design/07`
counted 73 of 117 register applications at 12px or smaller, which is why the page
reads as a form rather than a document. Both are live causes of the same
complaint.

## 050 — Four calls from the drawn-record review (2026-08-19)

Founder rulings closing the questions 049 left open, plus the scope of the work
that follows them.

**The record names what changed since you last opened it, and the scribe animates
only the band that moved.** §10's ceremony fires when an attestation lands and
the record at rest had nothing, which is the live half of "this feels cold". The
answer is not a greeting: a record that welcomes you is a record performing. It
is that *the record is alive*, so it says what moved: a chapter signed, a grant
about to end, and the figure redraws the one band that changed rather than
re-scribing the whole thing. When nothing changed it says nothing.

**Press physics belong to `Expanded`, not to the record.** The figure yielding
under the thumb is aliveness in the object, and §7's rigidity rule, verified
rows do not compress, because rigidity is how permanence is expressed, makes it
meaningful rather than decorative. It is confined to the expanded view, where
inspecting the figure is the task. On the record the figure is a plate you open,
and a plate that squirms under the thumb is a worse plate.

**Typography gets a full rebalance, not a floor raise.** `design/07` counted 73
of 117 register applications at 12px or smaller and §6's two display registers
are barely used. Instrument numerals at 40px have **zero** applications across
ten screens. Raising the floor alone would leave every screen with nothing large
on it, which is why the product reads as a form rather than a document. Every
screen gets one thing that is genuinely large, and the display registers §6
already defines get used.

**Gaps 8 and 13 are drawn.** The employer grant view and the two-tier share
model, the public page and the expiring full-record link, plus the reduced page
a crawler or logged-out visitor receives. Until they exist, `Sharing`'s controls
are inert and `Public` carries two surfaces marked NOT DRAWN, so the destination
045 created cannot be judged.

**The account glyph stays a person pictogram.** Raised against it: §9's
person-mark was deleted on the ground that a per-person figure implies a
legibility it cannot deliver, and this product otherwise refuses to draw people.
The founder ruled it fine, and the distinction holds. The deletion was about
representing a *specific* person, where this is generic chrome pointing at your
own account, and the pictogram is what makes it readable on sight.

**Dark mode is explicitly out of this run** (gap 6, decision 037), and stays
outstanding.

## 051 — Post-foundation rulings: frontier is strict, retention is 30 days, delegation terms stand (2026-08-19)

Three founder rulings closing the foundation run's open items.

**The strict layer gate governs the frontier.** A task is workable only when
every layer in its layer's `depends_on` is `done`. `soft_depends_on` remains
advisory prose. It names work that can be *prepared* early, and it never
unlocks a task in the computed queue. This resolves the raise recorded on
foundation/06's PR: the fine-grained reading of ORDER.md's prior-packet
sentence is rejected because it would let tasks build on neighbors whose
layer has not finished verification. `checks/plan-graph.mjs` as shipped is
the ruled behaviour.

**Backup retention is 30 days, ratified.** The number in
`db/deletion-policy.json` and `copy/deletion.md`, written as implementer
judgment in foundation/08, is now a decision. Changing it is a config and
copy edit that `checks/deletion-copy.mjs` keeps consistent, plus a
superseding entry here.

**Merge-delegation terms are standing, activation is per run.** The
arrangement decision 043 defined: the executive merges once CI, clean-context
verification, and resolved review findings are all green; unresolved judgment
calls wait for the founder; raises park and batch, is approved as the
template for future execution runs. Each run still requires an explicit
founder go and a delegation entry naming its layer scope; nothing merges
between runs. Execution is paused after foundation on the founder's ruling;
the frontier (trust-kernel/01, trust-kernel/06, person-identity/01) waits.

## 052 — Prose standard, deletion window, and four recorded invariants (2026-08-20)

Founder rulings from the foundation design review.

**The unslop standard binds repo-wide, and this entry is the one-time
approval to amend frozen records for it.** Em dashes, curly quotes,
decorative emoji, title-case headings, and the tell vocabulary are removed
from every tree, including closed decisions entries, verification logs,
discharged spikes, and rendered UI copy. UI copy gets no exception; it is
the prose workers actually see. The append-only principle is not weakened:
this amendment is style-only, meaning-preserving, approved once, here. A
future style amendment to a closed record requires a new entry. Going
forward, `checks/unslop.mjs` enforces the mechanical patterns; the
judgment patterns bind through review. Numeric ranges keep their en dash;
the rule targets dashes used as separators.

**Constraint-stating comments cite their enforcement.** A code comment may
state a constraint only alongside the check, test, or database constraint
that enforces it, or an explicit "enforced by reading". Comment drift is a
review defect. Recorded in CLAUDE.md.

**The deletion confirmation window is 72 hours,** cancellable in-app and
through support. Access cuts immediately on filing; the window delays only
the irreversible shred, and exists so nobody can be forced to destroy
their record on the spot. `copy/deletion.md` states the number;
`consent-and-deletion` implements it.

**Four invariants from the review, recorded so future work cannot
unknowingly break them:**

1. Ciphertext binds the person id as AEAD associated data, so a row
   written under a pre-merge id decrypts only under that id.
   Person-identity's merge design must keep each row's original subject
   id reachable on the read path; re-encryption on merge is not an
   option against append-only content.
2. Every payload serving path consults the restore gate through
   core/envelope. Any future caching of the gate must fail closed, and
   the gate check stays inside the envelope.
3. No payload read path may exist outside core/envelope. A server that
   queries payload tables directly bypasses the restore gate and the
   ciphertext discipline. Enforced by review until a mechanical form
   exists.
4. Restore replay re-applies the entire deletion journal by design. An
   optimization that replays a subset must first prove the restored
   backup cannot contain data for any person it skips.
