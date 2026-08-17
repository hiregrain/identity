---
id: verification
type: layer
status: draft
milestone: v1
depends_on: [person-identity, party-registry]
binds:
  - research/09-idv-vendor-landscape.md
  - decisions/LOG.md#010
  - design/ledger-design-0.1.md#1.2
acceptance: [AC-V1, AC-V2, AC-V3, AC-V4]
evidence: []
verified_by: null
---

# verification

Bought verification, stored as attestations. One internal interface:
`verify(person, method) → verification attestation {issuer, method, level,
verified_at, expiry/decay, evidence_commitment}`.

Scope: the adapter layer (thin, internal — no commercial orchestrator per
research/09); Persona integration first (free tier covers pilot;
results-only — **no document image, biometric, or raw PII from the vendor
ever persists in the ledger**; vendor retention/destruction schedules in
the DPA); Sumsub second (PH document coverage, region-pinnable storage);
method extensions on the same interface: PhilSys-QR validation, NBI-QR
check; per-region fallback ladders with pilot-measured pass rates (DHS
finding: vendor claims overstate); vendors registered as attesting parties
(one trust machinery); derived assurance level computed from the
verification set at read (none/channel/document/biometric ladder);
work-authorization verification per decision 008 — jurisdiction-scoped
boolean + basis class + expiry, readable only post-selection (the access
gate itself lands in `prior-packet`).

Acceptance:
- AC-V1 (mechanical): the ledger stores no image/biometric payloads after
  any verification flow — asserted by schema and by an integration test
  inspecting all writes.
- AC-V2: two verifications from different issuers coexist; assurance level
  derives correctly and decays on expiry.
- AC-V3: vendor swap requires only a new adapter + registry entry — no
  schema change (proven by the second provider landing).
- AC-V4: a failed/abandoned verification leaves the account usable at its
  prior assurance level (progressive proofing never gates signup).
