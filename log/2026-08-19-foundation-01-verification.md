# foundation/01: clean-context verification

- Task: `foundation/01` (plans/foundation/01-repo-scaffold-and-ci.md)
- Head SHA verified: `01aacc053ad4f5672ba63c5ddd7946ecd3bf26b2` (PR #1, branch `task/foundation-01`)
- Verifier: clean-context session, 2026-08-19. Inputs: the task file, the PR
  diff, plans/ORDER.md. Environment: fresh clone into an isolated scratch
  directory; `env` grep for AWS/GCP/Azure/Cloudflare/Postgres/D1 variables
  returned nothing, no cloud credentials present.
- Verdict: **PASS**

## Criterion 1: fresh clone → single check command green

Ran `make check` on the fresh clone at the head SHA. Full pipeline executed:
metadata check → `pnpm install --frozen-lockfile` → gofmt/prettier/eslint →
`go vet`/`go test` → `docker compose up -d --wait` (local Postgres 18, host
port 5433) → migrate (`applied 0 migration(s)` on the empty chain) → pnpm
typecheck/test → `docker compose down`. Terminal output `check: green`,
exit 0. Only local containers involved. CI at the same SHA: all seven jobs
pass, including the `all stages green` fan-in
(actions run 32296444103).

## Criterion 2: red paths proven by excluded fixtures

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
eslint's ignore list, no normal build sees them; the tree stays green
(criterion 1's run proves it).

## Criterion 3: repo-metadata checks fail before any database

- The broken-plan check ran with zero database containers up
  (`docker compose ps -q | wc -l` → 0 at the time of the run) and needs
  only Node.
- CI job graph inspected in `.github/workflows/ci.yml`: the `metadata` job
  has no service container and no Docker step, and `db-migrate` declares
  `needs: [metadata]`, metadata strictly precedes any database boot. The
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

## Delta re-verification: review-fix head

PR #1 gained one review-fix commit after the pass above; the evidence now
cites the head that merges.

- New head SHA verified: `57b7adb35baecae4e3ba06faa988d632a1022323`
  (`fix(foundation/01): review findings — pin actions, loopback db,
  honest ts stage`).
- Delta contents, confirmed exhaustive by diffing `01aacc0..57b7adb`:
  (1) every CI action pinned to a commit SHA with the release tag in a
  comment; (2) docker-compose port bound to `127.0.0.1:5433`; (3) new
  `checks/workspace-scripts.mjs` wired as the first step of
  `make ts-check`; (4) a workflow header comment stating that
  `needs: [db-migrate]` is ordering only, not a data dependency. Nothing
  else in the delta, no scope creep.
- All four pinned SHAs verified independently against the GitHub API:
  `actions/checkout@11d5960a…` = v4.4.0, `actions/setup-node@49933ea…` =
  v4.4.0, `actions/setup-go@40f1582…` = v5.6.0,
  `pnpm/action-setup@fc06bc1…` = v4.4.0, each SHA is exactly the commit
  its claimed tag points at.
- Re-runs on a fresh clone at the new head: `make check` exit 0
  (`check: green`), with the new zero-package statement observed:
  `workspace-scripts: zero workspace packages matched (surfaces/ is an
  empty seed; allowed)`. `make check-red` exit 0, all three red paths
  fail as before. CI at the new head: all seven jobs pass
  (actions run 32297414443).
- Planted-package test: a temporary `surfaces/tmp-verify-pkg/package.json`
  with a `test` script but no `typecheck` made
  `node checks/workspace-scripts.mjs` exit 1 with the expected FAIL line;
  removed, the check returned to the zero-package pass and the tree was
  left clean.
- Noted deviation, accepted by review: the fix commit uses type `fix`
  where ORDER.md's vocabulary would arguably say `chore` (`fix` corrects
  a verified defect; these were review findings). The commit is pushed;
  evidence cites SHAs, so it is accepted rather than rewritten.
- Verdict: **PASS** at `57b7adb35baecae4e3ba06faa988d632a1022323`.
