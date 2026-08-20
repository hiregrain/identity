---
id: integration-surface
type: layer
status: draft
milestone: v1
depends_on: [prior-packet, ingestion, party-registry]
binds:
  - decisions/LOG.md#040
  - model/attestation-interface.md
  - model/roster-firewall.md
  - design/stack-litigation/d4-verdict.md
  - decisions/LOG.md#031
  - decisions/LOG.md#033
evidence: []
verified_by: null
---

# integration-surface

The public API and party-onboarding product: any internal vertical or
external partner attaches through this, self-serve. The success measure is
that partner #2 integrates without talking to us.

Scope: the OpenAPI spec + typed SDKs **generated from the language-neutral
contract schema** (the same one the T1 vectors validate: the spec is
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
1. **Dispatch completes the full round trip as the first real party.** Dispatch registers as party #1 and completes the full round trip,
   packet down, attestation up, visible in the worker record, using only
   the public API and published docs.
2. **The code generators are pinned by name and by version.** (mechanical, added by decision 040) the generators are **pinned by
   version and named explicitly**. openapi-generator marks the plain `typescript`
   generator **experimental**; `typescript-fetch` and `typescript-axios` are the
   stable ones, and the plan must not silently take the experimental one. D2's own
   trigger register names **codegen-chain rot**, and that trigger sits closer to
   firing with more client targets, so one toolchain, pinned, with a CI job that
   fails on generator drift.
3. **Regenerating the SDKs produces byte-identical output.** (mechanical) the SDKs and OpenAPI spec regenerate byte-identical
   from the contract schema in CI; drift fails the build.
4. **The sandbox exercises every endpoint before a partner does.** the sandbox's synthetic workers exercise every endpoint
   including disputes and revocation; the conformance suite passes/fails a
   deliberately broken sample integration correctly.
5. **A second consumer proves the interface is not shaped around the first.** (mechanical) a second consumer, grain, or a synthetic second
   vertical, completes the round trip against a ledger build whose diff, from
   the commit where the first consumer's integration was verified, touches no
   file outside `docs/`, the party registry's data rows, and the consumer's own
   SDK package. Any other changed path fails the criterion.
6. **No roster data crosses the boundary.** (mechanical, `roster-firewall.md` RF-5 and interface A-6) no
   endpoint emits a `ledger_person_id`. A partner receives only its own
   pairwise pseudonym, and two partners holding records for the same person
   receive values that do not correlate; the invitation payload accepts
   employer identity and addressing only, and any worker-specific field is
   rejected by schema.
