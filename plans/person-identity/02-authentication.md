---
id: person-identity/02
type: task
layer: person-identity
satisfies: []
status: done
depends_on: [person-identity/01]
binds: [decisions/LOG.md#013, decisions/LOG.md#020]
evidence:
  - "test:make auth-test @ 1ab5887 (core/person/auth acceptance suite, both planes live)"
  - "test:make check, make check-red and make check-red-db @ 1ab5887 (green locally under a no-ports compose override)"
  - "log:github.com/hiregrain/identity/actions/runs/32529483382 (every stage green at 1ab5887, including the authentication and sessions job)"
  - "diff:PR #19 @ 1ab58875f52f67f4f745456a12bb1e2bd26df578"
  - "review:log/2026-08-21-person-identity-02-verification.md (clean-context verification, pass at 0a8d68b)"
  - "review:log/2026-08-21-person-identity-02-post-fix-verification.md (post-fix re-verification, pass at 6eb0994)"
verified_by: clean-context-verifier@2026-08-21
---

# Authentication and sessions

## Objective

Passkeys preferred, one-time codes always available. No worker excluded
by device class.

## Scope

- WebAuthn/passkey registration and login; multiple credentials per
  person; credential inventory visible to the worker.
- One-time-code login over the person's verified channel(s) as a
  first-class equal path (never a degraded fallback).
- Session issuance and revocation; sessions listed and individually
  revocable by the worker; every authentication event recorded
  append-only.
- Rate limiting and lockout on code paths; abuse signals feed the same
  risk scoring as signup.
- **Step-up is cut from this task** (decision 086): its criterion required
  a document-verified account, and decision 071 rules those cannot exist in
  first-product, so the criterion was unreachable. Step-up, the sensitive
  set, and session-assurance derivation return with the verification
  layer, whose task 04 owns the ladder. Decision 020's comparison rule is
  unchanged and waits there.

## Acceptance

- AC (mechanical): both paths authenticate the same identity; a session
  revoked by the worker fails on its next request.
- AC (mechanical): code endpoints resist enumeration (uniform responses
  and timing for existing vs. non-existent channels).
- AC: a device with no passkey support completes login start-to-finish.
- AC (mechanical): routine operations from a code session are never
  blocked; the code path is a first-class equal path (decision 013).
  (The step-up refusal criterion is cut by decision 086 and returns with
  the verification layer.)

## Outside check

Verifier authenticates via both paths, confirms routine operations stay
unblocked from a code session, revokes a session mid-flight, and runs the
enumeration probes.

## Evidence

Written by the implementing session, which may rewrite `status`,
`evidence` and `verified_by` and nothing else.

- `test:make auth-test` runs the acceptance suite for this task
  (`core/person/auth`) against both live planes. Each criterion's own
  test: `TestAuthBothPathsReachTheSameIdentity` and
  `TestAuthRevokedSessionFailsItsNextRequest` for the first,
  `TestAuthCodeEndpointsResistEnumeration` for the second,
  `TestAuthLoginWithoutAPasskeyCompletesEndToEnd` for the third, and
  `TestAuthCodeSessionIsNeverBlocked` with
  `TestNothingBranchesOnHowASessionWasAuthenticated` for the fourth.
- `test:make check`, `make check-red` and `make check-red-db` are the
  standing pipeline at the head, a precondition rather than evidence for
  any single criterion.
- `log:` the CI run at the head, where the `authentication and sessions`
  job this task adds to the graph runs.
- `diff:` the pull request and the head SHA it carries.
- `review:` the clean-context verification record in `log/`, written by
  the verifier and not by this session.
