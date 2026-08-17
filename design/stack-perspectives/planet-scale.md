# Stack Perspective: The Planet-Scale Architect

Independent technical-design perspective on the identity/work ledger
(`design/ledger-design-0.1.md`, `handoff/attestation-interface.md`), written
against the binding operating facts: 3-person AI-heavy team, greenfield,
~1M identities within months, hundreds of millions within ~2 years, then
planet scale as the explicit design target; global users including emerging
markets; effectively unlimited capital conditional on success.

---

## TLDR

1. **This system is topology-bound, not throughput-bound.** The arithmetic
   below shows attestation writes never exceed a few hundred per second
   sustained even at 10⁹ identities, with bursts to low tens of thousands at
   period close. A laptop Postgres survives the QPS. What Postgres cannot
   survive is the *shape*: jurisdictional residency partitioning of the
   payload plane, RPO-zero multi-region durability of the integrity spine,
   and sub-100ms packet reads from Manila, Lagos, and São Paulo
   simultaneously. Those are topology properties, and topology is the thing
   you cannot retrofit under fire.

2. **Recommendation: managed distributed SQL as the single system of record
   from day one.** Primary: Google Cloud Spanner (external consistency gives
   attestation ordering for free via commit timestamps; geo-partitioning
   maps exactly onto the residency-shaped payload plane; zero-ops fits a
   3-person team). Acceptable alternative: CockroachDB Cloud (Postgres wire
   compatibility, `REGIONAL BY ROW` is purpose-built for the payload plane,
   cloud-neutral). Unacceptable: single-writer Postgres as the spine's
   system of record, however boring and beloved.

3. **Per-subject hash chains, never a global chain.** A single global
   hash chain is a planetary serialization point — it caps the system at one
   region's sequencer and makes multi-region active/active impossible
   forever. Chain per subject (and per party for issuance accounting), with
   periodic Merkle checkpoints over all chains anchoring into one signed
   global checkpoint sequence, CT-style. Chain structure is immutable by
   definition; this is a day-one decision.

4. **Partition by subject, never by issuer.** Attestation writes cluster on
   hot parties (one vertical closing a month for millions of workers). The
   subject is the natural, evenly distributed partition key; issuer-keyed
   access is asynchronous and index-served. Hash-shard the time-ordered ID
   to avoid hot ranges.

5. **The two-plane model is a physical decision, not just a logical one.**
   Spine tables: global, no PII, replicated everywhere, RPO zero. Payload
   tables: keyed `(residency_region, subject_id, object_id)`, physically
   pinned in-region. Deletion (R2) is a payload-plane regional operation
   that never touches spine replication. If the planes live in the same
   rows, residency and erasure are both retrofits — the expensive kind.

6. **Languages: Go for the ledger core, TypeScript at the edges.**
   gRPC/protobuf as the internal contract with a schema registry; the
   attestation envelope stays JWS/Ed25519 exactly as designed (signature
   verification is cryptographically trivial at these rates — one core
   suffices at stage B).

7. **What can genuinely wait:** Kubernetes, cells, multi-cloud, search and
   analytics infrastructure, the public transparency log, caching tiers,
   API gateway sophistication, anomaly-detection pipelines. Compute is easy
   to retrofit. Data topology, ID scheme, chain structure, residency keys,
   and the event-ordered write path are not.

---

## 1. The load, arithmetically

Attestations are career-grained human events: one per completed engagement
or one per period-and-work-kind. That grain bounds the write rate to human
work rhythms, not machine rhythms. Packet reads are hiring/routing-decision
events, similarly human-bounded. Assumptions stated in the Assumptions
section; every figure below is derivable from them.

### Stage A — month 6, 1M identities

- Active attested workers: ~250k (25% of identities in routed work).
- Attestation writes: 250k × 2/month = 500k/month ≈ **0.2/s average**.
- Period-close burst: one vertical closing 250k workers in 2 hours ≈ **35/s**.
- Packet reads: 5/active-worker/month ≈ 1.25M/month ≈ **0.5/s average**.
- Storage: ~10 spine objects/person × 0.5KB ≈ **5 GB spine**; payloads ~20 GB.

Nothing here stresses any database. Stage A is not the design driver; the
point of stage A is to lay the *shape* that stages B and C need.

### Stage B — year 2, 100M identities

- Active attested workers: ~30M.
- Attestation writes: 60M/month ≈ **23/s average**.
- Period-close bursts: if 20% of monthly volume lands in a 4-hour
  end-of-period window, ≈ **830/s sustained burst**; a single pathological
  party closing 10M workers in one hour ≈ **2,800/s** against one issuer —
  this is the hot-party case and it is entirely absorbable by a durable
  ingest queue, but only if the storage partitioning does not funnel one
  issuer's writes into one range.
- Signature verification: Ed25519 verifies at ~10–20k/s/core with modern
  implementations. **One core** covers stage B's worst burst.
- Packet reads: 10/active-worker/month ≈ 300M/month ≈ **115/s average**,
  peak 1–2k/s. Each packet assembly walks alias closure + supersession
  chains + registry state ≈ 20–100 row lookups → **up to ~100–200k row
  reads/s peak**. This is the first number that is real work — and it is
  read work, served by follower/regional replicas.
- Storage: 100M × ~30 spine objects × 0.5KB ≈ **1.5 TB spine**; payloads
  at ~2KB average ≈ **6 TB**. One modest distributed-SQL cluster.

### Stage C — planet scale, 1B identities

- Active: ~200M. Writes: 400M/month ≈ **150/s average**, bursts
  **10–30k/s** (multiple simultaneous period closes across time zones).
- Packet reads: ~2B/month ≈ **800/s average**, **~10k/s peak** →
  ~1M row-reads/s peak, which is where read locality (packet assembled from
  replicas near the reader) becomes mandatory rather than nice.
- Storage: ~15 TB spine, ~60 TB payload. Still small. **This system is
  never big-data.** It is global-correctness-bound and
  availability-bound, not volume-bound.

The conclusion the arithmetic forces: do not buy throughput machinery. Buy
**ordering, placement, and durability guarantees** — from a vendor, because
three people cannot operate them and should not build them.

## 2. Data stores and topology

### 2.1 The system of record: one managed distributed-SQL cluster

**Primary recommendation: Spanner.** Reasons, in order:

1. **External consistency = free ordering.** The design requires a trusted
   ledger timestamp on every attestation ("valid iff the key was active at
   signing time and the ledger timestamp predates any compromise report").
   TrueTime commit timestamps give a globally consistent total order
   without any application-level sequencer — the single hardest thing to
   build correctly, delivered as a database property.
2. **Geo-partitioning maps directly onto the residency-shaped payload
   plane** (placement by row/partition into named regions).
3. **Operational load ≈ zero.** Three people. Spanner is the only
   database in this class where the honest answer to "who gets paged for a
   range-rebalance stall at 3 a.m.?" is "Google."
4. Proven at 10⁹-user scale for well over a decade; nothing about stage C
   is speculative for it.

**Acceptable alternative: CockroachDB Cloud (dedicated).** Postgres wire
compatibility (fits the team's SQL instincts and the AI-tooling ecosystem),
`REGIONAL BY ROW` is precisely the payload-plane primitive, cloud-neutral
if GCP concentration is unacceptable. Cost: you own more tuning surface
(hot ranges, contention) than with Spanner. As of 2025–2026, Aurora DSQL
remains too young and feature-constrained (no foreign keys, limited
compatibility) for a system-of-record bet, and the PlanetScale
Postgres-sharding line (Neki) is not yet GA-proven at this class — both are
watch-list, not foundation. (Sources: [CockroachDB vs Aurora/DSQL](https://www.cockroachlabs.com/compare/amazon-aurora-vs-cockroachdb/),
[PlanetScale Neki](https://planetscale.com/neki),
[distributed SQL landscape 2026](https://pdpspectra.com/blog/cap-theorem-distributed-databases-2026/).)

### 2.2 Physical schema: the two planes as two table families

- **Spine tables** (`objects`, `attestation_spine`, `party_events`,
  `key_events`, `merge_events`, `grants`, `read_log`, `checkpoints`):
  append-only, no readable PII, globally replicated, multi-region quorum
  writes, RPO zero. These are small (§1) and hot for reads.
- **Payload tables** (`payloads`, versioned): primary key
  `(residency_region, subject_id, object_id, version)`, physically placed
  in the named region. Erasure (R2) = delete payload rows in one region.
  Spine commitments are unaffected, exactly as the logical design requires.
- **Registry** (parties, keys, vetting metadata): tiny, global, strongly
  consistent — reads on the ingest path take it from the same cluster, no
  separate store, no cache-coherence problem at stage A/B. Introduce a
  read-through cache with short TTL only when measured.

### 2.3 The write path: durable log in front, not a bigger database behind

Ingest = `receive → validate (schema, signature, issuer state, subject
resolution) → append to durable queue → transactional write (spine +
payload) → ack to party with ledger timestamp`. The queue (GCP Pub/Sub; or
Kafka later if ordering-per-subject demands it) absorbs period-close bursts
so the database sees smoothed load, and gives every attestation an
at-least-once, idempotent (keyed by `attestation_id`) path. This is ~2
weeks of work at stage A and the difference between "period close is a
non-event" and "period close is an incident" at stage B.

## 3. Partitioning and hot-partition avoidance

- **Partition key: `subject_id`, always.** Subjects are ~uniformly
  distributed; issuers are catastrophically not (one vertical = millions of
  subjects). All synchronous writes and packet reads are subject-local.
- **Issuer-keyed access (party accounting, anomaly detection, "everything
  party X issued") is served by asynchronous global indexes or CDC-fed
  derived tables** — never on the synchronous path, so a hot party cannot
  create a hot range.
- **ID scheme caution:** UUIDv7's time-ordering is a hot-range generator on
  range-partitioned stores — all new IDs land on the tail range. Either use
  hash-sharded indexes on the time-ordered key (CRDB supports natively;
  Spanner via a shard-prefix column) or issue UUIDv4-class random IDs and
  keep time in a column. This is a one-line decision now and a
  full-table-rewrite later. The logical design's "UUIDv7 or equivalent"
  should be resolved to **random ID + timestamp column, or hash-prefixed
  v7** before the first row is written.
- **Alias-closure reads** (merge history) are subject-local by
  construction — the closure is small (merges are rare, human-reviewed) and
  co-located with the subject's partition.

## 4. Hash chains and signatures at scale

### 4.1 Chain structure — the one cryptographic decision that cannot wait

A single global hash chain means every attestation write serializes through
one predecessor pointer: one region, one sequencer, a hard ceiling, and a
permanent obstacle to multi-region writes. Chain structure is immutable —
you cannot re-chain history. Therefore, day one:

- **Per-subject chain:** each spine object carries
  `prev_hash(subject chain)`. Tamper-evidence where it matters — a career
  is the unit a reader verifies.
- **Per-party issuance chain:** each attestation also carries
  `prev_hash(party chain)`, giving parties an account of everything they
  issued (and making backdated-compromise claims checkable per party).
- **Checkpointing:** every N minutes, a Merkle root over all chain heads is
  computed, signed by the ledger's checkpoint key (Cloud KMS/HSM-backed),
  appended to a single small `checkpoints` sequence, and **escrowed
  outside the primary cloud** (a second provider's object store, and later
  a public log). The checkpoint sequence is the only global chain, and it
  is low-frequency by construction. This preserves the design's option of
  CT-style public inclusion proofs (`04` TLDR-8) without building the
  public log now.
- **Ordering authority:** the ledger timestamp on each attestation is the
  database commit timestamp (externally consistent under Spanner), bound
  into the chained hash. No application sequencer exists to be wrong.

### 4.2 Signatures

Ed25519/JWS exactly per the logical design. Verification cost is a
non-problem (§1). The engineering substance is key custody and hygiene:

- Ledger-owned keys (checkpoint signing, `ledger_invalidated` issuance) in
  Cloud KMS/HSM, non-exportable, with rotation runbooks in code.
- Party public keys live in the registry with their append-only key-event
  log, per the design; verification on ingest reads registry state
  transactionally in the same cluster.
- Canonicalization (the JWS signing input) is specified once, in the proto/
  schema repo, with cross-language test vectors — canonicalization drift is
  the classic silent signature-infrastructure failure.

## 5. Multi-region and residency

Phased, honestly matched to team capacity:

- **Stage A:** one primary region + one witness/DR region for the cluster
  (Spanner multi-region config or CRDB 3-region minimum). Already RPO
  zero, region-failure-surviving. This costs configuration, not
  engineering, which is why it is not deferred.
- **Stage B:** add read-serving replicas in the demand geographies
  (Southeast Asia, LATAM, Africa-adjacent Europe) — packet reads served
  from follower/bounded-staleness replicas near the reader (staleness of
  seconds is acceptable for packet assembly; grant-revocation checks read
  fresh). Payload partitions begin pinning to residency regions as counsel
  designates jurisdictions.
- **Stage C:** write regions follow subject residency (Spanner
  geo-partitioned read-write placements / CRDB regional-by-row write
  locality), so a Manila worker's payload writes commit in-region.
- **Residency is a schema key from day one** (`residency_region` in every
  payload primary key), even while every value is `us-east`. Adding the
  column later is a migration of the erasure-critical table under load;
  adding it now is free.
- **Emerging-markets read latency** is solved by replica placement plus a
  thin edge cache for static assets — not by CDN-caching packets, which
  are generated-at-read by contract and must reflect revocation
  immediately.

## 6. Languages and services

- **Go for the ledger core** (ingest, spine/payload write path, packet
  assembly, registry): static binaries, first-class gRPC, mature
  crypto, the lingua franca of exactly this infrastructure class, and —
  relevant to this team — a language AI coding agents produce reliably and
  reviewably. Rust is defensible for the canonicalization/crypto kernel if
  the team wants it; it is not required at these rates.
- **TypeScript at the edges** (worker-facing surface, admin/steward
  tooling), matching the team's stated default where iteration speed
  dominates.
- **Shape: a modular monolith**, one deployable ledger service with
  internal module boundaries (ingest, registry, read, identity/merge),
  splitting only when a module's scaling or blast-radius profile diverges
  (ingest is the first plausible split, at stage B). Three people cannot
  operate a microservice constellation and should not try.

## 7. API surface

- **Contracts in protobuf, in a dedicated schema repository**, versioned,
  with generated clients. The attestation-interface schema
  (`schema_version 0.1`) becomes a proto package; the JWS payload
  canonicalization is defined against it with test vectors.
- **Party-facing API: gRPC and JSON/HTTP transcodings of the same protos**
  (external partners will want plain HTTPS+JSON; internal verticals take
  gRPC). Idempotency keys (`attestation_id`) on all writes.
- **Worker-facing API:** JSON/HTTP behind the TypeScript surface.
- **Versioning discipline:** additive-only within a major version; the
  `schema_version` field on every attestation is honored forever
  (immutable historical bindings, mirroring the `work_kind@version` rule).
- **No GraphQL on the party path** — the packet is a fixed contract shape,
  not a query surface; ad-hoc query flexibility on career data is a
  disclosure-control hazard, not a feature.

## 8. Hosting and infrastructure

- **GCP** (follows Spanner; if CRDB Cloud is chosen instead, GCP or AWS —
  pick one, not both).
- **Compute: Cloud Run** for all services at stages A–B. Serverless
  containers, scale-to-demand, no cluster to operate. Kubernetes (GKE) is
  an explicit stage-B/C migration *if and when* Cloud Run's limits are
  measured, not assumed — compute is the canonical easy retrofit.
- **Everything in Terraform from the first week.** With an AI-heavy team,
  IaC is cheap to write and is the only defensible change-control story
  for a system whose credibility is "nothing was altered."
- **Environments:** dev / staging / prod as separate projects; staging runs
  the same multi-region database configuration in miniature so topology
  behavior is exercised before prod.

## 9. Observability

- **OpenTelemetry from day one** (traces on ingest and packet-read paths,
  metrics, structured wide-event logs), exported to Cloud
  Monitoring/Grafana Cloud — managed, not self-hosted.
- **SLOs, published internally:** packet read p99 < 400ms globally
  (< 150ms in-region); ingest ack p99 < 1s; ingest durability = zero
  acknowledged-then-lost attestations, ever (this one is measured by
  continuous chain-verification, below).
- **Continuous verifiers as first-class services:** a background process
  perpetually re-walks subject chains, re-verifies signatures against the
  registry, and re-derives checkpoints, alerting on any mismatch. An
  integrity ledger that does not continuously audit itself is asserting,
  not demonstrating. This also functions as bit-rot and
  migration-regression detection.
- **The read log is an operational table, not an afterthought** — it is
  worker-visible product surface and compliance evidence; it gets the same
  durability as the spine.

## 10. Disaster recovery

- **Spine + payload: continuous backup with PITR** (both Spanner and CRDB
  Cloud provide managed PITR), multi-region synchronous replication →
  **RPO 0, RTO minutes** for region loss without any failover engineering.
- **Cross-cloud escrow of the irreplaceable minimum:** daily encrypted
  exports of the spine (small — §1) and the checkpoint sequence to a
  second cloud's object storage with independent credentials. This is the
  defense against the two scenarios managed replication does not cover:
  primary-cloud account compromise and operator error propagated by
  replication. The spine at stage B is ~1.5 TB; escrowing it is trivial
  and buys survival of the worst case.
- **Deletion pipeline is DR-aware:** R2 purges must propagate to backups
  within the published window — PITR windows and backup retention are
  therefore bounded by the deletion SLA, a constraint set on day one, not
  discovered by a regulator.
- **Game days quarterly** from stage A: restore-from-escrow and
  region-failover rehearsals, scripted, because a 3-person team's DR plan
  is exactly as good as its last rehearsal.

---

## What must be right on day one, and why

1. **The ID scheme** (opaque, random-or-hash-prefixed, never reissued):
   the join key for a career; every party integration hard-codes it.
2. **The two-plane split as physical schema** with `residency_region` in
   the payload key: erasure and residency are structural or they are
   retrofits against an append-only store — the worst retrofit in the
   catalog.
3. **Per-subject/per-party chain structure + checkpointing:** chains
   cannot be re-chained; a global chain forecloses multi-region writes
   permanently.
4. **Ordering authority = database commit timestamp** on a store that
   provides external consistency: the compromise-vs-backdating rule in the
   logical design is only as strong as the timestamp's trustworthiness.
5. **Partition-by-subject and async issuer indexes:** hot-party writes are
   guaranteed by the business model (period closes), not hypothetical.
6. **Durable, idempotent ingest queue in front of the store.**
7. **Versioned proto contracts + signing canonicalization with test
   vectors:** external partners integrate against bytes; bytes are forever.
8. **IaC, PITR, cross-cloud spine escrow, continuous chain verification:**
   the product is integrity; these are the integrity of the integrity.

## What I concede can wait

- **Kubernetes and any service decomposition** — Cloud Run and a modular
  monolith to stage B.
- **Cell-based architecture** — the ID and partition scheme must not
  preclude cells (they don't, as specified); implementing cells is a
  stage-C project.
- **Multi-cloud active service footprint** — escrow yes, active
  multi-cloud no.
- **Search and analytics infrastructure** — CDC to BigQuery when steward
  tooling and anomaly detection need it; not before.
- **The public transparency log** — checkpoints are escrowed and
  publishable later; publishing is v2 hardening per the logical design.
- **Peer-attestation anomaly detection at scale** (graph/velocity/device
  clustering) — offline batch jobs over CDC output; correctness of the
  record does not depend on their latency.
- **Caching tiers, API gateway sophistication, rate-limiting
  infrastructure** beyond Cloud Run/LB defaults.
- **Full W3C VC conformance** — envelope-shape compatibility only, per the
  logical design.

## Where the boring-Postgres school actually dies

Precisely, and not on QPS — the QPS argument against Postgres is FUD and I
will not make it. 23 writes/s average and 2,800/s queued bursts at stage B
(§1) run on one large Postgres box. Postgres dies on three specific facts:

1. **RPO on the spine.** Postgres HA is async or quorum-sync to a small
   set of standbys with failover measured in tens of seconds to minutes
   and, in the common async configuration, **RPO > 0**. A lost
   acknowledged attestation is not "some data loss" here — it is a broken
   per-party chain, a party whose issuance record the ledger cannot
   account for, and a falsified core promise. The system of record for an
   integrity spine needs multi-region synchronous quorum commit as a
   *property*, not a runbook. Building that on Postgres (Patroni +
   sync-replica quorums across regions, cross-region commit latency
   management) is operating a hand-made distributed database with three
   people.
2. **Residency partitioning of the payload plane.** The moment counsel
   designates the first in-country payload requirement (EU is certain;
   PH-adjacent and India-style localization are probable given the worker
   geography), single-region Postgres is architecturally noncompliant.
   The Postgres answer is N regional databases plus an application-level
   transactional write across spine-DB and payload-DB — i.e., two-phase
   commit you wrote yourself, on the erasure-critical path. At stage B
   that is a rewrite of the write path under a compliance deadline; in
   distributed SQL it is a placement policy.
3. **Read locality at stage C.** ~1M row-reads/s peak assembled into
   packets with sub-400ms global p99 requires replicas near readers with
   bounded staleness and consistent cutover — follower reads are a native
   primitive in this class and a bolted-on read-replica mesh (with
   staleness you must reason about per-query, and promotion complexity) in
   Postgres.

The honest restatement: boring Postgres survives stage A completely and
stage B's load numerically. What it cannot do is *become* stage B's and
C's topology without a migration of the two most dangerous tables in the
system (spine, payloads) under live load and external contracts. The
whole point of choosing the skeleton early is that Spanner/CRDB at stage-A
size costs a few thousand dollars a month and near-zero operational
delta — the premium is small and the retrofit it avoids is the most
expensive one this system could ever face.

## What I'd veto from other schools

- **Single-region managed Postgres (RDS/Supabase-class) as the spine's
  system of record.** Fine for vertical-local data; disqualified above for
  the ledger.
- **A single global hash chain, or any application-level global
  sequencer.** Permanent serialization point; forecloses multi-region.
- **DynamoDB/KV-first for the spine.** Ingest is transactional multi-row
  (spine + payload + idempotency + registry read); packet assembly is
  relational (joins across alias closure, supersession, registry). KV
  buys throughput this system does not need at the cost of both.
- **Blockchain/DID anchoring** — concur with the logical design (`04`);
  the hard problem is vetting, and a chain does not touch it.
- **Microservices at stage A** — three people; modular monolith.
- **ORM-implicit schema / no proto contract.** External partners integrate
  against this interface for years; the contract must be an artifact, not
  an emergent property of application code.
- **Natural keys (phone, email, document numbers) anywhere in identity or
  partition keys** — concur with the logical design, restated here because
  partition keys are the place this mistake becomes permanent.
- **CDN/edge caching of prior packets.** Packets are generated-at-read by
  contract; caching them silently breaks revocation and deletion
  semantics — the two promises with the highest legal weight.
- **"We'll add residency when a regulator asks."** The ask arrives with a
  deadline shorter than the migration.

## Assumptions

- **Activity ratios:** 25–30% of identities are active attested workers;
  2 attestations/active/month; 5–10 packet reads/active/month. If actuals
  run 5× higher, every conclusion above still holds — the system stays 2+
  orders of magnitude below distributed-SQL throughput ceilings.
- **Object sizes:** ~0.5KB spine rows, ~2KB average payloads, ~30 spine
  objects per subject at maturity.
- **Period-close clustering:** 20% of monthly attestation volume within
  4-hour windows; single-party closes up to 10M attestations/hour at
  stage B. Derived from the interface's per-period attestation model, not
  measured.
- **Residency:** at least one hard in-region payload requirement within
  24 months (EU near-certain; others probable). If counsel concludes zero
  residency obligations ever bind, kill-shot #2 weakens; #1 and #3 stand.
- **Vendor state (2026):** Spanner and CockroachDB are mature at this
  class; Aurora DSQL is feature-constrained and young; PlanetScale's
  Postgres sharding (Neki) is pre-GA-proven. Re-verify before commitment.
- **Team:** 3 people, AI-heavy, can operate managed services and IaC but
  not self-hosted distributed databases, Kafka clusters, or Kubernetes
  fleets — this assumption drives every "managed, not self-hosted" call.
- **Capital:** the ~$2–5k/month stage-A premium for multi-region
  distributed SQL over a single Postgres instance is acceptable given the
  stated funding posture.

Sources consulted: [CockroachDB vs Amazon Aurora and DSQL](https://www.cockroachlabs.com/compare/amazon-aurora-vs-cockroachdb/),
[Distributed databases in 2026: CockroachDB, YugabyteDB, Spanner](https://pdpspectra.com/blog/cap-theorem-distributed-databases-2026/),
[PlanetScale Neki](https://planetscale.com/neki),
[PlanetScale for Postgres GA](https://planetscale.com/blog/planetscale-for-postgres-is-generally-available).
