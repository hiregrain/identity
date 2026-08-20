---
id: trust-kernel/08
type: task
layer: trust-kernel
satisfies: []
status: draft
depends_on: []
migrations: []
binds: [decisions/LOG.md#052]
evidence: []
verified_by: null
---

# Database transport: one seam for every SQL path

## Objective

One module owns how Go code reaches the two planes, so the eventual
Postgres-driver decision changes one file, and SQL safety lives in a seam
rather than in call-site discipline.

## Scope

- The foundation review (decision 052 context) found `docker compose exec
  psql` hard-coded in three packages, each with its own quoting rules and
  its own row-parsing format: core/deletion splits rows on "|",
  core/outbox on tabs, and core/envelope defines a Querier contract its
  callers implement ad hoc. Safe today because every value is
  shape-validated first; a copying-ground for the next layer that forgets
  why.
- One transport package: addressed by (plane, role), owning parameter
  substitution or a single literal renderer with the refuse-list
  discipline, and one row-parsing format. The compose-exec adapter is the
  first implementation; a driver adapter arrives behind the same seam
  when a decisions entry admits the dependency.
- core/envelope's Querier, core/deletion, and core/outbox move onto it.
  No behavior change: this task earns its keep by deleting duplicated
  plumbing, not by adding capability.
- Out of scope: the driver decision itself, connection pooling, and any
  change to what SQL the callers issue.

## Acceptance

1. (mechanical) exactly one package constructs a psql or driver
   invocation: a grep-class check fails any `exec.Command` reaching
   docker or psql outside the transport package, wired into the metadata
   group with a red-path fixture.
2. (mechanical) one literal renderer and one row parser exist: the
   duplicate quoting and parsing definitions in core/deletion and
   core/outbox are gone, asserted by grep for the removed symbols.
3. (mechanical) every existing acceptance suite passes unchanged:
   envelope (both providers), cross-plane outbox, deletion, append-only,
   two-plane split. The diff touches no test expectations.

## Outside check

Verifier greps for transport constructions outside the package, runs the
full check pipeline on a fresh clone, and confirms the three call sites
now import the transport module.
