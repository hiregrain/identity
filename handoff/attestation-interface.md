# Attestation interface, schema_version 0.1-proposed

> **SUPERSEDED, 2026-08-18.** This is the handoff copy as Dispatch authored it.
> The live contract is [`../model/attestation-interface.md`](../model/attestation-interface.md),
> ratified at 0.2 by decision 006 with amendments A-1..A-5 and resolutions
> R-1..R-4 applied, and carrying 0.3-proposed amendments since. Nothing here
> binds. Retained as the dated record of what was handed over, so the
> ratification diff stays legible.

The contract between the ledger and any vertical attached to it. Authored by
Dispatch (the first vertical) as `model/attestation.md` in the Dispatch repo;
**this repo's to ratify, amend, or argue against.** On ratification the ledger
owns the standard and Dispatch's copy becomes the conforming copy.

Two objects cross the boundary, one in each direction. Nothing else does.

## Down (ledger → vertical): the prior packet

Identity reference plus coarse portable facts. A vertical consumes these as
**cold-start priors, overridden by local evidence**. The ledger holds
evidence and coarse claims; each vertical computes its own routing-grade
estimates locally and never treats ledger claims as locally observed evidence.

| Field | Notes |
|---|---|
| `ledger_person_id` | The ledger's stable person ID. A vertical holds it as a reference, one identity proof among others, never its primary key. |
| `verification` | Identity verification attestation: issuer, level, verified-at. Verification itself is bought from external providers, not built. The ledger records the resulting attestation. |
| `credentials[]` | Coarse, ledger-verified claims. |
| `dimension_standing[]` | Position on the responsibility dimensions (below), as last attested across all verticals. |
| `prior_attestations[]` | Attestations from other verticals, in this same schema. |

## Up (vertical → ledger): the attestation

A standardized, signed summary of work outcomes. One per completed engagement,
or one per period-and-work-kind for ongoing engagements. **Append-only**: a
correction is a superseding attestation, never an edit.

| Field | Notes |
|---|---|
| `attestation_id` · `schema_version` | |
| `subject_id` | The `ledger_person_id`. A person without a ledger ID cannot be attested for; the attestation waits until the reference exists. |
| `attesting_party` | The vertical, as a ledger-registered attesting party. Signed. |
| `scope` | `engagement` (with reference) or `period` (with bounds + work kind). |
| `work_kind` | The kind of work, at the ledger's standardized cross-vertical grain. Each vertical translates its local work taxonomy into this vocabulary; local rows stay local. |
| `volume` | Units completed in scope. |
| `score_summary` | Scoring against the vertical's quality bar, aggregated from graded evaluations, **broken out by evaluation basis**. Customer acceptance and independent adjudication are never pooled into one number. |
| `dimensions_exercised[]` | Which responsibility dimensions the work exercised, at what demonstrated level. |
| `stretch_selections[]` | Deliberate above-level assignments taken in scope, and their outcomes. A below-bar stretch outcome carries its development context; it was a development bet, not a routing error, and must not read as evidence against the worker. |
| `supersedes` | Optional. The attestation this one corrects. |
| `issued_at` · `signature` | |

## The responsibility dimensions

Progression is measured as movement along responsibility dimensions,
demonstrated in real work, never as titles granted by administrative act.
The founder's axis set:

- ambiguity handled
- autonomy exercised
- customer exposure
- team size directed
- machine leverage operated
- budget controlled
- P&L ownership (eventually)

These are the grain at which capability claims cross verticals: "directed a
team of six under weekly customer exposure" must mean the same thing in
datacenter deployment as in managed customer operations.

## What never crosses

- **Routing internals.** Which candidates a vertical considered and rejected
  for an assignment trains that vertical's router; it is not career data.
- **Behavioral capture / traces.** Session-level records of how a person works
  are the vertical's operational data, governed by its capture-rights regime;
  at most a pointer crosses.
- **Per-unit work rows.** The ledger stores aggregates; the vertical keeps the
  full-fidelity record.
- **Derived estimates.** Locally computed inference is recomputable and never
  syncs up as fact. Duplicate models across verticals are deliberate;
  duplicate evidence stores are forbidden.
- **AI executors entirely.** A model configuration has no career.

## The no-shadow rules, both directions

- **No shadow profile in a vertical**: any person-fact a vertical wants to add
  to its own schema must answer "why isn't this a ledger field?" in review.
- **No shadow work-record in the ledger**: the ledger holds attestations about
  work, never the work itself.

## Known open items in this proposal

Flagged by Dispatch, expected to be resolved here:

1. The `work_kind` taxonomy: who authors it, at what grain.
2. Whether `score_summary` needs a cross-period anchor reference for
   comparability, or per-basis breakout suffices at ledger grain.
3. The signature mechanism for attesting parties.
4. Worker consent and portability scope for attestations crossing verticals.
