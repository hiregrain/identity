---
id: ingestion/03
type: task
layer: ingestion
satisfies: [8]
status: ready
depends_on: [ingestion/01, trust-kernel/02, party-registry/03, party-registry/05]
migrations: []
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
  and the ledger hash-chain timestamp predates any compromise report.
  Party suspension is never retroactive; existing records get a
  read-time flag elsewhere, never an edit here.
- Issuer state and probation caps at admission: a suspended party's
  submissions are rejected; a probationary party's submissions count
  against the caps party-registry/05 defines, and the cap breach
  rejection is structured.

## Acceptance

1. AC (mechanical): a valid signature from an active key lands; a
   tampered payload, an unknown `kid`, and a signature from a key
   inactive at signing time are each rejected with structured errors.
2. AC (mechanical): an attestation whose timestamp postdates its key's
   compromise report is rejected; one predating it lands, per R-3,
   proven with the party-registry compromise fixtures.
3. AC (mechanical): a suspended party's submission is rejected; a
   probationary party's submission over cap is rejected naming the
   cap; under cap it lands.

## Outside check

Verifier replays the signature and compromise fixtures against a fresh
clone and confirms every rejection is structured and every acceptance
verifies against the registry state at that moment.
