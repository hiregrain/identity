---
id: ingestion/03
type: task
layer: ingestion
satisfies: [8]
status: ready
depends_on: [ingestion/01, trust-kernel/02, party-registry/03, party-registry/05]
migrations: [0033-ingestion-counters]
binds: [model/attestation-interface.md, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# Signature verification and issuer state at admission

## Objective

An attestation is accepted only from a registered party whose key was
honestly live when it signed, within whatever caps its standing allows.

## Scope

- Signature verification through the kernel: Ed25519 over the
  canonical payload in the JWS envelope, `kid`-bound, against the
  party registry's key state.
- The R-3 validity rule: valid iff the key was active at signing time
  and, at the confirmation moment, the key carries no compromise
  report; the just-issued chain timestamp (decision 069) is what the
  comparison binds. A key past its renewal window halts that party's
  ingestion with a structured error naming the cause, the
  party-registry/03 obligation graded from this side too.
  Party suspension is never retroactive; existing records get a
  read-time flag elsewhere, never an edit here.
- Issuer state and probation caps at admission: a suspended party's
  submissions are rejected; a probationary party's confirmed
  submissions count
  against the caps party-registry/05 defines over that task's window,
  tracked in `0033-ingestion-counters`; rejections never count
  (decision 069), and the cap breach
  rejection is structured.

## Acceptance

1. AC (mechanical): a valid signature from an active key lands; a
   tampered payload, an unknown `kid`, and a signature from a key
   inactive at signing time are each rejected with structured errors.
2. AC (mechanical): a submission confirming after its key's compromise
   report is rejected; one confirmed before the report stands, per
   R-3, proven with the party-registry compromise fixtures; a key past
   its renewal window halts that party's submissions with a structured
   error naming the cause.
3. AC (mechanical): a suspended party's submission is rejected; a
   probationary party's submission over cap is rejected naming the
   cap; under cap it lands; a rejected submission does not move the
   counter, proven by counter inspection around a rejection.

## Outside check

Verifier replays the signature and compromise fixtures against a fresh
clone and confirms every rejection is structured and every acceptance
verifies against the registry state at that moment.
