# D4 Brief: Ledger-Hosted Party Signing by Default

Advocate brief in the stack litigation, docket item D4 (`convergence-map.md`).
Position argued: **party signing keys live in the ledger's KMS by default;
parties authenticate to a signing API; every signature is an auditable,
rate-limitable event.** Against: party-held keys as the default. School:
`security-infra` (§2.3). Adverse authority engaged: `ledger-design-0.1` §3
(assumes party-held keys), research `04`, research `06`, and the implicit
counter-position recorded in the convergence map.

---

## TLDR

1. **Third-party-verifiable non-repudiation is not load-bearing anywhere in
   the shipped product.** The only verifier in the system is the ledger's
   own read path: prior packets are generated at read time from the live
   record (design §7.2), no consumer receives raw signatures to verify
   offline, inclusion proofs in the packet are explicitly a 10⁸-scale
   deferral (security-infra §9), and the interface contract itself lists
   the party signature mechanism as *open item 3*, unresolved and hence not
   yet relied upon by anyone. What party signatures actually do today is
   (a) authenticate ingestion and (b) let the ledger attribute an
   attestation to a party in its own records. Hosted signing does both
   better.
2. **The realistic threat ranking is lopsided.** Leaked key files /
   credentials are the single most common breach vector on the internet
   (22% of breaches, #1 initial access vector, Verizon DBIR 2025; 28.6M
   secrets leaked to public GitHub in 2025 alone, 70% of 2022's leaks
   still live, per GitGuardian). Malicious insiders are 5% of North American
   breaches and 1% in APAC. The parties here are datacenter-staffing firms
   and training schools, not CAs. A party-held Ed25519 key *will* be a
   file in a CI secret; the base rates say that file leaks before the
   ledger's operator goes rogue.
3. **The non-repudiation objection is real but answerable**: hosted
   signing plus the day-one transparency log plus strong per-party
   authentication reconstructs ~90% of the non-repudiation story as an
   audit trail of *who asked for the signature*, and the missing ~10%
   (court-grade "the operator cryptographically could not have forged
   this") was never available anyway, because the operator runs the
   registry that decides which keys are valid.
4. **Compensating controls make the forgery-capable operator detectable
   and provable**: signing-request evidence committed to the transparency
   log, per-party KMS partitions with audit logs mirrored outside the
   blast radius, a party-visible feed of every signature made in their
   name, and periodic party countersignatures over their own issuance
   checkpoint. Cost: days of engineering, near-zero marginal ops.
5. **The hybrid (hosted-by-default + BYOK) is cheaper than either pure
   option** because the verification path is identical in both tiers,
   since custody changes only who calls KMS, and because pure party-held
   custody secretly *is* a hybrid already (nobody believes a Philippine
   ops firm and a hyperscaler partner get the same custody review).
6. **Conditional plea**: this position is contingent on D3 resolving to a
   day-one transparency log. Without the log, hosted signing loses its
   disciplining control and the objection wins. Switch-triggers below.

---

## 1. The objection, steelmanned

State it at full strength, because it deserves it:

If the ledger holds the party's key, then "party X signed this attestation"
reduces to "the ledger's database says party X asked the ledger to sign
this." The signature ceases to be independent evidence; it is a
cryptographically expensive restatement of the ledger's own row. Three
consequences follow:

1. **Evidentiary collapse.** A court, auditor, or partner's security team
   asking "could the ledger have forged this attestation?" gets the answer
   *yes, trivially, with a single API call its own IAM permits*. Under
   party-held keys the answer is "no, not without the party's key." The
   entire product is the assertion that an attestation was really made by
   that party (security-infra §1, TLDR-1); hosted signing makes that
   assertion rest on the operator's honesty rather than mathematics.
2. **Insider-risk concentration.** The design already concedes the
   operator is the single root of trust for the *registry* (design §3.3).
   Hosted signing extends that to the *signatures themselves*: a
   compromised insider or deploy pipeline no longer needs to corrupt the
   registry's key-validity records. It can just sign. The blast radius of
   operator compromise goes from "can admit bad keys" to "can fabricate
   any party's speech."
3. **Precedent asymmetry.** eIDAS-grade and CA-grade trust systems are
   built on the issuer holding its own key precisely so that
   cross-organizational attribution survives the infrastructure operator's
   failure. Research `04` models the registry on eIDAS/CA-Forum mechanics;
   hosted signing deviates from the model at its most sensitive joint.

This is the strongest form. The rebuttal must not minimize it.

## 2. Rebuttal

### 2a. What the signature is actually for, per the spec, not the vibes

The objection assumes a verifier who is *not* the ledger. Search the
corpus for that verifier:

- **The prior packet is generated at read time from the live record,
  "never stored"** (design §7.2). Consumers receive a packet through the
  ledger's authenticated read path under an active grant. They do not
  receive detached JWS envelopes to verify against an independent key
  distribution channel. The schema (`attestation-interface.md`) carries
  `issued_at · signature` inside a packet the ledger assembles; the
  consumer's trust anchor is the ledger connection, full stop.
- **Offline verifiability is explicitly deferred.** "Inclusion proofs in
  the prior packet and offline-verifiable packet format. Build when a
  consumer asks" (security-infra §9). Research `04` TLDR-8: provable
  non-tampering without querying the live API is "not needed at launch."
  No perspective, and no founder decision, names a v1 consumer who
  verifies party signatures independently.
- **The interface contract lists the party signature mechanism as open
  item 3**, the one thing everyone agrees is *not yet* settled. Nothing
  downstream can currently be load-bearing on a mechanism the contract
  says is undecided.
- **The registry already interposes the operator on every verification.**
  Design §3.2: signatures are "verified against the registry." Whoever
  controls the registry controls which public keys count as party X. A
  malicious operator under *party-held* custody does not need the party's
  key to forge. It registers a new key for the party, backdates the
  validity window, and signs with that. The design's own answer to this
  (§3.3 residual risk) is the transparency log over registry events, i.e.,
  the same control that disciplines hosted signing. **Party-held custody
  does not remove the operator from the trust path; it only adds one
  extra step to the operator's forgery playbook.** The objection's clean
  dichotomy, "party-held = math, hosted = trust," is false in this
  architecture. Both custody models reduce to: trust the operator, checked
  by the log.

So: the signature's real jobs in the shipped system are ingestion
authentication, internal attribution, and *future-proofing* toward offline
verification. Hosted signing serves the first two strictly better (every
signature is an authenticated, logged, rate-limited event) and does not
foreclose the third (BYOK tier, §4; inclusion proofs work identically over
hosted-signed entries).

### 2b. Threat ranking, with base rates

Who forges an attestation in years 1–3, ranked by evidence:

**1. Partner-side key/credential leakage, dominant.**

- 28,649,024 new secrets leaked in public GitHub commits in 2025, +34%
  YoY, the largest jump on record; 23.8M in 2024; **70% of secrets leaked
  in 2022 were still active** years later ([GitGuardian State of Secrets
  Sprawl](https://www.gitguardian.com/state-of-secrets-sprawl-report-2026),
  [2025 edition](https://blog.gitguardian.com/the-state-of-secrets-sprawl-2025/)).
  AI-assisted commits leak at roughly 2× baseline, and the partners in
  question will be writing their ledger integration with AI assistance.
- Stolen credentials were the **#1 initial access vector** in the 2025
  Verizon DBIR (22% of breaches; 88% of Basic Web Application attacks
  involved stolen creds) ([DBIR 2025 analyses](https://www.descope.com/blog/post/dbir-2025),
  [Aembit](https://aembit.io/blog/credential-and-secrets-theft-2025-verizon-data-breach-report/)).
- The party population at 1M identities: internal verticals plus early
  external partners, a datacenter-staffing company, a training school
  (security-infra §2.3). These organizations do not run HSMs. Their
  Ed25519 private key is a PEM file in a config repo, a CI secret, or a
  shared vault readable by contractors. It is exactly the artifact the
  GitGuardian numbers describe. And a leaked party key produces forgeries
  that **verify perfectly**. The registry machinery is useless against
  them until someone notices and files a compromise report, after which
  §3.3's timestamp rule only protects *pre*-report history.

**2. Party-side fraud within the rules, the top risk research `06`
actually names.** Research `06` TLDR-2: party-attestation fraud
(diploma-mill dynamics, collusive inflation, retaliation) is the
underweighted, probably-larger risk, and the effective countermeasure is
**network-structure anomaly detection on the party×subject graph** plus
enforceable volume caps. Hosted signing hands this layer a complete,
real-time, per-signature feed for free, and makes probation volume caps
(design §3.1) enforceable *at the signing endpoint* rather than
after-the-fact at ingestion. Party-held keys give the fraud layer nothing
until the envelope arrives.

**3. Ledger insider/operator, real but rare and already assumed.**
Insider-originated breaches: ~5% in North America, 1% in APAC (29% in
EMEA is the outlier) per DBIR 2025 regional cuts
([Keepnet summary](https://keepnetlabs.com/blog/2025-verizon-data-breach-investigations-report)),
and insider incident counts *fell* 41% YoY. More importantly: the insider
threat exists **identically under party-held custody** via registry
manipulation (§2a) and via everything else the operator controls (the read
path, the standing derivation, the packet assembly). Hosted signing does
not create the operator-trust assumption; it relocates one more operation
inside a perimeter that is, uniquely among the alternatives,
instrumented with KMS audit logs and a Merkle log.

The asymmetry in one sentence: **the partner-leak threat is
high-probability and invisible under party-held custody; the operator
threat is low-probability and maximally visible under hosted custody.**
Security architecture should put the invisible failure mode in the
instrumented perimeter, not outside it.

### 2c. Reconstructing non-repudiation: from "who held the key" to "who
### asked for the signature"

The industry has already run this migration once. Sigstore's keyless model
exists because long-lived signer-held keys were the failure mode, described
as a scheme where "keys get stored in CI secrets, shared across teams, and
rarely rotated; a leaked signing key compromises every artifact signed with
it." Its replacement for key possession is **identity-bound ephemeral
signing recorded in a transparency log** ([Sigstore overview](https://docs.sigstore.dev/about/overview/)).
Attribution moved from "possession of key material" to "authenticated
identity + immutable log entry," and the software-supply-chain world
accepted that as *stronger*, not weaker, evidence. This system should make
the same move, with the same ingredients:

1. **Strong per-party authentication to the signing endpoint.** No static
   API keys. OIDC workload identity or mTLS for machine callers;
   hardware-bound WebAuthn, named individual accounts, and step-up re-auth
   for the party console (security-infra §4.4). The audit question "who
   asked for this signature" resolves to a specific authenticated
   workload or a specific named human with a hardware credential, which
   is *more* forensic resolution than a bare Ed25519 signature ever
   provides (a signature proves key possession; it says nothing about
   which of the five contractors with vault access used it).
2. **Signing-request evidence in the transparency log** (see §3, control
   C1): every log entry for a hosted-signed attestation commits to the
   authenticated caller identity and request metadata, checkpointed
   outside the operator's blast radius hourly from day one, publicly
   witnessed from the first external party (security-infra §3.3).
3. **KMS audit trail as the second, independent record.** Every KMS sign
   call is logged by the *cloud provider*, shipped to a locked separate
   account (security-infra §3.5). A forged signature therefore requires
   simultaneously fabricating the application log, the transparency log
   (impossible after witnessing), and the cloud provider's audit log, an
   evidence trail no party-held-key forgery ever leaves.

What is genuinely not reconstructed: the ability to convince a maximally
skeptical third party that the operator *could not* have signed, using
cryptography alone. Conceded in §5. The claim defended here is narrower
and sufficient: for every verifier that actually exists in this product's
first years, "authenticated request + witnessed log + provider audit
trail" answers "did party X make this attestation?" at least as well as a
signature from a key file of unknown custody, and answers "when, from
where, by whom within party X" far better.

### 2d. Operational reality at partner #30

Walk the party-held default forward to thirty partners, supported by three
people:

- **Onboarding**: each partner must generate an Ed25519 keypair correctly,
  store it somewhere reviewable, and deliver the public key
  authentically. The ledger must either (a) run a custody review per
  partner, which is unstaffable, or (b) accept whatever they did, which is the
  CI-secret scenario the base rates price. Each partner must implement
  canonicalization + JWS signing correctly; canonicalization drift is "the
  classic silent signature-infrastructure failure" (planet-scale §4.2).
  Thirty partners means thirty independent implementations of the most
  fragile step, in whatever language their contractor picked.
- **Steady state**: key rotation reminders, expiring-key incidents,
  "we lost the key" tickets, "our new vendor needs the key" emails
  (each one a custody breach the ledger never learns about), and
  compromise response that depends on the partner *noticing* the leak,
  which the GitGuardian 70%-still-active figure says they don't.
- **Support burden**: every signature failure at ingestion is a
  cross-organization debugging session ("your envelope doesn't verify")
  landing on a 3-person team. This is the highest-friction possible
  integration contract with the least-capable possible counterparties.

Hosted default, same milestone: onboarding is an OIDC federation or mTLS
cert exchange plus a console login; signing is `POST /sign` with a
canonical payload the *ledger's* SDK canonicalizes (one implementation,
golden-vectored, in the trust kernel); rotation is invisible to the
partner; compromise response is one IAM change (freeze the endpoint) with
a rehearsed runbook (security-infra §2.4.1); and every partner-side
integration bug surfaces as a 4xx with a reason, not a cryptographic
mystery. The convergence map already agrees the scaling wall is the
constitutionally-human queues (settled point 11). Party key support under
party-held custody is a new human queue the docket hasn't priced.

## 3. The weakest point, confronted: a forgery-capable operator

Hosted signing makes the ledger a single point that *can* fabricate any
hosted party's speech. Compensating controls, with costs:

- **C1. Mandatory signing-request evidence in the transparency log.**
  Every hosted-sign log entry commits to: authenticated caller identity
  (OIDC subject / mTLS cert fingerprint), request timestamp, payload
  commitment, and the signing key's `custody_model`. Forgery by the
  operator now requires inventing a caller identity inside an entry that
  is hourly-checkpointed off-blast-radius from day one and externally
  witnessed from the first external party, i.e., the forgery is
  permanent, provable evidence against the operator. *Cost: one field
  family in the log entry schema + kernel review of the path; days.*
- **C2. Per-party KMS partitions.** One key ring per party, IAM-isolated;
  the signing service holds per-party grants, not a wildcard. An
  application-layer compromise of one party's endpoint cannot sign as
  another. *Cost: IaC templates; near-zero marginal.* (Per-party HSM
  protection level is a parameter flip when a partner demands it,
  per security-infra §9.)
- **C3. The party sees every signature made in its name.** The party
  console renders a live feed and monthly statement of every sign event on
  their keys (mirroring the worker-visible read log, §7.1's symmetry). A
  signature the party didn't request is detected by the one entity with
  perfect knowledge of what it asked for. *Cost: one console view over the
  log; small.*
- **C4. Party countersignature over its own issuance checkpoint.**
  Periodically (monthly, or at each registry event) the party
  countersigns the Merkle root covering its issuance history, using a
  *party-held* low-frequency acknowledgment key or even a documented
  out-of-band approval. This restores a party-held cryptographic commitment at
  the aggregate level without per-signature custody burden: the operator
  can forge an attestation but cannot obtain the party's countersignature
  over a history containing it. *Cost: modest. One more key per party,
  but used rarely and low-ceremony; the honest price of the strongest
  variant. Ship C1–C3 at launch; C4 at the first external party alongside
  public witnessing.*
- **C5. BYOK for parties that insist** (§4).

Residual risk after C1–C4: an operator forgery is possible for the window
between issuance and the party's next feed review/countersignature, and is
then *provable* rather than deniable. That is the same
"prevent-where-cheap, prove-always" posture the insider section
(security-infra §3.5) already adopts for every other operator power,
including the database itself, the registry, and the read path. Hosted signing adds no
qualitatively new operator capability; it adds one more instance of an
already-accepted risk class, with better instrumentation than any of the
existing instances.

## 4. The hybrid, designed honestly

**Hosted-by-default + BYOK tier.** Registry records `custody_model` per
key: `ledger_hosted | party_kms | party_hsm` (security-infra §2.3). Does
two-tier complexity exceed either pure option? Component by component:

- **Verification path: identical.** Ingestion verifies an Ed25519/JWS
  envelope against the registry regardless of who called KMS. Zero added
  verification complexity. This is the decisive fact. The tiers differ
  only *upstream* of the envelope.
- **Added by the hybrid**: the `custody_model` enum; a custody-review
  checklist for BYOK applicants (a one-page questionnaire + attestation of
  KMS/HSM custody, the review the pure party-held model would need for
  *every* party, run only for the few who opt in); two compromise-runbook
  variants (both already written, security-infra §2.4.1–2); read-time
  trust weighting *may* consult custody model, but founder decision 2
  already requires the attestation schema itself to be
  custody-indistinguishable, so no schema fork exists.
- **Compared to pure party-held**: the pure option needs key-delivery
  ceremonies, rotation support, and compromise handling for *all N*
  parties, including the ones structurally incapable of custody. The
  hybrid needs it only for the capable, opted-in few. The hybrid is
  strictly less operational surface than pure party-held.
- **Compared to pure hosted**: the hybrid adds the BYOK path, real but
  small, and it buys the exit ramp: any party (or regulator) for whom
  hosted custody is unacceptable has a standing, non-emergency answer.
  Without it, the first "we must hold our own key" partner is a schema
  crisis; with it, a checkbox.
- **Honest risks of the hybrid**: (1) BYOK as status signal, partners
  inferring hosted = second-class. Mitigated by decision 2's schema
  symmetry and by *not* surfacing custody model in packets. (2) The BYOK
  path atrophying untested, mitigated by making one internal vertical run
  BYOK permanently as the canary. (3) Trust-weighting on custody model
  quietly becoming a visible tier, forbidden for the same reason party
  scores are (design §3.5); custody feeds registry decisions, never
  consumer-visible weight.

Verdict: the two-tier system's complexity is a bounded superset of pure
hosted and a strict subset of honest pure party-held. Adopt it.

## 5. Concessions and switch-triggers

**Conceded:**

1. **Court-grade non-repudiation is genuinely weaker.** Under hosted
   custody, "could the operator have forged this?" is answered
   "yes-but-provably," not "no." For any future in which attestations must
   stand as qualified-signature-grade evidence against a hostile,
   log-distrusting tribunal, party-held (party_hsm) custody is the right
   answer, and this brief's default is wrong for that party class.
2. **The insider-concentration point is directionally true.** Hosted
   signing enlarges what a maximally-privileged insider can do before
   detection, even though detection is guaranteed. C1–C4 shrink the
   window; they do not close it.
3. **The base-rate argument is an analogy, not a measurement.**
   GitGuardian/DBIR describe secrets and credentials generally, not
   attestation-signing keys specifically; research `06` itself flags that
   no system like this ledger exists at scale to measure. Directionally
   strong, quantitatively loose, the same caveat class as `06` §2.
4. **This position is conditional on D3.** Hosted signing without a
   day-one transparency log is the pragmatist's "trust us" with extra
   steps. If D3 resolves to deferred/checkpoint-only anchoring, the
   compensating-control story collapses and the D4 default should flip to
   party-held with mandatory custody attestation (security-infra
   assumption 4's stated fallback).

**Switch-triggers, flip the default (globally or per party class) to
party-held/BYOK-mandatory if any of these occur:**

- Counsel or a regulator concludes attestations require
  eIDAS-QES-analog non-repudiation (issuer sole control of the key) in a
  target jurisdiction.
- Offline packet verification ships as a real product feature and a
  consumer class emerges that demands operator-independent signature
  provenance, not just inclusion proofs.
- A partner class materializes with genuine KMS/HSM capability *and*
  contractual insistence, then BYOK stops being the exception tier for
  that class.
- An operator-side signing incident occurs (even a provable, contained
  one): the deterrence model has then failed empirically and custody must
  move outward.
- D3 resolves against the day-one log (above).

**Ask of the court:** adopt hosted-by-default with `custody_model` in the
registry, controls C1–C3 at launch and C4 at first external party, BYOK
available under custody review, and the switch-triggers recorded in the
partner agreement template, because D4 "changes the partner integration
contract" (convergence map) and the triggers must be contractual, not
aspirational.

---

### Sources

- [GitGuardian, State of Secrets Sprawl 2026 (28.6M secrets in 2025, +34% YoY; AI-assisted leak rates)](https://www.gitguardian.com/state-of-secrets-sprawl-report-2026)
- [GitGuardian, State of Secrets Sprawl 2025 (23.8M in 2024; 70% of 2022 leaks still active)](https://blog.gitguardian.com/the-state-of-secrets-sprawl-2025/)
- [Verizon DBIR 2025, credential-theft findings (22% of breaches; 88% of BWA attacks)](https://www.descope.com/blog/post/dbir-2025)
- [Aembit, Credential and Secrets Theft in the 2025 DBIR](https://aembit.io/blog/credential-and-secrets-theft-2025-verizon-data-breach-report/)
- [Keepnet, 2025 DBIR summary (insider share by region: NA 5%, APAC 1%, EMEA 29%; insider count −41% YoY)](https://keepnetlabs.com/blog/2025-verizon-data-breach-investigations-report)
- [Sigstore, Overview (keyless signing rationale: identity + transparency log over long-lived keys)](https://docs.sigstore.dev/about/overview/)
- Repo: `design/ledger-design-0.1.md` §3, §7.2; `design/stack-perspectives/security-infra.md` §2.3–2.4, §3, §4.4, §9; `design/stack-perspectives/planet-scale.md` §4.2; `handoff/attestation-interface.md` (open item 3); `research/04-attestation-trust-mechanics.md`; `research/06-adversarial-threat-model.md`.
