# D1 Verdict: System of Record

Ruling on convergence-map docket item D1 (managed Postgres vs. distributed
SQL from day one), issued after review of both advocate briefs
(`d1-postgres.md`, `d1-distributed-sql.md`), the spec
(`ledger-design-0.1.md`), the four background perspectives, the D3 briefs'
findings on ordering authority, and independent verification of the two
technical claims on which the briefs genuinely conflicted. Clean context.

---

## Ruling

**Managed Postgres is the system of record, conditioned on four
launch-blocking obligations (§4) and governed by the adopted switch
triggers (§5).** The full planet-scale shape doctrine is adopted with it,
exactly as the Postgres brief proposes: physical spine/payload split,
`residency_region` in every payload primary key, per-subject/per-party
chains, hash-prefixed or random IDs, durable idempotent ingest queue,
privilege-level append-only, spine schema kept inside the
distributed-SQL-compatible subset, cross-cloud checkpoint escrow.

The distributed-SQL brief's minimum-viable fallback — regional Spanner from
day one with distributed-first idioms — is **rejected** (§3.6). Its own
strongest concession decides against it: the daily, certain costs it
carries land on the team's scarcest resource, while the contingent benefits
it insures wait on triggers that are observable in advance.

This is not "never distributed SQL." Both briefs converge on the honest
long-run position — at true stage C, managed distributed SQL is likely the
right system of record. The ruling is that the crossing is made when a
named trigger fires, on a migration deliberately kept friendly, not now on
speculation.

---

## 1. What decided it

Three findings are dispositive; everything else is priced but not decisive.

**First: the RPO kill-shot dissolves once the ack and the escrow are
gated, and D3's outcome supplies most of the gating for free.** The
distributed-SQL brief's §2.1 arithmetic (~830–4,000 acknowledged
attestations lost in a burst-correlated regional failover) is correct —
against *unmitigated* Aurora Global, which the Postgres brief itself
concedes is disqualifying. Against the watermarked design it fails, for a
structural reason: the property the spine must never violate is not "no
committed transaction is lost" but "nothing the ledger acknowledged, and
nothing an external party can hold as proof, is lost." The two-watermark
design covers exactly those two boundaries (§3.1). Independently verified:
Aurora PostgreSQL Global Database ships a **managed RPO primitive**
(`rds.global_db_rpo`) that blocks commits on the primary when all
secondaries exceed the target — a database property, not application code
([AWS](https://aws.amazon.com/about-aws/whats-new/2020/06/amazon-aurora-postgresql-global-database-supports-managed-recovery-point-objective-RPO),
[docs](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-disaster-recovery.html)).
Neither brief cited it. It materially weakens the "hand-made distributed
database" charge: the hand-built portion of the watermark is now a
tightening of a managed backstop, not a from-scratch consensus layer.

**Second: the certain-vs-contingent cost asymmetry, which the
distributed-SQL brief itself concedes in its §4 closing.** Spanner's costs
— degraded emulator loop (in-memory, one concurrent read-write
transaction), thin agent corpus, lost trigger fence, GoogleSQL/PG-dialect
friction, vendor gravity — are paid daily, with certainty, by a
three-person AI-build-heavy team whose primary axis all six perspectives
agreed is agent leverage. Postgres's topology costs are contingent, and
every one of them has an observable leading indicator (§5). When one side's
costs are certain and daily and the other's are contingent and forecastable,
and the migration between them is unusually friendly (below), the decision
rule is not close.

**Third: the migration is genuinely the friendliest shape in databases,
and the case record supports paying it later rather than insuring now.**
Append-only (no update-conflict resolution in dual-write), person-
partitioned (streams migrate independently), self-verifying (per-stream
chain hashes prove byte-fidelity at both ends), small (~1.5 TB spine at
stage B). Costed honestly at 2–4 engineer-quarters — executed by the
stage-B team, because every trigger that fires it implies stage-B revenue
and headcount. The survivorship objection to the case record is addressed
in §3.4; the evidence survives the discount.

**What was noise:** the TrueTime argument (already resolved by D3 — both
D3 briefs independently concluded the externally-anchored checkpoint
sequence, not any database commit timestamp, is the ordering authority
with evidentiary force; a Spanner timestamp is the operator's own database
asserting the operator's own ordering); the stage-C read-locality argument
(internally contradicted by the residency argument for payloads, and
applicable only to the small replicable spine); the QPS question (settled
6/6, neither brief argued it); and both briefs' rhetorical set pieces about
whose headcount is being bought.

---

## 2. Verified facts

Where the briefs conflicted or a claim was load-bearing, checked
independently:

1. **Aurora Global unplanned failover RPO is seconds, planned switchover
   is RPO 0** — both briefs agree; confirmed against AWS documentation.
2. **`rds.global_db_rpo` exists and blocks primary commits when
   replication lag exceeds target.** Caveats carried honestly: minimum
   value 20 seconds; it throttles the whole primary rather than gating
   per-transaction; it blocks major version upgrades while enabled. It is
   a backstop bounding worst-case loss, not a substitute for the ack
   watermark — the design in §4 uses both.
3. **Spanner strong reads from non-leader regions pay a round trip to the
   leader region (~100ms+ cross-region)** unless the application accepts
   stale reads or configures read leases
   ([Spanner docs](https://docs.cloud.google.com/spanner/docs/reads),
   [read leases](https://docs.cloud.google.com/spanner/docs/read-lease)).
   This is decisive for the deletion-consistency adjudication (§3.2): the
   latency cost of a fresh grant check is physics, not engine choice.
4. **Motion, ZITADEL, Figma, Notion write-ups are accurately
   characterized** by the Postgres brief; ZITADEL — the closest domain
   comparable, an identity platform — cited residency *governance* as a
   reason to leave CockroachDB, directly counter-evidencing the residency
   argument for distributed SQL.

---

## 3. Adjudication of the contested points

### 3.1 RPO and the acknowledged-loss scenario (adjudicated for Postgres, conditionally)

The failure walk in the Postgres brief §3 is technically sound. States 1–2
(queued; committed-unacked) lose nothing by construction of the settled
ingest queue. State 4 (escrowed) is made impossible by gating checkpoint
escrow on the replication watermark — one invariant, application-level,
small, and **composable with D3**: since D3's surviving positions both
require externally anchored checkpoints within minutes of every write, the
escrow-gating rule means *externally provable history has RPO 0 regardless
of the database's RPO*. That is the sentence that neutralizes the
distributed-SQL brief's most damaging sub-point (the escrowed checkpoints
indicting the operator after failover): a checkpoint gated on the
watermark can never attest to a row a failover un-commits.

State 3 (acked within the lag window) is the honest residue. Two closures,
both adopted (§4): gate acks on cross-failure-domain durability, and define
receipts as provisional until checkpoint inclusion — the latter being
exactly the consumption model D3 prescribes for its own reasons, so the
two-phase receipt machinery is already mandatory. The per-party chain-fork
scenario cannot occur for any attestation whose receipt was final, and a
provisional receipt that fails inclusion is a defined retry, not a fork.

The condition: this is trust-kernel-grade code that can regress where
Spanner's equivalent cannot. Hence trigger §5.2 fires on a *single*
game-day demonstration of acked loss or checkpoint/WAL divergence. One
occurrence, no averaging.

### 3.2 The deletion-consistency attack (real, and relocated — not solved — by distributed SQL)

The attack is real against the bloc's stated topology: a grant revocation
or deletion T0 commits on the global spine primary while a regional spine
replica serves packet assembly from pre-revocation state. The AI-native
theorem ("no packet issued after deletion acceptance") is false if grant
checks read stale replicas.

But the verified Spanner facts show distributed SQL does not remove this
cost — a strong read from Manila against a US-leader spine pays the same
cross-region round trip, and the moment the application opts into
bounded-staleness or read leases to avoid it, it is doing precisely the
per-query freshness reasoning the distributed-SQL brief claims Postgres
uniquely requires. What Spanner genuinely offers is better ergonomics: an
exact-staleness bound as a database guarantee rather than a measured
replica-lag bound. That is worth something; it is not worth the engine.

Ruling on the mechanism (binding, engine-independent): **liveness and
grant checks read the primary or a standby with a proven staleness bound
no larger than the published revocation SLA; content assembly reads
replicas.** The revocation/deletion SLA is published with an explicit
global bound (seconds), which is what "immediate" honestly means in any
multi-region system under either engine. The distributed-SQL brief's
concede-trigger 5 (quarterly adversarial game days inducing replica lag
and mid-saga failures, proving zero post-T0 issuance) is adopted as a
standing obligation, not a concession condition.

The PITR cross-plane restore point (dist-SQL §2.3.2) is conceded as a real
distributed-SQL advantage — one database restores to one timestamp — and
carried as residual risk (§6), mitigated by the chain structure itself:
per-stream hashes make cross-plane divergence after a partial restore
detectable and enumerable, which is what turns a forensic mystery into a
bounded repair queue.

### 3.3 The residency-forcing scenario (the strongest surviving distributed-SQL argument; priced, not dispositive)

If a jurisdiction ever requires spine rows *primaried* in-territory, the
architectures diverge exactly as the distributed-SQL brief says: Spanner
geo-partitions the spine by row while keeping one transaction domain (a
party chain crossing regions remains a single-database append); regional
Postgres spines make chain appends a cross-database serialization problem.
This is genuine and the Postgres brief concedes it.

Probability and cost, priced honestly: the trigger is a foreign
government's discretionary designation applied to *pseudonymous,
unreadable, deliberately minimized* data — the hardest data class to
justify localizing, and the class the spine-minimization discipline exists
to keep defensible. Schrems-III would pressure the transfer basis, not
mandate in-territory primaries. India's DPDP Rule 12 is a real mechanism
with discretionary reach; it is also observable years before it binds
(designation, rulemaking, compliance windows). Meanwhile the countervailing
evidence is concrete: the closest comparable operator found regional
Postgres the *stronger* residency-governance story, because a database
whose job is moving data across regions must be configured into compliance.

Ruling: carried as trigger §5.1, sharpened — the trigger is counsel's
written assessment that in-territory spine primary storage is *probable on
the 24-month roadmap*, not the mandate's arrival. Firing on probability
rather than mandate buys the migration window the distributed-SQL brief
correctly says a deadline denies.

### 3.4 The migration-evidence asymmetry (survives the survivorship discount)

The bias is real: migrations off CockroachDB produce blog posts; satisfied
customers produce silence, and large happy CRDB/Spanner deployments exist.
The discount is applied — and the evidence still stands, for two reasons.
Figma and Notion are not survivorship cases: they are the *forward
decision made at the decision point* — hundreds of millions of users, the
exact stage where this ruling would be tested — and both chose sharded
Postgres with full knowledge of the alternatives. And ZITADEL is a
domain-matched data point whose stated reasons (cost, latency, residency
governance) map onto this docket's actual axes. Against this, the
distributed-SQL brief offers no documented case of a company at this
team's size adopting Spanner/CRDB pre-need and crediting the choice — the
absence proves little, but the burden was its to carry.

### 3.5 Ops, cost, and agent fluency (conceded by the distributed-SQL brief; weighed heavily)

The distributed-SQL brief's own §3 is the most persuasive text against its
position: the emulator's one-concurrent-transaction limit lands on exactly
the behavior this system most needs to test; the trigger fence — one of two
structural append-only guarantees in an agent-written codebase — does not
exist on Spanner; the Postgres corpus advantage compounds daily. These are
not tie-breakers; combined with §1's asymmetry-of-certainty they are half
the ruling. The counter (the bloc's stage-B trajectory is itself
distributed-systems engineering) is acknowledged and answered by the
triggers: the moment that trajectory's leading indicators appear, the
crossing is made with stage-B resources.

### 3.6 The regional-Spanner fallback (rejected)

Evaluated on its merits as a third option. What it buys: placement-policy
optionality without migration, and a low invoice (~$100–650/month). What
it fails to buy: a *regional* Spanner has no RPO advantage over Multi-AZ
Aurora (both are synchronous within one region — the five-nines
multi-region property arrives only with the multi-region flip and its
bill); and it does not defuse the objections that actually carry weight,
because those are not the invoice — they are the emulator loop, the
dialect, the corpus, the lost trigger fence, paid from day one on the
scarcest resource. Meanwhile the optionality it preserves is already
preserved more cheaply in the schema: the shape doctrine plus the
compatible-SQL-subset discipline *is* the topology option, held open at
zero daily cost. The fallback is the right idea (keep the option, defer
the bill) implemented at the wrong layer (engine instead of schema).

---

## 4. Launch-blocking obligations attached to this ruling

The bloc position is defensible only as conditioned. These ship before the
first external-facing attestation, or the ruling does not hold:

1. **Ack watermark.** No attestation is acknowledged before its commit is
   durable on a second failure domain: quorum in-region (Aurora storage
   layer) for AZ loss, plus cross-region durability for region loss —
   implemented as cross-region queue durability before ack or an
   Aurora Global replication watermark, with `rds.global_db_rpo` enabled
   as the managed backstop bounding worst-case loss.
2. **Escrow watermark.** No signed checkpoint leaves the operator's
   control before the WAL it covers is confirmed multi-domain durable.
   This line, plus D3's day-one anchoring, is what makes externally
   provable history RPO-zero by construction.
3. **Two-phase receipts.** Party receipts are provisional until
   checkpoint-inclusion proof, delivered at next checkpoint — machinery
   shared with D3, built once.
4. **Freshness discipline as code.** Grant/deletion/liveness checks read
   the primary or a bounded-staleness standby with bound ≤ the published
   revocation SLA; enforced by the read-path module boundary, verified by
   quarterly adversarial game days (induced replica lag, mid-saga
   failure, single-plane PITR restore) with evidence artifacts.

All four are trust-kernel-grade: two-human review, golden vectors, game-day
tested, per the settled kernel discipline.

---

## 5. Adopted switch triggers

Consolidated from both briefs (the Postgres brief's §6 largely adopted; the
distributed-SQL brief's concede-triggers absorbed where they sharpen).
Distributed SQL (evaluate Spanner first; CRDB only with a fresh read on
its licensing/business posture) is adopted when **any** fires:

1. **Residency:** counsel assesses in writing that in-territory primary
   storage of spine-class data is probable in ≥1 roadmap jurisdiction
   within 24 months, or any regime mandates synchronous atomic
   cross-plane erasure. Payload-plane mandates do not trigger — regional
   payload databases are the designed answer.
2. **Watermark failure:** any game day or production event demonstrates
   loss of an acked attestation or escrowed-checkpoint/WAL divergence
   (one occurrence), or the ack watermark cannot hold ingest ack p99 < 1s
   for a sustained week.
3. **Write ceiling:** sustained committed spine writes > 2,000/s per
   region for a month with the interface contract intact.
4. **Sharding failure:** a Citus-class POC on a regional payload database
   approaching ~5×10⁸ rows fails correctness or latency acceptance.
5. **Read SLO:** packet-read p99 > 400ms global (>150ms in-region) for a
   quarter with regional replicas and in-region assembly deployed, *with
   grant checks reading fresh* — the freshness qualifier from the
   distributed-SQL brief is adopted so the SLO cannot be met by cheating
   the revocation bound.
6. **Ops burn:** ≥2 database-HA sev-1s in a rolling year, or >0.5 FTE
   sustained database operations for two quarters, or two consecutive
   failed failover game days.
7. **Region multiplication:** payload regions exceed 3 (US/EU/ROW) with a
   4th confirmed on the roadmap — the point where the distributed-SQL
   brief's O(N) operational-multiplication argument (upgrades, lockstep
   migrations, CDC meshes, carve-out migrations under deadline) stops
   being an annoyance. Adopted from its concede-trigger 4, inverted into
   a switch trigger.

Trigger evaluation is a standing quarterly agenda item; a fired trigger
that is argued around rather than acted on must be a written, signed
decision — the same governance discipline D3's checkpoint brief imposes on
its own trigger.

---

## 6. Residual risks of this ruling, stated honestly

1. **The watermarks are code.** Spanner's RPO-zero cannot regress via an
   application bug; ours can. The mitigations (kernel-grade review,
   one-strike trigger §5.2, managed `global_db_rpo` backstop) reduce but
   do not eliminate this. This is the single largest risk knowingly
   accepted.
2. **A residency mandate could still arrive faster than the migration.**
   Trigger §5.1 fires on probability to buy the window, but a
   discretionary foreign designation with a short compliance clock is a
   scenario in which this ruling pays its worst case: a quarters-scale
   migration under deadline. Judged low-probability for pseudonymous
   minimized data; not zero.
3. **Cross-plane restore is a real forensic burden.** A partial-plane PITR
   restore leaves reconciliation work a single-database architecture would
   not have. Chain hashes bound and enumerate the divergence; they do not
   remove the work.
4. **The trigger-governance failure mode.** Triggers can be argued around
   under commercial pressure. The written-decision requirement makes
   slippage a visible act, not a quiet one; it cannot make it impossible.
5. **Stage-C double migration.** If the company reaches true stage C, the
   likely path is Postgres → sharded Postgres → distributed SQL, and the
   middle step may prove wasted motion relative to a single early bet.
   Accepted: the middle step is only reached in worlds where the company
   has the resources to regret it cheaply.

---

## 7. Founder items

- **[FOUNDER-CALL] Commission the residency counsel opinion now.** Trigger
  §5.1 is only as good as its input. The distributed-SQL brief's
  concede-trigger 1 is adopted as an affirmative obligation: a written
  counsel assessment, within 12 months, of (a) in-territory
  spine-primary probability across the 24-month roadmap jurisdictions and
  (b) the DPF/SCC posture for global replication of the minimized spine.
  Engaging counsel, and choosing which jurisdictions are on the 24-month
  roadmap at all, are founder decisions — the roadmap *is* the risk input,
  and sequencing India/Indonesia/Gulf earlier or later materially moves
  the probability behind this ruling's biggest residual risk.
- **[FOUNDER-CALL] The acked-loss posture is now a promise, not a policy
  choice.** This ruling commits the product to RPO-zero-for-acknowledged-
  attestations as an engineered property (§4), which forecloses the
  distributed-SQL brief's alternative of papering N seconds of
  acknowledged loss in the party contract. That is a party-facing
  contractual commitment the founder should knowingly own, because §4's
  machinery is what backs it and §5.2 is the tripwire if it fails.

No other item in this docket requires the founder; everything else is
engineering under the conditions above.
