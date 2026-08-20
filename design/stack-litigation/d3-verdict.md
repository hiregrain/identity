# D3 Verdict: Day-One External Anchoring; the Tile Log on a Deadline, Not a Trigger

Ruling on convergence-map D3 (transparency-log timing), adjudicating
`d3-dayone-log.md` (day-one Tessera-class tile log as the spine's append
mechanism) against `d3-checkpoints.md` (5-minute WORM checkpoint anchoring
day one; tile log at a contractual trigger). Both briefs killed design
0.1 §3.3's "v2 hardening" deferral; that position is dead and is not
revived here. External claims verified 2026-08-17: Rekor v2 GA
2025-10-10 on Tessera tiles, with shard-rotation/freeze, TUF key
distribution, and monitoring as standing operator obligations and non-GCP
support "actively" in progress at GA; witness network = ~15
ArmoredWitness devices under TrustFabric, no onboarding path for private
commercial logs. Both briefs cited these facts accurately.

---

## The ruling

1. **Launch-blocking (day one):** the checkpoints brief's anchoring
   architecture, adopted in full as amended: per-stream chains; a
   checkpoint job at **T = 5 minutes** building a Merkle root over
   advanced stream heads, each checkpoint naming its predecessor, signed
   by a KMS checkpoint key chained to the offline root; written to S3
   Object Lock **compliance mode** in a **dedicated AWS account** whose
   credentials production does not hold, **mirrored to a second cloud's
   bucket-lock**; signed inclusion receipts issued to submitting parties
   at ingest; a continuous reconciliation job that re-derives recent
   roots from the database and alarms on divergence. Also launch-blocking:
   frozen entry canonicalization with golden vectors in the trust kernel,
   and a checkpoint format containing stream-head roots, sequence
   numbers, and predecessor hash. These are what make §4.3 of the
   checkpoints brief (the genesis-consistency proof) executable later,
   and they are cheap only if built now.

2. **The tile log is scheduled, not optional and not trigger-gated in its
   start.** Construction of the Tessera-class tile log (three entry
   families per the consolidated spec below) begins as the **first
   post-launch infrastructure project**, not "at the trigger." The
   trigger is a **deadline**, enforced in the registry state machine: the
   log, with a public checkpoint endpoint, at least one independent
   cosigning witness (a named auditor or the partner itself suffices),
   and the published genesis-consistency proof against the full anchor
   set, must be live **before the first external attesting party's
   `active` transition, or before 1,000,000 registered identities,
   whichever comes first**. External-party registration reaching
   `pending` starts the build clock if it has not already started.
   Slipping the deadline requires a signed, logged governance act, a
   `ledger_invalidated`-grade event in the privileged-operations family,
   not a quiet omission.

3. **The log is the integrity authority, never the synchronous write
   path.** The day-one brief's clause "the log **is** the spine's append
   mechanism" is **rejected**. Postgres remains the system of record;
   the log (once live) is appended asynchronously with a bounded lag SLO
   inside the checkpoint interval; the reconciliation job proves they
   agree and is the tamper alarm. A log incident is an alarmed
   degradation of integrity freshness, not a ledger write outage. This
   placement is what makes the log operable by three people; it costs
   nothing cryptographically because operator-resistance was never
   better than the externally-anchored checkpoint cadence anyway
   (finding (c) below).

4. **If the founder confirms an external attesting party is expected
   within ~2 quarters of launch, the log build moves into pre-launch
   scope** and the migration is skipped. This is the checkpoints
   brief's own flip condition 1, and on the record before the court
   (datacenter-technician contract as the canonical near-term example)
   it is more likely than not to obtain. See [FOUNDER-CALL] 1.

## Adjudicated findings

### (a) The day-one log's claimed cost is understated, but by scope, not by dishonesty

The "1–3 engineer-weeks, tens of $/mo" figure is accurate for the
dollars and roughly accurate for the initial integration *if rekor-tiles
fit as-is*. It does not fit: rekor-tiles entry types are
supply-chain-shaped (hashedrekord/DSSE), so the day-one brief's own
fallback, a bespoke Tessera personality with our entry schema,
applies, and that is weeks, not days, to stand up credibly. The larger
omission is recurring and structural, verified against the Rekor v2 GA
announcement: annual shard rotation and freeze ceremonies with
client-visible URL/key changes; a key-distribution discipline (Sigstore
uses TUF; a private deployment must run TUF or invent an equivalent
alongside the registry it already operates); continuous monitoring
(rekor-monitor-class) as a standing service; and Tessera's maturity
being GCP-first while D1 trends AWS. None of this is prohibitive, but
"queue-cheap" was Sigstore's cheapness, achieved with a dedicated team.
The decisive cost, however, was never the ops-hours: it was the day-one
brief's coupling of the log to the critical write path, under which
every log defect is a production ledger outage during the exact years
the team is three people. Severing that coupling (ruling ¶3) removes
most of the risk premium; what remains is a real but bounded standing
surface, which the deadline schedule (¶2) buys at the moment its
distinctive value, legibility to an external verifier, first exists.

### (b) The genesis-consistency argument is technically correct; the residue is conditional, not cryptographic

A log stood up later, whose initial entries replay the full append-only
spine in original order, whose recomputed interval roots are verified
byte-equal against every WORM-anchored checkpoint back to hour zero
(with the anchored checkpoint chain itself appended into the log), and
whose first witnessed checkpoint publishes with the verification
transcript, offers an external verifier the same epistemic ground truth
for the early era as a day-one log would: commitments that left the
operator's control within minutes of each write. The day-one log's
early era is equally unwitnessed and rests on the same species of
evidence (checkpoints mirrored outside the blast radius). The
unfixable-history argument therefore **dissolves against anchored
history**. It was decisive only against design 0.1's unanchored
deferral, which both briefs already killed.

The residue, stated precisely, is conditional on day-one discipline:
(1) the proof exists only if canonicalization is frozen, coverage is
complete, and the checkpoint format is recomputable, hence those items
are launch-blocking in ¶1, and the reconciliation verifier doubles as
the migration verifier; (2) per-record inclusion proofs for early
records do not exist until the migration completes, and between launch and
trigger, an individual early record is verifiable only by recomputing
an interval against an anchor, with operator-supplied data; granularity
is per-checkpoint until it becomes per-record retroactively. This is a
verification-ergonomics gap during a window in which, by construction,
no external verifier exists; (3) entries dropped inside a pre-anchor
window are absent from anchors and reconstructed log alike, identical
to the day-one log's pre-checkpoint exposure, mitigated identically by
receipts and the 5-minute cadence. No residue survives that a day-one
unwitnessed log would have avoided.

### (c) The omission-window equivalence claim is correct in trust class, mildly overstated in mechanics

At launch, both architectures reduce, against the operator, to
"externally anchored signed checkpoints every T": the unwitnessed tile
log's checkpoints mirrored to a second account are the same instrument
as the WORM anchors, and both leave a ≤T pre-anchor omission window
closed only by witnesses, which arrive at the same milestone on both
plans. Equivalence holds. Two honest qualifications in the day-one
log's favor: a log-as-append-path design has no separate DB-then-log
gap (mooted by ruling ¶3's severance, accepted as a cost of ¶3), and a
Merkle tree hands a third party O(log n) consistency proofs natively,
where the checkpoint chain requires the recomputation machinery. This is a
convenience difference, not a trust-class difference, given the
checkpoint format mandated in ¶1. The day-one log's one
non-cryptographic advantage, foreclosing trigger-slip as a human
failure mode, is real and is answered by making the trigger a
registry-enforced deadline with a start date of "immediately," rather
than by paying the write-path coupling.

### (d) The founder timeline nearly collapses the dispute, and is why the log starts now

With external attesting parties plausibly within quarters (the
datacenter-technician contract being the canonical case), the trigger
fires almost immediately after launch, and the checkpoints brief itself
concedes that in that world staging is ceremony and one should "build
the log before launch and skip the migration." The two positions
converge to within one decision variable: whether the external party is
*expected* or merely *plausible*. The court does not resolve a
commercial forecast; it removes the forecast's downside instead. Under
this ruling, if the party arrives fast, the log is already being built
and the deadline binds before activation; if the party slips, the
company has not carried a bespoke trust-critical service on its write
path for quarters with no audience able to read it. The only
configuration this ruling forecloses is the one neither brief defends:
anchoring deferred, or the log started only when a partner demands it.

### (e) Consolidated log-contents and R2-compatibility specification

The two briefs' proposals are compatible and are consolidated as
follows, binding for the anchored checkpoints from day one and for the
tile log's entry schema at build time. **Three entry families, one
checkpoint sequence** (one tree or three trees under one checkpoint,
an implementation choice): (1) **attestation commitments**, the
integrity-spine tuple: object ID, type, opaque subject/issuer refs,
salted payload commitment, signature hash, supersession pointer;
(2) **registry and key lifecycle events**, party registered / activated
/ suspended / revoked; key registered / rotated / compromised;
(3) **privileged operations**, merges/unmerges, `ledger_invalidated`
attestations, break-glass access, deploy attestations, and deletions as
**anonymous tombstones** ("person-scope deletion executed at T",
nothing linkable post-shred). Commitments are
`HMAC(canonical_payload, k_r)` with a per-record random key `k_r` held
**only in the erasable payload plane**, never bare hashes (EDPB
02/2025 treats hashes of personal data as personal data;
low-entropy payloads are dictionary-attackable). R2 deletion destroys
`k_r` together with the per-person DEK crypto-shred: the retained leaf
becomes an unlinkable random value, the tree and every other person's
inclusion proofs are untouched, and the tombstone proves timely
execution. Subject references are opaque `ledger_person_id`s,
tombstoned and never reused. **Excluded**: payloads and any readable
personal data (the log is public-by-destiny); derived values (standing,
flags, which are projections, not facts); the read log (`PacketIssued`,
worker product surface, >80% of volume, zero public-trust gain; spine only).
The spine CI lint extends to log entries. Caveat carried: salted
commitments discharge linkability technically; the legal posture is
counsel's to bless.

## Consequences for other docket items

- **D6 (ordering authority), ruled with D3, as the docket directs.**
  The ordering authority behind the compromise-vs-backdating rule
  (design 0.1 §3.3) is the **anchored checkpoint sequence**, the
  ledger's own commitment chain, externally immutable within minutes of
  each write, succeeded without interruption by the tile log's checkpoint
  sequence at migration (the genesis proof makes them one sequence).
  TrueTime-class commit timestamps are thereby removed from D1's
  scales: the planet-scale brief's ordering argument is moot regardless
  of D1's outcome.
- **D4 dependency, flagged for the D4 judge.** The hosted-keys brief
  conditioned operator discipline on the day-one log ("what disciplines
  the operator is the transparency log"). Under this ruling that
  condition is satisfied **in substance** from day one, since every
  registry mutation, key event, and privileged operation is externally
  anchored in compliance-mode WORM within five minutes, and every KMS
  signature is in the cloud audit trail. But **witnessed co-signing
  arrives only at the deadline**. If the D4 court weighs hosted signing's insider
  concentration against the discipline mechanism, it should price
  "anchored, not yet witnessed" for the launch window, not "day-one
  witnessed log."

## Residual risks

1. **Deadline slip under commercial pressure**, the one failure mode
   the day-one plan structurally forecloses. Mitigated: build starts
   immediately; the registry state machine blocks external-party
   `active` without the log; slipping requires a signed governance
   event. Not eliminated: a governance act can still be taken.
2. **Compliance-mode WORM is a cloud-provider promise, not physics.**
   Sole known escape is account closure (slow, loud, ~90-day window),
   covered by the second-cloud mirror; a years-premeditated operator
   conspiracy degrades gracefully rather than impossibly until
   witnessing lands. A day-one unwitnessed log would not have converted
   this either.
3. **Receipt-checking is party-dependent at launch**, and launch parties
   are internal verticals inside the operator's trust domain; during the
   earliest weeks the practical omission check is the reconciliation
   alarm the operator runs. Honest residue of self-trust; removed only
   by witnesses, on any plan.
4. **Witness availability at the deadline.** No self-serve onboarding
   exists for private logs (verified); the deadline's witness deliverable
   must be sourced bilaterally, by an auditor or the partner itself,
   contracted a quarter ahead. If the ecosystem matures into
   witnessing-as-a-service first, adopt it early.
5. **Tessera's GCP gravity vs. a likely-AWS stack (D1).** Non-GCP
   support was in progress at GA; re-verify driver maturity at build
   start. Fallback stands (both briefs agree): a self-built tiled log on
   the identical storage layout, the artifact shape, not the
   dependency, is the commitment.
6. **Canonicalization freeze is load-bearing.** The genesis-consistency
   proof fails open if entry canonicalization drifts before migration;
   golden vectors in the frozen trust kernel are the guard, and any
   canonicalization change before migration is a kernel change under
   two-human review.

## [FOUNDER-CALL]

1. **External-party timeline.** If a first external attesting party
   (e.g., the datacenter-technician contract) is expected to reach
   registration within ~2 quarters of launch, the tile log moves into
   pre-launch scope and the migration is skipped (ruling ¶4). This is a
   commercial forecast only the founder can make; the ruling is robust
   to either answer but cheaper if answered now.
2. **Counsel blessing of the salted-commitment posture** (EDPB 02/2025)
   before the log's checkpoints become public at the deadline.
   Publication is the moment the "public-by-destiny" property becomes
   irreversible.
3. **Witness sourcing preference at the deadline:** independent auditor
   under contract vs. the first partner acting as witness. Partners have
   the strongest incentive to witness the log they rely on, but a
   partner-witness is not independent of the relationship the log is
   meant to discipline; an auditor costs money. Either satisfies the
   deadline deliverable.
