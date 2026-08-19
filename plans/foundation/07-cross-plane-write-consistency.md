---
id: foundation/07
type: task
layer: foundation
satisfies: [5]
status: done
depends_on: [foundation/04]
migrations: [0020-cross-plane-outbox]
binds: [decisions/LOG.md#011, decisions/LOG.md#017, decisions/LOG.md#005]
evidence:
  - "log:log/2026-08-19-foundation-07-verification.md"
  - "diff:PR #7 @ ad2ad82ab1f6f824691ec5c4f6bb6491c7a7be57"
verified_by: clean-context-verifier@2026-08-19
---

# Cross-plane write consistency

## Objective

A write that touches both databases either completes or is completed by
retry. It never half-lands and stays that way.

## Scope

- The problem this exists to close: there is no shared transaction across
  two physical databases (decision 011), so every spine+payload write can
  commit one side and lose the other. A spine row with no payload is a
  record that exists and cannot be read; a payload row with no spine entry
  is content with no proof. No layer above foundation can solve this for
  itself without three layers inventing three answers.
- **Spine-first with a transactional outbox** (decision 017). The spine
  write and an outbox row commit in one local transaction — the spine is
  the ordering and integrity authority, so its commit is what "recorded"
  means.
- `0020-cross-plane-outbox` (spine): append-only outbox entries carrying
  the target plane, the payload instruction, attempt count, and terminal
  state. Append-only, so a completed entry is marked by a following row,
  never updated in place.
- **Idempotent payload apply.** A worker drains the outbox and applies to
  payload; re-applying the same entry is a no-op, proven by natural-key or
  instruction-hash idempotency rather than by the worker remembering.
- **Reconciler** for stragglers: entries past a threshold surface as an
  alert and a queue item. Silent backlog is the failure mode this exists
  to prevent.
- **No compensation path.** The spine is append-only; "undoing" a spine
  write means writing a retraction, which puts an infrastructure hiccup
  permanently into the record a dispute will read. Retry forward only.
- **Acknowledgment semantics, stated here because `ingestion` promises
  them:** an attestation is acknowledged only when both planes are
  durable. The outbox is what makes that promise keepable; `ingestion`'s
  ack watermark reads this state rather than defining its own.
- Explicit ban: no cross-database FDW, dblink, or shared-connection
  construct anywhere. That ban is what makes "no SQL joins across planes"
  (foundation/04) mechanically true rather than aspirational.

## Acceptance

- AC (mechanical): killing the process between the spine commit and the
  payload apply leaves a recoverable state; the worker completes it on
  restart with no operator action and no duplicate payload row.
- AC (mechanical): applying the same outbox entry twice produces one
  payload row — asserted by row count, not by inspecting worker logic.
- AC (mechanical): a payload apply that fails permanently surfaces through
  the reconciler within its threshold; it never sits silent.
- AC (mechanical): no FDW, dblink, or cross-database extension exists in
  either chain — asserted by a schema check.
- AC: nothing acknowledges before both planes are durable, proven with the
  payload apply artificially stalled.

## Outside check

Verifier kills the worker mid-flight at three different points, restarts,
and diffs both planes against expectation; replays one entry manually;
stalls payload indefinitely and confirms no acknowledgment; plants an FDW
in a test migration and confirms the check fails.
