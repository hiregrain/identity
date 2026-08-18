---
id: trust-kernel/05
type: task
status: ready
depends_on: [trust-kernel/03]
binds: [decisions/LOG.md#011, design/stack-litigation/d2-verdict.md]
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
- **Spec B — deletion vs. the read path**: a profile deletion executes
  while a prior packet is being assembled and while a grant check is in
  flight. Invariants: no packet is ever emitted containing payload for a
  person whose deletion has been acknowledged; a deletion acknowledged at
  T terminates every read initiated after T; no partially-purged state is
  ever externally observable.
- Conformance tests derived from each spec's traces, wired into CI
  against the real implementation (the specs must bind code, not sit
  beside it).
- Author both against the implemented behavior of trust-kernel/03 and the
  person-identity/consent-and-deletion designs; where the spec forces a
  design correction, that correction is a named judgment call.

## Acceptance

- AC-TK4 (mechanical): both specs model-check clean; the derived
  conformance tests pass against the implementation.
- AC (mechanical): a deliberately introduced violation (e.g. a read path
  that skips the deletion check) is caught by the conformance suite.

## Outside check

Verifier re-runs both model checks from clean state, then introduces one
violation per spec and confirms detection.
