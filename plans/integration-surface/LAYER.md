---
id: integration-surface
type: layer
status: draft
milestone: v1
depends_on: [prior-packet, ingestion, party-registry]
binds:
  - model/attestation-interface.md
  - model/roster-firewall.md
  - design/stack-litigation/d4-verdict.md
  - decisions/LOG.md#031
  - decisions/LOG.md#033
acceptance: [AC-IS1, AC-IS2, AC-IS3, AC-IS4, AC-IS5]
evidence: []
verified_by: null
---

# integration-surface

The public API and party-onboarding product: any internal vertical or
external partner attaches through this, self-serve. The success measure is
that partner #2 integrates without talking to us.

Scope: the OpenAPI spec + typed SDKs **generated from the language-neutral
contract schema** (the same one the T1 vectors validate — the spec is
derived from the tested schema, never written beside it); endpoints:
prior-packet read (grant-gated), attestation write, verification-status
read, work-history/credentials/skills reads (all provenance-graded),
reference request/confirm, grant management, dispute filing,
record-change webhooks scoped to what a grantee may see; party onboarding
flow: registration → vetting tier → key setup (party-held per D4, with kit)
→ sandbox with synthetic workers → automated conformance suite (schema +
surface-conformance/marks annex) → `active` (registry gates apply);
canonicalization test vectors published as part of the developer kit;
rate limits and probation caps enforced at the API edge; versioning:
endpoints carry the interface `schema_version`, migrations by crosswalk.

Acceptance:
- AC-IS1: Dispatch registers as party #1 and completes the full round trip
  — packet down, attestation up, visible in the worker record — using only
  the public API and published docs.
- AC-IS2 (mechanical): the SDKs and OpenAPI spec regenerate byte-identical
  from the contract schema in CI; drift fails the build.
- AC-IS3: the sandbox's synthetic workers exercise every endpoint
  including disputes and revocation; the conformance suite passes/fails a
  deliberately broken sample integration correctly.
- AC-IS4: a second consumer (grain, or a synthetic second vertical)
  attaches with zero ledger-side custom code.
- AC-IS5 (mechanical, `roster-firewall.md` RF-5 and interface A-6): no
  endpoint emits a `ledger_person_id` — a partner receives only its own
  pairwise pseudonym, and two partners holding records for the same person
  receive values that do not correlate; the invitation payload accepts
  employer identity and addressing only, and any worker-specific field is
  rejected by schema.
