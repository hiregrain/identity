---
id: extraction
type: layer
status: ready
milestone: first-product
depends_on: []
soft_blocks: [self-asserted-record]
binds:
  - decisions/LOG.md#062
  - decisions/LOG.md#067
  - decisions/LOG.md#072
  - model/record-schema.md
  - research/18-oss-resume-parsing-landscape.md
gated_criteria: [7]
evidence: []
verified_by: null
---

# extraction

Resume parsing, structured extraction, and match proposal. This layer
produces proposals; it writes nothing to either plane.

Grilled 2026-08-20 (decision 072); tasks authored in the same session;
the engineering review over these criteria and tasks runs before any
task is claimed.

**Nothing is self-hosted** (decision 072, superseding the self-hosted
half of 062/066): the extraction engine is a cheap commercial API model
with native document input, behind a model-agnostic seam. The schema,
traceability rule, and confidence contract are engine independent; the
engine is per-environment configuration under zero-data-retention API
terms, and the production engine choice is a gated founder ruling.
Switching vendors, or self-hosting if scale ever justifies it, is an
adapter and a config change.

Scope, per decisions 062/067/072:

- Document-to-text: the born-digital text layer extracted by a text
  library, which is what span traceability verifies against.
  Photographed and scanned documents yield no proposals and route to
  manual entry; an OCR path is a later entry.
- The engine seam and the commercial adapter: structured output
  enforced against the proposal contract self-asserted-record's import
  task defines (the consumer owns the shape, decision 067); every
  proposed field verified as a literal span of the text layer, blank
  otherwise; per-claim and per-match confidence slots filled per the
  contract below.
- Matching: Splink run locally as a library, proposals against the
  Grain party registry first, then the institution registry, then raw
  string, calibrated match probabilities, proposing never asserting.
- The confidence contract, published: field traceability is binary;
  match confidence is the calibrated probability; the batch threshold
  self-asserted-record consumes is stated here and renders from the
  live configuration.
- The eval harness: an in-house corpus per language and script,
  per-engine accuracy published; proposals are enabled per script only
  with passing numbers, everything else routes to manual entry.
- CI and verifiers run the stub and golden outputs; only the eval
  harness calls engines, in its own environment.
- The uploaded artifact is ephemeral (decision 062): staging TTL in
  hours, owned by self-asserted-record's import task; nothing
  extracted persists beyond it.
- Out of scope: any write to either plane; the review/confirm surface
  and the write (self-asserted-record); employer normalization at
  scale (decision 040 §E); OCR for image documents.

Acceptance:

1. **Extraction writes nothing.** (mechanical) the extraction package
   holds no INSERT or UPDATE privilege on any table in either plane
   and no write path exists, asserted by privilege inspection and the
   grep-class check with a red-path fixture.
2. **Every proposed field is a literal span or it is blank.**
   (mechanical) every populated field in a proposal carries its source
   span and the span verifier finds the value verbatim in the text
   layer; a fixture whose engine output invents a value yields a blank
   field, never the invention.
3. **No text layer, no proposals.** (mechanical) an image-only
   document and a document in a script without passing eval numbers
   each yield the no-proposal result routing to manual entry, never a
   proposal.
4. **Matches carry calibrated confidence and the right priority.**
   (mechanical) match proposals try registered parties, then the
   institution registry, then fall back to raw, proven by fixtures at
   each tier; every match carries its calibrated probability; nothing
   is ever auto-bound.
5. **The published contract cannot drift.** (mechanical) the
   confidence contract and batch threshold render from the live
   configuration; the drift check diffs published against rendered at
   two configurations.
6. **The engine is swappable by construction.** (mechanical) a second
   engine adapter lands touching only the adapter directory and the
   engine registry, asserted by a path-allowlist check; the stub
   engine is the standing proof and is what CI runs.
7. **The live engine is a ruling, not a drift.** (mechanical, gated)
   production engine configuration requires a founder ruling decisions
   entry cited at the site, naming the model and its
   zero-data-retention terms; the satisfying task is draft until that
   ruling exists.
