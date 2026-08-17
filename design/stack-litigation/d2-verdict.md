# D2 Verdict: Language for the Ledger Core

Ruling on convergence-map docket item D2 (TypeScript vs. Go), issued
against `d2-typescript.md` and `d2-go.md`, the spec
(`ledger-design-0.1.md`), the four background perspectives, and
independent web verification of every load-bearing external claim
(2026-08-17). Operating facts: founder + 2 engineers, AI agents write
most code, modular monolith on managed infra, 30–250 writes/sec,
crypto-sensitive trust kernel whose integrity is the product, TS web
surface, decade horizon.

---

## Ruling

**Go owns the ledger core — kernel, ingestion, registry, read path,
merge machinery, continuous verifier, partner API — as one Go modular
monolith. TypeScript owns the worker web surface, steward console, and
thin BFF endpoints. The single source of truth for all shared shapes is
a language-neutral generated contract layer (JSON Schema and/or proto +
canonicalization golden vectors, CODEOWNERS-gated), from which Go types,
TS types, Zod validators, and the published partner artifacts are all
generated.** This is the Go brief's §5 hybrid, adopted with conditions
and triggers below. The TS brief's alternative (TS-everything with Go as
a CI verifier oracle) is rejected for the core, and its verification
machinery and several of its switch-triggers are adopted into the
winning architecture.

The ruling is conditioned on trigger T1 (pre-code agent-fluency spike,
below). It does not reopen anything the convergence map records as
settled, and it deliberately does not split the backend: no
TS-app-calling-Go-kernel-in-process construction. The language boundary
is placed exactly once, at the trust boundary, which is also the only
place a schema must already be language-neutral for external partners.

---

## Adjudication of the five contested questions

### (a) Type erasure vs. discriminated unions: the TS flagship survives, diminished, and is partially offset

The TS brief's strongest card is that discriminated unions with
exhaustive `switch`/`never` make the four state machines (claim
classes, party lifecycle, supersession, merge/alias) illegal-state-
unrepresentable. The Go brief's rebuttal is correct in its central
observation: every dangerous surface in this system is a process
boundary — partner JWS bytes, Postgres rows, KMS calls, queue messages,
emitted packets — and at every one of them TS types are erased and
enforcement falls to runtime validators and the database constraints the
convergence map already treats as settled (item 5, adopted *because*
application-layer guarantees cannot be trusted against agent code). The
compile-time union is therefore a developer-experience layer above the
actual enforcement, not the enforcement.

What genuinely survives is in-process exhaustiveness over agent-written
fold and rendering code — a forgotten `suspended` arm caught before
merge. That is real value, and the court does not accept the Go brief's
occasional implication that it is negligible: the PH-DPA co-render rule
and the packet-assembly paths are exactly where a silent omission
contaminates careers. But its scope is bounded by the cardinality of the
closed sets (3 claim classes, 4 party states, ~25 event types), and Go
reaches most of it mechanically: sealed interfaces, `exhaustive` /
`go-check-sumtype` linters failing CI — operationally identical to a
compile error under merge-on-green — plus the DB transition tables both
sides mandate. Priced honestly at ~10–20% more code on kernel fold
paths and a linter config that must live under the same frozen
CODEOWNERS gate as the kernel.

Two further points tip (a) from "TS wins narrowly" to "near-wash":

1. **TS strictness is configuration; Go's is property.** `any`, `as`,
   `@ts-expect-error`, and tsconfig flags are all reachable by an agent
   making a red build green — the documented agent failure mode
   ("silently weakened validation to make tests pass"). The TS brief's
   own mitigation is a bespoke ~50-rule lint regime plus a maintained
   `IDIOM.md` — human-built guardrails simulating what Go's toolchain
   ships unconditionally. For an agent workforce, escape hatches that
   are loud and idiomatically rare beat escape hatches that are ambient.
2. **Branded types (`RawSubjectId` vs `ResolvedPersonId`) have a Go
   equivalent** (defined types over string with unexported constructors)
   that is adequate if less ergonomic.

**Finding: runtime boundary validation does not annul in-process
exhaustiveness, but the surviving advantage is a bounded ergonomics
delta, mostly reproducible in Go, and partially offset by TS's
configurable strictness. Not dispositive in either direction.**

### (b) Supply chain: verified in full, and dispositive for the kernel

Every cited incident checks out. September 8, 2025: chalk/debug-family
compromise, 18 packages, ~2.6B combined weekly downloads. September 15,
2025: Shai-Hulud, the first self-propagating npm worm, 500+ packages,
CISA alert September 23. November 21–24, 2025: Shai-Hulud 2.0, ~700–800
packages (sources range 600–796) including Zapier, ENS, PostHog,
AsyncAPI, Postman; 25,000+ poisoned GitHub repos; propagation via npm
`preinstall` lifecycle scripts. On the Go side: `go get` executes
nothing at install time (the worm mechanism structurally does not
exist); every module fetch verifies against sum.golang.org, a public
CT-style checksum log; and the stdlib crypto was audited by Trail of
Bits in 2025 with a single low-severity non-informational finding, in
the legacy Go+BoringCrypto path, not the native module. The Go brief in
fact *understated* the FIPS position: the Go Cryptographic Module
v1.0.0 (Go 1.24+) holds an actual CMVP FIPS 140-3 certificate
(#5247), not merely in-process status.

The TS brief's containment argument — keys in KMS, verification-only
in-process surface, dependency allowlist, pinned lockfiles — is real
and correctly reduces the blast radius: a poisoned dependency cannot
exfiltrate signing keys that never exist in process memory (AWS KMS
Ed25519 support, November 7, 2025, all regions: verified). But the
court finds it does not reach the kernel's actual threat model, for
three reasons:

1. **KMS custody protects keys, not verdicts.** The kernel also
   *verifies* signatures, computes chains and commitments, and executes
   deletion. A compromised dependency in the verification path can
   accept forged attestations, misreport chain integrity, or exfiltrate
   payload data. Key custody is orthogonal to all three.
2. **Security-infra's settled requirement — "kernel dependency set
   near-zero by construction" — is satisfiable in Go and not in TS.**
   Node has no stdlib JWS, and its Ed25519 story is Node-core OpenSSL
   bindings plus `jose` or libsodium bindings plus their trees. Small
   and reputable, but third-party code at the exact center of the
   product, forever. In Go the entire signing/verification/hashing
   surface is first-party, audited, certificate-carrying stdlib.
3. **Structural absence beats policied presence at decade horizon.**
   The allowlist is a control three humans must hold against the
   ecosystem's grain for ten years; the Go properties are not controls
   at all. For most products this is a tiebreaker. For a product whose
   single sellable property is that its signature machinery was never
   subverted — and whose partner security questionnaires must be
   answered in one line — it is dispositive.

**Finding: the supply-chain evidence is verified and decisive for the
kernel and everything on the signing/verification/deletion path. It is
not decisive for the web surface, which keeps npm exposure either way —
the point is precisely that under the hybrid, that exposure cannot
reach the trust path even in principle.**

### (c) Agent fluency in 2026: the TS bloc's premise does not survive verification

The benchmark claims were verified and, if anything, cut against TS for
backend work:

- **SWE-bench Pro** (Scale AI): 1,865 tasks across Python, Go, TS, JS —
  Go is first-class, and published language breakdowns show **Go and
  Python tasks resolving at higher rates than JS/TS tasks** for most
  frontier models. No Go cliff exists; on this benchmark the cliff, such
  as it is, is on the TS/JS side.
- **SWE-bench-Live MultiLang**: Go present with 68 tasks (TS 87, JS 75).
  Verified.
- **arXiv 2606.13763** (chess-engine study, 17 languages, June 2026):
  real; its finding is a null result across mainstream languages — the
  TS brief itself cites it honestly as such.
- **arXiv 2512.18567** ("AI Code in the Wild"): real; finds highest
  AI-file adoption in strongly-typed, highly-structured languages. This
  supports *typed* languages, a class containing Go; it does not
  discriminate TS from Go.
- **The "~94%" figure**: traced to ETH Zurich/Berkeley
  "Type-Constrained Code Generation with Language Models." The actual
  result: ~94% of *compilation errors in LLM-generated TypeScript* are
  type-check rather than syntax failures. It decomposes TS's own error
  mix; it is not evidence for TS over Go — Go's compiler catches the
  same class. Weight: ~zero for this docket. The TS brief flagged it as
  secondary-sourced; correctly so.

The residual TS claim — deeper corpus — is true but its depth is in web
code, which the hybrid keeps in TS. The ai-native perspective's deepest
argument (agents need one enforced idiom; they follow written idiom
nearly perfectly and unwritten idiom nearly randomly) is, as the Go
brief observes, an argument whose strongest satisfier is Go, where
uniformity is a toolchain property rather than a maintained artifact.

**Finding: no 2026 evidence supports a material agent-fluency penalty
for backend Go; benchmark evidence leans slightly the other way. The
docket's "4-ish vs 1" tally reflected perspectives formed on a premise
the current evidence does not support — and the Go brief is also right
that the tally was miscounted: security-infra mandates a Go-or-Rust
kernel (§9) and log-centric pre-authorizes rewriting the crypto core
out of TS (§8). Claim (c) is struck as support for TS-everywhere; it
survives only as the reason the web surface stays TS.**

### (d) Seam placement: the Go brief is right about where drift bites

The TS brief's "one language removes the dangerous seam" argument fails
on a fact both briefs accept: external partners integrate against bytes
in whatever languages they run, and the convergence map has already
settled cross-language canonicalization test vectors in the versioned
contract. Therefore the packet/attestation schema **must be a
language-neutral artifact regardless of D2's outcome**. A contract
whose source of truth is a Zod definition is natively validatable only
from inside TS; for every partner it is documentation, and the signing
canonicalization must be verified from outside the implementation
language to count as a contract at all. TS-everywhere does not remove
the serialization seam (browser, DB, KMS, partners — all still
serialize); it hides it inside one ecosystem's compiler.

The TS brief's legitimate residue is drift risk between *generated*
copies and the friction of the codegen chain. Answer: generation from
one gated schema source makes drift a build failure, and the chain is
infrastructure the partner contract requires anyway. The risk that the
codegen chain itself rots is real and gets a trigger (T4).

**Finding: the dangerous seam is the partner/wire boundary, which
exists and must be language-neutral in every design. Kernel↔UI share
only schema, not logic (the UI renders packets; it never derives them).
One language would eliminate a seam that is not the dangerous one,
while spending the kernel's supply-chain posture to do it.**

### (e) The two hybrids as concrete architectures

**TS-everything + Go CI verifier-oracle** (TS brief §5.2): production
code ~100% TS; Go confined to a ~30–300-line CI cross-check of golden
vectors. One toolchain, one idiom, zero production language boundaries.
But: the trust kernel's dependency tree is npm (jose/libsodium + Node
runtime + transitive surface), held near-zero only by standing policy;
the Go oracle validates vectors, not the running system; and the trust
boundary is invisible in the toolchain — nothing but lint prevents an
agent from importing chain computation into a React component or a
`node_modules` compromise from cohabiting with the signing path.
Review burden: one idiom for 3 humans, but kernel crypto reviewed in
the language with the weaker first-party crypto pedigree.

**Go core + TS surfaces** (Go brief §5): Go monolith (kernel <3k lines
within perhaps 20–40k LOC of core at maturity), one static binary on
the settled container platform; TS web app + steward console + BFF
(which exists as a deploy artifact in *both* designs — the web surface
is a separately-deployed Next.js-class app regardless). Typed
boundaries: exactly one, the generated contract layer, mandatory
anyway. Operational complexity: two toolchains and two CI paths —
conceded, permanent, and the honest price; against it, the core deploy
is a file, the Go 1 compatibility promise fits a frozen-kernel decade
horizon better than the Node/ESM/framework churn record, and `sqlc`+pgx
fit the settled invariants-live-in-Postgres architecture. Review burden
for 3 humans: the two review regimes the litigation already settled
(two-human kernel review vs. machine-gated product code) now coincide
with the language split — the boundary is legible in the toolchain, and
a web-build compromise cannot reach the signing path even in principle.
Auditor ergonomics favor Go's poverty of expression for the one
component a human must read line-by-line.

The court also rejects the un-briefed middle option (TS backend calling
a Go kernel in-process) on its face: it pays the two-toolchain cost
*and* adds an in-process FFI/subprocess boundary — the worst surface
area of the three.

**Finding: the Go-core hybrid's extra cost is one additional toolchain;
the TS-everything hybrid's extra cost is a policied-not-structural
kernel supply chain for the life of the company. For this product the
first cost is bounded and paid once; the second is unbounded and paid
continuously.**

---

## What was noise

- **Deployment simplicity, memory/RSS, cost, raw throughput,
  goroutine concurrency.** Both briefs agree these are settled or
  irrelevant at 30–250 writes/sec on managed containers; the TS brief's
  rebuttals here were correct and the Go brief mostly did not rely on
  them. The race-detector point is marginal in a design that has
  deliberately excised application-level concurrency.
- **The ~94% type-error figure**, as adjudicated in (c): a TS-internal
  decomposition, not comparative evidence.
- **Proto-native gRPC as a Go advantage**: the ratified contract is
  JSON/JWS and the partner surface is JSON/HTTPS; proto is at most one
  serialization of the neutral contract layer, not a language argument.
- **Corpus-depth as such**: real, web-weighted, non-discriminating for
  backend; both briefs converged on this.
- **The docket's "4-ish vs 1" framing**: on inspection, two of the six
  perspectives (security-infra, planet-scale) put the core in Go/Rust
  and a third (log-centric) pre-authorized evacuating the crypto core
  from TS. The genuine question was always the core, and on the core
  the perspectives were closer to split.
- **"Data races impossible in Node"**: true and worth little in a
  serialized, Postgres-isolated design.

## Residual risks under the ruling

1. **Fold/projection ergonomics.** The Go core pays a permanent
   verbosity tax on the fold-heavy paths, and exhaustiveness rides on
   linters that must sit in frozen CI config under the kernel's
   CODEOWNERS gate. Mitigation: variant structs and folds generated
   from the contract schema where mechanical; the differential
   reference model, property suite, and mutation floors carry the
   semantics (language-neutral machinery, per both briefs).
2. **Verification tooling is thinner in Go** (rapid/gopter vs
   fast-check; no Stryker-class mutation practice). Mitigation adopted
   from the Go brief: write the naive reference model in TypeScript and
   differential-test the Go kernel against it — this *strengthens*
   independence (implementation and model cannot share a language-level
   bug) and keeps D5's cost model intact, since TLA+ specs are
   language-independent.
3. **The contract codegen chain is now load-bearing.** Its failure mode
   (generated-type drift, upcaster rot) is the failure it exists to
   prevent; trigger T4 watches it.
4. **Hiring.** The TS pool is larger; the Go pool is where
   infrastructure engineers are, which matches the profile of hires
   #3–5. Trigger T3.
5. **The web surface keeps full npm exposure.** Bounded by the ruling
   (no keys, no chain computation, no deletion authority in any TS
   process) but the worker surface remains an XSS/session/supply-chain
   target in its own right — that is D-adjacent product security work,
   not a language question.
6. **Two idioms to maintain** — one `IDIOM.md`-class artifact per side
   of the boundary, each shallower than a single unified one would be.
   Accepted as the price of (b).

## Switch-triggers (adopted, merged from both briefs)

- **T1 — pre-code fluency spike (condition on this ruling).** Before
  the first production line: the same ~10 kernel-representative tasks
  (fold + invariant + boundary validation) through the team's actual
  agent setup in Go and TS; measure property-suite failures,
  mutation/differential shortfall, and human review-minutes per
  accepted PR. Go worse by >50% on defect rate → D2 reopens with the
  fluency finding struck. Repeat quarterly at small scale (the TS
  brief's T4, adopted symmetrically: a stable >10-point inversion
  across two quarters reopens the docket in either direction).
- **T2 — exhaustiveness escapes.** >2 state-machine bugs reaching
  staging in six months that a TS union would have caught at compile
  time and the Go linter stack missed → adopt schema-generated variant
  codegen, or reopen.
- **T3 — hiring reality.** A Go-competent engineer #3 cannot be closed
  within one quarter of opening the role → weight shifts.
- **T4 — contract-tooling friction.** >1 contract-drift incident per
  quarter caused by the codegen chain → the one-language Zod argument
  regains force; reopen the BFF/API layer's language (not the kernel).
- **T5 — supply-chain symmetry.** A compromise in any package that
  would have been in the TS kernel's tree is recorded as confirmation;
  a compromise of Go's checksum-log infrastructure counts symmetrically
  against this ruling.
- **T6 — read-path SLO** (from the TS brief, inverted context): if the
  TS surfaces ever grow server-side logic that breaches latency or
  correctness SLOs, the remedy is moving logic *into* the Go core, not
  duplicating it in the BFF.

## [FOUNDER-CALL]

1. **Execute T1 before ratifying.** The spike is days of work and the
   only piece of evidence this docket lacks: the team's *own* agents on
   the team's *own* task shapes. The ruling stands unless the spike
   contradicts it.
2. **IaC language.** Pulumi-in-TS (ai-native) adds a third register to
   the TS side; Terraform (planet-scale's position) keeps IaC neutral.
   Small, genuinely a taste call, decide with D1's platform choice.
3. **Whether the BFF layer exists at all** at v1, or the web app calls
   the Go core's API directly with generated TS clients. Thinner is
   better; decide at first product build.

---

## Sources verified for this verdict

- [SWE-bench Pro (Scale AI): 1,865 tasks, Python/Go/TS/JS; Go/Python resolve above JS/TS](https://scale.com/blog/swe-bench-pro) · [arXiv 2509.16941](https://arxiv.org/pdf/2509.16941)
- [SWE-bench-Live leaderboard — MultiLang incl. Go (68 tasks)](https://swe-bench-live.github.io/)
- [arXiv 2606.13763 — chess-engine polyglot study (Acher & Jézéquel)](https://arxiv.org/abs/2606.13763)
- [arXiv 2512.18567 — AI Code in the Wild (typed/structured languages highest adoption)](https://arxiv.org/pdf/2512.18567)
- [Type-Constrained Code Generation with Language Models (the real "94%" source)](https://dl.acm.org/doi/10.1145/3729274)
- [Unit 42 — Shai-Hulud](https://unit42.paloaltonetworks.com/npm-supply-chain-attack/) · [CISA alert 2025-09-23](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem) · [Datadog — Shai-Hulud 2.0](https://securitylabs.datadoghq.com/articles/shai-hulud-2.0-npm-worm/) · [PostHog post-mortem](https://posthog.com/blog/nov-24-shai-hulud-attack-post-mortem) · [Microsoft guidance](https://www.microsoft.com/en-us/security/blog/2025/12/09/shai-hulud-2-0-guidance-for-detecting-investigating-and-defending-against-the-supply-chain-attack/)
- [Go blog — Trail of Bits crypto audit (one low-severity finding, BoringCrypto path)](https://go.dev/blog/tob-crypto-audit) · [Go blog — FIPS 140-3 module](https://go.dev/blog/fips140) · [go.dev/doc/security/fips140 — CMVP Certificate #5247 for module v1.0.0](https://go.dev/doc/security/fips140)
- [AWS KMS EdDSA/Ed25519, 2025-11-07, all regions](https://aws.amazon.com/about-aws/whats-new/2025/11/aws-kms-edwards-curve-digital-signature-algorithm/)
- Repo inputs: `design/stack-litigation/d2-typescript.md`, `d2-go.md`; `design/ledger-design-0.1.md`; `design/stack-perspectives/{convergence-map,ai-native,security-infra,boring-pragmatist,log-centric}.md`.
