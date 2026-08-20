# Ledger handoff

This document seeds the identity/career ledger repo. It states what this repo
is, what is binding on it from day one, and what is deliberately withheld so
its agents design it independently.

## What this repo is

**The company is the ledger; Dispatch is the first vertical on it.** Confirmed
by the founder 2026-08-17 (Dispatch decision 49, closing the line Dispatch
decision 46 reserved for the founder alone).

The ledger is the company-level asset the founder's talent-infrastructure
thesis describes (`founder-thesis.md` in this package): persistent worker
identity, credentials, career history, standing on the responsibility
dimensions, and standardized attestations written by every vertical that
attaches to it: digital knowledge work (Dispatch, live), and later physical
infrastructure talent, managed deployment, managed customer operations, and
human control of autonomous systems.

The division of ownership, decided and binding:

**The ledger is the system of record for the person; each vertical is the
system of record for its work.** The litmus test for any object: would another
vertical want this exact row, untranslated? Yes → ledger. Needs translation →
vertical-local, and only a distilled attestation crosses.

## What is binding from day one

One thing: **the interface contract** (`attestation-interface.md` in this
package). It defines the only two things that cross the boundary: the prior
packet going down to a vertical, and the attestation coming up from one. It
also lists what never crosses.

Its status is precise: it is **Dispatch's proposal, schema_version
0.1-proposed**, authored in the Dispatch repo as `model/attestation.md` and
carried there as extraction-ready. This repo's first substantive act is to
ratify it, amend it, or argue against it. On ratification, ownership of the
standard transfers here; Dispatch's copy becomes the conforming copy and
Dispatch's evaluation machinery conforms to this rubric rather than growing a
second one.

## What is deliberately withheld, and why

This package contains **no substrate choice, no internal schema beyond the
interface, and no description of Dispatch's internal architecture.**

That is the founder's explicit call on handoff scope: the ledger's agents
should think through identity, evidence, trust, and progression architecture
from the thesis and the interface alone, and then their conclusions should be
diffed against Dispatch's positions. Agreement reached independently is
validation; disagreement reached independently is signal. Either is worth more
than inheritance.

`dispatch-positions-and-open-questions.md` lists Dispatch's relevant positions
*as claims to test after your design exists*, not as inputs to it, plus the
questions Dispatch identified as the ledger's to answer. Recommended order:
design first, read that file second, record every agreement and disagreement
explicitly, and surface the disagreements to the founder rather than silently
converging or diverging.

## Deployment posture

The schema line binds now; the deployment boundary comes later. Dispatch runs
as one deployed system until a second vertical is real. Nothing in this repo
should assume a service boundary exists yet. The clean schema line is what
keeps the eventual separation cheap.

## Operating conventions that worked in Dispatch (offered, not mandated)

- An append-only, numbered decisions log, in which reversing a decision means
  a new entry, never an edit, so the reasoning live at the time stays legible.
- A hard split between binding structure (model docs), settled calls
  (decisions), and evidence (research). Nothing in the evidence tier
  constrains an implementation.
- Code written only against explicitly readied plans; completion claims
  require linked evidence; a separate clean-context verifier grades the work.
- No hand-written counts of checkable things; mechanical self-checks run
  before any session that edits binding prose ends.

## Package contents

| File | What it is |
|---|---|
| `HANDOFF.md` | This document. |
| `attestation-interface.md` | The binding interface contract, 0.1-proposed. |
| `founder-thesis.md` | The founder's talent-infrastructure thesis, near-verbatim, and the why behind everything here. |
| `dispatch-positions-and-open-questions.md` | Dispatch positions to test against after designing; questions that are the ledger's to answer. Read last. |
