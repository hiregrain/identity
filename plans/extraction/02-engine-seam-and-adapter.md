---
id: extraction/02
type: task
layer: extraction
satisfies: [1, 2, 6]
status: ready
depends_on: [extraction/01, self-asserted-record/05]
migrations: []
binds: [decisions/LOG.md#067, decisions/LOG.md#072]
evidence: []
verified_by: null
---

# The engine seam, the stub, and the span verifier

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
- The commercial adapter is task 07; this task is the seam, the stub,
  the span verifier, and the write-nothing boundary.
- Span verification after the engine, never trusting it: every
  populated field is located verbatim in task 01's text layer or
  blanked; the engine's own claimed spans are checked, not believed. A
  blanked invention increments a counter carrying the field name; the
  invented value itself is never written anywhere (decision 073).
- The write-nothing boundary: the extraction package holds no
  database privilege of any kind, and the grep-class check built here
  fails any database access from the package, red-path fixture
  included; only the text layer, never document bytes, ever reaches an
  engine, asserted by the seam's signature taking text only.

## Acceptance

1. AC (mechanical): the stub engine drives the full path to
   contract-valid proposals; golden fixtures pass on a fresh clone
   with no network egress.
2. AC (mechanical): an engine output inventing a value not present in
   the text layer yields a blank field and an incremented counter
   naming the field, with the invented value present nowhere, proven
   by scanning every store after the red-path fixture; an engine
   claiming a false span is corrected by the verifier, second red
   path.
3. AC (mechanical): a second engine adapter lands touching only the
   adapter directory and the engine registry, asserted by the
   path-allowlist check this task builds; the extraction package holds
   no INSERT, UPDATE, DELETE, or TRUNCATE privilege anywhere, proven
   by inspection, and the grep-class check fails a planted database
   access, red-path fixture included.

## Outside check

Verifier runs the stub path with egress blocked, plants both red-path
fixtures, and lands a synthetic adapter to reproduce the allowlist
proof.
