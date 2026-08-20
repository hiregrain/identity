---
id: self-asserted-record/03
type: task
layer: self-asserted-record
satisfies: [8]
status: ready
depends_on: [self-asserted-record/01]
migrations: [0025-institution-registry]
binds: [decisions/LOG.md#063, model/record-schema.md, research/17-credential-education-schema-prior-art.md]
evidence: []
verified_by: null
---

# Institution registry and seeding

## Objective

Education claims resolve against a curated table of real institutions,
confirmed by the worker, and the raw string survives either way.

## Scope

- `0025-institution-registry` (payload plane, non-subject data): one row
  per institution with name, country, and a mandatory per-row source
  naming the accreditation list it came from.
- Seed importers for the machine-readable registries: US DAPIP, UK
  UKRLP, PH TESDA. India and the Philippine CHED wait on schema open
  item 6 (their regulators publish documents, not registries); the
  fallback raw-string path covers them, and no scraped source enters
  without a sourcing ruling.
- The confirmation constraint: `institution_ref` cannot be written
  without a confirmation reference, a database constraint, not
  application discipline. `institution_asserted` is stored verbatim in
  every case.
- No fuzzy matching in this task: it lands the table, the seeds, and
  the constraint. Match proposal is `extraction`'s job.

## Acceptance

1. AC (mechanical): each seed importer loads its list on a fresh clone;
   every row carries its source; row counts are asserted against the
   fetched list, never hand-written.
2. AC (mechanical): writing `institution_ref` without a confirmation
   reference fails at the database; with one, it lands and
   `institution_asserted` is still stored verbatim.
3. AC (mechanical): an education claim naming an institution absent from
   the registry lands cleanly with `institution_ref` null and country
   required, the fallback path.

## Outside check

Verifier runs the seeders against fixture copies of each list, attempts
the unconfirmed write, and confirms the raw string survives a confirmed
match byte-for-byte.
