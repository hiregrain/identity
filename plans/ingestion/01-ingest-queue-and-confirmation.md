---
id: ingestion/01
type: task
layer: ingestion
satisfies: [1, 6]
status: ready
depends_on: [trust-kernel/08]
migrations: [0030-ingest-queue]
binds: [decisions/LOG.md#068]
evidence: []
verified_by: null
---

# The ingest queue and the single confirmation

## Objective

A party's submission is rejected on the spot or confirmed once, the
confirmation means the attestation cannot be lost, and sending it twice
changes nothing.

## Scope

- `0030-ingest-queue` (payload plane): the queue in foundation's
  outbox pattern, partitioned by subject, idempotency keyed on
  `attestation_id`, internal received/recorded states for monitoring.
- The confirmation: sent only after the queue row is durable on the
  primary and its standby replica (decision 068). Every rejection path
  runs before it; after it, processing failures retry until recorded
  and no party-facing rejection exists.
- Retry and drain in the shape of foundation's outbox reconciler;
  stuck entries surface to monitoring, never to the party.

## Acceptance

1. AC (mechanical): a duplicate submission of a confirmed attestation
   returns the same confirmation and writes nothing new.
2. AC (mechanical): the watermark test kills the primary mid-run;
   every confirmed attestation is present afterward and none is
   double-recorded; an unconfirmed in-flight submission may vanish and
   its party never received a confirmation for it.
3. AC (mechanical): fault injection after confirmation produces
   retries until recorded; no code path after confirmation emits a
   party-facing rejection, proven by a check over the paths from the
   confirmed state.

## Outside check

Verifier runs the kill-the-primary fixture and the fault-injection
fixture on a fresh clone and inspects the party-facing responses for
any post-confirmation rejection.
