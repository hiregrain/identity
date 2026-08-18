---
id: foundation/02
type: task
status: ready
depends_on: [foundation/01]
migrations: [0001-migration-infrastructure]
evidence: []
verified_by: null
---

# Migration harness and type generation

## Objective

Numbered SQL migrations as the single schema source of truth, with
generated types that cannot drift.

## Scope

- Migration runner (plain SQL files, `NNNN-<kebab-noun-phrase>.sql`,
  applied in order, recorded in a migrations table; owner-role execution
  per the roles design landing in foundation/03).
- Migration `0001-migration-infrastructure`: the migrations bookkeeping
  table itself.
- Type generation from the live schema into Go and TS
  (`--check` mode diffs against committed output; CI runs it).
- CI replays the chain from empty twice (AC-F2's mechanism); adopt
  Dispatch's migration-number check into `checks/` scope (port lands in
  foundation/06, the number-claim convention binds from now).

## Acceptance

- AC: chain replays from empty deterministically; second replay is a
  no-op diff.
- AC (mechanical): editing a table without regenerating types fails CI.

## Outside check

Verifier drops the local database, replays twice, runs typegen `--check`,
and confirms a planted schema/typegen drift fails.
