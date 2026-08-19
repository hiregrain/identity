---
id: party-registry/01
type: task
layer: party-registry
satisfies: [1, 4, 5]
status: ready
depends_on: [foundation/03, foundation/04]
migrations: [0009-party-core]
binds: [decisions/LOG.md#007, decisions/LOG.md#015, design/ledger-design-0.1.md#3.1]
evidence: []
verified_by: null
---

# Party entries, lifecycle, and capability grants

## Objective

One table answers "who is allowed to write into a worker's record, and
what exactly are they allowed to write" — with the answer reconstructible
for any past date from events alone, and cheap enough to ask on every
write.

## Scope

- `0009-party-core` (spine). Numbered below `0014-safety-markers`
  deliberately: that migration carries `filing_party_id` and cannot
  precede the table it references. **A check asserts this ordering
  constraint** — foundation/06's migration check covers collisions and
  gaps, not cross-layer reference ordering.
- `party`: opaque id, `custody_model`
  (`party_kms | party_kms_provisioned | party_hsm | ledger_kms | none`),
  `is_operator`. Lifecycle state is **write-once + transition rows**, never
  an editable column (the foundation/03 pattern).
- **Legal name is an append-only event, not a column.** `party_name_events`
  records each name with its effective instant; the current name is a
  projection. Renames are ordinary events, so "what was this party called
  when it signed that record" is answerable for any instant — the question
  a dispute actually asks. No UPDATE path on a name exists, which keeps the
  foundation/03 posture intact.
- **Spine readable-column exemption, narrow and documented.** A party's
  legal name is a text column on the spine, which foundation/04's lint
  otherwise forbids. The exemption is granted in this migration, by
  column, with a comment stating its reason: the ban exists to keep
  *person* data off the global plane across residency boundaries, and a
  party's legal name is public by construction — it renders on the public
  status page (task 07). **The exemption names its columns explicitly and
  licenses nothing else**; the lint's allow-list entry cites this task.
- **Operator self-entry**, enforced by three constraints together, not by
  application code — a partial unique index alone proves only "at most one
  operator flag", which is weaker than the invariant claims:
  (1) partial unique index on `is_operator` — at most one operator;
  (2) a check constraint binding the two directions:
  `is_operator ⇔ custody_model = 'ledger_kms'`, so neither can be set
  without the other; (3) a seeded existence invariant — the operator row
  exists from this migration onward and a check asserts it is present.
  This is the amended D4 invariant (decision 015) made structural.
- `party_events`: append-only transitions across
  `pending → active → suspended | revoked | withdrawn`, each with a
  closed-enum reason code. **`withdrawn` is not `revoked`** — an ended
  relationship carries no finding. **No free-text reason, detail, or
  narrative column exists on or adjacent to an adverse lifecycle event**;
  the enum is the whole vocabulary. (The invariant is scoped to
  reason/detail fields, not to text being reachable at all — the party's
  name is text and is reachable by design.)
- **Freeze is a separate condition, not a lifecycle state.**
  `party_freezes` is append-only and composes with any lifecycle state: a
  frozen party is still `active`, still carries valid history, and is under
  no finding (decision 015 — freeze never auto-suspends). It blocks new
  writes only, lifts when its cause clears, and renders publicly as a
  pending review rather than an adverse mark. Folding it into the lifecycle
  enum would make it read as a mild suspension, which is what the ruling
  forbids.
- `party_capabilities`: append-only grant/revoke events for
  `may_attest(scope)`, `may_request_packet`, `may_file_safety_marker`.
  Capability is **never derived from vetting tier** — the tier column
  does not appear in any capability check.
- **No party may grant itself a capability.** Grants are operator acts;
  the grant path rejects a self-referential actor regardless of role.
- `may_file_safety_marker` grants require a **valid** addendum, not merely
  a reference: signed, executed by *this* party, effective at the grant
  instant, not revoked, and carrying the challenge-routing and joint-
  controller terms. A non-null pointer to an unvalidated row is satisfiable
  by garbage; the grant path checks every condition and rejects otherwise
  (decision 015 — joint controllership cannot be imposed on a party that
  never accepted it).
- Capability resolution is a function of (party, capability, instant), so
  "who could file on 2027-03-01" is answerable without replaying prose.
- **Transactional current-state projection** for party status, current
  name, freeze condition, and capabilities, written in the same transaction
  as the event that changes it. Not a cache: no staleness window, nothing to invalidate. Ingestion
  reads the projection on the write path; a standing check replays the
  event log and diffs against the projection.

## Acceptance

- AC (mechanical): inserting a second `ledger_kms` row fails at the
  database; so does setting `is_operator` without `ledger_kms`, setting
  `ledger_kms` without `is_operator`, and deleting the operator row.
- AC (mechanical): a party's name at any past instant is reconstructible
  from events; no UPDATE path on a name exists.
- AC (mechanical): a frozen party is still `active`, blocked from new
  writes, and renders with no adverse mark; freeze composes with every
  lifecycle state without a transition.
- AC (mechanical): a capability check consults only grant events —
  proven by granting a tier that would plausibly imply a capability and
  confirming the check still denies.
- AC (mechanical): a party cannot grant itself any capability, through
  any path including direct API and console.
- AC (mechanical): `may_file_safety_marker` is refused for each addendum
  defect independently — unsigned, wrong party, not yet effective, revoked,
  missing terms — one case per condition.
- AC (mechanical): no reason, detail, or narrative column adjacent to an
  adverse lifecycle event accepts free text; a schema assertion enumerates
  the reason and capability enums.
- AC (mechanical): the projection rebuilds byte-identically from the
  event log; a planted projection divergence is caught by the check.
- AC (mechanical): the spine lint passes with the named exemption and
  still fails on any *other* readable spine column.
- AC: `withdrawn` and `revoked` are distinguishable in every read that
  surfaces party status.

## Outside check

Verifier attempts a second operator row, grants every tier and confirms
no capability follows, attempts a self-grant as a party admin, attempts a
safety-marker grant with a null addendum, plants a projection divergence,
renames a party twice and reconstructs its name at an instant between the
renames, freezes an active party and confirms writes stop with no adverse
mark, adds an unrelated readable spine column to confirm the exemption did
not widen, and greps the migration for `text`/`varchar` columns adjacent to
suspension.
