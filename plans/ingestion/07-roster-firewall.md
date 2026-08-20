---
id: ingestion/07
type: task
layer: ingestion
satisfies: [5]
status: ready
depends_on: [ingestion/02, self-asserted-record/02]
migrations: []
binds: [model/roster-firewall.md, decisions/LOG.md#031, decisions/LOG.md#032, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# The roster firewall: worker-initiated or nothing

## Objective

No employer can push a record about a person who did not ask; every
attestation traces to a live request the worker made.

## Scope

- RF-2 at admission: an attestation lands only when its
  `verification_request_id` resolves in the schema §10 table to a
  request whose subject is the resolved person and whose party is the
  submitting party, and which is either **live** or **already
  attested** between that party and subject, the opened relationship
  (decisions 031/069, no new object: the attested request is the
  relationship anchor). Liveness is checked against the primary.
- The employer-push red path: a deliberately constructed roster-derived
  attestation with no request fails with a structured error naming the
  firewall.
- The `attested` transition itself happens at the append and belongs
  to task 05; this task is the gate only.

## Acceptance

1. AC (mechanical): an attestation with no request id, an expired
   unpinned request, a request naming a different subject, and a
   request naming
   a different party are each rejected pre-confirmation with
   structured errors.
2. AC (mechanical): the employer-push fixture fails ingestion; the
   same content submitted against a live matching request lands.
3. AC (mechanical): a follow-up attestation referencing an `attested`
   request between the same party and subject lands without a fresh
   request; the same reference from a different party, or against a
   declined or expired request, is rejected.

## Outside check

Verifier runs the four rejection fixtures, the employer-push red path,
and the freeze-transition fixture on a fresh clone.
