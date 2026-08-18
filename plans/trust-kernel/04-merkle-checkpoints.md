---
id: trust-kernel/04
type: task
status: ready
depends_on: [trust-kernel/02, trust-kernel/03]
migrations: [0008-checkpoint-log]
binds: [design/stack-litigation/d3-verdict.md, contract/CONTRACT.md]
evidence: []
verified_by: null
---

# Merkle checkpoints

## Objective

The ≤5-minute signed checkpoint cycle over all stream heads — the
system's ordering authority (D3/D6) — with inclusion proofs.

## Scope

- Merkle tree over stream heads per contract rule 6 (promotion rule,
  domain tags); checkpoint = signed root + sequence number + coverage
  metadata, produced by a scheduler with jitter tolerance.
- `0008-checkpoint-log` (spine): the checkpoint sequence, append-only;
  frozen canonical checkpoint format (recomputable byte-for-byte —
  genesis-consistency depends on this, per the D3 verdict).
- Inclusion-proof generation and verification (kernel API; consumed later
  by inclusion receipts in ingestion and the resolution pages).
- Publisher interface with a local-filesystem WORM emulation for dev/CI;
  the real cross-cloud object-lock publisher is wired at provisioning
  (founder gate) — interface and tests exist now.

## Acceptance

- AC (mechanical): checkpoints cover every stream head present at cut
  time; a planted head omission is detected by the coverage check.
- AC (mechanical): a proof verifies a named record's stream head into a
  named checkpoint; tampered proofs fail.
- AC: checkpoint cadence holds under synthetic ingest load (≤5 min p100
  in test).

## Outside check

Verifier replays a checkpoint from raw stream heads and confirms
byte-identical roots (the recomputability property), then runs the
omission and tamper cases.
