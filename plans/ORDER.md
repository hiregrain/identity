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

Every directory under `plans/` other than this file and `t1-spike.md` is a
layer. Their names, status and dependencies live in their own frontmatter,
nowhere else — this file does not carry a second copy of the list, and no
count of them is written here. Let a check count.

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

**Milestone `first-product`** = the shortest path to something sold:
`foundation`, `trust-kernel`, `person-identity`, `self-asserted-record`,
`analytics`. A worker signs up, imports a resume, and a partner buys a read on
their history and trajectory. It deliberately excludes `verification`, so the
first thing sold runs on unverified self-asserted history plus whatever
references have arrived — which is what `THESIS.md` §5 says, stated as a
boundary rather than a sentence. `v1` remains the attestation round trip.

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

**Naming.** *Names are derived, never invented* — every identifier already
exists in a plan file, a date, or a task id, so two agents naming the same
thing produce the same string. A name you had to invent means something
upstream, a task or a decision, is missing. Naming friction is a scope alarm,
not a wording problem.

- **Branches:** `task/<layer>-<NN>`. No descriptive words; the task file
  carries the description. (`<layer>/<NN>` is unusable — git forbids a branch
  under a name that is itself a branch.)
- **Commits:** `<type>(<scope>): <what changed>`, lowercase, present tense, no
  period. Closed vocabulary: `feat` implements criteria, `fix` corrects a
  verified defect, `verify` records a verification, **`docs` is binding prose
  and goes straight to `main`, scope being the directory** (`docs(model):`),
  `checks` is repo self-checks, `chore` is tooling with no criteria. **A change
  with no clear type is two changes** — and binding prose spanning several
  directories is one commit per directory, so a contract change is never buried
  inside a research diff.
- **PR titles:** `<task-id> — <the task file's H1, verbatim>`. No "Add", no
  "Implement" — a title you have to compose means no task exists for the work.
- **PR bodies:** three sections, headers verbatim. `## Criteria` — one line per
  acceptance criterion, how it was discharged. `## Judgment calls` — deviations
  with rationale, or "None.", which is a claim the verifier can falsify.
  `## Verification` — the verification record, `verified_by`, and the head SHA
  verified.
- **Log files:** `YYYY-MM-DD-<slug>.md`. Verification records
  `YYYY-MM-DD-<layer>-<NN>-verification.md`, carrying the task id, the head SHA
  verified, each criterion with how it was discharged, and the pass or fail.
  Recorded here so the first verifier does not invent it.
- **Migrations:** `NNNN-<kebab-noun-phrase>.sql`, naming what exists after, not
  what the migration does — `0002-roles-and-default-privileges`, never
  `0002-add-roles`.

**The fence.** A tool may rewrite `status`, `evidence` and `verified_by`.
Nothing else. Objective, scope, constraints and criteria are authored by a
human or an agent and read by tools, never rewritten by them.

**The grammar binds from 2026-08-19 forward.** Most earlier subjects on `main`
predate its enforcement and are left as they stand: rewriting them means
force-pushing a published branch, which costs more than the inconsistency.
Evidence cites SHAs, not subjects, so nothing depends on them.

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
| **The confidence threshold** below which analytics returns insufficient data, and whether it is published (decision 022 open item) | `analytics` going `ready` | open |
| **The run-record pseudonym** — it cannot be the `ledger_person_id`, which decisions 013/020 make permanent and spine-referenced (decision 026) | `analytics` going `ready` | open |
| **The run-record spine/payload fork** — inside the subject's DEK it dies at deletion and breaches AI Act Art. 19; outside it, it survives readable (decision 026) | `analytics`, and a `foundation` task nobody owns | open |
| **Worker-facing job suggestions.** 42 U.S.C. §2000e(c) defines an employment agency as one who procures "for employees opportunities to work for an employer" — the suggestion surface is that definition, and it would make Grain a covered entity rather than a vendor (`research/14` §1.2) | the suggestion surface; `THESIS.md` §8's matching position | open — founder, and it inverts the earlier reasoning |
| **Antitrust.** A cross-employer performance register is a labour-market information exchange under the Jan 2025 DOJ/FTC guidelines, where third-party intermediation is expressly not a defence (`research/13` §6.6) | nothing in code; the thesis's risk section | open — founder, unscoped |
| **Is R2 regional?** India DPDP Rule 8(3) compels one year of retention surviving account deletion from ~May 2027 (`research/14` §2) | the deletion promise, `consent-and-deletion` copy, and the India rail | open — counsel, long lead |

## Work that has no layer

- **`checks/`** — ported from Dispatch in `foundation`, exempt from the
  plan gate because it verifies the repo rather than the product.
- **Dispatch conformance** — the ratification notice
  (`handoff/ratification-notice-for-dispatch.md`) is Dispatch-repo work,
  tracked there, not here.
- **The slope disclosure text** — the three failure modes carried on every
  trajectory output (decision 022). Product copy with a correctness
  obligation; drafted nowhere, owned by `analytics`.
- **The Article 22 brief, rescoped.** `THESIS.md` §10 lists it as never
  scoped. In the UK the article no longer exists in that form: DUAA 2025 s.80
  replaced it with Arts. 22A–22D, in force 5 February 2026, and Art. 22C
  requires inform, representations, human intervention, and contest. The
  brief's question is now who owes that duty — Grain or the deployer
  (`research/14` §3).
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
