---
id: person-identity/02
type: task
status: ready
depends_on: [person-identity/01]
binds: [decisions/LOG.md#013, decisions/LOG.md#020]
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
- **Step-up: sensitive operations require a session whose assurance matches
  the account's derived level** (decision 020). Without this, recovery
  hardening is bypassed through ordinary login — an attacker does not need
  recovery if a code session reaches everything. The closed sensitive set:
  adding or removing credentials, changing contact channels, creating or
  revoking grants, requesting a packet, and initiating deletion. Credential
  enrollment is on the list deliberately: it is the takeover primitive,
  since it converts a temporary session into permanent access.
- A code session on a document-verified account reads and acts routinely
  without friction; only the sensitive set demands step-up.

## Acceptance

- AC (mechanical): both paths authenticate the same identity; a session
  revoked by the worker fails on its next request.
- AC (mechanical): code endpoints resist enumeration (uniform responses
  and timing for existing vs. non-existent channels).
- AC: a device with no passkey support completes login start-to-finish.
- AC (mechanical): from a code session on a document-verified account, each
  operation in the sensitive set is refused without step-up — one case per
  operation, credential enrollment included.
- AC (mechanical): non-sensitive operations from a code session are never
  blocked.

## Outside check

Verifier authenticates via both paths, attempts every sensitive operation
from a code session on a verified account, confirms routine operations stay
unblocked, revokes a session mid-flight, and runs the enumeration probes.
