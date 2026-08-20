---
id: verification/02
type: task
layer: verification
satisfies: [5]
status: ready
depends_on: [ingestion/01, party-registry/01]
migrations: []
binds: [decisions/LOG.md#070, model/attestation-interface.md]
evidence: []
verified_by: null
---

# The verify interface and the one door out

## Objective

Every verification method, real or synthetic, produces a signed
attestation and hands it to ingestion; nothing verification-shaped can
write to the record any other way.

## Scope

- The internal interface: `verify(person, method)` returning a
  verification attestation `{issuer, method, level, verified_at,
  expiry/decay, evidence_commitment}`; adapters register in a method
  registry.
- The synthetic adapter: a fixture provider implementing the full
  interface, which is what every downstream task tests against and
  half of criterion 3's proof.
- Submission: the adapter's result is signed as the vendor party's
  attestation and submitted to the ingestion pipeline under the
  worker-initiated request that started the flow; the verification
  package holds no database write path to any fact table.
- Vendor parties register through party-registry's normal machinery;
  the synthetic provider registers as a test-only party.

## Acceptance

1. AC (mechanical): a synthetic-adapter run produces a signed
   attestation that lands through ingestion, chained and confirmed
   like any party's; the run record of the flow is the ingestion
   pipeline's, not a parallel one.
2. AC (mechanical): the verification package holds no INSERT or UPDATE
   privilege on any fact table and the foundation/06 schema-grep check
   finds no direct write path, red-path fixture included.
3. AC (mechanical): an adapter returning a malformed result is
   rejected at ingestion validation and the failure surfaces to the
   flow, never a partial write.

## Outside check

Verifier runs the synthetic flow end to end on a fresh clone, inspects
privileges, and submits the malformed-result fixture.
