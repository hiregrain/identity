# foundation/01 — clean-context verification

- Task: `foundation/01` (plans/foundation/01-repo-scaffold-and-ci.md)
- Head SHA verified: `01aacc053ad4f5672ba63c5ddd7946ecd3bf26b2` (PR #1, branch `task/foundation-01`)
- Verifier: clean-context session, 2026-08-19. Inputs: the task file, the PR
  diff, plans/ORDER.md. Environment: fresh clone into an isolated scratch
  directory; `env` grep for AWS/GCP/Azure/Cloudflare/Postgres/D1 variables
  returned nothing — no cloud credentials present.
- Verdict: **PASS**

## Criterion 1 — fresh clone → single check command green

Ran `make check` on the fresh clone at the head SHA. Full pipeline executed:
metadata check → `pnpm install --frozen-lockfile` → gofmt/prettier/eslint →
`go vet`/`go test` → `docker compose up -d --wait` (local Postgres 18, host
port 5433) → migrate (`applied 0 migration(s)` on the empty chain) → pnpm
typecheck/test → `docker compose down`. Terminal output `check: green`,
exit 0. Only local containers involved. CI at the same SHA: all seven jobs
pass, including the `all stages green` fan-in
(actions run 32296444103).

## Criterion 2 — red paths proven by excluded fixtures

Ran `make check-red` (exit 0, meaning every red path failed as required),
then each command individually:

- `node checks/frontmatter.mjs test/fixtures/redpath/plans` → exit 1, four
  FAIL lines on the broken plan fixture (status `shipped` outside
  vocabulary, missing `verified_by`, `layer`, `satisfies`).
- `gofmt -l test/fixtures/redpath/go` → lists `bad_format.go` (non-empty =
  fail condition).
- `pnpm exec tsc -p test/fixtures/redpath/ts` → exit 2, `error TS2322`.

Fixtures live under `test/fixtures/redpath/`, outside the `core/` Go module,
outside the pnpm workspace glob (`surfaces/*`), outside `plans/`, and inside
eslint's ignore list — no normal build sees them; the tree stays green
(criterion 1's run proves it).

## Criterion 3 — repo-metadata checks fail before any database

- The broken-plan check ran with zero database containers up
  (`docker compose ps -q | wc -l` → 0 at the time of the run) and needs
  only Node.
- CI job graph inspected in `.github/workflows/ci.yml`: the `metadata` job
  has no service container and no Docker step, and `db-migrate` declares
  `needs: [metadata]` — metadata strictly precedes any database boot. The
  `red-paths` job, which runs the broken-plan fixture, contains no database
  anywhere in its steps.

## Judgment calls

All seven declared calls in the PR body reviewed against the spec; each is
a legitimate deviation with its rationale holding (later-task CI stages
absent rather than stubbed; minimal migrate and frontmatter check owned by
foundation/02 and /06; Go pin in `core/go.mod` consumed by CI's
`go-version-file`; pnpm root at repo root; host port 5433; `all-green`
fan-in expressing "all stages required"). No scope creep found: every file
in the diff maps to a scope item. `contract/` already existed on `main`,
so its absence from the diff is not a gap.
