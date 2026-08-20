# D2 Advocacy: TypeScript End-to-End

Litigation position for docket item D2 (convergence-map). Advocate brief for
**TypeScript across the kernel, API, and worker surface**, against Go for the
ledger core. Written against `design/ledger-design-0.1.md`, all six
stack-perspectives, and 2026-current web research. The opposing position is
`planet-scale.md` §6 (Go core, TS edges); the supporting bloc is `ai-native`
§2, `boring-pragmatist` §2, and `log-centric` §8, with `data-platform` §5
concurring and `security-infra` §9 permitting TS outside the trust kernel.

---

## TLDR

1. **The real question is not "TS vs Go" but "one language vs two."** The
   worker surface is a first-class product surface (design §7–8; founder
   decision 4) and is necessarily TypeScript. Go for the core therefore means
   a permanent polyglot seam through the exact artifacts, attestation schema,
   packet schema, provenance grades, where drift is most dangerous. Every
   language boundary is an invariant-restatement boundary; this system's
   defensibility is a list of invariants.
2. **Every classical Go advantage evaporates against this system's actual
   shape.** Deployment simplicity: both ship as one OCI image to Cloud
   Run/Fargate. Concurrency: the design deliberately has none at the
   application layer, Postgres serializable isolation carries it, and Node's
   run-to-completion model has *fewer* shared-memory footguns for
   agent-written code than goroutines. Throughput/memory: 30–250 writes/sec
   is three-plus orders of magnitude below either runtime's ceiling.
   Proto-native contracts: the external contract is JSON/JWS by ratified
   design, and a modular monolith has no internal network contracts to
   protobuf.
3. **The affirmative case is agent leverage plus type-level invariants.**
   TS pairs the deepest AI-generation corpus with a strict structural
   compiler; 2026 evidence says strongly-typed structured languages show the
   highest reliable AI-code adoption and that the dominant LLM error class is
   exactly what the TS compiler catches. Discriminated unions with exhaustive
   `switch`/`never` checking make the ledger's four load-bearing state
   machines (claim classes, party lifecycle, supersession, merge/alias)
   illegal-state-unrepresentable. Go structurally cannot express this (no
   sum types, no exhaustiveness; open proposal golang/go#19412 for ~9 years).
4. **TS's real weaknesses are conceded and priced, not denied.** Runtime type
   erasure is answered by three independent fences (Zod parse-don't-validate
   at every boundary, invariants revoked/CHECKed in Postgres itself, which is
   the convergence map's settled item 5, and the production invariant auditor).
   The crypto-stdlib audit gap vs Go is real and is contained by the
   already-settled architecture: keys live in KMS (zero in-process key
   material), the in-process surface is verification-only inside a <3k-line
   frozen kernel using Node-core/libsodium/audited-noble primitives with a
   near-zero dependency allowlist. Node's npm supply chain and monorepo
   tooling are genuine ongoing taxes; mitigations and their costs in §5.
5. **D5 is language-independent and mildly pro-TS.** TLA+ models protocols,
   not code; both specs survive either language unchanged. The conformance
   link (pure kernel + fast-check model-based differential testing + Stryker
   mutation floors) is native, mature tooling in TS.
6. **Concessions and triggers.** Go genuinely wins: stdlib crypto pedigree
   and the native FIPS 140-3 module, single-binary footprint, enforced idiom
   uniformity, simpler module tooling. None is decisive here, and each has a
   measurable switch-trigger (§7), including moving *only* the trust kernel
   to Go if a FIPS-validated in-process module is ever contractually
   required, and rewriting *only* the read path if packet-assembly p99 blows
   its SLO after SQL push-down is exhausted. The kernel-as-executable-spec
   design makes both bounded ports, not rewrites.

---

## 1. Framing: what D2 actually decides

Operating facts (binding): founder + 2 engineers; AI agents write most code;
modular monolith on managed infra (settled, 6/6); 30–250 attestation
writes/sec sustained even at 10⁸–10⁹ identities with bursts absorbed by a
durable queue (settled, "throughput is a non-problem; topology is the
problem"); crypto-sensitive trust kernel with two-human review, golden
vectors, external audit (settled item 10); decade horizon.

Under those facts, D2 is not a performance decision and not a deployment
decision. It decides two things:

1. **The agent-tooling and hiring axis for years** (the docket's own words):
   which language the workforce, mostly AI agents, supervised by three
   humans, is most reliable in.
2. **Whether the system has one type system or a seam.** The worker view is
   the product (decision 4: the person sees everything raw; the read log,
   registry history, and dispute state are product surface). That surface is
   web, therefore TypeScript, in every proposal on the table, including
   planet-scale's. So "Go" on this docket means Go-core + TS-edge polyglot,
   and the brief against it is the brief against restating the packet
   schema, the claim-class taxonomy, and the provenance grades in two type
   systems forever.

---

## 2. Steelmanning Go, and the rebuttals

Each advantage stated at full strength first. These are real advantages in
general; the rebuttals are about *this* system's shape.

### 2.1 Deployment simplicity: the single static binary

**Steelman.** `go build` yields one static binary; no runtime to version, no
`node_modules` to ship, `FROM scratch` images measured in megabytes,
cross-compilation trivial. For fleets, edge agents, and CLI distribution this
is a genuinely superior operational story.

**Rebuttal.** The settled deployment shape is a stateless modular monolith on
a managed container platform (Cloud Run / ECS Fargate class, planet-scale
§8, ai-native §3.2, pragmatist §2 all converge). The deployable artifact is
an OCI image either way; the delta is `FROM scratch` vs `FROM
node:lts-slim`, i.e., ~100MB of image and a few hundred ms of cold start on
a service that runs warm replicas. Nobody distributes binaries to customers;
there is no fleet; there is no cross-compile target. The advantage is real
and worth approximately one Dockerfile line here.

### 2.2 Runtime predictability

**Steelman.** Go's scheduler and sub-millisecond GC pauses give tight, boring
latency distributions; no event loop to starve; CPU-bound work doesn't stall
unrelated requests; per-process memory is a fraction of Node's.

**Rebuttal.** The stated SLO is packet-read p99 < 400ms globally
(planet-scale §9) at ~115/s average reads at stage B. Packet assembly is
20–100 indexed row lookups, I/O against Postgres, Node's exact sweet spot.
The known Node hazard (CPU-bound work starving the loop) has one candidate
here: signature verification, which is (a) a native call in every proposal
(Node-core crypto is OpenSSL-backed C; libsodium bindings likewise), and
(b) ~10–20k verifies/sec/core, so stage B's worst burst fits on one core
(planet-scale's own §1 arithmetic). Memory: the monolith runs at single-digit
replica counts; the Node-vs-Go RSS delta prices in tens of dollars a month
against a stated capital posture of "effectively unlimited conditional on
success." Predictability arguments are decisive at 100k RPS; at 250 writes/s
they are rounding error.

### 2.3 Concurrency: goroutines and fewer footguns

**Steelman.** Goroutines + channels are the cleanest mainstream concurrency
model; Go was designed so ordinary engineers write correct concurrent
servers; Node's async/await hides a single thread and invites subtle
ordering bugs and unhandled rejections.

**Rebuttal in two parts.** First, the design has *deliberately excised
application-level concurrency*: one database, serializable isolation on
kernel-path transactions, no cross-system authority, an idempotent queue in
front of ingest. Merge-vs-ingest and deletion-vs-read, the only genuinely
concurrent protocols, are resolved by Postgres isolation plus the two TLA+
specs (D5), which are language-independent. There is no concurrency for
goroutines to be better *at*. Second, for the actual workforce, the footgun
count inverts: Go's shared-memory model admits data races that no compiler
catches and that agents, "interleave-blind," per ai-native §8.1, and per
the 2026 structural-testing literature ([arXiv 2601.18827](https://arxiv.org/pdf/2601.18827)),
are worst at; a leaked `go` statement or an unguarded map write is
convention-checked, not compiler-checked. Node's run-to-completion event
loop cannot data-race on shared memory by construction. Awaiting a promise
in the wrong order is a bug an agent can reproduce deterministically;
a data race is the bug class it cannot.

### 2.4 Proto-native ecosystem

**Steelman.** Go is the native tongue of gRPC/protobuf; schema-registry
discipline, generated clients, and wire-level contracts are first-class.
Planet-scale §7 wants contracts in protobuf with generated clients.

**Rebuttal.** Follow the ratified contract: the attestation envelope is
Ed25519 **JWS over canonical JSON** (design §3.2), the partner surface every
perspective except planet-scale specifies is versioned JSON/HTTPS (partners
are HR-tech integrators, not infra teams, pragmatist §7), and the settled
monolith has no internal network boundary to put protos on. The load-bearing
contract artifact is *one schema source*: Zod definitions that are
simultaneously the runtime validator, the static types, and the generated
JSON Schema / OpenAPI published to partners (ai-native §2, pragmatist §7,
log-centric §8, marking three independent convergences). The convergence map's
signing-canonicalization flag is answered by test *vectors*, bytes, which
are language-neutral. If a proto contract is ever wanted for a specific
partner, `buf` + `ts-proto` generate TS-native clients from the same repo;
proto is an add-on, not a language decision.

### 2.5 Lower memory / cost

Covered in §2.2. Real, small, priced, irrelevant at this replica count.

### 2.6 Fewer footguns generally: enforced simplicity

**Steelman.** `gofmt`, one idiom, a deliberately small language: every Go
file looks like every other Go file, which is genuinely agent-friendly and
reviewer-friendly. TS has eleven ways to model everything, `any` as an
escape hatch, and config-dependent strictness.

**Rebuttal. The one steelman that survives partially.** Conceded that Go's
uniformity is free and TS's must be *built*: strictness maxed
(`strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`),
`any` lint-fatal, assertions quarantined to an audited `unsafe/` directory,
a ~50-rule lint regime plus `IDIOM.md` loaded into every agent context
(ai-native §2). That is real setup cost, a matter of days and one-time, and agents follow
written idiom nearly perfectly. What Go's simplicity *costs* in exchange is
§3.2: the state machines live in comments. Uniform syntax that cannot
express the invariant is uniformity of the wrong thing.

### 2.7 Go's stdlib crypto

**Steelman.** `crypto/ed25519` ships in the standard library, maintained by
Google's crypto team with a distinguished lineage, fuzzed, and as of Go 1.24
backed by a native FIPS 140-3 validated mode
([go.dev/doc/security/fips140](https://go.dev/doc/security/fips140)). Zero
third-party dependencies for the entire signing surface. This is the
strongest single card in Go's hand for a trust-kernel product.

**Rebuttal.** Conceded as a genuine gap (see §5.2 for the honest
accounting), then bounded by architecture the litigation has already
settled: **no signing key exists as extractable material.** Ledger keys
(and, under D4's likely outcomes, most party keys) live in cloud KMS, where
Ed25519 signing is an API call (AWS Nov 2025, GCP native; security-infra
§2.2, convergence item 12). The in-process crypto surface is therefore
*verification and hashing only*, inside a frozen <3k-line kernel with a
near-zero dependency allowlist, golden vectors, fuzzing, and external audit
(convergence item 10), controls specified language-independently. The TS
primitives available for that surface are not npm roulette: `node:crypto`
Ed25519/SHA-256 is Node core (OpenSSL-backed, no package install), libsodium
bindings wrap the most-audited NaCl lineage, and the pure-JS fallback
`@noble/curves` carries two independent audits (Trail of Bits Feb 2023;
Kudelski Sep 2023, [noble-curves](https://github.com/paulmillr/noble-curves)).
The JOSE layer, `panva/jose`, is the reference JS implementation
underpinning OpenID-certified stacks ([panva/jose](https://github.com/panva/jose)).
Go's stdlib is still better *as a stdlib*; the question is whether the delta
justifies a second language, and the delta applies to a few hundred lines
that are two-human-reviewed and externally audited regardless of language.

---

## 3. The affirmative case

### 3.1 Agent fluency, with the 2026 evidence stated at its honest strength

The binding constraint is three humans supervising an agent workforce
(ai-native §1, and the pragmatist, no friend of gold-plating, independently
reached the same premise: "the compiler is the review layer that scales when
human review doesn't," §2.2). The evidence, graded:

- **Well-supported:** the dominant LLM code-generation error class is
  type errors, a 2025 academic result circulated widely as "~94% of LLM
  compilation errors are type-check failures" ([secondary source](https://blaxel.ai/blog/typescript-vs-python-ai-agents);
  the figure is secondary-sourced and flagged as such), which is precisely
  the class a strict structural compiler converts from runtime defect to
  red squiggle *inside the agent's own iteration loop*. Large-scale mining
  of AI-generated code in top GitHub repositories (2022–2025) finds the
  highest AI-file adoption rates in strongly-typed, highly-structured
  languages ([arXiv 2512.18567](https://arxiv.org/pdf/2512.18567)).
- **Honest null result:** raw capability no longer separates mainstream
  languages. The 2026 chess-engine study across 17 languages
  ([arXiv 2606.13763](https://arxiv.org/pdf/2606.13763)) finds agents
  produce working systems in anything mainstream, TS and Go both qualify,
  with language now determining "cost, what gets built, and how much human
  supervision validation still needs." That last clause is the operative
  one: this brief does *not* claim agents cannot write Go. It claims the
  supervision-per-line is lower where the type system carries more of the
  spec, which is §3.2.
- **Corpus depth:** TS is, with Python, the densest high-quality corpus
  frontier models train on, and TS is the only typed member of that pair.
  Fluency is fewer subtle API misuses per thousand lines, the dominant
  agent defect source, and TS's feedback loop (typecheck + lint + property
  suite in minutes) is the throughput multiplier ai-native §2 identifies.

Four of the six independent, adversarial perspectives converged on TS
end-to-end without seeing each other; the docket itself scores D2 "4-ish vs
1." Independent convergence is the map's own strongest evidence class.

### 3.2 Sum types against this ledger's concrete state machines

The design is a system of state machines whose illegal states are legal
catastrophes. Concretely:

- **Claim classes** (design §2.2): `self_asserted | peer_attested |
  party_attested` as *distinct object types* is founder decision 5 rendered
  in schema. Nothing self-asserted may be schematically confusable with
  anything attested. In TS this is a discriminated union; a packet-assembly
  function that forgets the `peer_attested` arm fails to compile
  (exhaustive `switch` + `never`). The freeze rule ("editable until first
  party-grade verification, then frozen forever") is a type-state:
  `EditableSelfClaim` and `FrozenSelfClaim` are different types, and the
  edit path *does not accept* the frozen one. In Go, this is an interface
  plus a type switch with no exhaustiveness checking: the compiler is
  silent when a new class or state is missed, and "the checking degrades to
  convention, and convention is what agents silently violate" (ai-native
  §2). Go has no sum types; the proposal has been open and unresolved since
  2017 ([golang/go#19412](https://github.com/golang/go/issues/19412)).
- **Party lifecycle** (design §3.1): `pending → active → suspended →
  revoked` with the read-time rule that suspension flags but never edits.
  In TS the transition function's domain is the union of legal
  `(state, event)` pairs; an agent adding `reinstated` without handling
  every consumer gets compile errors at each site. Ingestion's "issuer must
  be `active`" check is a type guard whose result type cannot flow into the
  append path unverified.
- **Supersession** (design §2.4): current-truth derivation walks a chain
  where each node is `Head | Superseded {by} | LedgerInvalidated {reason}`.
  Same-issuer-or-ledger is a refinement the constructor enforces. The
  PH-DPA co-render rule ("both versions travel together") means *renderers*
  must handle every variant, exactly what exhaustiveness checking audits
  across the whole codebase mechanically.
- **Merge/alias** (design §1.4): a subject reference is
  `Live | Absorbed {survivor} | Tombstoned`. The design's subtlest rule,
  that attestations keep their original `subject_id` forever and resolve
  through the alias closure at read time, means every read-path consumer must
  distinguish "the ID I was given" from "the ID it resolves to." Branded
  types (`RawSubjectId` vs `ResolvedPersonId`) make confusing them a
  compile error. In Go both are `string`.

The same construction covers dispute states, custody models
(`ledger_hosted | party_kms | party_hsm`, D4), verification assurance
levels, and deletion states. This is not type-astronautics: it is the
cheapest known mechanism for making an agent's omission a build failure
instead of a career-contaminating production incident, applied to the four
places design 0.1 says omissions contaminate careers.

### 3.3 One-language leverage

- **One artifact, no drift:** Zod schema → static types (`z.infer`) →
  runtime boundary validation → generated JSON Schema/OpenAPI published to
  partners → DDL diffed against it. Three perspectives specified this
  pipeline independently. A Go core forks it: either the packet and
  attestation shapes are defined twice (Go structs + TS types, drift at
  the provenance-grade boundary, decision 5's nightmare), or a codegen
  toolchain is added and becomes load-bearing.
- **The type flows end-to-end:** the branded `LedgerPersonId` and the
  claim-class union travel from the DB driver through packet assembly into
  the React component that renders "self-asserted" visually distinct from
  "party-attested." No serialization seam exists for the confusion to hide
  in.
- **One idiom for the whole workforce:** kernel, API, projectors, steward
  console, worker surface, IaC (Pulumi TS), the naive reference model, and
  the property suite are one language, one `IDIOM.md`, one lint regime,
  one pattern for agents to match, and any of three humans can review any
  layer. A Go/TS split halves the depth of both idioms and re-creates the
  frontend/backend staffing seam in a company with no teams to mirror it.
- **The verification architecture is TS-native:** fast-check (property
  based/model-based testing), Stryker (mutation floors), in-process
  deterministic simulation of the pure kernel, the entire ai-native §4
  machinery, which the convergence map treats as the review-replacement
  strategy, is mature in exactly this ecosystem. Go has testing/quick and
  rapid, and no mainstream mutation-testing practice at Stryker's level.

### 3.4 Ecosystem for the specific needs, assessed honestly

| Need | TypeScript | Go | Verdict |
|---|---|---|---|
| JOSE/JWS | `panva/jose`, reference implementation, powers OpenID-certified `oidc-provider`; Node-core webcrypto backend | `go-jose` (square→Let's Encrypt lineage), mature, has had its own CVE history | Par. Neither is a stdlib; both are the ecosystem standard. |
| Ed25519 / SHA-2 | `node:crypto` (core, OpenSSL-backed); libsodium bindings; `@noble/curves` (Trail of Bits + Kudelski audited) | `crypto/ed25519` stdlib; FIPS 140-3 native mode (Go 1.24) | **Go wins.** Bounded by KMS custody + kernel controls (§2.7, §5.2). |
| Postgres | node-postgres + typed SQL layers (Kysely/pgtyped/Drizzle: queries typechecked against schema, a direct extension of §3.2 into SQL); mature migration tooling | pgx (excellent), sqlc (typed) | Slight TS edge: typed-query tooling integrates with the one schema source; both ecosystems are strong. |
| Schema/validation | Zod/Effect Schema, the one-artifact pipeline | Third-party validators; no `z.infer` equivalent (types don't derive from validators) | **TS wins**, and this is the load-bearing row: runtime validation and static types from one source is the type-erasure mitigation (§5.1). |
| Web surface | Native | Not applicable, TS required anyway | **TS by necessity**; this row is why "Go" means "two languages." |
| PBT/mutation/DST | fast-check, Stryker, pure-kernel in-process simulation | testing/quick, rapid; weak mutation story | **TS wins** for the verification-heavy strategy the docket has converged on. |

---

## 4. D5: does language choice affect the two TLA+ specs?

Minimally, and in TS's favor at the margin.

- **The specs themselves are language-independent.** TLA+ models the
  merge/unmerge-vs-ingest and deletion-vs-read *protocols*, namely their
  states, actions, and invariants, not implementation code. Both specs are written,
  model-checked in CI, and human-reviewed identically under either
  language. Nothing in D5 constrains D2.
- **The conformance link is where language touches D5**, and the TS plan
  already contains its substrate: a pure, dependency-free kernel whose
  functions map one-to-one onto spec actions, differential-tested against
  an independent reference model under generated operation sequences
  (fast-check model-based testing is literally "run the spec's abstract
  state machine against the implementation"). Go could do the same with
  more hand-rolling; neither language has TLA+ refinement checking, so the
  linkage is comment-discipline plus trace-checking in both worlds.
- One genuine cross-check: if D2 went to Go *because of* agent-verification
  worries, D5's premise ("agents do the mechanical conformance work,
  humans review 300 lines") would weaken, since the mechanical-work tooling
  is thinner. Choosing TS keeps D5's cost model intact.

---

## 5. TS's real weaknesses, mitigations, and what the mitigations cost

### 5.1 Runtime type erasure

**The weakness, stated plainly.** TS types vanish at runtime. A
discriminated union constrains what agents *write*; it constrains nothing
that arrives over the wire, out of the database, or through a bug in an
un-validated path. Go's types are also erased in the ways that matter here
(a Go struct populated from bad JSON is just as wrong), but Go partisans
correctly note TS culture tolerates `as`-casting the boundary.

**Mitigations (three independent fences):**
1. **Parse, don't validate, at every boundary:** every ingress (partner
   API, DB read, queue message, config) passes through the Zod schema that
   *is* the static type. Unvalidated data has no type-level path into the
   kernel. Enforced by lint: no `as`, no `any`, assertions only in the
   audited `unsafe/` directory.
2. **Invariants live in Postgres, indifferent to application language:**
   UPDATE/DELETE revoked on spine tables (settled, convergence item 5),
   transition-table FKs and CHECK constraints mirroring the TS unions,
   sensitive-data bans as constraints. The DB is the fence that
   agent-written code in *any* language cannot cross.
3. **The production invariant auditor** (ai-native §4.5): continuous
   recomputation of chain integrity, supersession acyclicity, closure
   consistency, orphan-payload absence, catching whatever crossed both
   fences.

**Cost:** Zod parse overhead on every boundary (microseconds against a
multi-millisecond I/O path, negligible); the discipline cost of writing
schemas first (this is the design's stated methodology anyway); lint
infrastructure setup (days, once). The honest residual: between fences,
in-process values are unchecked in TS where Go would at least enforce
struct shape, accepted, because the fences bracket every persistence and
egress point.

### 5.2 The crypto-library audit gap

**The weakness, stated plainly.** Go's `crypto/ed25519` is stdlib,
Google-maintained, FIPS-140-3-capable. TS's equivalents are Node-core
OpenSSL bindings (solid but not FIPS-validated as deployed), a C-binding
package, or an audited-but-small-team pure-JS library. For a company whose
product *is* signature integrity, this is the most serious honest objection
to TS, and it should be recorded as such.

**Mitigations:** KMS custody removes signing keys from process memory
entirely (§2.7); the in-process surface is verification/hashing inside the
frozen kernel; primitives pinned to Node-core crypto first (no npm
package), libsodium second, audited noble third; golden vectors
cross-checked in CI against an independent implementation (which can be a
30-line *Go* verifier in CI. Using Go as a test oracle costs nothing and
buys the stdlib's pedigree as a cross-check); external audit before the
first external party (settled).

**Cost:** the external audit money (already budgeted by the settled
controls); CI cross-implementation harness (~days); and a standing
obligation to track Node-core crypto advisories. The residual that cannot
be mitigated away: if a partner or regulator ever requires a FIPS-validated
module *in-process*, TS has no good answer. That is switch-trigger T1.

### 5.3 Node runtime operational sharp edges

**The weakness.** Event-loop starvation under CPU-bound work; historical
unhandled-rejection semantics; single-threaded per process; and the npm
supply chain, which in 2025 produced marquee incidents (the September 2025
compromise of chalk/debug-family packages and the "Shai-Hulud"
self-propagating worm) of a severity Go's module ecosystem has not matched.

**Mitigations:** CPU-bound work is native or in-SQL by design (§2.2);
`--unhandled-rejections` strict (default-fatal since Node 15) + lint rules
against floating promises; LTS-pinned runtime; and, the big one, the
dependency allowlist security-infra already mandates language-independently
(§6.3): agents may not add dependencies, lockfiles + provenance verified in
CI, kernel dependency set ~zero by construction. **Cost:** the allowlist is
real friction (a named human approves every new package, correct
friction); supply-chain scanning tooling; occasionally re-implementing a
small utility rather than importing it. The residual: the *transitive*
surface of the non-kernel app (framework, ORM, UI) remains larger than a
Go equivalent's would be accepted, monitored, and bracketed away from the
trust kernel.

### 5.4 Monorepo tooling complexity

**The weakness.** pnpm workspaces + tsconfig project references + build
orchestration (turborepo-class) + bundler config is a genuinely fussier
toolchain than `go build ./...`, and it drifts (TS version bumps, ESM/CJS
seams, config sprawl).

**Mitigations:** one-time scaffold with strict conventions; agents are
excellent at mechanical config maintenance under CI that fails on drift;
no bundling for the server (run tsc output or a single esbuild pass).
**Cost conceded in full:** a permanent ~low-single-digit-percent tax of
engineering attention that Go simply would not charge. This is the price
of §3.3's one-language leverage, and it is the right trade only because
the web surface makes the TS toolchain non-optional anyway. The marginal
cost of TS-everywhere is the backend's share of a toolchain the company
pays for regardless.

---

## 6. Concessions

Recorded so the record is honest, not to be litigated away:

1. **Go's stdlib crypto and FIPS posture are superior**, full stop. TS
   competes only because the architecture moved signing into KMS and shrank
   the in-process surface; had D4/custody gone differently (heavy
   in-process signing with raw key material), this brief would be weaker.
2. **Single-binary deployment and runtime footprint are cleaner in Go.**
   Worth little here; worth something.
3. **Go's enforced uniformity is free; TS's idiom must be built and
   policed.** The lint/IDIOM machinery is real work and a standing
   maintenance duty.
4. **Node's transitive npm surface is a larger attack surface than Go
   modules**, mitigated but not equalized by the allowlist.
5. **A stage-C hot-path ceiling is plausible:** packet assembly at 10⁹
   identities may outgrow Node economics, and the escape (SQL push-down,
   one native module, or a bounded read-path rewrite against the
   by-then-executable kernel spec) is a real, priced cost, which ai-native §9
   also identifies.
6. **The fluency gap is narrower than advocates claim.** 2026 agents write
   competent Go; the decisive margin is type expressiveness and
   one-language leverage, not raw generation quality. The brief rests on
   §3.2/§3.3 more than §3.1, and says so.

---

## 7. Measurable switch-triggers

Commitments, not vibes. Each names the scope of the switch. None of them
flips the whole stack.

- **T1, FIPS/in-process crypto mandate.** A partner, regulator, or D3/D4
  outcome contractually requires a FIPS 140-3 validated (or equivalently
  certified) crypto module *in-process*, and KMS offload cannot satisfy it.
  → Port the trust kernel (only) to Go; it is <3k lines with golden vectors
  and a reference model, a bounded, spec-conformant port. The TS app
  calls it over a local boundary.
- **T2, read-path SLO breach.** Packet-assembly p99 > 400ms global (or
  in-region > 150ms) at measured load, *after* SQL push-down and one native
  module are exhausted, sustained across a quarter. → Rewrite the read
  module (only) in Go/Rust against the executable kernel spec. Predicted
  earliest: stage C.
- **T3, event-loop saturation.** Sustained event-loop utilization > 70%
  or loop-delay p99 > 50ms at stage-B load despite offloading. → Same
  remedy path as T2, earlier warning light.
- **T4, measured agent-reliability inversion.** The team maintains a
  small internal eval (kernel-shaped tasks, both languages, current
  frontier agents, quarterly). If Go's pass/defect-escape rate beats TS's
  by a stable, material margin (>10 points across two consecutive
  quarters), the fluency premise is dead and D2 reopens on the evidence.
- **T5, supply-chain containment failure.** A dependency-allowlist breach
  reaches a deployable artifact, or the kernel's dependency set cannot be
  held at ~zero. → Kernel port per T1's mechanics; app-layer policy
  hardening regardless of language.
- **T6, the contract stops being JSON.** If the partner interface is ever
  renegotiated to proto-first gRPC as the primary surface (not an
  add-on), Go's ecosystem advantage on that surface becomes real and the
  API layer's language reopens (the kernel and web surface do not).

The asymmetry that makes TS the correct *starting* commitment: every
trigger above is a bounded, module-scoped port made cheap by the pure
kernel + reference model + golden vectors, while the reverse migration
(Go core → TS one-language leverage) would forfeit years of the agent
throughput and single-schema discipline that the whole verification
architecture is built on. Choose the option whose failure modes have exits.

---

## Sources

- [arXiv 2512.18567, AI Code in the Wild: AI-generated-code adoption highest in strongly-typed, structured languages](https://arxiv.org/pdf/2512.18567)
- [arXiv 2606.13763, Do programming languages still matter to your AI coding agent teammate? (chess-engine study, 17 languages)](https://arxiv.org/pdf/2606.13763)
- [arXiv 2601.18827, Automated structural testing of LLM-based agents (agent test-writing failure modes)](https://arxiv.org/pdf/2601.18827)
- [Blaxel, TypeScript vs Python for AI agents (secondary source for the ~94% type-error figure)](https://blaxel.ai/blog/typescript-vs-python-ai-agents)
- [arXiv 2601.18341, Agentic Much? Adoption of coding agents on GitHub](https://arxiv.org/pdf/2601.18341)
- [paulmillr/noble-curves, audits: Trail of Bits (Feb 2023), Kudelski Security (Sep 2023)](https://github.com/paulmillr/noble-curves)
- [panva/jose, JWS/JWT/JWK reference implementation for JS runtimes](https://github.com/panva/jose)
- [panva/node-oidc-provider, OpenID Certified stack built on jose](https://github.com/panva/node-oidc-provider)
- [Go FIPS 140-3 native mode (Go 1.24)](https://go.dev/doc/security/fips140)
- [golang/go#19412, sum types proposal, open since 2017](https://github.com/golang/go/issues/19412)
- [AWS KMS Ed25519 support, Nov 2025](https://aws.amazon.com/about-aws/whats-new/2025/11/aws-kms-edwards-curve-digital-signature-algorithm/)
- Repo inputs: `design/ledger-design-0.1.md`; `design/stack-perspectives/` (all six + convergence map).
