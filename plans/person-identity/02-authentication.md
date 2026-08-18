---
id: person-identity/02
type: task
status: ready
depends_on: [person-identity/01]
binds: [decisions/LOG.md#013]
evidence: []
verified_by: null
---

# Authentication and sessions

## Objective

Passkeys preferred, one-time codes always available — no worker excluded
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

## Acceptance

- AC (mechanical): both paths authenticate the same identity; a session
  revoked by the worker fails on its next request.
- AC (mechanical): code endpoints resist enumeration (uniform responses
  and timing for existing vs. non-existent channels).
- AC: a device with no passkey support completes login start-to-finish.

## Outside check

Verifier authenticates via both paths, revokes a session mid-flight,
and runs the enumeration probes.
