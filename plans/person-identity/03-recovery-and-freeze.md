---
id: person-identity/03
type: task
status: ready
depends_on: [person-identity/02, verification/01]
binds: [decisions/LOG.md#013]
evidence: []
verified_by: null
---

# Recovery and the post-recovery freeze

## Objective

Account recovery cannot be weaker than the assurance it recovers — and a
successful takeover still cannot destroy the record.

## Scope

- Recovery flows per assurance tier: a channel-only account recovers by
  channel; a document-verified account must **re-clear document
  verification** (decision 013), biometric likewise.
- The **7-day freeze** after any recovery: profile deletion, grant
  creation/revocation, and verification changes are blocked; notifications
  fire to every channel on file at recovery and at freeze expiry.
- Recovery attempts, successes, and freezes recorded append-only and
  visible in the worker's own record.
- Interaction with deletion: a deletion request placed during a freeze
  queues until expiry rather than failing (so a legitimate owner is not
  permanently blocked, and a thief gains nothing).

## Acceptance

- AC (mechanical): a document-verified account cannot be recovered by
  email/SMS code alone — proven by an attempted downgrade path.
- AC (mechanical): deletion attempted inside the freeze window does not
  execute; the same request executes after expiry.
- AC: every recovery emits notifications to all channels, logged.

## Outside check

Verifier attempts the downgrade recovery, runs the takeover-then-delete
scenario end to end, and confirms the record survives.
