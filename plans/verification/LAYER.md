---
id: verification
type: layer
status: ready
milestone: v1
depends_on: [person-identity, party-registry, ingestion, self-asserted-record]
binds:
  - decisions/LOG.md#010
  - decisions/LOG.md#040
  - decisions/LOG.md#070
  - research/09-idv-vendor-landscape.md
  - design/ledger-design-0.1.md#1.2
gated_criteria: [7]
evidence: []
verified_by: null
---

# verification

Bought verification, stored as attestations, and the worker-initiated
request flows that start every attestation in the system.

Grilled 2026-08-20 (decision 070); tasks authored in the same session;
the engineering review over these criteria and tasks runs before any
task is claimed.

**Work authorization does not exist here or anywhere** (decision 070,
superseding 008's shape): not stored, not requested, not shown. An
employer cannot outsource its own verification duty, so the field was a
prior signal with no compliance value carrying sensitive status.

One internal interface: `verify(person, method)` returning a
verification attestation in the ratified A-2 shape `{issuer, method,
level, verified_at, freshness/expiry}`; the vendor's transaction
reference is held payload-side internally and is not an interface
field (decision 071). **Results enter the record through ingestion and
only through ingestion** (decision 070): vendors are registered
attesting parties, a result is a signed attestation submitted through
the same admission pipeline as any employer's, under the request that
started the flow. For identity verification that request is the
implicit `identity_verification` kind of schema §10 (decision 071):
no claim ref, no freeze, the vendor as party, so the single door
stands without freezing a claim the flow was never about.

**Vendor order per decision 040 §C: Persona primary, Sumsub secondary.**
Neither vendor permits the capture step inside the host app's own
chrome; Grain's screen hands off with the vendor named on it (036's F3
relaxed). Both ship legacy-bridge React Native SDKs with no
`codegenConfig` and no Expo config plugin, and both force a location
prompt; those facts live in the adapter task. **Sandbox-first**
(decision 070): every task builds and verifies against vendor sandboxes
and the synthetic adapter; production contracting is gated on the
founder reading the vendor terms and ruling go, informed by an internal
research memo. No counsel is engaged or planned; the gate names its
real owner.

Scope: worker-initiated verification request flows (issuance, delivery
to the party carrying the pairwise pseudonym per decision 069, party
notification, the expiry copy the worker sees; self-asserted-record
owns the table, this layer owns the flows); the thin internal adapter
layer, no commercial orchestrator (research/09); Persona sandbox
integration, results-only, **no document image, biometric, or raw PII
from the vendor ever persists in the ledger** (decision 010); method
extensions on the same interface: PhilSys-QR validation, NBI-QR check;
per-region fallback ladders with pilot-measured pass rates (the DHS
finding: vendor claims overstate); vendors registered as attesting
parties, one trust machinery; the derived assurance level
(none/channel/document/biometric) computed at read from the
verification set under published one-sentence-per-level rules
(decision 070).

Out of scope: work authorization in any form; the live vendor contract
(gated criterion 7); packet rendering of verification state
(prior-packet, which carries the per-attestation list and never the
derived level, decision 071); request-creation UX surfaces
(worker-surface renders, this layer exposes the flows); sanctions
screening, deferred with its owner: it is bought like verification and
stores signed pass/fail only (decision 010), and it arrives with the
party-vetting work that consumes it, not here.

Acceptance:

1. **No document image or biometric ever persists in the ledger.**
   (mechanical) the ledger stores no image or biometric payloads after
   any verification flow, asserted by schema and by an integration test
   inspecting all writes during each fixture flow.
2. **The assurance ladder is published, deterministic, and honest about
   expiry.** (mechanical) two verifications from different issuers
   coexist on one person; a fixture table of (issuer, method, level,
   verified_at, expiry) rows maps to the expected assurance level for
   every row; identical verification sets always derive identical
   levels; an expired verification contributes nothing; the published
   one-sentence rule per level renders from the live derivation
   configuration, so published and enforced cannot drift.
3. **A second method drops in behind the same interface.** (mechanical)
   a new provider or method lands as an adapter module and a registry
   entry only, and `git diff` over `db/migrations/` for that change is
   empty, proven by the PhilSys adapter and by a synthetic adapter.
4. **A failed verification leaves the account working at the level it
   already had.** (mechanical) a failed or abandoned verification flow
   leaves the account's derived assurance level byte-identical to its
   pre-flow value; the signup path contains no call into the
   verification package, asserted by a grep-class check, which is what
   progressive-proofing-never-gates-signup means mechanically.
5. **Results enter only through ingestion.** (mechanical) no adapter or
   verification code path writes to any fact table; the only egress is
   a signed attestation submitted to the ingestion pipeline, asserted
   by the foundation/06 schema-grep check and privilege inspection.
6. **A request reaches the party carrying what the party needs and
   nothing more.** (mechanical) a delivered request carries the
   pairwise pseudonym and never a ledger id, the RF-1 serializer
   pattern; the worker sees the request's state and its expiry copy at
   the moment of asking; the party is notified on issuance.
7. **The live vendor flip is a ruling, not a drift.** (mechanical,
   gated) production vendor credentials configure only alongside a
   recorded founder ruling entry; the satisfying task is draft until
   that ruling exists.
8. **The derived level never crosses to a party.** (mechanical) no
   packet or party-facing response schema carries the derived
   assurance level, and the serializer check rejects a planted one,
   the RF-1 pattern; what crosses is the per-attestation verification
   list the ratified interface defines (decision 071); no person-level
   assurance column exists in any plane, asserted by schema
   inspection, the interface's per-attestation-never-per-person rule
   made mechanical.
9. **Every region resolves an explicit method ladder.** (mechanical)
   the region fallback configuration resolves an ordered method list
   per configured region and rejects an unconfigured region with a
   structured error, never a silent default; pass rates in the
   configuration are pilot-measured fields, not authored constants,
   enforced by the configuration schema marking them measured.
