# person-identity/02: post-fix re-verification

- Task: `plans/person-identity/02-authentication.md` (`satisfies: []`; the
  task carries its own four acceptance bullets, numbered first through
  fourth by its Acceptance section).
- PR: #19, branch `task/person-identity-02`.
- Implementation head verified: `6eb09947800a4b6811cefb1867cb55852b9fa4e8`
  ("fix(person): close three code-review findings on auth passkeys").
- Prior pass: `log/2026-08-21-person-identity-02-verification.md` verified
  head `0a8d68b` (implementation `1ab5887`) and set `status: done`. This
  record re-verifies the same four criteria at the new head after a
  code-review fix pass landed on top of that verified state.
- Verifier: clean-context session, 2026-08-21. No implementer transcripts
  or notes consulted. Ran against the PR head in an isolated worktree,
  both planes booted from empty under the repo's own compose pair.
- Verdict: **PASS**. Every mechanical criterion re-run green at the new
  head, the adjudicated criterion re-judged pass, the fix pass confined to
  its stated scope and benign to enrollment behaviour.

## What the fix pass changed

`git diff cc35503 6eb0994` (the fix commit is the only commit between the
prior-verified state and this head) touches three files, all in
`core/person/auth`, 86 insertions, 2 deletions:

- `auth.go`: comment only. Expands the `Deliverer` interface doc to state
  why a blocking implementer would break criterion 2.
- `passkey.go`: one behavioural line plus two comments. `BeginEnrollment`
  now passes `webauthn.WithExclusions(user.descriptors())`, with a new
  `ledgerUser.descriptors()` helper over the library's own
  `Credentials.CredentialDescriptors()`. The two comment additions are a
  caller-obligation note on `BeginPasskeyLogin` (masking `ErrNoCredential`
  on a typed-address login is the caller's job, unenforceable from the
  method) and a rationale note on `FinishPasskeyLogin`'s intentionally
  discarded signature counter (synced platform passkeys report signCount
  0; clone detection is a hardware-key control decision 013 forbids
  requiring).
- `auth_db_test.go`: new `TestAuthEnrollmentExcludesExistingCredentials`,
  asserting the enrollment ceremony's exclude list is empty on a first
  enrollment and grows to one then two as devices enroll.

No file outside the auth package changed. `cd core && go build ./...`
compiles clean, so the added verb and helper break no downstream caller.
This is not scope creep: excluding already-held credentials on enrollment
is squarely inside the task's scope bullet "multiple credentials per
person; credential inventory visible to the worker".

## Preconditions (re-run, not re-read)

- `docker compose up -d --wait` then `node db/migrate.mjs spine` and
  `node db/migrate.mjs payload`: spine applied 6 migrations, payload
  applied 7 including `0037-authentication-and-sessions`.
- `cd core && go build ./...`: clean.
- `make check` was not re-run in full. The fix pass is confined to
  `core/person/auth` (comments, one test, one behavioural line) and the
  prior verification already ran the full suite green at `1ab5887`. The
  load-bearing precondition here is the auth acceptance suite, re-run
  below, plus a clean build of the whole `core` module.

## Criteria, re-run at 6eb0994

Command for all four: `cd core && GRAIN_KEY_PROVIDER=software go test -tags
db -count=1 -timeout 30m -v ./person/auth`. Whole package `ok` in 101.6s,
exit 0. Per-criterion tests:

**First (mechanical): both paths authenticate the same identity; a
revoked session fails its next request.**
- `TestAuthBothPathsReachTheSameIdentity` PASS (6.63s).
- `TestAuthRevokedSessionFailsItsNextRequest` PASS (10.73s).
- Supporting `TestAuthBothPathsIssueTheSameKindOfSession` PASS (5.91s).

**Second (mechanical): code endpoints resist enumeration (uniform
responses and timing).**
- `TestAuthCodeEndpointsResistEnumeration` PASS (24.18s), the timing
  assertion included.

**Third (adjudicated): a device with no passkey support completes login
start to finish.**
- `TestAuthLoginWithoutAPasskeyCompletesEndToEnd` PASS (4.83s). The fix
  pass changed nothing in the code path or the no-passkey path
  behaviourally (`BeginPasskeyLogin`'s only change is a comment).
  Re-judged from criterion and diff: still pass.

**Fourth (mechanical): routine operations from a code session are never
blocked; the code path is a first-class equal path.**
- `TestAuthCodeSessionIsNeverBlocked` PASS (10.19s).
- `TestNothingBranchesOnHowASessionWasAuthenticated` PASS (0.00s), the
  structural half that fails on any comparison or switch against
  `MethodPasskey`/`MethodCode` in the package source. Still green at the
  new head; the fix pass's comments naming those constants in prose do not
  trip it, as it parses the AST, not comments.

## The WithExclusions change is benign to enrollment

The instruction's specific concern: did adding
`webauthn.WithExclusions(user.descriptors())` alter enrollment beyond
populating the exclusion list?

- A first enrollment still succeeds. `TestAuthEnrollmentExcludesExisting
  Credentials` asserts the first ceremony's `CredentialExcludeList` is
  empty and the enrollment completes; every other enrollment-driving test
  in the suite (`TestAuthCredentialInventory`,
  `TestAuthBothPathsReachTheSameIdentity`, and this test's own two
  follow-on enrollments) enrolls credentials successfully and passes.
- The exclude list grows as devices enroll: the test observes 0, then 1
  after "the phone", then 2 after "the laptop". PASS (5.25s).
- No behavioural regression: the virtual authenticator crafts response
  bytes directly and does not consult the exclude list, so the option
  changes what the ceremony *offers the browser*, not whether the stored
  ceremony completes. All prior enrollment behaviour is preserved, proven
  by the unchanged pass of every enrollment-using test.

## Outside check

The task's Outside check (authenticate via both paths, confirm routine
operations stay unblocked from a code session, revoke mid-flight, run the
enumeration probes) is discharged by the same suite runs that discharge
criteria one, two and four above, each of which drives a real ceremony or
code delivery against both live planes and attempts the adversarial case
(revoke-then-reuse, existing-vs-absent-channel probes, cross-session
revoke returning `ErrNotYours` with nothing written). No probe separated
the resolved from the unresolved branch in wording, table state, or time.
No break found.

## Findings

None. The fix pass is comment-and-test plus one in-scope behavioural line,
compiles across the module, and disturbs no criterion. `status: done`
stands correctly at `6eb09947800a4b6811cefb1867cb55852b9fa4e8`.
