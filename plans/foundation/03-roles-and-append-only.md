---
id: foundation/03
type: task
status: ready
depends_on: [foundation/02]
migrations: [0002-roles-and-default-privileges]
binds:
  - decisions/LOG.md#005
evidence: []
verified_by: null
---

# Roles and append-only enforcement

## Objective

The database itself guarantees append-only — the guardrail application
code (AI-written or otherwise) cannot violate. Adopts Dispatch's proven
pattern (its migrations 0002/0006) verbatim in structure.

## Scope

- Migration `0002-roles-and-default-privileges`: application role with
  `GRANT SELECT, INSERT` only; `ALTER DEFAULT PRIVILEGES` so every future
  table inherits the restriction with no manual step; migrations run as
  table owner (which retains UPDATE/DELETE — schema evolution stays
  ordinary tooling, per Dispatch's trigger-rejection reasoning).
- Documented exemption license: derived/cache tables and payload-plane
  tables may be granted UPDATE/DELETE explicitly, per table, by name, in
  the migration that creates them, with a comment citing the licensing
  decision. Nothing is exempt today.
- `test/append-only.test` — the standing proof.

## Acceptance

- AC-F1 (mechanical): the application role cannot UPDATE or DELETE any
  table; a table created by a later dummy migration inherits the
  restriction with no manual step. Both proven in the test.

## Outside check

Verifier re-runs the append-only test and additionally attempts one raw
UPDATE as the app role via psql; both must fail.
