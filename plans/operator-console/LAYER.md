---
id: operator-console
type: layer
status: draft
milestone: v1
depends_on: [person-identity, ingestion]
binds:
  - design/ledger-design-0.1.md#1.3
  - research/10-infra-comparison-grain-dispatch.md
acceptance: [AC-OC1, AC-OC2, AC-OC3, AC-OC4]
evidence: []
verified_by: null
---

# operator-console

The ledger operator's surface — the first slice of the human-queues
product line every school agreed is the real scaling wall. v1 is queues
and review screens, not the product line.

Scope: **merge steward queue** — candidate duplicate pairs with match
evidence, side-by-side records, approve/reject/defer, every action an
append-only event; steward decisions feed the matcher as labels (the
labeling flywheel, grain pattern); **dispute administration** — dispute
state tracking, deadline timers, unresponsive-issuer flagging;
**party-vetting queue** — registration review, tier assignment, probation
monitoring, the anomaly/reliability signals rendered internal-only (never
exported, never a visible score); **deletion oversight** — saga progress,
copy-map acknowledgment status, stuck-deletion alerts; audit: every
operator action logged and attributable; operator access itself under the
read-log discipline (worker-visible reads logged like any other). Role
model: operator and steward roles ledger-side; no employer/customer role
exists on ledger surfaces (that's vertical territory).

Acceptance:
- AC-OC1: a merge cannot execute over attested history except through the
  steward queue; the queue shows the evidence that justified the
  candidate.
- AC-OC2 (mechanical): every console action lands as an append-only event
  with actor attribution; a console session leaves a complete audit trail.
- AC-OC3: dispute deadlines fire notifications and state transitions
  without operator polling.
- AC-OC4: reliability signals render only inside the console — asserted by
  a check that no API or packet field carries them.
