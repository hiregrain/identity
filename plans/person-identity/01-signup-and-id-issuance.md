---
id: person-identity/01
type: task
layer: person-identity
satisfies: []
status: ready
depends_on: [foundation/04, foundation/07]
migrations: [0010-person-core]
binds: [decisions/LOG.md#013, decisions/LOG.md#017]
evidence: []
verified_by: null
---

# Signup and ID issuance

## Objective

Anyone can hold an identity in seconds: one verified contact channel in,
an opaque permanent `ledger_person_id` out.

## Scope

- `0010-person-core` (spine): `person` with opaque UUIDv7 id (hot-range-safe
  layout, rationale documented at the schema site), `created_at`,
  lifecycle state as write-once + transition rows (never an editable
  column — Dispatch's proven correction), tombstone marker.
- Payload-side person row: contact channels with verified-at and
  channel-risk fields; `display_name` free-text Unicode, optional.
- Email-primary signup with verified control of one channel (decision
  013); phone optional and captured with line-type/assurance metadata —
  PH mobiles recorded at their higher RA 11934 assurance rather than
  flattened.
- Channel risk scoring hook at signup (VOIP line-type, carrier
  reputation, velocity) — the real anti-Sybil control; v1 records signals
  and thresholds, escalation policy lands with the anti-fraud work.
- IDs are never reissued or recycled, including after deletion.
- **"Instantly" is defined, because signup writes both planes** (decision
  017): the id is issued and returned at **spine commit**; the payload row
  follows through the outbox. The account is usable immediately; anything
  requiring payload waits on the acknowledgment watermark. Without this
  stated, "issued instantly" is three different claims.

## Acceptance

- AC (mechanical): signup with an email and nothing else yields a usable
  identity; no field beyond one verified channel is required anywhere in
  the path.
- AC (mechanical): a tombstoned id can never be issued again (proven by
  a test attempting reuse against the generator and the table).
- AC: PH mobile signups carry the elevated assurance marker; US mobiles
  do not.

## Outside check

Verifier creates an identity with email only, inspects the row for absent
optional data, attempts id reuse, and confirms lifecycle state is not an
updatable column.
