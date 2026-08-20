# D4 Verdict: Party-Held Custody by Default for Registry-Grade Party Keys

Ruling on docket item D4 (`convergence-map.md`): default custody for party
signing keys, ledger-hosted KMS vs. party-held. Briefs:
`d4-hosted-keys.md` (hosted default + BYOK), `d4-party-held.md`
(party-held default + bootstrap tier). Adjudicated against
`ledger-design-0.1.md` §3, `research/04`, `research/06`,
`security-infra.md`, and independent verification of the briefs'
load-bearing citations (August 2026). D3 is taken as resolved to, at
minimum: a day-one real Merkle tree with externally-anchored, KMS-signed
checkpoints to WORM across two clouds, and a witnessed log by
first-external-party-or-1M. The hosted brief's own stated precondition is
therefore satisfied, and this verdict rules against it on the merits, not
on its D3 conditionality.

---

## Ruling

1. **Default custody for registry-grade party keys: party-held.** The
   ledger never holds, and has no code path to invoke, a registry-grade
   party signing key. The hosted brief's hosted-by-default + BYOK hybrid
   is rejected as the default; its compensating-control machinery is
   adopted where custody-independent (below).
2. **Hybrid structure adopted** (the party-held brief's §5 tiering, with
   the hosted brief's operational tooling folded in):
   - **Tier 1 (default): partner-side KMS via a ledger-shipped
     integration kit.** Terraform/Pulumi module + signing SDK that
     creates a non-extractable Ed25519 key in the partner's own cloud
     KMS, registers the public key, and signs via the partner's KMS API.
     The SDK carries the ledger's golden-vectored canonicalization, one
     implementation, written and maintained by the ledger, running in the
     partner's environment. Registry: `custody_model: party_kms`.
   - **Tier 2 (bootstrap): ledger-provisioned, partner-owned.** For
     parties without cloud capability: the ledger provisions a dedicated
     KMS key in a separate provisioning account and transfers full
     account/IAM ownership at activation, retaining no access path. The
     transfer is executed from a written runbook and recorded as a
     registry event. Registry: `custody_model: party_kms_provisioned`.
   - **Tier 3: party HSM / existing PKI** for sophisticated partners.
     Registry: `custody_model: party_hsm`.
   - **No tier in which the operator can invoke a registry-grade party
     key.** This is the invariant the tiers exist to preserve.
3. **Short-lived key validity, mandatory.** Registry validity windows of
   30–90 days with automated ACME-style renewal through the SDK (current
   key signs a registry challenge to activate its successor, generated in
   the partner's KMS). Renewal failure halts that party's ingestion,
   loud and recoverable, never silent forgery.
4. **Worker/peer account keys: ledger-hosted.** Both briefs converge here
   and the convergence is ratified. Person-account keys are a different
   trust class ("this account said it," structurally down-weighted, with
   §4-of-security-infra recovery machinery); client-held keys would
   convert device loss into career lockout. The D4 fight was registry-grade
   party keys only, and this ruling is scoped accordingly.
5. **Custody-independent controls from the hosted brief, adopted as
   defense-in-depth** (they discipline the operator and the party
   regardless of who calls KMS):
   - Issuance evidence in the transparency log: every accepted
     attestation's log entry commits to submitting-channel identity and
     ingestion metadata alongside the signature hash.
   - A party-visible issuance feed and monthly statement: the party
     console renders every attestation recorded in its name. The party is
     the one entity with perfect knowledge of what it actually issued.
   - Periodic party countersignature over its own issuance checkpoint
     (the hosted brief's C4): monthly, or at each registry event, the
     party signs the Merkle root covering its issuance history. Under
     party-held custody this is nearly free, the party already holds
     signing keys, and it converts "the party never noticed" into a
     recurring, attributable attestation of the record's completeness.
     Required from the first external party onward.
   - Per-party volume caps and anomaly scoring enforced at ingestion
     (design §3.1/§3.5), which §III(c) below finds equivalent to
     signing-endpoint enforcement.
   - No static API keys anywhere: OIDC workload identity or mTLS for
     ingestion submission; hardware-bound WebAuthn for the party console
     (security-infra §4.4).
6. **`custody_model` lives only in the registry.** Per founder decision 2
   the attestation schema and the prior packet cannot distinguish custody
   tiers; custody feeds registry decisions and internal trust weighting
   only, never consumer-visible weight. (Both briefs agree; ratified.)
7. **The switch-triggers in §V are contractual.** D4 changes the partner
   integration contract (convergence map); the triggers are recorded in
   the partner agreement template, not left as design intent.

---

## II. Dispositive reasoning

### II(a). The category argument prevails over "non-repudiation isn't load-bearing"

The hosted brief's strongest factual claim is true: today, the only
verifier is the ledger's own read path; packets are generated at read
time; offline verification is deferred; the interface contract lists the
signature mechanism as open. At launch, no external party verifies
signatures independently. **But this establishes timing, not category.**
The question is not who verifies signatures in month one; it is what the
signature must be able to prove in the product's success scenario, which
the founder has fixed: the platform must survive litigated disputes and
partner/regulator scrutiny, and its one-sentence story is "the party said
this, the ledger recorded it." The design's own dispute machinery
(FCRA-shaped, research `04` §4) and liability structure (qualified
privilege, research `06` §5) presuppose contested proceedings in which
"who could have produced this signature?" is the first discovery
question. Under hosted custody the truthful answer is "the party, or the
operator," and the operator is simultaneously the record-keeper, the
fraud adjudicator (`ledger_invalidated`), and a commercially interested
platform. Aerotek, Inc. v. Boyd (Tex. 2021), verified, shows why
audit-trail burden-shifting will not rescue that posture: the audit-trail
doctrine works because the platform is a disinterested third party to the
dispute. This operator never is, in any dispute about its own record's
integrity.

The hosted brief's sharpest rebuttal, registry-manipulation forgery
exists under both models, so "party-held = math, hosted = trust" is a
false dichotomy, is correct as far as it goes, and it does not go far
enough. The two forgery paths are not equivalent under the D3-resolved
log:

- **Registry manipulation** (register a rogue key for party X, sign with
  it) requires the operator to author a *new, visible registry event* in
  a witnessed log before any forged signature verifies. It is a
  self-incriminating public act; the party and any monitor can detect it
  from the key-event stream alone, and the design's §3.3
  compromise-vs-backdating rule exists precisely because this path is
  observable.
- **Custody forgery** (invoke the party's real key) touches no registry
  state, produces bytes indistinguishable from genuine issuance forever,
  and is detectable only by cross-referencing evidence the operator
  produces or mediates. The transparency log proves the entry existed at
  time T; it cannot prove who authored the bytes.

Registry trust and signing trust are different quantities. Party-held
custody leaves the operator holding only the observable path. Hosted
custody adds the unobservable one. The design's compromise machinery
depends on that difference; the verdict preserves it.

**The precedent record is uniform and was verified.** eIDAS permits
server-held qualified signing only under EN 419241-2 sole-control
Level 2, a certified Signature Activation Module driven by signer-held
activation data, such that the operator provably cannot sign alone.
Mozilla Root Store Policy §5.2 prohibits CAs generating subscriber TLS
key pairs; the CA/Browser Forum Code Signing BRs require subscriber keys
in subscriber-controlled hardware. CT logs and Rekor never hold signer
keys. And the hosted brief's own flagship precedent inverts on
inspection: **Sigstore's keyless model is not hosted signing.** The
signing key is ephemeral and client-generated; Fulcio binds it to an OIDC
identity but never holds or invokes it. Fulcio can mis-issue, the
registry-manipulation analog, visible in the CT log, but cannot produce
a signature. The migration Sigstore represents is "long-lived signer-held
keys → short-lived signer-held keys + transparency," which is exactly
this verdict's Tier 1 + short-validity design, not operator custody. No
surveyed regime accepts "the host could sign, but the host's logs would
show it" for third-party-relied-upon signatures.

### II(b). The compensating controls restore detectability, not impossibility, and detectability is insufficient here

Ruling on the specific question posed: C1–C4 do **not** restore "the
operator provably cannot sign alone." They restore "operator forgery is
detectable, and then provable, after the fact, if checked":

- **C1** (signing-request evidence in the log) is operator-authored
  content. An operator forging a signature writes the log entry too, with
  a fabricated caller identity. Witnessing makes the entry permanent; it
  does not make it true. The log proves existence-at-time, never
  authorship.
- The **KMS audit trail** is the strongest leg, provider-controlled,
  outside the application's blast radius, but it is evidence the
  operator must produce, retain, and interpret in its own defense: the
  platform vouching for itself with records of its own custody.
- **C3** (party-visible feed) depends on the party's vigilance; the
  hosted brief itself frames the residual as a window between issuance
  and the next review.
- **C4** (party countersignature) is the one control that genuinely
  binds the party cryptographically, and it is a party-held key by
  another name. Its presence in the hosted brief is a concession that
  custody matters; this verdict adopts it on the architecture where it is
  cheapest and most coherent.

The hosted brief concedes (its §5.1) that court-grade "could not have
forged" is genuinely lost. For a product whose entire margin over "a
database with an `issuer_id` column" is that the operator's honesty is
not assumed, detectable-after-the-fact is the wrong default. It is
adopted here as defense-in-depth, every one of these controls improves
the party-held architecture too, but it cannot carry the default.

The blast-radius table (party-held brief §3.2) is also sustained on its
central row: hosted signing does not eliminate the partner-side leakable
credential, it relocates it. A thief with the partner's signing-endpoint
credential forges through the hosted API exactly as a thief with the
partner's cloud IAM credential forges through partner-side KMS. Under
Tier 1 no key file exists in either architecture; the leakable artifact
is an authentication credential in both. On the hosted brief's own chosen
threat, the architectures are near-equivalent. What differs is that
hosted custody adds a second, permanent forger (the operator) for every
default-tier party. The GitGuardian/DBIR base rates the hosted brief
cites are real but price the *key-file* scenario, which Tier 1 abolishes
without custody transfer.

### II(c). Marginal fraud telemetry: adjudicated at approximately zero

The party-held brief wins this point cleanly. The ledger is the sole
verifier and sole store; no offline-presentation path exists (design
§3.2 defers VC interop); therefore every attestation capable of harming
anyone passes through ingestion, where the ledger already authenticates
the submitter, verifies the signature, checks registry state and
probation caps, timestamps, rate-limits, and anomaly-scores (design §4).
The only events signing-time telemetry adds are signatures requested but
never submitted, empty for a rational attacker, noise for an honest
party. Enforcement latency is equivalent: freezing a party is one
registry state change consumed by ingestion, as fast as an IAM change and
and, unlike the IAM change, visible in the public registry history.
Research `06`'s prescribed countermeasure for party fraud is
network-structure anomaly detection on the party×subject graph plus
volume caps, both custody-independent. Partner-side KMS additionally
yields a per-signature audit log in the partner's cloud for post-incident
forensics, the one genuinely useful hosted artifact, recovered without
custody. The "fraud detection for free" claim is dismissed.

### II(d). The hybrids as onboarding funnels

- **Partner #1:** both models are concierge onboarding. The bootstrap
  tier's provision-then-transfer runbook costs days over an OIDC
  handshake; at n=1 this is immaterial, and partner #1 is precisely the
  diligence-heavy partner for whom "you hold your own key; we cannot sign
  as you" is the better first meeting. The hosted brief's own school
  concedes the first security questionnaire asks "who can sign as you"
  (security-infra §2.1); under hosted default the honest answer is a
  finding.
- **Partner #30:** hosted is genuinely faster and cheaper, conceded and
  priced (~one engineer-month/year, activation in days rather than
  hours, low-single-digit expired-key incidents annually). Two of the
  hosted brief's operational arguments are, however, neutralized by the
  adopted structure: canonicalization drift ("thirty independent
  implementations of the most fragile step") is answered by the
  ledger-authored SDK, one golden-vectored implementation, distributed,
  not reimplemented; and "custody review per partner is unstaffable" is
  answered by the integration kit making custody a provisioned artifact
  rather than a reviewed essay. What remains is a real but bounded
  support delta, covered empirically by trigger T2.
- **Trust-story coherence is where hosted-default+BYOK fails outright.**
  It makes operator-forgeable the *default provenance* of the record,
  while the BYOK tier's existence concedes custody matters. Because
  founder decision 2 forbids the schema from distinguishing custody,
  relying parties would have to learn that "party signature" usually
  means "operator-mediated signature," the trust story dies in its own
  fine print. Party-held-default has the coherent story at every scale:
  every registry-grade signature, in every tier, is one the operator
  could not have produced.

### II(e). The incident asymmetry is the decisive weighing

The expected-loss comparison, weighed explicitly:

- **Party-held failure mode:** 1–2 partner-compromise incidents in three
  years (conceded), each bounded by probation caps and ≤60-day key
  death, provable from the log (exactly which attestations postdate
  last-known-good), and reparable inside the system's own machinery
  (`ledger_invalidated`, registry suspension, public registry history).
  The public story, "a partner was compromised; the design detected,
  bounded, and provably remediated it," *demonstrates* the integrity
  machinery. CT survived CA compromises on this exact pattern; the
  incidents validated the log.
- **Hosted failure mode:** a single operator-forgery allegation, or
  merely the establishment, in discovery, diligence, or the press, that
  the operator can sign as any party, is not an incident but a fact
  about the architecture, true since launch, retroactively recoloring
  every attestation ever issued. It has no repair function: the fix is a
  custody migration plus a permanent asterisk over the pre-migration
  record. Custody cannot be cheaply moved outward later; it can always be
  loosened later (T2/T3 triggers) without an asterisk, because
  party-held history remains party-held history.

A recoverable, probable, small loss is preferred over an unrecoverable,
less probable, existential one, in a product whose founder has ruled that
surviving scrutiny is constitutive. The asymmetry in repair functions,
not the probability ranking, which the hosted brief wins, decides D4.

---

## III. What the hosted brief won

Recorded so the verdict is not read as a rout:

1. Its threat ranking is sustained as fact: partner-side compromise is
   the most probable forgery event of years 1–3, and the DBIR/GitGuardian
   base rates, while analogical, are directionally right.
2. Its operational critique forced the party-held position to become
   buildable: the integration kit, the SDK-carried canonicalization, the
   short-validity/auto-rotation design, and the bootstrap tier exist
   because the naive "parties manage PEM files" default was indefensible.
   The verdict's Tier 1 is closer to the hosted brief's operational
   quality bar than to design 0.1's original assumption.
3. Its controls C1 (as issuance evidence), C3, and C4 are adopted
   outright; its insistence that switch-triggers be contractual is
   adopted; its warning about the BYOK-tier atrophy problem is inherited
   (see residual risk 4).
4. Its argument that registry manipulation keeps the operator in the
   trust path under both models is accepted as true, and is precisely
   why the D3-resolved witnessed log is a non-negotiable dependency of
   this verdict.

## IV. Residual risks

1. **Support cost and funnel drag:** ~one engineer-month/year, slower
   activations, expired-key support tickets. Accepted; bounded by T2.
2. **Expected partner-compromise incidents:** 1–2 in three years with
   some forged-attestation window despite the controls. Accepted; the
   repair machinery (§II(e)) is the mitigation, and the first incident's
   handling should be treated as a product demonstration.
3. **Registry manipulation remains the shared ceiling.** Party-held
   custody does not protect against an operator admitting fraudulent
   parties or rogue keys; only the witnessed log and vetting do. This
   verdict's guarantee is narrower and exact: the operator cannot forge
   in the name of a genuine party under that party's genuine key.
4. **Tier 2 integrity risk:** provision-then-transfer is only as good as
   the transfer. If the ledger retains any access path (residual IAM
   grant, recovery role, logging credential), Tier 2 silently becomes
   hosted custody with better branding. The transfer runbook must end in
   a verifiable zero-access state, re-audited annually and attested in
   the registry event.
5. **The D3 dependency.** If the transparency log's witnessing schedule
   slips past the first external party, the registry-manipulation path
   loses its observability and the verdict's §II(a) asymmetry weakens.
   The log milestone and the first external party activation are coupled
   deliverables, not independent ones.
6. **Precedent drift.** If sole-control server signing (EN 419241-2
   shape) becomes a commodity managed service, the cost basis of this
   ruling changes (T4).

## V. Switch-triggers (contractual, recorded in the partner agreement template)

Adopted from the party-held brief §7, with T2 tightened:

- **T1. Leak rate exceeds the model:** ≥3 distinct partner-compromise
  forgery incidents in any 18-month window despite Tier 1 controls, or
  any single incident evading the probation/anomaly bounds by an order
  of magnitude → revisit custody per party class (toward a sole-control
  hosted tier, not toward plain hosted).
- **T2. Funnel failure:** >25% of signed partner prospects abandoning
  at key provisioning over two consecutive quarters, with Tier 2
  concierge already offered → build the hosted tier for that party
  class, sole-control-shaped if T4 tooling exists, plainly disclosed in
  the registry if not.
- **T3. Counsel concludes the category argument is legally inert** in
  the governing jurisdictions → argues for a hosted *tier*, not a hosted
  default; the partner-diligence and narrative exposures survive T3.
- **T4. Sole-control hosted signing becomes commodity** (an
  operator-cannot-sign-alone managed service operable at integration-kit
  cost) → the principled objection to a hosted tier dissolves by
  construction; re-open D4 for the default.
- **T5. Product re-scope:** the founder decides the ledger is openly a
  first-party system of record rather than a neutral recorder of party
  speech → signatures are ceremony; host them.

## VI. [FOUNDER-CALL] items

1. **Tier 2 availability at launch vs. first-external-party.** Building
   the provision-then-transfer runbook before any party needs it is
   speculative work; building it late risks the first small partner
   stalling. Default in this verdict: runbook written (a document, not a
   system) at launch; first executed transfer rehearsed before the first
   Tier 2 party activates. The alternative, defer entirely, saves days
   now at the cost of an unrehearsed ceremony later.
2. **C4 countersignature cadence and enforcement.** Monthly
   countersignatures from every party is the strong posture; parties
   will lapse. Options: (a) advisory, lapses feed the party reliability
   signal only; (b) mandatory, sustained lapse suspends the party.
   Default here: advisory through the first external party, mandatory
   thereafter. The stricter option strengthens the §II(b) evidence story
   at real partner-relations cost.

---

### Verification record

Citations independently verified for this verdict (August 2026):

- Mozilla Root Store Policy §5.2 prohibition on CA generation of
  subscriber TLS key pairs, confirmed ([Mozilla policy](https://www.mozilla.org/en-US/about/governance/policies/security-group/certs/policy/);
  [cabforum/servercert #186](https://github.com/cabforum/servercert/issues/186)).
- Aerotek, Inc. v. Boyd, Tex. 2021, confirmed; disputed e-signature
  enforced on system/audit-trail evidence; the neutrality-of-platform
  reasoning applied in §II(a) ([Justia](https://law.justia.com/cases/texas/supreme-court/2021/20-0290.html);
  [DLA Piper](https://www.dlapiper.com/en-us/insights/publications/2021/06/enforcing-a-disputed-electronic-signature)).
- EN 419241-2:2019 sole-control Level 2 / Signature Activation Module,
  confirmed: SAM authorizes each activation against signer-held
  activation data; the TSP cannot sign alone
  ([iTeh](https://standards.iteh.ai/catalog/standards/cen/6161a882-7bd0-4450-a2ca-bf20251d6382/en-419241-2-2019);
  [Cryptomathic](https://www.cryptomathic.com/news-events/blog/eidas-qualified-remote-signing-exploring-en-419-241-2-certified-qualified-signature-creation-devices)).
- Sigstore keyless architecture, client-generated ephemeral keys;
  Fulcio issues certificates and never invokes signing keys; the hosted
  brief's use of this precedent is found inverted (§II(a))
  ([Sigstore overview](https://docs.sigstore.dev/about/overview/)).
- DBIR 2025 / GitGuardian secrets-sprawl figures, accepted as
  directionally accurate per both briefs' shared characterization; both
  briefs concede the base rates and the concession is mutual, so no
  independent re-verification was dispositive.
