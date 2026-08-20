# D4 Advocacy: Party-Held Signing Keys as the Default

Litigation brief for docket item D4 (`convergence-map.md`). Position argued:
**parties sign their own attestations with keys they control, registered in
the ledger's trust registry, against ledger-hosted signing as the default**
(security-infra §2.3). Written against `ledger-design-0.1.md` §3,
`security-infra.md`, `research/04`, `research/06`, and web research on
key-custody precedent. Clean context; `design/stack-litigation/` not read.

---

## TLDR

1. **The category argument decides this.** The product sells exactly one
   sentence: *"the party said this; the ledger merely recorded it."* Hosted
   signing makes that sentence false. The ledger can produce a valid
   signature for any party at any time, so every attestation reduces to a
   database row with cryptographic ceremony. The first litigated dispute or
   auditor question, "could you have forged this?", must be answerable
   "no, structurally," not "yes, but our own logs would show it."
2. **Precedent is uniform.** Every regime that has litigated server-held
   signing keys either forbids operator custody (WebPKI: Mozilla Root
   Policy prohibits CAs generating subscriber TLS keys) or permits it only
   under a certified sole-control architecture in which the operator
   *provably cannot sign alone* (eIDAS remote QSCD: certified SAM + HSM,
   signer-held activation data). Nobody who survived scrutiny runs the
   security-infra proposal, operator-held keys disciplined only by the
   operator's own audit log.
3. **The hosted case's real problem, partner key hygiene, is solved
   without custody transfer:** partner-side KMS (their cloud, their
   custody, still API-auditable), short-lived key validity with automated
   ACME-style rotation, and the probation caps already in design §3.1.
   Under these controls a leaked credential's blast radius is *smaller or
   equal* under party-held custody than under hosted custody, because
   hosted signing does not remove the partner-side credential. It renames
   it. A compromised partner authenticates to the hosted endpoint and
   forges just as effectively.
4. **The fraud-detection benefit of hosted signing is ~zero marginal.** A
   signature that is never submitted for ingestion harms no one; the
   ledger already sees, rate-limits, and anomaly-scores 100% of
   attestations at ingestion. Signing-time telemetry is ingestion-time
   telemetry minus nothing that matters.
5. **Honest weakest point, conceded:** years 1–3 partners are small and
   unsophisticated; expect 1–2 leak incidents and real support cost.
   Argued below that a leak-and-remediate incident is survivable and the
   custody question in a litigated dispute is not.
6. **Hybrid position:** party-held default; a bootstrap tier of
   *ledger-provisioned, partner-owned* KMS (custody transferred at
   activation) for small parties; **no operator-custody tier for
   registry-grade party keys.** Worker/peer account keys: conceded to
   hosted, a different trust class, different stakes.
7. **Switch triggers** enumerated in §7. This position is falsifiable.

---

## 1. The category argument: what an attestation is

### 1.1 The claim structure

The interface contract and design 0.1 build everything on a three-way
separation of roles: the party *asserts*, the ledger *records and
timestamps*, the reader *weighs*. The attestation's evidentiary value is
exactly the fact that these roles are held by different actors. Design 0.1
§4 states it as the ledger's oath: it verifies "provenance and form, who
said it, that they validly said it," and never substance.

Hosted signing collapses assertion and recording into one actor. The
technically precise statement becomes: *"the ledger, on receipt of an
authenticated request attributed to the party, generated a signature with
a key only the ledger can use."* That is not "the party said this." It is
"the ledger says the party said this," which is what a plain database row
with an `issuer_id` column already says. The Ed25519 envelope adds
integrity against third parties and nothing against the one actor whose
honesty the whole system is designed not to have to assume: the operator.

Security-infra's rebuttal (§2.3) is that the operator already controls the
registry, so operator trust is assumed either way. This proves too little.
Registry control lets a malicious operator admit a *fake party* or extend
a key's validity window, acts that are visible in the public registry and
transparency log, attributable to the operator, and that create a *new*
issuer identity relying parties never trusted. Key custody lets the
operator forge *in the name of a real, vetted, trusted party*, the exact
signature, the exact `kid`, indistinguishable forever from the genuine
article. The transparency log proves the forged entry existed at time T;
it cannot prove who authored the bytes. Registry trust and signing trust
are different trust quantities, and the design's entire §3.3
compromise-vs-backdating machinery exists because they are different.

### 1.2 The moment it becomes existential

Three concrete scenarios, all inside the design's own documents:

- **The litigated dispute.** Research `06` §5 predicates the record's
  usefulness on a qualified-privilege liability structure; `04` §4 adopts
  FCRA-shaped disputes. In any dispute that reaches counsel, whether a
  worker suing over a career-damaging attestation or a party disavowing
  one, the first discovery question is "who could have produced this
  signature?"
  Under party-held custody the answer is: the party, or someone holding
  the party's key. Under hosted custody the truthful answer is: *the
  party, or the ledger operator*, and the ledger is simultaneously the
  record-keeper, the fraud adjudicator (§3.4 `ledger_invalidated`), and a
  commercially interested platform. Aerotek, Inc. v. Boyd (Tex. 2021)
  shows how disputed e-signatures are actually won: system evidence and
  audit trails shift the burden to the challenger, but that works because
  the platform (a DocuSign-analog) is a *neutral third party* to the
  dispute. Here the operator is a party to every dispute about its own
  record's integrity. "Our audit logs show we didn't" is the platform
  vouching for itself with evidence the platform generates.
- **The regulator/auditor question.** Research `01`/`07` flag CRA-adjacency
  and EDPB exposure; the first serious audit of an attestation registry
  asks the eIDAS-shaped question: is the signature creation data under the
  signatory's sole control? Hosted-KMS-with-IAM answers no.
- **The partner security questionnaire.** Security-infra's own argument
  (§2.1) cut the other way. "Who can sign as you?" is a question partners
  ask *about their own keys* too. "You can, you host them" is a finding
  in every mature partner's review; the sophisticated partners
  security-infra exempts via BYO are precisely the ones whose diligence
  teams will ask why the default is operator custody.

### 1.3 Precedent: how server-held keys have fared under scrutiny

Web research, summarized; sources at end.

- **eIDAS remote signing (the strongest pro-hosted precedent, read
  carefully, it is a ruling against this proposal).** eIDAS explicitly
  *permits* qualified signatures with server-held keys, remote QSCD,
  which sounds like vindication for hosted signing. But the conditions are
  the point: the key must live in a certified HSM (EN 419 221-5), and
  every activation must pass through a Common-Criteria-certified Signature
  Activation Module (EN 419 241-2) driven by Signature Activation Data
  that only the signatory holds, achieving "sole control Level 2," the
  TSP *provably cannot create a signature without the signer's
  per-operation authorization*. In other words: the one regulatory regime
  that blessed hosted signing did so only after re-engineering it until
  the host cryptographically cannot forge. Security-infra's design, party
  keys in the ledger's KMS ring, activated by the ledger's service on an
  authenticated API call, is exactly the architecture eIDAS refused to
  bless. Done to the standard that survives scrutiny, "hosted" converges
  back to party-held control material (the activation data), plus a
  certified SAM the team would have to operate. Done below that standard,
  it is the thing the standard exists to prevent.
- **WebPKI.** Mozilla Root Policy §5.2 flatly prohibits CAs from
  generating subscriber key pairs for TLS certificates, and the
  CA/Browser Forum has moved the same direction; the Code Signing Baseline
  Requirements mandate subscriber private keys be generated and kept in
  hardware the subscriber controls. Thirty years of CA practice settled on
  the identical role separation this product's trust story needs: *the CA
  vouches for the binding of key to identity; it must never hold the key.*
  A CA that could sign as its subscribers would be distrusted on
  discovery. The ledger is, by design 0.1 §3.1's own analogy, a
  CA/Browser-Forum-shaped single root. It should inherit the norm.
- **E-signature case law.** Courts enforce disputed click-wrap signatures
  on audit-trail evidence (Aerotek; FRE 901's low authentication bar), and
  challengers lose because they must show "the entire system was
  compromised." That doctrine is exactly why hosted custody is dangerous
  here: it converts every attestation into the operator's business record,
  authenticated by the operator's testimony about the operator's system.
  DocuSign survives that posture because it is disinterested. A work
  ledger whose valuation rests on the record's independence does not get
  to be DocuSign; it is closer to a credit bureau that also writes the
  tradelines. The 2023 UK ruling rejecting an e-signature lacking AES
  non-repudiation features shows the other edge: where signature-level
  non-repudiation is expected, custodial shortcuts fail in court.
- **Certificate Transparency / Sigstore.** The design's own chosen
  lineage (`04` TLDR-2, security-infra §3). CT logs never hold CA keys;
  Rekor never holds signer keys. The transparency layer works *because*
  the log operator's compromise cannot forge entries' signatures, only
  their inclusion. Hosting party keys inverts the very property the
  Tessera log is being built to provide.

The pattern is uniform: server-held keys have survived legal and trust
scrutiny only where the server demonstrably cannot sign alone. No regime
accepts "the host could sign, but the host's logs would show it" for
third-party-relied-upon signatures.

---

## 2. The hosted case at its strongest (steelman)

Stated as forcefully as its advocate would, before rebuttal:

1. **The most probable forgery event in years 1–3 is a partner's leaked
   key file, not a ledger breach.** The year-1 partner roster is internal
   verticals and firms like a datacenter-training company or a Philippine
   ops firm. None runs KMS-grade custody. Their Ed25519 key will be a PEM
   file in a config repo, a CI secret, a shared 1Password vault five
   contractors can read. It leaks; fraudulent attestations verify
   perfectly; design §3.3's compromise machinery only helps after someone
   notices. Probability-weighted, partner leakage dwarfs operator insider
   risk. The operator is three named people with everything to lose;
   partner #30's contractor pool is nobody with anything to lose.
2. **Hosted signing turns every signature into an auditable, rate-limited,
   individually-logged API event.** The party-fraud detection that
   research `06` calls the top adversarial risk gets a complete, real-time
   feed for free; probation volume caps become mechanically enforceable at
   the signing endpoint; a compromised party is frozen with one IAM
   change instead of a registry revocation race.
3. **Partner key-management competence at partner #30 is genuinely poor,
   and the support cost is real.** Every partner-held key is an
   integration meeting, a rotation runbook the partner won't follow, and a
   3-person team on the hook for someone else's custody failure. Hosted
   signing is one OIDC handshake and zero partner-side key material,
   faster onboarding, fewer incidents, and the workers whose records ride
   on partner competence are better protected by the operator's KMS than
   by partner #30's laptop.
4. **Non-repudiation is already qualified.** The operator runs the
   registry, the timestamps, and the transparency log; a relying party
   already trusts the operator for what a signature *means*. Hosted
   custody adds no new trusted party. It consolidates trust that exists.

This is a serious position. Points 1 and 3 are factually correct and are
conceded as facts below. The rebuttal is that the conclusion does not
follow from them.

---

## 3. Rebuttal

### 3.1 The category rebuttal (§1, applied)

Steelman point 4 is the load-bearing error, and §1.1 answers it: registry
trust and signing trust are different quantities, the design's own
compromise-vs-backdating rule depends on their difference, and every
external regime that examined the question refused to let them merge. The
remaining points are operational, and operational problems get operational
solutions, not a change to what the product's core object *is*.

### 3.2 The partner-competence problem, solved without custody transfer

Three controls, all buildable by this team, all cheaper than a certified
SAM, all preserving "only the party can sign":

**(a) Partner-side KMS as the packaged default.** The ledger ships a
partner integration kit, a Terraform/Pulumi module plus SDK, that
creates a non-extractable Ed25519 key *in the partner's own cloud KMS*
(AWS and GCP both native since Nov 2025, per security-infra §2.2),
registers the public key with the registry, and signs via the partner's
KMS API. Custody: partner. Key material on laptops: none, the "key file"
never exists, which eliminates the exact vector the steelman leads with.
Auditability: every signature is an authenticated, logged KMS event *in
the partner's cloud audit log*, which the partner can (and under the party
agreement, must) retain and produce on compromise investigation. The
partners in question, a datacenter-training company, an ops firm, have
AWS accounts; "run this module" is within their competence in a way that
"manage this PEM file" is not. This captures ~all of hosted signing's
hygiene benefit with zero custody transfer.

**(b) Short-lived key validity, ACME-style.** Registry key records already
carry `valid_from`/`valid_until` (design §3.3). Set the window short,
30–90 days, and make renewal automated through the SDK (an ACME-like
re-attestation of control: sign a registry-issued challenge with the
current key inside its window to activate the successor, itself generated
in the partner's KMS). A key that must roll every 60 days cannot rot in a
config repo for two years; a leaked key is dead in ≤60 days even if the
leak is never noticed; and mandatory rotation exercises the compromise
runbook continuously instead of leaving it theoretical. Renewal failure
degrades safely: the party's ingestion halts (key expired), loud,
recoverable, and vastly better than silent forgery.

**(c) The controls the design already has, doing their job.** Probation
volume caps (§3.1) bound a new partner's total output; the bipartite
anomaly detection (§3.5) is custody-independent; the ledger timestamp +
compromise-report rule (§3.3) bounds the disavowal window; and
`ledger_invalidated` (§3.4) provides auditable per-attestation remediation
after any incident.

**Blast radius comparison, leaked-credential scenario:**

| | Party-held + controls (a)–(c) | Ledger-hosted (security-infra §2.3) |
|---|---|---|
| What leaks | Nothing extractable exists partner-side; realistic leak is the partner's *cloud IAM credential* | The partner's *signing-endpoint credential* (OIDC workload identity / mTLS client key) |
| Can the thief forge? | Yes, via partner's KMS API, until detected/rotated | Yes, via ledger's signing API, until detected/frozen. **Hosted signing does not remove this scenario; it relocates the credential** |
| Volume bound | Probation caps at ingestion + partner KMS quotas + ≤60-day key death | Probation caps at signing endpoint + ledger rate limits |
| Detection feed | Ingestion telemetry (100% of attestations) + partner cloud audit log | Signing telemetry (≈ ingestion telemetry, §3.3 below) |
| Who else can forge, ever | **No one. Not the operator.** | **The operator, permanently, for every party in the default tier** |
| Post-incident story | "A partner's credential leaked; caps bounded it; the log proves exactly what was forged; invalidated" | Same, *plus* every future dispute inherits "and the operator could have done it too" |

The honest reading of this table: on the steelman's own chosen threat
(partner-side leakage), the two architectures are near-equivalent, because
the forgery path in both cases is *a compromised partner authenticating
successfully*. Hosted signing swaps a signing key for a signing-endpoint
credential and the fraud looks identical. What differs is the last row,
which is the category argument, and it runs entirely one way.

### 3.3 The fraud-detection benefit is reproducible, almost exactly zero marginal signal

The steelman's point 2 claims hosted signing feeds fraud detection "for
free." Decompose it:

- A signed attestation is inert until submitted for ingestion. The ledger
  is the sole verifier and sole store (no wallet/offline-presentation
  requirement exists. `04`, design §3.2 defers VC interop). Therefore
  **every attestation that can harm anyone passes through ingestion**,
  where the ledger already authenticates the submitting party, verifies
  the signature, checks registry state and probation caps, timestamps,
  and can rate-limit and anomaly-score, design §4's pipeline, verbatim.
  The ledger IS the rate limiter and the telemetry point.
- The only events hosted signing observes that ingestion does not are
  *signatures requested but never submitted*, a set that is empty for a
  rational attacker (why request signatures you won't use?) and nearly
  empty for an honest party (retries, test runs). As fraud signal this is
  noise.
- Enforcement latency is equivalent: freezing a party is one registry
  state change consumed by the ingestion path (reject on
  `issuer != active`), exactly as fast as one IAM change on a signing
  endpoint, and, unlike the IAM change, it lands in the public registry
  history where relying parties can see it.
- Partner-side KMS (control (a)) additionally yields a per-signature
  audit log in the partner's cloud for post-incident forensics, the one
  genuinely useful artifact hosted signing would have produced, recovered
  without custody.

What hosted signing uniquely adds is not detection; it is *pre-ingestion
prevention* of signatures by a thief who has the party's endpoint
credential but not the party's KMS access, a sliver of the threat space
that short-lived keys already bound, purchased at the price of the
product's category.

---

## 4. The weakest point, confronted honestly

Obligation 2, no hedging.

**Support cost.** Party-held custody with the §3.2 tooling is not free.
Realistic estimate for years 1–3 (order-30 external parties, per the
docket's framing): building and maintaining the integration kit
(Terraform module, SDK, two clouds' KMS quirks) is weeks of initial
engineering and a permanent maintenance surface; each partner onboarding
still involves a cloud-permissions conversation the hosted model skips;
renewal failures will page someone. Expect a low-single-digit number of
"partner's ingestion stopped because their key expired" incidents per
year, each a support ticket and a mildly annoyed partner. Hosted signing
is genuinely simpler to operate. Estimated honest delta: on the order of
one engineer-month/year plus slower partner activation (days, not weeks).

**Expected leak rate.** Even with no key files, partners will leak cloud
credentials. Base rates for small-company credential compromise suggest
planning for **1–2 partner-compromise incidents in the first three
years** involving some forged-attestation window. This document does not
pretend the controls make the number zero.

**Does an early leak-and-forge incident damage the product more than
custody purity protects it?** This is the real question, and the answer
is no, for a structural reason: the two failure modes have different
*repair functions*. A partner-compromise incident is bounded, provable,
and reparable inside the system's own machinery, the log shows exactly
which attestations postdate last-known-good, `ledger_invalidated` marks
them, the registry shows the suspension, and the public story is "a
partner was compromised; the ledger's design detected, bounded, and
provably remediated it." That story, well-handled, *demonstrates* the
integrity machinery. CT survived CA compromises this way; the incidents
validated the log. The hosted-custody failure mode, the first time a
court, auditor, or journalist establishes that the operator can sign as
any party, has no repair function. It is not an incident; it is a fact
about the architecture, true every day since launch, retroactively
recoloring every attestation ever issued, and fixable only by the
migration to party-held custody plus the permanent asterisk that
everything before the migration was operator-forgeable. One failure mode
is an operational bad week; the other is the convergence-map's own
phrase: an existential credibility problem. Buy the bad week.

---

## 5. The hybrid position

The convergence map names two hybrids. Position:

**Rejected: hosted-by-default + BYO for parties that insist**
(security-infra's actual proposal). This makes operator-forgeable the
*default provenance* of the record. The BYO tier makes it worse, not
better: it concedes custody matters (else why offer it), creates a
two-class record in which most attestations carry the weaker provenance,
and, since `custody_model` is registry-only and the schema cannot
distinguish (founder decision 2), relying parties must learn that "party
signature" usually means "operator-mediated signature." The trust story
does not survive its own fine print.

**Adopted: party-held default + a bootstrap tier for small parties, where
the bootstrap tier still never gives the operator signing power.** The
tier structure that preserves the trust story:

- **Tier 1 (default): partner-side KMS via the integration kit** (§3.2a).
  Registry `custody_model: party_kms`.
- **Tier 2 (bootstrap): ledger-*provisioned*, partner-*owned*.** For a
  party too small to hold a cloud account, the ledger provisions a
  dedicated KMS key in a *separate provisioning account* and transfers
  the account/IAM ownership to the party at activation, keeping no access
  path. Concierge setup, no standing custody. Registry:
  `party_kms_provisioned`.
- **Tier 3 (sophisticated): party HSM / existing PKI.** `party_hsm`.
- **No tier in which the operator can invoke a registry-grade party key.**

Is the complexity worth it? Tier 2 is a runbook, not a system. The
marginal build over Tier 1 is small. The complexity that is *not* worth
it is the eIDAS-grade alternative: a certified SAM + party-held
activation-data stack that would make true hosted signing
forgery-impossible. That is the one honest form of hosted custody, and it
is a heavier build than the integration kit while converging on the same
property (party holds the control material). Skip it.

**Conceded to hosted, affirmatively: worker/peer account keys.**
Security-infra §2.3's last paragraph is right. Workers will never manage
key material, client-held keys convert the 6–11%/18-month device-loss
rate into career lockout for exactly the workers this system serves, and
peer attestations are already a structurally down-weighted, account-bound
trust class (design §2.2) whose provenance story is "this account said
it," not "this key-holding institution said it." Ledger-hosted signing
for person-account keys, with the recovery machinery of security-infra
§4, is the correct design and this brief does not contest it. The D4
fight is about registry-grade party keys only.

---

## 6. Concessions

1. **The steelman's facts are conceded:** the most probable forgery event
   in years 1–3 is partner-side compromise; partner key competence at
   partner #30 is poor; hosted signing is operationally simpler and its
   per-signature audit log is real. Contested is only the inference to
   operator custody.
2. **Party-held custody costs real support** (§4): ~an engineer-month/
   year, slower activations, expired-key incidents, and 1–2 expected
   compromise windows in three years.
3. **The category argument is partially a bet on scrutiny arriving.** If
   this product never faces a litigated dispute, a serious audit, or a
   sophisticated partner's diligence, i.e., if it fails early for other
   reasons, hosted signing would never have been caught, and the hosted
   design would have shipped faster. The bet is that the product's success
   case is exactly the case where scrutiny arrives.
4. **Registry compromise remains the shared ceiling.** Party-held custody
   does not protect against an operator who admits fraudulent parties;
   only the transparency log and vetting do. The claim is that custody
   should not *add* operator forgery of genuine parties to that ceiling.
5. **eIDAS-grade hosted signing (certified SAM, signer-held activation
   data) would satisfy the category argument.** It is rejected on cost,
   not principle; if it becomes commodity, the principled objection to a
   hosted tier built on it dissolves (trigger T4).

## 7. Switch triggers

Adopt hosted signing (in whole or as a tier) if:

- **T1. Leak rate exceeds the model.** ≥3 distinct partner-compromise
  forgery incidents within any 18-month window despite the §3.2 controls,
  or any single incident whose forged volume evades the probation/anomaly
  bounds by an order of magnitude.
- **T2. Partner acquisition measurably stalls on custody.** >25% of
  signed partner prospects fail or abandon integration at the
  key-provisioning step over two consecutive quarters, with the
  integration kit already at Tier-2 concierge level.
- **T3. Counsel concludes the category argument is legally inert:** a
  reasoned opinion that in the governing jurisdictions, attestations will
  be treated as the operator's business records regardless of key
  custody, and that relying parties' and regulators' assessments will not
  distinguish custody models. (This would refute §1.2, not §1.1, since the
  partner-diligence and narrative exposures survive, so T3 alone argues
  for the hybrid, not full hosted.)
- **T4. Sole-control hosted signing becomes commodity:** an
  EN 419 241-2-shaped (operator-cannot-sign-alone) managed service
  operable by this team at integration-kit cost. Then "hosted" no longer
  means "operator-forgeable," and the objection is moot by construction.
- **T5. The founder re-scopes the product** such that the ledger is
  openly a first-party system of record rather than a neutral recorder of
  party speech, in which case signatures are ceremony anyway and KMS
  hosting is the cheaper honest design.

Absent a trigger: party-held keys, partner-side KMS by default,
short-lived validity, provisioned-then-transferred bootstrap tier,
`custody_model` recorded in the registry, and no code path by which the
ledger can produce a registry-grade party signature.

---

## Sources

- [EN 419241-2:2019, QSCD Protection Profile for Server Signing (iTeh catalog)](https://standards.iteh.ai/catalog/standards/cen/6161a882-7bd0-4450-a2ca-bf20251d6382/en-419241-2-2019)
- [Cryptomathic, Exploring EN 419 241-2 certified QSCDs (sole control Level 2, SAM/HSM architecture)](https://www.cryptomathic.com/news-events/blog/eidas-qualified-remote-signing-exploring-en-419-241-2-certified-qualified-signature-creation-devices)
- [Utimaco, QSCDs under eIDAS: the Bank-Verlag Signature Activation Module](https://utimaco.com/news/blog-posts/qualified-signature-creation-devices-qscd-under-eidas-example-bank-verlag-signature)
- [atsec, eIDAS for remote (centralised server) signing](https://atsec.com/eidas-for-remote-centralised-server-signing/)
- [Thales, Qualified remote signatures with Luna HSMs (EN 419 221-5)](https://cpl.thalesgroup.com/blog/encryption/qualified-remote-signatures-luna-hsms)
- [cabforum/servercert issue #186, subscriber key generation by the CA as MUST NOT; Mozilla Root Policy §5.2 prohibition](https://github.com/cabforum/servercert/issues/186)
- [CA/Browser Forum, Code Signing Baseline Requirements (subscriber key protection in hardware)](https://cabforum.org/working-groups/code-signing/requirements/)
- [CA/Browser Forum, TLS Baseline Requirements](https://cabforum.org/working-groups/server/baseline-requirements/requirements/)
- [DLA Piper, Enforcing a disputed electronic signature (Aerotek, Inc. v. Boyd, Tex. 2021)](https://www.dlapiper.com/en-us/insights/publications/2021/06/enforcing-a-disputed-electronic-signature)
- [Fenwick, Using e-signatures in court: the value of an audit trail (FRE 901)](https://www.fenwick.com/insights/publications/using-e-signatures-in-court-the-value-of-an-audit-trail)
- [eSign Global, Common reasons e-signatures are rejected in court (2023 UK AES ruling)](https://www.esignglobal.com/blog/esignature-rejected-in-court-esignglobal)
- [LegalClarity, Non-repudiation in electronic signatures: legal meaning](https://legalclarity.org/non-repudiation-in-electronic-signatures-legal-meaning/)
- [AWS KMS EdDSA (Ed25519) support, Nov 2025](https://aws.amazon.com/about-aws/whats-new/2025/11/aws-kms-edwards-curve-digital-signature-algorithm/)
- Repo: `design/ledger-design-0.1.md` §3–4; `design/stack-perspectives/security-infra.md` §2; `design/stack-perspectives/convergence-map.md` D4; `research/04-attestation-trust-mechanics.md`; `research/06-adversarial-threat-model.md`
