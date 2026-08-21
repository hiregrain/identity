---
id: person-identity/02
type: task
layer: person-identity
satisfies: []
status: in_progress
depends_on: [person-identity/01]
migrations: [0037-authentication-and-sessions]
binds: [decisions/LOG.md#013, decisions/LOG.md#020, decisions/LOG.md#089]
evidence: []
verified_by: null
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
