# D1 Advocacy: Distributed SQL as System of Record from Day One

Advocate brief for the litigation docket item D1
(`design/stack-perspectives/convergence-map.md`). Position argued:
**Spanner (primary) / CockroachDB Cloud (alternative) as the single system
of record from the first row**, against the 5-school managed-Postgres bloc.
Clean context; inputs: the convergence map, `ledger-design-0.1.md`, all six
stack perspectives, and current-facts web research (August 2026). Team
facts honored: founder + 2 engineers, AI-build-heavy; ~1M identities in
months, ~10⁸ in ~2 years, planet scale as the stated design target;
effectively unlimited capital conditional on success.

---

## TLDR

1. **The bloc has already designed a distributed database; it proposes to
   build it out of Postgres parts and operate it by hand.** The
   data-platform architecture — global spine DB + per-region payload DBs +
   CDC-only copying + a cross-database deletion saga — is the strongest
   Postgres position on the table, and it is a federation of 5+ databases
   whose consistency, failover, and deletion guarantees are stitched
   together in application code. Every attack below is a place where that
   stitching is the system's weakest promise at exactly its highest legal
   or credibility stakes.
2. **Four concrete failure scenarios, argued with arithmetic:** (a) an
   unplanned regional failover of the spine with documented RPO of
   seconds loses ~800–4,000 *acknowledged* attestations at a stage-B
   period close, forking per-party chains and corrupting the
   compromise-vs-backdating rule's timestamp authority; (b) the day a
   residency regime reaches the spine itself — a live possibility the
   bloc's own author concedes — the "one global Postgres spine" has no
   move except hand-rolled regional projections plus a reconciliation
   protocol, i.e., building distributed SQL in-house under a compliance
   deadline; (c) the deletion saga's T0 spans databases with no shared
   transaction, and regional read replicas serving packet assembly can
   issue packets from stale grant state after deletion is accepted —
   violating the one invariant every school agreed is inviolable; (d) at
   5+ payload regions the bloc operates ~7 databases × upgrades × backups
   × CDC pipelines × lockstep migrations forever, and every region
   carve-out is a live dual-write PII migration under legal deadline.
3. **Honest self-costing:** at stage A, distributed SQL costs roughly
   $1–3k/month against a few hundred for modest Aurora — a 5–10×
   multiplier on a trivial base. The Spanner emulator is a genuinely
   degraded local-dev experience (in-memory, one concurrent read-write
   transaction, no IAM); AI-agent fluency in Spanner idioms is far below
   the Postgres corpus; CRDB fixes dev experience and wire compatibility
   but its triggers/stored-procedure support arrived only in 2024–25 and
   its extension ecosystem is thin. One of the bloc's best guardrails —
   trigger-enforced append-only as a second fence behind revoked grants —
   does not translate to Spanner. These costs are real and are paid by the
   team's scarcest resource.
4. **The "Google's problems without Google's headcount" jab is inverted.**
   Spanner-the-service exists so that you do not need Google's headcount;
   range rebalancing, quorum, TrueTime, and failover page Google, not the
   founder. The bloc's plan is the one that eventually requires
   distributed-systems headcount — in-house, at stage B, under fire.
   Distributed SQL converts that future engineering project into a present
   vendor invoice.
5. **Concessions and concede-triggers are stated in full** (§5, §6). The
   bloc is right about throughput, right about the two-plane schema
   (which ports to distributed SQL nearly unchanged), and right that
   Postgres survives 10⁸ *numerically*. Five measurable conditions under
   which I concede Postgres suffices through 10⁸ are enumerated — chief
   among them: counsel clearing the spine to replicate globally for the
   life of the roadmap, and the founder signing a written product
   position that seconds of acknowledged-attestation loss in a regional
   disaster is a priced, papered risk rather than a falsified promise.

---

## 1. Steelman: the bloc's strongest position

The Postgres bloc's best case is not the pragmatist's single cluster — it
is the data-platform architecture, and it deserves to be stated at full
strength:

- **A global spine database** holding only IDs, type codes, fixed-width
  hashes, signatures, timestamps, and pointers — no readable personal
  data, enforced by a CI schema linter so nothing readable *can* be
  written there. Small (~1.5 TB at 10⁸), append-only (UPDATE/DELETE
  revoked at the privilege level), replicated read-only to every region.
- **Per-residency-region payload databases** (US, EU, ROW day one),
  `residency_region` stamped on every row from row one, per-person
  envelope keys, regionally stamped out from one IaC module so partition
  N+1 is a deploy, not a project.
- **CDC as the sole sanctioned copy mechanism**, column-level PII/erasure
  tags driving the CDC allowlist, bucket routing, and masking policies
  mechanically; no copy exists off the copy map.
- **Deletion as an engineered saga** with per-copy SLOs (72h serving /
  30d analytical / 35d backups), an acknowledgment ledger, and
  crypto-shred as defense in depth — precisely the failures the EDPB's
  2026 erasure enforcement report found in the wild, prevented by design.

This is genuinely good architecture. It takes residency seriously from
row one, it makes erasure provable rather than aspirational, and it fits
three people because the always-on machinery is managed services and CI
gates. It also embeds the bloc's honest legal footnote: the spine is
pseudonymous personal data (EDPB Guidelines 02/2025 — hashes of personal
data remain personal data), replicated globally under SCCs, minimized so
that global replication stays defensible.

The steelman's core claim: the spine/payload physical split *already*
delivers residency without cross-region transactions, the spine is the
easiest shape in databases to replicate, and therefore distributed SQL
solves a topology problem the bloc has dissolved by schema design.

That claim is what the next section attacks. The split dissolves the
*payload* topology problem. It does not dissolve — it multiplies — the
consistency, failover, and jurisdictional problems of the spine and of
the seams between the planes.

---

## 2. The failure scenarios

### 2.1 Spine failover with RPO > 0: the fork in the chain

The bloc's spine is a single-writer Postgres with cross-region replicas.
Within one region, Aurora's shared-storage design makes Multi-AZ failover
effectively lossless — conceded. The exposure is the event the whole DR
section exists for: **loss of the writer region**, forcing promotion of a
cross-region replica. AWS's own documentation is plain: Aurora Global
Database unplanned failover has "RPO typically measured in seconds,"
bounded by replication lag at the moment of failure; only *planned*
switchover is RPO 0
([AWS Aurora docs](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-disaster-recovery.html),
[AWS DR blog](https://aws.amazon.com/blogs/database/cross-region-disaster-recovery-using-amazon-aurora-global-database-for-amazon-aurora-postgresql/)).
Regional failures do not schedule themselves as planned switchovers —
us-east-1 alone has produced major unplanned events in 2021, 2023, and
October 2025.

Now do the arithmetic against the planet-scale perspective's own
uncontested load model. Stage B period close: ~830 attestations/sec
sustained burst, ~2,800/sec from a single hot party. Replication lag is
*worst precisely under bulk write load* — the failure and the burst are
correlated, not independent. At 1 second of lag, an unplanned failover
loses **~830 acknowledged attestations**; at a realistic 5 seconds under
burst, **~4,000**. Each lost row is not "some data loss":

1. **The ack is a lie.** The party received a receipt and a ledger
   timestamp for an attestation that no longer exists. The planet-scale
   SLO every school implicitly endorsed — *zero acknowledged-then-lost
   attestations, ever* — is falsified in one event.
2. **Per-party chains fork.** The party's issuance chain head now hashes
   a vanished row. The next attestation the party submits references a
   `prev_hash` the database cannot produce. The convergence map calls
   chain structure "unretrofittable — a day-one decision"; a fork is a
   runtime violation of that same structure, and the repair (re-chaining
   from the last surviving head, re-ingesting lost tail entries) is
   exactly the "rewrite history" operation the product exists to make
   impossible. It can be done as audited repair events — but the ledger
   whose sales pitch is "nothing was ever altered" now carries a signed
   confession that history was reconstructed.
3. **The backdating rule loses its authority.** Design 0.1 §3.3: an
   attestation is valid iff its ledger timestamp predates any compromise
   report for the signing key. Re-submitted lost attestations get *new,
   later* timestamps. If a key-compromise report lands in the failover
   window — the chaotic window in which compromise reports are most
   likely — genuinely pre-compromise attestations now timestamp
   post-compromise and are flagged suspect. The alternative, manually
   backdating them, makes the ledger itself the backdater. The rule's
   entire value was that the timestamp authority is beyond dispute.
4. **The escrowed checkpoints indict the operator.** The bloc's hourly
   Merkle checkpoints in WORM S3 may cover the lost rows. Post-failover,
   the immutable escrow attests to a spine state the database no longer
   contains. The tamper alarm fires on the operator's own DR event, and
   the remediation choices are (a) publish a fork notice, or (b) quietly
   regenerate checkpoints — and (b) is byte-for-byte indistinguishable
   from the insider attack the checkpoint system exists to catch.

The class of incident is not hypothetical: GitLab's 2017 database
incident (Postgres replication lag plus operator action under pressure,
~6 hours of data lost) and GitHub's October 2018 cross-region failover
(lost writes, ~24 hours of reconciliation) are the canonical write-ups of
what asynchronous-replication failover does to systems that assumed it
away. Neither company sold integrity as its product.

Spanner and CRDB commit through synchronous multi-region quorum: RPO 0 is
a *property of the write path*, not a runbook outcome; Spanner's
multi-region configurations carry a 99.999% SLA. The failure mode above
does not exist to be handled.

### 2.2 The day the spine itself must leave the US

The bloc's answer to residency is that only payloads regionalize; the
spine replicates globally because it is unreadable. Its own author files
the caveat that decides this scenario: the spine is *pseudonymous
personal data* under EDPB 02/2025, its global replication rides on
SCCs/DPF-class transfer mechanisms, and the named worst case is
"regional spine *projections* with a global reconciliation protocol —
expensive" (data-platform §3.2).

Price the probability honestly rather than as FUD:

- **US transfer frameworks have been invalidated twice in a decade**
  (Safe Harbor 2015, Privacy Shield 2020). The DPF is the third attempt
  and is under standing litigation pressure. A Schrems-III outcome does
  not ban transfers outright, but it collapses the legal basis the
  bloc's global spine replication rests on, forcing the supplementary-
  measures argument to carry everything.
- **India's DPDP Rules (2025)** are permissive-by-default (blacklist
  model, Rule 15) — but Rule 12 lets the government require Significant
  Data Fiduciaries to keep government-specified categories of data
  in-country, with designation criteria at the government's discretion
  ([ITIF analysis](https://itif.org/publications/2025/06/09/india-cross-border-data-transfer-regulation/),
  [DPDP Rules overview](https://www.india-briefing.com/news/dpdp-rules-2025-india-data-protection-law-compliance-40769.html/)).
  A career-identity ledger over millions of Indian workers is a
  plausible SDF. Indonesia, Vietnam, and the Gulf states run harder
  localization postures still.

If any one regime on a 10⁸-identity roadmap demands that its residents'
spine rows be *primaried* in-territory, the two architectures diverge
totally:

- **Distributed SQL:** the spine is geo-partitioned by
  `residency_region` like the payloads — Spanner placement / CRDB
  `REGIONAL BY ROW` — while remaining *one database* with one schema,
  one transaction domain, and externally consistent commit timestamps
  spanning all partitions. The jurisdiction question is a placement
  policy value. Crucially, per-party chains still work: a party's
  issuance chain crosses subjects in many regions, and chain append
  remains a single-database transaction.
- **The Postgres bloc:** the spine must be split into regional Postgres
  instances. Per-party chains now span *databases*; appending to a chain
  whose previous entry lives in Frankfurt while the current subject lives
  in Mumbai is a cross-database serialization problem — two-phase commit
  you wrote yourself, on the integrity-critical path, which is the exact
  sentence the planet-scale perspective used for the payload plane and
  the bloc answered by splitting planes. There is no second plane to
  split. The bloc's own costing of this outcome is "expensive," and its
  own §1.2 says the minimization discipline exists "precisely to avoid
  ever needing this." An architecture whose viability depends on never
  needing its own named worst case, in a domain where the trigger is a
  foreign government's discretion, is not residency-shaped — it is
  residency-hopeful.

### 2.3 Cross-plane consistency: the deletion saga's seams

The bloc's T0 — grants revoked, reads stopped, person marked `deleting`,
"packet issuance impossible from this instant" — is described as
synchronous. It spans at least two databases (spine, regional payload)
and, for reads, N spine replicas. There is no transaction that covers it.
Two concrete holes:

1. **Stale-grant packet issuance.** Packet assembly in-region reads the
   spine's regional read-only replica (the bloc's stated topology).
   Postgres cross-region logical/physical replication lag under load runs
   seconds to minutes. Grant revocation commits on the US primary at T0;
   the Frankfurt replica serves a packet at T0+15s from pre-revocation
   grant state. The AI-native perspective proposes a TLA+ spec whose one
   theorem is "no packet is ever issued containing data from a person
   whose deletion has been accepted" — that theorem is checkable in a
   one-database model and is *false* in the bloc's deployed topology
   unless every grant check reads the global primary. Routing every
   grant check to the US primary destroys the read-locality story
   (every Manila packet read pays a trans-Pacific round trip) and
   re-couples global read availability to one region's writer. The
   bloc's own commandment — "standing never served from the stale
   analytics plane" — ignores that its operational replica mesh is also
   a stale plane. In Spanner, the grant check is a strong read (or a
   bounded-staleness read with a fence timestamp) against the same
   database that committed the revocation; the primitive exists and
   costs one line.
2. **Restore breaks the planes apart.** PITR-restore one payload region
   to T−15m after an operator error, and the spine — a different
   database with a different backup timeline — is still at T. Spine rows
   now reference payload rows that do not exist (or vice versa), and the
   deletion saga's acknowledgment ledger, which lives in a third place,
   agrees with neither. Reconciling three-plus independently restored
   databases into a consistent cross-plane state is a manual forensic
   project during an incident. One distributed database restores to one
   consistent timestamp across both planes by construction.

The same seam runs under merge/unmerge: a merge is a spine event whose
subjects' payloads may live in two different residency regions
(EU survivor, ROW absorbed). The bloc's merge is a multi-database
workflow with partial-failure states; in distributed SQL it is the one
two-partition transaction the workload contains, and the database's job.

### 2.4 Five-plus regions: the operational multiplication

The bloc opens with 5 databases (spine, registry, payload ×3). Apply the
§2.2 trigger table it wrote itself — PH carve-out, India, one more
partner-demanded region — and by stage B it operates **7 databases**,
each with HA topology, so ~20 database instances. What "managed" does
not remove, per database, forever:

- **Major version upgrades** roughly yearly (Postgres EOL cadence), with
  extension compatibility testing, replica re-provisioning, and writer
  restarts — ×7, coordinated so CDC connectors and the deletion saga
  tolerate mixed versions mid-rollout.
- **Schema migrations in lockstep ×7.** A migration applied to 5 of 7
  databases is per-region schema drift that the CDC tag registry, the
  copy-map walker, and the saga must all tolerate mid-flight. The bloc's
  "reject-don't-coerce" contracts now have N regional versions of the
  truth for hours per deploy.
- **CDC pipelines ×7**, each with its own lag alarms, connector
  restarts, and backfill procedures; the copy map's guarantees are only
  as good as the sickest connector.
- **Deletion saga fan-out** of 13 copy-map entries × N regions, each an
  independently failing acknowledgment.
- **The carve-out itself, repeated per jurisdiction:** data-platform's
  own playbook — "copy rows where `residency_region='PH'`, flip routing,
  delete from ROW" — is a live dual-write migration of PII under a legal
  deadline, executed each time a regulator asks, each execution a chance
  to violate the copy map it exists to serve.

None of this is exotic, and all of it is O(N regions) of standing
operational load on three people, compounding with every jurisdiction.
The distributed-SQL equivalent of a new residency region is
`ALTER DATABASE ... ADD REGION` plus a placement policy: one schema, one
migration stream, one backup story, one CDC changefeed, O(1) operations
as N grows. The bloc's claim that "partition N+1 is a deploy, not a
project" is true on day 1 of the partition and false on every day after.

---

## 3. Honest self-costing: what distributed SQL takes from this team

The obligations of this section are discharged without hedging.

**Money.** Spanner regional compute runs ~$0.90/node-hr (~$657/node-mo),
with 100-processing-unit granularity putting a minimal regional footprint
near $65–200/mo; multi-region configurations run ~3× per node-hour
(~$3/node-hr), so an honest minimal multi-region stage-A footprint with
storage, backups, and inter-region replication lands around
**$1–3k/month** ([pricing breakdown](https://www.gammateksolutions.com/post/google-cloud-spanner-cost-breakdown-2026-storage-compute-instance-pricing-explained),
[Finout GCP pricing](https://www.finout.io/blog/google-cloud-pricing)).
CRDB Cloud Standard starts around $0.18/vCPU-hr provisioned, with a
usable free Basic tier below that
([CRDB cost docs](https://www.cockroachlabs.com/docs/cockroachcloud/costs),
[pricing analysis](https://airbyte.com/data-engineering-resources/cockroachdb-pricing)).
Against a modest Aurora cluster at a few hundred dollars a month, the
premium is **5–10× on a trivial base** — irrelevant under the stated
capital posture, but it is real money spent on load that rounds to zero.

**Local development and CI.** This is Spanner's worst surface. The
emulator is in-memory only (all state lost on restart), permits **one
concurrent read-write transaction** (any concurrent transaction aborts),
ignores gRPC deadlines, and supports no IAM
([emulator repo](https://github.com/GoogleCloudPlatform/cloud-spanner-emulator)).
PGAdapter gives partial Postgres wire compatibility with real dialect
gaps ([PGAdapter](https://github.com/GoogleCloudPlatform/pgadapter),
[PG interface docs](https://docs.cloud.google.com/spanner/docs/postgresql-interface)).
The AI-native perspective's whole leverage model runs on fast, faithful
local loops — `docker run postgres` and ephemeral per-PR databases. The
emulator is a degraded facsimile of production; concurrency behavior, the
thing this system most needs to test, is exactly what it cannot exercise.
CRDB largely cures this (single binary, `cockroach demo`, faithful local
clusters) and is the honest reason the alternative exists in my
recommendation.

**AI-agent fluency.** The Postgres corpus dwarfs everything. Agents will
emit Postgres idioms; on Spanner these break on interleaved-table design,
mutation-per-commit limits, sequence idioms, and the GoogleSQL/PG-dialect
split. On CRDB most idioms run — but triggers, stored procedures, and
UDFs arrived only in 2024–25 and remain less battle-tested, and the
extension ecosystem is thin
([CRDB compatibility, v26.x](https://www.cockroachlabs.com/docs/stable/postgresql-compatibility),
[Bytebase comparison](https://www.bytebase.com/blog/cockroachdb-vs-postgres/)).
Materially: the bloc's belt-and-suspenders guardrail — revoked
UPDATE/DELETE grants *plus* an unconditional BEFORE-UPDATE trigger fence
on spine tables — only half-translates. The privilege fence exists on
both Spanner (fine-grained access control) and CRDB; the trigger fence is
unavailable on Spanner and young on CRDB. In an agent-written codebase,
losing a structural fence is a real cost and I book it as one.

**Vendor exposure.** Spanner is single-vendor gravity in its strongest
form: the dialect, placement model, and TrueTime semantics do not port
out cheaply; the exit is a real migration. CRDB carries business-model
risk — the 2024 licensing retreat from free self-hosted Core is a signal
about company economics that a system-of-record bet must price. The bloc's
Postgres has neither exposure.

**Ops burden, stated fairly in both directions.** Spanner removes vacuum,
connection-pool pathology, version upgrades (it is versionless), failover
drills, and replica topology management — at stage A its marginal ops
load genuinely approaches zero, which is the strongest honest claim on my
side. What it adds: a new performance mental model (hot ranges, split
points, interleaving) that the team must learn and the AI corpus teaches
poorly, and debugging tools less familiar than `pg_stat_statements`.
CRDB sits between: Postgres-shaped tools, but a real tuning surface
(range splits, contention) the vendor does not absorb.

---

## 4. "Buying Google's problems without Google's headcount"

The jab deserves a direct answer, because it is the bloc's most quotable
line and its least examined.

Google's problems — TrueTime fleet management, Paxos quorums, range
rebalancing, split management, versionless rolling upgrades, five-nines
multi-region failover — are precisely the layer that Spanner-as-a-service
sells *the absorption of*. The 3 a.m. page for a range-rebalance stall
goes to Google SRE. That is not buying Google's problems; it is renting
Google's headcount for the one layer where three people plus AI agents
have no business operating anything.

Now run the jab against the bloc's own trajectory. By stage B its plan
is: N regional Postgres databases, a hand-rolled cross-database deletion
saga, cross-database chain-consistency logic if residency ever touches
the spine, a CDC mesh, lockstep migrations, and region carve-out
migrations under legal deadlines. Every one of those is
distributed-systems engineering — the discipline the AI-native
perspective's own evidence says agents are *worst* at ("agents
interleave-blind") and that the team has no capacity to review. The bloc
does not avoid distributed-systems headcount; it defers the requirement
to the moment it must be met in-house, under fire, on the two most
dangerous tables in the system. The distributed-SQL position converts
that future headcount into a present invoice with an SLA attached. The
jab lands on the side that fired it.

What the jab gets right is narrower and conceded below: at stage A, the
Spanner *development-loop* problems (emulator, dialect, corpus) are
genuinely mine and genuinely daily, while the Postgres *topology*
problems I forecast are contingent and future. That asymmetry of
certainty is the strongest form of the bloc's case.

---

## 5. Concessions

1. **Throughput is a non-problem, permanently.** The convergence map's
   settled item 1 is correct; the planet-scale perspective opened by
   refusing the QPS argument and I hold that line. Nothing in this brief
   argues capacity.
2. **The schema is the bloc's victory regardless of D1's outcome.** The
   two-plane split, `residency_region` on every payload row, opaque
   never-reissued IDs, column-level PII/erasure tags, CDC-only copying,
   and the copy-map discipline are correct and port to Spanner/CRDB
   nearly unchanged. The fight is substrate, not schema — and the bloc
   designed the schema.
3. **Single-region RPO is effectively zero on Aurora.** Kill-shot 2.1
   fires only on writer-region loss or cross-region topology. Regional
   failures are rare events; my argument prices a low-probability,
   maximum-severity event, and honest actuaries can disagree on it.
4. **The dev-experience and agent-fluency costs are real and land on the
   scarcest resource.** If agent defect rates or iteration speed degrade
   measurably on the distributed dialect, the AI-native axis — which I
   accept as the correct primary axis for this team — cuts against me.
   CRDB mitigates but does not eliminate this, and adds vendor risk.
5. **The trigger fence is lost on Spanner.** One of the two structural
   append-only guarantees survives (privilege revocation); the second
   does not. In an agent-written codebase that is a genuine reduction in
   defense depth.
6. **Postgres survives 10⁸ numerically, and its migration is the
   friendliest possible.** Person-scoped queries, no cross-person
   transactions except rare human-gated merges, append-only shape: if
   the topology contingencies never fire, the bloc's staged path
   (partitioning → Citus-class sharding) is well-trodden and its "migrate
   a simple thing later" logic is sound.
7. **The bloc's deletion saga is better engineering than most of the
   industry ships.** My attack in §2.3 is that its guarantees are weaker
   than advertised at the seams — not that the subsystem is wrong. Most
   of it (copy map, tags, SLOs, acknowledgment ledger) is required under
   my substrate too.

---

## 6. Concede-triggers: measurable conditions under which Postgres suffices through 10⁸

I concede D1 to the bloc if all of the following hold; each is checkable,
not vibes:

1. **Residency clearance for the spine.** Written counsel opinion, within
   12 months, that (a) no jurisdiction on the 24-month market roadmap
   requires in-territory primary storage of spine-class pseudonymous
   data, and (b) global spine replication under SCCs + the unreadability
   supplementary measure survives the current DPF litigation posture. If
   the spine is legally free to live in one country for the life of the
   roadmap, §2.2 — my strongest attack — is moot.
2. **A signed acknowledged-loss policy.** The founder adopts, in the
   party-facing contract and the internal SLO doc, an explicit position:
   unplanned regional failover may lose up to N seconds of acknowledged
   attestations; chain repair is a defined, audited, party-notified
   procedure; the checkpoint-fork disclosure protocol is written. If the
   business is willing to *paper* RPO > 0 rather than promise RPO = 0,
   §2.1 becomes a priced risk instead of a falsified promise — and
   Postgres is adequate for a system that promises less.
3. **Measured global read latency.** At ≥10M identities, packet-read p99
   from three demand geographies (SE Asia, LATAM, Africa/EU-adjacent)
   against the US-primary + regional-replica topology meets the 400ms
   global SLO *with grant checks reading fresh* (primary or
   proven-bounded staleness ≤ the published revocation SLA). If the
   replica mesh delivers both freshness and latency in measurement, the
   read-locality argument dies.
4. **Region count stays ≤ 3.** No regulator, partner, or counsel
   direction forces a payload region beyond US/EU/ROW before 10⁸. The §2.4
   multiplication argument scales with N; at N=3 it is an annoyance, not
   an architecture.
5. **Deletion-seam verification survives adversarial testing.** Quarterly
   game days demonstrate, under induced replica lag and mid-saga
   failures, zero post-T0 packet issuance and clean cross-plane recovery
   from a single-database PITR restore — with the evidence artifacts the
   AI-native school would demand. If the seams hold under attack, my
   §2.3 is answered operationally rather than architecturally.

Symmetrically, I abandon distributed SQL if: emulator/tooling friction
measurably degrades agent throughput (CI wall-clock, defect-escape rate)
past an agreed threshold; Spanner's PG dialect forces a GoogleSQL rewrite
of core paths; or CRDB (if chosen) shows further licensing/business
distress. And the minimum-viable form of my own position should be on
the record: **start Spanner regional (cheap, ~$100–650/mo) with the
schema and idioms written distributed-first, and flip to a multi-region
configuration at the first external party** — the topology option is what
must exist from row one; the five-nines bill can wait a quarter.

---

## Sources

- [AWS: Aurora Global Database switchover and failover (RPO documentation)](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-disaster-recovery.html)
- [AWS Database Blog: Cross-Region DR with Aurora Global Database](https://aws.amazon.com/blogs/database/cross-region-disaster-recovery-using-amazon-aurora-global-database-for-amazon-aurora-postgresql/)
- [AWS: Global Database switchover under 30 seconds (2025)](https://aws.amazon.com/about-aws/whats-new/2025/05/amazon-aurora-cross-region-global-database-switchover-time-under-30-seconds)
- [Google Cloud Spanner cost breakdown 2026](https://www.gammateksolutions.com/post/google-cloud-spanner-cost-breakdown-2026-storage-compute-instance-pricing-explained)
- [Finout: Google Cloud pricing models 2026](https://www.finout.io/blog/google-cloud-pricing)
- [Cloud Spanner emulator (limitations)](https://github.com/GoogleCloudPlatform/cloud-spanner-emulator)
- [PGAdapter — PostgreSQL wire proxy for Spanner](https://github.com/GoogleCloudPlatform/pgadapter)
- [Spanner PostgreSQL interface documentation](https://docs.cloud.google.com/spanner/docs/postgresql-interface)
- [CockroachDB Cloud cost documentation](https://www.cockroachlabs.com/docs/cockroachcloud/costs)
- [Airbyte: CockroachDB pricing explained (2026)](https://airbyte.com/data-engineering-resources/cockroachdb-pricing)
- [CockroachDB PostgreSQL compatibility (stable, v26.x)](https://www.cockroachlabs.com/docs/stable/postgresql-compatibility)
- [Bytebase: CockroachDB vs. Postgres (2025)](https://www.bytebase.com/blog/cockroachdb-vs-postgres/)
- [ITIF: India's cross-border data transfer regulation (2025)](https://itif.org/publications/2025/06/09/india-cross-border-data-transfer-regulation/)
- [India Briefing: DPDP Rules 2025 notified](https://www.india-briefing.com/news/dpdp-rules-2025-india-data-protection-law-compliance-40769.html/)
- [DPDPA.com: Rule 15 — transfers outside India](https://www.dpdpa.com/dpdparules/rule15.html)
