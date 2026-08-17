# D1 Advocate Brief: Managed Postgres as System of Record

Advocate for the 5-school bloc position (D1, `convergence-map.md`): managed
Postgres as the system of record, against distributed SQL (Spanner primary /
CockroachDB alternative) from day one. Clean context. Inputs: the convergence
map, `ledger-design-0.1.md`, all six stack perspectives, and web research on
migration case law. The opposing brief's strongest text is
`stack-perspectives/planet-scale.md` §"Where the boring-Postgres school
actually dies"; it is engaged at its strongest form below, not a weakened one.

Operating facts: founder + 2 engineers, AI-build-heavy; ~1M identities in
months, ~10⁸ in ~2 years, planet scale as stated target.

---

## TLDR — the verdict argued for

**Adopt managed Postgres as the system of record, and adopt nearly the entire
planet-scale *shape* doctrine while rejecting its *engine* conclusion.** The
four shape arguments (residency, RPO-zero, read locality, TrueTime) are the
best pro-Spanner case ever likely to be made for this system, and each one,
examined against the architecture all six perspectives independently converged
on — tiny no-PII global spine, per-region payload databases, per-subject/
per-party chains, durable idempotent ingest queue, externally escrowed signed
checkpoints — either dissolves or reduces to a bounded engineering artifact
Postgres carries:

1. **Residency** is not a retrofit in this architecture: `residency_region`
   is in the payload primary key from row one and regional databases are
   IaC-stamped modules. The erasure path is a saga in *every* stack, because
   deletion must reach CDC topics, indexes, lakehouse, and backups that no
   database's transactional domain covers — Spanner does not make erasure
   atomic; it makes one of thirteen copy-map entries atomic.
2. **RPO-zero on the spine** is really "RPO-zero *for acknowledged
   attestations*," a strictly weaker property deliverable on managed Postgres
   with two durability watermarks (ack gating, checkpoint-escrow gating) plus
   the idempotent replay queue everyone already mandates. The per-party-chain
   failure walk in §3 shows the true residue is a receipt-finality protocol —
   which the D3 transparency log requires anyway.
3. **Stage-C read locality** contradicts the residency argument for payloads
   (data pinned in-region cannot also be replicated near readers), so it
   applies only to the spine and registry — small, no-PII, and trivially
   read-replicated in Postgres. In-region packet assembly plus one
   cross-region hop fits the 400ms budget with margin.
4. **TrueTime** is the operator's own clock and convinces no adversary the
   hash chain doesn't; the trustworthy ordering authority for the
   compromise-vs-backdating rule is the *externally witnessed checkpoint*
   (D3), at seconds granularity, which is stack-independent — and human
   key-compromise reporting is hours-grained anyway.

The migration cost, honestly researched (§4): a person-partitioned append-only
spine is close to the friendliest migration shape in databases — but it is a
one-to-two-quarter project, not a footnote. Against it stands the documented
cost of the opposite error: Motion and ZITADEL both executed *reverse*
migrations off CockroachDB after paying 3–5× cost and latency premiums for
distribution they never used. The asymmetry of regret favors Postgres now with
measurable switch triggers (§6).

---

## 1. What is already settled and adopted, not relitigated

The convergence map settles the load question (30–250 writes/s sustained even
at 10⁸–10⁹; the planet-scale author refuses the QPS argument and so does this
brief) and settles the shape: physical spine/payload split, residency key from
row one, per-subject/per-party chains with Merkle checkpoints, subject
partitioning, hash-prefixed or random IDs, durable idempotent ingest queue,
append-only enforced at the privilege level, cross-cloud checkpoint escrow.
**This brief adopts all of it.** The planet-scale perspective's "must be right
on day one" list (its items 1–8) is correct in seven of eight parts; the
dispute is confined to whether those properties require a distributed-SQL
engine. They do not, and in one case (residency vs. read locality) the
pro-Spanner arguments require contradictory data placements.

---

## 2. The four shape arguments, steelmanned and broken

### 2.1 Residency: "retrofit becomes hand-rolled cross-region coordination on the erasure path"

**Steelman.** The moment counsel designates the first in-country payload
requirement, single-region Postgres is architecturally noncompliant. The
Postgres answer is N regional databases plus application-level transactional
writes across spine-DB and payload-DB — two-phase commit you wrote yourself,
on the erasure-critical path, rewritten under a compliance deadline at stage
B. In Spanner/CRDB it is a placement policy (`REGIONAL BY ROW`); one
transactional domain covers spine tombstone and payload delete atomically.

**Rebuttal.**

*First: the premise "retrofit" is false for the architecture on the table.*
The settled design stamps `residency_region` into every payload primary key
from row one and stamps out regional infrastructure from one IaC module
(data-platform §3.1). Adding partition N+1 is the documented playbook: copy
rows where `residency_region='PH'`, flip routing, delete from source — itself
a copy-map operation. The planet-scale argument is aimed at a strawman (one
global Postgres with PII everywhere, region key added later) that all five
Postgres-family perspectives independently vetoed. What arrives with a
regulator's deadline is a *deploy*, not a migration, because the migration was
paid for at 10³ rows.

*Second: erasure is a saga in every stack, so "atomic erasure" is not on
offer from anyone.* The copy map (data-platform §2.1) enumerates thirteen
copy classes an R2 deletion must reach: primary, replicas, WAL/PITR, backups,
CDC topics, lakehouse bronze/silver/gold, blocking indexes, feature rows,
training snapshots, caches, logs, delivered packets, spine tombstone. Spanner
holds exactly two of them. Buying Spanner converts the deletion saga from
thirteen coordinated steps to twelve. The saga engine — idempotent per-copy
tasks, acknowledgment ledger, per-copy SLOs — is mandatory under either
engine, and it is the *actual* erasure-critical machinery. Within it, "spine
tombstone (global DB), then regional payload DELETE (regional DB)" are two
idempotent steps against a 72-hour published SLO. Cross-system coordination
with a 72-hour deadline and idempotent verifiable steps is a job queue, not
hand-rolled 2PC. Nothing on the erasure path needs cross-region *transactions*;
it needs cross-region *completion tracking*, which no database provides.

*Third: the ordering that must be synchronous already is.* The one
latency-critical erasure step — reads stop at T0 — is a single-row spine
transition (`person → deleting`) in the global spine database, checked on
every packet read. Synchronous, single-database, engine-independent.

*Fourth: empirical residency governance cuts the other way.* ZITADEL — an
identity platform, the closest comparable in this docket — cited *data
residency* as a reason to leave CockroachDB for Cloud SQL Postgres: they could
not adequately control where the distributed system moved data and log files;
regional pinning of plain Postgres instances was the stronger governance
story ([ZITADEL](https://zitadel.com/blog/move-to-postgresql)). A database
whose value proposition is moving data across regions must be *configured
into* compliance; N regional Postgres databases are compliant by construction.

*Where the rebuttal is incomplete, said plainly:* (a) If counsel ever
region-locks the **spine** itself with cross-region consistency requirements
(data-platform's named worst case), regional spine projections plus
reconciliation on Postgres is genuinely painful — but a globally replicated
Spanner spine is *equally noncompliant* in that world; the real defense is
spine minimization, which is engine-independent. (b) If a jurisdiction ever
demands synchronous cross-plane erasure (tombstone and payload removal in one
atomic instant), distributed SQL holds an edge Postgres cannot match. No
surveyed regime demands this; it is a trigger, not a design driver (§6).

### 2.2 RPO-zero: "an integrity spine cannot tolerate RPO>0 without breaking per-party chains during failover"

**Steelman.** Postgres HA is async or quorum-sync to nearby standbys;
failover is tens of seconds to minutes and, in common configurations, RPO>0.
A lost acknowledged attestation is not "some data loss" — it is a broken
per-party chain, an issuance the ledger acknowledged and can no longer account
for, a falsified core promise. Multi-region synchronous quorum commit must be
a database *property*, not a runbook; building it on Postgres is operating a
hand-made distributed database with three people.

**Rebuttal.** This is the strongest of the four, and it is answered by
decomposing what "RPO-zero" must actually cover. The full analysis is §3 (the
crux); the summary:

*The property the spine needs is not "no committed transaction is ever lost."
It is "no attestation the ledger acknowledged, and nothing an external party
can hold as proof, is ever lost."* Those differ, and the difference is the
whole case:

- **Unacknowledged writes are already covered** by the settled architecture:
  the durable ingest queue with idempotency keys means anything not yet acked
  is replayed or resubmitted by the party. No chain breaks, because the chain
  entry never existed.
- **Acknowledged writes are covered by gating the ack** on a durability
  watermark: the ack (with its ledger timestamp) is released only when the
  commit is confirmed on a second failure domain — a quorum-sync in-region
  standby for AZ loss (Aurora's storage layer gives this natively: six copies
  across three AZs, RPO 0 in-region), plus, for region loss, either
  cross-region queue durability before ack or an Aurora Global replication
  watermark (~sub-second lag). Cost: tens of milliseconds on an ingest path
  whose published SLO is p99 < 1s. This is an application-level watermark of
  a few hundred lines, not a hand-made distributed database — precisely
  because the *only* transactions needing cross-failure-domain synchrony are
  ack releases, not every write, read, and index update in the system, which
  is what Spanner's global quorum taxes.
- **Externally held proofs are covered by gating checkpoint escrow** the same
  way: a signed Merkle checkpoint leaves the building only when the WAL it
  covers is confirmed replicated. Then no escrowed checkpoint can ever cover
  a row a failover un-commits, and external verifiability survives any
  failover by construction.

What genuinely remains after the watermarks is a receipt-finality wrinkle,
walked in §3, whose fix (two-phase receipts: provisional ack, then
checkpoint-inclusion proof) is machinery the D3 transparency log wants for its
own reasons. The planet-scale author's kill-shot #1 thus purchases, at
Spanner's price, a property this system needs only at one boundary and can
build there for hundreds of lines.

*Where the rebuttal is incomplete:* the watermarks are hand-built and must be
tested (game days, chaos drills) — Spanner's version is a database property
that cannot regress via an application bug. That is a real, honest advantage;
it is priced against Spanner's costs in §5 and bounded by trigger §6.2.

### 2.3 Stage-C read locality: "~1M row-reads/s peak, sub-400ms global p99 wants native follower reads"

**Steelman.** At 10⁹ identities, ~10k packet reads/s peak at 20–100 row
lookups each ≈ 1M row-reads/s, assembled sub-400ms for readers in Manila,
Lagos, São Paulo simultaneously. That wants replicas near readers with bounded
staleness and consistent cutover — native in the distributed-SQL class, a
bolted-on replica mesh with per-query staleness reasoning in Postgres.

**Rebuttal.**

*First, the internal contradiction.* Argument (a) demands payloads physically
pinned in the subject's residency region. Argument (c) demands data replicated
near readers. For the cross-region read — the only case where global locality
matters — these are mutually exclusive *for the payload plane*: a Manila
worker's payload may not be replicated to a US vertical's region, under the
planet-scale author's own architecture. Follower reads cannot serve what
residency forbids replicating. So read locality legitimately applies only to
the **spine and registry**: small (~15 TB at stage C), append-only, no
readable PII, replicable everywhere. Async read replicas of small append-only
tables are the *easiest* replication problem Postgres has; "bolted-on mesh"
overstates a fleet of managed regional read replicas of two compact databases.

*Second, the latency budget closes without follower reads of payloads.* The
settled pattern (data-platform §3.3) assembles the packet in the subject's
region and ships the finished packet — one cross-region round trip, 150–250ms
trans-Pacific, inside a 400ms p99 with assembly at in-region replica speeds.
Where reader and subject share a region (the common case — a Philippine
vertical reading Philippine workers), assembly is entirely local.

*Third, staleness reasoning is not removed by Spanner — it is renamed.* The
planet-scale text itself concedes the split: "staleness of seconds is
acceptable for packet assembly; grant-revocation checks read fresh." That is
exactly the discipline a Postgres replica mesh requires (grant/deletion checks
against the primary or a sync standby; content reads against replicas), and
exactly the discipline Spanner requires (strong read for the grant check,
bounded-staleness read for content). The application reasons about freshness
per query class in both worlds; the reasoning is a product invariant
(revocation and deletion must bind immediately), not a database deficiency.

*Fourth, arithmetic.* 1M row-reads/s peak spread across, say, six serving
regions is ~170k row-reads/s per region of person-scoped indexed lookups —
two to three read replicas per region at conventional Postgres capacity. At
stage C this system also has stage-C headcount; and stage C is two years and
two architectural review cycles away.

*Where the rebuttal is incomplete:* consistent replica cutover during regional
failover is genuinely smoother in the distributed-SQL class; a Postgres
replica fleet needs promotion runbooks and rehearsal. Priced as ops burden in
§6 triggers, not as a correctness gap — packet reads are stateless and
retryable.

### 2.4 TrueTime: "a trustworthy ordering authority for compromise-vs-backdating, for free"

**Steelman.** The verification rule — valid iff the key was active at signing
and the ledger timestamp predates any compromise report — is only as strong as
the timestamp's trustworthiness. TrueTime commit timestamps give a globally
consistent total order as a database property; no application sequencer exists
to be wrong.

**Rebuttal.**

*First, TrueTime authenticates nothing to anyone who matters.* The threat the
rule defends against is a party disavowing genuine history by claiming
backdated compromise — and, one layer down (security-infra's frame), the
*operator* rewriting or backdating history. A Spanner commit timestamp is the
operator's own database asserting the operator's own ordering; to a disputing
party, a litigant, or an auditor, it carries exactly the evidentiary weight of
a Postgres `commit_ts`: "trust the operator's database." The ordering
authority with independent force is the **signed Merkle checkpoint escrowed
outside the operator's control, witnessed externally** — D3's day-one
transparency log, which both the security-infra and log-centric perspectives
specify and which works identically over either engine. An attestation's
trusted time is the earliest external checkpoint covering it. TrueTime adds
precision below that; it cannot add trust above it.

*Second, the required granularity is human, not atomic.* Key-compromise
reporting is an hours-to-days process (discovery, confirmation, report).
Checkpoint granularity of seconds-to-minutes is two to five orders of
magnitude finer than the event being ordered. Log-centric states the invariant
outright: consumers may rely on per-stream order and on checkpoint-granularity
happened-before, never on finer cross-stream order. Per-subject and per-party
chains give exact total order *within* every stream that has a verification
semantics — by construction, engine-free.

*Third, what TrueTime actually buys — external consistency for concurrent
multi-region writes — is a property the settled chain structure was designed
to avoid needing.* No global chain, no global sequencer, no cross-stream
ordering promise finer than checkpoints: the design deliberately removed the
problem TrueTime solves. Buying Spanner for TrueTime is buying the answer to a
question the architecture already declined to ask.

D6 (ordering authority) accordingly resolves with D3, not D1 — exactly as the
convergence map anticipated — and resolves against needing TrueTime.

---

## 3. The crux: does the spine need synchronous multi-region replication? The failure walk

**Question as posed:** does the spine need multi-region RPO-zero synchronous
replication at 1M? At 10⁸? What is actually lost if the spine fails over with
RPO>0?

### 3.1 The failure walk, per-party chain reconstruction

Setup: regional failure of the spine primary; failover to a replica missing
the last **W** seconds of commits (async cross-region lag; in-region
quorum-sync means W>0 only for whole-region loss). Every in-flight attestation
is in exactly one state:

**State 1 — received, queued, not committed.** Sits in the durable ingest
queue (idempotency key = `attestation_id`). After failover: replayed,
committed, chained, acked. Loss: none. Chain effect: none — the entries never
existed. At stage-B period-close burst (830/s), the queue is holding thousands
of these by design; the burst case is the *safest* case, not the worst.

**State 2 — committed, not yet acked.** The commit is gone after failover; the
queue entry survives (or the party retries on ack timeout — the API contract
requires idempotent resubmission). Replay re-appends. The attestation lands at
a possibly different position in its subject and party chains than the lost
commit had. Loss: none, because *nothing external referenced the lost
position* — no ack was issued, and (by the escrow watermark) no external
checkpoint covered it. Internally, chain hashes recompute on replay; the
chains are per-subject/per-party, so recomputation touches only the affected
streams' heads, not history.

**State 3 — committed and acked within W.** The only dangerous state. The
party holds a receipt (ledger timestamp, possibly a chain reference) for a row
the failed-over database does not contain. Magnitude: with un-watermarked
acks, W × ack-rate. At 1M identities (0.2/s average): W=5s ≈ **1
attestation**. At 10⁸ (23/s average): W=5s ≈ **115 attestations**, ~115
distinct subjects (subject-partitioned; burst traffic is in State 1). Each is
recoverable in *content* via queue replay — what breaks is the **receipt**:
the party's held timestamp/chain-ref no longer matches the re-appended row.

**State 4 — committed, acked, and covered by an escrowed checkpoint.**
Impossible by construction if checkpoint escrow is gated on the replication
watermark — a checkpoint never leaves the building before its WAL is
multi-domain durable. This is the single most important line in the design:
it guarantees *externally provable history has RPO zero* regardless of the
database's RPO.

### 3.2 What the walk establishes

- The catastrophic reading of "RPO>0 breaks per-party chains" — history
  silently diverging from what parties and auditors can prove — is prevented
  by one small invariant (escrow watermark), not by the database engine.
- The residue is State 3: acked-but-unproven receipts, bounded to ~W ×
  ack-rate rows, all content-recoverable, with a receipt mismatch to repair.
  Two available closures:
  1. **Eliminate State 3**: gate acks on the cross-region watermark
     (~sub-second added latency inside the 1s ack SLO). RPO-zero *for acked
     attestations* on managed Postgres.
  2. **Tolerate State 3**: define receipts as provisional until
     checkpoint-inclusion, with a final proof delivered at next checkpoint
     (seconds-to-minutes later). Parties treating inclusion proofs as
     finality is exactly the consumption model a transparency log (D3)
     prescribes anyway.
  Either suffices; doing both is cheap and defense-in-depth.

### 3.3 Answers to the posed question

- **At 1M: no.** Multi-AZ managed Postgres (in-region RPO 0), the durable
  queue, and the escrow watermark leave the worst whole-region-loss case at
  roughly one acked attestation with a repairable receipt — against a
  once-in-years event. Synchronous multi-region replication at this stage
  buys a rounding error.
- **At 10⁸: the spine needs cross-failure-domain durability at the ack
  boundary — yes; synchronous multi-region replication of the whole database
  — still no.** The ack watermark (closure 1) delivers the needed property at
  the only boundary that needs it. If measurement shows the watermark cannot
  hold the ack SLO, that is trigger §6.2 and the honest moment to buy the
  database property instead.

---

## 4. Migration costing: Postgres → distributed SQL for a person-partitioned append-only spine

The pragmatist calls the eventual migration "mechanical." Verdict after
research: **mechanical in data shape, real in operational surface — a one-to-
two-quarter project, not a footnote and not a rewrite.**

**Why this migration is unusually favorable, concretely:**

- *Append-only*: dual-write/backfill runs without update-conflict resolution —
  the hardest part of most live migrations simply does not exist. Backfill is
  a monotone copy; dual-write is two idempotent inserts.
- *Person-partitioned, no cross-person transactions* (merge excepted — rare,
  human-gated): streams migrate independently, in parallel, in any order.
- *Self-verifying*: per-subject and per-party chain hashes let the migration
  prove byte-fidelity per stream at both ends — a verification luxury almost
  no migration has. Log-centric's v3 path describes exactly this:
  stream-by-stream copy with hash-chain verification.
- *Small*: ~1.5 TB spine at stage B. Bulk-load guidance for CRDB (split dumps,
  parallelize across nodes) is documented and routine at this size
  ([bulk-loading writeup](https://medium.com/swlh/migrating-from-postgres-to-cockroachdb-bulk-loading-performance-ddcb1c013597),
  [LaunchDarkly migration tips](https://www.cockroachlabs.com/blog/customer-launchdarkly-database-migration-tips/)).

**Where the real costs are, from the case record:**

1. *SQL-surface friction.* CRDB's Postgres compatibility is wire-level, not
   semantic: sequences, triggers, `ON CONFLICT` edge behavior, range types,
   and ORM/migration tooling all surfaced in practice; Motion reported Prisma
   migrations timing out and being pinned past end-of-life on CRDB v22
   ([Motion](https://engineering.usemotion.com/migrating-to-postgres-3c93dff9c65d)).
   Mitigation available *now* at zero cost: keep the spine schema in the
   compatible subset — no triggers on migrating tables beyond the append-only
   fence (an engine-level guarantee that must be re-established as CRDB
   privileges anyway), `global_seq` advisory-only (never a correctness
   dependency — log-centric already mandates this), no exotic types.
2. *Latency re-profiling.* Distributed commit costs 2–10× single-region
   Postgres commit; every SLO on the ingest path gets re-measured. Absorbable
   (budgets are hundreds of ms) but it is work.
3. *Cutover machinery*: dual-write layer, shadow-read comparison, per-stream
   flip, rollback plan. The industry pattern (gradual migration, strong test
   coverage first) is well documented
   ([CockroachLabs lessons](https://www.cockroachlabs.com/blog/3-lessons-from-a-highly-successful-database-migration-and-modernization/)).
4. *Team-hours*: estimate 2–4 engineer-quarters all-in at stage B — executed
   by the stage-B team, because every trigger that would fire this migration
   (§6) implies revenue and headcount far beyond three people.

**The counter-ledger — the cost of the opposite error — is not hypothetical:**

- Motion adopted CRDB early for a single-region workload, watched the bill 5×
  to mid-six-figures annually, fought timeouts and stuck upgrades, and
  executed the *reverse* migration to Postgres
  ([Motion](https://engineering.usemotion.com/migrating-to-postgres-3c93dff9c65d)).
- ZITADEL — an identity/access platform — measured a 3-node CRDB cluster at
  ~3× the cost of a smaller Postgres instance with similar regional
  performance, better API latency after the move, *and* better residency
  governance, and migrated off
  ([ZITADEL](https://zitadel.com/blog/move-to-postgresql)).
- Figma and Notion, at hundreds of millions of users, each chose sharded/
  partitioned Postgres over distributed SQL when the decision actually
  arrived — Figma explicitly declining to be a NewSQL vendor's largest
  single-cluster customer
  ([Figma](https://www.figma.com/blog/how-figmas-databases-team-lived-to-tell-the-scale/),
  [Notion](https://www.notion.com/blog/sharding-postgres-at-notion)).

Both directions of migration cost about the same. Only one direction's
trigger condition is observable in advance (§6); the other must be paid on
speculation, plus the carrying cost (Spanner multi-region runs ~$3/node-hour
before storage — a few thousand dollars monthly is the planet-scale author's
own floor estimate — plus the thinner AI-tooling corpus and loss of the
relational-constraint enforcement the AI-heavy SDLC leans on, per the
pragmatist and AI-native perspectives). The asymmetry of regret decides it.

---

## 5. Concessions — what is true in the opposing case

Stated without hedging:

1. **The shape doctrine is right and is adopted wholesale.** Residency key in
   the payload PK from row one; hash-prefixed/random IDs (naked UUIDv7 vetoed
   at schema time); per-subject/per-party chains, never global; subject
   partitioning with async issuer indexes; durable idempotent ingest queue;
   IaC from week one; cross-cloud checkpoint escrow; canonicalization test
   vectors. The planet-scale perspective materially improved the design even
   where its engine conclusion fails. Several of these (ID scheme, chain
   structure) are genuinely unretrofittable, exactly as it argues.
2. **Unmitigated Postgres async HA is disqualifying for this spine.** The
   default posture (async standby, RPO measured in seconds, ack on local
   commit) would break the accounting promise exactly as claimed. The bloc
   position is only defensible *with* the watermark machinery of §3, which
   must be built, game-day tested quarterly, and treated as trust-kernel-grade
   code. Spanner delivers the equivalent as an unregressable database
   property; that is a real advantage, bought at real cost.
3. **Failover is a rehearsed runbook on Postgres and a non-event on Spanner.**
   RTO tens-of-seconds-to-minutes vs. transparent. For a three-person team,
   every runbook is a liability; this one is carried consciously.
4. **If the spine itself is ever region-locked with consistency requirements
   across regions, or synchronous cross-plane erasure is ever mandated,
   distributed SQL wins** — Postgres's answer (regional projections +
   reconciliation) is the painful fallback the data-platform perspective
   admits it is.
5. **At true stage C, managed distributed SQL is likely the right system of
   record**, and the sharded-Postgres interim (Citus-class) has more tuning
   surface than Spanner. The bloc position is "not yet, and not on
   speculation" — not "never." The switch triggers below are the difference
   between conviction and stubbornness.

---

## 6. Switch triggers — measurable conditions under which this advocate changes sides

Adopt distributed SQL (evaluate Spanner first, CRDB for cloud-neutrality) when
**any** of the following is observed, not forecast:

1. **Residency**: counsel designates, in writing, either (a) a requirement
   that the *spine* (not payloads) be processed in-country in ≥2
   jurisdictions with cross-region consistency obligations, or (b) any
   requirement of synchronous atomic cross-plane erasure. Payload-plane
   residency mandates do **not** trigger — regional payload databases are the
   designed answer.
2. **Durability watermark fails its budget**: the cross-failure-domain ack
   watermark cannot hold ingest ack p99 < 1s for a sustained week at current
   volume, or any game day demonstrates loss of an acked attestation or an
   escrowed-checkpoint/WAL divergence. One occurrence triggers.
3. **Write ceiling in sight**: sustained committed spine writes > 2,000/s per
   region for a month (≥40% of the pragmatist's measured chain/partition
   ceiling band), with the interface contract intact — i.e., real demand, not
   a contract breach to be fought as product.
4. **Sharding POC failure**: any regional payload database approaching
   ~5×10⁸ rows where a Citus-class sharding proof-of-concept on the actual
   workload fails its correctness or latency acceptance criteria.
5. **Read SLO miss**: packet-read p99 > 400ms globally (or > 150ms in-region)
   for a full quarter despite regional spine replicas and in-region assembly
   already deployed.
6. **Ops burn**: Postgres HA/failover machinery causes ≥2 sev-1 incidents in
   any rolling year, or database operations consume > 0.5 FTE sustained over
   two quarters, or two consecutive quarterly failover game days fail their
   runbook.

Each trigger names the moment the premium becomes cheaper than the property it
buys. Until one fires, the system of record is managed Postgres: two small
global databases (spine, registry) with watermarked durability and escrowed
checkpoints, N regional payload databases, and the entire planet-scale shape
doctrine implemented on the engine a three-person AI-heavy team can hold in
its head.

---

## Sources

- [Motion: Migrating to Postgres (off CockroachDB)](https://engineering.usemotion.com/migrating-to-postgres-3c93dff9c65d)
- [ZITADEL: Why We Moved From CockroachDB to PostgreSQL](https://zitadel.com/blog/move-to-postgresql)
- [Figma: How Figma's Databases Team Lived to Tell the Scale](https://www.figma.com/blog/how-figmas-databases-team-lived-to-tell-the-scale/)
- [Notion: Lessons learned from sharding Postgres](https://www.notion.com/blog/sharding-postgres-at-notion)
- [CockroachLabs: LaunchDarkly migration tips](https://www.cockroachlabs.com/blog/customer-launchdarkly-database-migration-tips/)
- [CockroachLabs: 3 lessons from a database migration](https://www.cockroachlabs.com/blog/3-lessons-from-a-highly-successful-database-migration-and-modernization/)
- [Postgres→CRDB bulk-loading performance](https://medium.com/swlh/migrating-from-postgres-to-cockroachdb-bulk-loading-performance-ddcb1c013597)
- [Patroni replication modes (quorum sync)](https://patroni.readthedocs.io/en/latest/replication_modes.html)
- [Postgres synchronous replication — a 99.99% guarantee only](https://kmoppel.github.io/2024-12-09-postgres-sync-replication-data-safety/)
- [Cloud Spanner pricing](https://cloud.google.com/spanner/pricing)
