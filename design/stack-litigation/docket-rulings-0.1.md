# Stack Litigation — Consolidated Rulings 0.1 (2026-08-17)

> **RATIFIED by the founder, 2026-08-17.** All four rulings bind, with these
> sub-rulings: D2 is ratified contingent on the T1 agent-fluency spike
> (pre-committed: Go stands unless its measured defect rate is materially
> worse); the first external attesting party is NOT confirmed within ~2
> quarters, so the witnessed log is post-launch with the registry-enforced
> deadline; D4 countersignatures are contractually mandatory (quarterly,
> automated by the integration kit) and the bootstrap tier is deferred to
> first external party; "zero loss of acknowledged attestations" is adopted
> as a party-facing contractual promise; the residency counsel opinion is to
> be commissioned for US + EU + PH + India.

Process: six independent clean-context perspectives → convergence map →
eight adversarial briefs (two per docket item, steelman-then-attack, with
measurable switch-triggers) → four independent judges who verified contested
claims before ruling. Full record in this directory and
`../stack-perspectives/`. Rulings below are judge recommendations; they bind
once the founder ratifies.

## The four rulings

**D1 — System of record: managed Postgres.** Two-plane, subject-partitioned,
regional payload databases + tiny global no-readable-PII spine. Conditioned
on four launch-blocking obligations: (1) ack watermark — no attestation
acknowledged until durable across failure domains (Aurora's managed RPO
primitive `rds.global_db_rpo` as the backstop, tightened); (2) checkpoint-
escrow watermark; (3) two-phase issuance receipts to parties; (4) fresh-read
discipline — grant/deletion liveness checks read the primary, never a
replica. Regional-Spanner-day-one rejected (defuses the invoice, not the
dev-loop and agent-fluency costs; placement optionality already held open by
schema discipline). Dispositive: the acknowledged-loss attack dissolves
under watermarks; the deletion-consistency attack is physics (Spanner pays
the same cross-region round trip), relocated not solved; ordering authority
is the anchored checkpoint sequence (per D3), mooting TrueTime; documented
migrations run OFF CockroachDB (Motion, ZITADEL) while Figma/Notion chose
sharded Postgres at the decision point.

**D2 — Language: Go core, TypeScript surfaces, one generated contract
layer.** Go owns kernel, ingestion, registry, read path, deletion, partner
API; TS owns worker web surface and steward console; a language-neutral
schema generates both sides plus the cross-language canonicalization test
vectors (needed for partners anyway). Dispositive: the 2025–26 npm
supply-chain record (Shai-Hulud et al.) vs. Go's structural properties
(no install-time execution, sumdb transparency, audited stdlib crypto with
an actual FIPS 140-3 certificate) — decisive for the kernel because a
poisoned dependency in the verification path can accept forgeries without
touching a key; the TS agent-fluency evidence did not survive verification;
the dangerous seam is the partner/wire boundary, which must be
language-neutral regardless. The language boundary coincides with the
two-human-review trust boundary. Conditional on the T1 pre-code
agent-fluency spike.

**D3 — Transparency: day-one anchoring launch-blocking; witnessed tile log
at a registry-enforced deadline.** Launch requires: per-stream Merkle roots
checkpointed every ≤5 minutes, KMS-signed, to compliance-mode WORM object
lock in a separate account, mirrored to a second cloud; frozen
canonicalization; recomputable checkpoint format; complete coverage;
inclusion receipts to parties. The Tessera-class log starts construction
immediately post-launch, runs beside Postgres as integrity authority (never
the synchronous write path), and must be live, witnessed, and genesis-proven
against the day-one anchors before the first external party's `active`
transition or 1M identities — enforced in the registry state machine so
slipping it is a visible governance act. If the founder confirms an external
party within ~2 quarters, the log moves into pre-launch scope. Consequence:
D6 resolved — the anchored checkpoint sequence is the system's ordering
authority.

**D4 — Party keys: party-held custody for registry-grade keys.**
Partner-side KMS via a ledger-shipped integration kit; ledger-provisioned-
then-ownership-transferred bootstrap tier for small parties; short-lived
(30–90 day) auto-rotating keys; no code path by which the operator can
invoke a registry-grade party key. Worker/peer account keys are hosted (both
briefs agreed). Hosted-brief controls adopted as defense-in-depth: issuance
evidence in the log, party-visible signature feed, periodic party
countersignatures. Dispositive: compensating controls restore detectability,
not impossibility, and the product's margin is not assuming the operator's
honesty; verified precedent uniform (eIDAS sole-control, CA/BF prohibition,
Sigstore's keyless model is client-held ephemeral keys + transparency —
exactly this shape); repair asymmetry — partner leaks are bounded and
reparable in-system, operator-forgery capability recolors the record forever.

## The consolidated stack (what the rulings + convergence map now specify)

- Modular monolith, one monorepo; no microservices, no Kubernetes, no
  Kafka-as-truth, no blockchain.
- Go core / TS surfaces / generated language-neutral contract layer.
- Managed Postgres (Aurora-class): global append-only spine (no readable
  PII, enforced by revoked UPDATE/DELETE + CI schema lint), regional payload
  DBs with `residency_region` on every row; per-person envelope encryption;
  deletion = orchestrated saga (copy-map with SLOs) + crypto-shred +
  provable `PayloadPurged` event.
- Per-stream (per-subject, per-party) hash chains; ≤5-minute KMS-signed
  Merkle checkpoints to cross-cloud WORM from day one; witnessed tile log by
  the registry-enforced trigger; checkpoint sequence = ordering authority.
- All ledger keys in cloud KMS (offline root, CA-style); party keys
  party-held per D4; workers on passkeys with recovery re-clearing derived
  assurance level.
- Prior packets generated at read time, never edge-cached; standing never
  served from the analytics plane; ingestion behind a durable idempotent
  queue; subject-partitioned (hot parties at period close).
- Trust kernel <~3k lines, two-human review, golden vectors + fuzzing +
  differential testing against a reference model; mutation testing on
  agent-written tests; two TLA+ specs (merge/unmerge concurrency; deletion
  vs. read path) — D5 rides with the AI-native verification architecture,
  now on Go core (PBT/mutation tooling thinner in Go; mitigated by a TS
  reference model per D2 verdict).
- Human queues (merge stewardship, disputes, party vetting) built as a
  product line with throughput design — the actual 10⁸ wall.

## Trigger register (contractual; full definitions in verdict files)

- D1: counsel-assessed residency probability on the spine; watermark SLO
  failure; sustained 2k writes/s/region; sharding POC failure; quarterly
  read-SLO miss; ops burn ≥2 sev-1s/year.
- D2: T1 pre-code agent-fluency spike (gate); FIPS mandate → kernel already
  Go; agent-defect-rate inversion; codegen-chain rot.
- D3: external party confirmed within ~2 quarters → log pre-launch;
  witnessing purchasable for private logs; launch-time inclusion-proof
  requirement from any party.
- D4: partner leak rate above modeled; onboarding-funnel failure; counsel
  ruling the category argument inert; commodity sole-control hosted signing;
  operator signing incident (any) → immediate re-litigation.

## [FOUNDER-CALL] register — the items that are yours

1. **Ratify the four rulings** (or overrule any — D2 is the one that
   overturned the perspectives' majority lean, on verified evidence).
2. **D3 timeline input:** is the first external attesting party realistically
   within ~2 quarters? If yes, the witnessed log moves into pre-launch scope.
3. **D1:** commission the 12-month residency counsel opinion (roadmap
   jurisdictions are the input); knowingly own "RPO-zero for acknowledged
   attestations" as a party-facing contractual promise.
4. **D2:** run the T1 agent-fluency spike before ratifying Go (a bounded
   pre-code experiment, defined in d2-verdict.md).
5. **D3:** counsel blessing of the salted-commitment posture before
   checkpoints go public; witness sourcing (auditor vs. partner-as-witness).
6. **D4:** bootstrap-tier timing and whether party countersignatures are
   contractually mandatory or best-effort.
