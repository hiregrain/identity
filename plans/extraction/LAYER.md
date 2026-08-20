---
id: extraction
type: layer
status: draft
milestone: first-product
depends_on: []
soft_blocks: [self-asserted-record]
binds:
  - decisions/LOG.md#062
  - model/record-schema.md
evidence: []
verified_by: null
---

# extraction

Resume parsing, structured extraction, and match proposal. This layer
produces proposals; it writes nothing to either plane. Created by
decision 062, which split it out of `self-asserted-record` because the
parsing system needs its own design work and its own grilling.

Not yet grilled. Decision 062 seeds the grilling; it does not close it.

What decision 062 already rules, carried in rather than reopened:

- Open-source, self-hosted components throughout, so the pipeline
  survives any vendor. Resume text never leaves Grain infrastructure.
- OSS layout/OCR for PDF-to-text; legacy OSS resume parsers rejected as
  abandonware (pre-062 ruling, carried forward).
- Extraction proposes only values literally present in the source text.
  Anything absent comes back blank for the worker to supply. A proposed
  field must be traceable to a source span.
- Match proposal order: Grain-registered parties, then the institution
  registry, then raw string. Proposals only; confirmation lives in
  `self-asserted-record`.
- The layer publishes a confidence contract: a calibrated score per
  claim and per match, and the threshold that separates batch-eligible
  from per-claim confirmation. `self-asserted-record` criterion 3 is
  gated on this contract existing.
- The uploaded artifact is ephemeral: extracted, confirmed elsewhere,
  discarded. At most a processing store with a TTL in hours.
- Model and inference infrastructure choice is a decisions entry once
  design work produces a shortlist; the open cloud-provider gate also
  gates production inference. Development runs against a stub, the
  software-key pattern from decision 011.

Known inputs to the grilling, from research/18:

- Marker (layout) and Zingg (entity resolution) lead their benchmarks
  but carry GPL-3.0/RAIL-M and AGPL-3.0 licenses; adopting either is a
  decision, not a default. Apache-family substitutes exist at some
  accuracy cost (Docling or MinerU; Splink).
- The strongest published extraction result is a small fine-tuned model
  (Qwen3-0.6B, F1 0.964), single paper, Chinese-English only, release
  unconfirmed. An existence proof, not a component.
- No published benchmark covers Philippine or Indic-script resumes.
  In-house evaluation on the actual target document mix is a criterion
  candidate, not an optional extra.

Acceptance: none yet. Criteria are authored when the layer is grilled
and reviewed; writing them before the pipeline design exists would
produce exactly the unverifiable criteria decision 042 records.
