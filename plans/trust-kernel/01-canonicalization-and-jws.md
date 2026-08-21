---
id: trust-kernel/01
type: task
layer: trust-kernel
satisfies: [1]
status: in_progress
depends_on: [foundation/01, foundation/02]
binds: [contract/CONTRACT.md, decisions/LOG.md#012, decisions/LOG.md#019]
evidence: []
verified_by: null
---

# Canonicalization and JWS core

## Objective

The kernel's serialization and signature primitives in Go, plus the
regenerated golden vectors (the T1 scratch vectors were lost to temp
cleanup; `contract/CONTRACT.md` preserves the normative rules).

## Scope

- JCS canonicalization per contract rules 1–2 (ECMAScript number
  placement, UTF-16 key ordering) as a kernel package.
- Ed25519 sign/verify in the JWS envelope per rules 3–4. **The key
  identifier is a signed payload field, not a header** (decision 019):
  contract rule 3 freezes the protected header to the exact 15 bytes
  `{"alg":"EdDSA"}`, compared byte-for-byte, so there is nowhere in the
  header for a `kid`. Putting it in the canonical payload places key
  identity *inside* the signed bytes, so nobody can change which key a
  record claims without breaking the signature. **Consequence requiring
  a separate interface amendment:** `model/attestation-interface.md`
  (schema_version 0.2, ratified in decision 006) must carry the field;
  this task does not amend it unilaterally.
- **Signing takes no key parameter** (decision 019): `sign(bytes)` returns
  the signature and the key identifier used; key selection is internal to
  the operator provider. A `sign(kid, bytes)` shape would make "no
  non-operator key is invokable" a runtime string check someone can
  regress, the exact regression decision 016 wanted structurally
  prevented. With no key parameter, the wrong key is unexpressible rather
  than rejected. Verification is a separate function taking a public key.
- Key resolution for verification reads the registry (integration lands in
  party-registry; a fixture resolver here).
- Vector regeneration: a deterministic generator producing
  `contract/vectors/task{1,2,3}.json`-class files (canonicalization,
  sign/verify incl. tampered cases) committed to `contract/vectors/`,
  plus a TS vector-runner so both languages exercise identical bytes in
  CI from day one.
- Kernel governance seed: CODEOWNERS on `core/kernel/`, plus the host
  ruleset decision 087 names: force pushes and branch deletion blocked
  on `main`. The two-approval host rule is dormant with its trigger
  written in 087 (it returns when a second maintainer holds write
  access); kernel review is enforced by the loop's own gates. The
  acceptance below checks the host policy, not just the file.
- A kernel-side adapter speaking `reference/`'s differential harness
  protocol, so `make differential KERNEL_ADAPTER=...` runs the kernel
  against the reference model (founder ruling 2026-08-21, resolving the
  trust-kernel/06 raise: the adapter belongs to the task that owns the
  kernel, not to the harness).
- **Line-budget check (<3k) scoped to the frozen core only** (decision
  019): canonicalization, sign/verify, chain append/verify, tree
  construction and proofs. Schedulers, publishers, reconciliation, and
  per-party root assembly live in a kernel-adjacent package that calls in
  and is reviewed normally. The budget bounds what gets the expensive
  treatment, namely two-human review, fuzzing, and formal specs, rather
  than measuring the layer.

## Acceptance

- AC (mechanical): kernel passes all regenerated vectors; the TS runner
  passes the identical files; a mutated vector fails both.
- AC (mechanical): the signing function exposes no key parameter, proven
  by its type signature, so passing another party's key is not expressible.
- AC (mechanical): the key identifier is inside the signed bytes; altering
  it invalidates the signature (vector case).
- AC (mechanical): CI blocks any budget overrun, and the **host policy
  decision 087 names** (force pushes and branch deletion blocked on
  `main`, CODEOWNERS present on the kernel paths) is asserted by
  querying the host, not inferred from the file.

## Outside check

Verifier regenerates vectors from the generator, diffs against committed
files (byte-identical), runs both language runners, attempts to sign with a
non-operator key and confirms it does not compile, tampers with the payload
key identifier and confirms verification fails, and confirms the host
ruleset decision 087 names is in force rather than only the CODEOWNERS
file.
