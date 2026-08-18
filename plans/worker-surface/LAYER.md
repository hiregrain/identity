---
id: worker-surface
type: layer
status: draft
milestone: v1
depends_on: [person-identity, consent-and-deletion]
binds:
  - decisions/LOG.md#022
  - design/ledger-design-0.1.md#7.1
  - design/ledger-design-0.1.md#8.1
acceptance: [AC-WS1, AC-WS2, AC-WS3, AC-WS4]
evidence: []
verified_by: null
---

# worker-surface

The worker's own application — the one surface the ledger owns end to end,
rendered in invariant ledger chrome on the ledger's origin.

Scope: the record view — every raw fact including superseded versions,
disputed/invalidated attestations with counter-statements, verification
history, all in provenance-graded rendering; grant management (who reads,
grant/revoke, full read log); dispute filing and tracking (the FCRA-shaped
flow from design 0.1 §4); deletion request flow; profile and self-asserted
claim editing (freeze states visible); notification of reads, new
attestations, dispute deadlines; responsive web first (global worker
population; low-end Android reality), installable PWA before native;
localization scaffolding from day one (EN, then TL/HI with the first
regional cohort). Operator-side analytics are not shown (decision 002 §4,
decision 022); the raw record always is.

**The boundary of "the record", for AC-WS1.** Analytics run records are
compliance artifacts about Grain's own processing, not entries in the
person's record, and are not shown here (decisions 022, 026). Attester
veracity events no longer exist (decision 025). AC-WS1's "nothing hidden"
therefore means every fact *about the person* — which is the whole record
and always was.

Acceptance:
- AC-WS1: every fact in the person's record is reachable in the UI; a
  side-by-side against a raw API dump shows nothing hidden.
- AC-WS2: provenance classes are visually distinct at every rendering
  site, at WCAG-AA contrast, without color-only encoding.
- AC-WS3: grant, revoke, dispute, and delete are each completable start to
  finish on a 360px viewport over a slow connection.
- AC-WS4: all trust-bearing flows serve from the ledger origin — no
  vertical chrome, no theming beyond light/dark (per the invariant-chrome
  ruling pending in the decisions log).
