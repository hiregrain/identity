---
id: foundation/06
type: task
status: ready
depends_on: [foundation/01]
evidence: []
verified_by: null
---

# Repo self-checks and the workable-frontier runner

## Objective

Port Dispatch's `checks/` machinery: the repo verifies itself, and the
execution queue is computed, never hand-maintained (plans/ORDER.md).

## Scope

- `checks/frontmatter.mjs` — validates every plan file's frontmatter
  fields and vocabulary (status enum, evidence format, verified_by
  format).
- `checks/plan-graph.mjs` — validates the dependency graph (no cycles,
  no dangling refs), computes and lists the workable frontier (`ready`
  tasks whose `depends_on` are all `done`).
- `checks/decisions-index.mjs` — adapted: validates decisions/LOG.md
  entry numbering (append-only, no gaps, no duplicate numbers).
- `checks/migration-numbers.mjs` — collisions and gaps across both
  chains, honoring at-authoring claims in task frontmatter.
- Schema-grep check (Dispatch AC-04.3 pattern): no fact-table column may
  store a capability score, tier, or trajectory; extended with the spine
  readable-column lint hook (foundation/04 supplies the rule, this task
  the runner).
- `checks/run.mjs` — runs all, then prints the frontier. Exempt from the
  plan gate (verifies the repo, not the product).

## Acceptance

- AC (mechanical): `node checks/run.mjs` passes on the current repo and
  lists the correct frontier for a synthetic fixture tree with known
  blocked/workable tasks.
- AC: each check fails correctly against a planted violation (one fixture
  per check, exercised in CI).

## Outside check

Verifier runs the suite, then introduces one violation per check
(scrambled status, cycle, duplicate decision number, migration collision,
scored column) and confirms each is caught with a message naming the
rule.
