# D3 Advocate Brief: The Transparency Log Ships Day One

Litigation position on convergence-map D3. Advocate for: **a real CT-style
Merkle transparency log (tile-based, object-storage-backed,
Rekor-v2/Tessera-class) ships day one**, with public witnessed checkpoints
no later than the first external attesting party or 1M identities.
Argued against: (a) the boring-pragmatist's hourly-Merkle-checkpoints-to-WORM-S3
position (`stack-perspectives/boring-pragmatist.md` §4), and (b)
`ledger-design-0.1.md` §3.3's "CT-style public commitment log is the v2
hardening, not v1." School: `stack-perspectives/security-infra.md` §3.
Web research current to August 2026; sources at end.

---

## TLDR

1. **The product is a single sentence, "this record was really made, by
   that party, at that time, and was never altered", and neither opposing
   architecture can prove that sentence against the people most able to
   falsify it.** A hash chain proves ordering to the operator's own
   database. Hourly checkpoints to WORM S3 add coarse tamper-*evidence*
   that only the operator can generate, only the operator can verify, and
   no outsider can consume. Against the four realistic history-rewriting
   actors, namely the operator itself, an insider with DB access, a poisoned
   CI/CD pipeline, and a compromised cloud account, the chain-plus-checkpoint
   architecture fails at least partially in every row of the table in §3.

2. **One failure is unfixable by any later investment: a log started at
   year 2 can never prove year 0–2 history.** The gap is permanent, and it
   lands exactly when the company can least afford it, namely the first
   major dispute, the first partner audit, and the first regulator
   inquiry, each of which asks about the *early* record, because early
   records are the oldest and most contested. "Our log covers everything since the first
   attestation" is a sentence that can only be bought on day one, at day-one
   prices.

3. **The 2026 cost facts support day one.** Tessera is production-ready
   (v0.2.0+; GCP, AWS, and POSIX drivers all production-grade), is a
   library with "no additional services to manage," and Rekor v2
   (rekor-tiles), built on it, GA since October 2025, running Sigstore's
   public instance at a 99.5% SLA, was explicitly designed for "low cost
   and minimal maintenance" self-hosting. Honest estimate for this team:
   **1–3 engineer-weeks of integration, single-digit hours/month steady
   state, tens of dollars/month of infrastructure** at our write rates
   (0.2/s launch, <500/s at year 2). That is more than the pragmatist's
   afternoon of WORM checkpoints, conceded, but it is bounded, one-time,
   and buys the only control that addresses operator-class threats.

4. **The witness ecosystem is honestly immature, which is why the position
   phases witnessing rather than demanding it day one.** ~15 ArmoredWitness
   devices exist, with TrustFabric as effectively the sole reputational
   backer; the C2SP tlog-witness protocol is real but onboarding an
   arbitrary private log is a bilateral arrangement, not a self-serve
   utility. Day one therefore uses the cheapest outside-the-blast-radius
   witness (second-cloud checkpoint mirror, independent credentials,
   adopting the pragmatist's own WORM mechanism as the *mirror*, where it
   belongs); a real cosigning witness is contracted by the
   first-external-party/1M milestone.

5. **Deletion compatibility is solved, not hand-waved:** log leaves carry
   salted commitments (HMAC with a per-record key held in the erasable
   payload plane), never bare hashes. R2 deletion destroys the salt with
   the payload; the retained leaf becomes an unlinkable random value, the
   tree stays intact, everyone else's inclusion proofs are unaffected.
   Counsel blesses the posture; the architecture is the strongest
   technically available.

6. **Concession and ruling aid:** if the founder can accept that the
   integrity of the year-0–2 record is permanently "trust us", meaning that
   the early adopters' careers are a discardable pilot rather than the seed
   asset, then defer-to-v2 is safe and cheaper. The founder thesis says
   the opposite. §7 states the full concession list and the only
   configurations under which the opposition's positions become adequate.

---

## 1. Steelman of the opposition

The court should hear the strongest versions, because both are serious.

**The boring-pragmatist (hourly Merkle checkpoints → WORM S3).** The
pragmatist's crypto section is not naive: Ed25519/JWS via libsodium, a
serialized hash chain, hourly Merkle roots signed by a KMS key, written to
S3 Object Lock in compliance mode, "optionally to a second cloud's bucket."
Genuinely cheap, costing dollars a month, an afternoon of code, a few hundred
lines auditable by one person, which matches the team's real crypto-review
capacity. It covers the retroactive-rewrite threat at coarse granularity:
compliance-mode WORM objects cannot be deleted even by the account root, so
old checkpoints survive a later rewrite, and a diligent auditor comparing
retained checkpoints against a re-derived chain could in principle detect
divergence. The pragmatist's deeper argument is that **operational
simplicity dominates at this stage**: the company dies of complexity, not
of unproven integrity; every additional system is a failure surface for a
three-person team; and the checkpoint format "preserves the design's
'expose CT-style inclusion proofs later' option without building a
transparency log now."

**Design 0.1 (defer to v2).** The design already builds the hash chain from
day one, specifies that storage "must not preclude later Merkle-tree/
CT-style public inclusion proofs" (`04` TLDR-8), and names the residual
risk honestly: "the ledger operator itself is the single root of trust; a
CT-style public commitment log over registry changes is the v2 hardening."
Its implicit timing argument: no outsider needs proofs before outsiders
exist; the chain plus checkpoints suffice for internal integrity until the
first external party, and the option is deliberately kept open.

Both positions are coherent. Both are wrong about the same two things: who
the threat is, and when the clock starts.

## 2. The threat frame the opposition mispriced

The record's value is that a reader can rely on it **without trusting the
operator**. Research `06` puts party-attestation fraud at the top of the
in-band adversarial list; the layer below it is the integrity of the
machinery itself, and there the adversaries are precisely the parties the
chain-plus-checkpoint design implicitly trusts. Four actors, in ascending
order of subtlety:

1. **The operator itself**, under commercial pressure (a partner
   threatening to leave over an embarrassing attestation), legal pressure
   (subpoena, settlement), or founder-level bad judgment in year one, when
   nobody external is watching. Not hypothetical malice: the *inability to
   prove it didn't happen* is commercially identical to it having happened.
2. **An insider with DB access**, one of three people, or the first
   contractor. The pragmatist's "no `psql` into prod" is behavioral policy;
   at this headcount there is no dual control on daily operations, and
   everyone can reach everything.
3. **A poisoned CI/CD pipeline**, the supply-chain case. Nearly all code
   is AI-written; the deploy pipeline is the one actor that touches every
   component, including the code that computes checkpoints and the
   reconciliation job that would raise the alarm.
4. **A compromised cloud account**, credential theft or cloud-side
   compromise. Holds the database, the KMS signing keys, the WORM bucket's
   write path, and the alarms, all at once.

## 3. Threat-actor table: what each architecture proves

"Chain+WORM" = serialized hash chain, hourly signed Merkle checkpoints to
compliance-mode WORM S3, optional second-cloud copy (pragmatist §4).
"Day-one Merkle log" = tile log per §5 below, with witnessed public
checkpoints from the stated milestone.

| Threat actor | Attack | Chain + hourly WORM checkpoints | Day-one Merkle log + witnesses |
|---|---|---|---|
| **Operator itself** | Rewrite spine rows, re-hash chain forward, emit fresh checkpoints | Old WORM checkpoints survive and *would* diverge, but only the operator holds the data needed to check, and a serialized chain has **no efficient consistency proof**: demonstrating that checkpoint N+1 honestly extends checkpoint N requires replaying the full interval. No outsider can run that audit; no partner or court can be handed evidence. Detection depends on the operator auditing the operator. | A rewrite forks the tree. Witnesses cosign only checkpoints **consistent** with every checkpoint they previously signed (O(log n) consistency proofs); a forked history can never gather cosignatures. Rewriting becomes provably impossible, not merely detectable-in-principle. |
| **Insider with DB access** | Targeted mutation of a few spine rows plus re-hash; or suppress the reconciliation alarm | Same verification gap as above, plus: the checkpoint job and the alarm run on infrastructure the insider administers. Within any hour-long window, entries can be dropped or reordered before ever being committed. | The append **is** the log write; there is no pre-commitment window. Tiles are content-addressed on object storage; mutation requires forking the tree, which witnesses refuse. The insider is guaranteed to leave indelible, checkpoint-anchored evidence, the deterrent security-infra §3.5 needs. |
| **Poisoned CI/CD** | Deployed code silently writes divergent history to DB and checkpoint stream in a self-consistent way | Fails completely. The pipeline controls both the chain and the checkpoint emitter; a self-consistent forged stream to WORM is indistinguishable from honest operation. The WORM property protects old *checkpoints*, not the honesty of new ones. | External witnesses hold their own view of the tree head and verify consistency independently of anything the pipeline emits. A split view (one history to us, another to witnesses) is the canonical attack CT witnessing was built to catch. Deploy attestations in the log (§5) additionally make "what ran" itself a logged fact. |
| **Compromised cloud account** | Full control of DB, KMS checkpoint key, buckets, alarms | Compliance-mode WORM genuinely resists deletion of old checkpoints, the steelman's best cell. But the attacker signs arbitrary new checkpoints with the in-account KMS key, and the optional second-cloud copy receives whatever the compromised account sends. Still no third-party-verifiable consistency, still no inclusion proofs. | Second-cloud checkpoint mirror with independent credentials from day one; witnesses outside the account refuse forked checkpoints. Post-incident, the honest tree up to the last witnessed checkpoint is provable to anyone, which is the difference between "incident" and "company-ending forensic mystery." |

Two structural failures cut across every row of the opposition column:

- **No consistency proofs.** A Merkle tree answers "does this new head
  extend that old head?" in O(log n) for a third party holding only the two
  checkpoints. A serialized hash chain answers it only by full replay of
  the interval, by someone with all the data, namely the operator. The
  pragmatist's checkpoints are commitments nobody else can check.
- **No inclusion proofs.** Nothing in the chain+WORM design can hand a
  worker, partner, or court a standalone proof that a specific attestation
  is in the committed history (or that a claimed attestation is *not*).
  The design's own promise, "expose CT-style inclusion proofs later",
  concedes that the artifact that matters is the tree, then declines to
  build it.

## 4. The unfixable failure: retroactive coverage

Everything in §3 could in principle be answered with "we'll upgrade when it
matters." One thing cannot. **A transparency log proves history only from
its own genesis.** Entries logged at year 2 commit to bytes as they exist
at year 2; if the record was altered at month 9, the year-2 log faithfully
commits to the altered version. No amount of later money, engineering, or
auditing closes this. The pre-log period is "trust us" forever.

When that kills trust, concretely:

- **First major dispute.** A worker alleges an attestation was altered or
  backdated, or a party disavows one, claiming key compromise (design
  §3.3's own scenario, whose resolution rule *depends on* a trustworthy
  timestamp). If the events predate the log, the ledger's answer to "prove
  the timestamp wasn't manufactured" is its own database, i.e., the
  defendant's diary. Design 0.1's dispute machinery is FCRA-shaped
  precisely because it expects adversarial, potentially litigated
  disputes; the earliest cohort's records are the ones that will be oldest,
  most valuable, and least provable.
- **First partner audit.** Security-infra §2.1 already observed that the
  first external party's questionnaire asks "who can sign as you." The
  follow-up is "prove your history wasn't rewritten before we arrived."
  A log with genesis at launch answers in one line. A log younger than the
  record permanently answers "for the early period, you trust us", in
  every partner negotiation, for the life of the company.
- **First regulator inquiry.** Under R2, deletion is a legal promise;
  §5's anonymous deletion tombstones make "we purged on schedule" a
  provable claim. A regulator examining conduct in the pre-log window gets
  assertions instead of evidence, and this is a company whose entire
  differentiation is that assertions about the record are evidence.

The asymmetry that decides D3: **deferral's savings are bounded (weeks of
work, §6); deferral's cost is unbounded and permanent** (an unclosable
evidentiary gap over the exact records the thesis says compound in value).
The pragmatist prices operational risk honestly and evidentiary risk at
zero. This record *is* evidence; that is the product.

## 5. What goes in the log, and deletion compatibility

**Three entry families, one tree** (or three trees under one checkpoint,
an implementation detail):

1. **Attestation commitments**, the integrity-spine tuple: object ID,
   type, subject/issuer refs (opaque IDs), **salted payload commitment**,
   signature hash, supersession pointer. This *is* design §3.3's "ledger
   hash-chain timestamp at write," upgraded to carry inclusion proofs. It
   also resolves convergence-map **D6**: the log's checkpoint sequence is
   the ordering authority behind the compromise-vs-backdating rule, which
   removes the planet-scale advocate's TrueTime argument from D1's scales.
2. **Registry and key lifecycle events**, party registered / activated /
   suspended / revoked; key registered / rotated / compromised. This is the
   very "CT-style public commitment log over registry changes" that design
   0.1 names as the v2 hardening, delivered in v1. Without it, a
   malicious operator can quietly backdate a key's validity window or
   un-suspend a party; with it, every registry mutation is provable.
3. **Privileged operations**, merges/unmerges, `ledger_invalidated`
   attestations, break-glass access, deploy attestations, and deletions as
   **anonymous tombstones** ("person-scope deletion executed at T",
   nothing linkable post-shred).

**Explicitly excluded:** payloads and any readable personal data (the log
is public-by-destiny; nothing readable may ever enter it); derived values
(standing, flags, which are projections, not facts); and the read log
(`PacketIssued` is >80% of system volume per the log-centric arithmetic,
is worker-facing product surface rather than public integrity surface, and
would bloat the tree for no trust gain, so it stays on the spine only).

**Deletion compatibility (R2), precisely:**

- Leaves carry `HMAC(canonical_payload, k_r)` with per-record random key
  `k_r` stored **only in the erasable payload plane**, never bare hashes,
  which EDPB 02/2025 treats as personal data and which are
  dictionary-attackable for low-entropy payloads.
- R2 deletion destroys `k_r` with the payload (alongside the per-person
  DEK crypto-shred). The retained leaf becomes an unlinkable random value;
  the tree is untouched; inclusion proofs for every other person's history
  are unaffected; the anonymous tombstone entry proves the deletion
  happened within the published window.
- Subject references are opaque `ledger_person_id`s, tombstoned and never
  reused; post-deletion they resolve to nothing readable.
- Caveat carried honestly (same status as design §2.1): this is the
  strongest technically available posture, to be blessed by counsel, not a
  legal conclusion.

## 6. Honest costing, 2026 facts

**Tooling reality.** Tessera (transparency-dev) is a Go library for
tile-based logs, production-ready since v0.2.0, with production-grade GCP,
AWS, and POSIX storage drivers, antispam and garbage collection included,
and an explicit design goal of "no additional services to manage" and
lower TCO than Trillian v1. Rekor v2 (sigstore/rekor-tiles), built on
Tessera, went GA in October 2025 and runs Sigstore's public production
instance at a 99.5% availability SLA; its stated design goals are ease of
use, low cost, and minimal maintenance for self-hosters. Deployment
footprint on GCP: GCS for tiles + a small sequencer (Spanner or CloudSQL)
+ one binary; on AWS: S3 + Aurora/RDS MySQL + one binary; a POSIX mode
exists for minimal deployments. The "cheap tile log on object storage" is
real, shipping infrastructure, not a research artifact.

**Cost for this team, estimated honestly:**

| Item | Estimate | Basis |
|---|---|---|
| Initial integration (entry schema, KMS checkpoint signing chained to root, Postgres↔log reconciliation job, golden vectors) | **1–3 engineer-weeks** | Tessera is a library call in the append path; the schema/reconciliation work is ours regardless (the pragmatist builds a checkpoint job too) |
| Steady-state operations | **single-digit hours/month** | One stateless binary + managed storage + managed sequencer; reads are static tiles, CDN-cacheable; Sigstore runs the same stack at public scale with a small team |
| Infrastructure | **tens of $/month at launch; low hundreds at year 2** | Write load 0.2/s → <500/s peak is negligible against a stack built for Sigstore-scale ingest; tiles are pennies of object storage |
| Public checkpoint endpoint + one cosigning witness (at milestone) | **days of work + a bilateral arrangement** | See witness reality below |
| Year-sharded logs, multi-witness (10⁸ scale) | deferred, funded by the growth that triggers it | Rekor v2's own operational pattern |

**Delta vs. the pragmatist:** the WORM-checkpoint design is perhaps 2–4
engineer-days and near-zero marginal ops. The day-one log costs roughly
**one to two additional engineer-weeks up front and a few hours a month**.
That is the entire price of converting §3's failure column into its
success column. It is the cheapest control in the building relative to
what it protects.

**Witness ecosystem, honestly assessed.** This is the weakest plank of my
own position and I state it plainly: the network is early. Roughly 15
ArmoredWitness devices are deployed with trusted custodians, with
TrustFabric as effectively the sole reputational unit behind the network;
the C2SP tlog-witness protocol and checkpoint/cosigning specs are settled,
and Sigsum publishes named witness policies (with 2026 policy iterations
expected), but there is **no self-serve onboarding for an arbitrary
private log**. Getting witnessed is outreach and agreement, not an API
call. Consequences drawn honestly:

- Day one does **not** claim public witnessing. Day one claims: a real
  tree, signed checkpoints, and a second-cloud mirror under independent
  credentials, the cheapest witness outside the blast radius (and the
  place the pragmatist's WORM bucket is genuinely useful: as the mirror).
- The public-witness milestone (first external party or 1M identities) is
  set months out precisely so the bilateral arrangement, an
  ArmoredWitness/TrustFabric custodian, an auditor, or the partner itself
  acting as witness (partners have the strongest incentive to witness the
  log they rely on), can be negotiated on a calendar, not in a crisis.
- If the ecosystem stalls entirely, the fallback is N independent
  checkpoint mirrors under separately-held credentials plus published
  checkpoints anyone can archive, weaker than cosigning but still
  categorically stronger than §3's opposition column.

## 7. The minimal day-one artifact vs. staged additions

For a concrete ruling, the proposal is this artifact and nothing more:

**Day one (launch blocker):**

1. Tessera-based tile log on the primary cloud's object storage
   (evaluate running rekor-tiles as-is first; if its entry model fights
   the attestation envelope, Tessera-with-our-entry-schema, the design,
   not the dependency, is the commitment).
2. The log **is** the spine's append mechanism: ingest = validate → append
   to log → write Postgres (queryable system of record) → ack with
   inclusion metadata. No pre-commitment window exists.
3. Entry families per §5 (attestation commitments, registry/key events,
   privileged ops). Salted commitments only; zero readable personal data;
   CI lint enforces it (the data-platform school's spine linter, extended
   to log entries).
4. Checkpoints signed every hour (or better) by a dedicated KMS checkpoint
   key chained to the offline root; retained internally **and mirrored to
   a second cloud account with independent credentials, WORM-locked**.
5. A reconciliation job that continuously proves Postgres and the log
   agree; divergence pages a human. This alarm is the tamper-detection
   product feature.
6. Golden test vectors for entry canonicalization and checkpoint
   verification in the frozen trust kernel (two-human review per
   security-infra §6).

**Staged, with named triggers:**

| Addition | Trigger |
|---|---|
| Public checkpoint endpoint + ≥1 independent cosigning witness (C2SP tlog-witness) | First external attesting party activation OR 1M identities, whichever first, contract for it a quarter ahead |
| Inclusion proofs in the prior packet (offline-verifiable attestations) | First consumer that asks; a feature, not a migration, because the tree exists |
| Multiple witnesses across jurisdictions; year-sharded logs (log2027, log2028, bounds tree size, makes future crypto rotation tractable) | ~10⁸ identities |
| RFC 3161 external timestamping alongside checkpoints | Partner/regulator demand only |

## 8. Concessions, and when defer-to-v2 would actually be safe

Conceded without reservation:

1. **The pragmatist's cost claim is true as far as it goes.** WORM
   checkpoints are dollars and an afternoon; my position costs 1–2
   engineer-weeks more and a new (if small) operational surface. If the
   only threat were an *external* attacker mutating the database, the
   pragmatist's design would be adequate and cheaper.
2. **The witness ecosystem is immature** (§6). "Public witnessed
   checkpoints" is presently a bilateral arrangement; the day-one claim is
   correspondingly limited to a real tree with mirrored checkpoints.
3. **The log addresses none of the top in-band risk.** Party-attestation
   fraud (`06`), fraudulent content that is validly signed, sails straight into
   a transparency log. The log proves *what was said and when*, never
   *that it was true*. Registry vetting and anomaly detection carry that
   load; the log is orthogonal, and overselling it would be its own harm.
4. **Sequencer dependency:** the cloud deployment leans on a managed
   sequencer (Spanner/CloudSQL/Aurora-class); a second small managed
   component, inside the one-cloud assumption security-infra already makes.
5. **Salted commitments discharge linkability, not the legal question.**
   EDPB posture remains counsel's to bless.
6. **If Tessera the project stalls**, the fallback is a self-built tiled
   log on the identical storage layout, more work but the same design. The
   commitment is to the artifact shape, not the dependency.

**Conditions under which the opposition's positions would be safe:**

- **Defer-to-v2 is safe iff the early record is disposable.** This holds
  if the founder is prepared to tell the first cohort of workers, the first
  partner, and any future court that integrity for years 0–2 rests on the
  operator's word, and to carry that gap forever. That is coherent for a
  throwaway pilot whose records will be re-attested later. It is
  incoherent with the founder thesis, under which the early adopters'
  compounding records are the seed asset and the interface contract, IDs,
  and chain structure are all being treated as unretrofittable for exactly
  this reason. Chain structure made the day-one list (convergence map,
  settled point 6) on identical logic; the log's genesis date is the same
  class of decision.
- **The chain+WORM position becomes adequate by converging with mine:**
  replace the serialized chain's hourly roots with a real tile tree whose
  tiles are retained and whose checkpoints support third-party consistency
  and inclusion proofs, at which point the pragmatist is running a
  transparency log with extra steps, minus the maintained implementation.
  If the court is minded toward the pragmatist on ops grounds, the correct
  ruling is not his design but this one with the *witness* milestone
  relaxed, never the tree deferred.
- **A genuine blocker would be entry-schema churn.** If the spine tuple
  were expected to change weekly, committing it to an immutable log early
  would be premature. It is not: the log commits to *commitments* (hashes
  over a versioned canonical form), and the interface contract is already
  the stability boundary the whole company is built around.

The ask: rule that the tile log is day-one launch-blocking scope per §7,
with witnessing staged at first-external-party-or-1M, and rule D6 with it.

---

### Sources

- [Rekor v2 GA - Cheaper to run, simpler to maintain (Sigstore blog)](https://blog.sigstore.dev/rekor-v2-ga/)
- [sigstore/rekor-tiles, signature transparency log "designed for ease of use, low cost, and minimal maintenance"; GCP/AWS/POSIX deployment footprints; production instance at 99.5% SLA](https://github.com/sigstore/rekor-tiles)
- [transparency-dev/tessera, production-ready tile-log library; GCP/AWS/POSIX drivers; "no additional services to manage"; lower TCO than Trillian v1](https://github.com/transparency-dev/tessera)
- [Announcing Trillian Tessera (transparency.dev blog)](https://blog.transparency.dev/announcing-the-alpha-release-of-trillian-tessera)
- [Can I Get a Witness (Network)? ~15 ArmoredWitness devices, TrustFabric as the reputational unit; witness-network maturity assessment](https://blog.transparency.dev/can-i-get-a-witness-network)
- [C2SP tlog-witness protocol](https://github.com/C2SP/C2SP/blob/main/tlog-witness.md)
- [C2SP transparency log trust policy](https://c2sp.org/tlog-policy)
- [Named policies for Sigsum, witness policy iteration expected through 2026](https://www.glasklarteknik.se/post/named-policies-for-sigsum/)
- [transparency-dev/armored-witness](https://github.com/transparency-dev/armored-witness)
- Repo inputs: `design/ledger-design-0.1.md` §3.3, §2.1;
  `design/stack-perspectives/security-infra.md` §3;
  `design/stack-perspectives/boring-pragmatist.md` §4;
  `design/stack-perspectives/convergence-map.md` D3/D6;
  remaining perspective files read for context.
