---
id: person-identity/03
type: task
layer: person-identity
satisfies: [2]
status: ready
depends_on: [person-identity/02]
binds: [decisions/LOG.md#013, decisions/LOG.md#020]
evidence: []
verified_by: null
---

# Recovery and the post-recovery freeze

## Objective

Account recovery cannot be weaker than the assurance it recovers, and a
successful takeover still cannot destroy the record.

## Scope

- Recovery flows per assurance tier: a channel-only account recovers by
  channel. In first-product every account is channel-only by
  construction, since the verification layer is excluded from the
  milestone (decision 071). The document and biometric re-clear paths
  (decision 013) arrive with verification tasks 03 and 04 and are
  declared here as that gated extension, not built now; this task's
  criteria cover channel recovery and the freeze.
- The **7-day freeze** after any recovery: profile deletion, grant
  creation/revocation, and verification changes are blocked; notifications
  fire to every channel on file at recovery and at freeze expiry.
- Recovery attempts, successes, and freezes recorded append-only and
  visible in the worker's own record.
- Interaction with deletion: a deletion request placed during a freeze
  queues, and **does not execute at expiry**. It requires a **fresh
  authenticated confirmation** after the freeze lifts (decision 020).
  Auto-execution at expiry was a time bomb: an attacker recovers the
  account, requests deletion, waits seven days, and the system destroys the
  record for them, which is the exact attack the freeze exists to stop, just
  slower. Re-confirmation keeps a legitimate owner unblocked while an
  attacker who has since lost access cannot finish. Notifications fire to
  every channel at request, at expiry, and before execution.

## Acceptance

- (The downgrade-proof criterion, a document-verified account refusing
  code-only recovery, is cut by decision 086: no such account exists in
  first-product per decision 071. It returns with the verification layer.)
- AC (mechanical): deletion attempted inside the freeze window does not
  execute, and **does not execute at expiry either**. It waits for fresh
  confirmation, proven by advancing the clock past expiry with no further
  action and confirming the record survives.
- AC: every recovery emits notifications to all channels, logged.

## Outside check

Verifier attempts the downgrade recovery, runs the takeover-then-delete
scenario end to end **including waiting past freeze expiry with no further
attacker action**, and confirms the record survives.
