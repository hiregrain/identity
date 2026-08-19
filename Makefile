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

.PHONY: check check-red check-red-db metadata install lint fmt-check go-check ts-check db-up db-reset migrate migrate-verify typegen typegen-check append-only db-down

check: metadata install lint go-check db-up migrate-verify typegen-check append-only ts-check
	$(COMPOSE) down
	@echo "check: green"

# Repo-metadata checks: validate files, need no database.
metadata:
	node checks/frontmatter.mjs plans
	node checks/migration-numbers.mjs
	node checks/serving-credentials.mjs
	node checks/cross-schema-queries.mjs

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

db-down:
	$(COMPOSE) down

# Red paths: prove each enforcement fails when pointed at a planted
# violation, without touching the tree the green path checks. No database
# is booted anywhere near these; the database-dependent red path is
# check-red-db below.
check-red:
	@echo "red path 1: broken plan file fails the metadata check (no database)"
	! node checks/frontmatter.mjs test/fixtures/redpath/plans
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
	@echo "check-red-db: planted violations fail as required and the databases are left as found"
