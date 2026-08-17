# Ledger Design 0.1

Independent design, produced in a clean-context session that read only:
`handoff/HANDOFF.md`, `handoff/founder-thesis.md`,
`handoff/attestation-interface.md`, `research/00` (binding founder decisions
and rulings R1/R2), and the research corpus `research/01`–`07`.
`handoff/dispatch-positions-and-open-questions.md` was **not** read.
Companion document: `design/interface-verdict-0.1.md` (the ratify/amend
verdict on the interface contract).

Binding inputs honored throughout: the interface contract as the boundary;
founder decisions 1–10 and rulings R1 (not a CRA; worker-owned platform) and
R2 (whole-profile deletion any time; verified records never editable).
Research constraints from `07` are honored where they do not conflict;
tensions are named where they exist.

---

## TLDR — all conclusions, including contested ones

1. **Identity.** `ledger_person_id` is an opaque surrogate issued instantly
   at universal self-signup with no proofing gate. All verification is bought
   externally and stored as dated, issuer-attributed, leveled *verification
   attestations* against the ID — assurance lives per-attestation, never in
   the ID. Phone and email are contact channels and weak signals with
   freshness decay, never identity anchors. Duplicate detection is
   multi-field probabilistic (Fellegi-Sunter) with mandatory human review
   before any merge touching attested history. Merge and unmerge are
   append-only events with a permanent alias table; attested history is never
   rewritten — old attestations keep their original `subject_id` and resolve
   through the alias closure at read time.

2. **R2 makes fresh-start a worker entitlement, not only an attack.** A
   worker who deletes their profile and re-signs up starts cold, having
   legitimately shed their record. The design accepts this as the price of
   the worker-owned model; the anti-fraud layer targets *concurrent*
   multi-accounting and party-side fraud, not record-shedding. Contested;
   stated plainly rather than buried.

3. **Record model: two-plane architecture.** An append-only integrity spine
   (IDs, hashes/commitments, signatures, provenance grade, timestamps) is
   separated from an erasable payload store (the actual claim content and all
   personal data). This is what lets R2's whole-profile deletion coexist with
   append-only integrity, and it is the EDPB's own recommended pattern.
   Claim classes — `self_asserted`, `peer_attested`, `party_attested` — are
   distinct object types, never a flag. Self-asserted claims are
   worker-editable (edit = new version) until first third-party verification,
   then frozen. Sensitive personal data categories are banned from
   attestation payloads outright.

4. **Attesting parties.** Single-root trust registry with lifecycle states
   (`pending → active → suspended → revoked`), tiered vetting (internal
   vertical vs. external partner) recorded only in the registry — the
   attestation schema cannot distinguish them, per founder decision 2.
   Signatures: Ed25519 in a JWS envelope, `kid`-bound, verified against the
   registry; every attestation gets a ledger hash-chain timestamp at write.
   Key compromise never retroactively invalidates timestamped history.
   Suspension flags past attestations at read time; it never edits them.
   Party reliability is monitored structurally (bipartite anomaly detection,
   dispute rates) and is internal-only — party-attestation fraud, not
   peer-Sybil, is treated as the top adversarial risk.

5. **Lifecycle.** The ledger validates provenance (who said it, validly, in
   schema), never substance — it does not re-verify work. Corrections are
   superseding attestations with a mandatory `supersedes` pointer;
   current-truth is derived by walking the chain. Disputes follow an
   FCRA-shaped, time-boxed process ending in a superseding correction or a
   permanent, always-co-rendered worker counter-statement. Nothing is edited.

6. **Dimension standing is derived by the ledger** from `dimensions_exercised`
   across attestations, by a published, deterministic, coarse rule, with
   every standing entry citing its supporting attestations. It is a summary
   of evidence, not a score; no cross-dimension composite ever exists.
   Contested — the alternative (pass through last-attested values unaggregated)
   is defensible and marked below.

7. **`work_kind` is ledger-authored**: a small versioned vocabulary (order
   30–150 terms at detailed-work-activity grain), governed by a taxonomy
   council (ledger editor + one delegate per attached party), versioned with
   immutable historical bindings and published crosswalks to O*NET/ISCO/ESCO.
   Attestations bind `work_kind@version` permanently.

8. **Read access.** Disclosure control is party-level (decision 7): the
   worker grants and revokes readers, never curates claims. The person sees
   everything raw; a granted party (internal or external — indistinguishable)
   receives only the generated-at-read prior packet; vertical customers have
   no ledger read at all. All reads are logged and worker-visible.

9. **Non-person identities.** Only two ledger-native entity types exist:
   persons (subjects) and attesting parties (issuers). Organizations and
   customers are vertical-local; an employer that wants to attest registers
   as an attesting party, which is an issuer identity, not a subject profile
   — no organization has a career on the ledger.

10. **Interface verdict: ratify with amendments** — resolved answers to all
    four flagged open items plus five schema amendments. See
    `interface-verdict-0.1.md`.

11. **Named tension with research (not resolved here, per R1):** the FCRA
    analysis in `01` concludes the US product is a CRA on conduct; R1 rules
    the worker-owned-platform model governs design. The design therefore does
    not build CRA machinery, but it deliberately avoids *foreclosing* it: the
    dispute process, read logging, party-level grants, and a policy-configurable
    reportability window are all shaped so that a later counsel-driven
    pivot is a policy change, not a schema migration. [FOUNDER-CALL] The
    alternative is to strip the reportability-window hook entirely for schema
    minimalism.

---

## 1. Person identity

### 1.1 The `ledger_person_id`

An opaque surrogate identifier (UUIDv7 or equivalent: time-ordered,
meaningless, non-enumerable), issued the moment anyone self-signs up.
Reasoning:

- **Universal issuance is a founder decision (00 §3)** — signup is not gated
  on verification, program membership, or documents. Every large-scale
  system surveyed (Aadhaar, UNHCR PRIMES, NIST 800-63-4's modular IALs,
  healthcare MPIs — `03`) separates enrollment from proofing and issues
  first. A global system will enroll undocumented and low-document workers;
  the ID must not implicitly require a government document to exist.
- **Opaque, because derived IDs break.** Any ID carrying embedded meaning
  (name, document number, phone hash) forces the ID to change when the
  underlying fact corrects — fatal in an append-only system where the ID is
  the join key for a career.
- The ID is never reissued and never recycled, including after profile
  deletion (§2.5). A vertical holds it as one identity reference among
  others, never its primary key (contract, prior-packet table).

### 1.2 Progressive verification

Verification is bought from external providers, not built (contract). Each
verification event is stored as a **verification attestation** against the
person: `{issuer, method, level, verified_at, expires_or_decays_at,
evidence_commitment}`. Consequences:

- Assurance is a property of the evidence set, not of the person or the ID.
  A person's current assurance level is *derived* at read time from their
  verification attestations, mapped to a small ordinal scale
  (`none / channel / document / biometric`-shaped, aligned loosely with NIST
  IAL tiers; exact tiering is an implementation detail, deliberately not
  frozen here — `03` flags 800-63-4 mappings as directional).
- Verification providers are registered attesting parties like any other
  (same registry, same signature scheme). This keeps one trust machinery,
  not two.
- **Phone and email are contact channels and weak proofing signals, never
  anchors.** Number recycling (45–90-day US windows), SIM-swap (80%
  first-try success in the Princeton study), and shared devices make
  phone-control too weak to be a join key (`03`). Channel-control
  attestations carry freshness and decay; an 18-month-old phone verification
  weighs less than yesterday's. grain's phone-anchor prior art does not
  generalize (07 §7); the grain ADR itself was not readable from this repo
  and is assessed only via the research corpus's characterization.

### 1.3 Duplicate detection

- **Never single-field, never phone/email alone.** Candidate duplicates are
  scored by weighted multi-field probabilistic matching (Fellegi-Sunter:
  name variants, DOB where present, document identifiers, channels, device
  signals) — the credit bureaus' mixed-file litigation record is the
  cautionary tale for weak-field matching, and a wrong merge here
  contaminates a *career*, which is worse.
- Any merge candidate where either profile carries attested history requires
  **human steward review** before execution. Auto-merge is permitted only
  for freshly created, attestation-free profiles matching on strong evidence
  (e.g., same verified document).
- Expect ~up-to-10% organic duplicate rates from entry variance and
  transliteration (`03` §8) — duplicates are an operating cost, not an edge
  case; instrument for them from day one.

### 1.4 Merge and unmerge under append-only rules

The healthcare-MPI pattern, verbatim in structure:

- A merge is a new immutable event:
  `person_merged{survivor_id, absorbed_id, evidence_refs, actor, ts}`.
- The absorbed ID is tombstoned into a permanent **alias table**; it still
  resolves — through the alias closure — to the survivor. Nothing that
  referenced it breaks.
- **What merge does to attested history: nothing.** Attestations keep the
  `subject_id` they were issued against, forever; their signatures stay
  verifiable byte-for-byte. Resolution happens at read time: the prior
  packet for the survivor assembles across the full alias closure. This is
  the only answer compatible with signed, append-only attestations — rewriting
  `subject_id` would break every signature.
- Unmerge is `person_unmerged{...}` flipping the alias pointer back; because
  neither event stream was touched, reversal is clean. Attestations issued
  *during* the merged period against the survivor ID are flagged for steward
  re-assignment review at unmerge — the one genuinely manual residue of a
  wrong merge, and the reason merges over attested history need review
  before, not after.

### 1.5 Fresh-start abuse — reshaped by R2

Research (`03` §4, `06` §3) says every comparable system defeats
abandon-and-resignup with a sticky identity layer, and recommends a separate
anti-fraud layer (document-reuse detection, device fingerprinting, optional
biometric 1:N) rather than signup friction. This design adopts that layer,
with one honest correction the research corpus predates:

**R2 legalizes the fresh start.** A worker may delete their whole profile at
any time and sign up again clean. Therefore:

- The anti-fraud layer's mandate is narrowed to (a) *concurrent*
  multi-accounting, (b) identity theft / synthetic identity, and (c)
  party-side fraud — not to preventing a person from shedding their own
  record, which is now their right.
- The systemic cost is real and accepted: negative history is only as
  durable as the worker's willingness to keep their profile. Two mitigations
  are structural, not schema: verticals keep their own local records
  (deletion does not reach them — the boundary already guarantees this), and
  a cold profile has no positive history either, so shedding a record is
  expensive for anyone with accumulated standing. The record's value to the
  worker is the deterrent, not a lock.
- [FOUNDER-CALL] Document-reuse detection (a government ID that anchored a
  deleted profile reappearing on a new one) *could* be retained across
  deletion as a salted hash to flag — not block — re-enrollment for
  anti-fraud review. This retains a derivative of deleted data and cuts
  against the spirit of R2; default here is **not** to retain it. The
  alternative (retain the hash, Uber-style) is the stronger anti-fraud
  posture.

---

## 2. The record model

### 2.1 Two planes: integrity spine and payload store

Every record object is split:

- **Integrity spine (append-only, never erased):** object IDs, object type,
  provenance class, subject/issuer references, cryptographic hash
  (commitment) of the payload, signature, ledger hash-chain timestamp,
  supersession pointers. Contains no readable personal data.
- **Payload store (erasable, versioned):** the claim content itself — text,
  scores, dimensions, evidence details, contact data, all PII.

Reasoning: this is the only architecture in which R2's "delete the whole
profile at any time" and "verified records are never editable" are *both*
true. Append-only survives as an **integrity property** (the spine proves
what was said, by whom, when, and that nothing was altered), while the
payload plane satisfies erasure. It is also the EDPB's own recommended
pattern (Guidelines 02/2025, per `01`/`07`), with the honest caveat that
hashes of personal data are still personal data under that guidance —
payload deletion plus commitment retention is strong mitigation and the
worker-consented model's best available shape, not a jurisdictional
guarantee. Flagged for counsel, not redesigned around.

### 2.2 Claim classes

Three distinct object types — not a grade *flag* on one type, because
founder decision 5 requires that nothing self-asserted can be
*schematically* confused with anything attested:

| Class | Author | Editable? | Signed? |
|---|---|---|---|
| `self_asserted` | the worker | yes, until first third-party verification; each edit is a new version, prior versions retained while the profile lives | no |
| `peer_attested` | another ledger person | no — append-only from birth | worker-context signature (account-bound), not registry-grade |
| `party_attested` | a registered attesting party | no — append-only from birth | registry-grade (Ed25519/JWS) |

- **Verification upgrades, never silently** (decision 5): verification is
  itself a new attestation *referencing* the self-asserted claim. The
  claim's effective grade is derived from its attached verifications. On the
  first party-grade verification, the self-asserted claim **freezes** — the
  edit path closes permanently; later changes happen only by supersession
  from the verifying class. The worker was warned of exactly this at the
  moment they requested verification (§8.2).
- **Peer attestations are structurally down-weighted and anchored.** Per
  `06`: reciprocity caps, velocity limits, device/IP clustering, and
  verified-anchor weighting (a peer attestation from a tenured, verified
  account counts more) are first-class ingestion-time signals recorded on
  the spine. Where a peer attestation can reference a shared engagement
  (both parties attested into the same engagement by a party), it is marked
  transaction-anchored and weighs categorically more. Peer attestation
  without any anchor is accepted but rendered as what it is: an unanchored
  social claim.
- **Sensitive-data ban:** education records beyond credential name/issuer,
  government ID numbers, DOB, health, criminal proceedings, and kindred
  sensitive categories are prohibited in attestation payloads by schema
  validation (`07` constraint 12 — the highest-leverage compliance move
  across all three researched jurisdictions, and costless to the thesis).

### 2.3 Credentials

A credential (certification, license, training completion) is not a fourth
class — it is a `party_attested` claim whose `work_kind`-equivalent is a
credential type, issued by the certifying body as a registered attesting
party (or imported via a verification provider who attests to having
verified it, which yields a party-attested claim *about the verification*,
with the provider as issuer). This keeps one lifecycle, one signature
scheme, one dispute path.

### 2.4 Supersession and current truth

- A correction is a new object with a mandatory `supersedes` pointer to its
  target (contract; `04` TLDR-7). Chains are walked to derive current truth;
  superseded objects remain readable to the worker and — flagged as
  superseded — to readers. The PH DPA Sec. 16(d) finding (corrected and
  retracted versions must both stay accessible and travel together) says
  versioned correction is not merely permitted but sometimes mandated;
  render both, always.

### 2.5 Whole-profile deletion (R2)

First-class operation, worker-initiated, no gate, no cooling-off longer than
an anti-coercion confirmation window (measured in days, to defeat "delete
your profile or else" coercion — a small, deliberate friction):

1. Reads stop immediately; all grants are revoked; the person disappears
   from prior-packet issuance at once.
2. The payload plane for the person — self-asserted claims, all attestation
   payloads about them, verification payloads, contact channels — is purged
   within a fixed published window.
3. The integrity spine retains only: tombstoned `ledger_person_id` (never
   reissued), object IDs, commitments, issuer references, timestamps. This
   preserves (a) the ledger's own hash-chain integrity, (b) attesting
   parties' ability to account for what they issued, and (c) nothing
   readable about the person.
4. Attesting parties are notified their subject is gone. Their vertical-local
   records are theirs and untouched — the boundary already keeps the
   work itself out of the ledger, which is what makes deletion honest rather
   than theatrical.
5. Already-delivered prior packets are governed by the receiving party's
   data-handling terms (see interface amendment A5) — deletion terminates
   future reads; it cannot recall the past ones.

### 2.6 Retention/reportability hook

The read path supports a policy-configurable `reportable_until` filter on
adverse content (default: no limit). Under R1 no CRA-style seven-year rule
is *applied*; the hook exists so that if counsel later requires windowed
reporting in some jurisdiction, it is a configuration change, not a
migration. Storage is unaffected either way. This is the named
R1-vs-research tension made concrete: the design obeys R1 and hedges
cheaply. [FOUNDER-CALL] Alternative: delete the hook for minimalism.

---

## 3. Attesting parties and the trust registry

### 3.1 Registration and vetting

Single-root registry operated by the ledger (`04`: this is a
one-operator system, not a federation — CA/Browser-Forum shape, not SWIFT).
Lifecycle: `pending → active → suspended → revoked`, all transitions as
append-only `party_events` with reason codes, public per-party status and
history (eIDAS trust-list transparency).

- **Vetting is tiered; the schema is not.** Internal verticals onboard under
  light review; external partners under proportionate diligence — legal
  identity, business verification, an initial probationary scope (volume
  caps, heightened monitoring). The tier, probation, and all vetting
  metadata live **only in the registry**. An attestation issued by an
  external partner is byte-for-byte schema-identical to an internal one
  (founder decision 2). Only the trust registry can tell them apart, and
  read-time trust weighting draws on the registry, not the attestation.
- **Accreditation is checked against closed allowlists, and re-checked.**
  `06` §2: attackers fake the accreditor, not just the credential. A party
  claiming certification authority must appear on a recognized external
  registry (DAPIP/CHEA-style where one exists); party status is re-verified
  on a schedule, never one-time.
- **Precondition for the first external party (legal, not schema):** the
  conditional liability-shield structure in worker and party agreements
  (qualified-privilege analog, `06` §5, `07` constraint 11). Without it the
  record goes "name, rank, dates only" silent. Named here because the
  registry must not activate an external party before it exists.

### 3.2 Signature scheme

- **Ed25519 over a canonical payload in a JWS envelope**, `kid` header
  identifying the key, verified against the registry — not blockchain/DID,
  not JSON-LD Data Integrity (`04`, high confidence; the hard problem is
  vetting, and blockchain doesn't touch it).
- The envelope is kept **W3C VC 2.0-compatible in shape** (claims structured
  so a VC-JOSE-COSE projection is mechanical), because `02` is right that
  the envelope is commodity and EUDI-era interop is cheap to keep open —
  but full VC conformance is deferred until an external wallet/interop
  requirement actually exists. Differentiation lives in provenance grading
  and the registry, exactly where W3C's own trust-registry effort stalled.
- Peer attestations use account-bound keys under the same envelope, so one
  verification path serves both classes; the registry entry type (person
  account vs. registered party) is what distinguishes grade.

### 3.3 Key lifecycle and compromise

The transparency-log pattern (`04`), adopted whole:

- Every key has `{party_id, key_id, valid_from, valid_until/revoked_at}`;
  key events (`registered, rotated, revoked, compromised`) are their own
  append-only log — never edited in place.
- **Every attestation receives a ledger hash-chain timestamp at write.**
  This is the load-bearing piece: it makes "compromise ≠ retroactive
  invalidation" defensible instead of exploitable. Verification rule: valid
  iff the key was active at signing time **and** the ledger timestamp
  predates any compromise report for that key. A party cannot disavow
  genuine history by claiming backdated compromise; anything appearing after
  a compromise report is flagged suspect.
- The storage layer must not preclude later Merkle-tree/CT-style public
  inclusion proofs (`04` TLDR-8); build the hash chain from day one, expose
  proofs later if a consumer ever needs offline non-tamper evidence.
- Residual risk, named: the ledger operator itself is the single root of
  trust; a CT-style public commitment log over registry changes is the v2
  hardening, not v1.

### 3.4 Suspension, revocation, and issued attestations

- **Suspension is never retroactive** (eIDAS precedent). Already-issued
  attestations remain in the ledger, cryptographically valid, and acquire a
  *derived, read-time* flag — "issuer since suspended (reason class)" —
  rendered wherever they are surfaced. The flag is computed from the
  registry at read; nothing is written into the attestation. Cryptographic
  validity and substantive reliability are kept visibly distinct — `04`'s
  warning about conflating them is honored by rendering them as two fields.
- **Revocation for proven fraud is stronger:** the ledger issues its own
  signed invalidation attestation (`ledger_invalidated{target, reason}`)
  against each specific fraudulent attestation — supersession machinery, not
  deletion. Blanket invalidation of a fraudulent party's entire output is a
  batch of such records, each auditable.

### 3.5 Party reliability over time

Party-attestation fraud is the top-weighted adversarial risk (`06`: the
high-trust tier is the highest-value target; `07` constraint 4). Standing
machinery:

- Bipartite (party × subject) network-structure anomaly detection —
  anomalously dense/positive clusters, correlated onward outcomes — the
  detection family that stayed effective when content analysis lost to
  generated text.
- Dispute rates, correction rates, corroboration rates (how often this
  party's attestations are consistent with other parties' attestations
  about the same people) feed an **internal-only** reliability signal.
- That signal drives registry actions (probation, audit, suspension) and
  read-time trust weighting. It is never exposed as a party score — a
  visible score would become the next Goodhart target.

---

## 4. Attestation lifecycle

**Ingestion.** Schema validation (version, required fields, sensitive-data
ban, `work_kind@version` exists) → signature verification against the
registry (key valid at signing time) → issuer state check (`active`; within
probation caps if probationary) → subject resolution (must be a live,
non-tombstoned ID; if absorbed, resolved through the alias table and both
recorded) → ledger timestamp → append (spine + payload). Rejection returns
to the party; the ledger never silently rewrites an inbound attestation.

**What the ledger does and does not verify.** It verifies **provenance and
form** — who said it, that they validly said it, that it is well-formed. It
never re-verifies **substance**: the vertical is the system of record for
the work, and per-unit evidence deliberately never crosses (contract). The
ledger's honesty machinery is the registry, the anomaly detection, and the
dispute process — not re-adjudication it has no evidence to perform.

**Supersession.** As §2.4. A superseding attestation must come from the
same issuing party (or from the ledger itself under §3.4 invalidation);
party A cannot "correct" party B — it can only add its own attestation.

**Dispute.** FCRA-shaped because it is the one battle-tested pattern for
exactly this situation (`04` §4), adopted as product design under R1, not as
statutory compliance:

1. Worker files a dispute against a specific attestation (structured, with
   grounds).
2. The issuing party is notified promptly; a time-boxed window opens
   (30 days, +15 on new evidence).
3. Outcomes: (a) party agrees → superseding correction with `supersedes`
   pointer; (b) party stands → the worker's **counter-statement** attaches
   permanently and is co-rendered wherever the attestation is surfaced —
   part of the record, not a footnote; (c) party is unresponsive → the
   attestation acquires a derived "unresolved dispute — issuer unresponsive"
   flag, which also feeds the party's reliability signal.
4. Nothing is ever edited or deleted by dispute (founder decision 6). The
   worker's remaining lever is R2 deletion — total, never selective, which
   is what keeps the record meaningful (decision 7's logic applied to
   deletion: no claim-level curation by another name).
5. Dispute-outcome distributions are monitored so the process itself can't
   be gamed into erasing true negatives (`06` threat table, last row).

---

## 5. Dimension standing

**Ruling: standing is derived by the ledger from attestations; attestations
assert only `dimensions_exercised` per engagement.** Reasoning:

- An attesting party can honestly speak only to what it observed in its own
  scope. "Standing" is inherently cross-vertical and longitudinal — only the
  ledger sees the whole graph. Letting any single party *assert* standing
  would let one attestation overwrite a career-level fact, which is both an
  attack surface (`06`) and a category error.
- The derivation is **deterministic, published, and coarse**: per dimension,
  standing is the highest level demonstrated in at least two independent
  attestations (distinct issuing parties or distinct engagements) within a
  freshness window, else the highest singly-attested level marked
  `singly_attested`. No weighting model, no learned inference — the
  contract's "derived estimates never sync as fact" line cuts against the
  ledger shipping model outputs downward, and the *SCHUFA*/Art. 22 finding
  (`07` §3) plus the Goodhart evidence (`07` constraint 10 — the Nature RCT
  on score granularity) both say: the more evidence-like and coarse the
  output, the safer and less gameable.
- **Every standing entry carries citations** — the attestation IDs it rests
  on — so any consumer can drop from summary to evidence. Standing is a
  view over the record, recomputable from it, and stored only as cache.
- No composite across dimensions is ever computed or exposed. Seven
  dimensions in, seven (at most) coarse ordinal positions out.
- Stretch-selection outcomes below bar are **excluded** from downward
  standing revision (contract: a development bet must not read as evidence
  against the worker); they appear in the record as what they are.
- The dimension set itself is a founder hypothesis, not validated prior art
  (`05`: SFIA/Hay/Radford converge on autonomy/complexity/accountability but
  none covers machine leverage, customer exposure, team size, and all are
  role-grained, not attestation-grained). The standing rule and per-dimension
  level definitions are therefore versioned like the taxonomy (§6) and
  expected to be re-calibrated after two verticals' worth of real
  attestations.

**Rendering in the prior packet:** `dimension_standing[]` = per dimension:
`{level, corroboration (multi|single), as_of, supporting_attestation_refs[]}`.
Verticals consume it as a cold-start prior, overridden by local evidence —
the contract already says this; the citations make it cheap to honor.

[FOUNDER-CALL] The alternative is pass-through: the ledger relays
last-attested `dimensions_exercised` values with no aggregation rule, and
every vertical derives standing locally. That maximizes Art. 22 distance but
duplicates derivation in every vertical and makes "as last attested across
all verticals" (the contract's own phrase) undefined when attestations
disagree.

---

## 6. The `work_kind` taxonomy

- **Authored by the ledger, not adopted** — nothing adoptable exists at the
  right grain and scope (`05`: O*NET US-only and ~9-year per-occupation
  staleness; ESCO EU-only; ISCO too coarse). Target grain: the
  detailed-work-activity level — order 30–150 terms, not occupations, not
  mega-buckets.
- **Governance** (the genuinely unsolved part, `05` §4): a taxonomy council
  — a ledger-side editor with final authority, plus one delegate from each
  attached attesting party of vertical scale (internal or external; same
  seat, same rights — decision 2's symmetry extended to governance).
  Change proposals are public to all parties, logged, and versioned.
  [FOUNDER-CALL] Alternative: pure internal editorial team, faster and
  cheaper, at the cost of external partners experiencing the vocabulary as
  imposed rather than joint — which matters once partners write attestations
  in it.
- **Versioning discipline, BLS-style, non-negotiable:** the vocabulary is
  versioned (v1, v1.1, …) with a public changelog; every attestation binds
  `work_kind@version` **immutably** — historical bindings are never edited;
  reclassification happens only in separate versioned crosswalk tables
  (old→new, explicitly one-to-one or one-to-many). Cadence: weeks-to-months
  with a changelog (Lightcast-shaped), not years.
- **Crosswalks out** to O*NET-SOC and ISCO-08/ESCO published from v1, for
  external legibility — federating onto existing standards' tops rather than
  reinventing them, as ESCO did onto ISCO.
- **Aliases, not forced trees:** local vertical terms map up via an alias
  graph (LinkedIn Skills Graph pattern); the vertical's local taxonomy stays
  local (contract), and only the translation to `work_kind` crosses.
- Grain mismatch is the central failure mode (`05` constraint 8): the v1
  vocabulary must be drafted against at least two live verticals' real work,
  not extended by analogy from one.

---

## 7. Read access and the prior packet

### 7.1 Reader classes and grants

Disclosure control is **party-level, not claim-level** (founder decision 7 —
claim curation destroys the record's meaning for consumers; the worker's
levers are who reads, dispute, counter-statement, and total deletion).

| Reader | Access | Under |
|---|---|---|
| The person | Everything raw: all claims incl. superseded versions, all attestations incl. disputed/invalidated, verification history, grants, full read log | Always; it is their record (decision 4) |
| A vertical considering or engaging them | The prior packet only | An active worker grant to that party |
| An external partner | Identical to a vertical in every respect — the read path cannot distinguish them (decision 2) | An active worker grant |
| A vertical's customer | Nothing. No ledger read exists for customers; whatever a customer learns is vertical-local and the vertical's responsibility | — |
| The ledger operator | Operational access under audit; derived operator analytics need not be worker-visible (decision 4) but raw-record access is logged like any read | Internal policy |

- A **grant** is an append-only event pair:
  `grant{person, party, granted_at}` / `revocation{...}`. Grants are scoped
  to a party, cover the whole record (the packet's defined contents),
  and are revocable at any time with immediate effect on future reads.
  Every packet issuance is logged `{party, purpose_tag, ts}` and visible to
  the worker.
- Routing-driven flow is the same machinery: when the person enters a
  company program, granting the operating vertical is part of onboarding —
  explicit, recorded, revocable, not implied.

### 7.2 The prior packet

Generated at read time from the live record — never stored, so revocation,
deletion, supersession, and registry-state changes are always reflected.
Contents per the contract: `ledger_person_id` (resolved through the alias
closure), verification attestations (amendment A2), `credentials[]` with
explicit provenance grade, `dimension_standing[]` per §5, and
`prior_attestations[]` in the interface schema — each carrying its
supersession status and any derived issuer-state or dispute flags.
Self-asserted claims cross inside the packet only as what they are:
provenance-graded, schematically unconfusable with attested content.

---

## 8. Consent and the worker view

### 8.1 What the person sees

Everything raw (§7.1), plus: the registry status and history of every party
that has attested about them; the dispute state of every attestation; the
full read log. Not shown by right: operator-internal derived analytics and
consumer-side routing estimates (decision 4) — those are recomputable
inferences, not facts of the record.

### 8.2 Onboarding consent

One consent instrument, plain-language, covering exactly the record's real
mechanics — because under R1 the model's defensibility rests on the worker
knowingly publishing and controlling their own profile:

1. Parties they engage with will write signed, append-only attestations
   about their work into their record.
2. Verification freezes: requesting or accepting third-party verification
   makes the verified claim permanent for the life of the profile
   (re-affirmed contextually at each verification request, not only at
   signup).
3. Disclosure is party-level: grants govern who reads; no claim-level
   curation exists.
4. Dispute rights: the time-boxed process and the permanent counter-statement.
5. Deletion right: the whole profile, any time, total — and its converse:
   deletion is the only removal; individual verified records never come out.
6. Data-handling: what a receiving party may retain from a delivered packet
   (per its agreement), and that deletion stops future reads but does not
   recall past deliveries.

### 8.3 Deletion semantics

Per §2.5. Deletion is the worker's unilateral right (R2), total and
first-class; it also discharges the bulk of jurisdictional-erasure exposure
structurally rather than via per-claim litigation of the append-only rule.

---

## 9. Non-person identities

**Organizations and customers are not ledger identities.** The ledger knows
exactly two entity types:

- **Persons** — the only subjects. The company is the ledger *for the
  person* (HANDOFF); the litmus test ("would another vertical want this
  exact row, untranslated?") fails for customer/org records, which are
  meaningful only in a vertical's operating context.
- **Attesting parties** — the only issuers: registry entries with keys,
  lifecycle state, and vetting metadata. A party entry is an *issuer
  identity*, not a subject profile: no career, no standing, no attestations
  about it as a subject. An employer or customer org that wants to attest
  registers as a party; everything else about it stays vertical-local.

This keeps the symmetry clean: the contract already excludes AI executors
because "a model configuration has no career" — neither does an
organization. If a future vertical needs portable organization facts, that
is a new interface negotiation, not a silent extension of person machinery.

---

## 10. Explicitly out of scope / deferred

- Business model and payment relationships (founder decision 9 — nothing in
  this schema encodes one).
- Substrate and deployment boundary (HANDOFF: schema line binds now, service
  boundary later; nothing above assumes a separate service).
- CRA-registration, controller/processor characterization, and the
  liability-shield contract structure — counsel items (`07`), with the
  design hooks noted in §2.6 and §3.1.
- grain's identity-anchor ADR and trust-graph doc: named prior art
  (decision 10) that lives outside this repo; this session could not read
  them under its isolation rule. Their claims should be diffed against §1.2
  and §2.2's peer-attestation defenses in a follow-up session permitted to
  read them.
