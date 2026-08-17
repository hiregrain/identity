---
id: peer-references
type: layer
status: draft
milestone: v1
depends_on: [person-identity, ingestion, verification]
binds:
  - design/ledger-design-0.1.md#2.2
  - research/06-adversarial-threat-model.md
  - research/10-infra-comparison-grain-dispatch.md
acceptance: [AC-PF1, AC-PF2, AC-PF3, AC-PF4]
evidence: []
verified_by: null
---

# peer-references

The `peer_attested` class made operational: references, confirmations,
coworker/manager vouching — with Sybil resistance from day one, not
retrofitted.

Scope: request/confirm flows (a worker requests a reference; the referrer
— themselves a ledger person — confirms under their account-bound key,
same envelope as party signatures, registry entry type distinguishes
grade); manager confirmations where the manager's org is a registered
party render as peer-attested with party-adjacent anchoring;
transaction-anchored weighting (both parties attested into the same
engagement weighs categorically more); ingestion-time signals recorded on
the spine: reciprocity caps, velocity limits, device/IP clustering,
verified-anchor weighting; grain's `excluded`-grade semantics — farmed or
suspect evidence is retained and rendered as what it is, excluded from
downstream weighting, never deleted; the shadow/promotion-gate pattern
(grain prior art) before any peer signal feeds anything consumed
downstream; referrer assurance level shown with the reference.

Acceptance:
- AC-PF1: an unanchored reciprocal pair contributes at most one weighted
  edge until anchored evidence corroborates (grain's cap, generalized).
- AC-PF2 (mechanical): every peer attestation carries its anchor status
  and referrer assurance level into any packet that includes it.
- AC-PF3: a simulated farming ring (shared device/IP, rapid reciprocal
  confirmations) lands with `excluded` weighting and appears in the
  operator review queue — and nothing is deleted.
- AC-PF4: no peer-derived signal reaches prior packets until the promotion
  gate's conditions are met and recorded.
