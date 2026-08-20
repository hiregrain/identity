# Attestation trust mechanics: signatures, key lifecycle, trust registries, disputes

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. A figure here describes what someone else did or what a
regulator said in one matter; it is not a target, a spec, or a decision.

Research memo. Confidence levels stated per claim, since this domain has well-documented standards (PKI, CT, eIDAS, FCRA) but few precedents for the exact combination this system needs (worker-outcome attestations at hundreds-of-parties scale). Where I extrapolate rather than cite, I say so.

---

## TLDR

1. **Signing scheme: plain asymmetric signatures (Ed25519) over a canonical claim payload, verified against a party registry, not blockchain/DID, not full W3C Data Integrity.** JWS/JOSE is the pragmatic middle: mature libraries, key-ID (`kid`) header for rotation, no canonicalization tax. W3C VC Data Integrity (JSON-LD proofs) buys selective disclosure and semantic linked-data interop the system doesn't need yet; adopt it later only if third parties demand W3C-standard VC interop. Blockchain/DID anchoring buys nothing here: the hard problem is *vetting who gets to attest*, not *where public keys live*, and a centralized registry with a signed append-only changelog gives equivalent tamper-evidence with far less operational cost. (High confidence on the "skip blockchain" call; medium on JWS vs. Data Integrity being the right long-run choice.)

2. **Key rotation and compromise must never rewrite history. Bind every signature to a `(party_id, key_id, timestamp)` triple, and record key state transitions (added, rotated, revoked, compromised) as their own append-only, hash-chained log**, following the Certificate Transparency / Sigstore Rekor pattern. Old attestations stay verifiable against the key that was valid *at signing time*, even after that key is rotated out or later marked compromised. Compromise invalidates the key for *new* signing, not retroactively for *past* signatures already corroborated by an independent timestamp. (High confidence. This is the settled pattern across CT, Rekor, and WhatsApp/Keybase key transparency.)

3. **Independent timestamping is the load-bearing piece that makes "compromise doesn't equal retroactive invalidation" defensible.** Without a trusted timestamp (RFC 3161 TSA, or simply the ledger's own append-order + Merkle log position), a party who claims "my key was compromised on date X" can attempt to disavow genuine attestations signed before X. A transparency-log-style timestamp proves the signature existed before the compromise was reported. (High confidence.)

4. **Trust registry: central registry + explicit lifecycle states (registered → active → suspended → revoked), not a peer federation model.** This system is not a multi-root federation like eIDAS or SWIFT. It's a single ledger operator vetting attesting parties, closer to a CA/Browser-Forum-style root-of-trust-with-audited-members than a cross-federation trust list. Model the registry after CA/Browser Forum + eIDAS trust-list mechanics: publish current status, status history, and reason codes per party. (Medium-high confidence on the shape; the "hundreds of parties" scale is closer to a CT-log-participant list than a handful-of-CAs model, so plan for that growth path from day one.)

5. **Suspension/unreliability discounts future trust, it does not retroactively erase past attestations. eIDAS is explicit on this and it is the right default.** Already-issued attestations from a since-suspended party remain in the ledger (append-only, nothing edits) but should carry a visible provenance flag ("issued by a since-suspended party") so consumers can weight them appropriately. Full retroactive invalidation is reserved for proven fraud/forgery, not general unreliability, and even then, invalidation is a new attestation ("this attestation is disputed/retracted") layered on top, never a deletion. (High confidence on eIDAS precedent; medium on how cleanly this generalizes to worker attestations, since eIDAS's "already-issued signatures stay valid" logic is about cryptographic validity, not substantive reliability, and those are two different things this system must not conflate.)

6. **Disputes need a subject-initiated annotation/counter-statement path modeled on FCRA reinvestigation, not a legal takedown mechanism.** A worker who disputes an attestation should trigger: (a) a time-boxed reinvestigation window with the attesting party, (b) a superseding correction if the party agrees, or (c) a permanent, equally-visible consumer counter-statement attached to the disputed record if the party doesn't budge. Nothing is deleted; the correction is the append. (High confidence. FCRA's Section 611 process is the most battle-tested version of exactly this pattern.)

7. **Corrections-supersede is already the right append-only pattern; the missing piece is a mandatory, structured link from correction to corrected claim** (like a git revert referencing its parent commit) so consumers reconstructing "current truth" don't have to guess which of several claims about the same work-episode is authoritative. Precedent: CT log entries never disappear, but "current status" is derived by walking the log, not by the log itself being current.

8. **Where the simple answer breaks down:** (a) once the party count reaches the hundreds and includes parties across jurisdictions, plain "central registry" needs a delegated/tiered vetting model (verticals self-vet under lighter review than external partners), flag this as a v2 problem, not a launch blocker; (b) if any consumer of attestations needs cryptographic proof of non-revocation at a specific point in time without querying your live API (e.g., for compliance/audit purposes), you'll eventually want something Merkle-tree/CT-log-shaped for provable append-only history. This is worth prototyping early even if not launched, because retrofitting tamper-evidence onto an existing plain database is expensive.

---

## 1. Signature schemes for signed claims

### Options on the table

**Plain asymmetric signing + party registry (JWS/JOSE-style).** Each attesting party holds a keypair (recommend Ed25519, fast, small signatures, no parameter-choice footguns vs. ECDSA). The ledger publishes/stores each party's current and historical public keys, keyed by `party_id` + `key_id`. Attestations carry a `kid` in a JWS header identifying which key signed them; verifiers look up that key in the registry (with its validity window) and verify. This is the JWT/JOSE model minus the "trust the issuer's `iss` claim blindly" problem, because the registry, not the token itself, is the root of trust.

- Mature, boring, widely-implemented (every language has JWS libraries).
- No canonicalization tax: JSON payload signs directly. W3C's own comparison of Data Integrity vs. JOSE notes JWT/JWS require no canonicalization, "resulting in less computation, less complexity, and lighter-weight libraries" than JSON-LD/LD-Proofs. [W3C VC-JOSE-COSE](https://www.w3.org/TR/vc-jose-cose/)
- Does not require Internet PKI or DID resolution as a dependency for verification. You control your own registry.

**W3C Verifiable Credentials with Data Integrity proofs.** JSON-LD-based, uses linked-data canonicalization (URDNA2015 or similar) so the payload's semantic structure, not its exact byte serialization, is what's signed. Enables selective disclosure and interoperability with the broader VC/DID ecosystem (e.g., a worker holding a wallet full of credentials from many unrelated issuers).

- W3C's own EXPLAINER: Data Integrity was developed because JOSE/JWT lacked canonicalization, selective disclosure, unlinkability, and semantic support, real gaps, but ones this system doesn't have yet since there's no multi-issuer wallet interop requirement stated. [w3c/vc-data-integrity EXPLAINER](https://github.com/w3c/vc-data-integrity/blob/main/EXPLAINER.md)
- Heavier: JSON-LD context resolution, canonicalization libraries, more moving parts, harder to audit.
- Worth adopting if/when the product needs the worker to *hold and present* portable, selectively-disclosable credentials outside this ledger's own UI, not needed for an internal append-only ledger where the ledger itself is always the verifier.

**Blockchain / DID anchoring.** Anchor either signatures or public-key state on a distributed ledger.

- The literature is fairly clear that blockchain is not required for VC/DID mechanics: "neither the DID standard nor technology requires using blockchains... other examples of verifiable data registries are decentralized file systems, databases, or peer-to-peer networks," and "a properly designed centralized registry... can technically be sufficient." [Curity, Myths and Truths About DIDs](https://curity.io/blog/myths-and-truths-about-decentralized-identifiers/); [Dock, Verifiable Credentials Guide 2026](https://www.dock.io/post/verifiable-credentials)
- Crucially, DIDs "don't solve the core trust problem — someone still has to issue and vouch for credentials, raising unresolved questions around trusted issuer registries and revocation." That's exactly this system's hard problem (who is a trustworthy attesting party), and blockchain doesn't touch it.
- Blockchain adds real cost (key management for on-chain writes, gas/fees or validator infra, immutability that can conflict with legitimate corrections unless carefully layered, and a much harder operational story for "hundreds of registered parties, some in regulated industries") without solving vetting, revocation semantics, or dispute handling, all of which are policy/registry problems, not cryptography problems.

### Recommendation

Start with plain asymmetric signatures (Ed25519) + JWS-style envelope + your own party/key registry. This is proportionate for "a handful of known parties scaling to hundreds." It's exactly the trust model CT and Sigstore use at far larger scale (millions of certs, thousands of log participants) without DIDs or blockchains. Revisit Data Integrity/VC only if a genuine cross-organization wallet/portability requirement emerges.

---

## 2. Key lifecycle in append-only stores

### The core problem

An append-only ledger cannot "unsign" a past attestation when a key is later found compromised. The transparency-log family of systems (Certificate Transparency, Sigstore/Rekor, WhatsApp/Keybase key transparency) converge on the same shape of answer:

**a) Bind signatures to a specific key version, not just a party identity.** Every signature references `key_id`; the registry tracks each key's validity window (`valid_from`, `valid_until`/`revoked_at`). Verification asks "was this key valid *at the time this attestation claims to have been signed*," not "is this party's *current* key good." Rekor's log entries are immutable once written. Auditors can verify the log stayed append-only and entries were never mutated or removed. [Sigstore Rekor overview](https://docs.sigstore.dev/logging/overview/)

**b) Log key-state transitions themselves in an append-only, tamper-evident structure.** Sigstore is formalizing scheduled key rotation with published, chained Trust Roots so old material remains verifiable against a documented lineage rather than silently disappearing. [Sigstore key rotation blog](https://blog.sigstore.dev/its-ten-o-clock-do-you-know-where-your-private-keys-are-5c869cf53234/) Certificate Transparency logs are explicitly append-only Merkle-tree structures anyone can audit; if a log itself suffers key compromise, "clients cease to trust it" going forward. The historical log entries aren't erased, trust in *future* entries from that root is what's pulled. [MDN, Certificate Transparency](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Certificate_Transparency)

**c) Independent/trusted timestamping is what makes "compromise doesn't retroactively invalidate" defensible rather than exploitable.** Rekor can act as its own Timestamp Authority and supports RFC 3161 signed timestamps so "the time becomes immutable and verifiable" independent of the signer's own claims. [Sigstore Trusted Time](https://blog.sigstore.dev/trusted-time/) Without this, a compromised or dishonest party could claim retroactive compromise to disavow attestations they don't like. With it, the ledger (or a timestamp authority) can independently prove an attestation existed *before* a reported compromise date, so it stays valid; anything signed *after* the compromise (even if backdated by the attacker) can be flagged as suspect since it wasn't in the log before the compromise was reported.

**d) Key transparency (WhatsApp/Keybase model) is about protecting against a malicious *registry operator*, which is adjacent but distinct.** Key transparency lets clients verify the registry itself hasn't been tampered with (e.g., silently swapping in an attacker's key). Keybase's append-only structures are designed so "a compromised server cannot roll back device revocations and team member removals." [Keybase blog](https://keybase.io/blog/chat-apps-softer-than-tofu) This is a defense against the registry operator being compromised, not against an attesting party's own key being compromised. This is worth noting as a distinct threat this design doesn't fully address if the ledger operator itself is the single point of trust. Flag as a known residual risk rather than something to solve at launch: mitigating it requires the ledger to publish a verifiable, auditable log of *its own* registry changes (a lightweight CT-style commitment), which is a reasonable v2 hardening step, not a v1 requirement.

### Recommendation

- `party_id` + `key_id` + validity window on every key.
- A separate, append-only `key_events` log (registered, rotated, suspended, revoked, compromised) with a timestamp and reason code, never edit key records in place.
- A trusted timestamp (which could be as simple as the ledger's own strictly-ordered, hash-chained append log, since you don't need an external RFC 3161 TSA at launch) attached to every attestation at write time, so "signed before compromise was reported" is provable.
- Verification logic: valid iff `key_id` was active at claimed signing time AND ledger-recorded timestamp predates any compromise report for that key.

---

## 3. Trust registry design

### Precedents surveyed

**eIDAS trust lists.** National Trusted Lists carry *constitutive* legal effect. A provider is only "qualified" if it's actually on the list, with status (`granted`, `withdrawn`, `recognised at national level`), suspension date/reason, and full history. Critically: "qualified timestamps issued before suspension keep their legal value, provided the certification chain was valid at issuance." Suspension is not retroactive. eIDAS 2.0 also requires QTSPs to file continuity/termination plans so verification remains possible after a provider exits. [ICO eIDAS guide](https://ico.org.uk/for-organisations/guide-to-eidas/qualified-trust-service-provider-obligations/); [ENISA, Guidelines on Termination of Qualified Trust Services](https://www.enisa.europa.eu/publications/tsp-termination)

**CA/Browser Forum.** CAs are audited annually against published Baseline Requirements (WebTrust or ETSI EN 319 411); audit reports are public and reviewed by browser root programs. Non-compliance can lead to browsers restricting or removing ("distrusting") a CA from their trust store, effectively ending that CA's business, but again, not retroactively invalidating certs that were validly issued before distrust (subject to normal expiry/revocation mechanics). [CA/Browser Forum, About Baseline Requirements](https://cabforum.org/working-groups/server/baseline-requirements/about/); [AppViewX, CA distrust](https://www.appviewx.com/blogs/how-does-google-chrome-make-the-decision-to-distrust-a-certificate-authority-ca/)

**OpenID Federation.** Trust Anchors and Intermediates publish an events log for subordinate entities, namely `registration`, `jwks_update`, `metadata_update`, `revocation`, `suspension`, as first-class event types with optional descriptions and info URLs, and trust chains are only valid up to the point they're rooted in a live Trust Anchor. [OpenID Federation Subordinate Events](https://openid.net/specs/openid-federation-subordinate-events-1_0.html) This is the closest existing spec to "append-only event log of party lifecycle state," and worth borrowing the event-type vocabulary from even without adopting the full federation protocol.

**SWIFT.** Membership is gated by a multi-step vetting process against SWIFT Corporate Rules (financial stability, AML/KYC/CTF compliance) before any messages flow, and SWIFT has demonstrated it can suspend members' network access entirely (e.g., sanctioned Iranian banks) as a network-level enforcement action. [SWIFT, Join the network](https://www.swift.com/myswift/join-swift) This is a useful analogy for "vetting is a real gate, and suspension is a real lever," but SWIFT's model is a *federation of peers with a neutral operator*, which is a heavier structure than this system needs at launch. It's closer to what emerges after this ledger has many independent competing verticals/operators, not at single-operator launch.

### Recommendation

Design the registry as a single-root, tiered model, not a peer federation:

- **States:** `pending → active → suspended → revoked`, plus `key-compromised` as an orthogonal flag on specific keys (a party can have an active registration with a compromised key that's been rotated out).
- **Public status + history per party**, mirroring eIDAS trust-list transparency: current state, state-change timestamps, reason codes, and a link to any superseding registration if a party re-onboards.
- **Vetting tiers:** internal verticals get lighter-weight vetting (already inside the organization's trust boundary); external partners get an onboarding review proportionate to SWIFT/CA-forum style diligence (identity verification, track record, maybe an initial probation/limited-scope period). This tiering is a v2 design need once party count grows past "a handful." Flag now, don't build prematurely.
- **Suspension effect:** matches eIDAS, and does not retroactively invalidate past attestations' cryptographic validity, but should visibly flag them to consumers ("issued while party was in good standing" vs. "party since suspended"). Revocation for proven fraud is different from suspension for general unreliability and should carry a stronger, explicit flag distinguishing "this party turned out to be unreliable" from "this specific attestation is confirmed fraudulent."

---

## 4. Dispute / appeal patterns

**FCRA reinvestigation is the strongest available benchmark**, precisely because credit bureaus already run an append-only-ish, third-party-attested, subject-affecting record system under regulatory dispute obligations:

- Consumer disputes an item → bureau has 30 days to complete a "reasonable" reinvestigation (45 days if the consumer supplies additional documentation mid-process).
- The furnisher (the attesting party, in this system's terms) must be notified within 5 days of the dispute.
- If reinvestigation isn't complete within the deadline, the disputed item must be removed.
- If the dispute isn't resolved in the consumer's favor, the consumer can still add a **100-word consumer statement** attached to the record, or escalate to a regulator/court.
[CreditInfoCenter, Dispute deadlines](https://www.creditinfocenter.com/credit-bureau-disputes-30-or-45-day-deadline/); [DisputeValet, FCRA Section 611](https://disputevalet.com/learn/section-611-dispute)

This maps cleanly onto this system's constraints:

- Correction supersedes (mirrors "item is corrected/removed" outcome) when the attesting party agrees the dispute has merit.
- A permanent, equally-visible counter-statement (mirrors the 100-word statement) when the party doesn't agree. This is the append-only-compatible version of "the record is wrong and no one will fix it": the subject's rebuttal becomes part of the permanent record rather than requiring the original claim to be deleted.
- A time-boxed process (30/45-day analog) forces resolution rather than leaving disputes open indefinitely, and gives the attesting party a defined obligation to respond.

### Recommendation

- Every attestation should support an attached, append-only thread: original claim → dispute → resolution (correction, uphold-with-counter-statement, or uphold-unresolved-escalated).
- A correction is a new attestation with a mandatory `supersedes` pointer to the disputed one (see TLDR point 7), never an edit.
- A counter-statement is visible by default alongside the original claim wherever it's surfaced to consumers of the ledger, not buried behind a click-through. FCRA's model treats the statement as part of the record, not a footnote.

---

## 5. Bottom line: recommended trust architecture (design constraints)

1. **Sign with Ed25519 in a JWS-style envelope; verify against a self-hosted party/key registry.** No blockchain, no DID resolution, no W3C Data Integrity/JSON-LD at launch. Those solve problems (multi-issuer wallet portability, selective disclosure) this system doesn't have yet. *High confidence.*

2. **Every signature binds to `(party_id, key_id, timestamp)`; key validity windows are tracked explicitly, and verification checks validity-at-signing-time, not validity-now.** This is what lets rotation and compromise happen without rewriting or invalidating history. *High confidence. This is the universal pattern across CT, Rekor, and key transparency systems.*

3. **Key and party lifecycle events (registered, rotated, suspended, revoked, compromised) live in their own append-only, timestamped log, never mutate existing key/party records in place.** Borrow OpenID Federation's event vocabulary even without adopting its federation protocol. *High confidence on the pattern; medium on exact event taxonomy, which should be refined once real onboarding/offboarding cases occur.*

4. **A trusted timestamp on every attestation at write time is what makes "compromise ≠ retroactive invalidation" defensible instead of exploitable.** This can start as the ledger's own strictly-ordered hash chain rather than requiring an external RFC 3161 authority, but it must exist from day one, because retrofitting provable ordering onto an existing plain database later is expensive. *High confidence on necessity; the "start simple, harden later" sequencing is a judgment call, not a cited precedent.*

5. **Suspension/unreliability discounts trust going forward and flags past attestations for consumer visibility. It does not delete or silently invalidate them.** Reserve true invalidation (via a new, explicit "disputed/retracted" attestation) for proven fraud, and keep that conceptually distinct from general unreliability. This is the eIDAS-precedented default and is consistent with append-only design. *High confidence on the eIDAS precedent; medium confidence this maps cleanly onto "worker outcome reliability" rather than "cryptographic signature validity," which are different failure modes the system should not conflate in its UI or scoring.*

6. **Disputes get a structured, time-boxed reinvestigation path with a mandatory, always-visible counter-statement fallback: the FCRA pattern.** This is the most battle-tested version of "subject disputes a third-party attestation about them in an append-only system" that exists in any regulated industry. *High confidence.*

7. **A central single-root party registry is proportionate through at least "hundreds of parties"; plan the transition to tiered/delegated vetting (internal verticals vs. external partners) as a v2 concern, not a launch blocker.** SWIFT/CA-Forum-style peer federation is over-engineering at this stage. The system has one operator (the ledger), not competing roots of trust. *Medium confidence. This is inference from the described party count and structure, not a cited case study of an identical system.*

8. **Where the simple answer will eventually break:** if any external consumer of this ledger someday needs to cryptographically prove non-revocation/non-tampering at a point in time without trusting your live API, you'll need a CT/Rekor-style provable append-only structure (Merkle-tree-backed log, public inclusion proofs). This is not needed at launch but is worth designing the storage layer to *not preclude*: for example, don't build on a database that makes retroactive hash-chaining of historical rows difficult to bolt on later. *Medium confidence. A forward-looking design constraint rather than a documented failure mode of a comparable system.*

---

## Sources

- [MDN — Certificate Transparency](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Certificate_Transparency)
- [RFC 9162 — Certificate Transparency Version 2.0](https://www.rfc-editor.org/rfc/rfc9162.html)
- [Sigstore — Security Model](https://docs.sigstore.dev/about/security/)
- [Sigstore — Rekor overview](https://docs.sigstore.dev/logging/overview/)
- [Sigstore blog — It's ten o'clock, do you know where your private keys are?](https://blog.sigstore.dev/its-ten-o-clock-do-you-know-where-your-private-keys-are-5c869cf53234/)
- [Sigstore blog — Trusted Time in Sigstore](https://blog.sigstore.dev/trusted-time/)
- [Sigstore blog — Rekor v2 GA](https://blog.sigstore.dev/rekor-v2-ga/)
- [Wikipedia — Key Transparency](https://en.wikipedia.org/wiki/Key_Transparency)
- [Keybase blog — Keybase is not softer than TOFU](https://keybase.io/blog/chat-apps-softer-than-tofu)
- [Cloudflare blog — Auditing key transparency for WhatsApp](https://blog.cloudflare.com/key-transparency/)
- [Tony Arcieri — Key rotation, user experience, and crypto reporting](https://tonyarcieri.com/key-rotation-user-experience-crypto-reporting)
- [W3C — Securing Verifiable Credentials using JOSE and COSE](https://www.w3.org/TR/vc-jose-cose/)
- [w3c/vc-data-integrity — EXPLAINER](https://github.com/w3c/vc-data-integrity/blob/main/EXPLAINER.md)
- [Curity — Myths and Truths About Decentralized Identifiers](https://curity.io/blog/myths-and-truths-about-decentralized-identifiers/)
- [Dock — Verifiable Credentials: The Ultimate Guide 2026](https://www.dock.io/post/verifiable-credentials)
- [OpenID Federation — Subordinate Events Endpoint 1.0](https://openid.net/specs/openid-federation-subordinate-events-1_0.html)
- [Connect2id — OpenID Federation 1.0 and the trust chain explained](https://connect2id.com/learn/openid-federation)
- [ICO — Qualified trust service provider obligations (eIDAS)](https://ico.org.uk/for-organisations/guide-to-eidas/qualified-trust-service-provider-obligations/)
- [ENISA — Guidelines on Termination of Qualified Trust Services](https://www.enisa.europa.eu/publications/tsp-termination)
- [CA/Browser Forum — About the Baseline Requirements](https://cabforum.org/working-groups/server/baseline-requirements/about/)
- [AppViewX — How CA distrust decisions get made](https://www.appviewx.com/blogs/how-does-google-chrome-make-the-decision-to-distrust-a-certificate-authority-ca/)
- [SWIFT — Join the Swift network](https://www.swift.com/myswift/join-swift)
- [CreditInfoCenter — Credit Bureau Disputes: 30 or 45 Day Deadline?](https://www.creditinfocenter.com/credit-bureau-disputes-30-or-45-day-deadline/)
- [DisputeValet — FCRA Section 611: Your Reinvestigation Rights Explained](https://disputevalet.com/learn/section-611-dispute)
