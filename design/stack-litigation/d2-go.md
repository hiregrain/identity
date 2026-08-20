# D2 Advocate Brief: Go for the Ledger Core

Litigation position on convergence-map D2 (TypeScript vs. Go). This brief
argues **Go for the ledger core**, meaning the kernel, ingestion, registry,
read path, and deletion, against TypeScript-everywhere. Written against
`design/ledger-design-0.1.md`, all six perspectives in
`design/stack-perspectives/`, and 2025–2026 web evidence cited inline.
Operating facts honored: founder + 2 engineers, AI agents write most code,
modular monolith, low-throughput/high-correctness, crypto-sensitive trust
kernel, decade horizon, planet-scale ambition.

---

## TLDR

1. **The docket's "4-ish vs 1" tally overstates the TS consensus.** Of the
   six perspectives, security-infra *mandates* "a Go or Rust trust kernel,
   TypeScript permitted at the API/product layer" (security-infra §9);
   planet-scale picks Go for the entire core; and log-centric, nominally in
   the TS bloc, pre-authorizes rewriting the crypto core out of TS "if
   profiling demands it" (log-centric §8), i.e., concedes the kernel-language
   question. The genuine disagreement is narrower than the map records:
   whether the *core*, not the web surface, is TS. On that question the
   honest count is closer to even, and the security perspective, the one
   whose axis is the product itself, is on this side.

2. **TS's flagship advantage, discriminated unions, is mostly annulled by
   this system's own architecture.** TS types are erased at runtime; every
   boundary that matters in this ledger, such as DB rows, partner JWS
   envelopes, KMS calls, and queue messages, is a process boundary where
   the compiler
   enforces nothing and runtime validators plus database constraints do all
   the work. The convergence map itself settles (item 5) that append-only is
   enforced *in the database* precisely because application-layer
   guarantees, including type-level ones, cannot be trusted against
   agent-written code. The sum-type advantage that survives is in-process exhaustiveness
   checking over small, closed state sets (3 claim classes, 4 party states,
   ~25 event types); Go reaches ~90% of it with sealed interfaces, proto
   `oneof`, and CI-enforced exhaustiveness linters, at a bounded boilerplate
   cost this brief prices honestly (§4.1).

3. **The agent-fluency gap for backend Go is no longer supported by 2026
   evidence.** Go is a first-class language in every current multilingual
   agent benchmark (SWE-bench Pro: Python/Go/TS/JS; SWE-bench-Live
   MultiLang includes Go), and frontier models complete Go backend tasks at
   rates comparable to TS. More importantly, the ai-native perspective's own
   deepest argument, "one idiom so every file looks like every other file;
   agents follow written idiom nearly perfectly and unwritten idiom nearly
   randomly", is an argument *for Go*: Go's uniformity is enforced by the
   toolchain (gofmt, go vet, one idiom by design), whereas TS's must be
   simulated with a bespoke ~50-rule lint regime plus an `IDIOM.md` that is
   itself a maintained artifact. Go was designed for large codebases written
   by many low-context programmers; that design pressure is isomorphic to
   agent-written code.

4. **The affirmative case is supply chain, and it is decisive for this
   product.** The company sells exactly one thing: signature integrity. The
   trust kernel's dependency graph is therefore attack surface on the
   product itself. The npm record during this system's design window:
   Sept 2025 chalk/debug compromise (18 packages, 2.6B weekly downloads) and
   the self-replicating Shai-Hulud worm (500+ packages); Nov 2025
   Shai-Hulud 2.0 (~500–800 packages including Zapier, PostHog, AsyncAPI,
   Postman; 20,000+ poisoned repos), propagating through npm install-time
   lifecycle scripts and deep transitive graphs. Go structurally lacks
   install-time code execution, verifies modules against a public
   CT-style checksum transparency log (the same log architecture this
   product is adopting for itself), and ships Ed25519/x509/SHA-2 in a
   stdlib audited by Trail of Bits in 2025 (one low-severity finding, in
   the legacy BoringCrypto path) with a native FIPS 140-3 module. A TS
   kernel can never have the "near-zero dependency set by construction"
   that security-infra §6 requires; a Go kernel has it by default.

5. **Honest weaknesses, mitigated not denied:** no sum types (sealed
   interfaces + linters + DB transition tables; ~10–20% more code on kernel
   fold paths); the worker web surface stays TS (argued below as a feature:
   the language boundary coincides with the trust boundary and forces the
   contract to be an explicit, language-neutral artifact, which
   planet-scale and security-infra independently require anyway for partner
   test vectors); fold/projection ergonomics are genuinely worse than TS
   unions (conceded; the differential reference model and property suite,
   language-neutral machinery, carry the semantic burden either way).

6. **Position: the hybrid, affirmatively.** Go for the ledger core and
   every service that touches signatures, chains, or deletion; TypeScript
   for the worker-facing web surface and steward console UI. One monorepo,
   contract-first: proto + JSON Schema + golden vectors as the single
   source of truth, with Go and TS types both *generated*. Measurable
   switch-triggers in §6.

---

## 1. Steelman: the TypeScript case at its strongest

Stated at full strength, because the rebuttal must survive it:

**S1. Agent fluency.** TS is, with Python, the densest training corpus a
frontier model has. Fluency is not cosmetic: it is fewer subtle API misuses
per thousand lines, the dominant defect source in agent code. With three
humans reviewing, agent defect rate is the scarcest-resource multiplier;
choosing a lower-fluency language is choosing more defects where there is
least review capacity (ai-native §2; boring-pragmatist §2).

**S2. Illegal states unrepresentable.** The ledger is a system of state
machines: claim classes as distinct object types, party lifecycle
`pending → active → suspended → revoked`, supersession status, merge/alias
state, deletion state. TS discriminated unions plus exhaustive `switch`
make a forgotten lifecycle state a compile error, not a production
incident. Go has no sum types; the checking degrades to convention, "and
convention is what agents silently violate" (ai-native §2). For an
invariant-driven design, the type system carrying semantics is the whole
verification strategy's substrate.

**S3. One language, one artifact.** Zod schemas are simultaneously the
runtime validator, the static types, the published JSON Schema contract,
and the source the DDL is diffed against: one artifact, so agents cannot
let copies drift. TS end-to-end means the same branded `LedgerPersonId`
flows from DB driver to React component with no serialization seam for a
provenance-grade confusion to hide in; a Go core reintroduces a second
language for the web surface and a boundary where every invariant must be
restated and can be mis-stated (ai-native §2; boring-pragmatist §2;
log-centric §8).

This is a serious case. S2 in particular is the strongest argument in the
TS corpus. The rebuttals follow.

## 2. Rebuttals

### 2.1 Rebutting S2: how much of the sum-type advantage survives runtime type erasure?

Ask the precise question: **when data crosses a process boundary, what
actually enforces the invariant?** TS types are erased at compile time.
The ledger's dangerous surfaces are, without exception, process
boundaries:

- attestations arrive as bytes in a JWS envelope from a partner's system;
- state is read from and written to Postgres rows;
- signing happens via KMS API calls;
- ingest traverses a durable queue;
- packets leave as JSON to a reader the ledger does not control.

At every one of these, `type PartyState = "pending" | "active" | ...`
enforces nothing. Enforcement comes from runtime validators (Zod, a
library discipline agents must remember to apply at every edge), CHECK
constraints, transition-table foreign keys, and revoked UPDATE/DELETE
grants. The convergence map records this as *settled* (item 5): append-only
lives in the database "so the guarantee is structural, not behavioral...
the guardrail AI-written application code cannot violate." The ai-native
perspective itself concedes the point by demanding "state machines in SQL
too: CHECK constraints and transition-table foreign keys, mirroring the TS
unions. The DB is the last line of defense" (ai-native §3.1). If the DB
must hold the invariant against agent code *anyway*, the compile-time
union is a developer-experience convenience layered on top of the actual
enforcement, valuable, but not load-bearing, and not worth deciding a
language war over.

What genuinely survives: **in-process exhaustiveness checking**, the
compiler telling an agent it forgot the `suspended` arm of a fold. That is
real value. Its scope is bounded: the closed sets here are small and
stable (3 claim classes, 4 party lifecycle states, ~25 event types in
log-centric's full catalog §2, a handful of custody/assurance enums). Go
closes most of the gap at that cardinality:

- **Sealed interfaces** (unexported marker method) make the event and
  claim-class hierarchies closed types that external code cannot extend.
- **`exhaustive` and sum-type linters** (golangci-lint's `exhaustive` for
  enums; `go-check-sumtype` for sealed interfaces) turn a missing switch
  arm into a CI failure, which, for an agent workflow that merges on
  green, is *operationally identical* to a compile error. The agent never
  ships the omission either way.
- **Proto `oneof`** gives the wire contract a machine-checked closed
  variant set that both Go and TS consume, sum types at the boundary,
  where erasure makes TS's own unions weakest.

One more asymmetry the TS case never prices: **TS's strictness is
configuration, not property.** `any`, `as` assertions,
`@ts-expect-error`, and tsconfig flags are all reachable by an agent
trying to make a red build green, exactly the documented agent failure
mode security-infra names ("silently weakened validation to make tests
pass," §6). The ai-native design needs lint-fatal `any` bans and an
audited `unsafe/` directory to simulate what Go gives unconditionally:
there is no compiler flag an agent can quietly relax to defeat Go's type
checking, no `any` to reach for, and `gofmt` is not configurable at all.
The escape hatches exist in Go (`interface{}`, `unsafe`) but are loud,
greppable, and idiomatically rare rather than sprinkled through ordinary
web code.

### 2.2 Rebutting S1: the agent-fluency gap for backend Go, on 2026 evidence

The claim to test is not "TS has a bigger corpus" (true, driven by
frontend volume) but "agents produce backend Go with materially more
defects than backend TS." The evidence does not support it:

- **Benchmarks treat Go as first-class.** SWE-bench Pro (Scale AI, the
  current harder standard) draws its 1,865 tasks from Python, **Go**, TS,
  and JS repositories; frontier models are scored across all four, and no
  published result shows a Go-specific cliff
  ([SWE-bench Pro leaderboard](https://www.morphllm.com/swe-bench-pro)).
  SWE-bench-Live's MultiLang expansion likewise ships Go alongside JS/TS
  as a mainstream supported language
  ([swe-bench-live.github.io](https://swe-bench-live.github.io/)). Go is
  the lingua franca of the infrastructure this system imitates (Docker,
  Kubernetes, Terraform, CockroachDB, Tessera itself). That corpus is
  exactly backend-and-crypto-shaped, the register this codebase is
  written in. The TS corpus's depth is in web surfaces, which the hybrid
  keeps in TS.
- **The uniformity argument inverts.** Ai-native's most insightful claim
  is that agents need "one idiom so that every file looks like every
  other file," that "agents follow written idiom nearly perfectly and
  unwritten idiom nearly randomly," and that consistency is what makes
  30k lines reviewable by sampling (§2). Go is the only mainstream
  language where that uniformity is a *toolchain property*: gofmt admits
  one layout; the language omits the features (inheritance hierarchies,
  operator overloading, decorators, three ways to declare a function)
  that create idiom dispersion; error handling has one visible shape. TS
  achieves uniformity only through the ai-native design's own ~50-rule
  bespoke lint regime plus a maintained `IDIOM.md`, human-authored
  guardrails simulating what Go's designers built in. Go was explicitly
  designed at Google for large codebases maintained by many
  interchangeable, low-context programmers. Swap "junior Google engineer"
  for "coding agent" and the design brief reads as if written for this
  team. Anecdotally but consistently, practitioners report agent-written
  Go is *more* reviewable per line than agent-written TS for exactly this
  reason; the claim here is the modest one that the fluency delta, if it
  exists at all for backend code in 2026, is small, and §6 proposes
  measuring it rather than asserting it.
- **The feedback loop favors Go.** Agent throughput is proportional to
  feedback-loop speed (ai-native §2, correctly). Go compiles a service in
  seconds, with no bundler, no `tsc`-vs-runtime split, no ESM/CJS
  ambiguity; `go test -race` gives agents a data-race oracle TS does not
  have at any price. The race detector matters: ingest workers,
  checkpointers, and the continuous verifier are concurrent by nature,
  and interleaving bugs are the class agents handle worst (every
  perspective agrees). TS removes the tool; Go hands agents a mechanical
  detector for it.

### 2.3 Rebutting S3: does one-language-everywhere matter when the web surface and the trust kernel share almost no code?

Inventory what the worker web surface and the trust kernel would actually
share in a TS-everywhere monorepo: the packet response types, the ID
branded types, some enum labels. Not the fold logic (the UI renders
packets; it never derives them), not signature verification, not chain
computation, not deletion. The shared artifact is **a schema**, and the
system is contractually obligated to make that schema language-neutral
regardless of the internal language choice, because:

- external partners integrate "against bytes; bytes are forever"
  (planet-scale §7), in whatever languages their stacks use. The contract
  must be publishable as JSON Schema/proto with **cross-language
  canonicalization test vectors**, which the convergence map already
  adopts as settled ("signing canonicalization test vectors in the
  versioned contract, agreed by planet-scale and security convergence");
- a contract whose source of truth is a Zod definition is a contract that
  can only be natively validated from inside TS, for everyone else it is
  documentation. The signing canonicalization must be verified from
  *outside* the implementation language to count as a contract at all.

So the "one artifact" argument (S3) is right about the conclusion and
wrong about the artifact: the single source of truth should be the
language-neutral schema, with Zod types *and* Go types generated from it
(buf/protovalidate on the proto side; quicktype/go-jsonschema on the JSON
Schema side). Once the schema is the artifact, drift cannot occur between
generated copies, and the "serialization seam" ai-native fears is
revealed as unavoidable in every design: TS-everywhere still serializes
at the browser, at the partner API, at the DB, and at KMS. One language
does not remove the seam; it hides the seam inside an ecosystem where the
compiler pretends it is not there. Making the seam explicit, a versioned
contract with test vectors on both sides, is the correct treatment for a
system whose product is what crossed the seam and when.

The residual cost of two languages, such as two toolchains and agents
context-switching, is real but small for agents specifically: an agent does not
pay a human's cognitive-switching tax; it pays for *within-codebase idiom
ambiguity*, which is minimized on each side of a clean boundary (uniform
Go core, conventional React/TS surface) and maximized in a single
language stretched across two registers (React component idiom and
crypto-kernel idiom in one lint regime).

## 3. The affirmative case for Go, for this system

### 3.1 Supply chain: the kernel's dependency graph is product attack surface

The product is the assertion that signatures are genuine and history
unaltered. Security-infra frames the top threat classes as forgery and
mutation via a "poisoned deploy" or compromised pipeline (§1, §3.1). A
dependency compromise in the signing/verification path *is* the poisoned
pipeline. Weigh the two ecosystems on the 2025–2026 record:

**npm.** September 8, 2025: a phishing compromise of a single maintainer
cascaded into 18 poisoned packages, chalk, debug, ansi-styles,
strip-ansi, with **2.6 billion combined weekly downloads**
([Upwind](https://www.upwind.io/feed/npm-supply-chain-attack-massive-compromise-of-debug-chalk-and-16-other-packages)).
September 15, 2025: the **Shai-Hulud worm**, the first self-replicating
npm attack, harvesting npm/GitHub/AWS/GCP credentials with TruffleHog
and republishing itself into victims' own packages; 500+ packages removed;
serious enough for a CISA alert
([Unit 42](https://unit42.paloaltonetworks.com/npm-supply-chain-attack/),
[CISA, Sept 23 2025](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem)).
November 24, 2025: **Shai-Hulud 2.0**, ~500–800 compromised packages
(~132M monthly downloads) including Zapier, ENS, AsyncAPI, PostHog,
Browserbase, and Postman, with 20,000+ poisoned GitHub repos
([Socket](https://socket.dev/blog/shai-hulud-strikes-again-v2),
[eSentire](https://www.esentire.com/security-advisories/new-npm-supply-chain-attack-identified-second-wave-of-shai-hulud)).
The propagation mechanics are structural, not incidental: npm executes
lifecycle scripts at install time, and a typical Node service resolves
hundreds to thousands of transitive packages maintained by strangers.
Security-infra's mitigations (dependency allowlist, provenance,
lockfiles) are real but are *fighting the ecosystem's grain*, and its
own requirement that "the kernel's dependency set is near-zero by
construction (stdlib crypto + Tessera client)" (§6.3) is **impossible in
TS**: Node has no stdlib Ed25519/JWS story production teams use; the
kernel would stand on `jose` or libsodium bindings plus their trees,
third-party code at the exact center of the product.

**Go.** Three structural properties, not policies:

1. **No install-time code execution.** `go get` fetches source; nothing
   runs. The entire Shai-Hulud propagation class, the worm mechanism,
   does not exist in the ecosystem.
2. **The checksum database.** Every module fetch is verified against
   sum.golang.org, a public, append-only, CT-style transparency log. A
   registry-side tamper is globally detectable. There is a pleasing and
   non-trivial symmetry here: **Go's supply chain is secured by the same
   tile-log architecture (Trillian lineage) this product is adopting for
   its own spine.** The team will understand its dependency security
   because it is the product's security, twice.
3. **Audited first-party crypto.** `crypto/ed25519`, `crypto/x509`,
   SHA-2/HKDF/HMAC live in the standard library, maintained by Google's
   Go security team (Filippo Valsorda lineage), audited by **Trail of
   Bits in 2025 with a single low-severity finding**, in the legacy
   BoringCrypto integration, not the native module, and shipped as a
   natively validated **FIPS 140-3 module in Go 1.24**, pure Go, no cgo
   ([Go blog: audit](https://go.dev/blog/tob-crypto-audit),
   [Go blog: FIPS 140-3](https://go.dev/blog/fips140)). When a partner's
   security questionnaire asks what verifies signatures, "the
   Trail-of-Bits-audited Go standard library, zero third-party crypto
   dependencies" is the one-line answer that closes deals, the same
   argument security-infra makes for KMS custody (§2.1) applied to code.

For most products this comparison is a tiebreaker. For a product whose
single sellable property is that its signature machinery was never
subverted, it is close to dispositive on its own.

### 3.2 The operational story: one static binary, three people, ten years

- **Deployment is a file.** A Go service is a single static binary in a
  scratch container: no node_modules layer, no runtime version manager,
  no native-module rebuild matrix. For the 3-person ops story every
  perspective centers, the difference between "deploy = copy one binary"
  and "deploy = reproduce a JS runtime environment" compounds across a
  decade of 3 a.m. incidents.
- **Runtime maturity.** Predictable memory (no heap-tuning flags),
  built-in pprof profiling, `-race` in CI, goroutines that make the
  ingest-queue workers, Merkle checkpointer, and continuous verifier
  (planet-scale §9; ai-native §4.5) natural single-process code rather
  than worker-thread choreography.
- **Decade horizon.** The Go 1 compatibility promise has held since 2012:
  code from a decade ago compiles today. The TS/Node world in the same
  window churned through CommonJS→ESM, three runtimes (Node/Deno/Bun),
  and successive framework generations; every churn event is agent-
  retraining surface and migration work. A trust kernel that must be
  *frozen and rarely touched* (security-infra §6.1) wants a substrate
  whose ground does not move. Boring-pragmatist's own criterion,
  "managed services with a runbook the industry has already written,"
  describes the Go runtime better than the Node runtime.
- **sqlc + pgx.** The convergence architecture puts the real invariants
  in Postgres. Go's sqlc compiles hand-written SQL into typed Go code at
  build time. Queries become compile-checked artifacts against the
  actual schema, which is exactly the right shape for a system whose
  database *is* the enforcement layer; pgx is a mature, first-class
  Postgres driver. This is not decisive alone, but it means the
  DB-centric architecture all six perspectives converged on has
  first-class, boring tooling on the Go side.
- **Proto-native contracts.** The partner API's contract artifact
  (planet-scale §7: proto package, versioned, generated clients, JSON
  transcoding for partners who want plain HTTPS) is native tooling in Go
  (buf, connect-go, grpc-gateway) and an add-on culture in TS.

### 3.3 Uniformity as an agent advantage, restated affirmatively

The claim, made falsifiably: **for backend services, a corpus of
agent-written Go will exhibit lower stylistic and structural variance
than a corpus of agent-written TS**, because Go's toolchain and language
design remove the degrees of freedom along which agent output varies
(formatting, error-handling shape, class-vs-function architecture,
sync-vs-async coloring). Lower variance is precisely what makes
review-by-sampling sound (ai-native §2) and what makes a greppable,
pattern-matchable monorepo legible to the next agent. TS reaches
comparable uniformity only by building and maintaining the guardrails Go
ships with. §6 proposes the measurement.

## 4. Go's real weaknesses, confronted and priced

### 4.1 No sum types and the state-machine cost

This is the strongest TS point and it deserves a real price tag, not a
wave.

**What Go does for the ledger's closed sets:**

- *Event types / claim classes:* sealed interface per family (unexported
  `isLedgerEvent()` marker), one struct per variant, folds as type
  switches. `go-check-sumtype` (or equivalent) makes non-exhaustive type
  switches a CI failure.
- *Lifecycle enums (party state, dispute state, custody model):* typed
  string/int constants with the `exhaustive` linter enforcing full switch
  coverage; constructors unexported so invalid values cannot be built
  outside the package.
- *Wire boundary:* proto `oneof` carries the closed variant sets across
  the contract, machine-checked on both sides.
- *Last line:* the CHECK constraints and transition-table FKs the
  ai-native design already mandates, identical in either language.

**The honest cost:** ~10–20% more code on kernel fold/projection paths
(variant structs and accessor boilerplate TS unions get for free);
exhaustiveness via linter rather than compiler (equivalent under
merge-on-green, but a linter must be configured and can theoretically be
disabled, put it in the frozen CI config under the same CODEOWNERS gate
as the kernel); and pattern-matching ergonomics that are simply worse,
with no destructuring over variants and more ceremony per case. On a kernel
targeted at <3,000 lines (security-infra §6.1) with ~25 event types, this
is days of one-time boilerplate and a permanent mild verbosity tax. What
it is *not* is a semantic gap: every illegal-state property TS encodes is
either reproduced (sealed types + linters), enforced deeper (DB), or
covered by the machinery both sides agree on, the differential reference
model, property suite, and mutation testing, all language-neutral. Note
also that a Go kernel plus a TS (or Python) *reference model* makes the
differential test stronger, not weaker: implementation and model can no
longer share a subtle language-level bug or an idiom an agent copied
between them.

### 4.2 The web-surface split, polyglot but actually good here

Conceded outright: the worker view and steward console front-ends are TS.
The question is whether the resulting two-language repo is a cost. The
boundary is not arbitrary. It coincides with the trust boundary. On one
side: code that computes what is true (signs, chains, derives, deletes) is
small, frozen, audited Go. On the other: code that renders what is true
is large, fast-moving, agent-churned TS. Different change velocities,
different review regimes (security-infra already splits them: two-human
kernel review vs. machine-gated product code), different blast radii.
Giving them different languages makes the boundary *visible in the
toolchain*: an agent cannot accidentally import chain computation into a
React component, and a `node_modules` compromise in the web build cannot
reach the signing path even in principle, because the signing path has no
`node_modules`. The ai-native objection, "every language boundary is an
invariant-restatement boundary", is answered in §2.3: the restatement is
a generated artifact from one schema source, and the boundary exists in
every design anyway. What TS-everywhere actually buys is one hiring
profile and one build system; what it spends is the §3.1 supply-chain
posture of the kernel. For this product that trade loses.

### 4.3 Expressiveness for event-fold/projection code

The folds (current-truth derivation, alias closure, standing derivation,
packet assembly) are where TS is genuinely nicer to write: mapped types,
union narrowing, higher-order combinators. Go's version is type switches,
explicit loops, and generics (mature since 1.18) for the collection
plumbing, more lines, less elegance. Two mitigations, one reframe.
Mitigations: the folds are the most property-tested, differential-tested
code in the system, so verbosity is backstopped by machinery; and Go's
"dumb" folds have no async coloring, no closure-capture subtleties, and
no hidden laziness. Each fold is a boring function over explicit state.
The reframe: for the specific audience of a human auditor reading the
trust kernel line-by-line (mandatory under security-infra §6.1),
transparency-over-elegance is the correct trade. Auditability is a
first-class requirement for exactly this code, and Go's poverty of
expression is, for auditors, a feature with a long pedigree.

### 4.4 Residual conceded costs

- Property-testing tooling: fast-check (TS) is somewhat more mature than
  Go's `rapid`/gopter; adequate but thinner. Antithesis-style
  whole-system DST is language-neutral (containerized monolith +
  Postgres) and unaffected.
- IaC: if Pulumi-in-TS is chosen for infra, that is a third context,
  or use Pulumi's Go SDK / Terraform and accept the docket's planet-scale
  position (Terraform, §8).
- Hiring: the TS pool is larger. The Go pool is where infrastructure
  engineers already are, which is the profile hires #3–5 should have,
  but the constraint is real in some markets.

## 5. Hybrid position

**Proposed, affirmatively, not as a compromise:**

- **Go:** `kernel/` (canonicalization, signing envelope, verification,
  chain/Merkle, commitment computation, deletion executor), `ingest/`,
  `registry/`, `read/` (packet assembly), `identity/` (merge machinery),
  the continuous verifier, and the partner-facing API. One modular
  monolith, one binary, per the settled convergence items.
- **TypeScript:** worker web app, steward console UI, and thin BFF
  endpoints that consume the generated client. No TS process ever holds
  key material or computes a chain hash.
- **The contract layer is the monorepo's center of gravity:** proto +
  JSON Schema + canonicalization golden vectors, human-gated
  (CODEOWNERS), with Go types, TS types, Zod validators, and the
  published partner artifacts all generated from it. This satisfies
  ai-native's one-artifact requirement, planet-scale's proto requirement,
  and security-infra's cross-implementation golden-vector requirement in
  the same mechanism.

Against the pure alternatives: TS-everywhere is rejected on §3.1 (kernel
supply chain) and §2 (its advantages don't survive scrutiny at the core);
Go-everywhere (including the web surface via templ/htmx or WASM) is
rejected because the worker surface is a first-class product with real UX
velocity needs, the browser runs JS regardless, and frontend agent
fluency genuinely is TS-dominant. The fluency argument is correct
*there*.

## 6. Concessions and switch-triggers

**Concessions, on the record:**

1. If frontier-agent backend-Go quality were shown to lag TS materially
   for this team's actual agents, the fluency argument would regain
   force; the 2026 evidence is against it, but it is measurable, not
   certain (trigger T1).
2. TS wins on kernel-iteration ergonomics and the elegance of the fold
   code; a team that weights developer joy heavily will feel Go as
   friction.
3. The verification architecture (reference model, property suite,
   mutation floors, DST, two TLA+ specs) matters more than the language
   choice and ports to either. If forced to choose between TS-with-full-
   verification-machinery and Go-without, take the former. Language is
   the second-most-important decision in this docket entry, not the
   first.
4. The supply-chain argument weakens (does not vanish) if the kernel's
   npm footprint could truly be held to `jose` + libsodium with vendored,
   hash-pinned, install-scripts-disabled installs. The mitigations are
   real; the claim is that structural absence beats policied presence.

**Measurable switch-triggers** (each pre-commits a revisit, per the
execution protocol's verifiable-goal discipline):

- **T1, fluency spike, before the first line of production code:** run
  the same 10 kernel-representative tasks (fold + invariant + boundary
  validation) through the team's actual agent setup in Go and TS;
  measure property-suite failures, mutation-score shortfall, and human
  review minutes per accepted PR. If Go's agent defect rate exceeds TS's
  by >50% sustained across the spike, D2 reopens with this brief's
  fluency claim struck.
- **T2, exhaustiveness escapes:** count state-machine bugs reaching
  staging that a TS discriminated union would have caught at compile
  time and the Go linter stack missed. More than 2 in the first 6 months
  → adopt stricter codegen (variant structs generated from the schema)
  or reopen.
- **T3, hiring reality:** if a Go-competent hire cannot be closed
  within one quarter of opening engineer #3, weight shifts.
- **T4, contract-tooling friction:** if the proto/JSON-Schema codegen
  chain produces >1 contract-drift incident per quarter (the failure it
  exists to prevent), the one-language Zod argument regains force.
- **T5, holding trigger (symmetric honesty):** a supply-chain
  compromise in any package that would have been in the TS kernel's
  dependency tree is recorded as confirmation; a compromise of the Go
  module ecosystem's checksum infrastructure would symmetrically count
  against this brief.

---

### Sources

- [Upwind, npm compromise of debug/chalk + 16 packages, Sept 2025](https://www.upwind.io/feed/npm-supply-chain-attack-massive-compromise-of-debug-chalk-and-16-other-packages)
- [Unit 42, "Shai-Hulud" worm compromises npm ecosystem](https://unit42.paloaltonetworks.com/npm-supply-chain-attack/)
- [CISA alert, Sept 23 2025, widespread npm supply-chain compromise](https://www.cisa.gov/news-events/alerts/2025/09/23/widespread-supply-chain-compromise-impacting-npm-ecosystem)
- [Socket, Shai-Hulud 2.0, Nov 2025 (Zapier, ENS, PostHog, Postman)](https://socket.dev/blog/shai-hulud-strikes-again-v2)
- [eSentire, second wave of Shai-Hulud advisory](https://www.esentire.com/security-advisories/new-npm-supply-chain-attack-identified-second-wave-of-shai-hulud)
- [Go blog, Trail of Bits audit of Go cryptography (2025)](https://go.dev/blog/tob-crypto-audit)
- [Go blog, the FIPS 140-3 Go Cryptographic Module (Go 1.24)](https://go.dev/blog/fips140)
- [Filippo Valsorda, 2025 Go Cryptography State of the Union](https://words.filippo.io/2025-state/)
- [SWE-bench Pro leaderboard (Python/Go/TS/JS tasks)](https://www.morphllm.com/swe-bench-pro)
- [SWE-bench-Live / MultiLang (Go among supported languages)](https://swe-bench-live.github.io/)
