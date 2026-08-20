---
id: extraction
type: layer
status: ready
milestone: first-product
depends_on: [self-asserted-record]
binds:
  - decisions/LOG.md#062
  - decisions/LOG.md#067
  - decisions/LOG.md#072
  - decisions/LOG.md#073
  - model/record-schema.md
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
half of 062/066): the extraction engine is a cheap commercial API
model behind a model-agnostic seam, and **only the extracted text
layer crosses the wire, never the document bytes** (decision 073). The
schema,
traceability rule, and confidence contract are engine independent; the
engine is per-environment configuration under zero-data-retention API
terms, and the production engine choice is a gated founder ruling
naming the model, its terms, its residency posture, and the eval
numbers it cleared (ORDER.md decision gate).
Switching vendors, or self-hosting if scale ever justifies it, is an
adapter and a config change. This layer depends on
self-asserted-record, which completes with its gated criteria
outstanding per the layer-done rule (decision 073); the batch
threshold there promotes when this layer's contract lands.

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
  institution registry, then raw
  string, calibrated match probabilities, proposing never asserting.
  The party tier defers to v1 with the registry it needs (decision
  073), a declared extension, not a silent absence.
- The confidence contract, published: field traceability is binary;
  match confidence is the calibrated probability; the batch threshold
  self-asserted-record consumes is stated here and renders from the
  live configuration.
- The eval harness: a synthetic-only, English-only corpus in v0
  (decision 073; languages expand by entry as markets are entered, no
  donated document without recorded consent and a deletion path);
  per-engine accuracy published; proposals are enabled per script only
  with passing numbers in `contract/eval-registry.json`, committed
  empty from the start, so extraction proposes nothing until the
  harness has run, which is the honest starting state.
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
   holds no INSERT, UPDATE, DELETE, or TRUNCATE privilege on any table
   in either plane, asserted by privilege inspection, and the
   grep-class check this layer builds fails any database access from
   the package, red-path fixture included.
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
   (mechanical) match proposals try the institution registry and fall
   back to raw, proven by fixtures at each tier (the party tier is a
   declared v1 extension, decision 073); every match carries its
   calibrated probability; the proposal payload schema carries no
   binding field, so a pre-bound ref cannot exist in a proposal,
   asserted at the schema.
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
