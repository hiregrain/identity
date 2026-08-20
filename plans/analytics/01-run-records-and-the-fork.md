---
id: analytics/01
type: task
layer: analytics
satisfies: [5, 6]
status: ready
depends_on: [foundation/05, foundation/08]
migrations: [0028-run-records]
binds: [decisions/LOG.md#026, decisions/LOG.md#066, decisions/LOG.md#067]
evidence: []
verified_by: null
---

# Run records split across the planes

## Objective

Every run leaves exactly one record of our processing that survives the
person's deletion without surviving the person.

## Scope

- `0028-run-records`, both planes. Spine half: requesting party (the
  recipient account per decisions 057/067), day-precision timestamp,
  instrument version, model version (present and null in v0; populated
  only when a decisions entry admits a model), per-run pseudonym, no
  output field, no subject field. Payload half, under the subject's
  DEK: the pseudonym, subject linkage, input references, and the
  full-precision timestamp. The join between halves is the pseudonym,
  readable only while the payload half lives.
- The pseudonym generator takes no subject-derived input: its signature
  accepts no subject identifier and it reads only the randomness
  source, so non-derivation is asserted structurally, not
  statistically.
- Writes through recording functions only, the foundation/03 pattern;
  one record per run enforced at the schema.
- Spine allow-list exception (foundation/04 rule): the run-record
  columns above are a written exception authored in the migration with
  its rationale at the site. Retention sweep on the spine half: six
  months, stated as that number; the sweep's DELETE is a named,
  role-scoped exemption per foundation/03, granted in the migration
  that creates the table.
- Read-path isolation: run records are readable by the audit role and
  by no packet, ranking, or worker-facing path, enforced by role
  grants.

## Acceptance

1. AC (mechanical): a scored run writes exactly one spine record and
   one payload record; a second write for the same run fails at the
   schema; the spine record has no output field and no subject field,
   asserted at the schema level.
2. AC (mechanical): after profile deletion the payload half is gone
   and the spine half survives with each non-identifying property
   asserted directly: no subject field, day-precision timestamp, and a
   requesting party that is a recipient account id.
3. AC (mechanical): the pseudonym generator's signature accepts no
   subject identifier, asserted by a grep-class check on its call
   sites; pseudonyms are unique across a fixture of repeated runs on
   one subject.
4. AC (mechanical): the audit role reads run records; the application,
   packet, and worker-surface roles cannot, proven by privilege
   inspection and bypass attempts.
5. AC (mechanical): the retention sweep prunes a spine record aged
   past six months and touches nothing younger; no role other than the
   sweep's holds DELETE, proven by privilege inspection.

## Outside check

Verifier runs the deletion fixture on a scored person, inspects both
planes, runs the privilege inspections and bypass attempts, and checks
the migration carries the allow-list exception and the named DELETE
exemption with rationale at the site.
