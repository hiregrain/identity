---
id: trust-kernel
type: layer
status: ready
milestone: first-product
depends_on: [foundation]
binds:
  - decisions/LOG.md#005
  - decisions/LOG.md#012
  - decisions/LOG.md#015
  - decisions/LOG.md#016
  - decisions/LOG.md#017
  - decisions/LOG.md#019
  - model/attestation-interface.md
  - design/stack-litigation/d3-verdict.md
  - design/stack-litigation/d4-verdict.md
evidence: []
verified_by: null
---

# trust-kernel

The <~3k-line frozen core: the **primitives** that touch signatures,
chains, and checkpoints: canonicalization, sign/verify, chain
append/verify, tree construction and proofs. Orchestration around them
(scheduler, publisher, reconciliation, per-party root assembly) lives in a
kernel-adjacent package under ordinary review, so the expensive discipline
stays concentrated where a subtle bug is unrecoverable (decision 019).
Two-human review on every frozen-core change, enforced by host branch
protection rather than CODEOWNERS alone; golden vectors; fuzzing;
differential tests against an independently-authored reference model
(`trust-kernel/06`); the two TLA+ specs. Language is Go per D2; the T1 gate
is discharged (decision 012).

Scope: canonical serialization (the cross-language test vectors are a
contract deliverable); Ed25519/JWS sign + verify where the **key identifier
is a signed payload field**, since contract rule 3 freezes the protected
header to 15 exact bytes, and the signing function takes **no key
parameter** so a non-operator key is unexpressible (decision 019); key
custody behind the provider interface, software for local/CI, KMS in
production (decision 011), with the offline-root ceremony a founder gate;
hash chains over **every governing event**: per-subject and per-party
attestations, registry and party lifecycle, key events, privileged operator
actions, and deletion journal entries, with **chain membership fixed at
write time and never re-keyed by a merge**; Merkle checkpoint construction
with ≤5-minute KMS-signed checkpoints each **naming its predecessor**, a
**continuous reconciliation job**, per-party issuance roots, anchoring at
spine commit while receipts fire at acknowledgment; WORM publishing to a
dedicated compliance-mode account mirrored to a second cloud
(`trust-kernel/07`, founder-gated), **launch-blocking per D3**; the
key-event append-only log and the compromise-vs-backdating verification
rule (valid iff key active at signing time AND ledger timestamp predates any
compromise report). Inclusion *proofs* are a kernel API here; inclusion
*receipts* are issued by `ingestion`.

Acceptance:
1. **The golden vectors pass byte-identically in both implementations.** (mechanical) golden-vector suite passes byte-identically in the
   kernel and the reference model; vectors published into the contract.
2. **Tampering with an old record is caught by the chain, not by luck.** (mechanical) a mutated historical record is detected by chain
   verification; a checkpoint proves inclusion of a named attestation.
3. **The chain keeps up under the write load the docket named.** (mechanical) under a sustained write load of the rate named in the
   task file, every checkpoint lands in WORM within the D3 interval measured at
   the 99th percentile over a run of at least one hour, and a deliberate attempt
   to overwrite or delete one fails at the storage layer. The load figure and
   the run length are stated in the task file, not here.
4. **The formal specs check, and the tests derive from them.** both TLA+ specs check; the conformance tests derived from them
   pass against the implementation.
5. **Only the kernel can sign, and nothing else can be made to.** no code path outside the kernel can produce a signature, and **no
   non-operator party key is invokable anywhere**, amended from "no
   registry-grade party key at all", which decisions 015/016 superseded by
   giving the operator a single registry self-entry it signs with. Enforced
   by the signing function having no key parameter, not by a runtime check.
6. **Every governing event is chained and covered.** (mechanical) every governing event type is chained and covered by
   a checkpoint; a mutation in any of them is detected. A merge moves no
   record between chains.
7. **The reference model and the kernel agree byte-for-byte.** (mechanical) the reference model and the kernel agree byte-for-byte
   over fuzzed input, and each checkpoint's predecessor link verifies.
