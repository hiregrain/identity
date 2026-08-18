---
id: peer-references
type: layer
status: draft
milestone: v1
depends_on: [person-identity, ingestion, verification]
binds:
  - design/ledger-design-0.1.md#2.2
  - decisions/LOG.md#025
  - research/06-adversarial-threat-model.md
  - research/10-infra-comparison-grain-dispatch.md
acceptance: [AC-PF1, AC-PF2, AC-PF3, AC-PF4, AC-PF5]
evidence: []
verified_by: null
---

# peer-references

The `peer_attested` class made operational: references, confirmations,
coworker/manager vouching — with Sybil resistance from day one, not
retrofitted.

Scope: **the reference form itself is ledger-authored** — Grain designs the
fields, and responses are structured throughout with **no free-response
field**, because free text adds noise to every downstream use and is
unusable as an analytics input (decision 025); request/confirm flows (a
worker requests a reference; the referrer
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

**Attester trust is withdrawn** (decision 025, superseding 023). No veracity
record about a referrer survives their deletion and no derived trust weight
exists; serious falsification routes to decision 014's severity-gated safety
marker, and below that bar the evidence is deletable by either party. The
Sybil apparatus above is what addresses farming, and it always was.

This layer is a day-one input to `analytics`; per-task dependencies should
land the reference request/confirm path before the Sybil-resistance
apparatus is complete, rather than blocking the whole layer on it.

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
- AC-PF5 (mechanical): the reference schema admits no free-text field; a
  submission carrying one is rejected with a structured error.
