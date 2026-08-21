# trust-kernel/01: clean-context verification

- Task: `plans/trust-kernel/01-canonicalization-and-jws.md` (layer
  criterion trust-kernel-1)
- PR: #15, branch `task/trust-kernel-01`
- Implementation head SHA verified:
  `96a4272908e8662781254cf9c246bc30af556cd3`
- Verifier: clean-context session, 2026-08-21. Criteria, task file, diff
  and PR body only; no implementer transcript or working notes consulted.
  CI at this SHA: every job passes (run 32501030291).
- Verdict: **FAIL**, on the task's fourth acceptance criterion. The host
  branch-protection half of it is not met and no change to this branch can
  meet it. The first three criteria pass, re-run rather than re-read, and
  the outside check found nothing else.

## What fails, and what would clear it

The fourth criterion is two claims joined by "and":

> CI blocks any budget overrun, **and** the host branch-protection policy
> requiring two approvals on `core/kernel/` is asserted by querying the
> host, not inferred from CODEOWNERS.

The first half holds. The second does not. Queried directly, as a party
other than the implementer:

```
$ gh api repos/hiregrain/identity/branches/main/protection
{"message":"Not Found", ... "status":"404"}
$ gh api repos/hiregrain/identity/rulesets
[]
$ gh api repos/hiregrain/identity --jq '{admin:.permissions.admin}'
{"admin":false}
```

The rulesets endpoint answers, and it answers empty: no ruleset exists.
The classic protection endpoint 404s, which under a non-admin token is
ambiguous between absent and unreadable. Taken together there is no
evidence of any host rule and positive evidence against a ruleset. The
frozen core carries a CODEOWNERS entry and nothing that requires a second
approver.

`checks/kernel-governance.mjs` exists, runs, and reports this honestly
(`make kernel-governance` exits 1 with "The frozen core is ungoverned
until a rule requiring 2 approving reviews and code-owner review exists").
A check that correctly reports an unmet condition is not the condition
being met. The implementer says as much in the PR body, judgment call 1,
and the reading there is the right one.

Clearing it is a founder act: create the rule on `hiregrain/identity@main`
requiring at least two approving reviews and code-owner review, then re-run
`make kernel-governance` under admin credentials and record the exit-0
output. Nothing in the diff needs to change.

## Criteria, re-run

Every command below was run by the verifier at the head SHA in a clean
worktree. A sibling session held the fixed host ports 5433 and 5434 that
`compose.yaml` pins, so an untracked `compose.override.yaml` dropped the
host bindings for the database stages and was deleted afterwards. The
whole pipeline reaches both planes through `docker compose exec`, so
nothing under test reads a host port. Precedent:
`log/2026-08-19-foundation-05-verification.md`.

Precondition: `make check` green end to end, exit 0. `go test -count=1
./...` in `core` green with a cold cache. `make check-red` green, every
labelled red path in the Makefile.

**1 (mechanical): the kernel passes all regenerated vectors, the TS runner
passes the identical files, and a mutated vector fails both.** PASS.

- Regenerated from the generator into a temporary directory
  (`go run ./cmd/vectors generate <tmp>`) and diffed against the committed
  files: `diff -r contract/vectors <tmp>` exits 0. Byte-identical.
  `sha256(canonicalization.json) = de7c2812...`,
  `sha256(sign-verify.json) = f045e690...`.
- Both runners over the regenerated set:
  `go run ./cmd/vectors check` reports 16 canonicalization and 12
  sign/verify cases; `node src/check.ts` reports the same counts. Both
  exit 0.
- Mutation, verifier's own sweep rather than the repo's: seven independent
  mutations of `sign-verify.json`, each applied to a copy and run through
  both runners. Flipping an invalid case to valid, flipping a valid case
  to invalid, altering a `compact`, altering a `signedPayload`, swapping
  the two public keys, adding one space to the protected header, and
  renaming the key identifier field. Every one exits 1 in Go and 1 in
  TypeScript, fourteen rejections, no acceptance.
- Third-implementation cross-check: the verifier verified all nine
  `verify` cases with raw `node:crypto` against public keys re-derived
  independently, and agreed with the vector's verdict on every case.
- The two fixture keys were re-derived from their printable labels
  (`sha256("grain trust-kernel/01 vector key 1"|"...2")`) outside both
  implementations and match the committed seeds and public keys exactly.
  No unre-derivable constant is in the vector files.
- Differential fuzz of contract rule 2, expectations authored by the
  verifier from the thing the contract cites rather than from either
  implementation under test. 5020 number cases (random IEEE 754 doubles
  plus the named edges: negative zero, the 1e21 and 1e-7 thresholds,
  2^53-1, denormal minimum, maximum double) expected against ECMAScript
  `JSON.stringify`, and 2000 member-ordering cases over mixed
  basic-multilingual and supplementary-plane names expected against JS
  default string sort, which is UTF-16 code-unit order. Both runners pass
  all 7020.

**2 (mechanical): the signing function exposes no key parameter, proven by
its type signature.** PASS.

- `kernel.Sign(payload []byte, signer Signer) (string, error)` and
  `Signer.Sign(signingInput []byte) ([]byte, string, error)`. No key type
  in either.
- The compile-refusal fixture fails for the right reason, checked with
  stderr visible rather than through the Makefile's `2>/dev/null`:
  `too many arguments in call to kernel.Sign / have ([]byte,
  *fixture.Signer, "crypto/ed25519".PrivateKey) / want ([]byte,
  kernel.Signer)`.
- Falsified by mutation: adding `_ ed25519.PrivateKey` to `kernel.Sign`
  breaks the build. Adding `_ ...ed25519.PrivateKey` instead compiles and
  `TestSigningPathExposesNoKeyParameter` still passes, because the
  reflected parameter type is a slice of keys rather than a key. The
  Makefile red path catches that case: the fixture then builds and
  `check-red` fails. The two proofs together hold; the reflection test on
  its own does not. Recorded as a finding, not a failure.

**3 (mechanical): the key identifier is inside the signed bytes; altering
it invalidates the signature.** PASS.

- Verifier's own tamper, not the committed case: took the genuine compact
  serialization, decoded the payload
  (`{"kid":"fixture-key-1","subject":"person-1"}`), changed only the
  identifier to `fixture-key-2`, re-encoded with the signature untouched,
  and planted it as a case claiming `valid: true`, so a runner that
  accepted it would exit 0. Both runners report
  `got valid=false, want valid=true` and exit 1.
- `kernel.Sign` adds the identifier, canonicalizes, and only then signs,
  so the identifier is inside the covered bytes. The rotation window
  between `CurrentKeyID` and `Sign` is closed by comparing the reported
  key against the embedded one.
- The other end holds too: the protected header is compared byte for byte
  and never parsed, so a header carrying `kid`, a header with one space
  added, and a header naming another algorithm are all refused.

**4 (mechanical): CI blocks any budget overrun, and the host
branch-protection policy is asserted by querying the host.** FAIL, on the
second half. See above.

- Budget half, PASS: `checks/kernel-budget.mjs` is registered in
  `checks/run.mjs`'s metadata group, so `make check` and CI's `repo
  metadata` job both run it. Observed in the verifier's own `make check`
  log: "kernel-budget: core/kernel is 414 lines against a budget of under
  3000". Red path 16 proves it fires.
- Host half, FAIL.

## Outside check, as written

Every step of the task's Outside check was run. Regeneration diffs
byte-identically; both language runners pass the identical files; the
non-operator key does not compile and fails with the expected compiler
message; the tampered payload key identifier fails verification in both
implementations; the host branch-protection rule is **absent**, only the
CODEOWNERS file is present, which is the distinction the criterion was
written to catch.

## Scope

Diff against `origin/main` (three implementation commits plus one
bookkeeping commit). `core/kernel` holds canonicalization, number
formatting, key hex encodings, and the JWS envelope, and nothing else. No
chain, no Merkle, no scheduler. The fixture signer and resolver sit in a
subpackage, which is the split decision 019 asked for. `contract/runner`
is a workspace package with one direct dev dependency, `@types/node`, and
no runtime dependency. The Makefile and CI additions are additive. The
task file's only change is `evidence`, which is inside the fence. No file
outside the task's footprint. No scope creep found.

One boundary worth naming: `.github/CODEOWNERS` covers `/contract/` and
`/core/cmd/vectors/` as well as `/core/kernel/`, which is wider than the
scope line's "CODEOWNERS on `core/kernel/`". The reason is stated in the
file and is sound, since those paths hold the bytes the frozen core is
judged against. Not a defect.

## Findings

1. **The Go test cache can hide a hand-edited vector file.** The vectors
   live outside the `core` module, so `go test` does not treat them as
   inputs. With a warm cache, editing `contract/vectors/canonicalization.json`
   leaves `make go-check` reporting `ok ... cmd/vectors (cached)`. Verified:
   a semantic edit is still caught, because `ts-check` has no cache and
   fails. A non-semantic edit is not caught by either: renaming a case
   (`"empty array"` to `"empty array (hand edited)"`) leaves `make
   go-check` and `make ts-check` both green while the file no longer
   matches a fresh generation. `actions/setup-go` caches the Go build
   directory by default, so CI is exposed to the same window. The PR body's
   "a forgotten regeneration cannot merge" is therefore conditional on a
   cold cache. A `-count=1` on the vectors package, or moving the
   regeneration diff into the metadata group, would close it.
2. **`checks/kernel-governance.mjs` queries only the classic
   branch-protection endpoint.** A rule created as a repository ruleset,
   which is the host's current mechanism, would leave the check reporting
   "no readable branch protection" and exiting 1 even though the frozen
   core was governed. This also bears on the PR body's judgment call 1:
   `repos/{owner}/{repo}/rulesets` answered for a non-admin token in this
   verification, so a rulesets-aware check would be readable by CI, and
   the argument that the check cannot be wired into the blocking pipeline
   would not survive.
3. **`core/kernel/doc.go` states a constraint that is not enforced.**
   "Everything in this package directory is under the line budget and the
   two-human review rule." The budget is enforced and the comment names
   its check. The two-human review rule is not in force, which the
   CODEOWNERS header says in as many words. Decision 052 makes a comment
   whose claim has drifted a review defect. It becomes true when the
   founder creates the host rule, so it can be left as is or hedged now.
4. **`make vectors` and `make vectors-check` break on a path containing a
   space.** `$(VECTORS)` is unquoted in both recipes, so on this checkout
   `make vectors-check` fails with `usage: vectors generate|check <dir>`.
   The red path quotes its copies and uses a space-free temporary
   directory, so `check-red` is unaffected, and CI paths carry no spaces.
   Quoting both uses fixes it.
5. **Red path 17 sends the compiler's stderr to `/dev/null`.** Any build
   failure counts as a pass, so the fixture could rot into failing for an
   unrelated reason and the red path would not notice. It fails for the
   right reason today, checked above. Matching on the expected message
   would make it durable.
6. **`kernel.Signer` is an interface, so a caller can supply any key
   through its own implementation.** That is the provider seam decision 019
   describes and `core/kernel/fixture` uses it deliberately, so it is not a
   defect here. Noting it because the layer's fifth criterion, "no
   non-operator party key is invokable anywhere", is a stronger claim than
   this task's fourth criterion and is not discharged by this diff.

None of findings 1 through 6 changes the verdict on criteria 1 to 3.
