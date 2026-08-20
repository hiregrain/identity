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

- RF-2 at admission: an attestation lands only when it carries a
  `verification_request_id` resolving to a live request (the schema
  §10 table) whose subject is the resolved person and whose party is
  the submitting party. Liveness is checked against the primary.
- The first-attestation rule from decision 031's narrowing of 028: the
  worker initiates the first attestation from a given party; that
  party writes freely thereafter within the opened relationship.
  Subsequent attestations from an opened relationship carry the
  relationship reference instead of a fresh request.
- The employer-push red path: a deliberately constructed roster-derived
  attestation with no request fails with a structured error naming the
  firewall.
- Request state transition: a landing attestation moves its request to
  `attested`, which is what makes the subject's claim freeze permanent
  (self-asserted-record's freeze rule).

## Acceptance

1. AC (mechanical): an attestation with no request id, an expired
   request, a request naming a different subject, and a request naming
   a different party are each rejected pre-confirmation with
   structured errors.
2. AC (mechanical): the employer-push fixture fails ingestion; the
   same content submitted against a live matching request lands.
3. AC (mechanical): a landing attestation transitions its request to
   `attested` and the subject's claim freeze becomes permanent, riding
   the self-asserted-record freeze fixtures.
4. AC (mechanical): within an opened relationship, a second
   attestation lands without a fresh request; from a party with no
   opened relationship, it is rejected.

## Outside check

Verifier runs the four rejection fixtures, the employer-push red path,
and the freeze-transition fixture on a fresh clone.
