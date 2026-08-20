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

## Where work happens

**The main checkout is a planning desk.** It holds plans, decisions, model and
design edits, and nothing else. Feature and code work happens in its own
worktree, never here. This is grain's rule, adopted for the reason grain has
it: on 2026-08-19 a second session checked out a branch in this checkout while
another was mid-edit, and the append-only decisions log ended up with three
duplicate entry numbers. One checkout, one purpose.

**Before editing anything here, check for divergence.** `git fetch origin`,
then read both `git log HEAD..origin/main` and `git log origin/main..HEAD`.
If either is non-empty, surface it rather than pivoting silently. A session
that starts on one branch and finishes on another has produced work nobody can
find.

**Untracked files survive a branch switch; tracked edits do not.** A session
holding a dozen modified files is one `git switch` away from a conflict it has
to resolve under pressure. Commit or stash before switching, never after
discovering the problem.

## Two reviews are mandatory

**`/plan-eng-review` before a layer goes `ready`.** The founder grilling
settles what a layer is for; the engineering review settles whether its
criteria can be executed and verified at all. The first layer written without
one carried six criteria this repo's own verifier protocol could not check and
three scope items with no criterion at all (decision 042). It runs again when a
layer's task files are authored.

**`/code-review` on every PR, after it is posted and before it may merge.**
Verification proves the task's criteria are met. Code review is the only step
that reads the diff for what the criteria did not think to ask about. Neither
substitutes for the other, and the merge gates run in order: CI green →
verification recorded → code review resolved → human merge.

## Criteria are numbered, not coded

Inside a layer a criterion is its number. Across layers it is `<layer>-<n>` —
`worker-surface-3`. A task declares `satisfies: [3, 5]` for criteria in its own
layer. The `AC-XX<n>` codes inherited from Dispatch were removed on 2026-08-19
because a reader could not tell what one meant; the identifier they carried is
load-bearing and survives in this readable form (decision 042). Do not
reintroduce opaque codes, and do not invent a replacement vocabulary for them
either — a bare count in frontmatter is worse than the codes were.

## Prose standard

**Unslop binds everywhere** (decision 052): no em dashes as separators, no
curly quotes, no decorative emoji, sentence-case headings, plain words over
tell vocabulary. `checks/unslop.mjs` enforces the mechanical patterns; the
judgment patterns (hedging, filler, restating labels) are review defects.
UI copy is included, not exempt.

**A comment states a constraint only beside its enforcement.** Name the
check, test, or database constraint that makes the statement true, or
write "enforced by reading". A comment whose claim has drifted from the
code is a review defect, not a nitpick (decision 052).

## Agent skills

### Issue tracker

GitHub Issues on `hiregrain/identity`, as an intake surface only — the work
queue stays `plans/` and decisions stay `decisions/LOG.md`. See
`docs/agents/issue-tracker.md`.

### Triage labels

The five defaults, label string equal to role name. See
`docs/agents/triage-labels.md`.

### Domain docs

Mapped to this repo's own structure — `THESIS.md` and `CLAUDE.md` as context,
`decisions/LOG.md` as the ADR log; no `CONTEXT.md`, no `docs/adr/`. See
`docs/agents/domain.md`.
