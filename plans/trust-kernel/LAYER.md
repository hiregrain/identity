---
id: trust-kernel
type: layer
status: ready
milestone: v1
depends_on: [foundation]
binds:
  - decisions/LOG.md#005
  - model/attestation-interface.md
  - design/stack-litigation/d3-verdict.md
  - design/stack-litigation/d4-verdict.md
acceptance: [AC-TK1, AC-TK2, AC-TK3, AC-TK4, AC-TK5]
evidence: []
verified_by: null
---

# trust-kernel

The <~3k-line frozen core: everything that touches signatures, chains, and
checkpoints. Two-human review on every change; golden vectors; fuzzing;
differential tests against an independently-authored reference model; the
two TLA+ specs (merge/unmerge under concurrent ingestion; deletion vs. the
read path). Language is Go per D2, contingent on the T1 spike's
pre-committed rule.

Scope: canonical serialization (the cross-language test vectors are a
contract deliverable); Ed25519/JWS sign + verify with `kid` resolution
against the party registry; KMS-only key custody for ledger keys (offline
root, online issuing keys, documented ceremony); per-stream (per-subject,
per-party) hash chains; Merkle checkpoint construction with ≤5-minute
KMS-signed checkpoints to compliance-mode WORM object lock in a separate
account, mirrored to a second cloud — **launch-blocking per D3**; inclusion
receipts; the key-event append-only log and the
compromise-vs-backdating verification rule (valid iff key active at signing
time AND ledger timestamp predates any compromise report).

Acceptance:
- AC-TK1 (mechanical): golden-vector suite passes byte-identically in the
  kernel and the reference model; vectors published into the contract.
- AC-TK2 (mechanical): a mutated historical record is detected by chain
  verification; a checkpoint proves inclusion of a named attestation.
- AC-TK3: checkpoints land in WORM within the interval under load, and a
  deliberate attempt to overwrite one fails at the storage layer.
- AC-TK4: both TLA+ specs check; the conformance tests derived from them
  pass against the implementation.
- AC-TK5: no code path outside the kernel can produce a signature; no code
  path anywhere can invoke a registry-grade party key (D4).
