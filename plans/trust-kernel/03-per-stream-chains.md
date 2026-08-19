---
id: trust-kernel/03
type: task
layer: trust-kernel
satisfies: [2, 6]
status: ready
depends_on: [trust-kernel/01, foundation/04]
migrations: [0007-stream-heads]
binds: [contract/CONTRACT.md, decisions/LOG.md#019]
evidence: []
verified_by: null
---

# Per-stream hash chains

## Objective

Append-only per-subject and per-party chains over spine records, per
contract rule 5 — the structure the D1/D3 verdicts called
unretrofittable.

## Scope

- Chain append inside the spine write transaction, alongside the outbox row
  (foundation/07): each record carries `prev_hash` for every stream it
  belongs to; genesis and empty-stream semantics per contract.
- **Streams cover every governing event, not only attestations** (decision
  019). D3's anchored contents are broader than the attestation record, and
  D4's dispositive argument depends on registry manipulation being visible
  in the log — which is false if registry events are unchained. Streams:
  per-subject and per-party attestation chains; **registry and party
  lifecycle events; key events; privileged operator actions; deletion
  journal entries**. An audited-but-unanchored operator action is alterable
  by the operator, and the operator is the party a dispute distrusts.
- **Chain membership is fixed at write time and never re-keyed** (decision
  019). A record stays in the chain it was written into, keyed to the
  `ledger_person_id` that was live at that moment — forever. Merge adds
  alias resolution *above* the chains; it never moves a record between
  them. Re-keying would mean rewriting records already hashed into
  published checkpoints, breaking every existing inclusion proof. Cost
  accepted: a merged person's full history is a walk over several chains
  combined at the resolution layer, and unmerge is trivially correct
  because chain membership was never touched.
- `0007-stream-heads`: current head per stream, rebuildable from the
  records. **Granted as a named, role-scoped exemption in this migration**
  — decision 017 dropped foundation/03's blanket derived/cache clause, so
  this table is licensed by name to a named role with its rationale at the
  site, not by a general category. Generalized over the stream types above,
  not just subject and party.
- Full-chain verification (used by the production auditor later): walks a
  stream, reports first divergence position.
- Subject-keyed layout honoring the hot-range warning (UUIDv7 bucketing
  decision documented at the schema site, per decision-50-style
  at-the-site rule).

## Acceptance

- AC (mechanical): a mutated historical record (simulated as table owner)
  is detected at the correct position in every stream it belongs to,
  including a registry event, a key event, an operator action, and a
  deletion journal entry.
- AC (mechanical): a merge moves no record between chains — chain
  membership before and after is byte-identical; resolution changes, chains
  do not.
- AC (mechanical): an unmerge restores prior resolution with zero chain
  writes.
- AC (mechanical): dropping stream heads and rebuilding reproduces
  identical heads (derived-cache proof).
- AC: chain append adds one round trip max to the write path (measured).

## Outside check

Verifier mutates one record as owner in each stream type, runs verification
on every affected stream, executes a merge and diffs chain membership
before and after, unmerges and confirms no chain write occurred, and
re-runs the rebuild diff.
