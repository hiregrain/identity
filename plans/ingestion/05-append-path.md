---
id: ingestion/05
type: task
layer: ingestion
satisfies: [4]
status: ready
depends_on: [ingestion/02, ingestion/03, ingestion/04, ingestion/07, trust-kernel/03]
migrations: [0032-attestations]
binds: [model/attestation-interface.md, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# The append path: attestations land in both planes, chained

## Objective

A validated, verified, resolved attestation becomes rows in both planes
with a hash-chain timestamp, through functions and nothing else.

## Scope

- `0032-attestations`: attestation storage per the ratified interface,
  spine reference and payload content under the subject's DEK,
  through the foundation/07 cross-plane pattern.
- Recording functions only, the foundation/03 pattern; the application
  role holds no direct INSERT on any fact table.
- The chain timestamp was issued at confirmation (decision 069); the
  drain materializes the already-admitted entry into both planes with
  no re-check and no re-rejection. If the subject deleted after
  confirmation, the deletion process has already discarded the entry
  and the drain never sees it.
- The landing append transitions the entry's verification request to
  `attested` through the licensed recording function schema §10 names
  (decision 069), which is what makes the subject's claim freeze
  permanent.
- Drain from the queue: recorded state written only after both planes
  commit per the cross-plane consistency rules.

## Acceptance

1. AC (mechanical): a drained attestation exists in both planes,
   carries its confirmation-time chain timestamp, and its streams pass
   kernel chain verification; its verification request is `attested`
   afterward and the subject's claim freeze is permanent, riding the
   self-asserted-record freeze fixtures.
2. AC (mechanical): the application role cannot INSERT or UPDATE any
   attestation table directly, proven by privilege inspection and
   bypass attempt.
3. AC (mechanical): a crash between the plane writes leaves the entry
   un-recorded and the drain retries it to completion, riding the
   foundation/07 outbox fixtures; no partial append is readable.

## Outside check

Verifier drains fixtures on a fresh clone, runs chain verification,
attempts the direct-write bypass, and replays the crash fixture.
