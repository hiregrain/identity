# Interface Verdict 0.1, on `attestation-interface.md` (0.1-proposed)

Verdict of the ledger's independent design session on Dispatch's proposed
interface contract. Standalone readable; full reasoning in
`design/ledger-design-0.1.md`. Produced without reading
`dispatch-positions-and-open-questions.md`.

## Verdict

**Ratify, with the amendments below.** The two-object boundary (prior
packet down, attestation up), the never-crosses list, and the no-shadow
rules are correct as proposed and are adopted unchanged. The four flagged
open items are resolved (R-1 through R-4). Five amendments (A-1 through
A-5) change or add schema text; three notes (N-1 through N-3) record
interpretations that bind the ledger side without changing the contract's
words. On ratification, ownership transfers to this repo per HANDOFF;
Dispatch's copy becomes conforming.

---

## Item-by-item

### Ratified as-is

- **Two objects, one each direction; nothing else crosses.** Correct and
  load-bearing. No change.
- **Prior packet consumed as cold-start priors, overridden by local
  evidence; ledger claims never treated as locally observed evidence.**
  Correct; the ledger's dimension-standing entries will carry supporting
  attestation references specifically to make this cheap to honor.
- **`ledger_person_id` held by verticals as a reference, never a primary
  key.** Correct. Ledger-side addition (no contract change): the ID is an
  opaque surrogate, never reissued, and resolves through a permanent alias
  table after merges. A vertical holding a since-absorbed ID keeps
  resolving to the right person.
- **Append-only up; correction = superseding attestation via `supersedes`.**
  Correct. Ledger-side rule (N-1 below) constrains who may supersede.
- **`subject_id` must exist before attestation; attestation waits.**
  Correct.
- **`scope`, `volume`, `dimensions_exercised[]`, `stretch_selections[]`
  (including the development-context protection on below-bar stretch
  outcomes), `issued_at`.** Correct as specified. The stretch protection is
  additionally enforced ledger-side: below-bar stretch outcomes are
  excluded from downward dimension-standing derivation.
- **The responsibility dimensions as the cross-vertical capability grain.**
  Ratified as the contract's grain, with the recorded caveat that the
  seven-axis set is a founder hypothesis without validated prior art
  (research `05`); level definitions will be versioned and recalibrated
  after two verticals of real attestations. This is a versioning note, not
  an amendment. The contract already carries `schema_version`.
- **What never crosses** (routing internals, behavioral traces, per-unit
  rows, derived estimates, AI executors). Correct, all five. "Derived
  estimates never sync up as fact" also shapes the ledger's own outputs:
  dimension standing is a deterministic, citation-backed summary, not a
  model estimate.
- **Both no-shadow rules.** Correct. The no-shadow-work-record rule is what
  makes worker profile deletion (founder ruling R2) honest: the ledger can
  truly erase because it never held the work.

### R-1. `work_kind` taxonomy, who authors, at what grain (open item 1)

**Resolved: the ledger authors it.** A small proprietary vocabulary (order
30–150 terms) at detailed-work-activity grain, not occupations, not
mega-buckets, governed by a taxonomy council (ledger editor with final
authority; one delegate per attached attesting party of vertical scale,
internal and external seated identically). Versioned with a public
changelog; historical bindings immutable; reclassification only via
versioned crosswalk tables; published crosswalks to O*NET-SOC and
ISCO-08/ESCO. Nothing existing was adoptable (O*NET US-only/stale, ESCO
EU-only, ISCO too coarse, research `05`).

### R-2. `score_summary` anchoring (open item 2)

**Resolved: per-basis breakout suffices at ledger grain, amended with a
lightweight anchor.** Each per-basis entry must carry the vertical-local
identifier of the quality bar it was scored against (`bar_ref`, e.g. a
rubric version ID). This makes cross-period comparison *possible* without
the ledger normalizing scores onto a shared scale. A ledger-normalized
scale is explicitly rejected: it would be the composite score that the
Goodhart and bias evidence (research `06`/`07`: the Nature RCT on score
granularity) and the Art. 22 exposure analysis both warn against.
Recommended, not required: verticals report coarse ordinal tiers rather
than continuous scores.

### R-3. Signature mechanism (open item 3)

**Resolved.** Ed25519 signatures in a JWS envelope, `kid` header, verified
against the ledger's party/key registry; key lifecycle events in their own
append-only log; every attestation receives a ledger hash-chain timestamp
at write; verification = key valid at signing time AND timestamp predates
any compromise report. No blockchain, no DID resolution, no JSON-LD Data
Integrity at this stage; the envelope stays W3C VC 2.0-compatible in shape
so a future VC-JOSE-COSE projection is mechanical. Suspension of a party is
never retroactive; already-issued attestations acquire a derived read-time
flag, never an edit.

### R-4. Worker consent and portability scope (open item 4)

**Resolved.** Attestations cross verticals only inside a prior packet
issued under an **active worker grant** to the receiving party. Grants are
party-level (founder decision 7), revocable, logged, and worker-visible;
packets are generated at read time so revocation and deletion bind
immediately. Consent is captured at onboarding (attestation writing,
verification-freeze, party-level disclosure, dispute rights, total-deletion
right) and re-affirmed contextually at each verification request. Profile
deletion (R2) terminates all future packet issuance; already-delivered
packets are governed by the receiving party's data-handling terms (A-5).

---

## Amendments

**A-1. Add `work_kind_version` (or bind `work_kind` as `term@version`).**
The attestation must permanently record which taxonomy version its term was
tagged under. Without this, R-1's immutable-binding discipline is
unenforceable at the boundary.

**A-2. Generalize `verification` to `verification[]`.** The prior packet's
single verification field becomes a list of verification attestations, each
`{issuer, level, method, verified_at, freshness/expiry}`. Progressive
verification means a person accumulates verification events of different
levels and ages; a single latest-value field loses exactly the provenance
the consumer needs. Assurance is per-attestation, never per-person.

**A-3. Carry explicit provenance grade on packet contents.** Every item in
`credentials[]` and any self-asserted content crossing in the packet must
carry its provenance class (`self_asserted | peer_attested |
party_attested`) as a schema-level field, so nothing self-asserted can be
confused with anything attested on the consumer side either (extends
founder decision 5 across the boundary).

**A-4. Ban sensitive personal data categories from attestation payloads.**
Government ID numbers, DOB, health data, criminal proceedings, and
education records beyond credential name/issuer are schema-invalid in
`score_summary`, `stretch_selections`, and any free-text field. Highest-
leverage compliance move across all three researched jurisdictions
(research `01`/`07` constraint 12), and costless to the thesis.

**A-5. Add a data-handling clause for delivered packets.** The contract
must state what a receiving party may retain and for how long, and that
worker profile deletion terminates future issuance without recalling past
deliveries. Today the contract governs what crosses but is silent on the
lifetime of what crossed; R2 makes that silence untenable.

---

## Binding interpretations (no text change)

**N-1. Supersession authority.** Only the original issuing party, or the
ledger itself via a signed invalidation record upon proven fraud, may
supersede an attestation. Party A cannot correct party B; it can only add
its own attestation.

**N-2. `dimension_standing[]` is ledger-derived.** "As last attested across
all verticals" is interpreted as: derived by the ledger from
`dimensions_exercised` across attestations under a published deterministic
coarse rule, with supporting attestation references included per entry.
Attestations assert what was exercised; only the ledger asserts standing.
[FOUNDER-CALL] Alternative: pure pass-through of last-attested values,
leaving aggregation to each vertical. Maximally conservative, but it leaves
the contract's own phrase undefined when attestations disagree.

**N-3. Internal/external symmetry is schema-invisible.** The attestation
schema and the packet read path are identical for internal verticals and
external partners (founder decision 2); vetting tier, probation, and trust
weighting live exclusively in the ledger's party registry.
