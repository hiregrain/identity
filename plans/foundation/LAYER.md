---
id: foundation
type: layer
status: ready
milestone: v1
depends_on: []
binds:
  - decisions/LOG.md#005
  - design/stack-litigation/docket-rulings-0.1.md
acceptance: [AC-F1, AC-F2, AC-F3, AC-F4]
evidence: []
verified_by: null
---

# foundation

Repo scaffolding and the storage substrate every other layer stands on.

Scope: monorepo layout (Go core / TS surfaces / language-neutral contract
schema per D2); CI (migrate → typegen → typecheck → tests → checks);
managed Postgres provisioning (D1) with the spine/payload physical split,
`residency_region` stamped on every payload row from row one; append-only
enforcement via `REVOKE UPDATE, DELETE` on the application role with
default-privilege inheritance (adopt Dispatch migrations 0002/0006 pattern
verbatim, including the derived-table exemption-by-name license); per-person
DEK envelope-encryption plumbing for the payload plane; mechanical checks
adapted from Dispatch (plan-graph, migration-numbers, decisions-index,
schema-grep banning capability-score columns on fact tables); Dispatch
decision-50 scale rule adopted as a review question.

Acceptance:
- AC-F1 (mechanical): a test proves the application role cannot UPDATE or
  DELETE any spine table, and that a newly created table inherits the
  restriction with no manual step.
- AC-F2 (mechanical): CI replays the migration chain from empty twice and
  diffs generated types against the live schema.
- AC-F3: no spine column can hold readable personal data — enforced by the
  schema lint that blocks non-approved column types/names in spine
  migrations.
- AC-F4: every payload table carries `residency_region` NOT NULL.
