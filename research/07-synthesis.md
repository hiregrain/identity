# Research Synthesis — Cross-Cutting Conclusions (2026-08-17)

**Evidence tier — binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

Synthesis of `01`–`06`, written for the design session. Two kinds of content:
where the research **converges** on a design constraint, and where it
**collides with a founder decision** recorded in `00-founder-grilling`.
Collisions are surfaced, not resolved — they are the founder's to re-decide.

> **Status update (same day):** the founder ruled on both collisions — see
> "Founder rulings after research review" in `00-founder-grilling`. R1: not a
> CRA; worker-owned-platform model, modeled on known platforms' constraints.
> R2: whole-profile deletion supported at any time; verified records never
> editable. Collision sections 1–2 below remain as the evidence record; R1/R2
> govern design.

## Collisions with settled decisions

### 1. The "global recruiter, not reporting agency" positioning fails (vs. decision 8)

`01` finds the US product is a Consumer Reporting Agency on its facts:
15 U.S.C. §1681a(f) is satisfied element-by-element, and §1681a(h) covers
partner reads about incumbent workers, not just hires. The staffing-agency
exclusion (§1681a(o)) fails three independent ways for this design —
it covers only interview-derived investigative communications (structured
attestations and scores never qualify), it requires the communication not be
reused for any other purpose (foreclosing a durable reusable record outright),
and it requires a prospective employer. The worker-consented, worker-visible,
worker-permissioned design does **not** weaken CRA status — each of those
features maps onto an existing CRA duty, so the architecture reads as
voluntary pre-compliance, which is evidence *for* status.

Consequence: the choice is not "recruiter vs. CRA" but "accidental CRA vs.
deliberate CRA." Deliberate compliance (dispute/reinvestigation engine as a
first-class subsystem, permissible-purpose gating on reads, adverse-action
support for consumers) is the defensible path. Needs counsel, not more
research. California ICRAA is stricter still ($10k/violation, "any means").

### 2. "Never deletion" and "freeze on verification" are unlawful as stated (vs. decision 6)

Three regimes independently break the pure append-only commitment:

- FCRA §1681i(a)(5)(A): after reinvestigation, inaccurate/unverifiable
  information **must be deleted or modified** — a superseding annotation is
  not enough.
- FCRA §1681c(a)(5): adverse items generally cannot be reported after seven
  years — a permanent, fully readable record violates this on its face.
- PH DPA IRR Sec. 34(e): erasure trigger for "private information prejudicial
  to the data subject" — describes an adverse attestation almost exactly,
  with criminal penalties reaching responsible officers personally. GDPR
  Art. 17 adds the EU version; EDPB Guidelines 02/2025 treat encrypted and
  hashed data as still personal, so crypto-shredding is mitigation, not a
  blessed substitute.

The survivable architecture (the EDPB's own pattern): **separate the
immutable evidence of an event from its reportable personal-data payload.**
Append-only commitments/references on the ledger; erasable, modifiable
payloads off it. Append-only survives as an integrity property, not a
retention policy. Retention windows (7-year adverse-item bar) become
first-class schema, not policy bolted on.

One finding cuts the other way and *supports* the supersession model:
PH DPA Sec. 16(d) statutorily requires that corrected and retracted versions
both stay accessible and be delivered together to recipients — versioned
correction is not just permitted but mandated there.

### 3. Scoring may itself be the regulated automated decision

Under *SCHUFA* (CJEU C-634/21), if consumers "draw strongly" on
ledger-computed grades or standings, the **ledger** is performing the
GDPR Art. 22 automated decision, with its obligations — not just the
employer. Interacts with the thesis's dimension-standing field: the coarser
and more evidence-like the ledger's outputs, the safer; the more score-like,
the more exposed. Converges with the Goodhart finding below.

## Convergent design constraints (no collision)

4. **The trust registry is the hard problem; signatures are easy.** `04`:
   plain Ed25519/JWS against a self-hosted party registry; blockchain/DID
   anchoring buys nothing. Key compromise handled transparency-log style
   (signatures bound to party+key+trusted-timestamp; key-state changes in
   their own append-only log; suspension never retroactive). `06` agrees from
   the attack side: **party-attestation fraud** (fake training providers,
   employer collusion/retaliation) is the underweighted top risk — bigger
   than peer-Sybil, which is tractable with known techniques (graph
   detection, reciprocity caps, velocity limits, device/IP clustering).

5. **A reputation network survives only with a compelled consumer.** `02`:
   every dead portable-reputation attempt (Sovrin, uPort, Bloom, Klout,
   LinkedIn Skill Assessments) lacked a downstream party compelled to check
   the record; every survivor (credit bureaus, ATS, licensing boards, CAs)
   has one. Braintrust survives because the marketplace came first and
   reputation lives inside the transaction loop. Validates internal-first
   sequencing: the verticals are the compelled consumers. Standalone-identity
   ambitions should stay downstream of routing volume.

6. **Adopt W3C VC 2.0 as the attestation envelope; differentiate on
   provenance grading and the trust registry.** VC 2.0 ratified May 2025;
   EUDI wallet mandated in the EU by end-2026. The envelope is commodity;
   issuer-trust logic is where even W3C stalled — and where the ledger's
   value is.

7. **Issue an opaque `ledger_person_id` at self-signup; verify progressively;
   never anchor on phone.** `03`: Aadhaar/UNHCR/NIST 800-63-4 all issue at
   enrollment and layer assurance later. Phone-control is too weak as primary
   anchor (45–90-day US number recycling; 80% first-try SIM-swap success in
   the Princeton study) — grain's phone-anchor ADR should not generalize.
   Merge = healthcare-MPI pattern: probabilistic match, human review,
   merge-as-event with alias tables and unmerge support. Fresh-start abuse is
   handled by a separate anti-fraud layer (Aadhaar, Uber pattern), never by
   signup friction — resolving the apparent tension with universal signup.

8. **Author a small proprietary `work_kind` vocabulary; crosswalk out.**
   `05`: nothing adoptable wholesale (O*NET US-only and ~9-year revision
   cycles; ESCO EU-only; ISCO too coarse). Author at O*NET
   "detailed work activity" grain, publish crosswalks to O*NET/ISCO/ESCO,
   adopt BLS crosswalk discipline: immutable historical bindings, versioned
   crosswalk tables, never edit in place. Taxonomy *governance* has no
   transferable prior art — it is a real open design problem.

9. **The responsibility dimensions are a hypothesis, not settled ground.**
   Closest prior art (SFIA autonomy/influence/complexity; Hay; Radford) was
   built for standing-role evaluation, not per-attestation scoring, and none
   covers machine leverage, customer exposure, or team size. Pilot across at
   least two verticals before hardening into the schema.

10. **Keep exposed scores coarse.** Causal evidence (Nature, gig-platform
    study): switching 5-star to thumbs-up/down eliminated a 9% racial
    earnings gap. Score granularity itself drives gaming and bias. Converges
    with constraint 3: coarse, evidence-like outputs are both safer under
    Art. 22 and less Goodhart-able.

11. **Attesting parties need a conditional liability shield or the record
    goes silent.** US reference-checking collapsed into "name, rank, dates
    only" under defamation fear; PH *Globe Mackay* (1989) makes unsolicited
    derogatory references an actionable tort. Without contractual
    qualified-privilege structure in worker and party agreements, honest
    negative attestations won't be written. Legal design, not schema design —
    but it must exist before the first external attesting party.

12. **Keep sensitive personal information out of attestation payloads
    entirely** (education records, government IDs, DOB, criminal
    proceedings). `01`: highest-leverage schema move across all three
    jurisdictions — PH DPA Sec. 13 makes legitimate-interest unavailable for
    sensitive data; FCRA/ICRAA amplify; GDPR Art. 9 parallels.

## Explicitly for counsel, not design

- Whether to register/operate deliberately as a CRA (and in which states).
- Controller-vs-processor characterization per jurisdiction (PH IRR
  Sec. 44(g) gives controllers a delete-all-copies right an immutable ledger
  cannot honor).
- The conditional-liability-shield structure for attesting parties
  (constraint 11).
- Jurisdiction-specific worker-agreement terms before the first worker signs
  (echoes Dispatch position 11's own flag).

## Quality caveats carried up from the files

- `02`: blockchain-era case specifics (Sovrin/uPort/Bloom details) flagged
  moderate-confidence; spot-check before external use.
- `03`: assessed grain's phone-anchor ADR from description, not the document
  (it lives in the grain repo); no rigorous source found for the
  shared-family-phone prevalence claim.
- `06`: party-side fraud and retaliation frequency rest on practitioner/legal
  sources, not empirical measurement (no work-attestation system exists at
  scale to measure).
- `06`: likewise assessed grain's trust-graph doc from description only.
- The design session should read grain's
  `docs/adr/0001-worker-identity-anchor.md` and
  `docs/architecture/trust-graph-adversarial-model.md` directly.
