---
id: extraction/01
type: task
layer: extraction
satisfies: [3]
status: ready
depends_on: []
migrations: []
binds: [decisions/LOG.md#072]
evidence: []
verified_by: null
---

# Document to text: the layer traceability stands on

## Objective

A born-digital document yields the text everything downstream verifies
against; anything else says so honestly and routes to typing.

## Scope

- Text-layer extraction from born-digital PDFs and common document
  formats through a text library, never a model; the output is the
  canonical source text spans are verified against.
- Born-digital detection: a document with no usable text layer (image
  PDF, photo) yields the structured no-proposal result that routes the
  worker to manual entry (decision 072); no OCR exists in v0.
- Script gating hook: the detector consults the eval registry (task
  05) and yields no-proposal for scripts without passing numbers.
- Stateless: input bytes in, text or no-proposal out; nothing
  persists here (staging is self-asserted-record's).

## Acceptance

1. AC (mechanical): born-digital fixtures yield text layers whose
   content matches golden outputs byte for byte; an image-only fixture
   and a photo fixture each yield the no-proposal result.
2. AC (mechanical): a fixture in a script with no passing eval entry
   yields the no-proposal result; the same fixture with a passing
   entry yields text.
3. AC (mechanical): the package writes nothing: no filesystem output
   outside the caller's buffers, no database access, proven by
   privilege inspection and a filesystem watch during the fixture run.

## Outside check

Verifier runs the fixture set on a fresh clone, diffs golden outputs,
and flips one eval-registry entry to watch the gate move.
