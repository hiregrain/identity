# Stack Litigation — Convergence Map (2026-08-17)

Six independent clean-context perspectives, formed in parallel with no
visibility into each other: `boring-pragmatist`, `planet-scale`,
`log-centric`, `security-infra`, `data-platform`, `ai-native`. This map
records where they converged unprompted and where genuine disagreement
survives. Convergence across independently-formed adversarial personas is
strong signal; the divergences are the litigation docket.

## Unanimous or near-unanimous convergence (treat as settled)

1. **Throughput is a non-problem; topology is the problem.** All six did the
   arithmetic independently and landed within one order of magnitude:
   attestation writes are ~30–250/sec sustained even at 10⁸–10⁹ identities,
   because the interface contract only lets aggregates cross. Even the
   planet-scale advocate opened by refusing to make the QPS argument. Every
   real risk named is about *shape*: residency, ordering, chain structure,
   deletion propagation, hot parties at period close.
2. **Modular monolith; no microservices; no Kubernetes; one repo.** 6/6.
   The AI-native framing (Conway inverts — there are no human team
   boundaries to mirror) supplies the why.
3. **No Kafka/broker as source of truth.** 6/6 veto, three independent
   arguments (dual-write hazard; at-least-once vs. exactly-once where law
   cares; R2 deletion through immutable topics is a research project).
4. **No blockchain, no DID resolution.** 6/6 (research `04` re-derived).
5. **Append-only enforced in the database itself** — UPDATE/DELETE revoked
   at the role/privilege level so the guarantee is structural, not
   behavioral. 5/6 explicit; the sixth is compatible. Doubles as the
   guardrail AI-written application code cannot violate.
6. **No single global hash chain.** 4/4 of those who addressed chain
   structure: per-stream (per-subject, per-party) chains + periodic signed
   Merkle checkpoints. Planet-scale flags chain structure as
   **unretrofittable** — a day-one decision. The pragmatist's serialized
   single chain was the one dissent and its own stated ceiling; it conceded
   per-shard chains as the migration.
7. **Physical spine/payload separation, residency-shaped from row one.**
   Global no-PII(-readable) spine; regional payload stores; `residency_region`
   stamped on every payload row. 4/6 explicit, 0 opposed. Data-platform adds
   the honest legal footnote: the spine is still pseudonymous personal data —
   minimize and replicate under SCCs; enforce the boundary with CI lint.
8. **Deletion = hard delete + crypto-shred, engineered as a subsystem.**
   Per-person envelope keys (DEK destruction covers backups/replicas) plus a
   copy-map with per-copy SLOs and an acknowledgment saga; crypto-shred is
   defense-in-depth, not the sole mechanism. Log-centric adds: deletion
   itself emits a provable `PayloadPurged` event.
9. **Prior packets generated at read time, never cached at the edge.**
   CDN-cached packets silently break revocation and deletion — the two
   highest-legal-weight promises. Standing never served from the stale
   analytics plane.
10. **A small isolated trust kernel with the strictest review.** Security:
    frozen <3k-line kernel, two-human review, golden vectors, fuzzing.
    AI-native: pure semantic kernel, differential-tested, human-gated paths.
    Log-centric: isolated crypto core. Same shape, three vocabularies.
11. **The scaling wall is the constitutionally-human queues.** Merge
    stewardship (~10% organic duplicate rates), disputes, party vetting —
    named independently by three perspectives as the thing that actually
    breaks at 10⁸. Build them as a product line with their own tooling and
    throughput design, not an ops afterthought.
12. **Signing keys in cloud KMS, zero extractable key material.** The
    Ed25519-in-KMS objection expired (AWS Nov 2025, GCP native). Offline
    root + online issuing keys, CA-style.

## The litigation docket — genuine disagreements

### D1. System of record: managed Postgres vs. distributed SQL from day one
**5 (Postgres-family) vs. 1 (Spanner primary / CockroachDB alternative).**
The planet-scale case is not QPS — it is: (a) residency partitioning
retrofitted onto regional Postgres becomes hand-rolled cross-region
coordination on the erasure-critical path; (b) an integrity spine cannot
tolerate RPO>0 replication without breaking per-party chains during
failover; (c) stage-C read locality (~1M row-reads/sec peak, sub-400ms
global p99) wants native follower reads; (d) TrueTime-class commit
timestamps give the compromise-vs-backdating rule a trustworthy ordering
authority for free. The Postgres bloc's implicit answer: the physical
spine/payload split + per-region payload databases already deliver
residency without cross-region transactions; the spine is tiny and
append-only (the easiest shape to shard/replicate); Spanner day one buys
Google's problems without Google's headcount. **Unresolved sub-questions:**
does the spine need multi-region RPO-zero synchronous replication at 1M?
at 10⁸? What is the honest cost of Postgres→distributed-SQL migration for a
person-partitioned append-only spine if (a)–(c) materialize?

### D2. Language: TypeScript vs. Go
**4-ish vs. 1.** TS case: highest agent fluency; discriminated unions make
ledger state machines illegal-state-unrepresentable; one language across
worker surface + API + kernel. Go case: deployment simplicity,
concurrency, proto-native contracts. Rust: rejected by AI-native on
human-audit capacity. The fight is narrow but foundational — it decides the
hiring/agent-tooling axis for years.

### D3. Transparency log: day one vs. checkpoints-to-WORM vs. deferred
Security-infra's sharpest attack, aimed at design 0.1 itself: a hash chain
alone defends against nobody who matters (operator, insider, poisoned
pipeline can rewrite it), and a Merkle log started after an incident can
never prove early history. Rekor v2/Tessera GA (Oct 2025) makes a
tile-based, object-storage-backed CT-style log cheap — so it ships day one,
public witnessed checkpoints by first external party or 1M identities.
Pragmatist: hourly Merkle checkpoints to WORM S3 deliver the anchoring for
dollars. Design 0.1 had said "v2 hardening." **Question for the founder:**
when does the integrity story need to be provable to outsiders — day one,
first external party, or later — and is the tile-log's operational cost
actually as low as claimed?

### D4. Party signing-key custody: ledger-hosted KMS vs. party-held keys
Security-infra's most contrarian claim: the most probable forgery event in
years 1–3 is a *partner's* key file leaking, so party keys should be
ledger-hosted in KMS by default — every signature becomes an auditable,
rate-limitable API event feeding party-fraud detection for free. The
counter (implicit in design 0.1 and the other perspectives): hosted signing
weakens non-repudiation — "the party signed it" becomes "the ledger signed
it on the party's behalf," which changes what an attestation proves and
concentrates insider risk in the operator. **Middle positions exist**
(hosted-by-default with bring-your-own-key for parties that insist; or
party-held with mandatory KMS attestation) and were not litigated.

### D5. Formal methods: two TLA+ specs vs. none
AI-native: merge/unmerge under concurrent ingestion, and deletion vs. the
read path — exactly two specs, justified because agents do the mechanical
conformance work and humans review 300 lines. No other perspective
proposed formal specs; the pragmatist school would call it gold-plating.
Cheap to decide late; listed for completeness.

### D6. Folded into D1/D3: ordering authority
TrueTime commit timestamps (planet-scale) vs. the ledger's own hash-chain/
Merkle timestamps (everyone else) as the authority behind the
key-compromise-vs-backdating rule. Resolves automatically with D1 and D3.

### Small technical flags worth carrying (no fight)
- Naked UUIDv7 is a hot-range generator on range-partitioned stores
  (planet-scale); trivially avoided with prefixing/bucketing — decide at
  schema time regardless of D1's outcome.
- Hot-party writes at period close (~2,800/sec from one party at stage B):
  partition by subject, never issuer; durable idempotent ingest queue.
- Account recovery, not login, is the worker-auth attack surface: recovery
  must re-clear the account's derived assurance level; time-locks block
  takeover-then-delete destruction of a victim's record (security-infra —
  no one contested; adopt).
- Signing canonicalization test vectors in the versioned contract
  (planet-scale + security convergence).

## Suggested litigation order

D1 (system of record) and D3 (transparency log) are the two decisions the
others hang off; D4 (key custody) changes the partner integration contract
so it should be decided before any external-party agreement is drafted; D2
(language) gates the first line of code; D5 rides on D2's outcome.
