---
id: ingestion/06
type: task
layer: ingestion
satisfies: [3]
status: ready
depends_on: [ingestion/05]
migrations: [0035-invalidation-records]
binds: [model/attestation-interface.md, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# Supersession authority: N-1 enforced at the door

## Objective

Only the party that wrote an attestation, or the ledger itself on
proven fraud, can ever supersede it.

## Scope

- The N-1 rule at admission: a superseding attestation lands only when
  its issuer equals the original's issuer; anyone else's is rejected
  with a structured error, before confirmation.
- The ledger invalidation path: `0035-invalidation-records` stores the
  signed invalidation record; this task builds the recording function,
  itself a chained privileged action; the operator-facing flow that
  calls it belongs to operator-console and arrives with that layer.
  Never an edit to the original.
- Supersession is append-only: the original stays; the superseded flag
  is a derived read-time projection this task exposes through the
  audit query, since this layer owns no party or worker read surface.

## Acceptance

1. AC (mechanical): party B's supersession of party A's attestation is
   rejected pre-confirmation; party A's lands and the audit query's
   derived projection shows the original superseded with its content
   untouched.
2. AC (mechanical): the ledger invalidation lands as a signed record,
   emits a chained privileged-operator event, and edits nothing,
   proven by byte-comparing the original before and after.
3. AC (mechanical): no code path updates an attestation row, proven by
   privilege inspection: no role but the append path's writes to the
   tables, and it holds INSERT only.

## Outside check

Verifier runs the cross-party supersession fixture, executes an
invalidation, byte-compares the original, and inspects privileges.
