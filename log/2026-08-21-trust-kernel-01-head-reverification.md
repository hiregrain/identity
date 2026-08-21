# trust-kernel/01: clean-context reverification at the fixed head

- Task: `plans/trust-kernel/01-canonicalization-and-jws.md` (layer
  criterion trust-kernel-1)
- PR: #15, branch `task/trust-kernel-01`
- Implementation head SHA verified:
  `6c78d826d9712f7bcfe7671a81e643128dbc11da`
- Merge base with `origin/main`:
  `cbec5c81df273e095bb8cf1b7c2ee686138fd522`, which equals
  `origin/main`, so the criteria read here are the ones on `main`.
- Verifier: clean-context session, 2026-08-21. Inputs: criteria, task
  file, diff, PR body, and the two earlier verification records on the
  branch. No implementer transcript or working notes.
- Why a third record: the branch's frontmatter carried `status: done`
  and `verified_by` from a pass at `34a4b30`
  (`log/2026-08-21-trust-kernel-01-reverification.md`). After that pass,
  commit `67c8eca` landed ten code-review fixes to the frozen core, and
  `6c78d82` merged the record. The prior done did not cover the current
  code. Both earlier records stand as written; this one grades the
  current head. The two records above stay as frozen facts.
- Verdict: **PASS**.

## Environment

Detached worktree at the implementation head. Sibling agent worktrees
held the fixed compose host ports 5433 and 5434, so the database stages
ran under a port-free compose override supplied through `COMPOSE_FILE`
(both paths absolute) and `COMPOSE_PROJECT_NAME=tk01verify`. Nothing in
the repository connects over a host port: every database command runs
`docker compose exec` inside the container, so dropping the port
mappings changes no behaviour under test. The tree under verification
was not edited; the override file lives outside it.

## Precondition

`make check` exits 0 at the head under the port-free override
(`check: green`). Green is a precondition, not evidence of the criteria.
`make lint` exits 0 (gofmt, prettier, eslint). `make check-red` exits 0:
every red path fails as required.

## Criteria

The task's acceptance is four mechanical AC clauses plus the Outside
check. Each was resolved to a command run at this head.

### AC 1: the kernel passes all regenerated vectors, the TS runner passes the identical files, and a mutated vector fails both

PASS.

- `cd core && go run ./cmd/vectors generate <tmp>` then
  `diff` against `contract/vectors`: both files byte-identical to a
  fresh generation.
- `cd core && go run ./cmd/vectors check contract/vectors`: 17
  canonicalization and 15 sign/verify cases pass.
- `cd contract/runner && node src/check.ts ../vectors`: the same 17 and
  15 cases pass.
- `node checks/vector-freshness.mjs` (metadata group): byte-identical to
  a fresh generation.
- Mutation, red path 16: a copy with one trailing byte appended to a
  case's expected `canonical` is rejected by the Go kernel and by the TS
  runner. Both non-zero.

### AC 2: the signing function exposes no key parameter, proven by its type signature

PASS.

- `kernel.Sign(payload []byte, signer Signer) (string, error)` and
  `Signer.Sign(signingInput []byte) ([]byte, string, error)`. No
  `ed25519` key type and no second byte slice a key could travel in.
- `go test ./kernel -run TestSigningPathExposesNoKeyParameter`: pass.
- Red path 18: the fixture handing `kernel.Sign` a generated private key
  fails to compile with exactly `too many arguments in call to
  kernel.Sign`. The red path fails if it ever compiles or fails for any
  other reason.

### AC 3: the key identifier is inside the signed bytes; altering it invalidates the signature

PASS.

- Vector cases `payload key identifier swapped for the other key`,
  `payload key identifier names a key nobody holds`, and `payload
  content altered under an untouched key identifier` all verify to
  `{"valid":false}` in both runners.
- `go test ./kernel -run
  'TestAlteringTheKeyIdentifierBreaksTheSignature|TestSignPlacesTheKeyIdentifierInsideTheSignedBytes|TestVerifyRefusesAnyOtherHeaderBytes'`:
  pass.

### AC 4: CI blocks any budget overrun, and the host policy decision 087 names is asserted by querying the host

PASS.

- Budget: `node checks/kernel-budget.mjs` reports `core/kernel is 558
  lines against a budget of under 3000`. Red path 17 (`kernel-budget.mjs
  core/kernel 10`) fails as required.
- Host policy: `node checks/kernel-governance.mjs hiregrain/identity`
  exits 0 against the live host:
  `hiregrain/identity@main blocks force pushes and branch deletion (2
  rule type(s) in force)` and CODEOWNERS covers the kernel paths. Red
  path 20 drives the five canned-answer cases: each missing piece fails
  on its own line, and the in-force fixture passes.

## Outside check

Run exactly as written.

- Regenerate vectors from the generator, diff against committed:
  byte-identical (both files). PASS.
- Both language runners over the committed files: pass. PASS.
- Attempt to sign with a non-operator key: red path 18 confirms it does
  not compile (`too many arguments in call to kernel.Sign`). PASS.
- Tamper with the payload key identifier: the swapped-key and
  unknown-key vector cases verify false in both runners. PASS.
- Confirm the host ruleset decision 087 names is in force rather than
  only the CODEOWNERS file: `kernel-governance.mjs` against the live host
  reports both rule types in force, separately from the file. PASS.

## The ten code-review fixes re-probed

Each fix in `67c8eca` was re-probed at the head. The first four were
probed by an independent external test written against the exported API
only (`kernel_test` package, removed after the run), corroborated by the
package's own guard tests; the rest by reading the diff and running the
covering test or vector.

1. `Sign([]byte("null"))` returns `ErrPayloadNotObject`, not a panic.
   Independent probe returned `kernel: payload is not a JSON object:
   payload is null, not an object`.
   `TestSignRefusesNullPayloadWithoutPanicking` passes.
2. `Verify` and `VerifyWithKey` return `Invalid()` on a wrong-length
   public key, not a panic. Independent probe drove a 5-byte and a
   3-byte key through both and got a false verdict without a panic.
   `TestVerifyRefusesAWrongLengthKeyWithoutPanicking` passes.
3. Deeply nested input returns `ErrTooDeep`, not a fatal stack overflow.
   Independent probe: `Canonicalize` of a 2,000,000-deep array returned
   `kernel: JSON nesting exceeds the depth limit: deeper than 256`.
4. The true verdict serializes as exactly `{"valid":true}`. Independent
   probe marshalled a true verdict and got `{"valid":true}`, and the
   false verdict `{"valid":false}`. Pinned by the `trueVerdict` and
   `falseVerdict` fields in `sign-verify.json`, which both runners
   check.
5. The TS runner refuses the duplicate-key and over-range-number
   payloads instead of signing them. `sign` canonicalizes the raw
   payload before inserting the key identifier
   (`contract/runner/src/jws.ts:76`), and the two `rejected` sign
   vectors require both languages to refuse them. `node src/check.ts`
   passes with those cases present.
6. The vectors now carry a rejected surrogate and a non-canonical
   base64url case. `canonicalization.json` has `rejected: unpaired
   surrogate escape`; `sign-verify.json` has `non-canonical base64url in
   the signature segment`. Both runners exercise them.
7. The O(n^2) sort is replaced and the ordering is unchanged.
   `sortMembers` uses `slices.SortFunc` with a non-allocating UTF-16
   cursor comparator. `TestCompareUTF16MatchesTheReferenceOrder` checks
   the new comparator against the old `[]uint16` order over 20000 random
   pairs, and `TestCanonicalizeSortsALargeReverseOrderedObject` sorts a
   4000-key reverse-ordered object; both pass.

Fixes 8 (nil-map null guard, same code as fix 1), 9 (dead
`fixture.ErrUnknownKey` export removed), and 10 (adapter uses
`utf16.EncodeRune`) were read in the diff and are covered by
`go vet ./...` clean and `go test ./...` green, including
`core/cmd/kernel-adapter`.

## Scope

The fix commit `67c8eca` touches only the kernel, the vector generator,
the runner, the adapter, and the fixture's dead-export removal. No file
outside the task's scope. The PR body's ten judgment calls are all
disclosed; none is a `None.` claim to falsify.

## Findings

None. The differential claim in the fix commit (zero divergence over
20108 requests) was not independently re-run, because the
trust-kernel/06 harness is not merged into this branch; it is a scope
item, not one of the four ACs or the Outside check, and every AC and
Outside-check clause is green without it.

## Verdict

PASS at `6c78d826d9712f7bcfe7671a81e643128dbc11da`. All four mechanical
AC clauses and every Outside-check clause resolve to a command that
passed at the head. The stale `status: done` from the `34a4b30` pass is
superseded by this record.
