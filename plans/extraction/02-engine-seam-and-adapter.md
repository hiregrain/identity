---
id: extraction/02
type: task
layer: extraction
satisfies: [2, 6]
status: ready
depends_on: [extraction/01, self-asserted-record/05]
migrations: []
binds: [decisions/LOG.md#067, decisions/LOG.md#072]
evidence: []
verified_by: null
---

# The engine seam, the stub, and the commercial adapter

## Objective

Any engine that can fill the contract can drive extraction, no engine
can invent a value that survives, and CI never needs one at all.

## Scope

- The engine seam: `extract(text, contract) → proposals` against the
  proposal payload shape self-asserted-record/05 defines (the consumer
  owns the shape, decision 067); engines register in an engine
  registry; the engine is per-environment configuration.
- The stub engine: deterministic fixture engine implementing the seam,
  what CI and every verifier runs, and half of criterion 6's proof.
- The commercial adapter: structured output enforced against the
  contract; sandbox/test-mode configuration in this task, the
  production flip is task 06 (gated). The adapter requires
  zero-data-retention terms in its configuration shape even in test
  mode, so the requirement exists before the ruling does.
- Span verification after the engine, never trusting it: every
  populated field is located verbatim in task 01's text layer or
  blanked; the engine's own claimed spans are checked, not believed.

## Acceptance

1. AC (mechanical): the stub engine drives the full path to
   contract-valid proposals; golden fixtures pass on a fresh clone
   with no network egress.
2. AC (mechanical): an engine output inventing a value not present in
   the text layer yields a blank field with the invention logged, the
   red-path fixture; an engine claiming a false span is corrected by
   the verifier, second red path.
3. AC (mechanical): a second engine adapter lands touching only the
   adapter directory and the engine registry, asserted by the
   path-allowlist check this task builds; the extraction package holds
   no database privilege, proven by inspection.

## Outside check

Verifier runs the stub path with egress blocked, plants both red-path
fixtures, and lands a synthetic adapter to reproduce the allowlist
proof.
