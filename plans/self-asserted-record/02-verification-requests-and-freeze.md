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
  table per schema §10: subject, claim ref (a chapter, education, or
  credential; positions freeze with their chapter and are never a
  claim ref), party ref, state enum, `requested_at`, mandatory
  `expires_at`.
- Freeze on request creation, enforced at the recording functions and by
  a database constraint, never UI-only: a frozen claim rejects edit and
  delete.
- Thaw on `declined`, on expiry (a sweep marks past-due requests
  `expired`), and on `withdrawn_before_send` (schema §10, decision
  064). Permanent freeze on `attested`. Every enum state is either a
  thaw, a permanent freeze, or `open`; no state is unhandled.
- State transitions are append-only rows in the pattern of
  person-identity's lifecycle states, never an editable column.
- Issuance flows (who may ask, party notification) belong to the
  `verification` layer; this task exposes creation to the worker's own
  API only.

## Acceptance

1. AC (mechanical): creating a request freezes the whole claim at API
   and database; edits and deletes are rejected at both layers while
   frozen.
2. AC (mechanical): decline, expiry, and pre-send withdrawal each thaw
   the claim; edits and deletes work again; the worker reads every
   version row while the claim is frozen and after it thaws, and the
   post-thaw version list equals the pre-freeze list plus any
   post-thaw edits.
3. AC (mechanical): a claim with an `attested` request rejects edits and
   deletes permanently; no transition out of `attested` exists.
4. AC (mechanical): a request cannot be created without `expires_at`;
   the sweep expires a past-due request and the claim thaws without any
   party action, the dissolved-employer case.

## Outside check

Verifier runs the freeze fixture across the three freezable claim types
and every enum state, and greps for any freeze check that lives only in
application code.
