---
id: verification/01
type: task
layer: verification
satisfies: [6]
status: ready
depends_on: [self-asserted-record/02, ingestion/04]
migrations: []
binds: [decisions/LOG.md#069, decisions/LOG.md#070, model/record-schema.md]
evidence: []
verified_by: null
---

# Verification request issuance and delivery

## Objective

A worker asks a party to vouch for a claim; the party receives
everything it needs to answer and nothing that identifies beyond its
own pseudonym.

## Scope

- Issuance flows over the schema §10 table self-asserted-record owns:
  create against a claim (which freezes it, that layer's machinery),
  deliver to the party, notify, and surface state to the worker.
- The delivered request carries the party's pairwise pseudonym for the
  subject, obtained through ingestion/04's derivation function, which
  is how a party first holds the pseudonym it later signs over
  (decision 069). No ledger id in any delivered payload, the RF-1
  serializer pattern.
- The expiry copy: the worker sees the request's mandatory expiry at
  the moment of asking, per schema §10.
- Delivery channel for v1 is the party's registered contact from
  party-registry; rendering surfaces belong to worker-surface.

## Acceptance

1. AC (mechanical): issuing a request delivers a payload carrying the
   pairwise pseudonym, the claim summary, and the request id; the
   serializer check rejects a planted ledger id, red-path fixture
   included.
2. AC (mechanical): the worker's state view shows the request through
   its lifecycle (open, attested, declined, expired, withdrawn) and the
   expiry is rendered at creation, proven by rendering fixtures.
3. AC (mechanical): the party notification fires on issuance to the
   registered contact; a request to a party with no registered contact
   fails creation with a structured error, never a silent non-delivery.

## Outside check

Verifier issues fixtures across the lifecycle, inspects delivered
payloads for ledger ids, and confirms the no-contact red path.
