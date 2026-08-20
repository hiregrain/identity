---
id: self-asserted-record/06
type: task
layer: self-asserted-record
satisfies: [9]
status: ready
depends_on: [self-asserted-record/01, self-asserted-record/02, self-asserted-record/05, trust-kernel/03]
migrations: []
binds: [decisions/LOG.md#009, decisions/LOG.md#063]
evidence: []
verified_by: null
---

# Record writes join the subject's chain

## Objective

Every worker record write is a chained governing event from the first
commit, and deletion leaves no hash behind.

## Scope

- Record-write events (create, new version, delete, freeze and thaw
  transitions) append to the subject's per-stream chain through
  trust-kernel/03's machinery; worker record writes are on the kernel's
  governing-event list (decision 063), so its coverage check counts
  them.
- Chain membership is fixed at write time per the kernel's rule; import
  commits chain identically to manual writes.
- Deletion semantics per decision 009: profile deletion leaves no
  retained hash of deleted content in any readable structure; the
  worker stream's entries follow the kernel's deletion design, and this
  task proves the property rather than inventing a mechanism.

## Acceptance

1. AC (mechanical): a CRUD-plus-import fixture across chapters,
   education, and credentials, with position writes chaining through
   their chapter's stream, produces a chain that passes trust-kernel
   verification; a mutated historical record row is detected by the
   chain check. Import commits come through task 05's flow, which is
   why 05 is a dependency.
2. AC (mechanical): the kernel's every-governing-event coverage check
   counts record writes and fails if any record write path skips the
   chain.
3. AC (mechanical): the delete-after-chain fixture deletes a profile
   after chained writes and a full scan finds no retained hash of the
   deleted content in any readable structure (decision 009).

## Outside check

Verifier runs the kernel's chain and coverage checks over this task's
fixtures on a fresh clone, then runs the deletion scan.
