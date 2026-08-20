---
id: verification/01
type: task
layer: verification
satisfies: [6]
status: ready
depends_on: [self-asserted-record/02, ingestion/04, party-registry/03]
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

- Issuance flows over the schema §10 table self-asserted-record owns,
  written only through that layer's recording functions, the stated
  seam: create a `claim_attestation` request against a claim (which
  freezes it, that layer's machinery) or an implicit
  `identity_verification` request when an IDV flow starts (no claim,
  no freeze, decision 071); deliver to the party, notify, and expose
  state to the worker through this layer's API (rendering is
  worker-surface's).
- The delivered request carries the party's pairwise pseudonym for the
  subject, obtained through ingestion/04's derivation function, which
  is how a party first holds the pseudonym it later signs over
  (decision 069). No ledger id in any delivered payload, the RF-1
  serializer pattern.
- The expiry copy: the worker sees the request's mandatory expiry at
  the moment of asking, per schema §10.
- Delivery channel for v1 is the party's registered operational
  contact, the artifact party-registry/03 records at key registration,
  which is why that task is a dependency.

## Acceptance

1. AC (mechanical): issuing a request delivers a payload carrying the
   pairwise pseudonym, the claim summary, and the request id; the
   claim summary schema carries only the claim's own asserted fields
   and the serializer check rejects a planted ledger id and a planted
   extra field alike, red-path fixtures for both.
2. AC (mechanical): the state API returns the request through its
   lifecycle (open, attested, declined, expired, withdrawn) and the
   creation response carries the expiry copy, proven by API fixtures.
3. AC (mechanical): the party notification fires on issuance to the
   registered contact; a request to a party with no registered contact
   fails creation with a structured error, never a silent non-delivery.

## Outside check

Verifier issues fixtures across the lifecycle, inspects delivered
payloads for ledger ids, and confirms the no-contact red path.
