---
id: foundation/03
type: task
layer: foundation
satisfies: [1]
status: done
depends_on: [foundation/02]
migrations: [0002-roles-and-default-privileges]
binds:
  - decisions/LOG.md#005
evidence:
  [
    "log:log/2026-08-19-foundation-03-verification.md",
    "diff:PR #3 @ eef3d59cad502bb8c9a9a4b5e06e5edbb42d7530",
  ]
verified_by: clean-context-verifier@2026-08-19
---

# Roles and append-only enforcement

## Objective

The database itself guarantees append-only, the guardrail application
code (AI-written or otherwise) cannot violate. Adopts Dispatch's proven
pattern (its migrations 0002/0006) verbatim in structure.

## Scope

- Migration `0002-roles-and-default-privileges`: application role with
  `GRANT SELECT, INSERT` only; `ALTER DEFAULT PRIVILEGES` so every future
  table inherits the restriction with no manual step; migrations run as
  table owner (which retains UPDATE/DELETE, schema evolution stays
  ordinary tooling, per Dispatch's trigger-rejection reasoning).
- Documented exemption license: a table may be granted UPDATE/DELETE
  explicitly, **per table, by name, to a named role**, in the migration
  that creates or licenses it, with a comment citing the licensing
  decision. Three exemptions exist by ruling: `party_users` erasure
  (decision 016), the payload purge role (`foundation/08`), and
  `stream_heads` rebuildable projection (`trust-kernel/03`, decision 019),
  each licensed by name to a named role at its own migration site. No
  derived/cache exemption is granted, that clause is dropped until this
  repo actually has derived/cache semantics, rather than carried in from
  Dispatch as an unused escape hatch.
- **Operational boundaries, not just the role grant.** A role restriction
  is worthless if the application can step around it. Stated and enforced:
  the application never holds owner credentials at runtime; migration
  credentials are separate and unavailable to serving processes; and
  **SECURITY DEFINER recording functions may only INSERT**: `ingestion`
  writes through them by design, so each one is asserted to contain no
  UPDATE or DELETE.
- **Schema boundaries as a general posture** (decision 017). Some table
  pairs must be unlinkable, and "no query joins these" is unenforceable if
  both sit in one schema under one role, someone will write the join.
  Established here once: named schemas, per-schema role grants, a declared
  list of incompatible schema pairs, and a lint that fails any query
  touching both members of a declared pair. `party-registry/04`
  (`party_users` versus person tables, decision 016) is its first user;
  verification evidence and safety markers are likely next. Declaring a new
  boundary is a list entry, not a new mechanism.
- **What the append-only claim actually covers.** The application role
  holds no UPDATE or DELETE on any table *without a named exemption*, and
  each exemption is enumerated by the test rather than assumed away. The
  earlier unqualified "any table" would have gone false the moment the
  first exemption landed, and a test trained to ignore exceptions is worse
  than no test.
- `test/append-only.test`: the standing proof.

## Acceptance

1. (mechanical) the application role cannot UPDATE or DELETE any
   table outside the enumerated exemption list; a table created by a later
   dummy migration inherits the restriction with no manual step. The
   exemption list is asserted explicitly, so adding one requires editing the
   test.
- AC (mechanical): default-privilege inheritance is proven **across both
  databases and across more than one schema**, and under a second owner
  role. Postgres default privileges are per granting role and per schema,
  so a single-schema single-owner test proves far less than the claim.
- AC (mechanical): every SECURITY DEFINER function contains no UPDATE or
  DELETE statement, asserted by inspecting function bodies.
- AC (mechanical): no serving process has access to owner or migration
  credentials.
- AC (mechanical): for a declared incompatible schema pair, no role can read
  both, proven by attempting the join as every defined role and having each
  fail at the permission layer; and the cross-schema lint fails a planted
  query touching both.

## Outside check

Verifier re-runs the append-only test, attempts one raw UPDATE as the app
role via psql, repeats in a second schema and against the second database,
attempts to reach owner credentials from a serving process, declares a test
schema pair incompatible and attempts the join as each role, and greps every
SECURITY DEFINER body for mutation statements.
