# D5 Verdict: Cloud Provider — Judge Recommendation

Docket item D5, opened on founder go 2026-08-19 against the open item in
decisions/LOG.md entry 011. Briefs: `d5-single-hyperscaler.md`,
`d5-composed-stack.md`.

> **PROPOSED — not ratified.** This is a judge recommendation. It binds only
> when the founder ratifies it as a decisions entry. The provisioning gate at
> `plans/ORDER.md` stays shut until then.

## Two procedural facts recorded before the ruling

**1. The gate was widened.** Decision 011 framed D5 as "the AWS-vs-GCP
mini-litigation." The founder widened it to full candidate coverage on
2026-08-19. The ratifying entry must record the widening as a divergence from
011's framing; otherwise the log shows a gate answered in narrower terms than
it was asked.

**2. This docket does not have the independence D1–D4 had.** Those ran six
clean-context perspectives, eight adversarial briefs and four independent
judges who verified contested claims. D5's briefs and this verdict were
authored in one context on founder instruction. The reasoning of decision 017 —
one author writing both sides shares the misreading twice — applies to this
document and is not cured by having written the briefs adversarially. **Weight
this verdict below D1–D4 accordingly.** If any single ruling below is
load-bearing enough to regret, the cheap remedy is one clean-context judge
given only the two briefs.

## Ruling

**D5 — Primary plane on AWS; anchor, mirror and their accounts placed away from
it.** Ruled as four placements, not one platform commitment. The distinction is
operative: a future session may not place the anchor or mirror on AWS by
inferring it from "Grain runs on AWS."

| Placement | Ruling | Governing constraint |
|---|---|---|
| Payload databases, global spine, compute | **AWS** (Aurora PostgreSQL global databases) | D1 ack-watermark obligation |
| Compliance-mode WORM anchor | **Not AWS.** OCI Object Storage locked retention rules, first choice | D3 — must survive the operator |
| D3 second-cloud mirror | **Backblaze B2**, compliance mode | D3 — commercial and jurisdictional independence |
| Production KMS / hosted keys | **AWS KMS**, conditioned — see obligation 3 | Decision 011 real-KMS rule; D4 |
| EU payload plane | **Deferred**, not ruled — see obligation 4 | GDPR; first EU cohort |

### Why the primary plane goes to AWS

Dispositive: `rds.global_db_rpo` is the only commit-gating cross-region
durability control in the managed-Postgres market. Aurora commits when at least
one secondary is inside the RPO window and blocks writes on the primary when
none is. AlloyDB's cross-region replication is asynchronous with RPO-0 only on
planned switchover — the case that is not the failure case. Azure Flexible
Server documents expected RPO up to five minutes, degrading to replication lag
under severe regional failure.

The composed-stack brief conceded this and was right to. The single-hyperscaler
brief's framing of it survives scrutiny: the parameter's value is not that it
delivers RPO-zero (it cannot — its floor is 20 seconds) but that it fails
*independently of* the application watermark that carries the contractual
promise. At three engineers, on a launch-blocking obligation, a second failure
domain in the engine is worth more than it would be at thirty.

Secondary and not independently sufficient: AWS KMS holds the only current
FIPS 140-3 Level 3 managed-KMS validation (NIST CMVP #4884). This matched D2's
own standard — an actual certificate over a claim of equivalence — and is
treated as a tiebreak, not a basis, because of obligation 3 below.

### Why the anchor leaves AWS

The single-hyperscaler brief quoted the strongest WORM guarantee available and,
in the same passage, its escape hatch: compliance-mode objects are undeletable
by any principal including root, and the documented early-deletion path is
deleting the AWS account. The control defends against a compromised principal.
It does not defend against loss of the account, and loss of the account is the
event a single-vendor posture makes common between the ledger and its proof.

Grain's product test — every claim resolves to the evidence beneath it — is not
met if one commercial event can end both. OCI is preferred over Backblaze for
the anchor on documented text (neither a tenancy administrator nor Oracle
Support can delete a locked retention rule) and on the mandatory 14-day pre-lock
delay, which is the correct control for a small team that will get retention
parameters wrong on the first attempt and would otherwise be permanently stuck
with the error.

### Candidates eliminated

- **Cloudflare R2** — fails D3. Bucket locks are administrator-modifiable.
- **Hetzner, OVH bare metal, Fly.io, Railway, Render** — fail D1 and the
  real-KMS rule.
- **Neon, Supabase, Timescale** — no commit-gating durability control; the
  deletion saga crosses an uncontrolled vendor boundary.
- **Crunchy Bridge** — Postgres-specialist quality granted; rejected on the
  Snowflake acquisition. A system of record should not sit inside a
  recently-acquired product on a new owner's roadmap.
- **EDB (BigAnimal / Postgres AI Cloud)** — the strongest specialist; runs in
  the customer's own AWS or Azure account so it adds no custody boundary.
  Rejected because it inherits the underlying cloud's replication rather than
  supplying its own primitive, and on the agent-fluency reasoning D2 already
  ratified.
- **Azure** — clears every hard gate including Cohasset-validated SEC 17a-4(f)
  immutability. Loses on the ack watermark alone. **Recorded as the designated
  fallback** if switch-trigger 3 fires.
- **IBM Cloud, Alibaba** — no surviving argument.
- **Wasabi** — viable but vendor-asserted rather than independently documented;
  behind Backblaze on evidence quality alone.

### Where decision 017's GCP burden landed

Decision 017 required a GCP outcome to address the Object Lock equivalence gap
explicitly rather than silently. Addressing it: GCS Bucket Lock is genuine WORM,
irreversible once locked, and places an automatic project lien that blocks
project deletion — materially stronger than this docket expected. It is **not**
the reason GCP loses. GCP loses on the ack watermark, in the AlloyDB finding
above. The 017 burden is discharged, and discharged in GCP's favour on the
control it was raised about.

## Launch-blocking obligations attached to this ruling

1. **The anchor account is a separate legal and billing boundary**, not merely a
   separate AWS account — because the documented escape from S3 compliance mode
   is account deletion, and a shared billing relationship reintroduces the
   common event this ruling exists to remove.
2. **Payload-plane relocatability survives D5.** `residency_region` in the
   payload primary key and IaC-stamped regional modules (D1) are not to be
   traded away for Aurora-specific features. Any Aurora-only dependency on the
   payload plane is a recorded divergence.
3. **AWS KMS certificate #4884 carries a sunset date of 11/17/2026** — inside
   this build's horizon. The successor validation must be confirmed **before
   ratification**, not after. If no successor exists, the KMS tiebreak in this
   verdict is void and the placement re-opens (the primary-plane ruling stands
   regardless; it does not rest on FIPS).
4. **The EU plane is deferred, not ruled.** AWS European Sovereign Cloud reached
   general availability 15 January 2026 in Brandenburg. Before the first EU
   cohort, it must be verified feature-by-feature that it offers Aurora global
   databases with `rds.global_db_rpo` and a FIPS-validated KMS. **If it does
   not, the EU plane does not inherit this ruling's central justification** and
   D5 re-opens for that plane specifically.
5. **The residency roadmap's premise changed and counsel must be told.** The
   commissioned opinion (decision 005) was scoped US + EU + PH + India on an
   assumption this docket did not verify. Research finds neither the Philippines
   nor India imposes a localization mandate — PH regulates cross-border transfer
   without a storage rule; India operates a negative list under DPDP §16. This
   converts PH and India from *placement* questions into *transfer* questions
   and should be put to counsel in that form. It does not touch India's Rule
   8(3) retention problem, which is a separate open gate.

## Measurable switch-triggers

1. A competing managed Postgres ships a commit-gating cross-region durability
   control → re-litigate the primary plane.
2. Two durability game-days demonstrate the application ack watermark is
   sufficient standalone → the primary-plane ruling loses its basis and the full
   field re-opens, EDB and Azure included.
3. AWS European Sovereign Cloud lacks the Aurora global primitive → EU plane
   splits; Azure is the designated fallback.
4. KMS certificate #4884 lapses with no successor → KMS placement re-opens.
5. A compliance-mode unlock incident at OCI or Backblaze → anchor or mirror
   re-placed immediately.
6. Any account-level enforcement, suspension or billing termination touching
   Grain at any placed vendor → immediate re-litigation of that placement.
7. Counsel returns a localization (not transfer) finding for India or the
   Philippines → regional placement question re-opens in both directions.

## Amendment 1 (2026-08-19) — candidate field expanded

The founder called for full option coverage after the first draft. The complete
field, with the gate each candidate fails, is `d5-candidate-field.md`. Three
things in it bear on this verdict:

1. **Aiven was omitted from the first draft. That was an error.** It offers
   cross-region disaster recovery, replicas across different public clouds, and
   BYOC — running inside Grain's own cloud account, which clears the deletion-
   controllability gate that every PaaS fails. It still dies on the ack
   watermark (its CRDR is failover, not commit-gating), so the ruling stands,
   but it is the first candidate to revisit if founder call 5 below goes the
   other way.
2. **The ack-watermark argument was stated too broadly.** "Only commit-gating
   *cross-region* control" holds. Unqualified, it does not: PlanetScale Postgres
   acknowledges a write only after it reaches stable storage in two availability
   zones. PlanetScale fails three other gates, so nothing changes — but see
   founder call 5.
3. **EU sovereign providers hold a CLOUD Act argument this verdict does not
   dispose of.** It becomes live when the deferred EU plane is ruled, and it
   should be heard then rather than treated as settled by obligation 4.

## [FOUNDER-CALL] register

1. **Ratify, overrule, or send to an independent judge.** The independence
   deficit recorded at the top is the one procedural reason to do the third.
2. **Obligation 3 is time-boxed.** Confirming the successor FIPS validation is
   cheap and must happen before ratification, not after.
3. **Anchor vendor:** OCI is ruled first choice over Backblaze on documented
   text and the 14-day delay. Backblaze is simpler and cheaper and is already
   the ruled mirror. Consolidating both onto Backblaze would collapse the
   anchor/mirror independence this verdict is built on and is not recommended,
   but it is a founder call.
4. **Obligation 5 changes what counsel was asked.** The residency opinion is
   commissioned and long-lead; if it has not gone out, the scope should be
   restated as a transfer question for PH and India before it does.

5. **Does an availability zone count as a failure domain?** D1's obligation
   says acknowledgment must wait for durability "across failure domains" and
   never says whether that means cross-AZ or cross-region. **This call was
   never made, and more of the candidate field turns on it than on anything
   else in this docket.** Cross-region reading: this verdict stands as written.
   Cross-AZ reading: the field widens and Aiven, EDB and PlanetScale re-enter.
   It should be settled before ratification, not after.

## Evidence

Primary vendor documentation and NIST CMVP, retrieved 2026-08-19: AWS S3 Object
Lock and Object Lock considerations; AWS Aurora global database and disaster
recovery pages; AWS KMS FIPS announcements and CMVP certificate #4884; Google
Cloud Storage Bucket Lock, Object Retention Lock, and AlloyDB cross-region
replication; Microsoft Learn immutable blob storage overview, container- and
version-level WORM policies, and Azure Database for PostgreSQL geo-replication;
Oracle OCI Object Storage retention rules; Backblaze B2 Object Lock
documentation; Cloudflare R2 bucket locks; AWS European Sovereign Cloud launch
release (15 January 2026).

Secondary and treated as secondary: vendor comparison write-ups on managed
Postgres; the Wasabi SEC 17a-4 self-assessment; Philippines and India data
protection commentary (Baker McKenzie, DLA Piper, and Indian firm analyses) —
**the PH and India findings are law-firm commentary, not counsel advice to
Grain, and obligation 5 exists because they are not a substitute for it.**
