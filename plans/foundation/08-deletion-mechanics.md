---
id: foundation/08
type: task
layer: foundation
satisfies: [6, 7]
status: in_progress
depends_on: [foundation/05, foundation/07]
migrations: [0021-deletion-journal]
binds: [decisions/LOG.md#017, decisions/LOG.md#014, design/ledger-design-0.1.md#2.5]
evidence: []
verified_by: null
---

# Deletion mechanics: purge, backups, and restore

## Objective

"Delete means gone" survives the scenario most likely to actually happen —
a restore from backup — and has an answer to "the bytes are still on your
servers."

## Scope

- `foundation/05` owns the primitive: destroy the person's key, content
  becomes unreadable. This task owns everything that makes the *promise*
  true rather than the *mechanism* work.
- **Crypto-shredding is recorded as a documented legal position, not as a
  mechanical proof** (decision 017). Key destruction is instant and
  irreversible; the reasoning for why that constitutes erasure is written
  at the schema site, with decision 014's *EDPS v SRB* analysis cited —
  the ledger cannot re-identify, and that is the load-bearing fact.
- **Scheduled physical purge.** Shredded rows are physically removed on a
  stated schedule, so unreadable ciphertext does not accumulate forever.
  The purge role is the *only* role holding DELETE on payload tables,
  named per table in the migration under foundation/03's exemption
  license, and every purge run is audited. This is also the concrete
  answer to foundation/04's placeholder ("exemptions where deletion
  requires it").
- `0021-deletion-journal` (spine): an append-only record of every
  destruction — person, instant, requester class — carrying **no
  identifying content**, only what a replay needs.
- **Backups cannot resurrect a deleted person** (decision 017): backup
  retention is bounded and stated as a number, and **any restore replays
  the deletion journal before the restored system accepts traffic**. The
  replay is a gate, not a cleanup step — a restored system that has not
  replayed does not serve.
- The residual window between a backup and its expiry is **disclosed
  rather than hidden**: the worker-facing deletion copy states it, and the
  number the copy states is the number the retention config enforces,
  asserted by a check.
- Out of scope, deliberately: the full deletion saga across services and
  copy-map acknowledgment, which `consent-and-deletion` owns. This task
  owns the substrate that saga stands on.

## Acceptance

- AC (mechanical): restoring a backup taken before a deletion, then
  running the replay, leaves nothing readable for that person — proven by
  attempting a read and by grepping a raw dump.
- AC (mechanical): a restored system that has not completed the replay
  refuses traffic.
- AC (mechanical): only the purge role holds DELETE on payload tables; the
  application role's append-only test (foundation/03) still passes.
- AC (mechanical): the retention window in the worker-facing copy and the
  retention window in config are the same value, asserted by a check that
  fails when they drift.
- AC (mechanical): the deletion journal carries nothing identifying — a
  schema assertion plus a raw-dump grep.
- AC: a purge run is fully audited and attributable.

## Outside check

Verifier deletes a person, takes and restores a pre-deletion backup, tries
to read before and after replay, brings up a restored system with the
replay disabled and confirms it refuses traffic, runs a purge and inspects
the audit trail, and edits the retention config to confirm the copy-drift
check fires.
