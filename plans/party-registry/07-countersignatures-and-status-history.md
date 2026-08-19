---
id: party-registry/07
type: task
layer: party-registry
satisfies: []
status: ready
depends_on: [party-registry/02, party-registry/06, trust-kernel/04]
migrations: [0019-party-countersignatures]
binds: [design/stack-litigation/d4-verdict.md, decisions/LOG.md#015]
evidence: []
verified_by: null
---

# Monthly countersignatures and public status history

## Objective

Every month, each party signs a statement that our record of what they
issued matches their own — converting "the party never noticed" into a
recurring, attributable claim.

## Scope

- **Per-party issuance root: consumed from `trust-kernel/04`, not defined
  here** (decision 019 relocated it under decision 015's boundary rule —
  signing and tree math belong to the kernel, written once). This task
  requests the root for a period and verifies the party's signature over
  it. The global checkpoint root is not a substitute: a party cannot
  recompute it from its own records, so signing it would attest to our
  arithmetic rather than to their issuance.
- `0019-party-countersignatures` (spine): the party's signature over its
  per-party issuance root for the period, with the covered range and the
  root recorded.
- **Cadence: monthly, or at each registry event** (d4-verdict §5;
  decision 015 corrects the layer file's "quarterly" drift). Required
  from the first external party onward.
- Countersignature is requested and verified registry-side; the
  automation that produces it ships in the partner kit
  (`integration-surface`), per the boundary rule in decision 015. **This
  task's acceptance therefore proves the protocol against a test harness,
  never against the shipped kit** — the "a partner runs one install and it
  works" claim belongs to `integration-surface` `integration-surface` criterion 1, and this layer
  cannot honestly assert it without depending on a layer that depends on it.
- **Missed periods escalate; they never pass silently and never break a
  working integration on the first miss.** D4 left advisory-versus-
  mandatory open and decision 005 called countersignatures contractually
  mandatory, so "queue entry, no consequence" would be choosing one side
  unrecorded. The ladder: first miss notifies and queues; consecutive
  misses raise a registry event and operator review, which may apply the
  orthogonal freeze from task 01. A missed cron job never costs a partner
  their integration; a partner who stops attending cannot stay unnoticed.
- **Public per-party status history** at plain, guessable URLs: current
  state, transition history with reason classes, key validity windows,
  countersignature currency, and **prior legal names** from task 01's name
  events — a party cannot shed a suspension history by rebranding, which is
  what trust-list transparency is for. **The operator's own entry renders
  the same way** — its key rotations appear in public history, which is the stated
  reason decision 015 chose a self-entry over a side table. The transparency claim is void if checking a
  party's standing requires asking us.
- This task owns the **projection and its stable URL contract**;
  rendering belongs to `public-web`. No vetting tier, cap, or reliability
  field appears in the projection.

## Acceptance

- AC (mechanical): the projection contains no internal-only field —
  asserted against the shared fixture defined in `party-registry/05`, not
  a second copy of the list.
- AC (mechanical): a party can recompute its issuance root from its own
  issuance records alone — proven by an independent recomputation in the
  test that never reads the global tree.
- AC (mechanical): the operator's key rotations appear in its public
  status history.
- AC (mechanical): a countersignature verifies against the party's
  registered key for the period, and one covering the wrong range is
  rejected.
- AC (mechanical): one missed period notifies and queues without affecting
  writes; the configured number of consecutive misses raises a registry
  event and makes the freeze available to review.
- AC (mechanical): prior legal names render on the public status page.
- AC: status URLs are stable across a party's rename and derivable from
  the party id alone.

## Outside check

Verifier submits a countersignature over a shifted range, skips one period
and confirms writes continue, skips enough consecutive periods to trigger
escalation, renames a party and re-fetches its status URL to confirm both
the stable address and the prior name, and diffs the projection's fields against the internal-only list.
