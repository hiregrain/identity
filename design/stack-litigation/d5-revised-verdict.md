# D5 revised verdict: cloud placement

> **NOT FINAL.** This supersedes the reasoning in `d5-verdict.md`, which rests on
> a claim about `rds.global_db_rpo` that is false. Nothing here is ratified. The
> provisioning gate in `plans/ORDER.md` stays shut.

Docket item D5, opened on founder go 2026-08-19 against the open item in
decisions/LOG.md entry 011, widened from AWS-vs-GCP to the full field on the
same day. Briefs: `d5-single-hyperscaler.md`, `d5-composed-stack.md`,
`d5-candidate-field.md`. First verdict: `d5-verdict.md`. Outside review: one
Codex pass and one clean-context Claude pass, both adversarial, both given the
same self-contained packet.

## What broke

The first verdict ruled AWS on one mechanism. It said `rds.global_db_rpo` was
the only commit-gating cross-region durability control in managed Postgres, and
that its value was failing independently of the application watermark that
carries the party-facing promise.

Both reviewers attacked it. Verified against AWS documentation, they are right
and the claim is wrong.

The parameter "commits the transaction if at least one secondary DB cluster has
an RPO lag time less than the RPO." The commit gates on a secondary's *observed
lag*, not on this transaction reaching another region. Managed failover "doesn't
wait for data to synchronize," the CLI flag is `--allow-data-loss`, and AWS
states both failover methods "can result in a loss of write transaction data
that wasn't replicated to the chosen secondary before the failover event
occurred."

It throttles staleness. It does not make a specific attestation durable. Under
the cross-region reading of D1, it contributes nothing to the ack watermark.

A second finding compounds it. The first verdict eliminated Azure for
documenting an expected RPO up to five minutes, then named Azure the designated
fallback. If the criterion is real, the fallback fails it. If the fallback is
acceptable, the criterion was never a gate. It was a tiebreaker promoted after
the winner was known. That is the signature of reasoning built backward from a
conclusion, and I built it.

## The reframe

D1 carries two watermarks and the first verdict collapsed them into one.

Obligation 1 is the ack watermark. Obligation 2 is the checkpoint-escrow
watermark, and D3 already puts that checkpoint in compliance-mode WORM, on a
second vendor, in a different region, within five minutes.

The cross-region durability mechanism already exists in the ratified design and
it is not the database. The ack watermark has to reach a distinct failure domain
at commit time. The anchor carries everything beyond that.

**Proposed reading of D1: an availability zone is a failure domain for the ack
watermark. The checkpoint escrow carries cross-region durability.**

This resolves the open interpretation from D1's own obligations rather than by
preference, and it is the ruling that decides most of the field.

## What the three candidates do at commit

Verified against vendor documentation, 2026-08-19.

| | Zones | Behaviour before acknowledgment |
|---|---|---|
| Aurora PostgreSQL | 6 copies across 3 AZs | Acked at a 4-of-6 write quorum. Survives an AZ plus one node |
| AlloyDB | Storage across 3 zones | Acked once the WAL persists on regional multi-zone log storage. Every zone holds a complete copy |
| Cloud SQL for PostgreSQL | Regional persistent disk, 2 zones | "All writes made to the primary instance are replicated to disks in both zones before a transaction is reported as committed" |

All three satisfy the cross-AZ reading. Aurora and AlloyDB tolerate more
simultaneous zone loss. Cloud SQL states its commit gate most plainly, in one
sentence a verifier can check, which is what an application watermark needs to
hook onto.

**No durability argument separates AWS from GCP.** That was the whole basis of
the first verdict.

## The ruling

**Primary plane on Google Cloud. Anchor and mirror stay off it.**

| Placement | Ruling | Reason |
|---|---|---|
| Payload databases, global spine | Cloud SQL for PostgreSQL, two instances | Commit gate is documented explicitly and is verifiable. Move payload to AlloyDB if scale demands it |
| Compute | Cloud Run | Smallest operating surface for three engineers with no standing staging environment |
| Object storage | Cloud Storage | |
| Production KMS | Cloud KMS | |
| Compliance-mode WORM anchor | OCI Object Storage, locked retention rules | Must not share a vendor with the primary. See below |
| D3 second-cloud mirror | Backblaze B2, compliance mode | Commercially independent of both |
| Third leg | Publish the checkpoint root where Grain does not pay for it | Roughly a day of work and it buys more independence than the second bucket |

### Why Google Cloud wins now

Four reasons, in order of weight.

**Operating surface.** Cloud Run runs a Go container without task definitions,
service architecture, or load-balancer topology. ECS and Fargate expose all
three. Decision 011 refused a standing staging environment, so every durability
drill runs on infrastructure the team stands up and tears down. That makes
operating surface a first-order cost, not a preference. This was the strongest
argument in the outside GCP proposal and the first verdict gave it no weight,
because it was busy defending a durability claim that turned out to be empty.

**Burn.** Cloud Run scales to zero. Cloud SQL costs a fraction of a multi-region
Aurora global cluster, and the multi-region compute floor disappears entirely
once cross-region stops being the ack mechanism. The first verdict contained no
cost row at all, which both reviewers flagged.

**Decision 017's burden discharged in GCP's favour.** Entry 017 required a GCP
outcome to address the Object Lock equivalence gap explicitly. Addressed: Bucket
Lock is genuine WORM, irreversible once locked, and applies an automatic project
lien that blocks project deletion. It is stronger than this docket expected. It
is also close to moot, since the anchor goes to OCI either way.

**The FIPS row is struck.** The first verdict used AWS KMS holding the only
current FIPS 140-3 Level 3 managed KMS validation as a tiebreak. Two problems.
Marvell LiquidSecurity modules reached FIPS 140-3 Level 3 in June 2024 and
Microsoft integrated them into Azure Managed HSM, so the claim was false.
And no ratified constraint requires that level. Decision 011 says "real KMS in
production." I imported a requirement that does not exist, then selected a
vendor on it.

### What still favours AWS

Training-corpus depth for Terraform and AWS operations. D2 already ratified
agent fluency as a first-class cost, so this is a legitimate argument and not a
throwaway. I cannot quantify it, and I do not think it outweighs a smaller
operating surface and lower burn once the durability argument is gone. Recorded
here so a later reader can weigh it rather than discover it.

### Why the anchor stays off the primary vendor

The justification in the first verdict was wrong and both reviewers said so.

It framed the split as protection against losing the primary account. It is not.
If the primary account dies, the spine and payload die with it, and an
OCI-held checkpoint then proves the integrity of a history Grain no longer
possesses. That is proof continuity, not business continuity, and no vendor
survives its own account termination.

What the split actually buys: **it defends against Grain tampering with Grain's
own ledger.** That is the threat a worker-owned record has to answer, and it is
the one threat a single-vendor posture genuinely fails. Decision 024 holds
neutrality by contract, published rules and audit rather than corporate
separation, so an audit trail the operator can delete is not one.

The corollary the first verdict missed: two buckets Grain pays for still
evaporate if Grain stops paying, and Grain's word is still the only attestation
that the published root is the real root. Publishing the root somewhere Grain
does not control, in party receipts or cross-signed by attesting parties, costs
almost nothing and does more than the second bucket. The witnessed tile log is
deferred post-launch under D3. This is the cheap stand-in until it exists.

## Two questions that outrank the vendor choice

Both reviewers raised both, independently, and neither was asked about them.

**1. Are checkpoint leaves person-linkable?** D3 makes checkpoints permanently
undeletable. Deletion has to be provable, with nothing keyed to the person
surviving anywhere. If a Merkle leaf, a salt, or an inclusion path is derivable
from a person, those two ratified constraints contradict each other permanently
and there is no remedy after the lock. The standard fix is a per-record random
salt held in the deletable payload plane, so destroying the salt makes the leaf
unlinkable. That has to be ratified before the first retention rule locks. OCI's
mandatory 14-day pre-lock delay is the only window and it happens once.

Decision 005 already lists "counsel blessing of the salted-commitment posture
before checkpoints go public" in the founder-call register, so the checkpoint
case was anticipated. The blast radius is wider: mirrors, authentication events,
KMS logs and the pseudonym table are all downstream of the same question, and
none of them are specified.

**2. Do attesting parties and workers hold their own signed copies?** If not,
the whole integrity apparatus is Grain proving things to Grain, and the WORM
spend buys a story rather than a guarantee. If they do, an OCI checkpoint
becomes a real reconstruction path and the anchor is worth several times what it
costs. This may be answered elsewhere in `model/`. It is not answered here.

## Authentication and the identity provider

Recorded here because the outside reviews covered them in the same pass.

**Authentication is a library inside the Go core, not a platform.**
`go-webauthn/webauthn` for the ceremony, vendored and pinned. Buy one-time-code
delivery. Build sessions, revocation, the step-up matrix and event recording,
because none of it can be bought: `person-identity/02` gates step-up on the
account's derived assurance level, binds sessions to a `ledger_person_id` that
survives merge and unmerge through an alias closure, and requires proving that
deletion leaves nothing behind. No CIAM vendor exposes any of that, and putting
user records in a vendor database makes the deletion criterion unprovable.

`go-webauthn` is v0.17.4 and pre-v1, so breaking changes can land without
warning. Pin it exactly, the way decision 040 pins Expo.

**On "Continue with Grain," both reviewers disagree with the founder ruling and
both had the criterion-5 rationale in front of them.** Their position: build the
pairwise pseudonym table on day one, hand Dispatch a first-party session against
it, and add OIDC when relying party number two has a name. Their reason: Hydra
brings OAuth correctness, client registration, consent flows, token rotation,
key management and a security review before the first vertical can log in, for
exactly one relying party that Grain owns. Hydra also brings a second
person-keyed store holding consent sessions, grants and refresh tokens, which is
the same objection that eliminated Kratos and was not applied to Hydra.

One further finding worth the founder's attention. Hydra's pairwise
implementation is a deterministic salted hash of subject plus sector identifier
plus one configured global salt, not a stored table. Correlation resistance then
rests on the secrecy of a single salt. Compromise of that salt plus a
`ledger_person_id` de-anonymises that person at every relying party,
retroactively and permanently. Rotating the salt breaks every relying party's
subject identifier at once. A stored random pseudonym has neither failure mode.
The roster firewall is a ratified constraint, so this matters.

My reading, offered against the ruling rather than around it: the privileged
path criterion 5 forbids is a privileged *identifier*, not a privileged
*transport*. If Dispatch never sees a `ledger_person_id` and draws its pseudonym
from the same table an external partner would, the firewall is real from hour
zero and the part that cannot be retrofitted is done. Adding OIDC later changes
the wire protocol, not the identity semantics. Whether "no privileged path"
means the protocol or the identifier is the founder's call and should be
written down either way.

## What would flip this ruling

**Ruling the failure domain cross-region.** Then no managed Postgres from either
hyperscaler qualifies, and the requirement becomes `synchronous_standby_names`
with `remote_write` or `remote_apply` against a cross-region standby. That is a
real commit-gating control and Aurora is the one architecture that withholds it,
because Aurora replicates at the storage layer and exposes no synchronous
cross-region primitive. Under that reading the field points at providers that
expose the GUC, which means Aiven, EDB or self-managed, not AWS and not GCP.
Both of the eliminations in the first verdict used the wrong test.

**A durability game-day showing the application watermark is insufficient
standalone.** Then the engine matters again and the comparison reruns.

**Any account-level enforcement, suspension or billing termination at any placed
vendor.** Immediate re-litigation of that placement.

**A compliance-mode unlock incident at OCI or Backblaze.** Re-place the anchor
or mirror.

## Founder calls

1. **Rule the failure domain.** One sentence. It decides the vendor, the cost,
   and half the candidate field. Nothing should be ratified before it.
2. **Rule checkpoint leaf linkability** before any retention rule locks.
   Fourteen days, once, no remedy.
3. **Rule whether "no privileged path" means the protocol or the identifier.**
   It decides whether Hydra is day-one work or partner-two work.
4. **Decide whether to accept this verdict or rerun the comparison.** The
   disciplined move is to rerun it against the corrected criterion. I have now
   changed position twice, which is itself evidence that a third confident swing
   from the same author is worth less than a clean-context pass.

## Provenance and confidence

The first verdict and both advocate briefs were written in one context, which
already fell short of the independence D1 through D4 had. The two outside
reviews are the correction, and they found the error that one-context authorship
produced.

High confidence: the `rds.global_db_rpo` claim is false, the FIPS row does not
belong in the decision, no durability argument separates AWS from GCP under the
cross-AZ reading, and the anchor belongs off the primary vendor for a different
reason than the first verdict gave.

Lower confidence: Cloud SQL over AlloyDB, and the size of the agent-fluency cost
of leaving AWS. Both deserve argument before ratification.

Unresolved and load-bearing: the failure-domain reading, checkpoint leaf
linkability, and whether parties and workers hold independently verifiable
copies of their own attestations.

## Evidence

Vendor documentation and NIST CMVP, retrieved 2026-08-19. Aurora global database
disaster recovery and the `rds.global_db_rpo` parameter description; Aurora
storage and quorum; AlloyDB cross-region replication and storage architecture;
Cloud SQL high availability with regional persistent disk; Cloud Storage Bucket
Lock and Object Retention Lock; Azure Database for PostgreSQL geo-replication
and immutable blob storage; OCI Object Storage retention rules; S3 Object Lock;
Backblaze B2 Object Lock; Cloudflare R2 bucket locks; CMVP certificate 4884;
Marvell and Microsoft FIPS 140-3 Level 3 HSM integration; AWS European Sovereign
Cloud launch, 15 January 2026; `go-webauthn/webauthn` v0.17.4; Ory Hydra subject
anonymisation.

Secondary and treated as such: managed-Postgres comparison write-ups, the Wasabi
SEC 17a-4 self-assessment, and Philippines and India data-protection commentary
from Baker McKenzie, DLA Piper and Indian firms. The PH and India findings are
law-firm commentary and not counsel advice to Grain. The residency opinion
commissioned under decision 005 was scoped on an assumption this docket did not
verify, and the scope should be restated as a transfer question for both
jurisdictions before it goes out.
