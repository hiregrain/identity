---
id: party-registry
type: layer
status: draft
milestone: v1
depends_on: [foundation, trust-kernel]
binds:
  - decisions/LOG.md#005
  - decisions/LOG.md#007
  - design/stack-litigation/d4-verdict.md
  - design/ledger-design-0.1.md#3
acceptance: [AC-PR1, AC-PR2, AC-PR3]
evidence: []
verified_by: null
---

# party-registry

The single-root trust registry: who may attest, under what key, in what
state. Internal verticals, external partners, customer organizations
(decision 007), and verification vendors are all schema-identical party
entries; only vetting tier and trust weighting differ, and both live only
here.

Scope: party lifecycle (`pending → active → suspended → revoked`) as
append-only `party_events` with reason codes and public per-party status
history; tiered vetting metadata; key registration for party-held keys
(D4): 30–90-day validity, ACME-style automated rotation, the
bootstrap-then-transfer kit deferred to first external party per decision
005 sub-rulings; suspension flags computed at read, never written into
attestations; ledger invalidation records for proven fraud; the
registry-enforced deadline gate — **no external party can transition to
`active` before the witnessed transparency log exists** (D3); mandatory
quarterly party countersignatures over their own issuance checkpoints,
automated by the integration kit.

Acceptance:
- AC-PR1 (mechanical): registry state transitions are append-only rows;
  attempting to activate an external-tier party without the witnessed-log
  flag fails.
- AC-PR2: a rotated key verifies for its validity window; a
  compromise-reported key invalidates only post-report signatures.
- AC-PR3: a suspended party's prior attestations remain cryptographically
  valid and acquire the derived read-time flag everywhere they render.
