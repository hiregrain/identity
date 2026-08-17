# Infra Comparison: Ledger Rulings vs. grain vs. Dispatch (2026-08-17)

Compares the ledger's ratified infrastructure decisions (decisions 005–006,
`design/stack-litigation/docket-rulings-0.1.md`) against the actual,
repo-verified decisions of `hiregrain/grain` (production hospitality
product) and `hiregrain/dispatch` (first vertical, pre-production codebase).
Evidence gathered by read-only exploration of both repos this session.
Evidence tier — binds nothing.

## Headline

Dispatch and the ledger converged independently on nearly every
load-bearing choice — including the *identical* append-only enforcement
mechanism — which is the handoff protocol's strongest possible validation.
grain, built earlier under prototype constraints, diverges on exactly the
axes the ledger litigated hardest: mutable reputation rows, phone-anchored
identity, no cryptographic integrity, no durability posture. None of
grain's divergences are surprising; all are now enumerable migration work
for the day grain conforms as a vertical.

## Where all three agree (and the ledger docket is confirmed)

| Axis | Ledger (ratified) | Dispatch | grain |
|---|---|---|---|
| Relational Postgres as system of record | D1: managed Postgres | Postgres 17, `pg` driver | Supabase Postgres |
| One deployable, no microservices | Convergence item 2 | Decision 28: "one deployable" default; splitting later is mechanical | Express monolith, jobs in-process |
| No broker as source of truth | Convergence item 3 | Decision 26 rejected event sourcing | Outbox→pgmq is delivery, not sourcing |
| Derived state never stored as truth | Standing = derived, citation-backed cache | AC-REP-1/2/3: mechanical drop-and-recompute checks; distributions, never points; "tier stored = promotion becomes administrative" | `CandidateScore` is a recomputable materialization |
| Deletion is engineered and itself recorded | Saga + DEK shred + `PayloadPurged` event | Deletable-capture class; deletion recorded as a fact | Grace window, anonymize/hard-delete, retraction propagation + counterparty recompute, deletion audit log, DSAR/PII registry |

The deletion row deserves emphasis: **grain's deletion machinery is the
most production-proven of the three** — its `retracted_due_to_deletion`
status + counterparty-recompute pipeline is the ledger's
supersession-plus-derived-recompute pattern already working in production.

## Ledger ↔ Dispatch: near-total convergence, three notable deltas

**Identical, independently:** append-only enforced by `REVOKE UPDATE,
DELETE` on the application role with default-privileges inheritance
(Dispatch decision 26 + migrations 0002/0006 + `append-only.test.ts` ≡
ledger convergence item 5); opaque never-reused person ID with
`identity_proofs` as a list so no provider becomes the primary key
(`model/party.md` ≡ ledger §1.1); verification bought, attestation stored;
no capability facts on identity; write-once columns with transition tables
(Dispatch even shipped the mutable version once, then fixed it — the
pattern is battle-scarred, not theoretical); evaluation bases never pooled;
derived lifecycle projections instead of status columns.

**Delta 1 — event sourcing.** Dispatch decision 26 explicitly *rejected*
event sourcing (on construction cost, honestly argued); the ledger's
litigation absorbed the log-centric school's semantics (events-as-rows,
rebuildable projections, per-stream chains) while also landing on plain
relational Postgres. These are compatible in substance — both are
"append-only rows + derived views" — but the ledger's event-catalog
formalism is stricter. No conflict; a vocabulary difference worth not
letting drift into a real one.

**Delta 2 — language.** Dispatch is strict TypeScript with a
one-dependency discipline (`pg` only — spiritually the same supply-chain
posture that decided D2). The ledger core is Go (T1-gated). No rewrite
implied: Dispatch touches the ledger only through the interface schema and
its canonicalization test vectors, which are deliberately language-neutral.
Dispatch's minimal-dep discipline shows TS *can* be run kernel-safe; D2's
ruling stands on verification-path poisoning risk, but Dispatch's practice
is the strongest available counterexample if T1 reopens the question.

**Delta 3 — the signature hole, now filled.** Dispatch self-declares the
attestation signature mechanism as "a field in the schema and no decided
implementation" (deferred with its entry-28 family). The ledger's R-3
(Ed25519/JWS + registry + hash-chain timestamp) and D4 (party-held keys)
are the answer; Dispatch will need party registration and a signing key
when it becomes a live attesting party — this lands on Dispatch's
conformance list alongside the ratification-notice items.

**Worth importing FROM Dispatch** (offered conventions, now with evidence
they work): decision 50's scale rule ("semantics must survive scale;
mechanisms may be scale-limited only if the limit is stated at the site
with a named replacement") — this is the ledger convergence-map philosophy
as an enforceable review question; the mechanical self-checks
(decisions-index drift check, verbatim-copy diff, the AC-04.3 schema-grep
that mechanically bans capability-score columns on fact tables);
SECURITY-DEFINER recording functions as the application's only insert path
(matches the ledger's ingestion-validation design and enforces what table
constraints can't); early-capture columns (decision 31) as the cheap form
of optionality the reportability hook also embodies.

## Ledger ↔ grain: the divergences are the migration list

| Axis | grain today (verified) | Ledger ruling | Migration implication |
|---|---|---|---|
| Reputation mutability | `WorkHistory` worker-editable incl. DELETE via RLS; `WorkHistoryVerification` mutated in place through a status state machine; enforcement is RLS + one partial unique index — no revoked privileges on any reputation table | Claims freeze on verification; attestations append-only from birth, enforced by DB privileges | The core retrofit: verified rows must freeze; in-place status transitions become superseding records. grain's status enum maps cleanly onto supersession + dispute annotations, but the write paths and RLS grants all change |
| Identity anchor | `User.id` + phone at `phone_control` grade (ADR-0001); SIM-swap accepted as residual risk | Opaque ID; phone never an anchor, only a decaying channel signal | grain's `phoneVerificationChannel` grades translate directly into ledger verification attestations (`issuer=grain, method=sms_otp, level=channel`) — the crosswalk is clean; the *anchor* role moves to `ledger_person_id` |
| Cryptographic integrity | None on reputation data (content-address hashes in the ops audit log only); env-var key management; one unauthenticated AES-CTR use already flagged internally | Ed25519/JWS, per-stream chains, ≤5-min WORM checkpoints, KMS-only keys | grain never needs to build this — as a vertical it consumes the ledger's machinery; its own rows stay vertical-local per the no-shadow rule |
| Durability | Supabase **Free tier: no backups, no PITR**, self-documented tripwire "before the first real pilot data lands"; plus unencrypted prod dumps on a laptop (flagged earlier this session) | D1 launch obligations: ack watermark, escrow watermark; "zero acknowledged loss" is a contractual promise | grain's posture is disqualifying for anything ledger-adjacent and, per its own tripwire, overdue for its own data. Cheapest real risk reduction available anywhere in the portfolio |
| Multi-region/residency | None, single region, no residency concept | Residency-stamped payload rows from row one | grain is PH-relevant (blue-collar expansion): when it attaches, its worker PII joins the regional payload plane; nothing to retrofit if attachment goes through the interface rather than schema merge |

**Worth importing FROM grain** (real prior art the ledger design lacked):

1. **The shadow-engine + promotion-gate pattern.** grain runs its new
   trust computation in shadow against the live one, logs divergence
   (`TrustShadowOuterActiveLog`), and promotes only after a six-condition
   gate (determinism, convergence caps, calibration window, cold-start
   density). This is exactly how the ledger's dimension-standing derivation
   rule and party-reliability signals should be introduced and recalibrated
   — a concrete mechanism for design 0.1's "recalibrate after two
   verticals" promise.
2. **Deletion propagation as a product feature.** Retraction of evidence
   the deleted person *provided to others*, with counterparty recompute
   queues and durable external-asset cleanup — the ledger's copy-map/saga
   design, already debugged in production.
3. **Trust-grade exclusion semantics.** `outerTrustGrade='excluded'` —
   evidence retained but excluded from live computation — is the right
   shape for the ledger's ingestion-time Sybil signals (record everything,
   weight at read), consistent with append-only.

## Bottom line

- The ratified docket is **confirmed** by Dispatch's independent
  convergence and **unthreatened** by grain's divergences, which are
  prototype-era choices on exactly the axes the ledger exists to own.
- Three adoption candidates for the ledger's own conventions: Dispatch's
  decision-50 scale rule, its mechanical self-checks, and grain's
  shadow/promotion-gate calibration pattern.
- Two action-shaped flags outside this repo: grain's backup tier (overdue
  by its own tripwire) and Dispatch's attesting-party onboarding
  (key + registration) when it goes live against the ratified interface.
