# Attestation Interface — schema_version 0.2 (RATIFIED)

The contract between the ledger and any vertical or external partner
attached to it. Ratified 2026-08-17 (decision 006) from Dispatch's
0.1-proposed, with amendments A-1..A-5 and resolutions R-1..R-4 from
`design/interface-verdict-0.1.md` applied. **This repo owns the standard**;
Dispatch's `model/attestation.md` is the conforming copy.

Two objects cross the boundary, one in each direction. Nothing else does.
The schema cannot distinguish an internal vertical from an external partner
or a customer organization registered as an attesting party (decisions 005,
007); only the ledger's party registry can.

## Down (ledger → vertical): the prior packet

Identity reference plus coarse portable facts, **generated at read time
under an active worker grant** — never stored, never edge-cached — so
revocation, deletion, supersession, and registry-state changes always bind.
A vertical consumes these as **cold-start priors, overridden by local
evidence**; ledger claims are never treated as locally observed evidence.

| Field | Notes |
|---|---|
| `ledger_person_id` | Opaque surrogate, never reissued; resolves through the permanent alias closure after merges. A vertical holds it as a reference — one identity proof among others, never its primary key. |
| `verification[]` | List of verification attestations, each `{issuer, method, level, verified_at, freshness/expiry}` (A-2). Assurance is per-attestation, never per-person; verification is bought from registered providers, not built. |
| `credentials[]` | Coarse, ledger-verified claims. **Every item carries its provenance class** — `self_asserted \| peer_attested \| party_attested` — as a schema-level field (A-3); nothing self-asserted can be confused with anything attested on either side of the boundary. |
| `dimension_standing[]` | Position on the responsibility dimensions, **derived by the ledger** from `dimensions_exercised` across attestations under a published deterministic coarse rule (N-2): per dimension `{level, corroboration (multi\|single), as_of, supporting_attestation_refs[]}`. Attestations assert what was exercised; only the ledger asserts standing. No cross-dimension composite exists. |
| `prior_attestations[]` | Attestations from other parties, in this same schema, each carrying supersession status and any derived issuer-state or dispute flags. |
| `work_authorization` (optional) | Jurisdiction-scoped, expiring attestation: boolean + coarse `basis_class` + expiry only — never documents, visa type, or nationality. **Readable only post-selection** (decision 008): the read path structurally prevents this field from being available to candidate ranking or selection. |

## Up (vertical → ledger): the attestation

A standardized, signed summary of work outcomes. One per completed
engagement, or one per period-and-work-kind for ongoing engagements.
**Append-only**: a correction is a superseding attestation, never an edit.
Only the original issuing party — or the ledger itself via a signed
invalidation record upon proven fraud — may supersede (N-1).

| Field | Notes |
|---|---|
| `attestation_id` · `schema_version` | |
| `subject_id` | The `ledger_person_id`. A person without a ledger ID cannot be attested for; the attestation waits until the reference exists. |
| `attesting_party` | A ledger-registered attesting party (internal vertical, external partner, or customer organization — schema-identical, N-3). Signed. |
| `scope` | `engagement` (with reference) or `period` (with bounds + work kind). |
| `work_kind` · `work_kind_version` | The kind of work in the ledger's standardized vocabulary, **bound immutably as `term@version`** (A-1). The vocabulary is ledger-authored at detailed-work-activity grain, council-governed, versioned with immutable historical bindings and published crosswalks to O*NET/ISCO/ESCO (R-1). Local taxonomies stay local; only the translation crosses. |
| `volume` | Units completed in scope. |
| `score_summary` | Scoring against the vertical's quality bar, aggregated from graded evaluations, broken out by evaluation basis — customer acceptance and independent adjudication never pooled. Each per-basis entry carries `bar_ref`, the vertical-local identifier of the quality bar scored against (R-2). No ledger-normalized scale exists. Coarse ordinal tiers recommended over continuous scores. |
| `dimensions_exercised[]` | Which responsibility dimensions the work exercised, at what demonstrated level. |
| `stretch_selections[]` | Deliberate above-level assignments and outcomes. A below-bar stretch outcome carries its development context and is excluded from downward standing derivation — a development bet, never evidence against the worker. |
| `supersedes` | Optional. The attestation this one corrects. |
| `issued_at` · `signature` | Ed25519 over a canonical payload in a JWS envelope, `kid`-bound, verified against the party registry; every attestation receives a ledger hash-chain timestamp at write; valid iff the key was active at signing time AND the timestamp predates any compromise report (R-3). Party suspension is never retroactive; it produces a derived read-time flag, never an edit. Cross-language canonicalization test vectors are part of this contract. |

**Sensitive-data ban (A-4):** government ID numbers, DOB, health data,
criminal proceedings, nationality/immigration detail, and education records
beyond credential name/issuer are schema-invalid in every attestation field,
including free text. Enforced at ingestion.

**Data handling of delivered packets (A-5):** the party agreement states
what a receiving party may retain from a delivered packet and for how long.
Worker profile deletion terminates all future packet issuance immediately;
it does not recall past deliveries, which remain governed by the receiving
party's retention terms.

## The responsibility dimensions

Progression is measured as movement along responsibility dimensions,
demonstrated in real work — never as titles granted by administrative act:

- ambiguity handled
- autonomy exercised
- customer exposure
- team size directed
- machine leverage operated
- budget controlled
- P&L ownership (eventually)

These are the grain at which capability claims cross parties. The axis set
and level definitions are versioned like the taxonomy and recalibrated
after two verticals of real attestations (they are a founder hypothesis;
closest prior art SFIA/Hay/Radford covers only part of the set).

## What never crosses

- **Routing internals.** Candidates considered and rejected train the
  vertical's router; they are never career data.
- **Behavioral capture / traces.** Session-level records are the vertical's
  operational data; at most a pointer crosses.
- **Per-unit work rows.** The ledger stores aggregates; the vertical keeps
  the full-fidelity record.
- **Derived estimates.** Locally computed inference never syncs up as fact.
  This binds the ledger's own outputs too: dimension standing is a
  deterministic, citation-backed summary, never a model estimate.
- **AI executors entirely.** A model configuration has no career.
- **Sanctions-screening hit data.** Only signed pass/fail attestations are
  stored (decision 010); hit detail never enters the ledger.

## The no-shadow rules, both directions

- **No shadow profile in a vertical**: any person-fact a vertical wants in
  its own schema must answer "why isn't this a ledger field?" in review.
- **No shadow work-record in the ledger**: the ledger holds attestations
  about work, never the work itself. (This is also what makes whole-profile
  deletion honest: the ledger can truly erase because it never held the
  work.)

## Versioning

The standard versions here. Attestations bind their `schema_version`
permanently; migrations are crosswalks, never rewrites. Changes are
ratified by this repo with attached-party review per the taxonomy-council
convention (R-1).
