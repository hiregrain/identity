---
id: analytics/01
type: task
layer: analytics
satisfies: [5, 6]
status: ready
depends_on: []
migrations: [0028-run-records]
binds: [decisions/LOG.md#026, decisions/LOG.md#066]
evidence: []
verified_by: null
---

# Run records split across the planes

## Objective

Every run leaves exactly one record of our processing that survives the
person's deletion without surviving the person.

## Scope

- `0028-run-records`, both planes. Spine half: requesting party,
  timestamp, instrument and model versions, per-run pseudonym (random,
  generated at run time, never reused), no output field, no subject
  field. Payload half, under the subject's DEK: the pseudonym, subject
  linkage, and input references. The join between halves is the
  pseudonym, readable only while the payload half lives.
- Writes through recording functions only, the foundation/03 pattern;
  one record per run enforced at the schema.
- Retention sweep on the spine half: six months, stated as that number
  (decisions 026, 066), pruned by the sweep and by nothing else.
- Read-path isolation: run records are reachable by the regulator/audit
  role and by no path touching a packet, a ranking, or a worker-facing
  surface, enforced by role grants, not convention.

## Acceptance

1. AC (mechanical): a scored run writes exactly one spine record and
   one payload record; a second write for the same run fails at the
   schema; the spine record has no output and no subject field,
   asserted at the schema level.
2. AC (mechanical): after profile deletion the payload half is gone,
   the spine half survives, and nothing readable links the surviving
   record to any person; two surviving records for the same deleted
   person are unlinkable through any readable data.
3. AC (mechanical): pseudonyms are unique across all runs in a fixture
   of repeated runs on one subject; no code path derives a pseudonym
   from any subject identifier, asserted by the red-path test seeding
   identical subjects and asserting distinct pseudonyms.
4. AC (mechanical): the audit role reads run records; the application,
   packet, and worker-surface roles cannot, proven by privilege
   inspection and bypass attempts.
5. AC (mechanical): the retention sweep prunes a spine record aged past
   six months and touches nothing younger.

## Outside check

Verifier runs the deletion fixture on a scored person, inspects both
planes, attempts the cross-record linkage with full database access,
and runs the privilege bypass attempts.
