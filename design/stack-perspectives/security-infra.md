# Stack Perspective: Security Infrastructure

One of six independent technical-design perspectives. Persona: the
security-infrastructure architect. Written against `design/ledger-design-0.1.md`,
`handoff/attestation-interface.md`, `research/00`, `04`, `06`, `07`, and
current (2026) state of cloud KMS, transparency-log tooling, and passkey
adoption. Clean context; no other perspective read.

Operating facts honored: founder + 2 engineers, AI-build-heavy, greenfield,
~1M identities in months, ~10⁸ in two years, global users, capital unlimited
conditional on success.

---

## TLDR

1. **The security architecture is the product architecture.** This company
   sells exactly one thing: the assertion that an attestation in the ledger
   was really made, by that party, at that time, and was never altered. An
   outage costs a week of growth; a single demonstrated forgery or silent
   mutation costs the company its reason to exist. Every trade-off below is
   priced against that asymmetry.

2. **No signing key ever exists as a file. Cloud KMS from day one, for the
   ledger's keys and for most parties' keys.** Both AWS KMS (Nov 2025) and
   GCP Cloud KMS now support Ed25519 natively, so the historical
   "KMS forces you off Ed25519" objection is dead. Non-extractable keys,
   signing as an authenticated API call, every use in the cloud audit log.
   For internal verticals and ordinary external partners, the ledger *hosts*
   party keys in KMS under per-party isolation, contrarian, argued in §2.3:
   a key file on a partner's laptop is the single most likely forgery vector
   in this entire system, and hosted signing eliminates it while keeping
   every signature auditable. Sophisticated partners may BYO key; the
   registry records the custody model per key.

3. **The ledger's own signing authority is run as a small CA**: an offline
   root created in a documented, witnessed ceremony; online issuing keys in
   KMS signed by that root; the root touches nothing day-to-day. At three
   people this is one afternoon of ceremony and a written runbook, not an
   HSM cage.

4. **Build a real Merkle transparency log from day one, not the deferred
   "hash chain now, Merkle in v2" in ledger-design-0.1 §3.3.** The cost
   argument for deferral died in October 2025 when Rekor v2 went GA on
   tile-based Tessera (modernized Trillian): cheap, object-storage-backed,
   CDN-cacheable, explicitly designed for minimal-maintenance self-hosting.
   The integrity spine's commitments, the party registry's lifecycle events,
   and the key-event log all go into the log. Signed checkpoints exist from
   launch; they become *public* (external witness co-signed) no later than
   the first external attesting party's activation or 1M identities,
   whichever comes first. This is the only control that protects the record
   against the ledger operator itself, including a compromised insider or a
   compromised deploy pipeline, and it cannot be retrofitted credibly after
   an incident.

5. **Account recovery, not login, is the worker-auth attack surface.**
   Takeover of a ledger identity is worse than a bank-account takeover: the
   attacker inherits an attestation-grade professional identity. Design:
   passkeys primary (≈5B in active use globally in 2026, but 6–11% of users
   lose all devices within 18 months, recovery is mandatory, not an edge
   case); SMS never as a sole factor anywhere (number recycling, SIM-swap);
   and the load-bearing rule, **recovery strength must equal the account's
   derived assurance level**. A document-verified profile can only be
   recovered by re-clearing document verification with a registered
   verification provider; email/phone alone can never recover it. Time-locked
   recovery with multi-channel notification for any account with attested
   history.

6. **Deletion is implemented as row purge + per-person crypto-shred.** Every
   person's payload data is encrypted under a per-person DEK wrapped by a
   KMS KEK. R2 deletion purges rows in the primary and destroys the DEK,
   which renders every backup, replica, and analytics copy unreadable
   without hunting them down. This is the only honest way to make "purged
   within a fixed published window" true in a real system with backups. Spine
   commitments are salted (HMAC with a per-record key held in the payload
   plane), so post-deletion the retained hashes are unlinkable. This
   materially strengthens the EDPB posture that ledger-design-0.1 §2.1 only
   flags.

7. **AI-written code changes the SDLC, and the answer is a frozen, human-read
   trust kernel plus machine-verifiable gates for everything else.** The
   signing/verification/canonicalization/log-append core is kept under
   ~3,000 lines, read line-by-line by two humans, fuzzed, property-tested
   against golden vectors, and externally audited before the first external
   party. Everything outside the kernel is defended by CI gates that do not
   care who wrote the code: static analysis, dependency allowlist (no new
   dependency without named human approval), secret scanning, invariant
   tests that prove append-only and verification behavior end-to-end, and
   signed reproducible builds so what runs is what was reviewed.

8. **Universal signup is a standing invitation to abuse; make signup cheap
   to serve and expensive to weaponize.** CDN/WAF in front of everything,
   layered rate limits (device, IP, ASN), no user-existence oracles,
   non-enumerable IDs, and risk-gating on the expensive operations
   (verification, packet reads) rather than friction on account creation,
   which founder decision 3 forbids gating anyway.

9. **Infrastructure this forces:** one major cloud (GCP has the edge:
   Cloud KMS Ed25519, Tessera/Trillian lineage, Cloud Audit Logs), Postgres
   as system of record, Tessera tiles on object storage for the log,
   memory-safe languages only, a Go or Rust trust kernel, TypeScript
   permitted at the API/product layer. **Forbidden:** keys in files or env
   vars, self-managed physical HSMs (a 3-person team cannot staff dual-person
   physical custody), blockchain anchoring, direct production DB write access
   for humans, SMS-only anything, and any bespoke cryptography.

---

## 1. Why security-first is the correct frame, priced honestly

The record's entire value is that a reader can rely on it without trusting
the subject, and mostly without trusting the reader's counterparty. Research
`06` already establishes that party-attestation fraud is the top adversarial
risk *within the rules*; this perspective adds the layer below it: the
integrity of the machinery itself. Three failure classes, in descending
order of company-ending-ness:

1. **Forgery.** An attestation that verifies but was never made by the
   named party (stolen/leaked party key, compromised signing path).
2. **Mutation.** History silently altered or deleted by whoever operates
   the database (external attacker with operator access, insider, or a
   poisoned deploy).
3. **Impersonation.** An account takeover that lets an attacker act as a
   worker or a party through the front door.

Class 1 is defeated by key custody (§2). Class 2 is defeated only by
tamper-evidence the operator cannot bypass (§3). Class 3 is defeated by
auth and recovery design (§4). Everything else, WAFs, scanners, SDLC, is
in service of these three.

The honest cost statement: everything mandated as non-negotiable in this
document is operable by three people because it is *managed-service-shaped*
(KMS, cloud audit logs, a tile log on object storage, CI gates). The things
that are genuinely expensive for a 3-person team, 24/7 SOC, physical HSM
custody, formal verification, SOC 2 theater, are explicitly deferred or
rejected below. Security architecture is cheap when it is architecture;
it is expensive when it is staffing. Buy architecture now, staffing later.

---

## 2. Signing and key architecture

### 2.1 The ledger as a certification authority

Ledger-design-0.1 already concedes "the ledger operator is the single root
of trust" (§3.3, residual risk). Then run it like one:

- **Offline root key.** Ed25519, generated in a one-time documented ceremony:
  air-gapped machine, two-of-three founder/engineer custody of shares
  (Shamir or simply two hardware tokens in separate physical custody),
  written minutes, the public key published and pinned in every client and
  in the transparency log's first checkpoint. The root signs exactly three
  things: issuing keys, log-checkpoint keys, and its own eventual rotation
  statement. It is used a handful of times per year.
- **Online issuing keys in cloud KMS.** These sign what the ledger itself
  asserts: `ledger_invalidated` attestations (§3.4 of the design), registry
  lifecycle events, log checkpoints, packet envelopes if packets are signed.
  Non-extractable, rotated on a schedule, each rotation a signed, logged
  event chaining to the root.
- **Why this matters at 1M, not just 10⁸:** the first external partner's
  security questionnaire will ask "who can sign as you and where does that
  key live." "An API-gated KMS key, chained to an offline root, with every
  use in an immutable audit log" is a one-line answer that closes deals.
  "A key in our deploy secrets" is a finding.

### 2.2 Ed25519 in KMS is no longer a compromise

The design's Ed25519/JWS choice (§3.2) is right and is now fully
KMS-compatible: GCP Cloud KMS supports Ed25519 including HSM-backed, and
AWS KMS added EdDSA/Ed25519 in November 2025, all regions. There is no
remaining reason for any signing key in this system, ledger or party, to
exist as extractable key material. Latency (~10–50ms per KMS sign) is
irrelevant at attestation volumes: even 10⁸ identities producing an
attestation a month is ~40 signs/second globally, trivially within KMS
quotas and parallelizable per party key.

### 2.3 Party keys: ledger-hosted signing by default

The contrarian call, argued in full. The design assumes parties hold their
own Ed25519 keys and submit JWS envelopes. Consider who the parties are at
1M identities: internal verticals (same operator) and early external
partners, a datacenter-training company, a Philippine ops firm. None of
these will run KMS-grade key custody. Their key will be a file: in a
config, in a CI secret, on a laptop, in a shared vault five contractors can
read. **The most probable forgery event in this system's first three years
is not a cryptanalytic break or a ledger breach. It is a partner's key file
leaking, followed by fraudulent attestations that verify perfectly.** The
verify-against-registry machinery is exactly useless against it, and §3.3's
"flag post-compromise-report attestations" only helps after someone notices.

Therefore:

- **Default custody model: the ledger hosts the party's signing key in KMS**,
  in a per-party key ring with IAM isolation. The party never sees key
  material; it authenticates to a signing endpoint (OIDC workload identity
  or mTLS, no static API keys) and submits the canonical payload; the
  service signs and returns the envelope. Every signature is thereby an
  authenticated, rate-limited, anomaly-scannable, individually-logged API
  event. The party-fraud detection of design §3.5 gets a complete,
  real-time feed for free, and probation volume caps become enforceable at
  the signing endpoint instead of at ingestion.
- **This does not weaken non-repudiation in practice.** Yes, hosted signing
  means the operator *could* sign as the party, but the operator already
  runs the registry that decides which keys are valid, so registry-level
  trust in the operator is assumed either way (design §3.3 says so). What
  disciplines the operator is the transparency log (§3 below): a forged
  entry is permanently, provably in the log, attributable to an exact
  operator action in the KMS audit trail. Meanwhile the realistic threat,
  partner-side leakage, is eliminated, not mitigated.
- **BYO-key remains available** for parties that can pass a custody review
  (their own KMS/HSM, attested), and the registry records `custody_model`
  per key: `ledger_hosted | party_kms | party_hsm`. Read-time trust
  weighting may use it; the attestation schema, per founder decision 2,
  cannot.
- Peer-attestation account keys are ledger-hosted by the same machinery.
  Workers will never do client-side key management, and pretending otherwise
  is how "decentralized" designs get people locked out of their own careers
  (§10).

### 2.4 Key-compromise runbook (exists before the first external party)

A one-page, rehearsed procedure per scenario, each ending in signed,
logged, append-only events:

1. **Party key compromise (hosted):** freeze the party's signing endpoint
   (single IAM change), mark key `compromised` in the key-event log, issue
   new key, sweep all signatures after last-known-good against the
   anomaly feed, notify party, publish the event in the log.
2. **Party key compromise (BYO):** registry marks key compromised with
   report timestamp; §3.3 verification rule (design) does the rest; suspect
   window swept and flagged.
3. **Ledger issuing-key compromise:** revoke in KMS, root signs a revocation
   + successor statement, checkpoint the log, re-sign nothing (history is
   protected by log inclusion, not by re-signing, this is why the log must
   exist first).
4. **Root compromise:** the company-ending scenario; the answer is the
   ceremony's physical custody making it a physical theft of two artifacts
   plus the published successor procedure. Documented, never improvised.
5. **Insider/operator compromise:** see §3.5.

---

## 3. The transparency log: day one, not v2

### 3.1 Why the deferral in ledger-design-0.1 §3.3 is wrong

The design builds a hash chain now and defers Merkle/CT-style proofs and
the public commitment log "to v2." Three objections:

1. **The threat it defends against is present from day one.** The hash
   chain proves ordering *to the operator's own database*. It does nothing
   against the operator. A compromised admin account, a poisoned deploy, or
   an engineer under coercion can rewrite the chain wholesale and re-hash.
   Tamper-*evidence* requires commitments that leave the operator's control
   (witnessed checkpoints). The most dangerous window for silent rewriting
   is precisely the early one, before external scrutiny exists.
2. **The credibility asymmetry.** A transparency log started at launch
   proves the whole history. One started after an incident, or after a
   partner demands it, proves only the future, and the gap is permanent.
   "Our log covers everything since the first attestation" is a sentence
   worth real money in every partner negotiation for the life of the
   company.
3. **The cost argument expired.** This was a fair deferral in the Trillian
   era (log server + signer + MySQL + ops). Rekor v2 went GA in
   October 2025 on Trillian-Tessera: tile-based, object-storage-backed,
   reads fully CDN-cacheable, explicitly built for low-cost minimal-
   maintenance private deployments, prebuilt containers. Running one is now
   comparable in effort to running a queue. A 3-person team can do it;
   the research corpus's own `04` TLDR-8 said retrofitting is the expensive
   path.

**Recommendation: adopt Tessera (the library under Rekor v2) directly as
the spine's append mechanism** rather than bolting Rekor's
software-supply-chain entry types onto attestations. Evaluate running
rekor-tiles as-is first. If its entry model fits the attestation envelope,
take the maintained system; if not, Tessera-on-GCS/S3 with our own entry
schema. Postgres remains the queryable system of record; the log is the
integrity authority; a reconciliation job proves they agree and alerts on
divergence (that alert is the tamper alarm).

### 3.2 What goes in the log

Three entry families, one tree (or three trees under one checkpoint, an
implementation choice):

1. **Attestation commitments.** The integrity-spine tuple: object ID,
   type, subject/issuer refs, salted payload commitment, signature hash,
   supersession pointer. This *is* the "ledger hash-chain timestamp at
   write" of design §3.3, upgraded to carry inclusion proofs.
2. **Registry and key lifecycle events.** Party registered / suspended /
   revoked, key registered / rotated / compromised. This is the CT-style
   commitment log over registry changes that the design itself names as the
   hardening for operator-as-single-root, delivered in v1. A malicious
   operator can no longer quietly backdate a key's validity window or
   un-suspend a party without leaving a provable record.
3. **Privileged operations.** Merges/unmerges, deletions (as anonymous
   tombstone events: "person-scope deletion executed," no identity
   linkable post-shred), break-glass access, invalidation attestations,
   deploy attestations (§6).

### 3.3 Checkpoints and witnesses, the schedule

- **Launch:** checkpoints signed hourly by a dedicated KMS checkpoint key
  (chained to root); retained internally and mirrored to a second cloud
  account with independent credentials (cheapest possible "outside the blast
  radius" witness).
- **First external attesting party OR 1M identities (whichever first):**
  checkpoints become public, published to an immutable public endpoint, and
  co-signed by at least one independent witness (the witness-network
  pattern from CT/sumdb; a partner, an auditor, or a public witness service
  can hold this role). From this point, silent rewriting is provably
  impossible rather than merely detectable by us.
- **10⁸ scale:** multiple witnesses across jurisdictions; year-sharded logs
  (the Rekor v2 pattern, log2026, log2027, which also bounds tree size and
  makes long-term crypto migration tractable); offer inclusion proofs in
  the prior packet so a consumer can verify an attestation offline.

### 3.4 Deletion compatibility (the part everyone gets wrong)

A Merkle log is append-forever, and R2 demands erasure. The two-plane
design already solves the structure; the log must solve the *linkability*:

- Log entries carry **salted commitments**, HMAC(payload, k_r) with a
  per-record random key k_r stored in the erasable payload plane, never
  bare hashes of payload. EDPB guidance treats hashes of personal data as
  personal data; a bare hash of a low-entropy payload is dictionary-
  attackable. On R2 deletion, k_r is destroyed with the payload: the
  retained commitment becomes an unlinkable random value, the tree stays
  intact, inclusion proofs for everyone else's history are unaffected.
- Subject references in log entries are the opaque `ledger_person_id`,
  which the design already tombstones without reuse; post-deletion the ID
  resolves to nothing readable.

This turns the design's "strong mitigation, not a jurisdictional guarantee"
caveat (§2.1) into the strongest technically available posture.

### 3.5 Insider threat, sized for three people

Classic dual-control is impossible at this headcount for daily operations.
The honest substitution is *prevent where cheap, prove always*:

- **No human write path to production data.** All mutations go through the
  service, which appends to the log. No `psql` into prod. Break-glass
  exists (sealed credential, two-person unseal, auto-expiring), and its use
  is itself a logged, checkpointed event.
- **Dual control reserved for the three operations that warrant it:** root
  key ceremonies, trust-kernel merges (§6), and break-glass unseal.
- **Everything else: detection over prevention.** Cloud audit logs shipped
  to a locked, separate account; the log reconciliation alarm; anomaly
  review of admin actions. An insider at a 3-person company cannot be
  stopped by process from *acting*. They can be guaranteed to leave
  indelible, checkpoint-anchored evidence. That guarantee, stated publicly,
  is also the deterrent.

---

## 4. Worker and party authentication, globally

### 4.1 Threat framing

The account is the pen that signs grants, files disputes, accepts
verifications, and, catastrophically, executes R2 deletion. Takeover =
career impersonation plus the ability to *destroy the victim's record
irreversibly* (delete + re-signup as them). Recovery flows, not login
forms, are where identity systems are actually broken; that is where the
design effort goes.

### 4.2 Login

- **Passkeys primary.** 2026 reality: ~5B passkeys in active use, ~75% of
  consumers have enabled at least one; Android penetration makes platform
  authenticators viable even at the emerging-market end of the user base.
  Password fallback exists (argon2id, breach-list checked) because forcing
  passkey-only on shared-device users locks out exactly the workers this
  system is for.
- **Phone/email are channels, not factors of record.** Consistent with
  design §1.2. SMS OTP may serve as *one* signal in low-risk step-up, never
  as a sole authentication or recovery path (SIM-swap, 45–90-day number
  recycling, carrier-store social engineering; regulators began phasing out
  SMS OTP for financial auth in 2025–26).
- **Shared-device reality (emerging markets):** short sessions on untrusted
  devices, no silent persistent login on first use, re-auth for
  consequential actions (grants, deletion, disputes). Device-binding is a
  risk signal, never a lockout criterion. Family-shared phones are normal.

### 4.3 Recovery, the actual design

The rule that does the work: **recovery strength ≥ derived assurance
level.** The record itself tells us how strongly this account is bound to a
person; recovery must re-clear that bar, or the verification layer is
worthless (attacker path: take over via email recovery, inherit
document-grade assurance).

| Account state | Recovery path |
|---|---|
| No verification attestations | Email/phone re-proof + time delay. Low stakes: profile is self-asserted only. |
| Channel-verified | Two independent channels + 72h time-lock, notification to all channels with one-click freeze. |
| Document/biometric-verified | **Re-verification with a registered verification provider** (same document class or biometric re-match). The verification-attestation machinery of design §1.2 doubles as the recovery machinery, cost billed as any verification event. Plus time-lock + all-channel notification. |
| Any attested history | Everything above, and the time-lock is non-waivable; deletion is blocked for the lock window after any recovery (prevents takeover-then-destroy). |

- **Passkey loss is a planned event, not an exception:** 6–11% of passkey
  users lose all devices within 18 months. Encourage multi-enrollment
  (second device, family device with distinct passkey) at onboarding;
  recovery is the table above, not a support ticket.
- **No human-judgment recovery at scale.** Support-agent-adjudicated
  recovery is the most-exploited path in every large identity system and
  is unstaffable at 1M with three people anyway. The escape hatch for the
  truly locked-out undocumented worker is honest: a fresh profile (which R2
  makes legitimate). The old profile stays frozen, not stolen.

### 4.4 Party authentication

Parties are the high-value accounts and get the enterprise treatment:
hardware-bound WebAuthn required for the party console, named individual
accounts (no shared logins) with roles, step-up re-auth for key operations,
signing access via workload identity/mTLS only (§2.3, no static API keys
to leak into a partner's git history), and IP/velocity anomaly alerts on
the signing endpoint feeding the §3.5-of-the-design reliability machinery.

---

## 5. Payload store: encryption and deletion mechanics

- **Envelope encryption, keyed per person.** Every payload row is encrypted
  under the subject's DEK; DEKs wrapped by a KMS KEK; KEK non-extractable,
  rotated on schedule. Blast radius of a database leak: ciphertext.
- **R2 deletion = purge + crypto-shred.** Delete rows in primary within the
  published window; destroy the DEK (and the commitment salts k_r, §3.4)
  immediately. DEK destruction is what makes the promise true across
  backups, replicas, log-shipped WAL, and analytics copies without a
  forensic hunt. Backup retention is finite and published; after DEK
  destruction the person's data in any backup is noise.
- **Sensitive-data ban enforced twice:** schema validation at ingestion
  (design §2.2) *and* a scanning pass (pattern + model-based) over accepted
  payloads, because parties will paste government IDs into free-text fields
  no matter what the schema says. Hits quarantine the payload and notify
  the party; the spine entry stands.
- **Access to payloads is mediated, logged, and purpose-tagged.** The read
  log the design promises workers (§7.1) is generated from the only path
  that can decrypt, not from app-layer bookkeeping that a bug can bypass.

---

## 6. AI-code assurance: SDLC for a machine-written codebase

The premise is unusual and must be designed for, not waved at: nearly all
code will be AI-generated, reviewed by at most two engineers and a founder.
AI-generated code fails in security-relevant ways: plausible-but-subtly-
wrong crypto usage, invented or typosquatted dependencies, over-broad IAM,
silently weakened validation "to make tests pass." The mitigation is
architectural:

1. **A frozen trust kernel.** Signing, verification, canonicalization,
   commitment computation, log append, and the deletion executor live in
   one small package (target < 3,000 lines, Go or Rust), with:
   - line-by-line human review by **two** named humans for every change,
     regardless of author (the one place dual control applies to code);
   - golden test vectors (signatures, envelopes, commitments) checked into
     the repo and verified in CI against independent implementations;
   - continuous fuzzing (OSS-Fuzz-style harness) on parsers/verifiers;
   - property tests for the invariants: append-only (no test run may ever
     observe a mutated spine row), verification-at-signing-time semantics,
     supersession acyclicity;
   - an external audit before the first external attesting party activates,
     and after any kernel-touching change batch thereafter.
2. **Machine gates for everything else, indifferent to authorship:**
   CodeQL/semgrep with a tuned ruleset, secret scanning, IaC policy checks
   (no public buckets, no wildcard IAM), and e2e invariant suites that
   exercise the real API against the real (staging) log.
3. **Dependency policy as an allowlist.** AI agents may not introduce
   dependencies; a new dependency is a human decision with a named
   approver, recorded. Lockfiles + checksum databases (Go sumdb / npm
   provenance) verified in CI; the kernel's dependency set is near-zero by
   construction (stdlib crypto + Tessera client).
4. **Adversarial AI review as a layer, not a substitute.** Every PR gets an
   independent review pass by a differently-prompted model instructed to
   attack, not summarize. Cheap, catches real classes of error, and is
   explicitly *not* credited as review for kernel paths.
5. **Reproducible, signed builds.** CI produces attested artifacts
   (Sigstore signing is free and fits the team's own transparency story);
   deploys verify the attestation; the deploy event lands in the §3.2 log.
   The chain "reviewed source → attested artifact → logged deploy" is what
   makes "our pipeline was compromised" a detectable event instead of a
   forensic mystery.

Priced honestly: items 2–5 are days of setup and near-zero marginal
burden. They are precisely the controls that scale with an AI-heavy team
because they are machines checking machines. Item 1 costs real senior-human
hours and is the deliberate bottleneck; it is affordable because the kernel
is small and changes rarely, and it is the correct place to spend the only
scarce resource this team has.

---

## 7. Abuse and DDoS on a universal-signup system

- **Edge first:** all traffic behind a major CDN/WAF (Cloudflare or
  Fastly); the origin accepts nothing but the CDN. TLS-terminating, bot-
  scored, absorbs volumetric attacks as a product feature we rent, not
  build.
- **Signup stays ungated (founder decision 3) but not free to weaponize:**
  IP/ASN/device velocity limits, proof-of-work challenges under attack
  conditions (works without CAPTCHAs' accessibility and labor problems),
  disposable-domain throttling. An account is cheap to create and worth
  nothing until attestations attach. The design already ensures signup
  fraud yields empty profiles, so the control target is infrastructure
  cost and namespace pollution, not record integrity.
- **No enumeration oracles:** UUIDv7 IDs are non-enumerable by design;
  signup/recovery endpoints return uniform responses regardless of account
  existence; packet reads require an active grant, so the read path cannot
  be used to scrape profiles at all.
- **Rate limits keyed to the trust registry on the write path:** party
  signing endpoints enforce the probation volume caps (design §3.1)
  mechanically; anomalies feed §3.5 reliability machinery.
- **The expensive endpoints (verification purchase, packet generation) are
  risk-gated,** with spend alarms on verification-provider calls. An
  attacker driving third-party verification spend is a cost-DoS the
  fraud-detection layer must see.

---

## 8. The controls that are non-negotiable at 1M identities

Ranked by what actually protects the attestation-integrity story:

1. All signing keys in cloud KMS; zero extractable key material anywhere.
2. Offline root + online issuing keys; ceremony documented; runbook
   rehearsed.
3. Tessera-based Merkle log carrying attestation commitments **and**
   registry/key events, hourly signed checkpoints mirrored outside the
   primary blast radius from day one.
4. Ledger-hosted party signing (or attested BYO custody), no party key
   files, ever.
5. Recovery-strength ≥ assurance-level rule; no SMS-only path; time-locked
   recovery with deletion lockout on attested accounts.
6. Per-person envelope encryption with crypto-shred deletion.
7. The frozen trust kernel with two-human review and golden vectors; CI
   gates + dependency allowlist on the rest.
8. No human write path to production; break-glass sealed and logged.
9. CDN/WAF fronting; enumeration-proof endpoints; signup velocity controls.
10. The party-key-compromise and insider runbooks, written and tested.

## 9. What can wait for 10⁸

- **Public witness network** (multiple independent co-signers across
  jurisdictions). One external witness suffices at the first-external-party
  milestone; a network is a 10⁸ credibility feature.
- **Inclusion proofs in the prior packet** and offline-verifiable packet
  format. Build when a consumer asks; the log makes it a feature, not a
  migration.
- **External RFC 3161 timestamping** alongside the log's own checkpoints.
- **Formal SOC 2 / ISO 27001.** The controls above are the substance;
  certification is paperwork to buy when enterprise procurement demands it.
- **Regional sharding / data-residency splits** of payload stores, and
  year-sharded log rotation.
- **Dedicated abuse/T&S staffing and ML risk models.** At 1M, rules +
  anomaly review; at 10⁸, a team.
- **Post-quantum migration.** Ed25519 is fine for this decade; the
  year-sharded log design is exactly what makes future algorithm rotation
  tractable, which is why the log ships now and PQ ships later.
- **HSM-backed (vs. software) KMS protection level.** Flip a parameter
  when a partner or regulator requires it; the API contract is identical.

## 10. Where other schools' designs get people hurt

- **The pragmatist school ("Postgres + a hash-chain column + keys in deploy
  secrets; harden later").** Its hash chain is tamper-evident only against
  outsiders; its key custody means one leaked env var forges history
  undetectably. The people hurt are workers whose records are forged or
  quietly edited during exactly the window when nobody external is
  watching, and the company, later, cannot *prove* it didn't happen,
  which is the same as it having happened.
- **The decentralization school (DIDs, wallets, client-held keys,
  blockchain anchoring).** Already correctly rejected by `04` for buying
  nothing on vetting; the security addition: client-held keys convert the
  6–11%/18-month device-loss rate into permanent career lockout for the
  workers least able to manage key material, shared-phone, low-document
  workers in emerging markets. A recovery-capable custodial design with a
  transparency log protects them better than self-sovereignty theater.
- **The defer-transparency school ("hash chain v1, Merkle v2").** Leaves
  the operator provably able to rewrite the early record, permanently caps
  the log's coverage at wherever v2 started, and forfeits the one control
  that addresses insider and pipeline compromise. The hurt lands on every
  early worker whose history's integrity is forever "trust us" instead of
  "verify."
- **The growth school (SMS-first auth, agent-adjudicated recovery,
  frictionless everything).** SMS recovery on an identity ledger hands
  SIM-swappers attestation-grade impersonation plus, under R2, the power
  to irreversibly destroy the victim's record. Support-adjudicated recovery
  reliably becomes the primary takeover path (every major platform's
  incident history says so) and cannot be staffed honestly at this
  headcount anyway.
- **The compliance-checklist school (SOC 2 first, architecture later).**
  Certifies the perimeter of a system whose core can still be silently
  rewritten. Auditable ≠ tamper-evident; workers are hurt by the false
  assurance more than by the gap itself.

## 11. Assumptions

1. **One major cloud provider is acceptable as the trust anchor for KMS and
   audit logs.** The transparency log's mirrored checkpoints are the hedge;
   full cloud-neutrality is not a v1 goal. GCP recommended; AWS workable.
2. **Attestation write volume stays modest relative to identity count**
   (≤ ~10⁸ attestations/year at 10⁸ identities), comfortably inside
   Tessera and KMS envelopes. If volume were 100× this, the log design
   holds but checkpoint/shard cadence changes.
3. **Founder decisions 1–10 and rulings R1/R2 bind**; §3.4/§5 mechanics are
   designed to make R2 true in physical reality (backups included), not
   just in the primary database.
4. **Hosted party signing is acceptable to founders and counsel** as the
   default custody model. If rejected, the fallback is mandatory BYO-KMS
   with custody attestation, strictly worse for the realistic threat, and
   said so.
5. **The 2026 tooling facts hold:** Rekor v2/Tessera GA and maintained;
   AWS KMS and GCP Cloud KMS Ed25519 support as shipped in Nov 2025 /
   earlier. If Tessera stalls, the fallback is a self-built tiled log on
   the same storage layout. The design, not the dependency, is the
   commitment.
6. **The EDPB salted-commitment posture (§3.4) is mitigation to be blessed
   by counsel, not a legal conclusion**, same caveat status as
   ledger-design-0.1 §2.1, strengthened but not discharged.
7. **Three people can operate this** because every always-on control is a
   managed service or a CI gate; the human-hours costs are concentrated in
   ceremonies (rare), kernel review (deliberate bottleneck), and runbook
   rehearsal (quarterly). If headcount assumptions change, §3.5's
   detection-over-prevention balance is the first thing to revisit toward
   real dual control.

---

### Sources (current-facts research)

- [Rekor v2 GA — cheaper to run, simpler to maintain (Sigstore blog)](https://blog.sigstore.dev/rekor-v2-ga/)
- [sigstore/rekor-tiles — tile-based transparency log for self-hosting](https://github.com/sigstore/rekor-tiles)
- [AWS KMS EdDSA (Ed25519) support announcement, Nov 2025](https://aws.amazon.com/about-aws/whats-new/2025/11/aws-kms-edwards-curve-digital-signature-algorithm/)
- [GCP Cloud KMS asymmetric signing (incl. Ed25519) codelab](https://codelabs.developers.google.com/codelabs/sign-and-verify-data-with-cloud-kms-asymmetric)
- [2026 FIDO report — passkeys at global scale (Descope)](https://www.descope.com/blog/post/2026-fido-report)
- [Passkey trends 2026 — device-loss and recovery data (Descope)](https://www.descope.com/blog/post/passkey-trends)
- [Passkey benchmark 2026 (Corbado)](https://www.corbado.com/passkey-benchmark-2026)
