# foundation/06: clean-context verification

- Task: `plans/foundation/06-checks-port.md`
- PR: #6, branch `task/foundation-06`
- Head SHA verified: `97b90f18f78b7a1a002fe66b8858adfefe16655f`
- Verifier: clean-context session, 2026-08-19. Fresh clone; no implementer
  transcripts consulted; no cloud credentials. CI at this SHA: every job
  green, including the reshaped `repo metadata (before any database)` and
  `red-path fixtures (database stage disabled)` jobs (run 32308806437).
- Verdict: **PASS**. Every mechanical criterion re-run green, the outside
  check re-run with the verifier's own plants (not the shipped fixtures),
  the frontier derived independently by hand and matched line for line,
  every judgment call sound, the one semantic conflict raised rather than
  silently chosen.

## Scope check

Diff vs `origin/main` (merge-base `d5dcbe3`), three commits: new checks
(`plan-graph`, `decisions-index`, `migration-order`, `verbatim-copies`,
`counts`, `scored-columns`, `run`), `frontmatter.mjs` extended to full
vocabulary validation, one shared helper (`checks/lib/plan-files.mjs`),
green/red fixtures under `test/fixtures/`, and additive Makefile/CI wiring
(`metadata` becomes the runner; `scored-columns` joins the db stage; red
paths 7–11 and db 8). Every file is inside the task's footprint or the
checks exemption; no product code, no migrations, no plan-prose edits
inside the implementation diff. No scope creep found.

## Mechanical outcomes (re-run, not re-read)

All commands in a fresh clone at the head SHA. Host ports 5433/5434 were
held by sibling sessions, so a verifier-local compose override dropped the
host bindings (foundation/04/05 verifier precedent).

1. **AC 3, metadata group with no database.** `docker compose ps` empty,
   then `node checks/run.mjs --metadata` → all nine metadata checks green,
   frontier printed, exit 0. `make metadata` is exactly that command.
2. **AC 1, full run on the real repo.** Both planes booted and migrated,
   `node checks/run.mjs` → all checks green including the three schema
   checks, frontier printed, exit 0.
3. **AC 1, synthetic fixture tree.** `node checks/plan-graph.mjs
   test/fixtures/frontier/plans` → workable `alpha/02`, `beta/01`; blocked
   `alpha/03` (dep ready), `beta/02` (dep unauthored under draft layer),
   `delta/01` (layer gate); `delta/01` absent from the frontier. Derived
   by hand from the fixture frontmatter first; matched exactly. Red path
   7b asserts the same lines mechanically.
4. **AC 2, shipped red paths.** `make check-red` → exit 0 end to end
   (red paths 1–11 all fail as required, green fixtures pass);
   `make check-red-db` → exit 0 (planted `trust_score` column fails
   `scored-columns` naming the rule, dropped, green again, databases left
   as found).

## The outside check, with the verifier's own plants

One violation per check, planted by the verifier in the clone (not the
shipped fixtures), each caught with a message naming the rule, each
reverted:

1. **Scrambled status.** `status: wobbling` in `foundation/08` →
   `frontmatter` FAIL: "outside the ORDER.md vocabulary (blocked is
   computed, never stored)".
2. **Dependency cycle.** `trust-kernel/05` added to `foundation/08`'s
   deps (05 already depends on foundation/08) → `plan-graph` FAIL: "task
   dependency cycle: foundation/08 -> trust-kernel/05 -> foundation/08".
3. **Duplicate decision number.** A second `## 044` appended →
   `decisions-index` FAIL: "entry 044 appears twice … append-only and
   numbered, a number is used once".
4. **Unmarked gap.** Entry 045 renumbered to 047 → FAIL on both 045 and
   046: "missing and not marked never assigned".
5. **Migration number collision.** `spine/0002-planted-collision.sql` →
   `migration-numbers` FAIL: "number 0002 used twice under the shared
   sequence".
6. **Out-of-order cross-layer reference.** `spine/0001` referencing
   `spine_object_id` (created by `spine/0003`) → `migration-order` FAIL
   naming decision 017's shared sequence. A first mis-namespaced plant
   (a payload object referenced from the spine chain) correctly did NOT
   fail. The chain-namespace rule behaves as documented.
7. **Scored column.** `capability_tier` planted in payload →
   `scored-columns` FAIL citing CLAUDE.md and decision 025; dropped,
   green again.

## Independent frontier derivation

Derived by hand from every plan file's frontmatter before reading the
runner's output, under the strict layer-gate semantics: layers foundation,
trust-kernel, party-registry, person-identity `ready`, all others `draft`;
ready tasks enumerated with each dep's status. Result: workable **empty**
(everything eligible is claimed, foundation/05, /06, /07 `in_progress`);
every remaining ready task blocked by a layer gate (`foundation is not
done`, plus `trust-kernel is not done` for party-registry), a non-done
task dep, or an unauthored dep under a draft layer (`ingestion/01`,
`verification/01`, `consent-and-deletion/01`); `foundation/09`
(`abandoned`) correctly absent. The printed frontier, claimed line, and
all blocked lines matched the derivation exactly, reason for reason.

Perturbation (on a copy of `plans/`, never the real tree): flipping
foundation/05 and /07 to `done` made exactly `foundation/08` workable, as
the strict semantics predict; additionally flipping the foundation layer
to `done` opened `trust-kernel/01`, `trust-kernel/06`, and
`person-identity/01`, the layer gate releasing precisely the tasks whose
task-deps were already satisfied. (Edge observed, not a defect: a layer
marked `done` while still holding ready tasks blocks its own tasks with
"layer … is not ready", an inconsistent input state producing a
conservative output.)

## The marked-gap mechanism, judged

The real log passes with 029/030 recognized from the italic note; the
verifier's unmarked-gap plant fails; the shipped contradicted-marker
fixture fails. Probed for spoofability: deleting a real entry (017) and
appending a bare `*Number 017 was never assigned.*` at the end of the file
**passes the check**. The marker is form-keyed and position-independent.
Judged honest nonetheless: the check's header explicitly scopes itself to
"what a file snapshot can prove", the contradiction guard catches the
accidental case, and the deliberate case is a two-part edit to an
append-only file that lands as a straight-to-main docs commit where the
diff is the evidence. Snapshot checking cannot prove append-only-ness
against deliberate deletion; git history remains the real guarantee. The
limitation is inherent and disclosed, not a shortcut. Recorded here so
nobody mistakes the green check for tamper-proofness.

## Counts false-positive sweep

`node checks/counts.mjs plans model DESIGN.md` → zero failures on the real
trees. Frozen counts confirmed unflagged: decisions/LOG.md entries 017
("6 → 9 tasks") and 019 ("5 → 7 tasks") are outside the scanned roots;
`plans/t1-spike.md` is skipped by its `**Discharged` banner. A fresh
plant ("All six criteria below are final." inserted immediately before
foundation's criteria list) → FAIL at the planted line, naming CLAUDE.md.

## Judgment calls, assessed

- **Strict layer-gate + RAISE.** Sound, and the raise is the point.
  ORDER.md genuinely underdetermines the semantics: the status vocabulary
  says a task is "eligible the moment `depends_on` are `done`", while
  layers carry `depends_on` that something must consume, and the
  "prior-packet task … starts the moment that schema lands" sentence
  reads as the looser semantics. No decisions entry rules it. The strict
  default is the correct conservative choice pending a ruling. It
  under-dispatches (recoverable) rather than dispatching work a ruling
  may make ineligible, and it is surfaced three times over: the PR
  body's RAISE, the check's own header comment, and the blocked lines the
  frontier prints. Handled per protocol; the founder ruling remains open.
- **`migration-order` from landed SQL only.** Correct. The
  dependency-proxy inversion is real and verified in the claim ledger:
  `person-identity/01` claims `0010` while depending on `foundation/07`'s
  `0020`. Only an actual reference constrains order. The spec's live
  example (0014 → 0009) is enforced the moment both land as SQL, and red
  path 9 proves the mechanism today.
- **decisions-index ignores file order.** Correct; entries 012–014 stand
  out of numeric order on `main`, frozen by ORDER.md's forward-binding
  grammar. Numbering, not position, is what evidence cites.
- **`soft_blocks` admitted, flagged for a docs fix.** Legitimate.
  Verified live on `main` (`plans/app-shell/LAYER.md`); rejecting it
  would fail the current tree from inside an implementation PR, and the
  binding-prose rule keeps the ORDER.md fix out of this diff. The
  one-line `docs(plans)` commit is still owed.
- **counts vocabulary narrowing.** Sound and disclosed in the check's
  header with its tuning history. Residual risk (a checkable noun outside
  the vocabulary drifts unflagged) is named there with the instruction to
  extend the vocabulary.
- **Verbatim label grammar restated.** Acceptable; the Dispatch source
  was not in the handoff, the grammar binds forward, and both directions
  are proven by fixtures despite the live tree carrying zero quotes.

## Criteria

| Criterion | Outcome |
|---|---|
| AC 1 (mechanical): full run green on the real repo; correct frontier for the synthetic tree | PASS, re-run; frontier hand-derived and matched |
| AC 2: each check fails a planted violation, one fixture per check, in CI | PASS, CI red-path jobs green at the SHA; both suites re-run locally; seven verifier-planted violations all caught |
| AC 3 (mechanical): metadata group completes with no database | PASS, re-run with compose down |

## Delta re-verification at the review-fix and integration head

- Final head SHA verified: `bd9e97703b82f9d2bcbfa234ce8f538486117719`
  (supersedes `97b90f1` above as the verified SHA). CI fully green at
  this head, including the metadata and red-path jobs.
- Verdict: **PASS**. Every hunk in `97b90f1..bd9e977` partitions into
  the three permitted buckets; nothing outside them.

**Bucket partition.** The branch's own delta is one commit plus two
merges:

- *(a) Review fixes*: `29f1c34`, exactly as described: red path 1 now
  writes the frontmatter failures to a file and red path 1b greps for
  every foundation/06 validation message by name; new fixture
  `test/fixtures/redpath/plans/broken-layer/03-done-unevidenced.md`
  (done with empty evidence and null verified_by, both completion
  rules); check-red-db gains a green path exercising
  `node checks/run.mjs --schema` and the bare form, asserting the
  frontier prints exactly once. Touches only the Makefile and the new
  fixture.
- *(b) Faithful main content*: everything else in the range arrived via
  the merges `b9d237b` and `bd9e977` and is verbatim main (foundation/05
  PR #5, the foundation/07 chain and PR #7, decisions 046–048, design
  commits, the soft_blocks docs fix, the foundation/08 claim).
  `--remerge-diff` on both merges shows hand-resolution confined to the
  Makefile (merge 1) and Makefile + `checks/run.mjs` (merge 2); every
  other file auto-merged.
- *(c) Conflict resolutions*: unions, with nothing dropped: merge 1
  keeps `scored-columns` (branch) alongside `envelope-test` (main);
  merge 2 keeps both alongside `cross-plane-constructs`/
  `cross-plane-outbox` (main), renumbers main's red path 7 → 12 and
  db 8/8b → 9/9b, and, the coverage question, moves main's
  `cross-plane-constructs.mjs` metadata-target line into the runner's
  METADATA group in `checks/run.mjs`, so the check runs in
  `make metadata` via the runner rather than being dropped. Set-diff of
  Makefile targets and CI jobs/steps: the merged head is the exact union
  of both parents on both counts (`scored-columns` retained in
  db-migrate; `outbox` and `envelope` jobs retained from main).

**Re-runs in a fresh clone at `bd9e977`** (ports override as before):

- `make check-red` → exit 0; every red path 1b grep observed hitting its
  message.
- *The blocking fix proven by gutting*: with the empty-evidence
  validation disabled in the clone's `frontmatter.mjs`, red path 1
  still passes (the fixture trips other rules) but red path 1b fails at
  exactly the `status done with empty evidence` grep. The per-message
  greps catch what the aggregate exit code provably cannot. Restored;
  green again.
- `make check-red-db` → exit 0, including the new green path
  (`--schema` group green; bare run's frontier printed exactly once).
- `node checks/run.mjs` (bare, both planes up) → all checks green,
  `cross-plane-constructs` now in the metadata group, frontier prints
  `claimed (in_progress): foundation/08`, the correct queue now that
  foundation/05, /06 and /07 are done and /08 is claimed.
- `make check` → green end to end.

**Judgment call in the PR body.** The invented `checks(pipeline)` scope
is recorded there as an accepted deviation from the derived-names rule;
it is disclosure, not drift, and the commit type itself (`checks`) is in
the closed vocabulary. Accepted.

**Recording note.** At recording time the main checkout carried six
unpushed docs commits from a parallel design session
(`3d616b4..c402ece`, decisions 049–050 and design prose). Binding prose
goes straight to main by rule, a fast-forward push loses nothing, and an
unpushed verification record would break the links this file's evidence
carries, so this record's push carries them. Surfaced here and in the
verifier's report rather than silently.
