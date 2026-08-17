---
id: marks-and-embeds
type: layer
status: draft
milestone: v1
depends_on: [prior-packet, worker-surface]
binds:
  - design/ledger-design-0.1.md#7
  - model/attestation-interface.md
acceptance: [AC-ME1, AC-ME2, AC-ME3, AC-ME4]
evidence: []
verified_by: null
---

# marks-and-embeds

The mark/glyph system and the embeddable trust-bearing components — one
mark system globally, invariant ledger chrome for trust flows.

Scope: the mark vocabulary as a closed versioned enum mapping only to
epistemic facts (identity-assurance ladder, provenance class,
corroboration, dispute/supersession/issuer-state flags — never quality,
score, tier, or composite); `marks[]` derived server-side on every claim in
packets and record reads (verticals never compute mark state); the three
render tiers — SDK components (web component + React/RN) with fixed
geometry and localized labels, the ledger-served badge endpoint for
non-SDK surfaces, static glyph assets with conformance rules for the long
tail; **every mark resolves** to a grant-scoped verification page on the
ledger origin (QR for print) — an unresolvable mark is counterfeit by
definition; entry-point components ("Continue with [ledger] ID") themable
per published guidelines; trust-bearing flows (verify, consent, dispute,
record) exclusively in invariant ledger chrome on ledger origin, light/dark
only; the surface-conformance annex drafted as the checkable companion to
the party agreement; no mark may encode work-authorization, nationality, or
anything the post-selection gate protects.

Acceptance:
- AC-ME1 (mechanical): mark state in any rendering equals the
  server-derived state for the same claim at the same instant — SDK, badge
  endpoint, and resolution page cannot disagree.
- AC-ME2: every rendered mark carries a working resolution URL; the
  resolution page respects grants and shows citations.
- AC-ME3: glyph geometry is identical across SDK/badge/static tiers;
  state is never encoded in color alone.
- AC-ME4: the conformance annex's rules are each expressed as an automated
  check a party's integration can run.
