# D5 Advocate Brief: One Hyperscaler as the Primary Platform (AWS)

Advocate for concentrating Grain's primary platform, namely payload databases,
global spine, compute, KMS, and the compliance-mode WORM account, on a single
hyperscaler, and for that hyperscaler being AWS. The opposing brief
(`d5-composed-stack.md`) is engaged at its strongest form: that concentrating a
neutrality-claiming ledger on one US hyperscaler is a governance failure, not
merely an availability one.

Scope note: decision 011 framed this gate as AWS-vs-GCP. The founder widened it
on 2026-08-19 to full candidate coverage. This brief therefore argues the
general form (single primary platform) before arguing the specific (AWS).

Operating facts: founder + 2 engineers, AI-build-heavy. Ratified constraints
this brief may not relitigate are D1 managed Postgres, D2 Go core, D3 day-one
WORM-anchored checkpoints with a second-cloud mirror, D4 party-held registry
keys with hosted worker/peer keys, and decision 011's physical spine/payload
split and real-KMS-in-production rule.

---

## The verdict argued for, in brief

**Adopt AWS as the primary platform, and adopt the opposing brief's decomposition
while rejecting its conclusion.** The composed-stack brief is right that this
decision is four decisions, namely primary database, WORM anchor, mirror, and
key custody, and right that they are separable. It is wrong that separating them is free. The
separation has a price paid in exactly the currency this team has least of:
operator attention across vendor boundaries, at a company with three engineers
and a launch-blocking durability obligation.

Four arguments carry it:

1. **The ack-watermark obligation has exactly one managed backstop primitive in
   the market, and it is Aurora's.** D1 named `rds.global_db_rpo` as the
   backstop. Research confirms it is a *transaction-blocking* control: Aurora
   commits only if at least one secondary is within the RPO window, and pauses
   writes on the primary when all secondaries fall behind. No other managed
   Postgres offers a commit-gating cross-region durability knob. AlloyDB's
   cross-region replication is asynchronous, with RPO-0 guaranteed only on
   *planned switchover*, which is not the failure case. Azure Flexible
   Server documents an expected RPO of up to five minutes, and "close to the
   replication lag" under severe regional failure.
2. **Compliance-mode WORM that survives the operator is a two-vendor market at
   the top tier.** S3 Object Lock in compliance mode cannot be deleted by any
   principal including the account root; the only documented escape is deleting
   the AWS account itself. Azure's locked time-based retention is
   Cohasset-validated against SEC 17a-4(f). GCS Bucket Lock is real WORM and
   places an automatic project lien, but Google's own documentation does not
   state the root/organization-admin case as flatly, which is the exact form of
   the gap decision 017 required a GCP outcome to address rather than pass over.
3. **Key custody is where certification actually differs.** AWS KMS HSMs hold a
   current FIPS 140-3 Security Level 3 validation (NIST CMVP certificate #4884,
   February 2025). Azure Managed HSM and Google Cloud HSM remain at FIPS 140-2
   Level 3. D2's dispositive reasoning already leaned on Go's *actual* FIPS
   140-3 certificate rather than a claim of equivalence; applying the same
   standard to key custody points the same way.
4. **The residency roadmap does not force a multi-vendor footprint, because it
   never was a localization roadmap.** Neither the Philippines nor India
   mandates in-country storage: the Philippines DPA regulates cross-border
   transfer without a localization rule, and India's DPDP framework uses a
   negative-list regime under Section 16 rather than a residency mandate. The EU
   is the one structurally binding case, and AWS closed it on 15 January 2026
   with the general availability of the European Sovereign Cloud in Brandenburg.
   This is an EU-operated, EU-staffed, logically separate cloud, expanding to
   sovereign Local Zones in Belgium, the Netherlands and Portugal.

---

## 1. The opposing brief's strongest argument, stated at full strength

The composed-stack case is not "avoid lock-in." It is this:

> Grain's product claim is that a worker's record survives the parties that
> observed it. A record layer that is free to everyone permanently, and that
> claims neutrality maintained by contract, published rules and audit rather
> than corporate separation (decision 024), has already accepted that its
> guarantees are institutional rather than structural. Concentrating the
> ledger, its anchor, and its keys inside one US hyperscaler makes the weakest
> guarantee in the design weaker still: it adds a single commercial party who
> can, by terminating an account, end the record. The mirror requirement in D3
> is an admission of exactly this. If one vendor can end the ledger, the
> "portable, worker-owned" claim is doing work the infrastructure does not
> support.

This is the strongest form and it is substantially correct. It is answered, not
dismissed, in §4.

## 2. Why the ack watermark is the load-bearing argument

D1's first launch-blocking obligation is that no attestation is acknowledged
until it is durable across failure domains. The party-facing promise ratified in
decision 005 is "zero loss of acknowledged attestations."

The honest form of the market position is this, and the opposing brief will
press it, so it is stated first: **no managed Postgres product delivers
cross-region RPO-zero automatically.** `rds.global_db_rpo` accepts values from
20 seconds upward. It cannot be set to zero. The real watermark is and always
was application-level, exactly as D1's own text says ("as the backstop,
tightened"). A reader who stops there concludes the primitive is not
discriminating.

That conclusion is wrong for one reason: **the backstop and the watermark fail
differently.** The application watermark is code this team writes, in a
three-engineer shop, on the path that produces the contractual promise. Its
failure mode is a logic bug that acknowledges early and is invisible until an
outage. Aurora's parameter is a database-enforced commit block: when the
watermark code is wrong, the engine still refuses the commit. On AlloyDB or
Azure Flexible Server there is no second line, because asynchronous replication will
acknowledge locally whatever the application asks it to, and the only thing
standing between a watermark bug and a broken contractual promise is the
watermark code that has the bug. For a launch-blocking obligation carrying a
party-facing contractual promise, a defense-in-depth primitive that exists in
one vendor and nowhere else is a legitimate reason to choose that vendor.

**Switch-trigger:** if a competing managed Postgres ships a commit-gating
cross-region durability control, or if D1's ack watermark is re-verified as
fully sufficient without a database-level backstop (a durability game-day
result, per decision 011's ephemeral-drill ruling), this argument expires and
D5 should be re-litigated.

## 3. Why the anchor decides more than the database

D3 makes checkpoint immutability launch-blocking, in a dedicated
compliance-mode object-lock account. The requirement is not "retention"; it is
that **the operator cannot destroy the record of what the operator published.**
Grain's whole posture rests on it: the neutrality claim in decision 024 is
audit-based, and an audit trail the operator can delete is not one.

The market sorts sharply against that test:

| Candidate | Compliance-grade WORM | Survives the operator? |
|---|---|---|
| AWS S3 Object Lock, compliance mode | yes | yes, not deletable by root; documented escape is deleting the account |
| Azure Blob locked time-based retention | yes, Cohasset-validated vs SEC 17a-4(f) | yes, policy cannot be deleted once locked; interval extendable up to five times, never shortenable |
| OCI Object Storage locked retention rules | yes | yes, Oracle's docs state neither a tenancy administrator nor Oracle Support can delete a locked rule; 14-day mandatory delay before lock takes effect |
| GCS Bucket Lock / Object Retention Lock | yes in substance | partial, policy is irreversible and a project lien blocks project deletion, but the root/org-admin case is not stated as flatly as AWS states it |
| Backblaze B2 Object Lock, compliance mode | yes | yes, Backblaze support documented as unable to unlock, explicitly as an anti-social-engineering control |
| Wasabi object lock | yes, asserted against SEC 17a-4(f) | asserted, vendor-sourced |
| Cloudflare R2 bucket locks | no | **no, modifiable by administrators.** Fails D3 outright |

Two consequences. First, R2 is eliminated for the anchor, whatever its other
merits. Second, and this is the concession that matters, **the anchor does not
have to live with the primary.** That is the opposing brief's best structural
point and it is conceded in §4.

## 4. The concession, and why it does not change the ruling

The composed-stack brief is granted three things outright:

- **The mirror is already multi-vendor and should be maximally independent.**
  D3 requires a second-cloud mirror. Putting it on Backblaze B2 in compliance
  mode, a vendor with no commercial relationship to the primary, whose support
  organization is documented as unable to unlock compliance-mode objects, is
  strictly better than mirroring AWS to GCP, and materially cheaper. This brief
  adopts it.
- **The anchor account should be a separate legal and billing boundary**, not
  merely a separate AWS account, precisely because the documented escape hatch
  for S3 compliance mode is account deletion.
- **Nothing about D5 should make the payload plane un-relocatable.** D1 already
  bought that optionality with schema discipline and `residency_region` in the
  payload primary key. It must survive D5.

What the concessions do not reach is the primary plane. Grain's differentiated
risk is not vendor concentration; it is a three-person team owing a
zero-acknowledged-loss contractual promise, a deterministic mark system, and a
deletion path that must reach CDC, indexes, lakehouse and backups. Every vendor
boundary added to the primary plane is a boundary across which the deletion saga
and the durability watermark must both be reasoned about and drilled, on
ephemeral environments, because decision 011 refused a standing staging
environment. The composed stack pays its independence premium in exactly the
scarce resource, and buys independence for the *database*, which is not the
thing that must survive the operator. The **checkpoint** is that thing, and it
is already independent under the concessions above.

Put plainly: **decentralize the proof, concentrate the plumbing.**

## 5. Candidates eliminated, with the reason

- **Cloudflare R2** fails D3 because its locks are administrator-modifiable.
- **Hetzner, OVH bare metal, Fly.io, Railway, Render** fail D1 (managed
  Postgres with a durability primitive) and the real-KMS rule in decision 011.
  Cost advantage is real and irrelevant to a launch-blocking durability
  obligation.
- **Neon, Supabase, Timescale** fail the ack-watermark obligation: no
  commit-gating cross-region durability control, and the deletion path crosses
  a vendor boundary the operator does not control. Neon's SOC 2 and HIPAA
  posture is not the constraint that binds here.
- **Crunchy Bridge** has real Postgres-specialist quality, but it was acquired
  by Snowflake in 2025. A record layer that must survive commercial events
  should not put its system of record inside a recently-acquired product whose
  roadmap now serves a data-warehouse strategy.
- **EDB (BigAnimal / Postgres AI Cloud)** is the most serious specialist
  candidate: it runs in the customer's own AWS or Azure account, so it does not
  add a data-custody boundary. Rejected on the same primitive test, since it
  inherits the underlying cloud's replication rather than a commit-gating RPO
  control, and on agent-fluency grounds identical to D2's reasoning: the
  training corpus for Aurora operations is an order of magnitude larger.
- **IBM Cloud** has no argument that survives contact with the region roadmap.
- **Alibaba** is a non-starter for US employment-adjacent personal data.
- **OCI** is not eliminated. See §6, the genuine surprise of this docket.
- **Azure** is the strongest runner-up. See §6.

## 6. The two candidates that are not eliminated, and why AWS still wins

**Azure** clears every hard gate: locked immutable blob storage with a Cohasset
assessment against SEC 17a-4(f), a Managed HSM at FIPS 140-2 Level 3, and
Flexible Server as managed Postgres. It loses on one thing, the ack watermark.
An expected RPO of up to five minutes, degrading to replication lag under severe
regional failure, is not a backstop for a zero-acknowledged-loss promise; it is
the thing the promise is defending against.

**OCI** has the strongest WORM text of any candidate. Oracle documents that
neither a tenancy administrator nor Oracle Support can delete a locked retention
rule, which is a stronger statement than Google's and as strong as Amazon's, with
a 14-day pre-lock testing window that is genuinely well-designed for a
three-person team that will get the retention parameters wrong on the first try.
It loses on the primary-plane test for the same reason as Azure, and on
agent-fluency: the corpus for OCI operations is thin, and D2 already ruled that
agent fluency is a first-class cost at this team size.

**AWS wins on the conjunction**, not on any single axis: the only commit-gating
durability backstop, the strongest stated root-proof WORM, the only current FIPS
140-3 Level 3 managed KMS, and, since 15 January 2026, an EU-sovereign answer
that does not require adopting a second vendor to serve the one jurisdiction
that structurally binds.

## 7. Measurable switch-triggers

D5 should be re-litigated, without further argument, on any of:

1. A competing managed Postgres ships a commit-gating cross-region durability
   control (kills §2).
2. A durability game-day demonstrates the application ack watermark is
   sufficient standalone, twice, on ephemeral environments (kills §2 the other
   way, and would re-open the whole field, including EDB and Azure).
3. AWS's KMS FIPS 140-3 certificate (#4884) is not renewed past its
   **11/17/2026 sunset date** and no successor validation is issued (kills §3;
   this is a dated fact and must be re-checked before ratification, not after).
4. Counsel's residency opinion returns a *localization* finding, not a transfer
   finding, for India or the Philippines (re-opens §4 and forces a regional
   vendor question this brief has ruled out).
5. AWS European Sovereign Cloud fails to ship a managed Postgres with the
   Aurora global primitive, or its Local Zone expansion slips past the first EU
   cohort (splits the EU plane onto a second vendor and re-opens the ruling).
6. Any account-level enforcement action, billing termination, or sanctions
   exposure affecting Grain's AWS accounts (immediate re-litigation; this is the
   opposing brief's scenario materializing).
