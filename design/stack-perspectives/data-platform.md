# Stack Perspective: Data Platform & Jurisdictional Architecture

Author persona: data-platform and jurisdictional-architecture specialist.
Independent perspective; produced without reading other stack perspectives.
Inputs: `design/ledger-design-0.1.md`, `handoff/attestation-interface.md`,
`research/00` (R1/R2 binding), `research/01` (TLDR), `research/07`.
Web research: 2026 state of managed Iceberg lakehouses and GDPR erasure
practice (sources at end).

---

## TLDR

1. **This system is a data architecture with an API on top, not the reverse.**
   Identity data is the longest-lived, most residency-sensitive, most
   regulated data class there is, and three ML workloads (duplicate
   detection, party anomaly detection, routing priors) are in the design
   from day one. Decide the data topology first; everything else is
   replaceable.

2. **Operational store: partitioned PostgreSQL, one physical database per
   residency region for the payload plane, one global logical database for
   the integrity spine.** Managed Postgres (Aurora-class). No NoSQL: merges,
   alias closures, supersession chains, and grant semantics are relational
   and transactional. The spine/payload split from `ledger-design-0.1.md`
   §2.1 must be a *physical* storage split, not a schema convention,
   different databases, different encryption keying, different replication
   topology, different retention rules.

3. **The spine is personal data.** A `ledger_person_id` with hashes and
   commitments of a person's payloads is pseudonymized, not anonymized, and
   EDPB Guidelines 02/2025 say hashed personal data remains personal data.
   Accept this: the spine is a *minimized, deliberately residual* regulated
   dataset that replicates globally under transfer mechanisms (SCCs +
   supplementary measures), because a region-locked spine destroys the
   global-identity property the product exists to provide. The design work
   is keeping the spine so small that its global replication is defensible:
   IDs, type codes, hashes, signatures, timestamps, pointers. Nothing
   readable, ever, enforced by schema.

4. **CDC is the only sanctioned copy mechanism.** No service reads another
   service's tables; no analyst exports from the operational store; no batch
   job scrapes an API into a bucket. One CDC stream per regional database,
   schema-registered, column-level PII-tagged, feeding one lakehouse. Every
   copy of a datum that exists must be *derivable from the copy map*. If a
   copy isn't on the map, it's a compliance incident, not a convenience.

5. **Deletion is an engineered subsystem with SLOs, not a DELETE statement.**
   An R2 whole-profile deletion is an orchestrated saga that must reach:
   operational primary, read replicas, CDC topics, lakehouse
   bronze/silver/gold, search/blocking indexes, feature store, embeddings,
   ML training snapshots, caches, backups, and logs, each with a tracked
   acknowledgment and a published SLO (operational: 72h; streams: retention
   capped at 7 days so payloads age out structurally; lakehouse: delete
   queue + snapshot expiry within 30 days; backups: 35-day maximum retention
   plus per-person envelope-key destruction as defense in depth, not as the
   erasure mechanism itself). The EDPB's Feb-2026 erasure enforcement report
   found exactly the failures this prevents: undefined backup erasure and
   pseudonymization passed off as deletion.

6. **Lakehouse: Iceberg, managed, from roughly month three, not day one,
   and never self-run Spark.** The table-format war is over; Iceberg won,
   and every major platform (Snowflake managed Iceberg + Horizon, BigQuery
   BigLake, AWS S3 Tables) now sells it managed with catalog, maintenance,
   and row-level deletes included. Day one, analytics runs on a Postgres
   read replica + dbt. The trigger for the lakehouse is the first of:
   ~1M identities, the second vertical, or the first ML model in production,
   expected within months, so the schema contracts that feed it are built
   day one even though the lakehouse itself is staged.

7. **The three ML workloads are two ML systems and one deterministic view.**
   Duplicate detection: Fellegi–Sunter via Splink-class tooling over a
   regional blocking index, with the human-steward review queue as the
   labeled-data flywheel. Party anomaly detection: batch graph features on
   the lakehouse (bipartite party×subject statistics), not a graph database.
   Dimension standing: deterministic, published, recomputed from the live
   operational record. It must never be served from the analytics plane,
   because the analytics plane is eventually consistent with deletions and
   supersessions and the prior packet is not allowed to be.

8. **Residency partitioning starts at two partitions (US, EU) plus a
   rest-of-world default, with the region key stamped on every payload row
   from row one.** Adding a partition (Philippines when local hosting or
   NPC posture requires it; others by trigger) is then an operational
   migration, not a schema change. Retrofitting a region key at 10⁸ rows is
   the canonical impossible migration; stamping it at 10³ costs nothing.

9. **Data contracts govern both boundaries.** The vertical boundary is the
   attestation interface, enforced as a versioned schema registry with
   reject-don't-coerce semantics. The operational→analytical boundary is a
   second, internal contract: every CDC-published column carries
   machine-readable tags (`pii_class`, `residency`, `erasure_group`,
   `retention`) that *drive* erasure propagation and region pinning
   mechanically. Untagged columns don't replicate. This is the single
   highest-leverage early investment in the whole platform.

---

## 1. Operational store

### 1.1 Choice: PostgreSQL, managed, partitioned by plane and region

- **Relational, transactional, boring.** The workload is textbook OLTP with
  strong integrity requirements: alias-table closures on merge/unmerge,
  supersession chains, grant/revocation pairs, registry state machines,
  hash-chain append with monotonic ordering. Every one of these wants
  multi-row transactions and foreign keys. Wide-column/document stores buy
  write scale the system will not need for years (attestation write volume
  is bounded by real-world work events, even 10⁸ workers generating one
  attestation a week is ~165 writes/sec average) at the price of the exact
  integrity machinery the design depends on.
- **Managed (Aurora PostgreSQL or Cloud SQL-class).** Three people do not
  operate databases. Managed Postgres in 2026 handles the first several
  hundred million rows per region without heroics; the sharding cliff is
  far away and, when it arrives, arrives per-region (see §3.4).
- **Physical layout:**
  - `spine` database, global, append-only tables only, no readable
    personal data by schema construction (enforced: columns are IDs, enums,
    fixed-width hashes, signatures, timestamps; no free-text column exists
    in the spine schema, so nothing readable *can* be written there).
    Replicated to every region read-only.
  - `payload-{region}` databases, one per residency partition. All PII,
    all claim content, all contact channels. Hard-deletable. Encrypted with
    per-person envelope data keys (see §2.4).
  - `registry` database, attesting-party registry, keys, lifecycle events.
    Global like the spine; parties are businesses, and the registry is the
    trust root. It colocates with the spine.
- **The spine/payload split is physical, not logical.** A schema-level
  split inside one database means one backup, one replication stream, one
  blast radius, and an erasure story that has to argue about WAL segments.
  Separate databases give the two planes their true, different lifecycles:
  the spine's backups can be kept for years; the payload's cannot exceed
  the erasure SLO.

### 1.2 What the spine is, legally decided, not deferred

The spine holds `ledger_person_id`, object hashes, issuer references,
timestamps. Position taken: **this is personal data** (pseudonymous;
EDPB 02/2025 treats hashes of personal data as personal data), and the
architecture accepts that rather than pretending otherwise. Consequences:

- Global spine replication is a cross-border transfer of pseudonymized
  personal data → covered by SCCs/DPF-equivalents plus the strongest
  available supplementary measure: the data is unreadable without the
  regional payload store, which never leaves its region.
- On R2 deletion, the spine row set for the person is *tombstoned* (person
  marked deleted, ID never reissued) but not physically removed. This is
  the residual retention the logical design already commits to (§2.5 of
  `ledger-design-0.1.md`), and it is defensible precisely because the spine
  was minimized to unreadability. Flag for counsel, per the logical design;
  do not weaken the split waiting for the opinion.
- The pseudonymization boundary is therefore exactly the spine/payload
  boundary, and it must be auditable: an automated schema linter blocks any
  migration adding a readable-content column to the spine. This is a
  10-minute CI job and one of the highest-value controls in the system.

### 1.3 Event-shape from day one

All state changes in the spine and registry are already events in the
logical design (`person_merged`, `party_events`, grants). Keep Postgres as
the source of truth. Do *not* build Kafka-as-source-of-truth event
sourcing. The event tables in Postgres are the ledger; CDC turns them into
streams for consumers. This gets replayability and audit without making a
3-person team operate a distributed log as its system of record.

---

## 2. The copy map and deletion propagation

### 2.1 The copy map (exhaustive, maintained as code)

Every copy a payload datum will ever have, enumerated. Anything not on
this list is prohibited from existing:

| # | Copy | Region-bound? | How deletion reaches it | SLO |
|---|---|---|---|---|
| 1 | Payload primary (regional Postgres) | yes | hard DELETE in deletion saga | 72h |
| 2 | Payload read replicas | yes (same region) | replication of the DELETE | 72h |
| 3 | WAL / PITR window | yes | ages out structurally | window ≤ 7d |
| 4 | Backups (payload) | yes | retention cap + envelope-key destruction | ≤ 35d |
| 5 | CDC topics (payload streams) | yes (regional brokers) | topic retention cap; no compacted PII topics | ≤ 7d |
| 6 | Lakehouse bronze/silver/gold | yes (regional buckets) | deletion-request table → row deletes → snapshot expiry | ≤ 30d |
| 7 | Duplicate-detection blocking index (search index over names/channels/doc-hashes) | yes | delete-by-person, verified | 72h |
| 8 | Feature store rows + any embeddings | yes | keyed by person; deleted with saga | ≤ 7d |
| 9 | ML training snapshots | yes | snapshot TTL ≤ 90d + exclusion list applied at next train; no model ships trained on data older than the TTL | ≤ 90d |
| 10 | Application caches (packet assembly, session) | n/a | TTL ≤ 24h; reads already stop at T0 | 24h |
| 11 | Service logs / traces | n/a | payloads never logged (contract-enforced redaction); IDs only | N/A |
| 12 | Delivered prior packets | recipient's problem | out of scope by design (interface amendment A5) | N/A |
| 13 | Spine + registry | global | tombstone only, by design | N/A |

Two rules make the map enforceable rather than aspirational:

- **No copy without lineage.** Every derived dataset in the lakehouse
  declares its upstream tables; the deletion job walks the lineage graph.
  This is why lineage is a day-one requirement, not an enterprise luxury.
  Retrofitting lineage over an organically grown lake at 10⁸ identities is
  the failure mode that makes erasure unprovable.
- **No compacted or infinite-retention topic may carry payload columns.**
  Streams are transport, not storage. If a consumer needs history, it reads
  the lakehouse, which participates in deletion.

### 2.2 The deletion saga

R2 deletion is a first-class orchestrated workflow (Temporal-class managed
workflow engine, or a Postgres-backed job table day one):

1. **T0 (synchronous):** grants revoked, reads stop, person marked
   `deleting` in spine, packet issuance impossible from this instant.
2. **Fan-out:** one deletion task per copy-map entry, each with an owner
   service, an idempotent delete operation, and a verification step
   (count-by-person = 0, or structural proof such as "retention window
   elapsed").
3. **Acknowledgment ledger:** each task's completion is recorded; the
   deletion is *published to the worker as complete* only when every
   non-structural task has verified. Structural tasks (backup aging) get a
   published date.
4. **Audit:** the saga record itself contains no payload, only the person
   tombstone and per-copy timestamps. It is the artifact shown to a
   regulator.

### 2.3 Deletion SLOs are product surface

The logical design promises a "fixed published window." Make it: **hard
deletion from serving systems in 72 hours; from all analytical copies in
30 days; from backups in 35 days.** Publish those numbers in the consent
instrument (§8.2 of the logical design). SLOs force the engineering; vague
windows rot.

### 2.4 Crypto-shredding: defense in depth, never the mechanism

Per-person envelope data keys for payload-at-rest encryption, destroyed at
deletion. This bounds the harm of any copy the map missed and shortens the
effective life of backups. But EDPB 02/2025 explicitly declines to bless
encryption/hashing as erasure, so key destruction *supplements* physical
deletion everywhere reachable; it substitutes only where physical deletion
is genuinely impossible (immutable backup media inside its capped window).

---

## 3. Residency partitioning

### 3.1 Day-one topology

Three payload partitions: **US, EU, ROW** (rest-of-world default). The
Philippines launches in ROW: the PH DPA regulates conduct and reaches the
operator regardless of hosting, and has no hard localization mandate for
this data class today. What is non-negotiable day one is the *mechanism*:

- Every payload row carries `residency_region` (assigned at signup from
  declared residence + signals; correctable by supported migration event).
- Every service that touches payloads is region-aware: a request for a
  person's payload routes to that person's regional store. The spine tells
  it where to go (`person → region` is spine metadata, a pointer, not
  content).
- Regional infrastructure is stamped out from one IaC module, so partition
  N+1 is a deploy, not a project.

### 3.2 Evolution and triggers

| Trigger | Action |
|---|---|
| NPC/PH posture, PH enterprise partner, or PH volume at scale | carve `PH` out of ROW (mechanical: copy rows where `residency_region='PH'`, flip routing, delete from ROW, itself a copy-map operation) |
| First partner or regulator demanding in-country processing (India, Indonesia, Gulf states are the likely askers) | same carve-out playbook |
| EU counsel outcome on spine transfers | worst case: regional spine *projections* with a global reconciliation protocol, expensive, so the spine-minimization discipline (§1.2) exists precisely to avoid ever needing this |

### 3.3 Cross-region reads

A US vertical reading a prior packet about an EU-resident worker is a
cross-border disclosure of readable personal data. This is the *packet's*
transfer, distinct from the spine question. It happens at read time,
worker-granted, logged. Handle contractually (party data-handling
agreements incorporate transfer terms) and mechanically: the packet is
assembled *in the worker's region* and delivered outward, so raw payload
stores are never queried cross-region. Only finished packets cross, and
every crossing is a logged, attributable event. This keeps the transfer
narrative clean: one worker, one grant, one packet, one log line.

### 3.4 Scale path

Per-region Postgres to ~low-10⁸ rows with partitioned tables; then
per-region sharding (Citus-class or application-level by
`ledger_person_id` hash, the opaque UUIDv7 ID is an excellent shard key,
another reason the ID design is right). Because partitioning is by region
first, no single database ever holds the planet; the 10⁸-identities
problem arrives as several 10⁷–10⁸ regional problems, which managed
Postgres + sharding handles without exotic technology.

---

## 4. Analytics and ML architecture

### 4.1 Topology

```
payload-{region} ──CDC──▶ regional Kafka/Kinesis ──▶ Iceberg bronze-{region}
spine, registry  ──CDC──▶ global stream          ──▶ Iceberg bronze-global
                                                    │
                                     dbt/SQL ──▶ silver (conformed, PII-tagged)
                                                    │
                                          gold marts: dedupe features,
                                          party-graph features, ops metrics
```

- **One warehouse engine over Iceberg, managed.** In 2026 this is a
  commodity choice: Snowflake managed Iceberg (Horizon catalog, RBAC,
  masking, lineage built in), BigQuery + BigLake metastore, or Athena/
  SageMaker Lakehouse over S3 Tables. Pick the one on the chosen cloud;
  the Iceberg substrate keeps the engine swappable. That is the point of
  Iceberg. Never self-hosted Spark with three engineers.
- **Regional buckets for payload-derived tables.** The lakehouse inherits
  the residency partitioning; cross-region analytics runs over the
  *global* tables (spine-derived, pseudonymous) plus per-region aggregates.
  Operator analytics rarely needs readable PII cross-region; when a
  workload does (dedupe review), the reviewer tooling reads
  region-locally.
- **Managed CDC.** Postgres logical replication into a managed connector
  (MSK Connect/Debezium, Datastream, or Snowflake's Postgres connector),
  never hand-rolled pollers. CDC configs are code-reviewed against the
  column tag registry: a column without tags does not ship.

### 4.2 Workload 1, duplicate detection (real ML system)

- **Model:** Fellegi–Sunter probabilistic linkage. Splink is the mature
  open implementation and runs on the warehouse engine directly.
- **Blocking:** candidate generation from a regional index over normalized
  name variants, DOB, channel identifiers, document-number salted hashes.
  This index is copy-map entry #7 and participates in deletion.
- **Serving:** signup-time synchronous candidate check (index lookup +
  cheap scoring) plus nightly batch full-pass; both emit *candidates*,
  never merges.
- **Human loop as flywheel:** the steward review queue (mandated by the
  logical design for any attested-history merge) is the labeling system.
  Every steward decision is an append-only event → training data for
  threshold calibration. Design the queue tooling as carefully as the
  model; at up-to-10% organic duplicate rates, review throughput is the
  real bottleneck, and the model's job is queue *ranking* as much as
  auto-merge.
- **Metrics from day one:** precision on auto-merges (target: no wrong
  merge, ever, a wrong merge contaminates a career), steward
  agreement rate, queue latency, duplicate-rate by cohort.

### 4.3 Workload 2, party anomaly detection (batch graph statistics)

- Bipartite party×subject graph features computed in the warehouse on
  schedule: attestation velocity, subject-set overlap between parties,
  score-distribution divergence, dispute/correction/corroboration rates,
  cluster density vs. cohort baselines.
- **No graph database.** At attestation cardinalities (parties in the
  thousands, edges in the hundreds of millions eventually), SQL over
  Iceberg computes these features fine; a graph DB is a fourth datastore
  to operate for query patterns that are actually aggregations.
- Output: internal-only party reliability signal → registry action queue
  (probation, audit, suspension) with human decision, matching §3.5 of the
  logical design. Never a visible score.

### 4.4 Workload 3, dimension standing (deterministic; not ML; not analytics-plane)

The standing rule is published, deterministic, and coarse. Therefore it is
an **operational-plane materialized view**: computed from live attestations
in the regional payload store, invalidated by attestation/supersession/
deletion events, recomputed synchronously or near-synchronously. It must
not be served from the lakehouse. The lakehouse is minutes-to-hours stale
against deletions and grants, and the prior packet's correctness guarantee
("generated at read time from the live record") forbids that staleness.
The lakehouse *evaluates* the standing rule (calibration studies across
verticals); it never serves it.

### 4.5 The analytics privacy boundary

Operator analytics that workers don't see (decision 4) still operates on
regulated data. Rules: silver/gold tables default to pseudonymous (spine
IDs, no readable PII); readable-PII columns exist only in bronze and in
the two workloads that need them (dedupe features), access-controlled and
audited via the warehouse's native governance (masking, row policies,
another reason to buy Snowflake/BigQuery-class governance rather than
build it).

---

## 5. Languages, tooling, hosting

- **Services:** TypeScript/Node, matches the team, and this system's
  services are I/O-and-integrity logic, not compute. One modular monolith
  day one (packet assembly, ingestion, grants, deletion saga as modules),
  split only along the plane boundaries when scale forces it.
- **Data transforms:** SQL + dbt (lineage, tests, docs generated,
  dbt's lineage graph is the day-one lineage system, upgraded later only
  if needed).
- **ML:** Python, only where ML lives (Splink, scikit-learn, review-queue
  ranking). No Python in the serving path.
- **Workflow/orchestration:** managed workflow engine (Temporal Cloud) or
  Postgres job tables initially; Dagster/managed Airflow for batch when
  the lakehouse lands.
- **Hosting:** one cloud, multi-region within it. AWS is the default call
  (region coverage incl. Frankfurt + future carve-out regions, Aurora,
  MSK/DMS, S3 Tables' native Iceberg); GCP (Cloud SQL/AlloyDB +
  Datastream + BigQuery/BigLake) is an acceptable alternative with a
  slightly better managed-analytics story. The wrong answer is two clouds.
- **Everything infra is IaC** from the first week. The regional stamp-out
  (§3.1) depends on it.

---

## 6. Data contracts at the boundaries

### 6.1 The vertical boundary (external contract)

- The attestation interface is enforced as a **versioned schema registry**:
  attestations validate against `schema_version` at ingestion;
  reject-don't-coerce; rejection returns structured errors to the party.
  The ledger owns the registry (it owns the standard post-ratification).
- The prior packet is likewise a versioned response schema; verticals pin
  versions; deprecation windows are published. The contract's semantic
  rules (priors-not-evidence, no derived estimates upward, no per-unit
  rows) get mechanical teeth where possible: payload size ceilings and
  schema shape make per-unit smuggling structurally awkward, and ingestion
  rejects unknown fields outright.
- Per interface "what never crosses": the ledger's schemas contain no
  columns for routing internals, traces, or per-unit rows. The strongest
  contract is a schema that cannot represent the violation.

### 6.2 The operational→analytical boundary (internal contract)

Every table/column published to CDC carries a registered contract:

```
column: attestation_payload.score_summary
  pii_class: none | quasi | direct | sensitive-banned
  residency: inherit-person | global
  erasure_group: person:<ledger_person_id-fk>
  retention: lakehouse-standard | short | none
```

These tags are not documentation. They are inputs to machinery: the CDC
allowlist, the regional bucket router, the deletion lineage walker, and
the warehouse masking policies are all *generated* from them. Adding a
column without tags fails CI. This one discipline is what makes §2's copy
map maintainable by three people instead of a governance department.

---

## 7. Decisions that are irreversible at 10⁸

1. **The spine/payload physical split and the rule "nothing readable in
   the spine."** Un-splitting is easy; splitting later means re-keying and
   re-writing hundreds of millions of rows *and* their backups while
   proving erasure the whole time. This is the single most irreversible
   call in the system.
2. **`ledger_person_id` format and never-reissue semantics.** It is the
   join key for careers, the shard key, and the erasure group key. Opaque
   UUIDv7, forever.
3. **`residency_region` stamped on every payload row.** Retrofitting
   region assignment at 10⁸ requires deciding, per row, a fact about a
   person you may no longer be able to ask.
4. **CDC as the only copy mechanism / no copy without lineage.** A culture
   of ad-hoc extracts, once formed, cannot be audited back out; the
   datasets it spawns are unerasable because unenumerable.
5. **Column-level PII/erasure tagging in the schema registry.** Tags
   applied at 50 columns are a habit; applied retroactively at 5,000
   columns they are an archaeology project with legal deadlines.
6. **Event-shaped writes (merge, grant, registry, deletion as events).**
   The hash-chain timestamps and audit story depend on it; you cannot
   reconstruct events from state you didn't record.
7. **Streams-as-transport (bounded retention, no compacted PII topics).**
   A compacted Kafka topic that spent two years as somebody's source of
   truth is a permanent, unerasable copy.
8. **Deterministic standing served from the operational plane.** If
   verticals ever consume standing from a stale analytics path, the
   read-time-freshness guarantee (and the deletion guarantee behind it)
   is broken in ways contracts downstream will have hardened around.

Deliberately *reversible*, and therefore not to be over-designed: the
warehouse engine (Iceberg keeps it swappable), the workflow engine, the
dedupe model internals, the blocking index technology, the cloud's managed
CDC flavor.

## 8. Day-one minimal platform vs. staged additions

**Day one (the first ~90 days, 3 people):**

- Aurora-class Postgres: `spine` (global) + `payload-us`, `payload-eu`,
  `payload-row` + `registry`. IaC-stamped regions.
- Modular monolith in TypeScript; deletion saga on Postgres job tables.
- Spine schema linter (no readable columns) in CI; column tag registry in
  CI; copy map checked into the repo as code.
- Analytics: one read replica + dbt + (optionally) DuckDB for exploration.
  No lakehouse, no Kafka.
- Dedupe v0: deterministic blocking index + Splink batch scoring on the
  replica; steward review queue as a first-class internal tool.
- Deletion SLOs published; backup retention capped at 35 days from the
  first backup ever taken.

**Staged, with triggers:**

| Addition | Trigger |
|---|---|
| Managed CDC + regional Iceberg lakehouse + warehouse engine | first of: ~1M identities, second vertical live, first production ML model, or replica analytics degrading OLTP |
| Managed workflow engine (Temporal-class) for the deletion saga | deletion volume or copy-map size makes job-table orchestration error-prone (~10⁵ identities or lakehouse arrival, whichever first) |
| Party anomaly-detection pipeline | first external attesting party activated (the risk it targets barely exists before then) |
| Feature store as a distinct system | second ML model in production (before that, dbt tables are the feature store) |
| PH regional partition | NPC posture, PH enterprise partner requirement, or counsel direction |
| Per-region sharding (Citus-class) | any regional payload DB approaching ~5×10⁸ rows or write ceilings |
| CT-style public commitment log over registry/spine | first consumer needing offline non-tamper proof (v2 hardening per logical design §3.3) |
| Dedicated governance/catalog beyond dbt + warehouse-native | data team > ~5 people or first external audit |

## 9. What I'd veto from other schools

- **"One global Postgres with PII everywhere; we'll shard and regionalize
  later."** Later never comes cheaper. Items 1 and 3 in §7 are exactly the
  migrations this school ends up unable to perform.
- **Kafka-as-source-of-truth event sourcing.** Beautiful on a whiteboard;
  for this system it makes the erasure story nearly unfalsifiable (infinite
  log of payloads) and hands three engineers a distributed log to operate.
  Events yes, in Postgres; log as transport only.
- **Blockchain / immutable-storage anything for payloads, and DID/VC
  maximalism.** The logical design already rejected it for signatures; I
  extend the veto to storage: any medium that cannot hard-delete is
  disqualified from holding payloads, full stop.
- **Microservices day one.** Twelve services × four regions × a deletion
  saga that must reach all of them is an SRE organization, not a startup.
  The plane boundaries are the only service boundaries that pay rent early.
- **DynamoDB/Cassandra-class operational store for "planet scale from day
  one."** Trades away transactions and relational integrity, the exact
  properties merges, chains, and grants require, to solve a write-volume
  problem this workload does not have.
- **Graph database for the trust/anomaly work.** A fourth datastore for
  what are, in practice, SQL aggregations.
- **Serving dimension standing or prior packets from the warehouse.**
  Freshness guarantees (deletion, revocation, supersession) forbid it.
- **"Backups are exempt from erasure" as a permanent posture.** Bounded
  backup windows + key destruction is the 2026-defensible position;
  indefinite backup retention of payload data is not.
- **Building identity verification, KYC, or biometric infrastructure
  in-house.** The contract already says verification is bought; the data
  platform stores resulting attestations and evidence *commitments*, never
  raw document images. Keep the most toxic data class entirely outside
  the estate.

## 10. Assumptions

1. **Write volume stays real-world-bounded** (attestations track actual
   work events, not telemetry). If a vertical ever tries to push per-unit
   cadence through the interface, the contract, not the database, is the
   defense.
2. **Counsel does not region-lock the spine.** If EU counsel concludes
   even the minimized spine cannot replicate globally, §3.2's worst-case
   (regional spine projections + reconciliation) is the fallback; it is
   costed as painful but survivable *because* the spine is minimal.
3. **R1 holds.** No CRA machinery is built; the `reportable_until` hook
   from the logical design is honored as a read-path filter, which this
   architecture supports trivially (it is a predicate, not a topology).
4. **The 3-person team is genuinely AI-leveraged.** The day-one platform
   above is roughly 2× what a 2019-era trio could carry and roughly right
   for an AI-heavy 2026 trio; if that assumption fails, cut the third
   residency partition (US+EU only) before cutting the tagging/copy-map
   discipline, which must never be cut.
5. **Iceberg's market position holds** (it is the settled default across
   Snowflake, Google, and AWS as of mid-2026); the bet is hedged anyway,
   since Iceberg's openness is what makes the engine choice reversible.
6. **Scale arrives as stated** (~1M in months). If it arrives 10× slower,
   nothing above is wasted. The staged additions simply trigger later;
   the day-one platform is deliberately small enough to be cheap even in
   the slow world.

---

**Web sources consulted (2026 state of the art):**
[State of Apache Iceberg Catalogs, June 2026](https://dev.to/alexmercedcoder/the-state-of-apache-iceberg-catalogs-in-june-2026-265e) ·
[Snowflake managed Iceberg + Horizon](https://medium.com/dataaichronicles/snowflake-just-made-iceberg-the-default-what-v3-horizon-catalog-and-managed-storage-mean-for-c3767fc64449) ·
[Google Cloud Lakehouse for Apache Iceberg](https://cloud.google.com/products/lakehouse) ·
[Databricks: Iceberg v3](https://www.databricks.com/blog/next-era-open-lakehouse-apache-icebergtm-v3-public-preview-databricks) ·
[Dremio: Iceberg and the Right to Be Forgotten](https://www.dremio.com/blog/apache-iceberg-and-the-right-to-be-forgotten/) ·
[Databricks GDPR deletion guidance](https://docs.databricks.com/aws/en/ldp/gdpr) ·
[EDPB right-to-erasure enforcement findings (2026)](https://jetico.com/blog/what-the-edpbs-right-to-erasure-report-reveals-about-where-organizations-still-struggle/) ·
[GDPR deletion and backups](https://www.probackup.io/blog/gdpr-and-backups-how-to-handle-deletion-requests)
