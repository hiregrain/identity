# D5 Advocate Brief: A Composed Stack, Decomposed by Trust Requirement

Advocate against concentrating Grain's platform on a single hyperscaler, and for
ruling D5 as four separate placements rather than one. The opposing brief
(`d5-single-hyperscaler.md`) is engaged at its strongest form, meaning §2's
defense-in-depth argument for `rds.global_db_rpo` and §4's "decentralize the
proof, concentrate the plumbing," not the lock-in strawman it correctly
refuses to argue against.

Scope note: as with the opposing brief, this argues the widened gate the founder
opened on 2026-08-19, not decision 011's AWS-vs-GCP framing.

---

## TLDR, the verdict argued for

**Rule D5 as four placements against four different failure models, and refuse
to answer "which cloud" as a single question.** The four are:

1. **Primary plane** (payload databases, global spine, compute). Optimize for
   operator attention and durability primitives. AWS is defensible here and this
   brief does not contest it.
2. **Anchor** (compliance-mode WORM checkpoint account). Optimize for
   *surviving the operator*. Must not be the primary vendor.
3. **Mirror** (D3's second cloud). Optimize for *commercial and jurisdictional
   independence* from both the primary and the anchor.
4. **Root key custody** (D4 registry-grade keys). Optimize for the founder-sole-
   keyholder ceremony ruled in decision 011 remaining true in fact, not just on
   paper.

The opposing brief concedes 2, 3 and 4 in its §4 and then rules as though it had
not. If the concessions bind, the ruling is *this* brief's ruling with a
different title. The remaining disagreement is narrow and worth naming
precisely: **whether "AWS primary" is ratified as a platform commitment or as a
placement of one plane.** The difference is not rhetorical. It decides what a
future session is allowed to do without re-litigating.

---

## 1. The one thing this brief actually contests

Grant the opposing brief §2 entirely. `rds.global_db_rpo` is a real
transaction-blocking control, and no competitor has one. Grant §3's table.
Grant §6's eliminations. Grant that AWS KMS holds the only current FIPS 140-3
Level 3 managed-KMS validation.

What does not follow is the framing. A ruling that reads "Grain runs on AWS"
will be read by the next agent, and by the next engineer, as authorization to
place the anchor in an AWS account, the mirror in an AWS region, and the KMS
root in the same organization, because each of those is the path of least
resistance and each will look consistent with the ruling. The repo has a name
for this: an unrecorded divergence is drift. A platform-shaped ruling *invites*
the drift; a placement-shaped ruling forecloses it.

## 2. The anchor must not be the primary vendor, and the reason is in AWS's own docs

The opposing brief's §3 quotes the strongest available WORM guarantee and then
quotes its escape hatch in the same sentence: compliance-mode objects cannot be
deleted by any principal including root, **and the documented way to delete them
early is to delete the AWS account.**

That is the whole argument. The control protects against a compromised or
coerced *principal*. It does not protect against the loss of the *account*, and
the account is exactly what a single-vendor posture makes common between the
ledger and the proof of the ledger. Billing failure, enforcement action,
sanctions, or a support decision made by a stranger can each end Grain's
primary plane. Any one of them ends the anchor with it if they share a vendor.

Grain's own product test asks whether every claim resolves to the evidence
beneath it. If the evidence and the claim can be destroyed by one commercial
event, the answer is no, and it is no regardless of how good the retention
control is.

**Placement:** the anchor goes on a vendor that is not the primary, with
compliance-grade WORM that survives the vendor's own support organization. Two
qualify on documented text rather than assertion: **OCI**, whose documentation
states that neither a tenancy administrator nor Oracle Support can delete a
locked retention rule, and **Backblaze B2**, whose compliance mode is documented
as unremovable by Backblaze support explicitly as an anti-social-engineering
control. OCI's mandatory 14-day pre-lock delay is a material operational
advantage for a team that will misconfigure retention on the first attempt and
would otherwise be permanently stuck with the mistake.

## 3. The mirror is not a backup, but a second jurisdiction

D3's second-cloud mirror exists so that a checkpoint's existence can be
demonstrated without the operator's cooperation. If the mirror shares the
primary's vendor, its country of incorporation, and its legal process exposure,
it demonstrates nothing that the primary does not already demonstrate.

The opposing brief adopts Backblaze for the mirror. Good, but if Backblaze is
the mirror and OCI is the anchor, the composed stack has already been ruled and
the "single hyperscaler" title is describing one of four placements.

There is a further point the opposing brief does not reach. **The witnessed tile
log (D3, registry-deadline-gated) is the real answer to this whole brief**, and
it is post-launch. Until it exists, vendor diversity on the anchor path is the
only thing standing in for it. The single-vendor ruling spends the interim
capital that the witnessed log will eventually make unnecessary. But "eventually"
is the registry-enforced first-external-party-or-1M deadline, and decision 005
already recorded that the first external party is *not* expected within ~2
quarters. The interim is long.

## 4. Residency: the opposing brief's §4 proves this brief's point

The research finding is correct and important: neither the Philippines nor India
imposes a localization mandate. The Philippines DPA regulates cross-border
transfer without requiring in-country storage; India's DPDP framework operates a
negative list under Section 16 rather than a residency rule.

The opposing brief treats this as removing a constraint. It also removes the
*argument for concentration.* If PH and India are transfer questions rather than
placement questions, then the payload plane's placement is driven by latency and
by counsel's transfer analysis, not by which vendor has the widest region map.
The widest-region-map advantage was AWS's strongest structural claim to the
whole footprint, and this finding retires it.

What remains is the EU, where the constraint is real. Here the opposing brief's
own answer cuts both ways: AWS European Sovereign Cloud reached general
availability on 15 January 2026 with a *first* region in Brandenburg, expanding
through sovereign Local Zones in Belgium, the Netherlands and Portugal. A cloud
that is seven months old is not a de-risked dependency for a launch-blocking
plane. Its Postgres and KMS surface must be verified feature-by-feature, and
specifically it must be confirmed that the Aurora global primitive, the entire
basis of the opposing brief's §2, exists there at all. **If it does not, the EU
plane cannot inherit the AWS ruling's central justification, and the composed
stack is not a preference but a fact.**

## 5. Key custody: the ceremony must be true in fact

Decision 011 rules the founder the sole keyholder for the root ceremony, with a
third-party keyholder revisited at the witnessed-log milestone. D4 places
registry-grade keys with the party and hosts worker/peer keys.

A hosted KMS root inside the primary's organization means the sole-keyholder
ruling is true about *authorization* and false about *custody*: the vendor holds
the module. That is acceptable. It is what "hosted keys" in D4 means. But it
should be ruled explicitly rather than inherited from a platform choice, and it
should be recorded that the operator-signing key and the anchor live under
different vendors. Otherwise a single vendor holds the signing capability, the
record, and the proof of the record.

FIPS 140-3 Level 3 is the right tiebreak for where the module sits, and it points
at AWS KMS today. **It points at a certificate with a sunset date of 11/17/2026,
which falls inside this build's horizon.** Ratifying a platform on a certificate that expires
in under three months without confirming the successor validation is the kind of
dated fact that decision 042 exists to stop.

## 6. What this brief is not arguing

- Not arguing for multi-cloud compute, Kubernetes-for-portability, or an
  abstraction layer over vendor APIs. Those are the lock-in strawman and they
  would cost the operator attention the opposing brief correctly protects.
- Not arguing against AWS for the primary plane. §2 of the opposing brief is
  accepted.
- Not arguing for provider-neutral application code beyond what decision 011
  already requires while the gate is open.

## 7. Measurable switch-triggers

1. The witnessed tile log ships and carries external witnesses (retires §3;
   anchor-vendor diversity becomes optional rather than load-bearing).
2. AWS European Sovereign Cloud is verified to offer Aurora global databases
   with `rds.global_db_rpo` and a FIPS-validated KMS (removes §4's EU-split
   argument).
3. Any single-vendor account event, such as suspension, billing termination, or
   legal process, reaching either the primary or the anchor (proves §2; forces
   immediate separation if not already ruled).
4. A compliance-mode WORM incident at Backblaze or OCI in which the vendor
   *does* unlock data (kills the chosen anchor and forces re-placement).
5. Counsel returns a localization finding for India or the Philippines
   (re-opens §4 and forces a regional placement question in both directions).
