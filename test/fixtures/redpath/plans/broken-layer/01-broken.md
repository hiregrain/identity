---
id: broken-layer/01
type: task
status: shipped
depends_on: []
evidence: []
---

# Broken plan fixture

Red-path fixture: `status: shipped` is outside the ORDER.md vocabulary and
the task fields `layer`, `satisfies`, and `verified_by` are missing.
`make check-red` points `checks/frontmatter.mjs` at this tree and asserts
it fails, before any database exists in the environment.
