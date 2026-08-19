# Grain Identity — Agent Guide

Durable operating context for agents and developers in this repo. Keep this
file short, stable, and useful.

## Product

Grain is the trust layer that replaces the résumé: a portable, worker-owned,
cryptographically verifiable record of what a person has actually done,
attested by the parties that observed it, visible to whoever the worker
permits. The record layer is free to everyone, permanently. Analytics on work
history and trajectory is the first product. See [`THESIS.md`](THESIS.md).

Default product test:

- Does the worker keep custody? An employer's interest in your record ends
  when you leave; the worker's does not. Worker ownership here is an argument
  about incentive durability, not ideology.
- Does every claim carry its provenance, and resolve to the evidence beneath
  it? A title with nothing under it must read as a title with nothing under it.
- Does it survive being held by a company that also operates verticals on the
  record? Neutrality is maintained by contract, published rules and audit
  rather than by corporate separation — entry 024 — which is a weaker
  guarantee than a bureau's and is described as what it is.

## The constraint that outranks convenience

**Grain says what is known and how well it is known. The partner decides what
it means and bears the decision.** The marks are deterministic — the rule for
each is publishable in one sentence, and two records with identical evidence
always produce identical marks. That is what lets the ledger compute them
without becoming a scorer.

Nowhere may a mark, a packet field, or a surface collapse a graded epistemic
claim into a yes. That is the credential logic this product exists to replace,
and it is why the pointer says *this person has a record you can inspect* and
never *this person is verified* (entry 027).

Two entity types exist and only two: persons, who are subjects, and attesting
parties, who are issuers. Organisations are never subjects (entry 007). AI
executors never appear at all.

## Repo state

**There is no code yet, and that is deliberate.** Code is written only against
a plan layer with `status: ready`. Nothing outside one may be written — no
schema, no migrations, no server, no client, no CI ahead of the layer that
calls for it. Proposing a design is useful; implementing ahead of the plan is
the specific failure this file exists to prevent.

**One exemption: `checks/`.** Programs that verify this repository against
itself operate on the repo rather than the product, so they are not plan-gated.
They do not exist yet — the port from Dispatch is
[`plans/foundation/06-checks-port.md`](plans/foundation/06-checks-port.md).
Until it lands, every rule in this file is enforced by reading, which is why
the rules are written with their reasons attached.

**Layer and task status live in `plans/` frontmatter and nowhere else.** Never
trust a prose restatement of status, including in this file.

**Conventions are inherited from Dispatch and they bind.**
[`handoff/HANDOFF.md`](handoff/HANDOFF.md) offered them; this repo adopted
them, and [`plans/ORDER.md`](plans/ORDER.md) is where branch, commit, PR and
naming grammar live. Where the handoff's "offered, not mandated" framing and
ORDER.md's "adopted verbatim" appear to conflict, ORDER.md governs. Divergences
from Dispatch are legitimate but must be recorded with their reason as a
decisions entry; an unrecorded divergence is drift.

**No hand-written counts of checkable things.** "All six layers", "seventeen
layers", "three objects" — every such count in this repo drifted or was wrong
within days of being written. Say "every layer", point at the table, or let a
check count. Counts inside closed records — decisions entries, a discharged
spike — are frozen facts and stay.

If a task seems to require a decision that `decisions/LOG.md` has not made,
that is the signal to stop and raise it, not to choose quietly and note it in
a comment. `plans/ORDER.md` carries the open decision gates.

## Source of truth

1. This file
2. [`decisions/LOG.md`](decisions/LOG.md) — settled calls; beats the thesis on
   specifics. Append-only and numbered; a reversal is a new entry, never an
   edit
3. [`model/`](model/) — binding structure; beats prose on shapes. A document
   marked RATIFIED binds; one marked PROPOSED does not, and the last ratified
   version stays in force until a founder ratifies its successor
4. [`THESIS.md`](THESIS.md) — draft, and its `[GAP]` markers are the work queue
5. Code, once there is any

A decision in `decisions/LOG.md` is not reopened by inference. Propose a
superseding entry instead of quietly designing against it. Entries are
referenced by number and the number is stable.

**[`research/`](research/) is evidence and never a requirement.** Nothing in it
constrains an implementation. A figure there describes what some other company
did or what a regulator said in one matter; it is not a target, a spec, or a
decision. [`counsel/`](counsel/) holds questions put to outside counsel, not
answers received — a brief is not advice.

## Working here

**Plans.** Acceptance criteria are either *mechanical* — resolving to a command
that exits 0 or 1 — or *adjudicated* — resolving to an independent verifier
with a clean context, given only the criterion and the diff. If a criterion is
neither, it is not a criterion. "Works correctly", "handles errors", "degrades
gracefully" and "derives correctly" are rejected. A criterion that cites an
artifact this repo does not yet contain is not a criterion either; it is a
decision gate wearing one.

**Done requires linked evidence.** `status: done` is not typeable. A completion
claim with no linked test output, diff, or verifier result does not stick.
What reaches a human is the claim that could not prove itself.

**The verifier grades someone else's work.** An agent checking its own output
against criteria it just read is grading its own homework. Separate session,
separate context, criteria only.

**The fence.** A tool may rewrite `status`, `evidence`, and `verified_by`.
Nothing else. Objective, scope, constraints, and criteria are authored by a
human or an agent and read by tools, never rewritten by them.

**Binding prose goes straight to `main`** — decisions, model changes, plan
authoring — as `docs(<directory>):` commits, one per directory, never on a
branch and never inside an implementation diff. Branch and PR grammar in
`plans/ORDER.md` applies to task work only. Names are derived, never invented.
