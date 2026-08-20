---
id: ingestion/01
type: task
layer: ingestion
satisfies: [1, 6]
status: ready
depends_on: [trust-kernel/03, trust-kernel/08]
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
  outbox pattern, partitioned by resolved subject (the admission
  pipeline resolves before enqueue, decision 069), idempotency keyed
  on (attesting party, attestation id), a resubmission with the same
  key and a different payload hash rejected, internal
  received/recorded states for monitoring.
- The confirmation: sent only after the queue row is durable on the
  primary and its standby replica (decision 068). At confirmation the
  hash-chain timestamp is issued through trust-kernel/03 and the
  verification request is pinned (decision 069). Every rejection path
  runs before it; after it, processing failures retry until recorded
  and no party-facing rejection exists. Party-facing rejections are
  constructed by exactly one emitter in this module, which asserts the
  submission's state precedes confirmation; the grep-class check fails
  any rejection construction outside it.
- If the subject deletes between confirmation and recording, deletion
  wins: the entry is discarded by the deletion process and the party
  notification rides the deletion-notification path (decision 069).
- Retry and drain in the shape of foundation's outbox reconciler;
  stuck entries surface to monitoring, never to the party.

## Acceptance

1. AC (mechanical): a duplicate submission of a confirmed attestation
   by the same party returns the same confirmation and writes nothing
   new; the same key with a different payload hash is rejected; a
   different party reusing the attestation id collides with nothing.
2. AC (mechanical): the watermark test kills the primary mid-run;
   every confirmed attestation is present afterward and none is
   double-recorded; no confirmation was emitted for any submission not
   present afterward.
3. AC (mechanical): fault injection after confirmation produces
   retries until recorded; the single rejection emitter asserts
   pre-confirmation state, and the grep-class check fails a planted
   rejection construction outside it, red-path fixture included.
4. AC (mechanical): confirmation issues the chain timestamp and pins
   the request; the expiry sweep run after confirmation does not
   expire a pinned request, riding the self-asserted-record freeze
   fixtures.

## Outside check

Verifier runs the kill-the-primary fixture and the fault-injection
fixture on a fresh clone and inspects the party-facing responses for
any post-confirmation rejection.
