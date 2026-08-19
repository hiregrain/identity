# Single-command check pipeline (foundation/01). Mirrors the CI dependency
# graph: repo-metadata checks before any database, then db up -> migrate,
# then the Go and TS suites. Runs entirely against local containers; no
# cloud credentials exist or are required.

COMPOSE := docker compose
PSQL := $(COMPOSE) exec -T postgres psql -v ON_ERROR_STOP=1 -U identity -d identity

.PHONY: check check-red metadata install lint fmt-check go-check ts-check db-up migrate db-down

check: metadata install lint go-check db-up migrate ts-check
	$(COMPOSE) down
	@echo "check: green"

# Repo-metadata checks: validate files, need no database.
metadata:
	node checks/frontmatter.mjs plans

install:
	pnpm install --frozen-lockfile

fmt-check:
	@unformatted="$$(gofmt -l core)"; \
	if [ -n "$$unformatted" ]; then echo "gofmt needed on:"; echo "$$unformatted"; exit 1; fi

lint: fmt-check
	pnpm exec prettier --check "checks/**/*.mjs" "eslint.config.mjs" "surfaces/**/*.{ts,tsx,js,json}" --no-error-on-unmatched-pattern
	pnpm exec eslint .

go-check:
	cd core && go vet ./... && go test ./...

# workspace-scripts first: `pnpm -r run` silently skips packages without
# the script, so the check fails any package missing typecheck/test and
# states explicitly when zero packages matched (allowed while surfaces/
# is an empty seed).
ts-check:
	node checks/workspace-scripts.mjs
	pnpm -r run typecheck
	pnpm -r run test

db-up:
	$(COMPOSE) up -d --wait

# Minimal ordered apply; the real runner with its bookkeeping table is
# foundation/02. The chain is empty until 02's first migration lands.
migrate:
	@applied=0; \
	for f in db/migrations/*.sql; do \
		[ -e "$$f" ] || continue; \
		echo "applying $$f"; \
		$(PSQL) -f - < "$$f" || exit 1; \
		applied=$$((applied + 1)); \
	done; \
	echo "migrate: applied $$applied migration(s)"

db-down:
	$(COMPOSE) down

# Red paths: prove each enforcement fails when pointed at a planted
# violation, without touching the tree the green path checks. No database
# is booted anywhere near these.
check-red:
	@echo "red path 1: broken plan file fails the metadata check (no database)"
	! node checks/frontmatter.mjs test/fixtures/redpath/plans
	@echo "red path 2: misformatted Go file fails gofmt"
	@unformatted="$$(gofmt -l test/fixtures/redpath/go)"; \
	if [ -z "$$unformatted" ]; then echo "fixture unexpectedly clean"; exit 1; fi; \
	echo "flagged: $$unformatted"
	@echo "red path 3: TS type error fails tsc"
	! pnpm exec tsc -p test/fixtures/redpath/ts
	@echo "check-red: all red paths fail as required"
