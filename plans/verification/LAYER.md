---
id: verification
type: layer
status: draft
milestone: v1
depends_on: [person-identity, party-registry]
binds:
  - decisions/LOG.md#040
  - research/09-idv-vendor-landscape.md
  - decisions/LOG.md#010
  - design/ledger-design-0.1.md#1.2
evidence: []
verified_by: null
---

# verification

Bought verification, stored as attestations. One internal interface:
`verify(person, method) → verification attestation {issuer, method, level,
verified_at, expiry/decay, evidence_commitment}`.

**Vendor order inverted 2026-08-19 (decision 040 §C): Persona is primary,
Sumsub secondary.** Both advocacy briefs and two verification agents independently
established that **neither vendor permits the capture step to be hosted inside the
host app's own chrome**. Persona's docs direct you to a "Transactions-based"
integration if you want your own UI; Sumsub offers four buckets of theming and
requires modal presentation because its SDK "contains its own navigation stack."
**Decision 036's F3 is relaxed accordingly**: Grain's screen hands off with the
vendor named on it, not Grain's viewfinder around the vendor's camera. This is
framework-independent.

**`research/09`, the document decision 010 rests on, contains no mobile-SDK
analysis at all.** The vendor choice was ratified without examining client
integration. That gap is closed by decision 040 and by the evaluation record, and
the SDK facts belong in this layer's task files: both vendors ship maintained
first-party React Native SDKs, **neither declares `codegenConfig`** (both are
legacy-bridge modules against an RN line that has begun deleting legacy classes),
neither ships an Expo config plugin, and both force a location permission prompt.

**Counsel gate before contracting**: Persona lists 16 US subprocessors including
Anthropic, OpenAI and Groq for "data extraction and analysis": identity documents
and selfies reaching three model providers. Decision 010 forbids document images
in the *ledger* and says nothing about the vendor's onward processing. India DPDP
residency is unproven for both vendors and must be answered in writing.

Scope: the adapter layer (thin, internal, no commercial orchestrator per
research/09); Persona integration first (free tier covers pilot;
results-only, **no document image, biometric, or raw PII from the vendor
ever persists in the ledger**; vendor retention/destruction schedules in
the DPA); Sumsub second (PH document coverage, region-pinnable storage);
method extensions on the same interface: PhilSys-QR validation, NBI-QR
check; per-region fallback ladders with pilot-measured pass rates (DHS
finding: vendor claims overstate); vendors registered as attesting parties
(one trust machinery); derived assurance level computed from the
verification set at read (none/channel/document/biometric ladder);
work-authorization verification per decision 008: jurisdiction-scoped
boolean + basis class + expiry, readable only post-selection (the access
gate itself lands in `prior-packet`).

Acceptance:
1. **No document image or biometric ever persists in the ledger.** (mechanical) the ledger stores no image/biometric payloads after
   any verification flow, asserted by schema and by an integration test
   inspecting all writes.
2. **Two issuers can both verify the same person without collision.** (mechanical) two verifications from different issuers coexist on one
   person; a fixture table of (issuer, method, level, verified_at, expiry) pairs
   maps to the expected assurance level for every row, and a verification whose
   expiry has passed contributes nothing to the level.
3. **A second vendor drops in behind the same internal interface.** (mechanical) a second provider adapter is added behind the internal
   `verify(person, method)` interface using only a new adapter module and a
   registry entry, and `git diff` over `db/migrations/` for that change is
   empty. A synthetic second adapter satisfies this; it does not wait on a
   commercial provider landing.
4. **A failed verification leaves the account working at the level it already had.** a failed/abandoned verification leaves the account usable at its
   prior assurance level (progressive proofing never gates signup).
