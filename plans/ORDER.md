# Order

> *Things in here are always what the dependency graph cannot express.*

**Order is derived, not written.** Every task declares `depends_on`, and
what is workable right now is computed from that. There is no phase list,
no schedule, and no second copy of the sequence. Dispatch's ORDER.md
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
nowhere else; this file does not carry a second copy of the list, and no
count of them is written here. Let a check count.

**Two levels; tasks are files, not headings.** Each task carries its own
`status`, `evidence`, `verified_by`; two agents working two tasks in one
layer never contend on one document. **Dependencies are per task, not per
layer**. A `prior-packet` task needing only the packet schema starts the
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
references have arrived, which is what `THESIS.md` §5 says, stated as a
boundary rather than a sentence. `v1` remains the attestation round trip.

**Its exit test is a second read.** The milestone ships two individually weak
levels: a self-asserted record, and a read over it that `THESIS.md` §5
concedes may return insufficient data. One purchase does not establish that
either level holds value on its own. The same partner returning to the same
record does. Until that happens `first-product` has produced a demonstration
rather than a product, and declaring the test in advance is the point.

## Frontmatter, and what each field is for

A layer and a task carry different fields. The checks port
(`plans/foundation/06`) validates these; until it lands they are enforced by
reading.

**Layer**: `id`, `type`, `status`, `depends_on`, `binds`, `evidence`,
`verified_by`, plus `milestone` where it applies. Optional, and worth using:

- `soft_depends_on`: work that can start before the dependency lands.
- `soft_blocks`: the inverse pointer, layers this one informs but does not
  gate. Advisory, never read by the frontier computation.
- `gated_criteria`: criteria a `ready` layer knowingly cannot reach yet,
  because the only task that would satisfy them is still `draft`. **Declaring
  it is the point.** The undeclared case is the one that drifts. Adopted on
  Dispatch's reasoning (decision 042). **A layer is `done` when every
  non-gated criterion is met** (decision 073); gated criteria discharge
  later through their declared draft tasks, and the strict layer gate
  reads `done` in this sense, or any milestone containing a layer with a
  gated criterion deadlocks.
- `discharged_at_layer`: a criterion settled by adjudication with no
  implementation behind it. A task carrying one would be a PR containing
  nothing, so it is declared here instead.

**Task**: `id`, `type`, `layer`, `status`, `depends_on`, `satisfies`,
`binds`, `evidence`, `verified_by`.

**`satisfies` is the join.** It names the criteria a task delivers, so a
check can prove every criterion has a task and no task claims a criterion
that does not exist. Every task file carries `layer` and `satisfies`
(written 2026-08-19, closing a divergence from Dispatch); the checks port
will enforce both once it lands.

**Criteria are identified by position, not by code** (decision 042). Inside a
layer a criterion is its number; across layers it is `<layer>-<n>`, as in
`worker-surface-3`. A task writes `satisfies: [3, 5]` for its own layer. The
old `AC-XX<n>` codes were removed on 2026-08-19 because they were unreadable;
the identifier they carried was load-bearing and survives in this form.

## The execution protocol

Adopted from Dispatch verbatim, because it is proven and agents move
between these repos:

**Status vocabulary:** `draft` (not decomposed/specified; ineligible) →
`ready` (criteria final; eligible the moment `depends_on` are `done`) →
`in_progress` (writing this IS the claim) → `done` (criteria met,
evidence linked, verification recorded) | `abandoned` (reason in body).
**Blocked is never stored**. It is computed.

**`evidence`**: list of `<kind>:<ref>`, kind ∈ `test | diff | log |
review`, each explained in the file's Evidence section.

**`verified_by`**: `null` until verification, then `<verifier>@<date>`,
written only by the verification recorder, never the implementing session.

**Verifier protocol:** a separate clean-context session, given only the
task file and the diff/artifact, not the working notes. Mechanical
criteria are re-run, not re-read. On a pass the verifier writes
`status: done`; nobody else ever does. An implementer never verifies its
own task.

**Pull requests:** one PR = one task; the task file is the spec; anything
in the diff the task did not call for is scope creep by definition.
Binding prose (decisions, model changes, plan authoring) goes straight to
`main`, never inside implementation diffs. Merge gates in order: CI green
→ clean-context verification recorded → human review of judgment calls.
Merging is a human act. **Never squash**. Evidence cites SHAs.

**Naming.** *Names are derived, never invented*. Every identifier already
exists in a plan file, a date, or a task id, so two agents naming the same
thing produce the same string. A name you had to invent means something
upstream, a task or a decision, is missing. Naming friction is a scope alarm,
not a wording problem.

- **Branches:** `task/<layer>-<NN>`. No descriptive words; the task file
  carries the description. (`<layer>/<NN>` is unusable, git forbids a branch
  under a name that is itself a branch.)
- **Commits:** `<type>(<scope>): <what changed>`, lowercase, present tense, no
  period. Closed vocabulary: `feat` implements criteria, `fix` corrects a
  verified defect, `verify` records a verification, **`docs` is binding prose
  and goes straight to `main`, scope being the directory** (`docs(model):`),
  `checks` is repo self-checks, `chore` is tooling with no criteria. **A change
  with no clear type is two changes**, and binding prose spanning several
  directories is one commit per directory, so a contract change is never buried
  inside a research diff.
- **PR titles:** `<task-id>: <the task file's H1, verbatim>`. No "Add", no
  "Implement". A title you have to compose means no task exists for the work.
- **PR bodies:** three sections, headers verbatim. `## Criteria`: one line per
  acceptance criterion, how it was discharged. `## Judgment calls`: deviations
  with rationale, or "None.", which is a claim the verifier can falsify.
  `## Verification`: the verification record, `verified_by`, and the head SHA
  verified.
- **Log files:** `YYYY-MM-DD-<slug>.md`. Verification records
  `YYYY-MM-DD-<layer>-<NN>-verification.md`, carrying the task id, the head SHA
  verified, each criterion with how it was discharged, and the pass or fail.
  Recorded here so the first verifier does not invent it.
- **Migrations:** `NNNN-<kebab-noun-phrase>.sql`, naming what exists after, not
  what the migration does: `0002-roles-and-default-privileges`, never
  `0002-add-roles`.

**The fence.** A tool may rewrite `status`, `evidence` and `verified_by`.
Nothing else. Objective, scope, constraints and criteria are authored by a
human or an agent and read by tools, never rewritten by them.

**The grammar binds from 2026-08-19 forward.** Most earlier subjects on `main`
predate its enforcement and are left as they stand: rewriting them means
force-pushing a published branch, which costs more than the inconsistency.
Evidence cites SHAs, not subjects, so nothing depends on them.

**Grill-before-ready (this repo's addition):** promoting a layer to
`ready` requires a founder grilling session on that layer's design tree,
frontier questions with recommendations, jargon explained, rounds until
empty, recorded as a decisions-log entry. Task files are authored only
after the layer's grilling closes, and **in the same session that
grilled it, while its context is live**; a later cold session authoring
tasks is the drift case this rule exists to prevent (founder ruling,
2026-08-20, applied to self-asserted-record). First instance: decision 011
(foundation + trust-kernel).

**Grill-before-ready has a second half (added 2026-08-19).** A layer may not
go `ready`, and its task files may not be authored, until an engineering
review has run over the layer, `/plan-eng-review`, or an equivalent
architecture pass recorded the same way. The founder grilling settles *what*
the layer is for; the engineering review settles whether its criteria can be
executed and verified. Decision 042 records why: the first layer written
without one carried six criteria that this repo's own verifier protocol
could not check, and three scope items with no criterion at all.

## The executive loop

One **executive** session drives execution. It runs no task itself; it runs
the loop:

1. **Read the queue.** `node checks/run.mjs` is the only source of what is
   workable. The executive never re-derives status from prose, including
   from this file. Until the checks port lands (`plans/foundation/06`), there
   is no queue and therefore no loop. That port is the gate on everything
   below.

2. **Claim and dispatch.** Claim by writing `status: in_progress` (the write
   is the claim), then hand the task to an **implementer**, a fresh session
   given the task id and nothing else. One implementer per task; parallel
   implementers only on tasks with no shared `depends_on` frontier.

   **Every implementer works in its own worktree. The main checkout is a
   planning desk.** It holds plans, decisions, model and design edits, and
   nothing else. No implementer, and no executive, does code work in it.
   This is grain's rule and it is adopted because its absence has already
   cost this repo: on 2026-08-19 a second session checked out a branch in the
   main checkout while another was editing it, producing duplicate entry
   numbers in an append-only log.

   **Before editing anything in the main checkout, check for divergence:**
   `git fetch origin`, then read both `git log HEAD..origin/main` and
   `git log origin/main..HEAD`. If either is non-empty, surface it rather
   than pivoting silently.

3. **Verify.** When the implementer's PR is up, dispatch a **verifier**, a
   separate clean-context session that did not implement, given the task id
   only. It reads the criteria, the diff, and runs the outside check. On a
   pass it writes `status: done` and `verified_by`. Nobody else ever writes
   `done`. An implementer never verifies its own task, and the executive
   never verifies. It dispatched the work, so its context is contaminated
   by intent.

4. **Review the code.** `/code-review` runs on every PR after it is posted
   and before it may merge. This is a gate, not a courtesy: verification
   proves the task's criteria are met, and code review is the only step that
   reads the diff for what the criteria did not ask about.

5. **Present for merge.** Merging is a human act and stays one. The executive
   batches merge-ready PRs, every gate below green, with one-line
   judgment-call summaries, so founder review time goes to fit rather than
   mechanics.

6. **Aggregate raises.** An implementer that hits an unmade decision stops
   and raises. The executive collects raises, answers none itself, batches
   them to the founder, and marks the task honestly: `in_progress` with the
   raise noted if work can continue elsewhere in it, back to `ready` if not.

7. **Repeat** from 1 on every merge, raise resolution, or gate change.

**What the executive never does:** implement, verify, merge, answer a raise,
edit anything above a task's fence, or start work the queue does not list.
Its authority is dispatch and bookkeeping; every judgment stays with the role
that owns it.

**Merge gates, in order.** All four, every time:

1. CI green.
2. Clean-context verification recorded (`verified_by` written by the verifier).
3. `/code-review` run on the posted PR, findings resolved or explicitly accepted.
4. Human review of judgment calls, and the merge itself.

**Never squash.** Evidence and verification records cite SHAs.

## Founder gates

Artifacts only the founder can produce; the loop stalls visibly here
rather than one discovery at a time.

| Gate | Blocks | Owner state |
|---|---|---|
| T1 spike ruling (pre-committed rule in `t1-spike.md`) | none | **discharged (decision 012).** Go stands; switch-triggers carry forward as the guard |
| Worker-agreement terms (brief 4 stays on file as the question) | the first real worker; `durability-and-launch` criterion 3 config. Not the build | open; founder ruling backed by an internal research memo, no counsel is engaged or planned (decision 070) |
| Chrome/marks rulings (invariant ledger chrome; epistemic mark system) | `marks-and-embeds` going `ready`; `worker-surface` criterion 4 as written | open, drafted in session, awaiting ratification |
| **Cloud provider ruling** (AWS vs. GCP mini-litigation, decision 011 open item) | real provisioning; nothing local | open, litigation starts on founder go |
| **KMS conformance at provisioning** must include a cross-session destroy scenario: a scope destroyed by one client stays destroyed for a fresh client. The in-repo suite cannot prove durability across restarts (foundation/05 review) | first production use of the real KMS | open, runs with the provisioning gate |
| **Backup governance**: `copy/deletion.md`'s retention promise is enforced only by `db/backup.mjs` pruning; a dump taken outside that tooling is ungoverned. Runbook rule plus a counsel question on what "at most 30 days, ever" can honestly claim | real operations; the deletion copy shipping to a worker | open, operational rule needed before launch |
| Cloud accounts + KMS + WORM buckets provisioned (two clouds, separate account for object-lock) | `trust-kernel` checkpoint tasks against real infra; local/CI work is ungated (software-key provider per decision 011) | open, follows the provider ruling; founder-held billing |
| Persona/Sumsub DPAs signed (retention/destruction schedules per research/09) | live verification in `verification`; sandbox/stub work is ungated | open |
| **Mark open items**: lobe count, break angle, largest/smallest silhouette agreement (`DESIGN.md` gap 1) | `app-distribution` going `ready`; the app icon and every store asset (decision 039) | open |
| **Persona DPA, subprocessor scope** (decision 040 §C): 16 US subprocessors incl. Anthropic, OpenAI and Groq processing identity documents; plus India DPDP residency, unproven for both vendors | live verification in `verification`; sandbox work ungated | open; founder ruling on the vendor terms backed by an internal research memo, before contracting (decision 070) |
| **Imprint patent re-read** (decision 040 §F): `imprint/README.md` §8's non-interactivity limb no longer holds now the expanded imprint responds to touch | nothing in the build; a disclosure correction to counsel | open, counsel |
| PR merges (merge gate 3) | every task's completion | standing |
| Witnessed-log witness contract | nothing until the registry deadline nears (D3); listed so it is not discovered late | open, deferred |

## Decision gates

| Gate | Blocks | Status |
|---|---|---|
| Money-movement entity red line (decisions/LOG.md 010, open item) | nothing in v1, the ledger holds no funds. Listed because the first vertical payment feature proposal must hit this gate, not discover it | open |
| ~~Work-authorization rollout jurisdictions~~ | closed as moot: work authorization is not stored at all (decision 070, superseding 008's shape) | closed |
| grain retrofit sequencing (research/10 migration list) | nothing in v1, grain attaches through `integration-surface` when ruled | open |
| **The confidence threshold's numeric parameters** (form and publication ruled in decision 066: evidence-class-based, deterministic, published). Ruled against golden fixtures once the calibration task produces them | analytics criterion 3 discharging; not the layer going ready | open, narrows 022's gate |
| ~~The run-record pseudonym~~ | discharged: per-run random, never reused (decision 066) | closed |
| ~~The run-record spine/payload fork~~ | discharged: split across the planes, the fork task lives in analytics (decision 066) | closed |
| **Worker-facing job suggestions.** 42 U.S.C. §2000e(c) defines an employment agency as one who procures "for employees opportunities to work for an employer"; the suggestion surface is that definition, and it would make Grain a covered entity rather than a vendor (`research/14` §1.2) | the suggestion surface; `THESIS.md` §8's matching position | open, founder, and it inverts the earlier reasoning |
| **Antitrust.** A cross-employer performance register is a labour-market information exchange under the Jan 2025 DOJ/FTC guidelines, where third-party intermediation is expressly not a defence (`research/13` §6.6) | nothing in code; the thesis's risk section | open, founder, unscoped |
| **Is R2 regional?** India DPDP Rule 8(3) compels one year of retention surviving account deletion from ~May 2027 (`research/14` §2) | the deletion promise, `consent-and-deletion` copy, and the India rail | open; founder ruling backed by an internal research memo (decision 070), long lead |
| **Which set of seven measures is canonical.** Ratified interface 0.2 names one set; the imprint and every screen name another, and four of the seven are different constructs (decision 054). Recorded as an open divergence with both named, because choosing between two hypotheses with no evidence for either is what the pilot exists to end | ratifying interface 0.3; nothing that renders, since 054 renders none of it | open, founder, after the pilot |
| **What consent and the packet say about measures collected and not rendered** (decision 054). Attesting parties are still asked; nothing draws a level. The wording is not settled and is deliberately unwritten | `Consent` shipping at all: its fourth term promises levels that travel to a public page they no longer reach | open, founder |
| **Worker-supplied document evidence as a distinct class.** Contracts, stamped drawings, completion certificates. The only representation for real and unconfirmable work today is the absence of an attester, which falls on dissolved employers, informal work and cross-border history (decision 053) | nothing in v1; it is an addition to `model/`, not a gap in it | open, founder, and it needs counsel on what Grain asserts by accepting a document |
| **Whether the consent instrument can be split without weakening the consent Grain relies on** (decision 058). Just-in-time is better comprehension and, on its face, stronger consent; the brief stays on file as the question | `consent-and-deletion` going `ready` | open; founder ruling backed by an internal research memo (decision 070) |
| **The extraction engine ruling** (decisions 072/073). Names the model, its zero-data-retention terms, its residency posture, and the eval numbers it cleared. Discharges extraction criterion 7 and promotes its draft flip task | live extraction proposals; the stub path and everything else is ungated | open, founder, after the eval harness runs |
| **Postgres driver adoption** (decision 065). The trust-kernel/08 seam keeps the change to one file; compose-exec is fine for tests and unusable for production load. Trigger: before any layer serving external reads goes `ready`, so it is decided on schedule rather than in an incident | nothing in the current frontier; the first serving layer | open |
| **The mark set is not a total function** (decision 061). Five states cannot encode two peers and no business, an agency plus its client as two registered businesses, or a peer at a registered business that never answered, for which the legend's own sentence is false. Determinism is claimed on every surface; it holds for the drawn examples and not for the reachable space | `worker-surface` going `ready`; the packet's provenance field | open, founder, and it is a model question before it is a drawing |
| **A confirmation link makes a non-user the subject of a claim** (decision 061). Asking a manager to attest asked them to confirm a work address, and the copy took that as confirming their own time at the business: a person-record created as a side effect, upstream of any consent, for someone the product says does not need the app. The copy is withdrawn; whether the ledger may write anything at all about a third party from a confirmation is not settled | `peer-references`, and `public-web`'s attestation flow | open, founder, and it presses on entry 007's two-entity rule so it probably needs counsel |
| **"Imprint to human visitors, never to the index" needs a mechanism or a narrower claim** (decision 056, challenged in 061). Serving one thing to a person and another to a crawler on the same logged-out URL is user-agent detection, unverifiable from a design, brittle against a crawler that renders or spoofs, and the pattern search engines penalise | `public-web`'s reduced page | open, founder, and the honest fallback is that the figure is simply absent from the logged-out page |

## Work that has no layer

- **`checks/`**. Ported from Dispatch in `foundation`, exempt from the
  plan gate because it verifies the repo rather than the product.
- **Dispatch conformance.** The ratification notice
  (`handoff/ratification-notice-for-dispatch.md`) is Dispatch-repo work,
  tracked there, not here.
- **The slope disclosure text.** The three failure modes carried on every
  trajectory output (decision 022). Product copy with a correctness
  obligation; drafted nowhere, owned by `analytics`.
- **The Article 22 brief, rescoped.** `THESIS.md` §10 lists it as never
  scoped. In the UK the article no longer exists in that form: DUAA 2025 s.80
  replaced it with Arts. 22A–22D, in force 5 February 2026, and Art. 22C
  requires inform, representations, human intervention, and contest. The
  brief's question is now who owes that duty, Grain or the deployer,
  (`research/14` §3).
- **Counsel briefs 1–3.** Inform design; block nothing in code. Brief 2
  (salted commitments) must return before checkpoints go *public*;
  private WORM anchoring is ungated.

## Live risks, recorded rather than resolved

- **The human queues scale wall** (merge stewardship, disputes, vetting)
  is v1-thin by design; the risk is forgetting it is a product line, not
  an ops afterthought. The trigger for building it out: any queue's
  latency becoming worker-visible.
- **T1 inverts D2.** If Go's measured defect rate is materially worse,
  trust-kernel re-plans onto the TS+Go-oracle hybrid, priced, bounded,
  and pre-agreed, but a real re-plan of one layer.
