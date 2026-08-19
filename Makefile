# Single-command check pipeline (foundation/01; db stages foundation/02).
# Mirrors the CI dependency graph: repo-metadata checks before any
# database, then the two plane databases up -> replay-verified migrations
# -> typegen check, then the Go and TS suites. Runs entirely against local
# containers; no cloud credentials exist or are required.

COMPOSE := docker compose
PSQL_SPINE := $(COMPOSE) exec -T spine psql -v ON_ERROR_STOP=1 -U identity -d spine
PSQL_PAYLOAD := $(COMPOSE) exec -T payload psql -v ON_ERROR_STOP=1 -U identity -d payload
# --restrict-key pins the token pg_dump 18 otherwise randomizes per run,
# so two dumps of one schema are byte-identical.
DUMP_SPINE := $(COMPOSE) exec -T spine pg_dump --schema-only --restrict-key=dump -U identity spine
DUMP_PAYLOAD := $(COMPOSE) exec -T payload pg_dump --schema-only --restrict-key=dump -U identity payload

.PHONY: check check-red check-red-db metadata install lint fmt-check go-check ts-check db-up db-reset migrate migrate-verify typegen typegen-check append-only spine-schema payload-residency scored-columns two-plane-split envelope-test cross-plane-constructs cross-plane-outbox deletion-test db-down

check: metadata install lint go-check db-up migrate-verify typegen-check append-only spine-schema payload-residency scored-columns two-plane-split envelope-test cross-plane-constructs cross-plane-outbox deletion-test ts-check
	$(COMPOSE) down
	@echo "check: green"

# Repo-metadata checks: validate files, need no database. The runner
# (checks/run.mjs, foundation/06) owns the group's membership and prints
# the workable frontier after a green run.
metadata:
	node checks/run.mjs --metadata

install:
	pnpm install --frozen-lockfile

fmt-check:
	@unformatted="$$(gofmt -l core)"; \
	if [ -n "$$unformatted" ]; then echo "gofmt needed on:"; echo "$$unformatted"; exit 1; fi

lint: fmt-check
	pnpm exec prettier --check "checks/**/*.mjs" "db/**/*.mjs" "db/**/*.ts" "db/*.json" "test/*.mjs" "eslint.config.mjs" "surfaces/**/*.{ts,tsx,js,json}" --no-error-on-unmatched-pattern
	pnpm exec eslint .

go-check:
	cd core && go vet ./... && go test ./...

# workspace-scripts first: `pnpm -r run` silently skips packages without
# the script, so the check fails any package missing typecheck/test and
# states explicitly when zero packages matched (allowed while surfaces/
# is an empty seed). The db tsconfig covers the generated plane types and
# the plane-separation test, which live outside the workspace.
ts-check:
	node checks/workspace-scripts.mjs
	pnpm exec tsc -p db/tsconfig.json
	pnpm -r run typecheck
	pnpm -r run test

db-up:
	$(COMPOSE) up -d --wait

# No volumes are defined, so down && up is a from-empty pair of databases.
db-reset:
	$(COMPOSE) down
	$(COMPOSE) up -d --wait

# The migration runner (db/migrate.mjs): ordered apply recorded in each
# database's schema_migrations, executing as the table owner.
migrate:
	node db/migrate.mjs spine
	node db/migrate.mjs payload

# Layer criterion 2's mechanism: both chains replay from empty
# deterministically, and a second replay is a no-op — proven by schema
# dumps, not by trusting the runner's own output.
migrate-verify:
	@dumps="$$(mktemp -d)"; \
	$(MAKE) db-reset && $(MAKE) migrate && \
	$(DUMP_SPINE) > "$$dumps/spine-first.sql" && \
	$(DUMP_PAYLOAD) > "$$dumps/payload-first.sql" && \
	second="$$($(MAKE) migrate)" && echo "$$second" && \
	echo "$$second" | grep -q "migrate(spine): applied 0 migration(s)" && \
	echo "$$second" | grep -q "migrate(payload): applied 0 migration(s)" && \
	$(DUMP_SPINE) > "$$dumps/spine-second.sql" && \
	$(DUMP_PAYLOAD) > "$$dumps/payload-second.sql" && \
	diff "$$dumps/spine-first.sql" "$$dumps/spine-second.sql" && \
	diff "$$dumps/payload-first.sql" "$$dumps/payload-second.sql" && \
	$(MAKE) db-reset && $(MAKE) migrate && \
	$(DUMP_SPINE) > "$$dumps/spine-replay.sql" && \
	$(DUMP_PAYLOAD) > "$$dumps/payload-replay.sql" && \
	diff "$$dumps/spine-first.sql" "$$dumps/spine-replay.sql" && \
	diff "$$dumps/payload-first.sql" "$$dumps/payload-replay.sql" && \
	rm -rf "$$dumps" && \
	echo "migrate-verify: second replay is a no-op and an independent replay from empty produces an identical schema"

typegen:
	node db/typegen.mjs

typegen-check:
	node db/typegen.mjs --check

# The standing append-only proof (foundation/03): runs against both
# migrated planes; see test/append-only.test.mjs for what it asserts.
append-only:
	node test/append-only.test.mjs

# The spine schema lint (foundation/04): every live spine column is an
# allow-listed domain (db/spine-allow-list.json) or a declared exception
# whose migration carries the five-question justification block.
spine-schema:
	node checks/spine-schema.mjs

# The residency check (foundation/04): every payload table carries
# residency_region NOT NULL, and no row disagrees with the database's
# declared region (database authoritative, column checked).
payload-residency:
	node checks/payload-residency.mjs

# The schema-grep check (foundation/06): no fact-table column on either
# plane stores a capability, tier, trajectory, reliability, trust, or
# weighting judgment about a person (decision 025 withdrew the last
# licensed use).
scored-columns:
	node checks/scored-columns.mjs

# The physical-split proof (foundation/04): distinct clusters, no
# spanning transaction, a role catalog per plane.
two-plane-split:
	node test/two-plane-split.test.mjs

# The envelope acceptance suite (foundation/05): runs against the live
# payload plane once per key provider — the provider swap is
# configuration only (GRAIN_KEY_PROVIDER) and the suite must pass under
# both (criterion 6). Build tag db keeps these tests out of the
# database-less go-check job; -count=1 defeats the test cache, since the
# database is state the cache cannot see.
envelope-test:
	cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 ./envelope/...
	cd core && GRAIN_KEY_PROVIDER=stub-kms go test -tags db -count=1 ./envelope/...

# The FDW/dblink ban, live half (foundation/07): no cross-database
# construct in either live database. The file half runs in `metadata`.
cross-plane-constructs:
	node checks/cross-plane-constructs.mjs --live

# The cross-plane write consistency scenarios (foundation/07): the
# spine-first outbox worker driven through its kill points, manual
# replay, the reconciler (its documented alert threshold is 60 seconds;
# the scenarios pass -threshold 0 to make stragglers immediate), and
# the stalled-payload acknowledgment proof. Builds core/cmd/outbox, so
# it needs Go as well as both migrated planes.
cross-plane-outbox:
	node test/cross-plane-outbox.test.mjs

# The deletion-mechanics acceptance suite (foundation/08): a real
# pg_dump backup taken pre-deletion, restored (db/backup.mjs and
# db/restore.mjs, driven exactly as an operator runs them), the restore
# gate refusing traffic, the journal replay opening it, the purge role's
# licensed DELETE and its audit trail. Build tag db like the envelope
# suite; -count=1 because the database is state the test cache cannot
# see. One provider run: everything this suite proves — journal, gate,
# purge, replay — is provider-independent registry and grant state, and
# the provider swap is already proven both ways by `envelope-test`.
# NOTE: the restore scenario recreates the payload container mid-run;
# the suite leaves both planes migrated and consistent on the green
# path, which is why this target runs last in the database stage.
deletion-test:
	cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 ./deletion/...

db-down:
	$(COMPOSE) down

# Red paths: prove each enforcement fails when pointed at a planted
# violation, without touching the tree the green path checks. No database
# is booted anywhere near these; the database-dependent red path is
# check-red-db below.
check-red:
	@echo "red path 1: broken plan file fails the metadata check (no database)"
	! node checks/frontmatter.mjs test/fixtures/redpath/plans > /tmp/frontmatter-red.out 2>&1
	@echo "red path 1b: every foundation/06 validation is individually proven to fire (an aggregate exit code proves only the oldest rule)"
	grep -F 'status "shipped" is outside the ORDER.md vocabulary' /tmp/frontmatter-red.out
	grep -F 'id "broken-layer/99" does not match its path-derived id' /tmp/frontmatter-red.out
	grep -F 'layer "other-layer" does not match its directory' /tmp/frontmatter-red.out
	grep -F 'field "priority" is outside the ORDER.md vocabulary for a task' /tmp/frontmatter-red.out
	grep -F 'depends_on entry "not a ref" is not a <layer>/<NN> reference' /tmp/frontmatter-red.out
	grep -F 'satisfies entry "first" is not a criterion number' /tmp/frontmatter-red.out
	grep -F 'evidence entry "screenshot:proof.png" is not <kind>:<ref>' /tmp/frontmatter-red.out
	grep -F 'verified_by "someone, probably" is neither null nor' /tmp/frontmatter-red.out
	grep -F 'status done with empty evidence' /tmp/frontmatter-red.out
	grep -F 'status done with verified_by null' /tmp/frontmatter-red.out
	rm /tmp/frontmatter-red.out
	@echo "red path 2: misformatted Go file fails gofmt"
	@unformatted="$$(gofmt -l test/fixtures/redpath/go)"; \
	if [ -z "$$unformatted" ]; then echo "fixture unexpectedly clean"; exit 1; fi; \
	echo "flagged: $$unformatted"
	@echo "red path 3: TS type error fails tsc"
	! pnpm exec tsc -p test/fixtures/redpath/ts
	@echo "red path 4: duplicate migration number across chains fails the numbering check (no database)"
	! node checks/migration-numbers.mjs test/fixtures/redpath/migrations test/fixtures/redpath/plans
	@echo "red path 5: owner credential planted in a serving tree fails the credentials check (no database)"
	! node checks/serving-credentials.mjs test/fixtures/redpath/serving
	@echo "red path 6: planted query touching both members of a declared incompatible schema pair fails the cross-schema lint (no database)"
	! node checks/cross-schema-queries.mjs test/fixtures/redpath/cross-schema/pairs.json test/fixtures/redpath/cross-schema/queries
	@echo "red path 7: dependency cycles and a dangling reference fail the plan-graph check (no database)"
	! node checks/plan-graph.mjs test/fixtures/redpath/plan-graph/plans
	@echo "red path 7b: the plan-graph frontier is computed correctly for the synthetic fixture tree (workable and blocked both asserted)"
	node checks/plan-graph.mjs test/fixtures/frontier/plans > /tmp/frontier-fixture.out
	grep -qx "  alpha/02" /tmp/frontier-fixture.out
	grep -qx "  beta/01" /tmp/frontier-fixture.out
	grep -q "^blocked: alpha/03 — alpha/02 is ready" /tmp/frontier-fixture.out
	grep -q "^blocked: beta/02 — epsilon/01 is unauthored" /tmp/frontier-fixture.out
	grep -q "^blocked: delta/01 — layer gate: alpha is not done" /tmp/frontier-fixture.out
	! grep -qx "  delta/01" /tmp/frontier-fixture.out
	rm /tmp/frontier-fixture.out
	@echo "red path 8: a duplicate entry number, an unmarked gap, and a contradicted never-assigned marker each fail the decisions-index check; a marked gap passes (no database)"
	! node checks/decisions-index.mjs test/fixtures/redpath/decisions/duplicate.md
	! node checks/decisions-index.mjs test/fixtures/redpath/decisions/unmarked-gap.md
	! node checks/decisions-index.mjs test/fixtures/redpath/decisions/contradicted-marker.md
	node checks/decisions-index.mjs test/fixtures/greenpath/decisions-marked-gap.md
	@echo "red path 9: a migration referencing an object a higher-numbered migration creates fails the ordering check (no database)"
	! node checks/migration-order.mjs test/fixtures/redpath/migration-order
	@echo "red path 10: a labeled blockquote that drifted from its source fails the verbatim check; an exact copy with a marked splice passes (no database)"
	! node checks/verbatim-copies.mjs test/fixtures/redpath/verbatim
	node checks/verbatim-copies.mjs test/fixtures/greenpath/verbatim
	@echo "red path 11: a hand-written count adjacent to an enumerable structure fails the counts check (no database)"
	! node checks/counts.mjs test/fixtures/redpath/counts
	@echo "red path 12: a planted FDW migration fails the cross-plane construct check (no database)"
	! node checks/cross-plane-constructs.mjs test/fixtures/redpath/cross-plane-constructs
	@echo "red path 13: deletion copy whose day counts drift from the retention config fails the disclosure check (no database)"
	! node checks/deletion-copy.mjs test/fixtures/redpath/deletion-copy/copy.md test/fixtures/redpath/deletion-copy/policy.json
	@echo "check-red: all red paths fail as required"

# Database-dependent red path: a schema edit without regenerated types
# must fail typegen --check. Needs migrated databases (make db-up +
# migrate); plants a table, asserts the failure, drops it, and asserts
# the check is green again so the databases are left as found.
check-red-db:
	@echo "red path db: a table edited without regenerated types fails typegen --check"
	echo "CREATE TABLE planted_drift (id integer PRIMARY KEY);" | $(PSQL_SPINE) -f -
	! node db/typegen.mjs --check
	echo "DROP TABLE planted_drift;" | $(PSQL_SPINE) -f -
	node db/typegen.mjs --check
	@echo "red path db 2: an unenumerated UPDATE grant to the app role fails the append-only test"
	echo "GRANT UPDATE ON schema_migrations TO identity_app;" | $(PSQL_SPINE) -f -
	! node test/append-only.test.mjs
	echo "REVOKE UPDATE ON schema_migrations FROM identity_app;" | $(PSQL_SPINE) -f -
	@echo "red path db 2b: an unenumerated sequence UPDATE grant (setval) fails the append-only test"
	echo "CREATE SEQUENCE planted_seq; GRANT UPDATE ON SEQUENCE planted_seq TO identity_app;" | $(PSQL_SPINE) -f -
	! node test/append-only.test.mjs
	echo "DROP SEQUENCE planted_seq;" | $(PSQL_SPINE) -f -
	@echo "red path db 3: a SECURITY DEFINER function containing UPDATE fails the append-only test"
	echo "CREATE FUNCTION planted_definer() RETURNS void LANGUAGE sql SECURITY DEFINER AS 'UPDATE schema_migrations SET name = name';" | $(PSQL_PAYLOAD) -f -
	! node test/append-only.test.mjs
	echo "DROP FUNCTION planted_definer();" | $(PSQL_PAYLOAD) -f -
	node test/append-only.test.mjs
	@echo "red path db 4: a spine column of a type outside the allow-list fails the spine schema lint"
	echo "CREATE TABLE planted_spine (note text);" | $(PSQL_SPINE) -f -
	! node checks/spine-schema.mjs
	echo "DROP TABLE planted_spine;" | $(PSQL_SPINE) -f -
	@echo "red path db 5: an allow-listed exception column whose migration lacks the justification block fails the spine schema lint (and passes with the block present)"
	echo "CREATE TABLE planted_exception (blob bytea);" | $(PSQL_SPINE) -f -
	! node checks/spine-schema.mjs test/fixtures/redpath/spine-schema/allow-list.json db/migrations db/migrations/spine test/fixtures/redpath/spine-schema/without-justification
	@echo "red path db 5b: a justification block in the WRONG file (a decoy the declared migration field does not name) is not a match — the lint must still fail"
	! node checks/spine-schema.mjs test/fixtures/redpath/spine-schema/allow-list.json db/migrations db/migrations/spine test/fixtures/redpath/spine-schema/without-justification test/fixtures/redpath/spine-schema/decoy
	node checks/spine-schema.mjs test/fixtures/redpath/spine-schema/allow-list.json db/migrations db/migrations/spine test/fixtures/redpath/spine-schema/with-justification
	echo "DROP TABLE planted_exception;" | $(PSQL_SPINE) -f -
	node checks/spine-schema.mjs
	@echo "red path db 6: a payload table without residency_region fails the residency check"
	echo "CREATE TABLE planted_no_residency (id integer PRIMARY KEY);" | $(PSQL_PAYLOAD) -f -
	! node checks/payload-residency.mjs
	echo "DROP TABLE planted_no_residency;" | $(PSQL_PAYLOAD) -f -
	@echo "red path db 7: a row whose residency_region disagrees with its database fails the residency check"
	echo "INSERT INTO schema_migrations (number, name, residency_region) VALUES (9999, 'planted-disagreement', 'zz');" | $(PSQL_PAYLOAD) -f -
	! node checks/payload-residency.mjs
	echo "DELETE FROM schema_migrations WHERE number = 9999;" | $(PSQL_PAYLOAD) -f -
	node checks/payload-residency.mjs
	@echo "red path db 8: a planted column carrying a judgment token fails the scored-columns check on either plane"
	echo "CREATE TABLE planted_judgment (person_ref integer, trust_score integer, residency_region text NOT NULL DEFAULT 'us');" | $(PSQL_PAYLOAD) -f -
	! node checks/scored-columns.mjs
	echo "DROP TABLE planted_judgment;" | $(PSQL_PAYLOAD) -f -
	node checks/scored-columns.mjs
	@echo "green path db: the runner's --schema group and bare form both work while the databases are up, and the bare run prints the frontier exactly once"
	node checks/run.mjs --schema
	node checks/run.mjs > /tmp/run-bare.out
	test "$$(grep -c '^frontier (' /tmp/run-bare.out)" = "1"
	rm /tmp/run-bare.out
	@echo "red path db 9: a cross-database extension created live fails the cross-plane construct check"
	echo "CREATE EXTENSION postgres_fdw;" | $(PSQL_SPINE) -f -
	! node checks/cross-plane-constructs.mjs --live
	echo "DROP EXTENSION postgres_fdw;" | $(PSQL_SPINE) -f -
	@echo "red path db 9b: a foreign server on the OTHER plane also fails it (the catalog net, not just the extension list)"
	echo "CREATE EXTENSION postgres_fdw; CREATE SERVER planted_server FOREIGN DATA WRAPPER postgres_fdw;" | $(PSQL_PAYLOAD) -f -
	! node checks/cross-plane-constructs.mjs --live
	echo "DROP SERVER planted_server; DROP EXTENSION postgres_fdw;" | $(PSQL_PAYLOAD) -f -
	node checks/cross-plane-constructs.mjs --live
	@echo "red path db 10: a DELETE grant to the purge role on an unlicensed table fails the append-only standing proof"
	echo "GRANT DELETE ON restore_gate TO identity_purge;" | $(PSQL_PAYLOAD) -f -
	! node test/append-only.test.mjs
	echo "REVOKE DELETE ON restore_gate FROM identity_purge;" | $(PSQL_PAYLOAD) -f -
	node test/append-only.test.mjs
	@echo "check-red-db: planted violations fail as required and the databases are left as found"
