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
protocol. Diff against Dispatch positions: `design/dispatch-diff-0.1.md` —
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
(issuers). A customer organization — e.g., an in-person electrician
training program a worker is routed to — registers as an attesting party
and writes performance attestations back; it never holds a subject profile.
Approval-authority needs are met by party-registry entries or
vertical-local records.

## 008 — Work-authorization attestations, post-selection-only (2026-08-17)

Founder ratified the `research/08` proposal: work-authorization status may
live in the ledger as a jurisdiction-scoped, expiring verification
attestation carrying only a boolean + coarse basis-class — never documents,
visa type, or nationality — and readable only AFTER candidate selection.
Access is architecturally incapable of influencing routing/selection
(the eTeam/§1324b constraint expressed as access control). Reflected in
`model/attestation-interface.md` §work-authorization.

## 009 — No identity-evidence retention across deletion; reportability hook stays (2026-08-17)

(a) No salted document-hash survives profile deletion — R2's spirit
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
  pattern) — the plan gate only self-enforces when code and plans share CI.
- **Physical spine/payload split from day one**: two databases (global
  spine + `payload-us`) from the first migration, so the residency seam is
  real from hour zero.
- **No standing staging environment** — founder override of the
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
Entry 009(a)'s original instinct — no retention by default — is restored
and refined.

**Legal correction on the record.** The argument that carried 013's
universal token was wrong in a specific way: **GDPR Art. 17(3) contains
no fraud exemption** — the list is closed at five items. Recital 47
establishes fraud prevention as an Art. 6(1)(f) *legal basis for
processing*, not an erasure carve-out; post-erasure retention must win on
necessity at Art. 17(1) with the burden on the controller. Hashing does
not rescue it: *EDPS v SRB* (C-413/23 P) protects only a recipient that
cannot re-identify, and retaining the salt in order to match is what
makes the token personal data.

**Two findings aimed at 013's design.** AEPD fined Goldcar €80,000 over a
customer blacklist, reasoning that the retained flag "does not refer with
certainty to a fraud committed by the claimant" — which is definitionally
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
  act — which is also what defeats the delete-before-the-finding race,
  since the party holds its own records and can file after the fact);
  keyed to the **document identifier only** (industry convergence — no
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
cannot be a global invariant — Seattle's deactivation ordinance and India
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
  email-or-phone; phone-mandatory platforms gate at payout, not signup —
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
practice is NOT the standard to copy — three of six major IDV vendors
corrupt mononyms): worker-owned free-text `display_name`; immutable
per-verification `document_name` in ICAO 9303 vocabulary
(primary/secondary identifier, mononym flag, raw MRZ + raw visual zone,
native script + ISO code, source); derived regenerable `name_index` for
fuzzy matching (transliterations alongside originals, never phonetic
hashing of non-Latin, candidates only — never auto-merge). Name changes
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
  duplicates are **never proactively surfaced** to a worker — founder
  ruling; proactive disclosure leaks the existence of a matching account
  and teaches detection thresholds.
- No automatic merge touches attested history. **Two stewards** required
  where both records carry verified attestations; one otherwise.
- Concurrent multi-accounting: **flag for steward review only** — no
  visible enforcement, no automatic consequence.

**Deletion and re-registration (supersedes 009a).**
- **You can delete your record; you do not get a second identity.**
- A **universal, contentless enrollment token** survives every deletion:
  a one-way hash of verified document identifiers (primary strength),
  plus phone/email if present (weak). It carries **no outcome tag, no
  cause label, no reputation content** — this is what keeps it lawful
  (fraud prevention is the named legitimate interest; retaining a
  judgment about a person is not) and simple (no cause classification, no
  adjudication surface, no race condition where a bad actor deletes
  before a finding lands).
- **Never expires**, until counsel says otherwise.
- Re-registration matching a token: **new ledger ID, internally linked**
  — a tombstoned ID is never reissued (spine signatures reference it
  forever). First re-registration: usable, flagged for review. Repeat
  velocity: created but **restricted** (no verification, attestations, or
  grants) pending steward decision. **No automatic hard block** —
  matching after erasure is defensible fraud prevention; denying service
  on it is the sharpest legal exposure, and a contentless token cannot
  distinguish fraud from a change of mind.
- **Disclosed plainly at deletion**, not buried: the record is
  unrecoverable, and the identity remains known — re-signup with the same
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

The gate is discharged on this interim evidence by founder ruling — the
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
blind-first + differential-self-test discipline — routine kernel-adjacent
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
`design/stack-litigation/d4-verdict.md` §II(a) — that the ledger is never
a disinterested third party in a dispute about its own record, so
"who could have produced this signature?" must answer *only the partner*
— is reaffirmed as the controlling argument. Recorded because the
question was put and answered, not assumed.

**Amendment to the D4 invariant (narrow).** D4 §2 read "no tier in which
the operator can invoke a registry-grade party key." The operator signs
`ledger_invalidated` records and checkpoints, and those signatures must
verify through the same registry lookup as any other. The invariant is
restated: **no code path invokes a registry-grade key other than the
operator's own**, with the operator holding a single self-entry
(`custody_model: ledger_kms`) enforced unique by a partial index — one
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
not control. The claim as signed is also the truthful one — *the ledger
obtained this result from that vendor*.

**Vetting tier and capability are orthogonal.** `vetting_tier`
(`internal | external_probationary | external_standard | vendor`) drives
internal trust weighting only. Capabilities — `may_attest(scope)`,
`may_request_packet`, `may_file_safety_marker` — are **granted
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
suspension anywhere** — a text box eventually gets typed into and read
back in a deposition.

**Party principals are not ledger entities.** Partner console logins are
`party_users`: WebAuthn-bound auth records scoped to a party, carrying no
`ledger_person_id` and no path to one. Decision 007's two-entity rule is
untouched — a console login is not a ledger entity. The founder noted the
same human may separately hold a worker record; therefore **duplicate
detection is barred from linking `party_users` to persons**, enforced, not
merely unimplemented.

**Activation gates are computed, never stored.** Two limbs, both required
at transition and re-asserted by a check: (1) the witnessed transparency
log exists and is accepting, queried live from the kernel — no cached
boolean, which is one UPDATE away from being flipped under deadline
pressure; (2) the conditional liability-shield instrument
(`design/ledger-design-0.1.md` §3.1) is executed and recorded as a
precondition row. The **1M-attestation limb of decision 005 is a build
deadline for the log, not a second route to activation** — recorded
explicitly so it is not later read as an escape hatch.

**Countersignature cadence: monthly**, or at each registry event, per
`d4-verdict.md` §5. `plans/party-registry/LAYER.md` said quarterly; that
was drift and is corrected. Monthly bounds the "the party never noticed"
window to 30 days, matching the 30–90-day key validity window rather
than cutting across it.

**Probation caps: declared here, enforced at ingestion, never cached.**
Default cap ≈10× the party's stated expected volume, reviewed at 90 days.
**Accreditation re-checked every 90 days** and on any registry event —
one scheduled job shared with the key-renewal rhythm. Falling off an
external allowlist **flags a human and freezes new writes; it never
auto-suspends** (name changes and data errors in external registries are
common enough that automation would take legitimate parties offline).
**Public per-party status pages live at plain, guessable URLs** — the
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
  append-only — attestations must survive to stay verifiable — does not
  apply to a console login. Actions carry an opaque `actor_id` that outlives
  the principal row. Requires a table-scoped exemption under foundation/03's
  documented license. **This is a gap in decision 015, not merely in a task
  file**: 015 settled that principals are not ledger entities and never
  addressed that they remain data subjects.
- **Per-party issuance root, added to the kernel surface.** Task 07 assumed
  a per-party Merkle root that no task in the graph produced;
  `trust-kernel/04` builds one global tree over stream heads. A party must
  countersign something it can recompute from its own records — signing the
  global root would attest to the ledger's arithmetic instead. Recorded as
  an extension `trust-kernel`'s own grilling round did not anticipate.
- **`person-identity/07` corrected.** Written before 015 created
  `may_file_safety_marker`, its acceptance said only "the filing party."
  Now binds 015, requires a live grant, and tests that a fully vetted
  `external_standard` party without the grant is refused — tier confers
  nothing.
- **Ingestion halt is derived, not stored.** A party is halted exactly when
  no key's validity window covers now. No `halted` column exists, matching
  the computed-not-stored rule 015 set for the activation gate.
- **Transactional projections on the write path.** Status, name, freeze, and
  capability reads on ingestion's hot path resolve against projections
  written in the same transaction as their events. Not a cache: no staleness
  window, nothing to invalidate — which satisfies 015's no-cached-copy
  ruling rather than working around it.

**Found by the outside voice.**
- **Key-loss recovery ceremony, written now.** ACME renewal assumes the
  current key still signs, so missed expiry, cloud lockout, or admin
  compromise had no path. Recovery is **re-registration**: fresh key,
  ordinary proof-of-possession challenge, operator review, registry event.
  No privileged bypass is created — an unwritten ceremony is not an absent
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
  (015). Adding `frozen` to the enum would render it as a mild suspension —
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
  erasure ruling above — an admin login needs an email. The invariant is: no
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
  boundary — the boundary is the control, the test is the alarm, and both
  are kept.
- **Operator uniqueness needs three constraints, not one.** A partial unique
  index on `is_operator` proves only "at most one operator." Added: a check
  binding `is_operator ⇔ custody_model = 'ledger_kms'` in both directions,
  and a seeded existence invariant.
- **The free-text ban is scoped to reason and detail fields** adjacent to
  adverse lifecycle events, not to text being reachable at all — the name
  exemption above made the original wording unsatisfiable.
- **Countersignature acceptance proves the protocol against a harness, not
  the shipped kit.** "A partner runs one install and it works" is
  `integration-surface` AC-IS1; this layer cannot assert it without
  depending on a layer that depends on it.

Consequences: eight task files in `party-registry` (08 added);
`person-identity/07` amended; `party-registry/08` declares a dependency on
`ingestion/01`, which is not yet authored — a known dangling reference of
the same class as 07's, discharged when `ingestion` is decomposed.

## 017 — foundation engineering review; layer re-decomposed 6 → 9 tasks (2026-08-18)

Founder rulings from `/plan-eng-review` over `foundation`. Outside voice:
Codex, high reasoning effort, 33 findings; 9 more from the seam pass. The
volume was the finding: roughly a third were not defects in what the tasks
said but concerns **no task covered**, which is a different failure from
party-registry's (decision 016, all patches). Founder ruled the layer is
**re-decomposed rather than patched** — the missing concerns become tasks
with their own acceptance criteria and verifiers, because a missing rule for
what happens when a two-database write half-fails costs every layer that
writes, while a missing acceptance criterion costs one PR.

**Cross-plane write consistency: spine-first transactional outbox**
(`foundation/07`, new). There is no shared transaction across two physical
databases (decision 011), so every spine+payload write could commit one side
and lose the other, and nothing said what happens next. The spine write and
an outbox row commit together — the spine is the ordering authority, so its
commit is what "recorded" means — then a worker applies payload
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
a deleted person's record — the structure 014 rejected on AEPD and CNIL
reasoning. Consequence for the partner agreement: it must state plainly that
the ledger-side copy does not survive the subject's deletion.

**Deletion mechanics** (`foundation/08`, new). Three gaps closed at once.
(1) **Backups defeated deletion and nothing addressed it** — a backup holds
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
tables — this is also the concrete rule replacing foundation/04's
placeholder exemption "where deletion requires it." (3) **Crypto-shredding
is recorded as a documented legal position, not a mechanical proof**, citing
014's *EDPS v SRB* analysis: the ledger cannot re-identify, and that is the
load-bearing fact.

**One shared migration numbering sequence across both chains.** Task 06
checked "collisions and gaps across both chains" while task 04 created two
independent chains — two different models, both asserted. Ruling: numbers
are globally unique across spine and payload; each chain has gaps where the
other's fall. Only a shared sequence can express a cross-plane ordering
constraint, and the constraint is live rather than hypothetical:
`0014-safety-markers` references the party table created in
`0009-party-core`. A new `checks/migration-order.mjs` enforces it —
collisions and gaps do not catch reference ordering.

**AC-F3 narrowed to what it can prove, with the rest made explicit.** The
criterion claimed no spine column holds readable personal data and enforced
it with a type lint. A lint blocks a `text` column; it cannot prove an
opaque `bytea` or an id does not encode a name, and it says nothing about
the harder direction — stable ids, timestamps, and issuer patterns identify
people by **correlation** with zero readable columns present. Ruling: an
**exhaustive allow-list** of permitted spine types (the term
"readable-content type" was never defined, so implementers would have
invented the boundary), a **written justification** in-migration for
anything outside it reviewed by a human, and the correlation risk as its own
deliverable — `foundation/09`, the **spine linkage threat model**, new, a
document task with no code, because every layer above adds spine columns and
needs something to review them against.

**Append-only had holes; the claim is now scoped and the boundaries are
operational.** The unqualified "cannot UPDATE or DELETE any table" would
have gone false the moment the first exemption landed, and a test trained to
ignore exceptions is worse than no test — the exemption list is now
enumerated in the test. Beyond the grant: serving processes hold no owner or
migration credentials, and **SECURITY DEFINER recording functions may only
INSERT** (asserted by inspecting bodies) — `ingestion` writes through them
by design, which was a legitimate path around the restriction. Default-
privilege inheritance is proven across both databases, multiple schemas, and
a second owner role, because Postgres default privileges are per granting
role and per schema and a single-schema test proved far less than claimed.
The inherited derived/cache exemption clause is **dropped** — imported from
Dispatch before this repo has derived/cache semantics, it was an unused
escape hatch.

**Smaller rulings applied.** Typegen output is **namespaced per plane** so a
payload type cannot satisfy a spine-typed parameter — accidental cross-plane
type reuse violates the split in application code while every database check
passes. CI is a **dependency graph, not a linear slogan**: metadata checks
(frontmatter, plan graph, numbering, ordering, decisions) run before any
database boots. Red-path CI acceptance uses **excluded fixtures**, not
genuinely broken committed files, which would make the tree permanently red.
`make check` **never requires cloud credentials** — local Docker and managed
D1 were conflated. The DEK registry's derived state is specified: at most
one active DEK per person by constraint, one documented resolution rule,
idempotent destruction. `destroy(person)` is defined for **merged
identities** (every id in the alias closure) and under concurrency (fail
closed, never partial plaintext). Encryption evidence is **stronger than a
dump grep**, which only proves one planted literal is absent. The provider
invariant is corrected: **business logic is provider-agnostic; operational
code may know** — observability and incident response legitimately need to.
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
  schemas plus grants, the general version costs almost nothing more —
  while a second one-off would give one invariant two expressions and the
  cross-schema lint would be written twice.
- **The payload database is authoritative for residency; the column is a
  checked assertion.** Two records of one fact needed a governing rule. The
  column stays because it is what survives a dump or restore, which is
  precisely when the database name is lost, and a check now fails any row
  whose `residency_region` disagrees with the database holding it. Dropping
  the column was rejected — it would make a separated payload dump
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
inside the signed bytes — nobody can change which key a record claims
without breaking the signature. Amending the contract to admit a two-field
header was rejected: it invalidates every golden vector and the byte-
exactness is deliberate (seven ambiguity resolutions were recorded to reach
it). An unprotected header was rejected outright — unsigned key identity is
the substitution attack the registry lookup exists to prevent.
**Consequence requiring separate action:** `model/attestation-interface.md`
(schema_version 0.2, ratified in decision 006) must carry the field. Not
amended here; flagged as an interface change needing its own ratification.

**Signing takes no key parameter.** `sign(kid, bytes)` made "no non-operator
key is invokable" a runtime string check — the exact regression decision 016
wanted structurally prevented. Ruling: `sign(bytes)` returns the signature
plus the key identifier used; key selection and rotation are internal to the
operator provider. With no key parameter, the wrong key is **unexpressible
rather than rejected**. A typed-handle variant was rejected as a
handle-producing function one careless addition away from producing a handle
for anything, and as a parameter whose only valid value is always the same.

**Chains cover every governing event, not only attestations.** D3's anchored
contents are broader than the attestation record, and **D4's dispositive
argument depends on registry manipulation being visible in the log** — which
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
anchored** — coupling the ≤5-minute cadence to a background worker would let
a retry loop stall a launch-blocking commitment. The signed receipt to a
party fires on the acknowledgment watermark instead. Anchoring proves
ordering; acknowledgment proves durability. Anchoring only acknowledged
records was rejected on the cadence-coupling ground; issuing receipts at
spine commit was rejected as reversing decision 017's acknowledgment rule.

**D3's checkpoint requirements were mostly unwritten, and the layer split on
the cloud-ruling line.** `trust-kernel/04` specified the tree and a local
WORM stand-in; D3 also requires each checkpoint to **name its predecessor**,
a **continuous reconciliation job**, signed receipts at ingest, a dedicated
compliance-mode object-lock account, and a second-cloud mirror — so AC-TK3
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
vectors cannot substitute — **the vectors are generated by the implementation
they test**, so a contract misreading baked into the generator produces
vectors that agree with the bug. The task is dispatched with explicit
instruction not to read `core/kernel/`: independence is enforced by
assignment, because one author writing both shares the misreading twice.
Folding it into `01` was rejected for that reason.

**The 3k line budget holds; orchestration moves out.** The budget bounds what
gets two-human review, fuzzing, and formal specs — it does not measure the
layer. Frozen core: canonicalization, sign/verify, chain append/verify, tree
construction and proofs. Kernel-adjacent, ordinary review: scheduler,
publisher, reconciliation, per-party root assembly. Raising the cap was
rejected because strict review over a two-thirds larger surface becomes
perfunctory, and a budget that moves when inconvenient is not a budget.

**Corrections applied.** AC-TK5 narrowed to **non-operator** party keys
(decisions 015/016 gave the operator a self-entry it signs with; the old
absolute wording was false). Layer and task `binds` extended to 012, 015,
016, 017, 019. `0007-stream-heads` re-licensed as a **named, role-scoped**
exemption — decision 017 dropped foundation/03's blanket derived/cache
clause, so the table can no longer claim it; foundation/03's exemption list
now names it alongside `party_users` erasure and the payload purge role.
Layer no longer claims inclusion *receipts* (kernel provides proofs;
`ingestion` issues receipts) and no longer says "KMS-only" custody, which
contradicted decision 011's software provider for local/CI. Two-human review
acceptance now checks the **host branch-protection policy** — CODEOWNERS
requests reviewers, it does not require them, and a synthetic PR in local CI
cannot prove a rule living in the host's settings. The **per-party issuance
root relocated** from `party-registry/07` to `trust-kernel/04` under decision
015's boundary rule; party-registry consumes the API. `trust-kernel/05`'s
dependencies corrected: Spec B models deletion, purge, restore replay, and
alias-closure key destruction, so it can no longer depend on
`trust-kernel/03` alone — it now declares `foundation/08`,
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
been flagged — the structure the AEPD fined Goldcar over, and exactly the
re-identification capability decision 014's *EDPS v SRB* analysis identifies
as what makes a value personal data. Ruling: keyed hash with **the key in
the key management service, never in the database**, plus the parts that
were missing entirely — issuer and document-type canonicalization (one
document written two ways must yield one key, or matching does not work),
a key-rotation and re-derivation story with a stated window, a collision
policy, and a written brute-force analysis against the weakest
jurisdiction's format. A stored salt was rejected: a salt sitting beside the
data does nothing against an attacker holding the table.

**The recovery freeze had a time bomb.** A deletion requested during the
7-day freeze was to execute automatically at expiry. So an attacker
recovers the account, requests deletion, waits a week, and the system
destroys the record for them — the exact attack the freeze exists to stop,
merely delayed, and the task's own outside check would have passed. Ruling:
the queued deletion **requires fresh authenticated confirmation after
expiry**. A legitimate owner is never permanently blocked, which was the
reason for queueing rather than rejecting; an attacker who has lost access
by day seven cannot finish. Notifications at request, at expiry, and before
execution.

**One-time-code sessions get step-up on a closed sensitive set.** The code
path is first-class by design, but nothing said what such a session may do.
If it can enroll a passkey, change channels, create grants, request a
packet, or start a deletion, then AC-PI2 is performative — an attacker never
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
marker inert)** — the case where an expiry bug would otherwise hide forever —
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
implementable instruction — a column, a rendered packet, a search index, and
an abuse check on worker-submittable free text each need a bound, and absent
one the first oversized input decides the behavior in whichever component
fails first. The model's principle was that no *cultural structure* is
imposed, not that no limit exists. Bounds are stated with reasoning at the
schema site, and over-length input is **rejected loudly, never truncated
silently** — silent truncation being the precise harm the model exists to
prevent.

**Corrections applied.** Layer `binds` moved from `#009` alone to 013, 014,
016, 017, 019, 020. `person-identity/01` gains `foundation/07` (signup
writes both planes) and defines "instantly" as spine commit, with payload
following through the outbox — three different claims were hiding in one
word. `person-identity/06`'s "permanent alias table" with a flipped pointer
becomes **append-only alias events plus a named, role-scoped projection
exemption**, since decision 017 removed the blanket derived/cache license.
`06` also gains the deletion-under-merge obligation: it owns the alias
closure, so it owns proving the deletion subsystem receives the correct one
under a merge-or-unmerge racing a deletion. `07`'s `challenge_state` becomes
**append-only challenge events** — a mutable field on an append-only marker
row is a contradiction — and marker filings and steward approvals join the
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
  changes. It does not silently override ratified mechanics — a conflict with
  `model/attestation-interface.md` or `contract/CONTRACT.md` is a defect
  resolved by a decision entry, not by whichever file was written last.
- **The draft header claiming it "supersedes nothing" is struck.** It was
  attempting to encode drafting immaturity and instead encoded a false
  authority ordering.
- **Scope is the identity layer.** Dispatch holds its own thesis, aligned.
  Identity is the platform; adjacent businesses are secondary to it.
- **`handoff/founder-thesis.md` is stale**, marked as such in its own header,
  and superseded on every point where the two differ — notably its placement
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
  others'; structured references (entry 023); and observable meta-signals —
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
- **Slope ships with its limits disclosed** — the three known failure modes
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
- **Worker-facing job-match suggestions** are permitted in principle — ranking
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
  facts — this attestation was found falsified, this one corroborated — and
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

- **The record layer is free to everyone, permanently** — candidates and
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
- **Nobody re-inks the mark** — third-party embeds and Grain's own verticals
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
severity-gated carve-out on four counts — the marker is keyed to a document
identifier with no payload, carries a fixed expiry, requires an evidential floor
of "could confidently report to the police", and produces **review, never
denial**, whereas attester trust produces automatic network-wide down-weighting
with no expiry. 014's own escalation #2 anticipated the structure: a
cross-employer record carrying an exclusion flag is a blacklist and will be read
as one.

`research/13` closes the remaining argument. **AEPD PS-00176-2024 (Iberia
Cards)** fined a controller that retained precisely the minimal link needed to
recognise a returning applicant and used it against them — an Article 6(1)
infringement, with no fraud and no safety involved.

**Consequences.**
- `peer-references` keeps its Sybil apparatus — reciprocity caps, velocity
  limits, device/IP clustering, verified-anchor weighting, `excluded` grading,
  the shadow/promotion gate — which already addresses the abuse case that
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

**The AI Act does not compel it.** Art. 12(1) is a design duty — the system
"shall technically allow for" logging — not a retention duty. Art. 12(3) is the
only provision itemising log content, including input data, and it applies only
to Annex III point 1(a) biometric identification. Grain is Annex III point 4, so
**no minimum log content is prescribed at all**. Art. 19 is the sole retention
duty: a six-month floor, risk-based, expressly subordinated — "unless provided
otherwise in the applicable Union or national law, **in particular in Union law
on the protection of personal data**". A provision that yields to the GDPR
cannot be the Art. 17(3)(b) legal obligation that displaces a GDPR right. Art.
17(3)(b)'s "to the extent that", Art. 6(3) with Recital 41, and *Digi* (C-77/21)
and *SS SIA* (C-175/20) each independently confine it further.

**No other regime asks for it either.** Colorado SB 26-189 §6-1-1702(4) imposes
a three-year retention duty directly on Grain as developer, but over **system
version identifiers, changelogs, and deployer notices** — system artifacts, not
person records. California 11 CCR §7101(e) says expressly that a business is not
required to retain personal information to fulfil a consumer request; §7155(c)'s
five-year duty covers risk assessments about the processing. US federal
recordkeeping binds the employer, not the vendor.

**The ruling.** A run record holds the **requesting party, the timestamp, the
instrument and model versions, and the input references** — and **not the
output**, and nothing else attributable to a person. It is reachable by
regulator and by audit and by no read path that touches ranking or a worker's
packet. Retention is six months minimum per Art. 19, with the period stated as a
number rather than as "the compliance period", which resolved to four different
periods across the regimes surveyed.

**Two open items this creates.**
- **OPEN: the pseudonym.** Pseudonymised run records work only if the pseudonym
  is not the `ledger_person_id` — entries 013 and 020 make tombstoned ids
  permanent and referenced in spine signatures forever, which is a retained
  means of singling out (EDPB Guidelines 01/2025). What identifier a run record
  carries is undesigned.
- **OPEN: the architectural fork.** Under `foundation/05` a run record either
  sits inside the subject's DEK envelope, dying at deletion and breaching Art.
  19, or outside it, surviving readable and unlawful. It must be split
  spine-side and payload-side, and no task owns that.

**Recorded, not ruled.** Two findings from `research/13` and `research/14` that
belong to the founder and are not decided here: worker-facing job suggestions
match 42 U.S.C. §2000e(c)'s definition of an employment agency — "to procure for
employees opportunities to work for an employer" — which would make Grain a
covered entity in its own right rather than a vendor supplying documentation to
one; and a cross-employer performance register is a labour-market information
exchange under the January 2025 DOJ/FTC guidelines, where third-party
intermediation is expressly not a defence. Both are in `ORDER.md`'s gate table.

## 027 — Mark, pointer and imprint constraints settled (2026-08-18)

Recorded in `mark/README.md` and `DESIGN.md` §3; generator and assets in `mark/`.

**The mark.** Three concentric threaded bands, seven lobes, unequal band widths,
one lobe deliberately deepened. Provisional — the lobe count may change and the
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
  exit is all-or-nothing — whole-profile deletion remains available at any time,
  but individual chapters cannot be quietly excised.

**Attestation.**
- **Partners write freely. No worker countersign.** Founder ruling: the employer is
  inherently more trustworthy. Consequence to design for: GDPR Art. 16 gives a
  right of rectification regardless, so a correction path must exist — it moves
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
  genuinely signed by that party, whether it is a duplicate or spam — yes. Whether
  a performance claim is fair — never. Reason: FCRA §611 requires a consumer
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

**Verification tiers.** Four internally — recorded, contact, document, biometric.
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
