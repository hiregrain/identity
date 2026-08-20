---
id: foundation/02
type: task
layer: foundation
satisfies: [2]
status: done
depends_on: [foundation/01]
migrations: [0001-migration-infrastructure]
evidence:
  [
    "log:log/2026-08-19-foundation-02-verification.md",
    "diff:PR #2 @ 11b1b2f1870fba5842eaa03686548c7a5c5c3ade",
  ]
verified_by: clean-context-verifier@2026-08-19
---

# Migration harness and type generation

## Objective

Numbered SQL migrations as the single schema source of truth, with
generated types that cannot drift.

## Scope

- Migration runner (plain SQL files, `NNNN-<kebab-noun-phrase>.sql`,
  applied in order, recorded in a migrations table). **Migrations execute
  as the table owner**, established here; foundation/03 then constrains the
  *application* role without touching this. Stated in this direction
  because 03 depends on 02, not the reverse.
- **One shared numbering sequence across both chains** (decision 017).
  Numbers are globally unique across spine and payload; each chain
  therefore has gaps where the other's numbers fall. This is what makes a
  cross-plane ordering constraint expressible: a payload migration
  referencing a spine table can be required to follow it by number.
  Independent per-chain numbering cannot express that, and the constraint
  is real: `0014-safety-markers` references the party table created in
  `0009-party-core`.
- Migration `0001-migration-infrastructure`: the migrations bookkeeping
  table itself.
- Type generation from **both** live schemas into Go and TS, **namespaced
  by plane**, separate output per database, with no shared type namespace.
  A spine type and a payload type must not be interchangeable at a call
  site; accidental cross-plane type reuse is how the plane split gets
  violated in application code while every database-level check still
  passes. `--check` mode diffs against committed output; CI runs it.
- CI replays the chain from empty twice (criterion 2's mechanism); adopt
  Dispatch's migration-number check into `checks/` scope (port lands in
  foundation/06, the number-claim convention binds from now).

## Acceptance

- AC: both chains replay from empty deterministically; second replay is a
  no-op diff.
- AC (mechanical): a duplicate number across the two chains fails the
  numbering check.
- AC (mechanical): generated spine and payload types are separately
  namespaced; a test asserts a payload type cannot satisfy a spine-typed
  parameter.
- AC (mechanical): editing a table without regenerating types fails CI.

## Outside check

Verifier drops the local database, replays twice, runs typegen `--check`,
and confirms a planted schema/typegen drift fails.
