---
id: foundation/06
type: task
layer: foundation
satisfies: []
status: done
depends_on: [foundation/01, foundation/04]
evidence:
  [
    "log:log/2026-08-19-foundation-06-verification.md",
    "diff:PR #6 @ bd9e97703b82f9d2bcbfa234ce8f538486117719",
  ]
verified_by: clean-context-verifier@2026-08-19
---

# Repo self-checks and the workable-frontier runner

## Objective

Port Dispatch's `checks/` machinery: the repo verifies itself, and the
execution queue is computed, never hand-maintained (plans/ORDER.md).

## Scope

- `checks/frontmatter.mjs`: validates every plan file's frontmatter
  fields and vocabulary (status enum, evidence format, verified_by
  format).
- `checks/plan-graph.mjs`: validates the dependency graph (no cycles,
  no dangling refs), computes and lists the workable frontier (`ready`
  tasks whose `depends_on` are all `done`).
- `checks/decisions-index.mjs`: adapted, validates decisions/LOG.md
  entry numbering (append-only, no gaps, no duplicate numbers).
- `checks/migration-numbers.mjs`: collisions across both chains under the
  **one shared numbering sequence** (decision 017), honoring at-authoring
  claims in task frontmatter. Gaps within a single chain are expected and
  are not failures; a number used twice anywhere is.
- `checks/migration-order.mjs`: **cross-layer reference ordering**, when a
  migration references an object another migration creates, the referencing
  number must be higher. Collisions and gaps do not catch this, and the
  constraint is live today (`0014-safety-markers` references
  `0009-party-core`).
- Schema-grep check (Dispatch AC-04.3 pattern): no fact-table column may
  store a capability score, tier, or trajectory, **nor any derived
  reliability, trust, or weighting score about a person** (decision 025
  withdrew the one mechanism that would have needed such a column, so this
  now catches an unlicensed reintroduction rather than a bounded exception);
  extended with the spine readable-column lint hook (foundation/04 supplies
  the rule, this task the runner).
- `checks/verbatim-copies.mjs`: Dispatch's diff of labeled constraint
  blockquotes against their sources. In Dispatch this check is the
  **precondition for quoting any constraint into a plan file**: a labeled
  blockquote is an exact copy, `[…]` marks a deliberate splice, and commentary
  sits outside the quote. Identity's plan files today carry pointers rather
  than quotes, so the check has nothing to fail on. Port it anyway, because
  its absence is what makes quoting look free.
- `checks/counts.mjs`: no hand-written count of a checkable thing outside a
  closed record (`CLAUDE.md`). Flags a numeral or number-word immediately
  preceding an enumerable structure (a table, a list, a directory listing)
  in `plans/`, `model/`, `DESIGN.md` and the READMEs, excluding
  `decisions/LOG.md` and discharged spikes, whose counts are frozen facts.
  Two such counts were already wrong when this task was authored.
- `checks/run.mjs`: runs all, then prints the frontier. Exempt from the
  plan gate (verifies the repo, not the product). Splits its checks into
  **metadata checks that need no database** (frontmatter, plan graph,
  numbering, ordering, decisions index, verbatim copies, counts) and **schema
  checks that do**, so foundation/01's CI can run the first group before any
  database boots.

## Acceptance

- AC (mechanical): `node checks/run.mjs` passes on the current repo and
  lists the correct frontier for a synthetic fixture tree with known
  blocked/workable tasks.
- AC: each check fails correctly against a planted violation (one fixture
  per check, exercised in CI), including a cross-layer ordering violation.
- AC (mechanical): the metadata check group runs to completion with no
  database available.

## Outside check

Verifier runs the suite with no database running to confirm the metadata
group completes, then introduces one violation per check (scrambled status,
cycle, duplicate decision number, migration collision, out-of-order
cross-layer reference, scored column) and confirms each is caught with a
message naming the rule.
