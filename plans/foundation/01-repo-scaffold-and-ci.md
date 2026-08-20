---
id: foundation/01
type: task
layer: foundation
satisfies: []
status: done
depends_on: []
evidence: ["log:log/2026-08-19-foundation-01-verification.md", "diff:PR #1 @ 57b7adb35baecae4e3ba06faa988d632a1022323"]
verified_by: clean-context-verifier@2026-08-19
---

# Repo scaffold and CI

## Objective

The monorepo skeleton and the check pipeline every later task lands into.

## Scope

- Layout: `core/` (Go module, kernel and services), `surfaces/` (TS
  workspace, worker surface, console, public web), `contract/`
  (language-neutral schema + vectors; empty seed), `db/migrations/`,
  `checks/`, `test/`.
- Toolchains pinned: Go (version file), pnpm + Node (packageManager
  field), one `docker-compose.yml` for local Postgres (no volume,
  Dispatch pattern).
- CI (GitHub Actions) as a **dependency graph, not a linear slogan**:
  repo-metadata checks (plan frontmatter, plan graph, migration numbering,
  decisions index) run **before** any database boots, because they validate
  files and need no schema; then `db up → migrate → typegen --check →
  go vet/test → pnpm typecheck/test → schema-dependent checks`. Ordering by
  what each stage actually needs, so a bad plan file fails in seconds
  instead of after a database spins up. All stages required.
- Pre-commit: gofmt + eslint/prettier config, enforced in CI not hooks.
- Local Postgres is Docker Compose; **managed Postgres (D1) is not part of
  this task and `make check` never requires it.** The single check command
  runs entirely against local containers. A fresh clone has no cloud
  credentials, and conflating local with managed is how "fresh clone works"
  becomes false for a new contributor.

## Acceptance

- AC: fresh clone → `make check` (or equivalent single command) passes
  green on an empty schema, locally and in CI.
- AC (mechanical): the red paths are proven by **fixtures under a test
  directory excluded from normal builds**: a misformatted Go file and a TS
  type error the check pipeline is pointed at deliberately. Committing
  genuinely broken files to the tree to prove CI catches them would make
  the tree permanently red.
- AC (mechanical): repo-metadata checks run and can fail before any
  database starts, proven by pointing CI at a broken plan file with the
  database stage disabled.

## Outside check

Verifier runs the single check command on a fresh clone of the PR head
with no cloud credentials present, confirms both red-path fixtures fail,
and confirms a broken plan file fails before the database stage runs.
