---
id: self-asserted-record/01
type: task
layer: self-asserted-record
satisfies: [4]
status: ready
depends_on: [person-identity/01]
migrations: [0023-record-objects]
binds: [decisions/LOG.md#008, decisions/LOG.md#010, decisions/LOG.md#062, decisions/LOG.md#063, decisions/LOG.md#064, model/record-schema.md, model/attestation-interface.md]
evidence: []
verified_by: null
---

# Record objects, version history, and write validation

## Objective

The four worker-authored objects exist with append-only version history,
and no write that violates the ratified schema or the sensitive-data ban
can land.

## Scope

- `0023-record-objects` (payload plane): `chapter`, `position`,
  `education`, `credential` tables per schema §2, §3, §8, §9, plus
  append-only version rows for each, under the subject's DEK per the
  §1 freeze rule. Writes go through recording functions only, the
  SECURITY-DEFINER pattern foundation/03 established; the application
  role has no direct INSERT.
- CRUD for unfrozen claims: create, edit (a new version row, prior rows
  never mutated), and delete as a tombstone version row, because
  foundation/03's ratified invariant permits recording functions to
  INSERT only (decision 064); a tombstoned claim leaves the record and
  its versions persist worker-only until profile deletion. Freeze
  enforcement itself is task 02; this task leaves every claim unfrozen.
- The confirmation-reference columns and constraints of schema §10
  (decision 064) ship in `0023-record-objects` with the tables:
  `origin: resume_parsed` requires a confirmation reference, and so do
  `institution_ref` and `issuer_ref` writes. This task creates the
  constraints; tasks 03, 05, and 08 exercise them.
- Validation at the recording functions: month precision, enum
  membership, positions inside chapter bounds, `party_country`
  required when `party_ref` is null and the same rule for
  `institution_country` and `issuer_country`, raw asserted strings
  stored verbatim.
- The A-4 sensitive-data ban (interface, extended by decisions 008/010)
  enforced on every field including free text: `field_of_study`,
  `credential_name`, `institution_asserted`, `title_asserted`,
  `party_asserted`. Rejection returns a structured error naming the
  category.

## Acceptance

1. AC (mechanical): each of the four object types round-trips create,
   edit, and tombstone-delete; every edit produces a version row; a
   tombstoned claim is absent from record reads and present in the
   worker's version history; no code path mutates or removes a prior
   version, proven by the append-only test pattern from foundation/03
   with zero UPDATE or DELETE grants.
2. AC (mechanical): a write violating schema shape, month precision,
   bounds, or a required-country rule is rejected with a structured
   error; a fixture exercises each rule per object type.
3. AC (mechanical): every A-4 category, including one planted in each
   free-text field, is rejected with a structured error naming the
   category; a DOB typed into `field_of_study` does not land.
4. AC (mechanical): the application role cannot INSERT or UPDATE any
   record or version table directly.

## Outside check

Verifier runs the migration on a fresh clone, runs the acceptance
suites, and greps for any write path that bypasses the recording
functions.
