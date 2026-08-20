# Stack Perspective: Log-Centric / Event-Sourced

Author persona: the event-sourcing architect. Independent perspective; no
other stack-perspectives read. Inputs: `design/ledger-design-0.1.md`,
`handoff/attestation-interface.md`, `research/00-founder-grilling-2026-08-17.md`,
`research/07-synthesis.md`, plus current-state web checks on event-store
tooling (August 2026).

---

## TLDR

1. **This system is already event-sourced; the only question is whether we
   admit it.** Every mutation in ledger-design-0.1 is an append (attestation,
   supersession, merge/unmerge, grant/revocation, key event, party lifecycle,
   deletion), every read is a fold (prior packet, dimension standing, alias
   closure, derived issuer flags). Modeling it as mutable tables with an
   audit trail bolted on would re-introduce update-in-place semantics that
   corrupt exactly the guarantees the product sells. The event log is the
   source of truth; everything else is a rebuildable projection.

2. **The log should BE Postgres for the first several years.** One
   append-only `events` table (insert-only at the privilege level),
   per-stream sequence numbers for optimistic concurrency, monthly
   partitions. No Kafka, no Kurrent/EventStoreDB, no purpose-built store at
   v1. The arithmetic below shows even the two-year "hundreds of millions of
   identities" scenario peaks in the low thousands of events/second, small
   by log standards. Kafka's ops burden buys nothing a 3-person team needs,
   and its dual-write hazard (validate against one store, publish to
   another) is precisely the bug class this product cannot afford.
   Postgres-as-log gives synchronous, transactional command validation
   against projections in the same database. That is the one honest
   superpower a small team should not give up.

3. **Two planes map cleanly onto CQRS-with-a-twist.** The integrity spine is
   the event log itself: events carry pointers to payloads plus *salted*
   commitments, never PII. The erasable payload plane is a separate store,
   one data-encryption-key per person; R2 deletion = destroy the DEK *and*
   hard-delete the rows (crypto-shredding alone is mitigation, not
   compliance, per EDPB, do both). The hash chain is built into the log:
   per-stream chains plus periodic signed Merkle checkpoints, CT-style, so
   integrity never requires a global serial write lock.

4. **The event contract, not the substrate, is the load-bearing artifact.**
   A versioned event schema (additive-only within a version, upcasters
   across versions, never migrate stored events in place) is what lets the
   substrate move: partitioned Postgres, then Citus/Aurora Limitless, then
   a purpose-built store if planet scale ever demands it, under an
   unchanged contract. Section "Invariants" enumerates what must hold
   regardless of substrate; that list is the real deliverable.

5. **Reads are events too.** Packet issuance is logged as a first-class
   event because the worker-visible read log is a product feature, not
   telemetry. Grants, revocations, and disputes are events for the same
   reason. Derived things (standing, current-truth heads, issuer-suspended
   flags, alias closures) are *never* written as facts. They are
   projections, recomputable, and versioned by projector code, which is how
   "derived-at-read" stays true when the derivation rule changes.

6. Languages: TypeScript end-to-end (team default, AI-generation-friendly),
   with the signature/hash verification core isolated behind a small
   interface so it can be rewritten in Rust if verification ever becomes the
   hot path. Hosting: one managed Postgres (Aurora Postgres or Crunchy
   Bridge), stateless API + projector containers, single primary region,
   read replicas for packet assembly. Observability is dominated by one
   number: projection lag, treated as an SLO from day one.

---

## 1. Why the log is the model, not an implementation detail

Read ledger-design-0.1 with an event-sourcing eye and the pattern is total:

- "A correction is a superseding attestation, never an edit." Appends.
- "Merge is a new immutable event... unmerge flips the alias pointer back;
  because neither event stream was touched, reversal is clean." That
  sentence only makes sense if streams are the primitive.
- "Suspension flags past attestations at read time; nothing is written into
  the attestation." A projection over two streams (attestations, registry).
- "Standing is a view over the record, recomputable from it, and stored only
  as cache." That is the definition of a read model.
- "Every attestation receives a ledger hash-chain timestamp at write." That
  is the log's own append position, doing double duty as the trust anchor.

If we build this on mutable rows plus triggers-to-an-audit-table, three
corruptions creep in within a year, silently:

1. **Audit as side effect.** Somebody writes an UPDATE path "just for this
   admin fix" and the audit table stops being the truth. The hash chain then
   attests to a history that isn't the one the tables show. For a product
   whose entire pitch is "the record was never altered," this is fatal, and
   it is undetectable until an auditor or litigant finds it.
2. **Derived facts hardening into stored facts.** Standing, current-truth,
   and issuer flags get materialized "for performance," then written back,
   then diverge from the rule that defines them. The design's promise that
   standing is deterministic and citation-backed dies quietly.
3. **Deletion by UPDATE.** R2 deletion implemented as row updates on shared
   tables inevitably leaves PII in WAL segments, indexes, and audit copies.
   Deletion must be a *modeled operation* (an event that triggers payload
   purge in a store designed for purging), not a SQL verb.

Event sourcing is not an aesthetic here. It is the only modeling discipline
under which the product's guarantees are structural rather than behavioral.

## 2. The event model

Streams (the unit of ordering and optimistic concurrency):

- `person-{ledger_person_id}`, everything about one subject.
- `party-{party_id}`, registry lifecycle and key events for one issuer.
- `taxonomy`, one global stream for work_kind versions and crosswalks.
- `registry-root`, root-of-trust changes, checkpoint signing keys.

Event types (the enumeration; names bind, fields are envelope + typed body):

**Person lifecycle**
- `PersonRegistered`, issues the UUIDv7, opens the stream.
- `ContactChannelLinked` / `ContactChannelUnlinked`, channels, never anchors.
- `PersonMerged {survivor, absorbed, evidence_refs, actor}`, appended to
  *both* streams; absorbed stream is thereafter alias-closed, never written.
- `PersonUnmerged {…}`, same, reversal.
- `ProfileDeletionRequested` / `ProfileDeletionConfirmed` (anti-coercion
  window) / `ProfileDeleted`, the last one carries no payload at all; it is
  the trigger for payload-plane purge and tombstones the stream.

**Claims and attestations**
- `SelfClaimAsserted {claim_id, payload_ref, commitment}`, a revision is a
  new `SelfClaimAsserted` with `revises` pointer; versions are events.
- `VerificationRecorded {provider_party, method, level, references_claim?}`,
  freezing of the referenced self-claim is *derived* (a claim is frozen
  iff any party-grade verification references it), never written.
- `PeerAttestationRecorded {issuer_person, anchor_ref?, ingest_signals}`
- `PartyAttestationRecorded {attesting_party, scope, work_kind@version,
  payload_ref, commitment, signature, supersedes?}`, the interface-contract
  object, verbatim; supersession is the same event type with the pointer set.
- `LedgerInvalidationIssued {target_attestation, reason}`, ledger-signed.

**Disputes**
- `DisputeFiled {target, grounds_ref}`
- `DisputeResolvedByCorrection {dispute, superseding_attestation}`
- `CounterStatementAttached {dispute, payload_ref, commitment}`
- `DisputeLapsedUnresponsive {dispute}`, feeds party reliability projection.

**Access**
- `GrantIssued {party}` / `GrantRevoked {party}`
- `PacketIssued {party, purpose_tag, packet_commitment}`, the read log.
  High-volume; see arithmetic. Same log, its own partition strategy.

**Party registry** (on `party-{id}`)
- `PartyRegistered`, `PartyActivated`, `PartySuspended {reason_class}`,
  `PartyReinstated`, `PartyRevoked {reason_class}`
- `PartyKeyRegistered {kid, pubkey, valid_from}`, `PartyKeyRotated`,
  `PartyKeyRevoked`, `PartyKeyCompromiseReported {reported_at}`, the
  "compromise ≠ retroactive invalidation" rule is a pure function over this
  stream plus attestation chain-timestamps.

**Taxonomy** (on `taxonomy`)
- `WorkKindVersionPublished {version, changelog_ref}`
- `CrosswalkPublished {from_version, to_version | external_std, table_ref}`

**Payload plane bookkeeping**
- `PayloadPurged {object_ids[], executed_at}`, appended after the purge
  job completes, so the spine proves deletion happened on schedule without
  saying anything about what was deleted beyond opaque ids.

Envelope, every event: `{event_id, event_type, event_version, stream_id,
stream_seq, global_seq, recorded_at, actor, body, payload_ref?,
payload_commitment?, issuer_signature?, prev_stream_hash, stream_hash}`.

Rule of thumb enforced in review: if a field's value can be computed from
prior events, it does not go in an event. Events record decisions and
received facts; projections compute everything else.

## 3. Arithmetic on event volumes

Assumptions stated so they can be attacked:

- Month ~6: **1M identities.** Say 40% monthly-active in some engagement,
  one period attestation per active worker per month, plus one verification
  event per new signup, plus peer attestations at 0.5/person/month, plus
  packet reads at ~5 per active worker per month.
  - Attestations: 400k/mo ≈ **0.15/s average**.
  - Packet issuances: 2M/mo ≈ 0.8/s.
  - Everything, with a 20x peak-to-average factor: **< 50 events/s peak.**
- Year ~2: **300M identities**, 30% monthly-active.
  - Party attestations: 90M/mo ≈ **35/s avg**, ~700/s at 20x peak.
  - Packet issuances: ~450M/mo ≈ 170/s avg, ~3.5k/s peak.
  - Total sustained write load: **~200–250 events/s average, ~4–5k/s peak**,
    dominated by the read log, not by attestations.
- Storage: spine row ~1 KB. 550M events/mo ≈ **~550 GB/yr → ~6.6 TB/yr** at
  the year-2 rate, of which >80% is `PacketIssued`. Payload plane is
  comparable. Single-digit terabytes per year.

Conclusion the arithmetic forces: **this is a small system pretending to be
a big one.** A single well-tuned Postgres primary sustains 10–50k simple
inserts/s; we need 5k at the two-year peak, and the one high-volume event
type (`PacketIssued`) has no ordering dependency on anything and can be
partitioned freely. Planet scale (billions of identities) multiplies this by
~10x, which is where partitioning by stream becomes real work, and still
nowhere near needing Kafka-class throughput. The scaling problem here is
never log throughput; it is projection rebuild time and operational
discipline. Design for those.

## 4. Log substrate and its evolution path

**v1 (now → ~100M identities): Postgres is the log.**

- One `events` table, `PARTITION BY RANGE (recorded_at)` monthly;
  `PacketIssued` split into its own sibling table from day one (same
  envelope, same chain rules, separate volume profile and retention knobs).
- Append-only enforced structurally: the application role has INSERT and
  SELECT only. No UPDATE/DELETE grant exists on spine tables for any
  service role. Superuser access is break-glass, logged, and alarmed.
- Optimistic concurrency: `UNIQUE (stream_id, stream_seq)`; a command
  handler reads the stream head, validates, appends at head+1; conflict =
  retry. `global_seq` is a bigint from a sequence, advisory ordering, with
  the *verifiable* ordering supplied by the checkpoint tree (§6).
- Commands validate transactionally: because projections live in the same
  Postgres at v1, "subject exists and is not tombstoned", "issuer is active
  and within probation caps", "work_kind@version exists" are checks and the
  append in one serializable transaction. This eliminates the entire
  dual-write / eventual-validation bug class that Kafka-first designs eat.
- Why not Kurrent (né EventStoreDB), Axon, et al.: both are real products
  (Kurrent rebranded and refocused in 2025; Axon Framework remains
  JVM-centric), but each is a new operational surface, a new failure
  domain, and a hiring/knowledge tax on a 3-person team, for throughput we
  demonstrably do not need and features (built-in subscriptions,
  categories) that are ~300 lines of poller against Postgres. EventStoreDB's
  leader-follower write path scales no better than Postgres's anyway.
- Why not Kafka/Redpanda/WarpStream as source of truth: retention-infinite
  Kafka-as-database remains an anti-pattern in practice; no transactional
  read-your-own-validation; per-entity streams (hundreds of millions of
  them) fight the partition model; and the erasable payload plane is
  awkward against immutable segments. Redpanda and WarpStream reduce the
  *ops* burden, not the *model* mismatch. If a downstream consumer ever
  needs a firehose, publish one via logical decoding or a polling outbox.
  The log feeds Kafka; Kafka never feeds the log.

**v2 (~100M+ identities): partition, don't replatform.** Streams are
shard-friendly by construction (a person stream never crosses shards; merge
events are the only cross-stream writes, and they are rare and steward-gated,
so run them through a coordinator). Citus / Aurora Limitless-style sharded
Postgres by `stream_id` hash, with the `taxonomy` and `registry-root`
streams on a designated shard. The event contract, chain rules, and
projector code do not change.

**v3 (only if reality demands): purpose-built log.** If per-stream Postgres
sharding ever hits a wall, the invariants section is the spec for the
replacement. Migration is a stream-by-stream copy with hash-chain
verification at both ends, possible precisely because the contract was
substrate-independent. I assign this <20% probability of ever being needed.

## 5. Projection architecture

Strict CQRS discipline, minimal machinery:

- **Projectors are single-writer, ordered, resumable.** Each projection is a
  small TypeScript worker that tails `events` by `global_seq` (or per-shard
  seq in v2), applies a pure fold function, and records its checkpoint in a
  `projection_checkpoints` row. Delivery is at-least-once; every fold is
  idempotent (keyed on `event_id`). No message broker: a `FOR UPDATE SKIP
  LOCKED` poller or Postgres logical decoding, nothing more.
- **The projection inventory (v1):**
  1. `alias_closure`, merge/unmerge → resolves any historical person id.
  2. `current_truth`, supersession heads per claim/attestation chain.
  3. `registry_state`, party lifecycle + key validity intervals; serves
     both ingestion checks and read-time "issuer since suspended" flags.
  4. `grants_acl`, active grants per (person, party).
  5. `dimension_standing`, the published deterministic rule, with
     citations; cache only, carries the projector code version that built it.
  6. `dispute_state`, open/lapsed/resolved per attestation.
  7. `read_log_view`, worker-facing read history.
  8. `duplicate_candidates`, Fellegi-Sunter feature index feeding the
     steward review queue (reads payload plane; its index rows are
     themselves PII-bearing and are purged with the person).
  9. `party_reliability`, internal-only anomaly/dispute-rate signals.
- **The prior packet is a query, not a projection.** Assembled at read time
  from projections 1–6 plus payload fetches, then discarded; only
  `PacketIssued` (with a commitment to what was served) persists. This is
  how revocation, deletion, and registry changes are always reflected,
  the design doc's requirement, satisfied by construction.
- **Rebuild is a rehearsed operation, not an emergency.** Every projection
  can be rebuilt from `global_seq` 0 into a shadow table and swapped. At
  year-2 volume (~10^10 events, dominated by reads), a full rebuild of a
  non-read projection scans ~10^9 events, hours, not days, and read-log
  events can be skipped by type filter. We rebuild one projection in staging
  monthly as a drill. When the standing rule changes version, the rebuild
  *is* the migration.
- **Synchronous-read exception, used sparingly:** ingestion-path checks
  (issuer active, subject live) read projections inside the append
  transaction, so those projections are updated transactionally by the
  command handler (dual-maintained: transactional apply + idempotent
  projector as reconciler). Everything else is async with lag SLOs.

## 6. Payload store and deletion mechanics

- Separate schema (v1) / separate cluster (v2): `payloads(object_id,
  person_scope, ciphertext, dek_ref, salt, created_at)`.
- **Per-person DEK**, envelope-encrypted under a KMS root. Every payload row
  for a person encrypts under that person's DEK.
- **Salted commitments.** The spine's `payload_commitment` is
  `H(salt ‖ canonical_payload)` with the salt stored *only* in the payload
  row. After purge, the commitment is an opaque value that cannot be
  dictionary-tested against guessed payloads. This materially strengthens
  the "hashes of personal data are still personal data" posture the design
  doc flags. The commitment still proves integrity while the payload lives.
- **R2 deletion = three steps, all evented:** `ProfileDeleted` appended →
  purge job destroys the DEK, hard-deletes payload rows and PII-bearing
  projection rows (duplicate-candidate features, contact channels), vacuums
  → `PayloadPurged` appended with the object-id list and execution time.
  The spine then proves deletion happened within the published window.
  Deletion itself becomes attestable, which no update-in-place design gives
  you.
- Backups: payload-plane backups are encrypted per the same DEK scheme, so
  DEK destruction renders backup copies unreadable immediately; hard-delete
  ages out of backup retention (published window ≥ backup retention).

## 7. Hash chain and signature integration

- **Per-stream chain:** every event carries `prev_stream_hash` and
  `stream_hash = H(prev ‖ envelope-canonical)`. Cheap, contention-free
  (streams are single-writer by optimistic concurrency), and gives
  per-person / per-party tamper evidence.
- **Global checkpoints, CT-style:** every N seconds, a checkpoint job builds
  a Merkle root over all stream heads advanced since the last checkpoint and
  appends a ledger-signed `CheckpointPublished` to `registry-root`. This is
  the "ledger hash-chain timestamp" the key-compromise rule needs: an
  attestation's trusted time is the earliest checkpoint covering it. No
  global serial write lock; ordering granularity of seconds is ample for
  "did this precede the compromise report."
- Issuer signatures (Ed25519/JWS, kid-bound) are verified at ingestion
  against `registry_state` and stored in the envelope; re-verification is
  always possible because key-validity intervals are themselves events.
- v2 hardening (already anticipated in ledger-design-0.1 §3.3): publish
  checkpoint roots externally (a public S3 bucket + a witness or two) so
  the operator cannot silently rewrite history even with superuser access.
  Inclusion proofs to consumers become possible without schema change.

## 8. Languages, hosting, API surface, observability

- **TypeScript everywhere** (command API, projectors, packet assembler,
  steward console). Matches the team default, maximizes AI-codegen
  leverage, one toolchain. The crypto core (canonicalization, hashing,
  chain verification, JWS) is a single small package with a frozen
  interface and exhaustive vectors. This is the one component where a later
  Rust rewrite is pre-authorized if profiling demands it. Zod (or equivalent)
  schemas generated from the event-contract source of truth; the contract
  repo is the artifact both engineers and the AI tooling are pointed at.
- **Hosting:** one cloud (AWS), one primary region. Aurora Postgres (or
  Crunchy Bridge if we want less lock-in) for spine + projections; a second
  instance for the payload plane so its access controls, encryption posture
  and backup policy differ; KMS for DEK roots; stateless services on
  ECS/Fargate; read replicas serve packet assembly. Multi-region reads
  later; multi-region *writes* only with v2 sharding, and even then
  region-pinned by stream, never active-active on one stream.
- **API surface:** small and asymmetric, mirroring the interface contract.
  - Write: `POST /attestations` (party-signed), `POST /claims` (worker),
    `POST /disputes`, `POST /grants`, `DELETE /profile` (the R2 flow),
    registry admin endpoints (steward-gated). Every write is a command that
    becomes exactly one event or is rejected whole.
  - Read: `GET /me/*` (raw record, read log), `GET /packet/{person}`
    (grant-checked, logged), `GET /registry/{party}` (public status),
    `GET /taxonomy/*`. No generic query API; no endpoint ever exposes
    another tenant's projection.
  - Internal: steward console (merge review, dispute ops) drives the same
    command API. No side doors into the database.
- **Observability:** the north-star metrics are (1) projection lag per
  projector, alarmed against per-projection SLOs (grants/ACL: seconds;
  standing: minutes); (2) chain-verification audit, a continuous job
  re-walks recent stream chains and re-verifies a random sample of issuer
  signatures, because tamper-evidence you never check is decoration;
  (3) event-count reconciliation between spine and each projection;
  (4) deletion-SLA tracking from `ProfileDeletionConfirmed` to
  `PayloadPurged`. OpenTelemetry traces keyed by `event_id` so any packet
  can be traced to the events it folded. Sentry for exceptions. That is the
  whole stack; no Datadog-scale spend at v1.

## 9. The invariants that must hold regardless of substrate

The substrate will change; these may not:

1. **No spine write path supports update or delete.** Enforced by
   privilege, verified by audit, not promised by convention.
2. **Every fact enters as exactly one event; every event is attributable**
   (actor, and issuer signature where the actor is a party or worker key).
3. **Per-stream total order with monotonic `stream_seq`,** and a verifiable
   global happened-before at checkpoint granularity. Consumers may rely on
   stream order; they may never rely on cross-stream order finer than
   checkpoints.
4. **Events carry pointers and salted commitments, never PII.** Any event
   found embedding payload content is a sev-1, because it breaks R2.
5. **Every user-visible state is a deterministic fold** over (events,
   payload plane, projector-code-version). Two rebuilds from the same log
   agree byte-for-byte or the projector is broken.
6. **Derived values are never re-ingested as facts.** Standing, flags,
   closures live only in projections and packets; nothing writes them back
   into the log. (Mirrors the contract's "derived estimates never sync as
   fact." The same rule, applied internally.)
7. **Supersession, merge, unmerge, deletion, suspension are events**, and
   their semantics are read-time interpretations. No event's stored bytes
   are ever modified by any later event.
8. **The event contract is versioned; stored events are immutable in
   schema.** New readers upcast old versions; old events are never
   rewritten. Additive change within a version; breaking change = new
   version + upcaster + contract-repo review.
9. **Deletion is completable and provable:** DEK destruction + payload
   hard-delete + `PayloadPurged` within the published window, on any
   substrate, including its backups.
10. **Signature and chain verification is re-runnable forever** from the
    log alone (key-validity events + checkpoints), with no dependency on a
    live external service.

## 10. Where this breaks

- **True planet scale with hot cross-stream operations.** Merge review at
  hundreds of millions of identities (the ~10% organic duplicate rate the
  research warns about) is a human-throughput problem this architecture
  does not solve. The log makes merges safe, not cheap. The steward queue,
  not the event store, is the scaling wall.
- **Projection rebuild time grows linearly with the log.** At 10^11+ events,
  full rebuilds stop being an afternoon. Mitigations (type-filtered scans,
  per-shard parallel rebuild, projection snapshots with replay-from-
  snapshot) are known but are real engineering the 3-person team must
  eventually fund. If we skip the monthly rebuild drill, we will discover
  a broken rebuild path during an incident.
- **The read log dominates the log.** `PacketIssued` is >80% of volume;
  if packet reads grow 10x faster than modeled (e.g., programmatic
  vertical polling), the "small system" arithmetic bends first there.
  Countermeasure is contractual (packet caching rules for verticals) plus
  the separate partition, but it is the number to watch.
- **Serializable ingestion transactions couple write throughput to
  projection reads.** At v2 shard scale the transactional-validation
  convenience narrows to per-shard; cross-shard invariants (merge) need the
  coordinator. This is accepted complexity, deferred honestly.
- **A single primary region is a real availability trade** in year one.
  The product tolerates minutes of write unavailability (attestations are
  not latency-critical); if the founder disagrees, that changes the v1
  hosting answer, not the model.

## 11. The failure modes of my own school, and how this design avoids them

1. **Projection-lag confusion** ("I granted access, why can't they read?").
   Avoided by dual-maintaining the small set of read-your-writes-critical
   projections (grants, registry, liveness) transactionally in the command
   path, and letting only analytics-grade projections (standing,
   reliability) lag. Lag is an SLO with an alarm, not a surprise.
2. **Event-version migration hell.** Avoided by a single contract repo,
   additive-only discipline, upcasters written the day the version bumps,
   and a CI job that replays the full corpus of historical event fixtures
   through current projectors on every merge.
3. **Small team drowning in infrastructure.** Avoided by the central call
   of this whole document: no broker, no separate event store, no
   microservices, one Postgres, one repo, pollers. The event-sourcing
   *discipline* is kept; the event-sourcing *industrial complex* is not.
4. **Event soup** (hundreds of anemic CRUD-shaped events like
   `PersonUpdated`). Avoided by the enumerated, decision-shaped event
   catalog in §2 and the review rule that computable fields don't ship in
   events. The catalog is small because the domain's real decisions are few.
5. **Kafka-as-database drift.** Teams start with "just a topic" and wake
   up with infinite-retention topics as their system of record and no
   transactional validation. Avoided by ruling it out in writing: the log
   feeds brokers; brokers never feed the log.
6. **GDPR-vs-immutability improvisation.** Event-sourced systems commonly
   bolt on crypto-shredding late and discover PII in event bodies. Avoided
   because the two-plane split is in the envelope itself (invariant 4).
   There is no compliant-by-cleanup phase, only compliant-by-construction.

## 12. What I'd veto from other schools

- **CRUD tables + audit log.** The audit log becomes a side effect and the
  guarantees become behavioral. See §1. This is the veto I hold hardest.
- **Kafka (or Redpanda/WarpStream) as the source of truth**, or any design
  where validation and persistence live in different systems joined by
  hope. Streaming infra is a downstream convenience here, never the spine.
- **Blockchain / DID anchoring.** The research already killed it; I concur
  from the ops side: the trust problem is registry vetting, and a 3-person
  team should not run consensus infrastructure to avoid running `pg_dump`.
- **Microservices at v1.** Service boundaries multiply the dual-write
  problem this design exists to eliminate. One deployable command service,
  N projector workers, one packet service, a modular monolith over one log.
- **Writing derived standing (or any derived flag) as stored fact.** The
  moment a "performance optimization" persists standing outside a
  rebuildable projection, the published-deterministic-rule promise is
  unenforceable.
- **Soft-delete/erasure via UPDATE on shared tables** as the R2 mechanism.
  Deletion must be the DEK-and-purge pipeline or it is theater.
- **A generic GraphQL/query surface over the ledger.** Read paths must go
  through the packet assembler and grant checks; ad-hoc query surfaces are
  how "no shadow profile" rules die.

## 13. Assumptions

1. Activity model: 30–40% of identities monthly-active, ~1 party
   attestation per active worker-month, ~5 packet reads per active
   worker-month, 20x peak-to-average. If reads run 10x hotter, §10 governs.
2. The team stays 3 people + heavy AI codegen for at least the first year;
   headcount growth would relax (not change) the "no new ops surfaces" rule.
3. Attestation ingestion tolerates hundreds of ms latency and minutes of
   downtime; packet reads tolerate seconds of staleness for standing but
   not for grants/deletion (hence the dual-maintained projections).
4. Counsel does not later mandate per-claim erasure (R2's whole-profile
   deletion holds). If it did, the payload plane already supports
   object-granular purge, and spine semantics would not change.
5. "Hundreds of millions in ~2 years" is identities *enrolled*, not
   concurrently active; the arithmetic uses that reading.
6. The steward/merge-review function is staffed as an ops function; this
   design assumes its existence and does not size it.
7. Postgres (managed, sharded when needed) remains operationally viable to
   ~10^11 spine events; beyond that, invariant list §9 is the RFP for the
   replacement substrate.
