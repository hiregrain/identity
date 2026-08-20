---
id: trust-kernel/04
type: task
layer: trust-kernel
satisfies: [2]
status: ready
depends_on: [trust-kernel/02, trust-kernel/03, trust-kernel/08]
migrations: [0008-checkpoint-log]
binds: [design/stack-litigation/d3-verdict.md, contract/CONTRACT.md, decisions/LOG.md#016, decisions/LOG.md#019]
evidence: []
verified_by: null
---

# Merkle checkpoints

## Objective

The ≤5-minute signed checkpoint cycle over all stream heads, the
system's ordering authority (D3/D6), with inclusion proofs.

## Scope

- Merkle tree over stream heads per contract rule 6 (promotion rule,
  domain tags); checkpoint = signed root + sequence number + **predecessor
  hash** + coverage metadata, produced by a scheduler with jitter
  tolerance. The predecessor hash is what makes the checkpoint sequence a
  chain rather than a series of unrelated signatures, and D3 requires it
  by name. It was missing, and it is a format decision, so deferring it
  would mean the first checkpoints are written in a format that must
  change.
- **Anchoring happens at spine commit, not at acknowledgment** (decision
  019). A checkpoint covers every spine row committed at cut time,
  including rows whose payload apply is still in flight. Coupling the
  cadence to the payload worker would let a retry loop stall a
  launch-blocking commitment. Stated explicitly because two different
  moments now exist: **anchoring proves ordering; acknowledgment proves
  durability**, and the signed receipt to a party fires on the second
  (issued by `ingestion`, on the watermark from foundation/07).
- **Per-party issuance root** (decision 016, relocated here by decision
  019's boundary rule, signing and tree math belong to the kernel): a
  Merkle root over a single party's issuance stream for a period, built
  from the same stream-head machinery. `party-registry/07` consumes this
  API rather than defining it. The global root is not a substitute: a party
  cannot recompute it from its own records, so signing it would attest to
  our arithmetic instead of their issuance.
- **Continuous reconciliation job** (D3, was missing): re-derives recent
  checkpoints from raw stream heads and compares against what was
  published, on a standing schedule. This is the job that proves the whole
  anchoring scheme actually holds, and D3 names it as launch-blocking.
- `0008-checkpoint-log` (spine): the checkpoint sequence, append-only;
  frozen canonical checkpoint format (recomputable byte-for-byte;
  genesis-consistency depends on this, per the D3 verdict).
- Inclusion-proof generation and verification (kernel API; consumed later
  by inclusion receipts in ingestion and the resolution pages).
- Publisher interface with a local-filesystem WORM emulation for dev/CI.
  **The real publisher is `trust-kernel/07`**, dedicated compliance-mode
  object-lock account and second-cloud mirror, which cannot exist before
  the cloud provider ruling. Split there so everything buildable today is
  actually buildable, and the blocked part is visible in the graph rather
  than hidden inside a task that looks ready.
- **Scheduler, publisher, reconciliation, and per-party root assembly live
  in the kernel-adjacent package, not the frozen core** (decision 019). The
  core holds tree construction and proof math; orchestration calls in.

## Acceptance

- AC (mechanical): checkpoints cover every stream head present at cut
  time across every stream type; a planted head omission is detected by the
  coverage check.
- AC (mechanical): each checkpoint names its predecessor, and a broken
  predecessor link fails verification of the sequence.
- AC (mechanical): the reconciliation job re-derives a published checkpoint
  byte-identically and flags a planted mismatch.
- AC (mechanical): a party can recompute its own issuance root from its own
  records alone, without reading the global tree.
- AC (mechanical): a spine row with payload still in flight is anchored,
  and no receipt is issued for it.
- AC (mechanical): a proof verifies a named record's stream head into a
  named checkpoint; tampered proofs fail.
- AC: checkpoint cadence holds under synthetic ingest load (≤5 min p100
  in test).

## Outside check

Verifier replays a checkpoint from raw stream heads and confirms
byte-identical roots (the recomputability property), breaks one predecessor
link, plants a published-versus-derived mismatch for the reconciliation job,
recomputes one party's issuance root from that party's records only, stalls
a payload apply and confirms the row anchors without a receipt, then runs
the omission and tamper cases.
