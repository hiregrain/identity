# Stack Perspective: AI-Native

Author persona: the AI-native architect. Independent perspective; no other
stack-perspective was read. Inputs: `design/ledger-design-0.1.md`,
`handoff/attestation-interface.md`, `research/00-founder-grilling-2026-08-17.md`,
`research/07-synthesis.md`, plus 2026-current web research on AI-assisted
engineering practice, property-based testing, and deterministic simulation
testing.

---

## TLDR

1. **The binding constraint is three humans' attention, not throughput.**
   AI agents will write most of this code and run most of this system. Every
   architectural decision should therefore be scored on one axis first: does
   it make correctness *machine-checkable* and the codebase *agent-legible*,
   so that human review load grows sublinearly with system size. Database
   throughput is not the risk at any point on the stated trajectory; silent
   semantic drift in agent-written code is.

2. **One language: TypeScript end-to-end**, strict to the maximum, in a
   single monorepo, one idiom, one deployable modular monolith. TS is the
   highest agent-fluency typed language in existence, its discriminated
   unions make the ledger's state machines (claim classes, party lifecycle,
   supersession, merge/unmerge) *unrepresentable-when-illegal* at the type
   level, and it erases the frontend/backend language boundary entirely.
   Rust and Go both lose on the axis that matters (below).

3. **One stateful system: managed Postgres**, holding both planes (integrity
   spine and payload store) with append-only enforced *in the database* —
   revoked UPDATE/DELETE on spine tables, trigger-rejected mutation, hash
   chain as a table. The scale math (§5) says partitioned Postgres carries
   hundreds of millions of identities comfortably; this is a low-write-rate,
   high-integrity system, not a firehose.

4. **Verification architecture is the product's real moat internally**: a
   small pure "semantic kernel" (supersession, alias closure, merge/unmerge,
   deletion, standing derivation) with an independent naive reference model,
   exhaustive property-based tests, mutation testing to keep agent-written
   tests honest, deterministic simulation testing on the three concurrent
   workflows, and **TLA+ specs for exactly two protocols** (merge/unmerge
   under concurrent ingestion; deletion pipeline vs. the read path). Formal
   specs pay their way here precisely *because* agents do the mechanical
   work: humans review a 300-line spec, agents keep a 30,000-line
   implementation conformant to it.

5. **SDLC: humans gate specs, invariants, and blast radius; agents own
   everything else.** Human review attaches to five path classes (crypto,
   authz, migrations-execute, registry actions, deletion) enforced by
   CODEOWNERS, and to the invariant/spec layer. Ordinary feature diffs are
   merged on green machine verification, not human eyes.

6. **Operations are API-first and reconcilable**: declarative IaC (Pulumi in
   TypeScript — same language), GitOps reconciliation, a production
   *invariant auditor* that continuously recomputes hash-chain integrity,
   supersession acyclicity, alias-closure consistency, and orphan-payload
   absence — so agents can both operate the system and *prove* it is
   correct, not just observe that it is up.

7. **Honest weaknesses are routed around, not denied**: agents remain weak
   at subtle concurrency (contained by serializable Postgres transactions +
   DST + the two TLA+ specs), security-sensitive code (contained by a
   frozen, human-reviewed, externally audited crypto/authz kernel), and
   long-horizon migrations (contained by expand/contract discipline with
   human-gated contract phases). §7.

8. **Where this breaks** (§8): if merge-steward and dispute human-review
   volume at 10⁸ identities swamps the humans — that is an ops-tooling
   product problem this architecture surfaces early but cannot dissolve; and
   if frontier-agent capability plateaus, this is an understaffed team with
   excellent tests.

---

## 1. The inverted premise

Every classical school of architecture optimizes for some scarce resource:
CPU (systems school), operational simplicity (boring-tech school),
organizational scaling (microservices school). All of them assume the
scarce resource is something other than what it actually is here: **the
attention of three humans supervising a workforce of AI agents.**

Two consequences the other schools will get wrong:

**Conway's law inverts.** Microservice decomposition exists to give human
teams independent deploy cadences and bounded contexts. There are no human
teams. Agents do not benefit from network boundaries — they benefit from
*legibility*: one repository they can grep end-to-end, one type system that
carries an invariant from the DB row to the API response without a
serialization boundary laundering it, one idiom so that every file looks
like every other file. Service boundaries in an agent-built system are pure
cost: each one converts a compile-time type error into a runtime integration
failure that an agent must diagnose from logs instead of from the compiler.

**Review is the bottleneck, so verification must replace it.** Three humans
cannot read the diffs of a system that grows at agent speed. The 2026
empirical record on agent-written code is sobering where it is unassisted:
agents write tests at the same rate whether or not they actually fixed the
bug, and prefer value-revealing print statements to assertions
([arXiv 2601.18827](https://arxiv.org/pdf/2601.18827)). The industry answer
that is actually working is not "review harder" — it is moving correctness
into machinery: property-based testing, deterministic simulation testing
(TigerBeetle's VOPR, Antithesis's whole-system PBT under fault injection,
now with 2026 production case studies —
[Antithesis/Tigris](https://antithesis.com/blog/2026/tigris_report/),
[Antithesis PBT docs](https://antithesis.com/docs/resources/property_based_testing/)),
and a re-emergent formal-methods discipline aimed specifically at agentic
engineering ([PAgE @ PLDI 2026](https://pldi26.sigplan.org/home/page-2026)).
This system's core semantics — append-only spine, supersession chains,
alias closures, two-plane deletion — are *exactly* the kind of
crisply-specifiable invariants this machinery is best at. That is the
architectural gift of ledger-design-0.1: it is already written as a set of
invariants. Build the system so those invariants are executable.

---

## 2. Language: TypeScript, end-to-end, one idiom

**Choice: TypeScript everywhere** — services, semantic kernel, worker-facing
web surface, IaC (Pulumi), internal tooling. Node LTS runtime. Strictness
maxed: `strict`, `exactOptionalPropertyTypes`,
`noUncheckedIndexedAccess`, no `any` (lint-fatal), no type assertions
outside a single audited `unsafe/` directory.

Why this maximizes agent reliability:

- **Training density.** TS is, with Python, the language frontier models
  write most fluently and idiomatically. Fluency is not cosmetic: it is
  fewer subtle API misuses per thousand lines, which is the dominant defect
  source in agent code.
- **Illegal states become type errors.** The ledger is a system of state
  machines: claim classes (`self_asserted | peer_attested |
  party_attested` as *distinct object types*, per design §2.2), party
  lifecycle (`pending → active → suspended → revoked`), supersession
  status, merge/alias state, deletion state. Discriminated unions +
  exhaustive `switch` checking mean an agent that forgets a lifecycle state
  gets a compile error, not a production incident. Go cannot express this
  (no sum types — the checking degrades to convention, and convention is
  what agents silently violate). This single feature outweighs everything
  Go offers.
- **One schema source of truth.** Zod (or Effect Schema) definitions are
  simultaneously the runtime validators at the ingestion boundary, the
  static types throughout the codebase, the generated JSON Schema published
  to attesting parties as the interface contract, and the source the DB
  DDL is generated-and-diffed against. The attestation-interface contract
  literally *is* a file in the repo that both machines and partners consume.
  When there is one artifact, agents cannot let three copies drift.
- **No frontend boundary.** The worker view (design §8) is a first-class
  product surface. TS end-to-end means the same branded `LedgerPersonId`
  type flows from the DB driver to the React component; there is no
  serialization seam for a provenance-grade confusion (founder decision 5's
  nightmare) to hide in.
- **Fast feedback loop.** Typecheck + lint + kernel property suite in under
  a couple of minutes is what lets an agent iterate dozens of times per
  task. Agent throughput is proportional to feedback-loop speed more than
  to anything else.

Why not the alternatives:

- **Rust** buys memory safety this I/O-bound system does not need, at the
  cost of lower agent fluency and — decisively — *human* review cost: when
  a human must audit a crypto-path diff, three founders' worth of Rust
  expertise does not exist. The borrow checker is a superb reviewer of
  problems we do not have.
- **Go** is the respectable boring pick, and its uniformity is genuinely
  agent-friendly — but no sum types means the state machines live in
  comments, and the whole verification strategy (§4) leans on the type
  system carrying semantics. Also reintroduces a second language for the
  web surface.
- **Polyglot "right tool per layer"** is the worst answer available: every
  language boundary is a place where an invariant must be re-stated and can
  therefore be mis-stated, and it fragments the idiom agents pattern-match
  on.

Performance honesty: Node is not the fastest runtime. It does not need to
be (§5 scale math). If a hot path ever genuinely needs it, push it into
SQL or a single audited native module — do not fork the language strategy.

**Idiom enforcement is infrastructure, not culture.** A ~50-rule lint/style
regime (functional core, imperative shell; no classes outside adapters; DB
access only through the generated query layer; errors as typed results on
kernel paths) enforced in CI, plus a written `IDIOM.md` that is loaded into
every agent context. Agents follow written idiom nearly perfectly and
unwritten idiom nearly randomly. Consistency is what makes 30k lines
reviewable by sampling.

---

## 3. Data and infrastructure: one database, reconcilable everything

### 3.1 Postgres as the only stateful system

Managed Postgres (Aurora Postgres or AlloyDB class; the specific vendor is
swappable, the requirement is: serializable isolation available, logical
replication, mature partitioning, API-driven administration).

Both planes live in it, as separate schemas with separate grant regimes:

- **`spine` schema (append-only):** attestation spine rows, verification
  spine rows, party/key event logs, merge/unmerge events, grant/revocation
  events, hash-chain table, tombstones. The application role has
  INSERT+SELECT only — **no UPDATE or DELETE grant exists**, and BEFORE
  UPDATE/DELETE triggers raise unconditionally as a second fence. The
  hash chain (each row carries `prev_hash`; chain heads checkpointed) is a
  plain table, built from day one per design §3.3, Merkle/CT-style proofs
  exposable later.
- **`payload` schema (erasable):** claim content, PII, contact channels,
  evidence details, keyed by spine object ID. A single deletion pathway —
  one stored procedure, executable only by the deletion service's role,
  invocable only through the human-gated deletion workflow (§6) — is the
  *only* thing in the system that can destroy data.
- **State machines in SQL too:** party lifecycle and claim-class
  transitions enforced by CHECK constraints and transition-table foreign
  keys, mirroring the TS unions. The DB is the last line of defense against
  an agent-written bug in the application layer; belt and suspenders is the
  correct posture when the application layer is agent-written.

Why one database: every additional stateful system (Kafka, a second store,
a cache with authority) multiplies the cross-system invariants — exactly
the class of bug (distributed interleaving) agents are worst at and humans
have no time to hunt. Postgres serializable transactions make the hard
concurrency problems *disappear as problems*: merge + concurrent ingestion,
deletion + concurrent read, supersession races are all single-database
transactions with the isolation level doing the reasoning. An outbox table
+ logical replication provides the event feed (notifications to parties,
search indexing, analytics) without granting any downstream system
authority.

### 3.2 Infrastructure

- **One modular monolith**, deployed as stateless replicas on a managed
  container platform (ECS/Fargate or Cloud Run class). Modules
  (`ingestion`, `registry`, `identity`, `read`, `deletion`, `worker-app`)
  are directories with lint-enforced import boundaries, not network
  services. Split a module into a service only when a *measured* runtime
  constraint demands it — predicted splits: none before ~10⁸ identities,
  and then only `read` (packet generation) for independent scaling.
- **Declarative IaC in Pulumi/TypeScript**, whole environment in the
  monorepo, GitOps-reconciled. Agents change infrastructure by PR, never by
  console; the reconciler makes actual state converge to declared state, so
  an agent can also *diagnose* infra by diffing declared vs. actual —
  reconcilability is what makes infrastructure agent-operable.
- **Managed services with good APIs everywhere**: KMS/HSM for the ledger's
  own signing and timestamping keys, object storage for exported artifacts,
  managed identity-verification vendors via the registry (per contract).
  Nothing self-hosted that a vendor runs better; every vendor chosen partly
  on API quality, because an agent will be the one operating it at 3am.
- **Ephemeral full-stack environments per PR** (Postgres branch + app
  deploy), so agents verify against a real system, not mocks. Mocks are
  where agent tests go to lie.

---

## 4. The verification architecture

This is the center of the design. The ledger's semantics are restated as
machine-checkable artifacts, in four layers.

### 4.1 The semantic kernel

All core semantics live in one pure, dependency-free TS package
(`kernel/`): supersession-chain resolution, alias-closure resolution,
merge/unmerge application, claim-class transitions and freeze rules,
standing derivation (the published deterministic rule of design §5),
deletion-completeness computation, verification-attestation assurance
derivation, prior-packet assembly. Pure functions over explicit state;
every DB interaction in the shell serializes through it. Purity is what
makes the next three layers cheap.

### 4.2 Property-based testing against a reference model

- An **independent naive reference model** — the ledger semantics
  implemented as slow, obvious, in-memory code (hundreds of lines) — is
  maintained *separately from the kernel*, and differential-tested against
  it under generated operation sequences (fast-check). This is the standard
  defense against the documented failure mode of agent-written tests
  mirroring the implementation's own bugs: the model and the kernel would
  have to be wrong *identically*.
- Named invariants, each an executable property, each traceable to a line
  of `ledger-design-0.1.md` — a sample of the suite:
  - Spine rows are never mutated; hash chain re-verifies from genesis.
  - Supersession chains are acyclic, same-issuer (or ledger-invalidation),
    and current-truth derivation is deterministic and total.
  - Merge then unmerge restores exact pre-merge read-time resolution for
    all attestations except those flagged for steward review (design §1.4)
    — a round-trip property agents can regression-run forever.
  - Alias closure: every historical `subject_id` resolves; no packet ever
    omits an attestation reachable through the closure; no packet ever
    includes one that is not.
  - Deletion completeness: after deletion, no readable personal data is
    reachable from any API surface or any payload-schema row for the
    tombstoned ID, *and* the hash chain still verifies, *and* the ID never
    re-resolves. R2 as an executable property.
  - Frozen self-asserted claims reject all edit paths permanently.
  - Standing derivation: deterministic, citation-complete (every entry's
    `supporting_attestation_refs` actually support it under the published
    rule), no cross-dimension composite computable from exposed outputs.
  - Registry: no attestation accepted from a non-`active` key; suspension
    changes read-time flags and nothing at rest; compromise-report ordering
    vs. ledger timestamp enforced (design §3.3's load-bearing rule).
- **Mutation testing** (Stryker) on the kernel with a high enforced
  mutation score. This is the honesty check *on the tests themselves* —
  the specific corrective for agents that write green-but-vacuous tests.

### 4.3 Formal specification: yes, narrowly — and the calculus has changed

The traditional case against TLA+ was cost: specs are expensive to write
and drift from code. Both halves weaken when agents do the mechanical work
and the 2026 tooling context is what it is (formal methods re-entering the
agentic mainstream — [PAgE 2026](https://pldi26.sigplan.org/details/page-2026-papers/6/Formal-Methods-for-Frontier-AI-Systems)).
The remaining scarce input is *human judgment about what the spec should
say* — which is precisely the artifact three humans have time to review.

Verdict: **two TLA+ specs, no more.**

1. **Merge/unmerge under concurrent attestation ingestion** — the one place
   design 0.1 itself admits a manual residue (attestations landing during a
   merged period). Model-check that no interleaving of
   merge/unmerge/ingest/read loses, duplicates, or mis-attributes an
   attestation.
2. **Deletion pipeline vs. the read path** — grants revoked, reads
   stopped, payloads purged, spine retained, across concurrent packet
   generation. Model-check that no packet is ever issued containing data
   from a person whose deletion has been accepted.

Everything else — supersession, standing, freezing, registry — is
sequential, single-transaction logic where the executable property suite is
strictly cheaper and equally rigorous. A spec beyond these two must earn
its place by exhibiting a concurrency structure the property suite cannot
reach. The specs live in the monorepo, model-checked in CI (small
configurations), and each spec action is comment-linked to the kernel
functions implementing it; agents keep the linkage current, humans review
spec diffs — which are rare, small, and semantically dense: the ideal
human-review substrate.

### 4.4 Deterministic simulation testing

The kernel's purity plus single-database design means the whole service can
run under an in-process deterministic harness (simulated clock, seeded
randomness, virtual Postgres transaction interleaving), TigerBeetle-VOPR
style ([vopr.md](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/internals/vopr.md)),
exploring crash/retry/interleave schedules over ingestion, merge, and
deletion workflows, checking the §4.2 invariants continuously. Every
failure replays exactly from its seed — which converts the worst class of
bug (heisenbug an agent cannot reproduce) into the best class (failing seed
an agent can fix autonomously). When budget allows, whole-system
fault-injection via Antithesis
([DST docs](https://antithesis.com/docs/resources/deterministic_simulation_testing/))
is the natural upgrade; the architecture (containerized monolith + Postgres)
is exactly its sweet spot.

### 4.5 The production invariant auditor

Verification does not stop at CI. A continuously running auditor service
recomputes, against production: hash-chain integrity from checkpoints,
supersession acyclicity, alias-closure referential integrity, absence of
payload rows for tombstoned persons, absence of spine mutations
(WAL-derived), grant/read-log consistency (every packet issuance backed by
an active grant at issuance time). Any violation is a sev-1 that pages a
*human*. This is what "agents operate the system" safely means: the system
carries its own proof obligations, so an operating agent's mistakes are
caught by machinery, not by a human noticing.

---

## 5. Scale trajectory

The arithmetic, so nobody over-builds:

- **~1M identities in months:** ~10⁶ persons, attestations arriving per
  engagement/period — call it 10–50/person/year. Tens of millions of spine
  rows/year. A single unpartitioned Postgres yawns.
- **Hundreds of millions in ~2 years:** ~10⁸ persons × ~20 attestations/yr
  ≈ 2×10⁹ small spine rows/yr, low-terabyte range with payloads. Writes:
  even 10⁹/yr averages ~30/sec (peaks in the low thousands) — modest.
  Reads: packet generation is bounded by grant activity, not by traffic
  fashion. Hash-partition both planes by `ledger_person_id` (every query
  in the system is person-scoped or party-scoped; the two-plane model
  shards perfectly on person). Still one logical Postgres, now partitioned,
  read replicas for the worker view.
- **Planet scale:** move the partitions onto a Postgres-compatible
  distributed layer (Citus-class) or shard-by-person with a routing layer
  in the app — the access pattern (no cross-person transactions except
  merge, which touches exactly two persons) makes this one of the
  friendliest sharding problems in databases. Merge across shards is the
  one two-shard transaction; it is already human-gated and low-volume.
  Regionalization for data-residency is a payload-plane concern only —
  the spine contains no readable personal data (design §2.1), which is a
  quietly enormous infrastructure gift: the integrity layer can be global
  while payloads localize.

What actually scales superlinearly is not compute — it is **human-touch
workflows**: merge steward review at an up-to-10% organic duplicate rate,
dispute handling, party vetting. At 10⁸ identities that is millions of
review items. The architecture's answer is to treat these as *products*
from day one — queue, evidence panel, decision log, agent-prepared
recommendation with human click-through — so the marginal human cost per
review falls continuously and review labor can eventually be hired/scaled
independently of engineering. But see §8: this is the trajectory's real
bottleneck, and no stack choice dissolves it.

---

## 6. SDLC: what humans gate, what agents own

**Agents own:** feature implementation, test authoring, refactors, IaC
diffs, dependency updates, migration *authoring*, incident triage and
first-response, documentation, the reference model's extension (with the
adversarial-pairing rule: the agent context that writes a kernel change
never writes the corresponding model change — separate contexts, separate
prompts, so differential testing retains its independence).

**Humans gate — enforced by path-based CODEOWNERS and deploy machinery,
not by convention:**

1. **The spec/invariant layer**: TLA+ specs, the named property list, the
   reference model's semantics, `IDIOM.md`, the interface contract schema.
   This is the highest-leverage human hour in the company: reviewing what
   the system *must do*, once, instead of reviewing every diff that does it.
2. **Crypto and authz paths** (`kernel/crypto`, signature verification,
   grant enforcement, session/auth): mandatory human review on every diff,
   no exceptions, plus periodic external audit. Small frozen surface,
   audited libraries (libsodium bindings for Ed25519/JWS), zero hand-rolled
   primitives.
3. **Blast-radius operations**, each a two-key workflow (agent prepares,
   human approves in-band): key ceremonies and rotation; registry lifecycle
   transitions (activate/suspend/revoke a party); merge execution over
   attested history (design §1.3 already demands this); the deletion
   pipeline's destructive phase; the *contract* phase of schema migrations;
   IAM/network IaC changes.
4. **Taxonomy versions** (`work_kind`) — council-governed per design §6,
   mechanically versioned.

**How review load scales sublinearly:** an ordinary PR merges on machine
verification alone — typecheck, lint, property suite, mutation-score
floor, differential tests, DST smoke, migration lint, and a generated
**invariant impact statement** (which named invariants' coverage the diff
touches, which gated paths it does not touch). Humans sample-audit merged
work and spend their attention on the four gates above. Migrations are
expand/contract only: expand phases auto-deploy; contract phases queue for
human approval with shadow-read verification evidence attached. Deploys are
progressive with auto-rollback on SLO burn — rollback is an agent-safe
operation because deploys are stateless and migrations are
backward-compatible by construction.

---

## 7. Observability, designed for agent diagnosis

- **Wide structured events, not log lines**: one canonical event per
  request/workflow-step (OTel traces + a wide event to columnar storage),
  carrying the semantic identifiers (`ledger_person_id`, object IDs,
  invariant-relevant state) an agent needs to reconstruct causality by
  *query* rather than by scrolling. Dashboards are for humans passing by;
  the primary observability interface is a query API, because the primary
  operator is an agent.
- **Determinism as an observability feature**: kernel purity means any
  production anomaly can be replayed locally from its event's inputs. The
  best diagnostic tool an agent can have is the ability to reproduce.
- **SLOs with burn-rate alerts route to an on-call agent** that triages,
  correlates (deploy? migration? dependency? invariant-auditor signal?),
  executes the safe playbook set (rollback, replica failover, rate-limit),
  and writes the incident narrative. Humans are paged for: invariant-auditor
  violations, anything touching the §6 gates, and agent-triage timeout.
  Every incident feeds a postmortem whose action items are — in this shop —
  usually new machine checks, not new human vigilance.
- **The audit log is a product surface, not an ops afterthought**: read
  logs, grant history, registry history are worker-visible by design
  (founder decision 4), which conveniently means the observability of
  record is built to product quality from day one.

---

## 8. Where agent-built systems fail, and how this design contains it

1. **Subtle distributed-systems bugs.** Agents interleave-blind. Contained
   by *removing the distribution*: one database, serializable isolation on
   kernel-path transactions, no cross-system authority; plus DST exploring
   interleavings mechanically, plus the two TLA+ specs on the only
   genuinely concurrent protocols. The architecture's simplicity is not
   aesthetic — it is the containment strategy.
2. **Security-sensitive code.** Agents produce plausible-but-subtly-wrong
   crypto and authz. Contained by minimizing the surface (one frozen
   kernel, audited libraries, no hand-rolls), mandatory human review on
   the path class, external audit before the first external attesting
   party, and secrets/keys living in KMS where application code — and
   therefore agent code — never touches key material.
3. **Vacuous or implementation-mirroring tests.** Documented 2026 failure
   mode. Contained by the independent reference model, differential
   testing, mutation-score floors, and adversarial pairing (§6).
4. **Long-horizon migrations.** Agents lose the plot across multi-week
   stateful transitions. Contained by expand/contract discipline (every
   step individually reversible and verifiable), shadow-read verification
   producing evidence artifacts, human gates on contract phases, and the
   invariant auditor running throughout — a migration that violates an
   invariant halts itself.
5. **Slop accumulation and idiom drift.** Each agent diff is locally fine;
   the sum is entropy. Contained by mechanical idiom enforcement, code
   generation from single schema sources (drift cannot occur where copies
   do not exist), scheduled consolidation passes run *by agents* under the
   mutation-tested safety net, and repo-level complexity budgets in CI.
6. **Confident wrong diagnosis in operations.** Contained by the two-key
   pattern on anything destructive, playbook-restricted autonomous actions,
   and the invariant auditor as ground truth an agent cannot argue with.

---

## 9. Where this breaks

- **The human-review queues, not the software.** Merge stewardship at a
  ~10% duplicate rate, dispute windows, and party vetting are
  *constitutionally* human under this design (and under design 0.1). At
  10⁸ identities the stack keeps the marginal cost per review falling, but
  the total is a staffing and product problem — thousands of review-hours
  a week — that three people cannot absorb and this document cannot
  architect away. If that is not confronted as a first-class product line
  (or the auto-merge criteria loosened, with career-contamination risk),
  it is the trajectory's real wall.
- **Agent capability plateau.** The entire leverage model assumes 2026-era
  frontier agents keep improving or at least hold. If agent reliability
  regresses or plateaus below the threshold where the verification
  machinery catches their defect rate, this is a three-person team with an
  unusually good test suite and a hiring problem.
- **TS/Node at true planet-scale hot paths.** Packet generation at 10⁹
  identities with heavy read amplification could outgrow Node economics.
  The escape hatch (push hot paths into SQL, or one audited native module)
  is real but has a ceiling; a rewrite of the read path in a systems
  language at year 4 is a plausible, bounded cost this design knowingly
  defers — correctly, because the kernel semantics it would reimplement
  are, by then, an executable specification.
- **Single-vendor Postgres gravity.** Everything-in-Postgres is the right
  2026 call; it does concentrate migration risk if the distributed-Postgres
  layer chosen at stage 3 disappoints. Mitigated by the sharding pattern
  being app-visible (person-hash) rather than vendor-magic, but not zero.
- **Regulatory demands for human process.** If counsel later concludes
  (per the research corpus's standing FCRA analysis) that dispute
  reinvestigation or Art. 22 requires demonstrably human decision-making at
  volume, the agent-operated dispute machinery must be re-papered with
  humans in more loops than this design budgets for.

## 10. What I'd veto from other schools

- **Microservices / Kubernetes-first decomposition.** Decomposition for
  team boundaries that do not exist, paid for in the exact bug class
  (cross-service interleaving) agents handle worst and in the destruction
  of whole-system type flow. One monolith until a measured constraint says
  otherwise.
- **Event sourcing on Kafka (or any log system) as the source of truth.**
  The append-only spine *in Postgres* already is the event log, with
  transactional integrity the external log cannot offer. Kafka as authority
  means dual-write invariants forever. Outbox + logical replication gives
  every downstream benefit with zero authority leakage.
- **Rust-core/TS-edge polyglot purism.** Every language boundary is an
  invariant-restatement boundary. The performance case does not exist at
  the stated write rates; the human-audit case is negative.
- **Blockchain/DID/VC-stack maximalism.** Design 0.1 already ruled
  correctly: keep the VC-2.0-compatible envelope shape, defer conformance;
  the hard problem is registry vetting, which no chain touches.
- **"Boring tech" fatalism about verification.** The boring-tech school
  will accept Postgres (good) and then treat property-based testing, DST,
  and the two TLA+ specs as gold-plating (fatal). In a human-built system
  that machinery is a luxury; in an agent-built system it *is* the review
  process. Cutting it does not save effort — it silently converts machine
  verification back into human review that no one has capacity to perform.
- **Hiring as the scaling strategy.** Adding engineers before adding
  verification machinery lowers the leverage of every agent and every
  human. Headcount should follow the §9 review-queue wall (ops/stewardship
  roles) long before it follows engineering.

## 11. Assumptions

1. Frontier agent coding/operating capability at least holds at the
   2026 level; the team runs current-generation agents with large-context
   monorepo tooling.
2. The founder rulings (R1 worker-owned platform; R2 whole-profile
   deletion, no record editing) and the interface contract are stable;
   the two-plane model of design 0.1 is the semantic ground truth this
   stack executes.
3. Write volume stays attestation-shaped (per-engagement/period
   aggregates), never behavioral-trace-shaped — the contract's "what never
   crosses" holds. If per-unit work rows ever cross the boundary, the §5
   scale math and the one-database strategy must be redone.
4. Managed Postgres (then a Postgres-compatible distributed layer) remains
   commercially healthy through the trajectory.
5. Standing derivation stays deterministic and published (design §5). If
   product later demands learned/ML-derived standing, the verification
   architecture needs a new layer (eval harnesses, not property tests)
   this document does not provide.
6. Budget exists for external security audits and, at stage 2, a
   commercial DST platform; "virtually unlimited capital if big" is read
   as: spend on verification machinery early, it is the cheapest insurance
   in the building.

---

Sources consulted (2026-current): [PAgE @ PLDI 2026](https://pldi26.sigplan.org/home/page-2026) ·
[Formal Methods for Frontier AI Systems](https://pldi26.sigplan.org/details/page-2026-papers/6/Formal-Methods-for-Frontier-AI-Systems) ·
[Automated structural testing of LLM-based agents (arXiv 2601.18827)](https://arxiv.org/pdf/2601.18827) ·
[PBT-Bench (arXiv 2605.15229)](https://arxiv.org/pdf/2605.15229) ·
[Antithesis: property-based testing](https://antithesis.com/docs/resources/property_based_testing/) ·
[Antithesis: deterministic simulation testing](https://antithesis.com/docs/resources/deterministic_simulation_testing/) ·
[Antithesis/Tigris 2026 report](https://antithesis.com/blog/2026/tigris_report/) ·
[TigerBeetle VOPR](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/internals/vopr.md) ·
[WarpStream: DST for an entire SaaS](https://www.warpstream.com/blog/deterministic-simulation-testing-for-our-entire-saas)
