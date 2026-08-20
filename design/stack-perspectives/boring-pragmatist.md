# Stack Perspective: The Boring-Technology Pragmatist

Author stance: one language, one relational database, one deployment unit,
managed services, no distributed systems until measured load forces them.
This is not an aesthetic preference. It is a claim about where this company
will actually die if it dies: operational complexity and a three-person team
spread across systems nobody deeply understands, not database ceilings.
The arithmetic below shows the ceilings are farther away than the
planet-scale intuition suggests, and the migration path when we reach them
is well-trodden.

---

## TLDR

1. **This is a low-write system of record wearing a planet-scale costume.**
   Attestation volume, not identity count, is the load. At 100M identities
   the honest arithmetic is ~50 attestation writes/sec average, ~500/sec at
   batch peaks, and low-thousands of prior-packet reads/sec. One large
   managed Postgres with read replicas handles this with an order of
   magnitude to spare. At 1M identities (the "within months" target) the
   load rounds to zero.
2. **Stack: TypeScript everywhere, one modular monolith, one Aurora
   PostgreSQL cluster, AWS, no Kubernetes.** Node/TS API + Next.js worker
   surface in one monorepo, deployed as one unit on ECS Fargate behind an
   ALB, SQS in front of attestation ingestion, S3 for blobs and spine
   checkpoints. Every component is a managed service with a runbook the
   industry has already written.
3. **Two-plane model maps directly onto vanilla Postgres**: append-only
   spine tables with UPDATE/DELETE revoked at the database level, erasable
   payload tables keyed by object ID. R2 deletion is a payload-plane
   `DELETE`; the spine never changes. No event store, no separate ledger
   database, no blockchain.
4. **Crypto is a library call, not an architecture.** Ed25519/JWS via
   libsodium; a single serialized hash chain over the spine with hourly
   Merkle checkpoints exported to S3 Object Lock (WORM). Ledger keys in AWS
   KMS. Total crypto surface: a few hundred lines, auditable by one person.
5. **Where it genuinely breaks**: sustained chained writes above roughly
   2–5K/sec (hash-chain head serialization), any single table approaching
   Aurora's 32 TiB per-table limit, working set past a single node's RAM at
   the read path, or, most likely first, a legal data-residency mandate,
   not a performance ceiling. Every one of these has a documented,
   incremental exit (per-shard chains, person-keyed sharding, regional read
   replicas) that is *easier* to execute because the v1 is simple.
6. **Vetoes**: Spanner/DynamoDB/Cosmos day one, Kafka-as-source-of-truth
   event sourcing, microservices, DID/blockchain anchoring, self-run
   Kubernetes, and any bespoke consensus or HSM ceremony. Each adds
   permanent operational tax to solve a problem the arithmetic says we will
   not have for years, and the unlimited capital that arrives *if it gets
   big* funds the migration then, with ten times today's engineering
   capacity.

---

## 1. The arithmetic, honestly

The founder's trajectory: ~1M identities within months, hundreds of
millions in ~2 years. Take it at face value and convert it into what a
database actually experiences. Identity count is a vanity denominator;
**attestation writes and prior-packet reads are the load**, because the
interface contract is deliberately narrow: one attestation per completed
engagement or per period-and-work-kind, aggregates only, per-unit work rows
never cross, behavioral traces never cross.

**Write volume.**

| | 1M identities (months) | 100M identities (~2 yr) |
|---|---|---|
| Active fraction (being routed/attested) | ~30% → 300K | ~30% → 30M |
| Attestations per active worker per month (period cadence, 1–2 engagements) | ~4 | ~4 |
| Attestations/month | ~1.2M | ~120M |
| Average writes/sec | **~0.5** | **~46** |
| Peak (parties batch-submit at period close, 10× average) | ~5 | **~460** |

Each write is: schema validation, one Ed25519 verification (~50µs of CPU),
a registry lookup (cached), two inserts (spine + payload), one chain-hash.
Call it 2–3ms of real work. A single mid-size Postgres instance sustains
5–15K simple OLTP writes/sec; we need three orders of magnitude less at
launch and one order less at the two-year horizon. **The ingestion queue
(SQS) exists to absorb the batch peaks, not because the database needs
protection.**

**Read volume.** Prior packets are generated at read time, triggered by
grants and routing events, not by page views. Assume 2 packet generations
per active worker per month plus worker-view traffic at 10× that:
~60M packet reads/month at the 100M mark ≈ 23/sec average, maybe 1–2K/sec
at coordinated peaks. A packet is 5–10 indexed, person-scoped queries. Read
replicas make this embarrassing.

**Storage.** Spine row ~0.5KB, payload ~2KB. At maturity, 50 lifetime
attestations per identity: 100M × 50 × 2.5KB ≈ **12.5 TB**. Add
verification attestations, party events, grants, and the genuinely
high-volume table, the read log (~720M rows/year at the above read rate,
~1TB/year), and the two-year system is **20–30 TB**. Aurora PostgreSQL
now scales to 256 TiB per cluster ([AWS, July
2025](https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-aurora-postgresql-database-clusters-256-tib-storage-volume/)),
with a 32 TiB per-table limit ([Aurora
quotas](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_Limits.html)).
Native range partitioning (monthly on the spine, hash-on-person
for payloads) keeps us far under per physical table. The practitioner
literature is consistent that partitioning plus replicas carries Postgres
comfortably into the billions-of-rows, multi-TB range before sharding is
forced ([Severalnines](https://severalnines.com/blog/advanced-partitioning-strategies-for-postgresql-oltp-and-analytics-datasets-at-scale/),
[pgDash](https://pgdash.io/blog/scaling-postgres.html),
[Tinybird](https://www.tinybird.co/blog/scaling-postgres-to-billions-of-rows)).

**Conclusion of the arithmetic**: the planet-scale framing confuses
*identities held* with *load generated*. A career ledger is closer in shape
to a land-title registry than to a social feed. Registries run on
relational databases. Ours should too.

## 2. Language and shape: TypeScript modular monolith

**One language: TypeScript, end to end.** Reasons, in order:

1. The worker surface is necessarily web/TS; a second backend language
   doubles the type-definition surface at exactly the boundary (the
   attestation schema, the packet schema) where drift is most dangerous.
   One Zod schema set is the single source of truth for API validation,
   packet generation, and the worker UI.
2. The team is founder + 2 engineers with AI agents writing most code.
   TypeScript is the deepest AI-generation corpus that also has a strict
   compiler; the compiler is the review layer that scales when human review
   doesn't. A boutique language with a thinner corpus (or a split Go/TS
   stack) raises AI error rates precisely where we have the least review
   capacity.
3. Nothing in the load profile needs Go/Rust throughput. Ed25519
   verification is a libsodium native call regardless of host language.

**One deployment unit: a modular monolith.** Internal modules with
enforced import boundaries (`identity`, `registry`, `attestation`,
`packet`, `dispute`, `taxonomy`, `worker-surface`, `partner-api`), the
service boundaries we would *draw* if forced, kept as folders instead of
network hops. HANDOFF already says the schema line binds now and the
service boundary later; a monolith is that ruling expressed in
infrastructure. Three people cannot operate twelve services; one deploy,
one log stream, one on-call surface.

## 3. Database and the two-plane schema

**One Aurora PostgreSQL cluster** (writer + 2 readers, Serverless v2 or
provisioned r-class; Multi-AZ). Postgres specifically because the design's
invariants are *relational constraint* problems, and the safest place to
enforce invariants that AI-generated application code must not be able to
violate is the database itself.

Two-plane mapping, concretely:

- **Spine tables** (`attestation_spine`, `claim_spine`, `person_events`,
  `party_events`, `key_events`, `grant_events`, `merge_events`,
  `read_log`): append-only enforced by revoking UPDATE/DELETE from the
  application role and a belt-and-suspenders trigger. Columns: IDs, type,
  class, subject/issuer refs, payload SHA-256 commitment, signature,
  `supersedes`, ledger sequence + chain hash, timestamps. No readable PII.
  Range-partitioned by month.
- **Payload tables** (`attestation_payload`, `claim_payload_versions`,
  `contact_channels`, `person_pii`): keyed by spine object ID, JSONB
  content validated against versioned Zod schemas at the app layer (the
  sensitive-data ban enforced there *and* by CHECK constraints on known
  forbidden keys). Hash-partitioned by `subject_id`. **R2 deletion is
  `DELETE ... WHERE subject_id = $1` across the payload plane plus a
  tombstone event on the spine.** One transaction family, one database,
  verifiable completion. This is where a polyglot design (payloads in a
  document store, spine in Postgres) turns a legal guarantee into a
  distributed-consistency problem. Veto.
- **Registry, taxonomy, aliases, standing cache**: ordinary relational
  tables. Standing is a recomputable cache per design §5; a materialized
  table refreshed on write, never a source of truth.
- **Alias closure and supersession chains**: recursive CTEs at read time,
  cached. Person-scoped, depth-bounded, cheap.

The single most important property: **every query in the system is
person-scoped or party-scoped.** No cross-person joins in any hot path.
That is what makes the eventual sharding story (§9) mechanical rather than
architectural.

## 4. Hash chain and signatures: small, boring, auditable

- **Party signatures**: Ed25519 over a canonical (JCS) payload in a JWS
  envelope, `kid`-bound, verified against the registry, exactly as the
  ledger design specifies. Implementation: libsodium via Node bindings.
  No DID resolution, no JSON-LD canonicalization stack (a notorious
  complexity and vulnerability sink). VC-2.0-shaped claims so the
  projection stays mechanical if interop ever becomes real.
- **Ledger hash chain**: a monotonic `ledger_seq` (single-row head, updated
  in the append transaction) with
  `chain_hash = SHA256(prev_hash || object_hash)`. At <500 writes/sec this
  serialization point is a non-issue; its ceiling (~2–5K chained
  writes/sec) is the first genuine bottleneck in the system and is named in
  §8 with its fix.
- **Checkpoints**: hourly Merkle root over the interval, signed with a
  KMS-held ledger key, written to S3 with Object Lock (compliance-mode
  WORM) and optionally to a second cloud's bucket. This gives
  operator-tamper evidence and makes backups verifiable, and it preserves
  the design's "expose CT-style inclusion proofs later" option without
  building a transparency log now.
- **Keys**: party keys are theirs; ledger and checkpoint keys live in AWS
  KMS with rotation events recorded in `key_events`. No HSM procurement,
  no ceremony beyond KMS's own.

Total bespoke cryptographic code: on the order of hundreds of lines. That
is the correct amount for a team whose crypto reviewer capacity is one
person part-time.

## 5. Auth

- **Workers**: managed identity provider (Cognito or WorkOS-class) doing
  email OTP + passkeys, OIDC into our session. Phone as a contact channel
  and weak signal only, per the design. The IdP must not make phone an
  anchor. Passkeys matter for the emerging-markets base (shared devices,
  SIM churn) and are now table stakes in managed IdPs. We do not build
  password storage, recovery flows, or MFA. Ever.
- **Partners**: OAuth2 client-credentials for transport auth; the
  attestation's own registry-verified signature is the trust mechanism, so
  transport auth stays boring. mTLS offered, not required, at partner
  request.
- **Internal/steward tooling**: same IdP, separate audience, hardware-key
  MFA required for merge review and registry actions.

## 6. Worker-facing surface

Next.js (same monorepo), server-rendered, behind CloudFront. Design
targets: works on a $60 Android over 3G, total JS budget small, no native
app in v1 (a wrapped PWA if distribution demands a store presence). The
worker view is mostly *reads of their own record*. SSR + CDN handles
global latency without global infrastructure: the dynamic calls are few
and person-scoped, the shell is edge-cached. Localization in from the
start (the first cohorts include Philippine ops workers); RTL and
low-bandwidth budgets are product requirements, not scale requirements.

## 7. Partner integration surface

Versioned JSON REST over HTTPS. Nothing cleverer.

- `POST /v1/attestations`, single and batch; **idempotency key
  required**; synchronous schema/signature validation, asynchronous append
  via SQS with a receipt ID; explicit, machine-readable rejection reasons
  (the ledger never silently rewrites, per design §4).
- `GET /v1/packets/{ledger_person_id}`, requires an active grant; returns
  the generated-at-read packet; every issuance writes the read log.
- `GET /v1/registry/{party_id}`, public status/history (eIDAS-style
  transparency).
- `GET /v1/taxonomy/{version}`, the `work_kind` vocabulary and
  crosswalks, cacheable and CDN-served.
- Webhooks (signed, retried) for dispute notifications, supersessions
  affecting a party's attestations, and subject-deleted notices.

OpenAPI spec generated from the same Zod schemas; the spec *is* the
contract artifact partners integrate against. No GraphQL (an open query
surface over a record this sensitive is a disclosure-control bug factory),
no gRPC (partners are HR-tech integrators, not infra teams), no SDK
proliferation beyond a generated TS client.

## 8. Observability, backup, DR

- **Observability**: one managed vendor (Datadog or Grafana Cloud,
  pick one, not both), Sentry for errors, `pg_stat_statements` reviewed
  weekly. Four golden dashboards: ingestion latency/rejection rate, packet
  generation latency, chain-head lag, replica lag. Business-integrity
  monitors as first-class alerts: chain verification job (continuously
  re-hashes recent spine segments), deletion-completion verifier, dispute
  SLA clocks, party anomaly-detection batch jobs (nightly SQL + a Python
  notebook is genuinely sufficient at v1 volumes).
- **Backup**: Aurora continuous backup, 35-day PITR; daily snapshot copied
  cross-region and cross-account; hourly Merkle checkpoints to WORM S3
  (which also makes restores *verifiable*, not just possible). Quarterly
  restore drill, timed, written up. An untested backup is a rumor.
- **DR**: single primary region (us-east or ap-southeast given the
  Philippine cohort, a product call), cross-region Aurora replica,
  RPO ≈ seconds, RTO ≈ 1 hour via promotion runbook. Not active-active:
  active-active writes on a hash-chained ledger is a hard distributed
  problem we should refuse to have.

**One caveat argued honestly: erasure vs. backups.** R2 deletion must
eventually reach backups. Policy: payload purge is immediate in the live
database; backups age out on the published 35-day window; the deletion
notice states this. This is the industry-standard posture and another
reason to keep exactly one payload store. Every additional copy of PII is
another erasure obligation.

## 9. Team workflow for AI-heavy development

The stack above is itself the AI strategy. AI agents fail worst on
distributed-systems reasoning (partial failure, cross-service invariants,
eventual consistency) and best on typed, single-process, schema-first code.
So:

- **Invariants live in the database, not in prose.** Append-only via
  revoked grants and triggers; sensitive-data bans via CHECK constraints;
  foreign keys everywhere. An AI agent *cannot* generate code that edits an
  attestation, because the role can't.
- **One source of truth for shapes**: SQL migrations + generated types +
  Zod schemas, all in the monorepo; CI fails on drift.
- **Human review is budgeted, not uniform**: mandatory human review on the
  spine, crypto, deletion, and packet-generation paths; agent-written UI
  and CRUD flows ride on the type system plus integration tests. A
  golden-file test suite over packet generation and chain verification is
  the regression net that lets agents refactor freely.
- **Trunk-based, one pipeline, deploy on green, feature flags** for
  anything touching partner-visible behavior. No release trains, no
  staging archipelago.

## 10. Where this breaks, specific thresholds

1. **Chain-head serialization**: the single-row ledger head caps chained
   appends at roughly **2–5K/sec** (lock + fsync bound). At 4 attestations
   per active worker per month, that ceiling corresponds to **~2 billion
   monthly attestations** if smoothed, but batch peaks reach it around
   **~1B active identities**, or far earlier if the interface contract is
   ever loosened to admit event-grade data. The contract is the load
   shield; defend it.
2. **Per-table 32 TiB / operational bloat**: the read log crosses
   painful-VACUUM territory (~5–10B rows) around year 3–4 at the 100M
   trajectory. Fix is mechanical (aggressive partition drop-and-archive to
   S3/Parquet after 13 months hot) and should be built in year one because
   it is two days of work.
3. **Working set past single-node RAM (~1–2 TB effective)**: packet reads
   degrade first. Read replicas + the person-scoped access pattern push
   this out; it becomes real somewhere past **~300–500M identities with
   active read traffic**.
4. **Data residency (the actual first break)**: an EU or Philippine
   localization mandate forces a second region *legally* long before load
   forces one technically. This is a compliance fork, not a scale fork,
   and no planet-scale database choice today would dodge it, because it
   dictates *where* data lives, not *how it shards*.

## 11. Migration path when it does

In order, each triggered by a measured threshold, none by anticipation:

1. **Now → first pain**: bigger instance, more replicas, partition
   hygiene. (Vertical scaling remains criminally underrated;
   see [pgDash](https://pgdash.io/blog/scaling-postgres.html).)
2. **Chain ceiling approached**: split the single chain into **N per-shard
   chains** (person-hash) with the hourly Merkle checkpoint becoming a
   super-root over shard heads. Verification semantics unchanged;
   checkpoint format designed for this from day one (§4).
3. **Single-writer ceiling or residency mandate**: **shard by
   `ledger_person_id`**, Citus or application-level, whichever is boring
   at that date. Every hot query is already person-scoped (§3), so
   sharding is a routing change, not a redesign. The append-only spine is
   the easiest data shape in existence to shard and replicate: no
   cross-shard transactions exist because no cross-person writes exist.
4. **Only then**, with hundreds of engineers and the promised capital, is
   a distributed-native store even worth evaluating, and by then the
   spine's total ordering requirements are already relaxed to per-shard,
   which is exactly the shape those systems want.

The migration is cheap *because* v1 is simple: one schema, one language,
invariants in the database, and a load shield in the interface contract.
Complexity now would not prevent the migration; it would just mean
migrating a complicated thing instead of a simple one.

## 12. What I'd veto from the other schools, and why

- **Planet-scale school (Spanner / DynamoDB / Cosmos / CockroachDB day
  one).** Solves a write-throughput problem we measurably do not have
  (§1), at the price of: no mature relational constraints to hold the
  append-only and sensitive-data invariants against AI-generated code,
  weaker transactional deletion for R2, thinner AI training corpus, and a
  permanent operational tax on a three-person team. "Design for 10⁸
  honestly" means doing the arithmetic, which shows 10⁸ identities is
  ~50 writes/sec, not buying Google's problems with Google's headcount.
- **Event-sourcing / Kafka-as-source-of-truth school.** Superficially
  seductive because the domain is append-only, but the domain needs an
  append-only *record with strong read-time joins, constraints, and a
  transactional erasable plane*, which is a ledger table, not a log
  pipeline. Kafka gives us at-least-once delivery semantics where we need
  exactly-once legal semantics, makes R2 deletion (compacted topics,
  consumer-side copies) a research project, and doubles the source-of-truth
  surface. SQS as a dumb ingestion buffer, yes; a streaming platform as
  the system of record, veto.
- **Crypto-heavy school (blockchain anchoring, DIDs, ZK proofs, verifiable
  data registries).** The research corpus already adjudicated this (`04`):
  the hard problem is party vetting and the trust registry; signatures are
  easy and decentralization buys nothing when there is one root of trust.
  Us. Public-chain anchoring adds a dependency with its own outage and fee
  politics to deliver what an S3 WORM Merkle checkpoint delivers for
  dollars. ZK selective disclosure contradicts the founder's own decision 7
  (no claim-level curation). Keep the VC-shaped envelope, skip the
  movement.
- **Microservices / Kubernetes.** Twelve services is twelve failure modes
  and zero additional capacity for a team of three plus agents. The module
  boundaries are drawn; they ship as folders.

## 13. Assumptions I'm making

1. **Active fraction and cadence**: ~30% of identities actively attested,
   ~4 attestations/month each. If the real cadence is 10× (e.g., weekly
   per-engagement attestations across many gigs), all figures shift one
   order, and the conclusion still holds at 100M (460 avg / 4.6K peak
   writes/sec is within one Postgres writer with the SQS buffer; the
   chain-shard split in §11.2 moves up the calendar).
2. **The interface contract holds.** Aggregates only; no behavioral
   traces, no per-unit rows. If product pressure pushes event-grade data
   into the ledger, the load model breaks and so does every other school's.
   That is a product decision to fight, not an architecture to
   pre-build.
3. **Read volume is grant/routing-driven**, not feed-driven. If the worker
   surface grows social/feed mechanics, the read path needs a separate
   (cacheable) tier, additive, not a rewrite.
4. **AWS as the cloud** is interchangeable with GCP (AlloyDB/Cloud SQL);
   the argument is "one major cloud's managed Postgres," not AWS
   specifically.
5. **The 100M-in-2-years trajectory is aspiration to design against, not
   a commitment to pre-pay for.** I have designed the break-glass points
   and exits against it honestly; I refuse to spend today's three-person
   team on it.
6. **Counsel outcomes (CRA posture, residency)** may impose structure
   (regions, retention windows) that no stack choice avoids; the design's
   policy hooks (§2.6 of the ledger design) are configuration on this
   stack.

Sources for load-bearing external facts:
[Aurora PostgreSQL 256 TiB (AWS, 2025)](https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-aurora-postgresql-database-clusters-256-tib-storage-volume/) ·
[Aurora quotas/32 TiB table limit](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_Limits.html) ·
[Vertically scaling PostgreSQL (pgDash)](https://pgdash.io/blog/scaling-postgres.html) ·
[Partitioning at scale (Severalnines)](https://severalnines.com/blog/advanced-partitioning-strategies-for-postgresql-oltp-and-analytics-datasets-at-scale/) ·
[Scaling Postgres to billions of rows (Tinybird)](https://www.tinybird.co/blog/scaling-postgres-to-billions-of-rows)
