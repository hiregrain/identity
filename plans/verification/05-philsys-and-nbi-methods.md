---
id: verification/05
type: task
layer: verification
satisfies: [3]
status: ready
depends_on: [verification/02]
migrations: []
binds: [decisions/LOG.md#070, research/09-idv-vendor-landscape.md]
evidence: []
verified_by: null
---

# PhilSys and NBI methods behind the same interface

## Objective

The Philippine rails land as adapters, and landing them proves the
interface holds: a new method is a module and a registry entry, nothing
else.

## Scope

- PhilSys-QR validation and NBI-QR check as adapters behind
  `verify(person, method)`: parse and validate the QR payloads,
  results-only, no document image persisted, each producing its
  attestation through ingestion like every other method.
- Criterion 3's proof rides this task: the diff that lands each
  adapter touches an adapter module and a registry entry, and
  `git diff` over `db/migrations/` for the change is empty; the
  synthetic adapter from task 02 is the second half of the proof.
- Per-region fallback ladder configuration: the ordered method list
  per region, with pass rates measured at pilot rather than assumed
  (the DHS overstatement finding); the configuration exists here, the
  numbers arrive from the pilot.

## Acceptance

1. AC (mechanical): each adapter lands with an empty migrations diff,
   asserted by the criterion 3 check over the landing commits.
2. AC (mechanical): a valid PhilSys QR fixture yields an attestation
   with the method and level the fixture table expects; a tampered QR
   is rejected with a structured error and nothing persists.
3. AC (mechanical): the region fallback configuration resolves an
   ordered method list per region and rejects a region with no
   configured ladder, never a silent default.

## Outside check

Verifier lands a synthetic adapter change to reproduce the
empty-migrations proof, runs the QR fixtures, and probes the
unconfigured-region path.
