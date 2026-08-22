# person-identity/02: clean-context verification

- Task: `plans/person-identity/02-authentication.md` (`satisfies: []`; the
  task carries its own four acceptance bullets, numbered first through
  fourth by its Evidence section).
- PR: #19, branch `task/person-identity-02`.
- Head SHA verified: `0a8d68bf59145fb7f87460ee218cc9d4f73bfae5` (the
  implementation is `1ab5887`, "authentication and sessions"; the head
  adds only the plan file's evidence entries).
- Verifier: clean-context session, 2026-08-21. No implementer transcripts
  or notes consulted. Ran against the PR head in an isolated worktree,
  both planes booted from empty under the repo's own compose pair.
- Verdict: **PASS**. Every mechanical criterion re-run green, the
  adjudicated criterion judged pass, the Outside check run without a
  successful break.

## Preconditions (re-run, not re-read)

- `docker compose up -d --wait` then `node db/migrate.mjs spine` and
  `node db/migrate.mjs payload`: spine applied 6 migrations, payload
  applied 7 including `0037-authentication-and-sessions`.
- `cd core && go vet ./...`: clean.
- `cd core && go test ./...` (no db tag): every package `ok`, including
  `core/keys` (the provider conformance suite) and `core/person/auth`
  (the structural hygiene tests).
- `node checks/run.mjs --metadata`: exit 0. All repo-metadata checks
  green, including `unslop` (673 files, no banned pattern),
  `transport-seam` (48 Go files, no database invocation outside
  core/transport), `migration-numbers` (0037 globally unique),
  `migration-order`, `counts`, `serving-credentials`.
- `gofmt -l core`: clean. `pnpm exec eslint .`: clean.

## Criterion 1: both paths authenticate the same identity; a revoked session fails its next request (mechanical)

Command: `cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1
-timeout 30m -v ./person/auth`.

- `TestAuthBothPathsReachTheSameIdentity` PASS (23.21s): a real WebAuthn
  ceremony through a virtual authenticator and a delivered-code login both
  resolve to one `person_id` and to two distinct session ids.
- `TestAuthRevokedSessionFailsItsNextRequest` PASS (19.97s): for both
  paths, a token authenticates, is revoked, and then returns
  `ErrNoSession`; a second revoke is not an error; a stranger's revoke is
  `ErrNotYours` and writes nothing (re-authentication after the refusal
  still succeeds).

## Criterion 2: code endpoints resist enumeration (mechanical)

- `TestAuthCodeEndpointsResistEnumeration` PASS (28.54s): `RequestCode`
  returns nil and `SubmitCode` returns `ErrCodeRejected` alike for an
  address on an account and one on none; no challenge, attempt, or event
  row exists for a non-existent person; the two branches' five-sample
  means stay within `CodeUniformFloor / 8` and no sample overruns the
  floor.
- Verifier's own DB probe against the live payload plane after the whole
  suite: `auth_code_challenge`, `auth_event`, and `auth_code_attempt` each
  hold 0 rows for a person absent from `person_contact_channel`. Row
  absence holds independently of the test's own assertion.
- The timing floor is deferred at the top of both `RequestCode` and
  `SubmitCode`, so it covers every return path including the early
  `ErrAddressShape`. `ErrAddressShape` fires only for input that fails to
  canonicalize, which is offline-computable by the caller and is not an
  account-existence oracle.

## Criterion 3: a device with no passkey support completes login start-to-finish (adjudicated)

- `TestAuthLoginWithoutAPasskeyCompletesEndToEnd` PASS (9.63s): no
  credential enrolled and no ceremony run; `BeginPasskeyLogin` refuses
  with `ErrNoCredential`, then the account is reached by code, lists its
  own (empty) credential inventory and its one live code session, and
  signs out by revoking.
- Adjudication: the criterion is met. What would have failed it: any
  operation in the code-only flow returning an error, a credential
  appearing without a ceremony, or the code session not resolving to the
  signed-up person. None occurred.

## Criterion 4: routine operations from a code session are never blocked; the code path is a first-class equal path (mechanical)

- `TestAuthCodeSessionIsNeverBlocked` PASS (14.37s): every worker-facing
  operation the package exposes is run from a code session and a passkey
  session on one account and the two agree on every one.
- `TestNothingBranchesOnHowASessionWasAuthenticated` PASS: the package's
  own source carries no `==`/`!=` comparison and no switch case against
  `MethodPasskey` or `MethodCode`.
- Verifier's own source sweep: the only `Method`-constant comparisons in
  the package are in `_test.go` files asserting the recorded value, not in
  production paths. The serving SQL never filters or branches on `method`;
  `auth_session_live` gates on expiry and revocation alone. The `method`
  column is written for the worker's session list and read by nothing that
  decides what a session may do.

## Supporting tests in the suite (all PASS)

`TestAuthBothPathsIssueTheSameKindOfSession` (session rows from the two
paths are field-for-field identical but for the method column),
`TestAuthCredentialInventory` (multiple credentials per person; labels
sealed, no plaintext in the payload plane), `TestAuthCodeRateLimitAndLockout`
(request limit and per-challenge lockout enforced from rows, not a
counter), `TestAuthEventsAreRecorded` (closed-vocabulary append-only
trail), `TestTheCodeDefaultsHoldTogether`.

## Outside check

Run as written: authenticate via both paths, confirm routine operations
stay unblocked from a code session, revoke a session mid-flight, run the
enumeration probes. All are exercised by the acceptance suite above and
were re-run green. Additional adversarial probes attempted by the
verifier, none of which broke the implementation:

- Direct payload-plane query for auth rows owned by no person: 0 across
  all three tables.
- `address_lookup` inspection: every `person_contact_channel` row carries
  a 32-byte value (HMAC-SHA256 output width) and the column is opaque
  binary that does not UTF-8-decode to the address, so it is the keyed
  index decision 089 and decision 020 require, not a recoverable
  plaintext. The key lives in the provider (in memory for the software
  provider, KMS in production), never in a database column.
- Source and SQL sweep for method-based authorization: none found.

## Scrutiny items raised with the task (assessed, not blocking)

- **All auth schema on the payload plane (migration 0037).** Assessed
  defensible and in fact required. Every datum here (credentials,
  sessions, revocations, one-time codes, attempt rows, auth events, and
  the `address_lookup` index) is personal or person-derived activity that
  must die with the person under the purge role (foundation/08). The spine
  is append-only and never deleted, including tombstoned persons
  (`0010-person-core`), so placing any of these on it would make
  authentication material and an address-derived re-identification handle
  survive account deletion, contrary to decision 014 and to
  `0010-person-core`'s explicit "nothing else." No auth datum belongs on
  the spine. Decision 086's sentence "auth needs schema on both planes"
  sits inside a migrations-bookkeeping paragraph and reads as a
  description of the person-identity auth area (whose spine half is
  already `0010-person-core` from task 01), not a ruling that task 02 add
  a spine migration. The implementer flagged the tension rather than
  choosing silently, which is what the fence requires; a founder who meant
  that sentence as a plane ruling can say so, but the placement as built is
  correct.
- **`go-webauthn`** is the single new direct dependency,
  `github.com/go-webauthn/webauthn v0.17.4`, version-pinned, with its
  transitive deps recorded in `go.sum`, exactly as decision 089 licenses.
- **`keys.Provider.Mac`** is added to the interface, implemented by both
  in-repo providers, and covered by conformance checks 10-13 (determinism,
  scope binding, message binding, code does not carry the message, and
  refusal under a destroyed scope). Both providers pass the suite.
- **`address_lookup`** is built per decision 089: keyed HMAC of the
  canonicalized address under `ScopeChannelLookup`, the population-wide
  scope, key held in the provider and never in the database. Confirmed at
  the DB level above.
- **Enumeration resistance** holds on both axes: timing (the floor, run
  green) and row-absence (0 orphan rows, verifier-probed).
- **Nothing branches on authentication method**, structurally and in SQL.

## Scope

The diff is confined to the authentication package, its migration, the
key-provider `Mac` verb and conformance, the channel lookup index, the
signup change that populates `address_lookup` (the decision 089 raise),
generated payload types, the pinned dependency, and the CI/Makefile wiring
that runs the new suite. Every item outside the auth package is either the
decision 089 raise or a judgment call disclosed in the PR body. No
undisclosed scope creep found. The PR body discloses its judgment calls
rather than claiming none, so there was no "Judgment calls: None." claim to
falsify.
