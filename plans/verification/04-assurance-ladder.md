---
id: verification/04
type: task
layer: verification
satisfies: [2, 8]
status: ready
depends_on: [verification/02]
migrations: []
binds: [decisions/LOG.md#070]
evidence: []
verified_by: null
---

# The assurance ladder: derived at read, published in sentences

## Objective

A person's assurance level is a lookup anyone can recompute, stated in
rules anyone can read.

## Scope

- The derivation: none/channel/document/biometric computed at read
  from the person's live verification set; per level, one published
  sentence, rendered from the live derivation configuration so
  published and enforced cannot drift (the threshold-sentence pattern
  from analytics).
- Expiry honesty: an expired verification contributes nothing; decay
  is expiry, no partial credit.
- Coexistence: verifications from different issuers stack; the level
  is the highest whose rule the set satisfies; no averaging, no
  composite.
- The fixture table: (issuer, method, level, verified_at, expiry) rows
  to expected level, covering every level boundary and expiry edge.
- The boundary rule (decision 071): the derived level is internal and
  worker-facing only; no packet or party-facing response schema
  carries it, the RF-1 serializer pattern with a planted-field red
  path; what crosses is the per-attestation list the ratified
  interface defines.

## Acceptance

1. AC (mechanical): the fixture table maps every row to its expected
   level; identical sets derive identical levels across repeated runs
   and processes.
2. AC (mechanical): an expired verification's removal from a fixture
   set changes nothing; its presence unexpired changes the level the
   table says it does.
3. AC (mechanical): no party-facing response schema carries the
   derived level and the serializer check rejects a planted one,
   red-path fixture included.
4. AC (mechanical): the published sentences render from the live
   configuration; running the render at two configurations produces
   two different sentence sets, and the check this task builds diffs
   the published sentences against the rendered ones.
5. AC (mechanical): no person-level assurance column exists in any
   plane, asserted by schema inspection; the level is computed at
   read and never stored, the interface's per-attestation rule made
   mechanical (decision 071).

## Outside check

Verifier recomputes the fixture table on a fresh clone and runs the
drift check at two configurations.
