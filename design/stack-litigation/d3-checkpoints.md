# D3 Brief: Signed WORM Checkpoints at Launch; Tile Log at a Contractual Trigger

Advocate position in the D3 litigation (transparency-log timing), arguing
the boring-pragmatist line as amended below, against security-infra's
day-one Tessera log. Inputs: `convergence-map.md`,
`ledger-design-0.1.md`, `boring-pragmatist.md`, `security-infra.md`, the
other perspective files, and August 2026 web research on Rekor
v2/Tessera and the witness ecosystem.

---

## TLDR

1. **What must ship day one is external anchoring, not the log.**
   Per-stream Merkle/hash chains plus signed checkpoints of the stream
   roots, written at least hourly (target: every 5 minutes) to S3 Object
   Lock in **compliance mode**, in a **separate AWS account with
   independent credentials, mirrored to a second cloud's bucket-lock**,
   with submitting parties given read access to the checkpoint bucket
   and issued signed inclusion receipts. This is a cron job and a bucket
   policy — days of work — and it closes the operator-rewrite threat to
   a sub-checkpoint-interval omission window.
2. **At launch, the day-one log buys zero additional trust.**
   Security-infra's own schedule (§3.3) runs the Tessera log
   *unwitnessed* until first external party or 1M identities; until a
   witness co-signs, a tile log's operator-resistance reduces to exactly
   what its checkpoints anchored outside the blast radius provide —
   which is what WORM anchoring provides directly. D3 at launch is not
   "log vs. no log"; it is Tessera-shaped anchoring vs. S3-shaped
   anchoring, at very different operational prices.
3. **The unfixable-history argument dissolves if anchoring starts day
   one.** A log stood up at the trigger builds its tree over the full
   historical spine and proves its genesis consistent with every
   independently-immutable anchor back to hour zero. The history a late
   log "can never prove" is only history that was never anchored. So
   the argument is decisive against design 0.1's bare "v2 hardening" —
   and inert against this position.
4. **The claimed cheapness of the tile log is Sigstore's cheapness, not
   ours.** Rekor v2 is real and much cheaper than the Trillian era, but
   its entry types are supply-chain-shaped, key distribution assumes a
   TUF repository, shard rotation/freezing and monitoring are recurring
   operator obligations, and non-GCP support was still "actively being
   worked on" at GA. Adopting Tessera as the spine's *append mechanism*
   (security-infra's actual recommendation) puts a custom
   3-person-maintained service on the critical write path, where a log
   incident becomes a ledger write outage.
5. **The witness ecosystem cannot deliver the day-one promise anyway.**
   The operating network is ~15 ArmoredWitness devices under one
   reputational unit (TrustFabric), witnessing public open-source
   ecosystems (Go sumdb, Sigstore, Sigsum, LVFS, Android BT). There is
   no evidence a private commercial career ledger can purchase
   witnessing today; the network's own writeup names policy/update
   handling and concentration as open problems.
6. **Trigger, specified contractually now:** the full tile log with at
   least one independent witness must be live before the first external
   attesting party reaches `active` in the registry, or before 1M
   identities, whichever comes first — with genesis-consistency proof
   against the anchor set as a named deliverable. Sophisticated external
   verifiers are the only audience to whom the log's extra assurance is
   legible; they arrive with external parties; the log arrives with
   them.

---

## 1. The steelman: security-infra's case at full strength

State it properly before touching it.

**The operator threat is present from day one and the hash chain is
worthless against it.** Design 0.1 §3.3 builds a chain in the operator's
own database and defers Merkle/public commitments to "v2." A chain the
operator holds is a chain the operator can rewrite wholesale — a
compromised admin, a poisoned deploy, an engineer under coercion
re-hashes history and nothing detects it. The product's single asset is
"this record was never altered"; a control that only defends against
outsiders defends against nobody who matters, because the operator *is*
the highest-capability adversary in the system. The most dangerous
window is precisely the early one, when no external scrutiny exists and
the team is three people with no dual control.

**The unfixable-history argument.** A transparency log started at launch
covers everything; one started after an incident — or after a partner
demands it — proves only the future. The gap is permanent. "Our log
covers everything since the first attestation" is worth real money in
every partner negotiation forever, and you cannot buy it later at any
price.

**The cost objection expired.** Rekor v2 went GA in October 2025 on
tile-based Tessera: object-storage-backed, CDN-cacheable reads, built
explicitly for low-cost minimal-maintenance private deployment. If the
log now costs roughly what a queue costs, deferral is pure risk with no
offsetting saving.

This is a serious case, and against design 0.1 *as written* it wins:
"hash chain in our own Postgres now, hardening later" is indefensible.
The position defended here is not design 0.1's deferral. It is the
pragmatist's §4 checkpoint architecture, hardened, with the log staged
at a defined trigger.

## 2. Attack-window analysis: what WORM anchoring proves, and against whom

### 2.1 The day-one mechanism

- Per-stream chains (per-subject, per-party) — the convergence map's
  settled item 6 — with every event carrying `prev_stream_hash`.
- A checkpoint job every interval T builds a Merkle root over all
  advanced stream heads, includes the previous checkpoint hash
  (checkpoints are themselves a chain), signs with a KMS-held key
  chained to the offline root, and writes the checkpoint object to:
  (a) S3 Object Lock, **compliance mode**, multi-year retention, in a
  **dedicated AWS account** whose credentials the production
  environment does not hold write-beyond-append access to; and
  (b) a second cloud's equivalent (GCS bucket lock).
- Ingestion returns a signed receipt to the submitting party: entry
  hash, stream position, and a promise of inclusion in a checkpoint
  within T — the SCT analog. Parties (and anyone the operator chooses to
  give the URL) can read the checkpoint buckets directly.
- A continuous reconciliation job re-derives recent roots from the
  database and compares against the anchored objects; divergence is the
  tamper alarm (the same alarm security-infra specifies for
  log-vs-Postgres reconciliation).

### 2.2 Walk the rewrite

Adversary: the operator itself — admin credentials, deploy pipeline,
database superuser. Goal: alter or excise attested history silently.

**History older than the last anchored checkpoint.** Any modification
changes a stream head, which changes every subsequent Merkle root. The
anchored roots cannot be altered: compliance mode blocks overwrite and
deletion by every principal *including the AWS root user* until
retention expires. To rewrite undetectably the operator must produce a
new checkpoint sequence — but the old one is still sitting in two
clouds, readable by parties, and any verifier holding a receipt or a
prior checkpoint can demand a consistency proof the forged history
cannot supply. Two inconsistent checkpoints signed by the same key are
not a suspicion; they are portable cryptographic proof of fraud.
**Result: no silent rewrite of anchored history exists.** The residual
escape is closing the AWS account itself (the only way to defeat
compliance mode) — an action that is loud, slow (~90-day
post-closure window), and defeated by the second-cloud mirror; it
destroys evidence rather than forging history, and its occurrence is
itself damning. This is why "separate account, second cloud" is part of
the position, not gold-plating.

**The window.** What remains is history younger than the last anchor: an
insider can drop or reorder an entry received minutes ago before it is
ever checkpointed. Three observations size this honestly:

1. The window is ≤ T, and T is a config knob whose cost is one small
   object PUT per interval — run it at 5 minutes, not an hour, for
   pennies.
2. Omission is detectable by the injured party: they hold a signed
   receipt whose inclusion promise the next checkpoint fails to honor.
   Detection requires the party to check — a real limitation, conceded
   in §5.
3. **A day-one Tessera log has the same window.** Its durability against
   the operator is its checkpoint, and until a checkpoint is (a) written
   somewhere the operator cannot reach and (b) ideally co-signed by a
   witness, entries can be dropped pre-checkpoint and unwitnessed
   checkpoints can be forked. Security-infra's launch schedule mirrors
   checkpoints "to a second cloud account" — the identical mechanism
   argued here. The log narrows nothing at launch; witnesses narrow it,
   and witnesses come later on *both* plans.

**Split-view.** Can the operator show party A and party B different
histories? Only by publishing forked checkpoints. Forked checkpoints
both land immutably in the WORM buckets (or one fork is withheld from
the bucket — detectable by any reader as a missing interval in the
checkpoint chain, since each checkpoint names its predecessor). This is
the same split-view posture an unwitnessed CT log has; full split-view
immunity requires witness quorums in either architecture.

### 2.3 Does unfixable-history survive?

The argument's force is real only for **unanchored** history. Under this
position there is none: every spine entry is covered by an anchored root
within minutes of ingestion, from the first attestation ever written.
When the tile log is stood up at the trigger, its genesis is not a cold
start — see §4.2 — and the sentence security-infra prices ("our log
covers everything since the first attestation") remains true, with
"log" meaning the anchored commitment structure whose serving format
upgraded. What is genuinely lost relative to day-one Tessera: nothing
cryptographic; only the convenience of never running a migration.

## 3. Costing interrogation: is the tile log actually queue-cheap?

The 2026 facts, checked:

**What got cheap.** Rekor v2 GA (Oct 2025) replaced Trillian's log
server + signer + MySQL with Tessera tiles on object storage; reads are
immutable, content-addressed, CDN-cacheable; storage backends are GCP,
AWS, MySQL, POSIX. The Sigstore blog's cost claims are about storage,
infra, and egress — all true, all real. The public instance runs at a
99.5% SLO.

**What did not get cheap — the operator obligations that remain:**

- **Shard lifecycle.** The v2 model is explicit per-year shards
  (`logYEAR-rev`): the operator must "periodically rotate the log
  instance" and "freeze the previous log instance shortly afterwards."
  That is an annual ceremony with client-visible URL and key changes,
  forever.
- **Key distribution.** Sigstore distributes per-shard public keys via
  its TUF repository. A private deployment either runs TUF as well or
  invents its own key-distribution discipline — a second trust system
  next to the registry we already operate.
- **Monitoring.** Tamper-evidence you never check is decoration
  (log-centric's phrase); the recommended answer is running
  rekor-monitor or equivalent, continuously, as another service.
- **Entry-model mismatch.** rekor-tiles entry types are software-supply-
  chain shapes (hashedrekord/DSSE). Security-infra's own recommendation
  acknowledges this: evaluate rekor-tiles, and if the entry model
  doesn't fit, run "Tessera-on-GCS/S3 with our own entry schema" — i.e.,
  a bespoke log personality, written and maintained by a 3-person team,
  and (per the same recommendation) adopted "as the spine's append
  mechanism."
- **Failure-domain placement.** That last clause is the expensive one.
  If the log is the append mechanism, the log's availability is the
  ledger's write availability. A Tessera integration bug, a tile-storage
  incident, an antispam/dedup edge case, a botched shard rotation — each
  is a production write outage *and* a public incident in the integrity
  story itself, during exactly the years when there is no one to page
  and no SRE bench. Sigstore absorbs this class of incident with a
  dedicated team and a community; we absorb it with three people.
  Under checkpoint-to-WORM, the analogous failure (anchor job down) is
  an alarmed degradation of tamper-evidence freshness for its duration —
  writes continue, and the per-stream chains still bind everything
  written for retroactive anchoring when the job resumes.
- **The GCP gravity.** Tessera's maturity is GCP-first; at GA, other
  cloud support was "actively" in progress. The pragmatist stack (and
  D1's likely outcome) is AWS. Running the trust-critical component on
  its second-best-supported backend, or splitting clouds for it, are
  both real costs the "queue-cheap" framing omits.

**Honest ops-hours estimate.** WORM checkpointing: days to build, near-
zero marginal (a scheduled job, two bucket policies, a reconciliation
alarm — all inside the skill set the team already needs for backups).
Tessera-with-custom-personality on the write path: weeks to stand up
credibly, plus a permanent surface (shard rotations, key distribution,
monitor, incident response) that is small for an infrastructure
organization and large for this team. The asymmetry is not the AWS
bill; it is whose pager and how many distinct systems can have a sev-1.

**The witness ecosystem, priced.** The day-one log's *distinctive* value
is public witnessing — and that is the part that cannot currently be
bought. The operating network is ~15 ArmoredWitness devices with
trusted custodians, operated under TrustFabric as effectively one
reputational unit, witnessing public ecosystems (Go sumdb, Sigstore,
Sigsum, LVFS, Android Binary Transparency). Onboarding an arbitrary
private commercial log is not an advertised service; the project's own
retrospective names policy/software-update handling and the need for
"more independent reputational units" as open problems. Security-infra
implicitly agrees: its own schedule defers the witness to
first-external-party/1M. A day-one log without a witness is anchoring
with extra steps.

## 4. The sequencing argument, trigger spec, and clean genesis

### 4.1 Who can even read the extra assurance?

An unwitnessed tile log and a WORM anchor chain are distinguishable only
by a verifier who consumes inclusion/consistency proofs — a
sophisticated external auditor, a partner's security team, a regulator's
technical consultant. Workers cannot read either; internal verticals
share the operator's trust domain; and there are no external parties at
launch by definition. The audience for whom the log's format matters
arrives with the first external attesting party. Trust infrastructure
should be staged to the arrival of the party who can verify it —
provided (and only provided) the staging loses no history. §4.3 shows it
loses none.

### 4.2 The trigger, specified contractually

Written into the design record now, so commercial pressure cannot quietly
defer it:

- **Trigger:** the earlier of (a) the first external attesting party's
  registration reaching `pending` (build starts) with the log **live
  before that party's `active` transition** — the registry state machine
  itself enforces the ordering, since activation is a steward-gated
  event; or (b) 1,000,000 registered identities.
- **Deliverables at trigger:** tile log (Tessera-class) carrying the
  three entry families from security-infra §3.2 (attestation
  commitments, registry/key lifecycle events, privileged operations);
  public checkpoint endpoint; at least one independent external witness
  co-signing checkpoints (a named auditor or partner suffices where the
  public network cannot onboard us); the genesis-consistency proof of
  §4.3, published; inclusion receipts upgraded to reference log
  coordinates.
- **Standing obligations from day one that make the trigger cheap:**
  checkpoint format includes stream-head roots, sequence numbers, and
  predecessor hash (already required above); entry canonicalization
  frozen with golden vectors (already a settled convergence item); the
  reconciliation job's verification logic written against the anchor
  set, since it becomes the migration verifier.

### 4.3 Why the migration is clean — the genesis-consistency proof

At the trigger, the log does not start empty and it does not start
blind:

1. Replay the full historical spine (append-only by construction — the
   settled convergence items guarantee the corpus is intact and ordered)
   into the new tile log as its initial entries, in original order.
2. Recompute, from the log's own contents, every historical
   checkpoint-interval root, and verify each equals the corresponding
   WORM-anchored object — every hourly/5-minute root back to hour zero,
   in two clouds, none of which the operator could have altered.
   Additionally append the anchored checkpoint chain itself into the
   log's registry-events family, so the anchors are thereafter
   inclusion-provable.
3. Publish the first witnessed checkpoint over the resulting tree,
   together with the verification transcript.

Any external verifier can now check, without trusting the operator: the
log's genesis commits to a history that is byte-consistent with an
unbroken sequence of independently-immutable commitments contemporaneous
with the events themselves. That is the same epistemic guarantee a
day-one log would offer for the same period — in both cases, the ground
truth for the early era is "commitments that left the operator's control
within minutes of each write." The day-one log's early era is *also*
unwitnessed; its checkpoints mirrored to a second account are the same
species of evidence as our anchors. **This is what kills the
unfixable-history argument in this configuration: lateness only forfeits
history that was never externally committed, and here none is.**

What the migration does not launder, stated plainly: entries dropped
inside a pre-anchor window during the early era are absent from both
the anchors and the reconstructed log, and no migration can conjure
them. The mitigation is the receipt mechanism plus the short interval —
identical to the exposure of the day-one log's pre-checkpoint window.

## 5. Concessions

1. **Security-infra is right against design 0.1 as written.** "Hash
   chain in our own database, Merkle in v2" defends against no adversary
   who matters. If the alternative to the day-one log were design 0.1's
   deferral, I would join the day-one side. My position stands only with
   day-one WORM anchoring as a hard launch requirement — anchoring is
   not deferrable, and this brief should be read as amending the
   pragmatist school to make that explicit and non-negotiable.
2. **A sub-interval omission window exists**, and its detection is
   party-dependent (receipts must be checked). At launch the parties are
   internal verticals inside the operator's trust domain, so during the
   earliest weeks the practical check is the reconciliation alarm, which
   the operator runs — an honest residue of self-trust that only
   witnesses (later, on both plans) fully remove.
3. **Compliance-mode WORM is a cloud-provider promise, not physics.**
   Its known escape (account closure) is slow and loud, and dual-cloud
   mirroring covers it, but a years-premeditated operator conspiracy
   degrades gracefully rather than impossibly. Witness co-signing at the
   trigger is what converts "provably detectable" into "provably
   impossible"; the day-one log without witnesses would not have
   converted it either.
4. **The staged plan carries execution risk the day-one plan does not:**
   a trigger can be slipped under commercial pressure ("the partner
   doesn't care, ship the integration"). The registry-gated trigger
   (§4.2) exists precisely to make slipping it a visible governance
   act rather than a quiet omission — but a governance act can still be
   taken. Day-one construction forecloses that human failure mode; that
   is its one real, non-cryptographic advantage.
5. **If the tile log is adopted anyway for engineering reasons** (e.g.,
   as a favored append mechanism out of D1/D6), the marginal cost of
   day-one drops toward zero and the staging argument loses most of its
   force.

## 6. Conditions under which I flip to day-one

Any one suffices:

1. **First external party expected within ~2 quarters of launch.** The
   trigger fires almost immediately; staging becomes ceremony. Build the
   log before launch and skip the migration.
2. **Witnessing becomes purchasable for private logs before launch** —
   a witness-network-as-a-service or ≥2 independent reputational units
   accepting arbitrary checkpoint-format commercial logs. The day-one
   log would then deliver its distinctive good (public witnessed
   checkpoints) on day one, which anchoring cannot match.
3. **A partner, regulator, or counsel requires launch-time inclusion
   proofs or an offline-verifiable packet format** — the log stops being
   staged trust and becomes a product requirement.
4. **The team cannot commit to the §4.2 contractual trigger with
   registry enforcement.** If the trigger cannot be made binding, the
   execution risk in concession 4 dominates, and paying the day-one ops
   tax is cheaper than an unbounded deferral.
5. **D1/D6 resolve toward infrastructure that already embeds a tiled
   log on the write path** — marginal cost collapse per concession 5.

---

## Sources

- [Rekor v2 GA — cheaper to run, simpler to maintain (Sigstore blog)](https://blog.sigstore.dev/rekor-v2-ga/) — shard rotation/freeze obligations, TUF key distribution, cost-claim scope, non-GCP caveat, 99.5% SLO.
- [sigstore/rekor-tiles — tile-based transparency log](https://github.com/sigstore/rekor-tiles) — entry model, self-hosting posture.
- [Trillian-Tessera storage backends / Rekor v2 announcement](https://blog.sigstore.dev/rekor-v2-alpha/) — GCP/AWS/MySQL/POSIX backend support.
- [Can I Get A Witness (Network)? (transparency.dev blog)](https://blog.transparency.dev/can-i-get-a-witness-network) — 15 ArmoredWitness devices, TrustFabric operation, witnessed-log roster, stated maturity gaps.
- [transparency-dev/armored-witness](https://github.com/transparency-dev/armored-witness) — witness-network scope: public ecosystems (Go sumdb, Sigstore, Sigsum, LVFS, Android BT).
- [Amazon S3 Object Lock (AWS feature page)](https://aws.amazon.com/s3/features/object-lock/) and [Object Lock user guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html) — compliance mode blocks deletion/overwrite by all principals including the account root user.
- [AWS re:Post — compliance-mode deletability](https://repost.aws/questions/QUIYAWBZdLTMimGlM2MIhTUQ/are-objects-under-compliance-mode-with-retention-period-deletable) — account closure as the sole escape; cross-account copy guidance.
- Repo inputs: `design/stack-perspectives/convergence-map.md` (D3 docket, settled items 5–6), `design/ledger-design-0.1.md` §3.3, `design/stack-perspectives/boring-pragmatist.md` §4, `design/stack-perspectives/security-infra.md` §3, `design/stack-perspectives/log-centric.md` §7.
