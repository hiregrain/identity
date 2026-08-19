# D5 Candidate Field — Full Map and Elimination Record

Companion to `d5-verdict.md`. The verdict eliminated most of the field in one
line per candidate. This document carries the actual reasoning, the gate each
candidate fails, and — where the one-liner was wrong or thin — the correction.

Retrieved 2026-08-19. Vendor capability claims move; every row is a dated fact.

## The gates, and where each comes from

A candidate must clear all of these to be placed on the **primary plane**. The
anchor and mirror are judged on G4 and G6 alone.

| Gate | Requirement | Source |
|---|---|---|
| **G1** | Managed Postgres as system of record. Not distributed SQL, not self-managed | D1 (decision 005) |
| **G2** | An engine-level control that gates *acknowledgment* on durability across failure domains — not a monitoring metric, a control that refuses the commit | D1 obligation 1; the "zero loss of acknowledged attestations" contractual promise |
| **G3** | Two physically separate databases (global spine, regional payload) with `residency_region` on every payload row, and per-region payload placement | Decision 011; `plans/foundation/04` |
| **G4** | Compliance-mode WORM that survives the operator's own principals and the vendor's support organisation | D3 |
| **G5** | Real HSM-backed KMS in production | Decision 011; D4 |
| **G6** | A second cloud, commercially and jurisdictionally independent, for the checkpoint mirror | D3 |
| **G7** | The deletion saga must be controllable end-to-end — reaching CDC, indexes, lakehouse and backups inside a boundary Grain can audit | Decisions 009 / 013 / 038 |
| **G8** | Operable by three engineers with no standing staging environment, at the agent fluency D2 already ruled a first-class cost | Decision 011 (no staging); D2 |

**G2 carries an unresolved interpretation, and it decides more of this field
than anything else.** D1's text says "durable across failure domains." It does
not say whether an availability zone is a sufficient failure domain or whether
the requirement is cross-region. Aurora satisfies both readings. At least one
other candidate satisfies the AZ reading only. **This is a founder call that
was not made, and it should be made before D5 is ratified** — see the
correction in §3.

---

## 1. The full field

Grouped by what they were considered *for*. A candidate can fail as a primary
plane and still win a placement.

### Tier 1 — hyperscalers (primary-plane candidates)

| Candidate | G1 | G2 | G4 | G5 | Verdict |
|---|---|---|---|---|---|
| **AWS** (Aurora PostgreSQL) | yes | **yes** — `rds.global_db_rpo` blocks commits when all secondaries exceed the window | yes — S3 Object Lock compliance mode, undeletable by root | yes — FIPS 140-3 L3, CMVP #4884 | **Ruled: primary plane** |
| **GCP** (AlloyDB / Cloud SQL) | yes | **no** — cross-region replication is asynchronous; RPO-0 only on *planned* switchover | yes in substance — Bucket Lock, irreversible, automatic project lien | FIPS 140-2 L3 | Eliminated on G2 |
| **Azure** (Flexible Server) | yes | **no** — documented expected RPO up to 5 min, degrading to replication lag under severe regional failure | yes — locked time-based retention, Cohasset-validated vs SEC 17a-4(f) | FIPS 140-2 L3 (Managed HSM) | Eliminated on G2. **Designated fallback** |
| **OCI** | yes | not established | **yes — strongest documented text**: neither a tenancy administrator nor Oracle Support can delete a locked rule; 14-day pre-lock delay | Vault/HSM | Eliminated as primary on G2/G8. **Ruled: anchor** |
| **IBM Cloud** | yes | no | — | — | Eliminated. No surviving argument on G8 |
| **Alibaba** | — | — | — | — | Excluded. Non-starter for US employment-adjacent personal data |

### Tier 2 — managed-Postgres specialists

| Candidate | Where it dies | Detail |
|---|---|---|
| **Aiven** | G2, narrowly | **Omitted from the first verdict — that was an error.** The most serious specialist candidate: cross-region DR as a product feature, replicas across *different public clouds*, ISO 27000-series / HIPAA / PCI-DSS / SOC 2 Type II, and **BYOC — runs inside Grain's own cloud account**, which clears G7 outright. Dies on G2: CRDR is replica-and-failover, not commit-gating. Worth naming as the candidate to revisit first if G2 is re-read |
| **EDB** (BigAnimal / Postgres AI Cloud) | G2, G8 | Runs in the customer's own AWS or Azure account, so no custody boundary. Inherits the underlying cloud's replication rather than supplying a primitive. Agent fluency thin relative to Aurora |
| **PlanetScale Postgres** | **G2 under one reading only** | See §3. Semi-synchronous replication is *always on*: a write is acknowledged only after reaching stable storage in two availability zones. That **is** a commit-gating durability control — cross-AZ, not cross-region. Also fails G3 as a packaged product and G4/G5 entirely |
| **Crunchy Bridge** | Institutional | Postgres-specialist quality granted. Acquired by Snowflake in 2025; a system of record should not sit inside a recently-acquired product on a new owner's roadmap |
| **Neon** | G2, G7 | Serverless architecture, SOC 2 and HIPAA. No commit-gating cross-region control; branching/autosuspend model is orthogonal to a ledger's needs |
| **Tiger Data (Timescale Cloud)** | G2, fit | 99.9% uptime SLA; HA replica is push-button and monthly HA guarantee is Enterprise-tier. Built for time-series analytics; the HA model is failover, not acknowledgment-gating |
| **Nile, Xata** | G2, G8 | Multi-tenant-app-shaped Postgres platforms. Neither is positioned for a durability obligation of this kind |

### Tier 3 — PaaS

| Candidate | Where it dies | Detail |
|---|---|---|
| **Supabase** | G2, G7, G8 | See §2. The strongest PaaS candidate and the one most worth explaining |
| **Railway** | G1 and G2, decisively | Default Postgres service is **single-node**: no PITR, no read replicas, no automated failover. An HA Postgres upgrade launched March 2026 and **Railway's own documentation warns it is not production-ready**. Independent write-ups cite repeated platform outages. This is not a close call |
| **Render** | G2, G4, G5 | Materially better than Railway: PITR (3 days Hobby / 7 days paid), read replicas and HA on Pro and above. Still no acknowledgment-gating control, no compliance WORM, no HSM-backed KMS |
| **Heroku Postgres** | G2, G8 | 99.95% SLA on Standard; HA on Premium. Salesforce-owned, and the platform's strategic position has been in question for years — the same institutional objection raised against Crunchy Bridge, with a longer track record behind it |
| **Fly.io Managed Postgres** | G2 | In-region HA and regional read replicas; 35+ regions is a real advantage for a residency story. **Fly does not offer managed cross-region replicas or multi-master** — G2 fails at the requirement, not the margin |
| **Vercel Postgres** | — | Neon under the hood. Inherits Neon's row |

### Tier 4 — bare metal and unmanaged

**Hetzner, OVH bare metal, self-managed Postgres on anything.** Fail G1 by
definition — D1 ruled *managed* Postgres, and the ruling's reasoning was that a
three-person team should not own the durability of the system of record at the
operating-system level. Cost advantage is large, real, and irrelevant to a
launch-blocking durability obligation. Not a close call and not revisitable
without overturning D1.

### Tier 5 — EU sovereign providers

**OVHcloud, Scaleway, STACKIT, Exoscale, Open Telekom Cloud.** All incorporated
under EU law, GDPR-native, and carrying a **CLOUD Act exemption no US
hyperscaler can offer** — a genuine argument the first verdict did not engage.
OVHcloud Object Storage carries native Object Lock WORM. All offer managed
PostgreSQL.

They fail G2 and G8 as a primary plane. But the CLOUD Act point is not
disposed of by that, and it lands on a live question: whether the EU payload
plane belongs on AWS European Sovereign Cloud (EU-operated, EU-staffed, but
Amazon-owned) or on an EU-incorporated provider. **The verdict defers the EU
plane; this is the argument that should be heard when it is ruled.**

### Tier 6 — object storage, considered for anchor and mirror only

| Candidate | G4 | Placement |
|---|---|---|
| **OCI Object Storage** | yes — strongest documented text; 14-day pre-lock delay | **Ruled: anchor** |
| **Backblaze B2** | yes — compliance mode documented as unremovable *by Backblaze support*, explicitly as an anti-social-engineering control | **Ruled: mirror** |
| **AWS S3** | yes — but shares the primary's vendor and account-loss event | Excluded from anchor by ruling, not by capability |
| **Azure Blob** | yes — Cohasset-validated | Viable alternate anchor |
| **GCS** | yes in substance — irreversible policy, project lien | Viable alternate anchor |
| **Wasabi** | asserted against SEC 17a-4(f), vendor-sourced | Behind Backblaze on evidence quality alone |
| **Cloudflare R2** | **no — bucket locks are administrator-modifiable** | **Fails D3 outright.** The only hard capability elimination in this document |

### Tier 7 — excluded by prior ruling, listed so they are not rediscovered

**Spanner, CockroachDB, YugabyteDB.** Distributed SQL was litigated and rejected
in D1. Not reopened here. D1's switch-triggers govern.

---

## 2. Why not Supabase — the long form

Supabase is the strongest PaaS candidate and the elimination deserves more than
a line. It is Postgres — real Postgres, not a fork — with SOC 2, HIPAA and GDPR
posture, cross-region read replicas, PITR, and enterprise failover. Nothing
about it is unserious.

It fails on three gates, in descending order of how hard they are to argue with:

**G2 — no acknowledgment-gating control.** Read replicas are asynchronous.
Enterprise failover is failover: it decides what happens *after* loss, not
whether a write is acknowledged before it is durable elsewhere. Grain's D1
obligation is upstream of failover — an attestation must not be acknowledged
until it is durable across failure domains, because "zero loss of acknowledged
attestations" is a **contractual promise to attesting parties** (decision 005),
not an availability target. Nothing in Supabase's platform refuses a commit.

**G7 — the deletion saga crosses a boundary Grain does not control.** Decisions
009, 013 and 038 make deletion a hard, worker-controlled obligation, and D1's
own reasoning notes that erasure must reach CDC topics, indexes, lakehouse and
backups that no database's transactional domain covers. On Supabase's managed
platform, several of those live inside Supabase's AWS account, on Supabase's
backup schedule, under Supabase's retention defaults. Grain would be making a
deletion promise it cannot fully audit. Self-hosting Supabase moves the boundary
back but forfeits the managed guarantee that satisfies G1 — it is 7+ services
to operate, which is the opposite of what a three-person team should take on.
Supabase does not offer a first-party BYOC tier that resolves this; the BYOC
options in the market are third-party or self-managed.

**G8 — it is a platform, and Grain needs a database.** Supabase's value is the
bundle: auth, storage, edge functions, realtime. Grain already has ratified
answers for auth (D4 key custody), for storage (D3 WORM), and for its surfaces
(D2). Adopting the bundle means either not using most of it, or letting it
compete with ratified decisions. The bundle is the product; buying it for the
Postgres alone is paying an integration surface for a component available
without one.

**What would change this:** if G2 is re-read as an application-level obligation
with no engine backstop required (switch-trigger 2 in the verdict), Supabase's
G2 failure becomes moot and only G7 remains — and G7 is arguable. Supabase
should be reconsidered in that branch, alongside Aiven.

## 3. Correction to the verdict — G2's scope was overstated

`d5-verdict.md` says `rds.global_db_rpo` is "the only commit-gating
cross-region durability control in the managed-Postgres market." **Cross-region,
that holds. Unqualified, it does not.**

PlanetScale Postgres runs semi-synchronous replication always-on: a write is
acknowledged only once it has reached stable storage in **two availability
zones**. That is an acknowledgment-gating durability control. It is cross-AZ
rather than cross-region, and PlanetScale fails G3, G4 and G5 independently, so
the ruling does not change. But the *reasoning* was stated too broadly, and the
gap it exposes is real:

**D1 says "durable across failure domains" and never says whether an AZ is
one.** Under the AZ reading, the field is wider than the verdict presents —
PlanetScale qualifies on G2, and Aurora's advantage narrows to a difference of
degree. Under the cross-region reading, the verdict stands as written.

This is a founder call, it was not made, and it should be made before
ratification. It is the single interpretation on which the most of this field
turns.

## 4. What was *not* eliminated on capability

Recorded so the ruling is not mistaken for a capability verdict:

- **GCP, Azure and OCI all clear the WORM gate.** Only Cloudflare R2 fails it.
- **Aiven and EDB both clear G7 via BYOC**, which AWS-direct also clears and
  which every PaaS fails.
- **EU sovereign providers hold a CLOUD Act argument** that no ruling here
  disposes of, and that becomes live when the EU plane is ruled.
- **Azure is a complete alternative platform**, not a partial one. It is the
  designated fallback for a reason.
