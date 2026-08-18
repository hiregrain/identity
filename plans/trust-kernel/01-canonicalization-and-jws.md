---
id: trust-kernel/01
type: task
status: ready
depends_on: [foundation/01, foundation/02]
binds: [contract/CONTRACT.md, decisions/LOG.md#012]
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
- Ed25519 sign/verify in the JWS envelope per rules 3–4, with the key
  lookup behind an interface (registry integration lands in
  party-registry; a fixture resolver here).
- Vector regeneration: a deterministic generator producing
  `contract/vectors/task{1,2,3}.json`-class files (canonicalization,
  sign/verify incl. tampered cases) committed to `contract/vectors/`,
  plus a TS vector-runner so both languages exercise identical bytes in
  CI from day one.
- Kernel governance seed: CODEOWNERS two-human rule on `core/kernel/`,
  line-budget check (<3k), golden-vector CI gate.

## Acceptance

- AC (mechanical): kernel passes all regenerated vectors; the TS runner
  passes the identical files; a mutated vector fails both.
- AC (mechanical): CI blocks any `core/kernel/` change lacking two
  approvals and any budget overrun.

## Outside check

Verifier regenerates vectors from the generator, diffs against committed
files (byte-identical), runs both language runners, and confirms the
governance gates fire on a synthetic PR.
