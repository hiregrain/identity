---
id: party-registry/05
type: task
status: ready
depends_on: [party-registry/01]
migrations: [0017-party-vetting]
binds: [decisions/LOG.md#015, design/ledger-design-0.1.md#3.1, research/06]
evidence: []
verified_by: null
---

# Vetting tiers, accreditation re-checks, and probation caps

## Objective

Vetting metadata lives here and only here, drives internal weighting
only, and never leaks into an attestation or a packet.

## Scope

- `0017-party-vetting` (spine): `vetting_tier` (`internal |
  external_probationary | external_standard | vendor`), diligence
  artifacts by reference, probation window, declared cap.
- **Probation caps: declared here, enforced at ingestion, never cached
  there.** Default ≈10× the party's stated expected volume, reviewed at
  90 days. Ingestion reads the current value per request from the
  **transactional projection** (task 01) — written in the same
  transaction as the declaring event, so there is no staleness window and
  nothing to invalidate. A cached copy with its own lifetime is how a
  party ends up uncapped after a forgotten invalidation; a projection
  cannot drift.
- **Accreditation re-check every 90 days** and on any registry event —
  one scheduled job, sharing the key-renewal rhythm. Accreditation is
  checked against closed external allowlists (DAPIP/CHEA-style where one
  exists), per research/06 §2: attackers fake the accreditor, not just
  the credential.
- **Falling off an allowlist flags a human and freezes new writes; it
  never auto-suspends** (decision 015). External registries carry name
  changes and data errors at rates that would take legitimate parties
  offline. The freeze uses the orthogonal `party_freezes` condition from
  task 01 — the party stays `active` and under no finding — and lifts when
  the accreditation check passes. The suspension decision belongs to the
  operator console queue.
- Tier, probation, caps, and reliability signals are **internal-only**:
  a check asserts none of these fields appears in any API response,
  packet, or attestation. **The internal-only field list is a single
  shared fixture**, consumed by this check and by task 07's projection
  check — two independently maintained lists would drift.

## Acceptance

- AC (mechanical): changing a cap in the registry changes ingestion
  behavior on the next request with no deploy and no cache flush.
- AC (mechanical): allowlist absence produces freeze + queue entry and
  never a state transition to `suspended`.
- AC (mechanical): no serialized output anywhere carries `vetting_tier`,
  cap, or reliability fields — asserted by a response-shape check across
  every endpoint.
- AC: the re-check job is idempotent and its schedule is derived, not
  duplicated alongside the key-renewal schedule.

## Outside check

Verifier lowers a cap and issues a write without restarting anything,
removes a party from a stubbed allowlist and confirms no auto-suspension,
and greps every response fixture for tier and cap fields.
