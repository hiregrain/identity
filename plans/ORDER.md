# Order

> *Things in here are always what the dependency graph cannot express.*

**Order is derived, not written.** Every task declares `depends_on`, and
what is workable right now is computed from that. There is no phase list,
no schedule, and no second copy of the sequence — Dispatch's ORDER.md
records that its own early phase table drifted within a day, and this repo
inherits the lesson instead of relearning it. (An INDEX.md with a wave
table existed here for one session; it is deleted.)

`checks/` (to be ported from Dispatch in `foundation`) validates every
frontmatter block and the dependency graph, then lists what is workable.
Claiming is first-writer-wins on `status: in_progress`.

## How plans are structured

```
plans/
  ORDER.md                  this file
  t1-spike.md               cross-cutting gate, not a layer
  foundation/
    LAYER.md                scope, acceptance, outside check
    01-*.md … NN-*.md       tasks (authored when the layer goes ready)
  trust-kernel/ … durability-and-launch/
```

Sixteen layers: `foundation`, `trust-kernel`, `party-registry`,
`ingestion`, `person-identity`, `verification`, `self-asserted-record`,
`consent-and-deletion`, `worker-surface`, `peer-references`,
`prior-packet`, `marks-and-embeds`, `integration-surface`,
`operator-console`, `public-web`, `durability-and-launch`. Their current
status and dependencies live in their own frontmatter, nowhere else.

**Two levels; tasks are files, not headings.** Each task carries its own
`status`, `evidence`, `verified_by`; two agents working two tasks in one
layer never contend on one document. **Dependencies are per task, not per
layer** — a `prior-packet` task needing only the packet schema starts the
moment that schema lands, without waiting for the rest of `ingestion`.
This is the biggest lever on parallel agent count. **A task is one agent
session with one done-condition**, roughly four to eight per layer.

**Milestone `v1`** = the full round trip: a worker signs up (cold or via
resume import), verifies, controls and can delete their record; a
registered party reads a prior packet under grant and writes an
attestation back; the record renders with correct marks; the D1/D3 launch
obligations (decision 005) are in force.

## The execution protocol

Adopted from Dispatch verbatim, because it is proven and agents move
between these repos:

**Status vocabulary:** `draft` (not decomposed/specified; ineligible) →
`ready` (criteria final; eligible the moment `depends_on` are `done`) →
`in_progress` (writing this IS the claim) → `done` (criteria met,
evidence linked, verification recorded) | `abandoned` (reason in body).
**Blocked is never stored** — it is computed.

**`evidence`**: list of `<kind>:<ref>`, kind ∈ `test | diff | log |
review`, each explained in the file's Evidence section.

**`verified_by`**: `null` until verification, then `<verifier>@<date>`,
written only by the verification recorder, never the implementing session.

**Verifier protocol:** a separate clean-context session, given only the
task file and the diff/artifact — not the working notes. Mechanical
criteria are re-run, not re-read. On a pass the verifier writes
`status: done`; nobody else ever does. An implementer never verifies its
own task.

**Pull requests:** one PR = one task; the task file is the spec; anything
in the diff the task did not call for is scope creep by definition.
Binding prose (decisions, model changes, plan authoring) goes straight to
`main`, never inside implementation diffs. Merge gates in order: CI green
→ clean-context verification recorded → human review of judgment calls.
Merging is a human act. **Never squash** — evidence cites SHAs.

**Naming:** branches `task/<layer>-<NN>`; commits
`<type>(<task-id>): <what changed>` with the closed vocabulary
`feat | fix | verify | docs | checks | chore`; PR titles
`<task-id> — <task H1 verbatim>`; migrations `NNNN-<kebab-noun-phrase>`
naming what exists after. Naming friction is a scope alarm.

**Grill-before-ready (this repo's addition):** promoting a layer to
`ready` requires a founder grilling session on that layer's design tree —
frontier questions with recommendations, jargon explained, rounds until
empty — recorded as a decisions-log entry. Task files are authored only
after the layer's grilling closes. First instance: decision 011
(foundation + trust-kernel).

**The executive loop:** one executive session reads the computed queue,
claims and dispatches to fresh-context implementers (one per task,
parallel only on disjoint frontiers), dispatches clean verifiers, batches
merge-ready PRs and raises for the founder, and never implements,
verifies, merges, or answers a raise itself.

## Founder gates

Artifacts only the founder can produce; the loop stalls visibly here
rather than one discovery at a time.

| Gate | Blocks | Owner state |
|---|---|---|
| T1 spike ruling (pre-committed rule in `t1-spike.md`) | — | **discharged (decision 012)** — Go stands; switch-triggers carry forward as the guard |
| Counsel brief 4 → final worker-agreement terms | the first real worker; `durability-and-launch` AC-DL3 config. Not the build | open, long lead — send the brief |
| Chrome/marks rulings (invariant ledger chrome; epistemic mark system) | `marks-and-embeds` going `ready`; `worker-surface` AC-WS4 as written | open — drafted in session, awaiting ratification |
| **Cloud provider ruling** (AWS vs. GCP mini-litigation, decision 011 open item) | real provisioning; nothing local | open — litigation starts on founder go |
| Cloud accounts + KMS + WORM buckets provisioned (two clouds, separate account for object-lock) | `trust-kernel` checkpoint tasks against real infra; local/CI work is ungated (software-key provider per decision 011) | open — follows the provider ruling; founder-held billing |
| Persona/Sumsub DPAs signed (retention/destruction schedules per research/09) | live verification in `verification`; sandbox/stub work is ungated | open |
| PR merges (merge gate 3) | every task's completion | standing |
| Witnessed-log witness contract | nothing until the registry deadline nears (D3); listed so it is not discovered late | open, deferred |

## Decision gates

| Gate | Blocks | Status |
|---|---|---|
| Money-movement entity red line (decisions/LOG.md 010, open item) | nothing in v1 — the ledger holds no funds. Listed because the first vertical payment feature proposal must hit this gate, not discover it | open |
| Work-authorization rollout jurisdictions (decision 008 sets the shape; which jurisdictions ship in v1 is unruled) | `verification` work-authorization tasks only | open |
| grain retrofit sequencing (research/10 migration list) | nothing in v1 — grain attaches through `integration-surface` when ruled | open |

## Work that has no layer

- **`checks/`** — ported from Dispatch in `foundation`, exempt from the
  plan gate because it verifies the repo rather than the product.
- **Dispatch conformance** — the ratification notice
  (`handoff/ratification-notice-for-dispatch.md`) is Dispatch-repo work,
  tracked there, not here.
- **Counsel briefs 1–3** — inform design; block nothing in code. Brief 2
  (salted commitments) must return before checkpoints go *public* —
  private WORM anchoring is ungated.

## Live risks, recorded rather than resolved

- **The human queues scale wall** (merge stewardship, disputes, vetting)
  is v1-thin by design; the risk is forgetting it is a product line, not
  an ops afterthought. The trigger for building it out: any queue's
  latency becoming worker-visible.
- **T1 inverts D2.** If Go's measured defect rate is materially worse,
  trust-kernel re-plans onto the TS+Go-oracle hybrid — priced, bounded,
  and pre-agreed, but a real re-plan of one layer.
