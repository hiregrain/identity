---
id: foundation/01
type: task
status: ready
depends_on: []
evidence: []
verified_by: null
---

# Repo scaffold and CI

## Objective

The monorepo skeleton and the check pipeline every later task lands into.

## Scope

- Layout: `core/` (Go module — kernel and services), `surfaces/` (TS
  workspace — worker surface, console, public web), `contract/`
  (language-neutral schema + vectors; empty seed), `db/migrations/`,
  `checks/`, `test/`.
- Toolchains pinned: Go (version file), pnpm + Node (packageManager
  field), one `docker-compose.yml` for local Postgres (no volume,
  Dispatch pattern).
- CI (GitHub Actions): `db up → migrate → typegen --check → go vet/test →
  pnpm typecheck/test → node checks/run.mjs`. All stages required.
- Pre-commit: gofmt + eslint/prettier config, enforced in CI not hooks.
- Note: if the T1 spike inverts D2 before this merges, `core/` becomes TS
  per the pre-committed rule; the layout survives either way.

## Acceptance

- AC: fresh clone → `make check` (or equivalent single command) passes
  green on an empty schema, locally and in CI.
- AC: a deliberately misformatted Go file and a TS type error each fail
  CI.

## Outside check

Verifier runs the single check command on a fresh clone of the PR head
and confirms both red-path cases fail.
