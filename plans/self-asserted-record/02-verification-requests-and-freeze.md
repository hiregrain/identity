---
id: self-asserted-record/02
type: task
layer: self-asserted-record
satisfies: [1]
status: ready
depends_on: [self-asserted-record/01]
migrations: [0024-verification-requests]
binds: [decisions/LOG.md#063, model/record-schema.md]
evidence: []
verified_by: null
---

# Verification requests and the freeze lifecycle

## Objective

A claim freezes the moment its worker asks a party to attest it, thaws
if the ask dies, and locks permanently the moment an attestation lands.

## Scope

- `0024-verification-requests` (payload plane): the `verification_request`
  table per schema §10: subject, claim ref (any of the four object
  types), party ref, state enum, `requested_at`, mandatory `expires_at`.
- Freeze on request creation, enforced at the recording functions and by
  a database constraint, never UI-only: a frozen claim rejects edit and
  delete.
- Thaw on `declined` and on expiry; a sweep marks past-due requests
  `expired`. Permanent freeze on `attested`.
- State transitions are append-only rows in the pattern of
  person-identity's lifecycle states, never an editable column.
- Issuance flows (who may ask, party notification) belong to the
  `verification` layer; this task exposes creation to the worker's own
  API only.

## Acceptance

1. AC (mechanical): creating a request freezes the whole claim at API
   and database; edits and deletes are rejected at both layers while
   frozen.
2. AC (mechanical): decline and expiry each thaw the claim; edits and
   deletes work again; version history spans the freeze unbroken.
3. AC (mechanical): a claim with an `attested` request rejects edits and
   deletes permanently; no transition out of `attested` exists.
4. AC (mechanical): a request cannot be created without `expires_at`;
   the sweep expires a past-due request and the claim thaws without any
   party action, the dissolved-employer case.

## Outside check

Verifier runs the freeze fixture across all four object types and all
three terminal states, and greps for any freeze check that lives only in
application code.
