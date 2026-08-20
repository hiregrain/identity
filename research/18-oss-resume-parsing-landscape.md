# Open-source resume parsing and entity matching: component landscape

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A benchmark number here is what someone measured once,
not a target.

**Status:** Research memo, prepared 2026-08-20 for the `extraction` layer
(decision 062). The layer's ruling is open-source and self-hosted for
durability; this surveys what exists under that constraint. Benchmark
figures are third-party unless marked as vendor-published.

---

## TLDR (conclusions first)

1. A license-clean, production-grade stack exists end to end: Docling or
   MinerU for PDF layout, PaddleOCR-VL for multilingual OCR, XGrammar on
   vLLM for constrained JSON decoding, Instructor or BAML as the
   extraction wrapper, Splink for probabilistic name-to-registry matching
   with calibrated confidence scores. All Apache or MIT.
2. Two accuracy leaders are license-encumbered and must not be adopted
   silently: Marker/Surya (layout, GPL-3.0 code plus RAIL-M weights with
   a commercial revenue threshold) and Zingg (entity resolution,
   AGPL-3.0). Each has an Apache-family substitute at some accuracy cost.
3. The strongest accuracy signal favors small fine-tuned models: one 2025
   paper fine-tuned Qwen3-0.6B on resumes and reported F1 0.964 against
   Claude-4's 0.959 and a commercial parser's 0.817, at 1.54s per resume.
   Single Alibaba-authored paper, Chinese-English resumes only, code
   release unconfirmed. An existence proof, not a component.
4. Hardware envelope follows from 3: a single 24GB GPU plausibly serves
   extraction at meaningful throughput. Self-hosting breaks even against
   API pricing at roughly 1-5M tokens/day.
5. The real gap is the target population: no published benchmark covers
   Philippine or Indic-script resumes. The best published numbers are
   English/Chinese. In-house evaluation on the actual document mix is
   unavoidable before committing to a model.

## 1. PDF layout and OCR

- **Docling** (IBM, MIT; its 258M VLM is Apache 2.0). CPU-runnable,
  unified document output. Strong on its own table benchmark (97.9%) but
  50.3% on the independent olmOCR-Bench at 2.1 pages/sec, weaker on messy
  real-world layouts than Marker or MinerU. Broadest permissive
  licensing of the group.
- **Marker** (Datalab, on the Surya 650M VLM). Leads olmOCR-Bench: 76.0%
  overall, 83.5% born-digital, 96.1% reading order, about 120 pages/sec
  batched on an H100. GPL-3.0 code plus RAIL-M weights restricting
  commercial use above a revenue threshold. The license is the blocker.
- **MinerU** (mostly Apache 2.0). 72.7% olmOCR-Bench at 0.54 pages/sec.
  The permissive mid-tier.
- **Unstructured** (Apache 2.0 core, paid hi-res tiers). 64+ file types;
  pipeline glue rather than best-in-class layout.
- **PaddleOCR / PaddleOCR-VL** (Apache 2.0). 109 languages including
  Devanagari, Arabic, Cyrillic. One comparative study: F1 0.938 against
  Tesseract's 0.797, 89% against 71% on mixed-language content. The OSS
  option for non-Latin scripts.
- **Tesseract** (Apache 2.0). Mature, stagnant, baseline only.

Sources: https://huggingface.co/PaddlePaddle/PaddleOCR-VL,
https://ijrpr.com/uploads/V6ISSUE10/IJRPR53627.pdf,
https://www.marktechpost.com/2026/07/24/datalab-marker-v2-vs-mineru-docling-and-liteparse-benchmark-breakdown/,
https://docs.unstructured.io/open-source/introduction/overview

## 2. LLM structured extraction

The field has shifted from largest-model to small-fine-tuned-model. The
paper behind TLDR point 3 (arXiv 2510.09722) is the strongest single
claim; treat it as research-grade until its release lands and it is
reproduced on non-Chinese documents. A general benchmark, LLMStructBench,
found a 12B model beating several 70B models on structured extraction,
which points the same direction: instruction tuning and data curation
matter more than size here. A small OSS project (ResumeParser, local
Qwen2.5-1.5B, no API dependency) shows the pattern working at small
scale.

Constrained decoding is a solved layer: XGrammar is the default backend
across vLLM, SGLang, TensorRT-LLM and MLC-LLM, with 97.1% schema accuracy
on complex nested JSON where Outlines scored 76.4% (Qwen-2.5-32B,
GitHub-issues benchmark); Outlines remains competitive when one complex
schema is reused across many requests. Instructor (MIT, Pydantic-native)
and BAML (MIT, contract-first with codegen) are the developer-facing
wrappers, both provider-agnostic. JSONSchemaBench (arXiv 2501.10868) is
the closest standardized cross-tool benchmark if more evaluation is
needed.

Sources: https://arxiv.org/html/2510.09722v1,
https://arxiv.org/pdf/2601.04426,
https://docs.vllm.ai/en/v0.8.2/features/structured_outputs.html,
https://github.com/567-labs/instructor

## 3. Entity matching against a registry

- **Splink** (UK Ministry of Justice, MIT). Probabilistic
  Fellegi-Sunter linkage over DuckDB/Spark/Athena backends; tens of
  millions of records in sub-hour runtimes; emits calibrated
  match-probability scores directly from the statistical model, which
  maps onto the confidence-tiered confirmation ruling (decision 062).
  The production-grade, license-clean default.
- **dedupe** (MIT). Active-learning fuzzy matching, Python-native,
  smaller scale, manual training loop.
- **Zingg** (AGPL-3.0). Spark-native active-learning entity resolution
  at data-lake scale. The license needs a decision before any adoption.
- **LLM-based matching** (ComEM, COLING 2025, and confidence-calibration
  work at arXiv 2509.19557). Embed structured context, then LLM re-rank;
  raw LLM confidence is poorly calibrated without an explicit
  calibration step. Research code, would need building.

Sources: https://github.com/moj-analytical-services/splink,
https://github.com/tshu-w/ComEM, https://arxiv.org/pdf/2509.19557

## 4. Multilingual and non-Latin-script performance

PaddleOCR-VL is the strongest OSS option for Indic scripts. Indic-language
digital resources are thin; post-OCR correction models exist as research
patches, not integrated pipelines, so expect materially lower accuracy on
Indian regional-language resumes than Latin-script ones. Philippine
resumes are typically English or Filipino in Latin script, so closer to
solved, but no Filipino resume benchmark was found. The one paper with
hard multilingual extraction numbers tested Chinese-English mixes only.

Sources: https://arxiv.org/pdf/2412.15248,
https://ijrpr.com/uploads/V6ISSUE10/IJRPR53627.pdf

## 5. Self-hosting cost envelope

A 0.6B-1.7B extraction model fits many concurrent instances on one 24GB
card; 7B-14B fits a single 24GB GPU (roughly $0.50-1/hr cloud); 70B-class
needs 80GB+ (about $2-4/hr on demand) and is not obviously necessary
given section 2. Layout/OCR models (250M-650M params) are CPU-runnable or
share the same box. vLLM is the reference serving engine; SGLang runs
about 29% faster on H100 as of 2026 if throughput binds. Break-even
against commercial API pricing lands around 1-5M tokens/day.

Sources: https://www.sitepoint.com/self-hosted-llm-costs-2026/,
https://packet.ai/blog/llm-inference-cost
