---
id: operator-console
type: layer
status: draft
milestone: first-product
depends_on: [person-identity]
soft_depends_on: [party-registry, ingestion, consent-and-deletion]
gated_criteria: [3, 6]
binds:
  - decisions/LOG.md#077
  - decisions/LOG.md#013
  - decisions/LOG.md#014
  - decisions/LOG.md#015
  - design/15-operator-console-brief.md
  - design/ledger-design-0.1.md#1.3
  - research/10-infra-comparison-grain-dispatch.md
evidence: []
verified_by: null
---

# operator-console

The surface every steward action happens on, and the first slice of the
human-queues product line every school agreed is the real scaling wall. It is
in `first-product` because a product that can be sold cannot ship a steward
queue with no steward (decision 077): `person-identity/05` writes candidate
pairs and `person-identity/06` requires approval, both in the same milestone,
while the surface a steward acts on sat in `v1`.

**The hard dependency is `person-identity` alone**, so merge review starts when
person identity lands. Everything needing the attestation path, the party
registry or the deletion saga is declared in `gated_criteria` and discharges when
those layers arrive (decision 073: a layer is `done` when every non-gated
criterion is met).

**Two roles, admin and operator** (decision 077). Admin administers the console:
access, configuration, role grants. Operator works the queues. `steward` is the
name of the act rather than a role, so decision 013's two-steward rule reads as
two operators. No employer or customer role exists on ledger surfaces; that is
vertical territory. Operators are Grain employees.

Scope: **merge review**: candidate duplicate pairs with match evidence, an
evidence extract by default rather than two full records, approve, reject or
cannot-determine, the two-operator gradient rendered as a state (two approvals
where both records carry verified attestations, one otherwise), every action an
append-only event; operator decisions feed the matcher as labels, which is why
no per-operator statistic exists anywhere; **unmerge re-assignment review**: the
attestations `person-identity/06` flags on unmerge, which had no owning layer;
**dispute administration**: dispute state, deadline timers, unresponsive-issuer
flagging, drawn as a state view rather than a work queue because deadlines fire
without polling; **party-vetting queue**: registration review, tier assignment,
probation monitoring, the freeze that decision 015 refuses to let become a
suspension, the anomaly and reliability signals rendered internal-only and never
exported; **safety-marker match review**: separately tiered, deciding identity
and never the finding, because `person-identity/07` schema-forbids any column a
finding's details could occupy; **deletion oversight**: saga progress, copy-map
acknowledgment status, stuck-deletion alerts; audit: every operator action logged
and attributable, operator escalations to a full record logged as record reads
and disclosable on an Article 15(1)(c) request, never as a feed (decision 077).

Acceptance:
1. **A merge over attested history happens only through the ceremony.** a merge
   cannot execute over attested history except through the console; the queue
   shows the evidence that justified the candidate, and the case screen shows the
   per-signal contributions rather than a bare total.
2. **Every operator action lands as an appended event.** (mechanical) every
   console action lands as an append-only event with actor attribution; a console
   session leaves a complete audit trail.
3. **Dispute deadlines fire on their own, without a human remembering.** dispute
   deadlines fire notifications and state transitions without operator polling.
4. **Reliability signals never leave the console.** reliability signals render
   only inside the console, asserted by a check that no API or packet field
   carries them.
5. **An unmerge puts its residue in front of a human.** merge-window attestations
   surface as a re-assignment queue rather than a notification, satisfying
   `person-identity/06`'s final criterion on a surface that owns it.
6. **A marker match decides identity and never the finding.** (mechanical) the
   safety-marker surface exposes no control phrased as a judgment about the
   person, and no code path on it converts a match into a denial.

**Why 3 and 6 are gated, and why 3 is the worse of the two.** Criterion 6 needs
`consent-and-deletion/01`, whose layer is still `draft` with no authored tasks,
which is an ordinary wait. Criterion 3 is different: it asserts that dispute
deadlines fire without operator polling, and **no layer owns the dispute
lifecycle**. `design/ledger-design-0.1.md` §4 specifies it, layers across the
plan reference it, and none scopes it. Until one does, this criterion is a
promise about a subsystem nobody is building, which is why it is recorded as a
gate in `plans/ORDER.md` rather than treated as a wait.

Criteria 4 and 5 were gated when this file was written and are not any more:
decision 078 moved `party-registry` and `ingestion` into the same milestone, so
the party registry and the attestation path land alongside this layer rather
than after it.

Outside check: the verifier attempts a merge over attested history outside the
console and through the single-approval path, greps every response fixture for
tier, cap and reliability fields, and confirms the safety-marker surface offers no
outcome that reads as an adjudication of the finding.
