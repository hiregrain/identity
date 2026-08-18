---
id: trust-kernel/03
type: task
status: ready
depends_on: [trust-kernel/01, foundation/04]
migrations: [0007-stream-heads]
binds: [contract/CONTRACT.md]
evidence: []
verified_by: null
---

# Per-stream hash chains

## Objective

Append-only per-subject and per-party chains over spine records, per
contract rule 5 — the structure the D1/D3 verdicts called
unretrofittable.

## Scope

- Chain append inside the spine write transaction: each record carries
  `prev_hash` for its subject stream and its party stream (two chain
  memberships per attestation); genesis and empty-stream semantics per
  contract.
- `0007-stream-heads`: current head per stream — a derived-cache table
  under the exemption license, rebuildable from the records.
- Full-chain verification (used by the production auditor later): walks a
  stream, reports first divergence position.
- Subject-keyed layout honoring the hot-range warning (UUIDv7 bucketing
  decision documented at the schema site, per decision-50-style
  at-the-site rule).

## Acceptance

- AC (mechanical): a mutated historical record (simulated as table owner)
  is detected at the correct position in both its streams.
- AC (mechanical): dropping stream heads and rebuilding reproduces
  identical heads (derived-cache proof).
- AC: chain append adds one round trip max to the write path (measured).

## Outside check

Verifier mutates one record as owner, runs verification on both affected
streams, and re-runs the rebuild diff.
