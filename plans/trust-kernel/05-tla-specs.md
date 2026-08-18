---
id: trust-kernel/05
type: task
status: ready
depends_on: [trust-kernel/03, foundation/08, person-identity/06, consent-and-deletion/01]
binds: [decisions/LOG.md#011, decisions/LOG.md#017, decisions/LOG.md#019, design/stack-litigation/d2-verdict.md]
evidence: []
verified_by: null
---

# The two TLA+ specs

## Objective

Exhaustive model-checking of the two behaviors where silent corruption
would be existential and conventional tests are weakest (decision 011:
specs stand, property-based suites are the recorded fallback).

## Scope

- **Spec A — merge/unmerge under concurrent ingestion**: a merge executes
  while attestations arrive for both the survivor and the absorbed ID.
  Invariants to check: no attestation is lost or duplicated; every
  attestation remains resolvable through the alias closure in both merged
  and unmerged states; unmerge restores exactly the pre-merge resolution
  for records not issued during the merged window; chain integrity holds
  on every stream throughout.
- **Spec B — deletion vs. the read path**, updated for decision 017's
  deletion mechanics, which this spec predates. A profile deletion executes
  while a prior packet is being assembled and while a grant check is in
  flight. Invariants: no packet is ever emitted containing payload for a
  person whose deletion has been acknowledged; a deletion acknowledged at
  T terminates every read initiated after T; no partially-purged state is
  ever externally observable; **a key destruction covers every id in the
  alias closure, so no surviving pre-merge key leaves the record
  readable**; **the scheduled physical purge is never observable as a
  partial row**; and **a restore that has not completed the deletion replay
  cannot serve a read**. The last three are new surface from decision 017
  and are exactly where a race would be invisible in testing.
- Conformance tests derived from each spec's traces, wired into CI
  against the real implementation (the specs must bind code, not sit
  beside it).
- Author both against the implemented behavior of trust-kernel/03 and the
  person-identity/consent-and-deletion designs; where the spec forces a
  design correction, that correction is a named judgment call.
- Dependency note: this task's `depends_on` was previously `trust-kernel/03`
  alone, which made it eligible before the surfaces it models existed.
  Spec B models deletion, purge, restore replay, and alias-closure key
  destruction, so it depends on `foundation/08`, `person-identity/06`
  (merge/unmerge), and `consent-and-deletion/01`. Two of those are not yet
  authored — a known dangling reference, discharged when those layers are
  decomposed.

## Acceptance

- AC-TK4 (mechanical): both specs model-check clean; the derived
  conformance tests pass against the implementation.
- AC (mechanical): a deliberately introduced violation (e.g. a read path
  that skips the deletion check) is caught by the conformance suite.

## Outside check

Verifier re-runs both model checks from clean state, then introduces one
violation per spec and confirms detection.
