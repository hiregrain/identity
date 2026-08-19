# foundation/02 — clean-context verification

- Task: `foundation/02` — Migration harness and type generation
- Verifier: clean-context session, 2026-08-19
- Head SHA verified: `1db47f577163b8f3b78683197e78a58a67c5b4d0` (PR #2,
  branch `task/foundation-02`)
- Method: fresh clone, no cloud credentials in the environment, every
  mechanical criterion re-run against local containers. The implementer's
  transcripts were not read; inputs were the task file, the layer file,
  ORDER.md, the diff, and the PR body.

## Outside check

Both databases reset from empty (`docker compose down && up`, no volumes),
both chains replayed twice via `make migrate-verify`: first replay applied
`0001-migration-infrastructure` to each plane, second replay reported
`applied 0 migration(s)` on both, and `pg_dump --schema-only
--restrict-key=dump` dumps were byte-identical across the no-op replay and
across an independent from-empty replay. Dumps confirmed non-vacuous
(schema_migrations present). `node db/typegen.mjs --check` exited 0 against
the migrated schemas. **Pass.**

## Criteria

1. **Both chains replay from empty deterministically; second replay is a
   no-op diff.** `make migrate-verify` exited 0 with the dump-diff
   mechanism above. **Pass.**
2. **Duplicate number across chains fails the numbering check
   (mechanical).** `node checks/migration-numbers.mjs` green on the real
   tree (exit 0); exit 1 on the red-path fixture
   (`test/fixtures/redpath/migrations`, number 0002 in both chains); and
   exit 1 on a verifier-planted duplicate outside the fixture
   (`db/migrations/payload/0001-verifier-duplicate.sql` against the landed
   0001), naming both files. Planted file removed; check green again.
   **Pass.**
3. **Types separately namespaced per plane; a payload type cannot satisfy
   a spine-typed parameter (mechanical).** Go:
   `TestPayloadTypeCannotSatisfySpineParameter` passes (`go test -v`, PASS);
   a verifier-written scratch file passing
   `payload.SchemaMigrationsRow` to a spine-typed parameter fails
   `go build` ("cannot use p ... as spine.SchemaMigrationsRow value").
   TS: `tsc -p db/tsconfig.json` green including the `@ts-expect-error`
   assertion in `db/plane-separation.ts`; a verifier-written scratch file
   making the same cross-plane call fails tsc with TS2345 (missing
   `[spinePlane]` brand). Both probes removed; builds green again.
   **Pass.**
4. **Editing a table without regenerating types fails CI (mechanical).**
   Verifier's own alteration (not the fixture's):
   `ALTER TABLE schema_migrations ADD COLUMN verifier_note text` on the
   payload database made `db/typegen.mjs --check` exit 1 naming
   `core/gen/payload/payload.go` and `db/gen/payload.ts`; after
   `DROP COLUMN`, exit 0. The shipped red path (`make check-red-db`,
   planted `planted_drift` table on spine) also exited 0 having asserted
   the failure and the recovery. **Pass.**

## Naming and pipeline

- Every migration file matches `NNNN-<kebab-noun-phrase>.sql` naming what
  exists after: `0001-migration-infrastructure.sql` (plus grammar-valid
  red-path fixtures). Enforced mechanically by `checks/migration-numbers.mjs`.
- `make check` end-to-end: exit 0 ("check: green"). `make check-red`:
  exit 0, all four red paths fail as required. CI on the head SHA: all
  seven jobs green.

## Judgment calls reviewed

All eight PR-body judgment calls were read against the task and layer:
the plane-agnostic 0001 root file, two Postgres containers replacing
foundation/01's single service (consistent with the layer's physical-split
language and decision 011; a declared deviation, not hidden), psql via
compose instead of a driver, dependency-free in-repo typegen, `db/gen`
outside the pnpm workspace, self-gofmt-aligned Go output (confirmed:
`gofmt -l` clean), `pg_dump --restrict-key` pinning, and the
database-dependent red path living in `check-red-db` rather than
`check-red`. No scope creep found: every file in the diff traces to a
scope item or a declared judgment call.

## Verdict

**PASS.** `status: done` and `verified_by` written by this verifier.
