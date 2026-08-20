# foundation — layer-close verification (2026-08-19)

- Layer: `plans/foundation/LAYER.md`
- Verifier: layer-close verifier, clean-context session, 2026-08-19. Verified
  none of the tasks itself; inputs were the layer file, ORDER.md's status
  vocabulary, every task's frontmatter, and each task's verification log read
  for the section that discharges the claimed criterion — the join checked
  semantically, not just by number.
- Main at close: `9f2383cf5597b0dc32911a6a2d5ed69b04bb6626`
  (foundation/08 merge, PR #8).
- Verdict: **PASS** — every criterion discharged by a `done`, verified task;
  every scope clause landed or deferred by a recorded decision; full checks
  run, `make check`, and CI all green on current main.

## Criteria roll-up

Every criterion is claimed (`satisfies`) by at least one task with
`status: done`, `verified_by` written by a clean-context verifier, and
evidence resolving to a verification log whose content discharges that
criterion.

| Criterion | Task (done, verified) | Evidence | How discharged |
|---|---|---|---|
| 1 — append-only enforced by the database | foundation/03 | `log/2026-08-19-foundation-03-verification.md` (PR #3 @ `eef3d59`) | Standing proof re-run: 18 assertions on both planes; verifier's own later table and second-owner/second-schema probes inherited the restriction with no manual step; exemption gating proven by planting an unenumerated grant (test fails until the EXEMPTIONS list is edited); SECURITY DEFINER scan and serving-credentials boundary probed |
| 2 — migration chain replays from empty; types match | foundation/02 | `log/2026-08-19-foundation-02-verification.md` (PR #2 @ `11b1b2f`) | `make migrate-verify` re-run: both chains from empty twice, second pass a no-op, byte-identical schema dumps; `typegen --check` green, and the verifier's own live-schema alteration made it fail until reverted |
| 3 — no spine column type outside the allow-list, exceptions justified | foundation/04 | `log/2026-08-19-foundation-04-verification.md` (PR #4 @ `638a51a`) | `checks/spine-schema.mjs` green live; verifier's own plants (bare type, unjustified exception, stale exception, decoy justification block) each fail naming the rule; red suites green |
| 4 — every payload row knows its region | foundation/04 | same log | `checks/payload-residency.mjs` green; verifier's plants (table without `residency_region`, row disagreeing with the declared region) each fail |
| 5 — interrupted cross-plane write leaves nothing half-done | foundation/07 | `log/2026-08-19-foundation-07-verification.md` (PR #7 @ `ad2ad82`) | Outbox harness re-run (45 assertions): kills at every window recovered by plain drain with no duplicate; idempotent re-apply proven at the database (UNIQUE + ON CONFLICT); permanent failure surfaces through the reconciler (exit 1 + QUEUE line, no silent backlog); nothing acknowledged before both planes durable, confirmed under the verifier's own indefinite stall and real SIGKILLs |
| 6 — restored backup does not resurrect deleted payloads | foundation/08 | `log/2026-08-19-foundation-08-verification.md` (PR #8 @ `db0dd64`) | Verifier's own driven sequence: byte-level resurrection reproduced on restore, unreplayed restore refuses traffic (`ErrNotServing`), replay re-applies the journaled destruction, post-replay reads fail closed AND the registry-bypass unwrap fails at the crypto-shred; dumps of both planes grep clean; living person intact |
| 7 — key destruction destroys readability; subject-keyed, no second wrap | foundation/08 (claims it), with the destroy-path core evidenced by foundation/05 | 08's log (restore side) + `log/2026-08-19-foundation-05-verification.md` (PR #5 @ `e91daf5`, header: "layer criterion foundation-7") | 05: `TestDestroyLeavesNothingReadable` under both providers — read, write, provision, and registry-bypass provider `Unwrap` all fail closed (crypto-shred, stronger than a dump grep, which also holds); `TestTwoPersonRowKeyedToSubjectAlone` plus registry schema inspection (one key column, one person column — a second wrap is unrepresentable). 08 extends the same guarantee through the backup/restore path |
| 8 — no spine column re-identifies a person on its own (adjudicated) | foundation/04 | 04's log, "Criterion 8 adjudication" section | Judged from foundation/04's correlation checklist and the spine schema alone (payload not consulted): every live column answered against all five questions, cross-column correlation considered, the three domains' pre-answered checklists correctly defer per-column review to first use; justification honesty assessed. PASS recorded, reaffirmed unchanged at the review-fix head |

Notes on the join:

- foundation/01 (`satisfies: []`) carries no criterion — it is scaffolding;
  done and verified (`log/2026-08-19-foundation-01-verification.md`, PR #1).
- foundation/05's frontmatter reads `satisfies: []` although its verification
  log explicitly targets layer criterion foundation-7. The criterion is
  formally claimed by foundation/08 (`satisfies: [6, 7]`), so no criterion is
  unclaimed; the empty list on 05 is a frontmatter omission, observed here and
  left for a docs commit — the fence puts `satisfies` outside what a verifier
  may rewrite.
- foundation/09 (`satisfies: [8]`) is `abandoned` with the reason in its body,
  which is exactly what ORDER.md's vocabulary requires. Criterion 8 remains
  claimed and discharged by foundation/04.

## Scope walk

Every clause of the layer's scope paragraph, and where it landed:

- **Monorepo layout (Go core / TS surfaces / contract schema per D2)** —
  foundation/01, PR #1.
- **CI ordered as a dependency graph, metadata checks before any database
  boots** — foundation/01 (pipeline), completed by foundation/06 (the runner's
  metadata group runs with compose down, proven in 06's log AC 3), PRs #1/#6.
- **Spine/payload physical split, one shared migration numbering sequence,
  `residency_region` stamped from row one** — foundation/04 (split and
  residency, PR #4) on foundation/02's harness (shared numbering enforced by
  `checks/migration-numbers.mjs`, PR #2).
- **Append-only enforcement: default-privilege inheritance across both
  databases and multiple schemas, per-table exemptions to a named role,
  operational boundaries (no owner credentials in serving trees, SECURITY
  DEFINER may only INSERT)** — foundation/03, PR #3.
- **Cross-plane write consistency: spine-first transactional outbox,
  idempotent apply, reconciler, no compensation path** — foundation/07, PR #7.
- **Subject-scoped per-person DEK envelope encryption** — foundation/05,
  PR #5.
- **Deletion mechanics: scheduled physical purge, bounded backup retention,
  mandatory restore-time deletion replay** — foundation/08, PR #8.
- **Spine linkage threat model** — cut on founder ruling 2026-08-18: the
  standing-document shape was abandoned (foundation/09, reason in body) and
  the correlation questions moved into foundation/04 as the per-column
  reviewer checklist, which is the artifact criterion 8's own text names and
  the adjudication in 04's log applied. The clause is discharged in that
  form, not dropped.
- **Mechanical checks adapted from Dispatch (plan-graph, migration-numbers,
  migration-order, decisions-index, schema-grep)** — foundation/06, PR #6
  (schema-grep landing as `spine-schema`/`scored-columns`).
- **Managed Postgres provisioning** — explicitly out of scope in the layer's
  own text; it stands as a founder gate in ORDER.md. Nothing here required
  cloud credentials, and every verification log records a credential-free
  environment.

Deferral: **the run-record spine/payload fork** (decision 026) was carried in
ORDER.md as "a `foundation` task nobody owns". Decision 043 defers it to
`analytics` by founder ruling — "`foundation` may close without it" —
and `analytics` cannot go `ready` without owning it. Cited, not silently
dropped.

Other layers' items: the two device spikes named in `plans/app-shell` and
`design/09-app-framework-evaluation.md` belong to those layers; nothing in
this layer's text claims either (grep of `plans/foundation/` finds no
reference).

## Mechanical state at close

On current main (`9f2383c`), fresh clone, both planes booted from empty under
a verifier-local no-ports compose override (sibling worktrees held the host
ports — established precedent; everything speaks `docker compose exec`):

- `make check` — green end to end (`check: green`, exit 0), including both
  acceptance suites, envelope under both key providers, the outbox scenarios,
  and the deletion suite.
- `node checks/run.mjs` (full run, planes migrated) — every check green:
  frontmatter, plan-graph, decisions-index, migration-numbers,
  migration-order, verbatim-copies, counts, serving-credentials,
  cross-schema-queries, cross-plane-constructs, deletion-copy, spine-schema
  (15 columns), payload-residency (5 tables), scored-columns (38 columns).
  Frontier empty pre-close: every remaining ready task blocked on the
  foundation layer gate, which is the state this record changes.
- CI — run 32315427029 at the latest main commit (`9f2383c`, the PR #8
  merge): completed, success.

## Frontier after the flip

`node checks/run.mjs --metadata` re-run after `status: done` was written:
workable = `trust-kernel/01`, `trust-kernel/06`, `person-identity/01` — the
layer gate releasing exactly the tasks whose own dependencies were already
satisfied, matching foundation/06's perturbation prediction. (Recorded after
the frontmatter edit; see the commit this file lands in.)
