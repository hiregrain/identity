# foundation/05: clean-context verification

- Task: `plans/foundation/05-envelope-encryption-plumbing.md` (layer
  criterion foundation-7)
- PR: #5, branch `task/foundation-05`
- Head SHA verified: `e91daf58fa07b675a3a3752d20271f7ce7dc560a`
- Verifier: clean-context session, 2026-08-19. Fresh clone; no implementer
  transcripts consulted; no cloud credentials. CI at this SHA: all eight
  checks pass, including the new `envelope suite (both key providers)` job
  (run 32308259651).
- Verdict: **PASS**. Every mechanical criterion re-run green under both
  providers, every independent probe green, every judgment call sound.

## Scope check

Diff vs `origin/main` (merge-base `d5dcbe3`): `core/keys` (provider seam,
software + stub-KMS, conformance suite), `core/envelope` (read/write/destroy
path + tests), `db/migrations/payload/0005-dek-registry.sql`, typegen `uuid`
mapping + regenerated `core/gen/payload/payload.go` / `db/gen/payload.ts`,
additive Makefile target `envelope-test` and additive CI job. **No product
content table entered either migration chain.** The payload chain gained
only the DEK registry, the spine chain nothing; the tests exercise the path
against a harness-scoped table they create and drop as the owner role.
`core/go.mod` still declares zero dependencies. No file outside the task's
footprint. No scope creep found.

## Mechanical outcomes (re-run, not re-read)

All commands in a fresh clone at the head SHA. Host ports 5433/5434 were
held by a sibling session, so a verifier-local compose override dropped the
host bindings (foundation/04 verifier precedent; the whole pipeline speaks
`docker compose exec`, so the override touches nothing under test).

1. **`make check`** → green end to end, including `envelope-test` run twice:
   `GRAIN_KEY_PROVIDER=software go test -tags db ./envelope/...` → ok
   (30.6s) and `GRAIN_KEY_PROVIDER=stub-kms` → ok (61.6s).
2. **Criterion 1 (destroy closes every path, stronger than a grep):**
   `TestDestroyLeavesNothingReadable` green under both providers inside the
   suite runs above: read path fails closed (`ErrNoActiveDEK`), write path
   closed, registry-bypass provider `Unwrap` of the stored wrapped DEK
   fails (the crypto-shred), re-provision refused, content column set
   asserted exactly, all surfaced errors marker-free, package has no
   logging sink (`TestPackageHasNoLoggingSink`, also in the pure `go test`
   run), and the full-dump grep floor holds.
3. **Criterion 2 (subject-only keying, no second wrap):**
   `TestTwoPersonRowKeyedToSubjectAlone` green both providers; schema-level
   assertion of the registry's exact column set and both partial unique
   indexes.
4. **Criterion 3 (idempotent destroy; concurrent reads all-or-nothing):**
   `TestDestroyIdempotentAndSafeUnderConcurrentReads` green both providers,
   and re-run by the verifier with `-race -count=3` under both providers
   (software 55s, stub-kms 118s), no race, no partial plaintext, exactly
   one `destroyed` row after three destroys.
5. **Criterion 4 (alias closure):**
   `TestDestroyMergedPersonDestroysWholeClosure` green both providers:
   three-id synthetic closure, every alias unreadable, every wrapped DEK
   dead at the provider, one destroyed row each.
6. **Criterion 5 (one active DEK by constraint):**
   `TestOneActiveDEKEnforcedByConstraint` green, plus the verifier's own
   raw psql probe as `identity_app`: a second `created` row fails
   `duplicate key value violates unique constraint
   "dek_registry_one_created"`; a second `destroyed` row fails naming
   `dek_registry_one_destroyed`; `UPDATE` and `DELETE` on the registry as
   the app role fail `permission denied` (append-only posture inherited,
   no grants in 0005).
7. **Criterion 6 (provider swap by config only):** the suite passes under
   both `GRAIN_KEY_PROVIDER` values with no code change; verifier grep of
   all non-test Go source found provider names interpreted only in
   `keys.FromConfig` and read only via `Provider.Name()` into registry rows
   (the operational surface decision 017 allows), no business branch on
   provider identity.

## Independent probes (verifier's own, beyond the shipped tests)

- **Own-marker probe** (`TestVerifierProbeDestroyClosesEveryPath`, scratch
  test in the clone, run under both providers, green): provisioned two
  people, encrypted the verifier's own marker as subject A on a row naming
  counterparty B, confirmed B's key path cannot decrypt it even
  pre-destruction, destroyed A, then walked every public read/write path in
  `core/envelope`: `Decrypt`, `Encrypt`, `Provision`, provider-level
  `Unwrap` of the stored blob, each failed closed returning nil material;
  B's own key untouched. Full `pg_dump` of the payload plane contained the
  marker in none of plaintext, hex, or base64 forms.
- **Registry schema inspection**: exact column set
  `person_id, event, wrapped_dek, key_provider, recorded_at,
  residency_region`: one key column, one person column; a second wrap is
  unrepresentable, and the `CHECK ((event = 'created') = (wrapped_dek IS
  NOT NULL))` keeps key material off destruction rows.
- **Conformance suite sabotage test**: the suite runs against both in-repo
  providers in every plain `go test ./...`. Verifier temporarily broke the
  stub so `Unwrap` on a destroyed scope returned plaintext:
  `TestStubKMSConformance` failed immediately ("Unwrap succeeded after
  Destroy — destruction is not a crypto-shred"); reverted, green again. The
  suite would catch the failure mode it exists for.

## Judgment calls: assessed

- **No rotation path (at most one `created` row per person, ever): sound,
  as a conservative narrowing, not an over-constraint.** The spec's "at
  most one active DEK per person at any instant" would in principle admit a
  created→destroyed→created sequence; the schema forbids it forever. Three
  reasons this narrowing holds: (1) a partial unique index cannot express
  "created with no later destroyed" across rows, and the alternatives (a
  projection table, a trigger-maintained state) need an UPDATE-licensed
  writer foundation/03's rulings do not grant, correctly a raise, not a
  quiet exemption; (2) no decisions entry rules DEK rotation, and the only
  destroy-then-recreate sequence any current decision contemplates is
  deletion, where decision 014's never-reissue rule forbids re-keying the
  id anyway, so today a second `created` row has no legitimate meaning;
  (3) **the narrowing is undoable without violating append-only**: relaxing
  it is a later migration dropping/replacing an index, a schema change
  mutating no rows, and real DEK rotation would in any case require
  re-encrypting content (an UPDATE story) that would need its own decision
  regardless of this index. The constraint is not the hard part of a future
  rotation; the migration comment states all of this in place.
- **Destroy of a never-keyed person records a blocking `destroyed` row:
  sound.** Fail-closed: the row makes the id permanently unprovisionable
  (the provision SQL's `WHERE NOT EXISTS` refuses it, probe-confirmed),
  matching never-reissue; a silent no-op would leave a destroyed id able to
  acquire fresh key material later.
- **Alias closure as an input set: sound.** Merge machinery belongs to
  person-identity; the contract (complete closure, canonical id included,
  single-element set for unmerged people) is documented on
  `envelope.Destroy``envelope.Destroy` where the caller reads it. The residual risk, a
  caller passing a partial closure, is exactly the risk the documented
  contract names, and computing closures here would be scope creep into a
  layer that does not exist.
- **Querier seam with a psql test harness, no SQL driver: sound.**
  Adding core's first dependency is not this task's call; the seam's
  contract (args validated by shape before any SQL) is enforced:
  `validPersonID` regexp, hex-only bytea args, provider-name constants,
  and the harness's literal substitution independently refuses quotes,
  backslashes, and NUL outside the hex shape. Running the whole path as
  `identity_app` also proves the read/write path needs only SELECT and
  INSERT.
- Destroy ordering (registry row commits first, provider shred second,
  both halves idempotent, retry-forward): fail-closed in the correct
  direction, a crash between halves leaves reads already refusing.
- Additive Makefile/CI wiring, the typegen `uuid` mapping (one entry, with
  justification comment), and residency stamped from `database_residency`
  in the insert statements rather than a DEFAULT: all consistent with the
  standing patterns and rulings.

## Evidence

- CI: https://github.com/hiregrain/identity/actions/runs/32308259651
- Suite runs, probes, and raw psql outputs: this record; commands are
  reproducible from a fresh clone at the head SHA with
  `make db-up && make migrate && make envelope-test`.
