# trust-kernel/01: clean-context reverification

- Task: `plans/trust-kernel/01-canonicalization-and-jws.md` (layer
  criterion trust-kernel-1)
- PR: #15, branch `task/trust-kernel-01`
- Implementation head SHA verified:
  `34a4b308b6455f7eea0f586d3fd7d0f678718b94`
- Merge base with `origin/main`:
  `d3d952e1b61c11f5cc1062cd69ee4f033476d1b2`, which already carries
  decision 087 and the amended fourth criterion, so the criteria read
  here are the ones on `main`.
- Verifier: clean-context session, 2026-08-21. Criteria, task file, diff,
  PR body, and the earlier verification record on the branch. No
  implementer transcript or working notes.
- Why a second record: `log/2026-08-21-trust-kernel-01-verification.md`
  failed the fourth criterion's host half at
  `96a4272908e8662781254cf9c246bc30af556cd3`. Decision 087 then
  superseded that criterion's policy, the task file was amended on
  `main`, the host ruleset was created, and the branch gained four more
  commits. That record stands as written; this one grades the current
  head against the current criteria.
- Verdict: **PASS**.

## Environment

Detached worktree at the implementation head. Sibling agent worktrees
held the fixed compose host ports 5433 and 5434, so the database stages
ran under a port-free compose override supplied through `COMPOSE_FILE`
and `COMPOSE_PROJECT_NAME`; the tree under verification was not edited.
Nothing in the repository connects over a host port: every database
access goes through `docker compose exec`, and the only occurrences of
5433 outside `docker-compose.yml` are `db/connections.json`, which no
program reads, and a serving-credentials red-path fixture string.

## Precondition

```
make check            -> exit 0, "check: green"
make check-red        -> exit 0, "check-red: all red paths fail as required"
```

CI at this head is green on every job, including `host rules in force on
the frozen core` (run 32518333109).

## Criteria

### 1. Kernel and TypeScript runner pass the regenerated vectors, and a mutated vector fails both

Mechanical. Regenerated into a scratch directory and byte-compared
against the committed files, then both runners pointed at the fresh
copy:

```
make vectors VECTORS=<scratch>
cmp <scratch>/canonicalization.json contract/vectors/canonicalization.json  -> exit 0
cmp <scratch>/sign-verify.json      contract/vectors/sign-verify.json       -> exit 0
make vectors-check VECTORS=<scratch>                                        -> exit 0
  vectors: kernel passes 16 canonicalization and 12 sign/verify case(s)
  vectors: the typescript runner passes 16 canonicalization and 12 sign/verify case(s)
```

Mutation: red path 16 inside `make check-red` copies the vectors, appends
a byte to an expected canonical output, and requires both runners to
reject the copy. Red path 19 plants the edit both runners tolerate, a
renamed case, and requires `checks/vector-freshness.mjs` to catch it.
Both fired. `checks/vector-freshness.mjs` also runs in the metadata group
on every `make check`, and reported byte identity there.

Pass.

### 2. The signing function exposes no key parameter

Mechanical. The exported surface, read from the compiler rather than from
the source:

```
$ go doc -all ./kernel
func Sign(payload []byte, signer Signer) (string, error)
func SignEnvelope(payload []byte, signer Signer) (compact string, keyID string, err error)
type Signer interface {
	CurrentKeyID() (string, error)
	Sign(signingInput []byte) (signature []byte, keyID string, err error)
```

No signing entry point takes a key. The compile probe run on its own:

```
$ cd test/fixtures/redpath/kernel-sign && go build ./...
./main.go:27:69: too many arguments in call to kernel.Sign
	have ([]byte, *fixture.Signer, "crypto/ed25519".PrivateKey)
	want ([]byte, kernel.Signer)
exit 1
```

The red path requires that exact message, so a build broken for any other
reason no longer passes as proof.

Pass.

### 3. The key identifier is inside the signed bytes, and altering it invalidates the signature

Mechanical, and probed rather than read. The verifier took the genuine
compact serialization out of the committed vectors, swapped the key
identifier inside the signed payload from `fixture-key-1` to
`fixture-key-2`, left the header and signature untouched, and asserted
the result **valid** in a copy of the vector file:

```
original payload: {"kid":"fixture-key-1","subject":"person-1"}
tampered payload: {"kid":"fixture-key-2","subject":"person-1"}

$ go run ./cmd/vectors check <tampered>
FAIL verify/verifier probe: key identifier swapped, asserted valid: got valid=false, want valid=true
exit 1
$ node src/check.ts <tampered>
FAIL verify/verifier probe: key identifier swapped, asserted valid: got valid=false, want valid=true
exit 1
```

Both implementations refuse the record, so the identifier is covered by
the signature in both.

Pass.

### 4. CI blocks a budget overrun, and the host policy decision 087 names is asserted by querying the host

Mechanical, both halves.

Budget. `checks/kernel-budget.mjs` is registered in `checks/run.mjs`'s
metadata group, which `make check` and CI's `metadata` job both run.

```
$ node checks/kernel-budget.mjs
kernel-budget: core/kernel is 509 lines against a budget of under 3000   -> exit 0
$ node checks/kernel-budget.mjs core/kernel 10
FAIL kernel-budget: core/kernel is 509 lines, the budget is under 10     -> exit 1
```

Host policy. Queried independently first, as a party other than the
implementer:

```
$ gh api repos/hiregrain/identity/rules/branches/main
[{"type":"deletion","ruleset_id":21162777},{"type":"non_fast_forward","ruleset_id":21162777}]
$ gh api repos/hiregrain/identity/rulesets/21162777 --jq '{enforcement,rules}'
{"enforcement":"active","rules":[{"type":"deletion"},{"type":"non_fast_forward"}]}
```

Then the check itself:

```
$ make kernel-governance
kernel-governance: .github/CODEOWNERS covers /core/kernel/, /core/cmd/vectors/, /contract/
kernel-governance: hiregrain/identity@main blocks force pushes and branch deletion (2 rule type(s) in force)
kernel-governance: the host enforces decision 087's policy on the frozen core
exit 0
```

That the host half is a live query and not an inference from the file was
probed by pointing the same check at a repository with no ruleset, from
this same tree, with the real CODEOWNERS present:

```
$ node checks/kernel-governance.mjs octocat/Hello-World
kernel-governance: .github/CODEOWNERS covers /core/kernel/, /core/cmd/vectors/, /contract/
FAIL host: octocat/Hello-World@master has no non_fast_forward rule in force ...
FAIL host: octocat/Hello-World@master has no deletion rule in force ...
exit 1
```

The file passing did not save it. Red path 20 drives the five canned
cases and all five land as required. The check runs in CI as its own job,
`host rules in force on the frozen core`, which is in the `all-green`
fan-in, so it gates the merge; it passed on the head SHA's run.

Pass.

## Outside check

Run as written. Vector regeneration, the byte diff, both runners, the
compile refusal, and the key-identifier tamper are recorded above. Three
further attempts to break the implementation, each asserting the
permissive answer and requiring both runners to refuse it:

| Probe | Asserted | Both runners |
|---|---|---|
| Nested duplicate member `{"a":{"b":1,"b":2}}` collapses to `{"a":{"b":2}}` | accepted | refused |
| Protected header with one space added, `{"alg":"EdDSA" }` | valid | refused |
| Signature segment respelled in its non-canonical base64url form, same 64 bytes | valid | refused |

The two languages agreed on every case, including the reasons, which is
what the committed vectors exist to hold.

Host ruleset: confirmed in force by direct query above, not inferred from
CODEOWNERS.

## Scope

Every file in the diff maps to a scope item in the task file:
the kernel package and its tests, the vector generator and the committed
vectors, the TypeScript runner and its workspace registration, the three
checks and their CI wiring, CODEOWNERS, the red-path and green-path
fixtures, and `core/cmd/kernel-adapter`, which the founder ruling of
2026-08-21 wrote into this task's scope. `log/` carries the earlier
verification record and `plans/` carries only `evidence`, which is inside
the fence. Nothing present that the task did not call for.

## Findings

1. **The PR body's line count has drifted.** Its fourth-criterion section
   says the frozen core is 414 lines; `checks/kernel-budget.mjs` reports
   509 at this head. The figure was written before the adapter pass added
   `keyhex.go` and the envelope split. No file in the repository carries
   the number, and the criterion is that CI blocks an overrun, which it
   does, so this does not fall. It is worth correcting in the body rather
   than leaving a count nobody regenerated.

2. **The force-push rule does not bind the one account that can rewrite
   `main`.** `hiregrain` is a user account, so
   `repos/hiregrain/identity/rulesets/21162777` reports
   `current_user_can_bypass: "always"` with `bypass_actors: null`: the
   repository owner bypasses a repository ruleset by construction.
   Decision 087 names this ruleset as the policy in force and the
   criterion asks for exactly what the check asserts, so the criterion is
   met as written. What the rule buys is protection against every other
   actor and against an accidental force push through a token that is not
   the owner's, which is most of the exposure. Worth the founder knowing
   that the guarantee stops short of the owner's own hands, and worth a
   sentence in a future entry rather than a silent assumption.

3. **A `kernel.Signer` over an arbitrary key is still constructible from
   outside the package**, since `kernel.ParsePrivateKeyHex` is exported
   and the interface is satisfiable by anyone. This is the provider seam
   decision 019 describes and it is what the earlier record recorded as
   its sixth finding. The layer's fifth criterion, no non-operator key
   invokable anywhere, is `trust-kernel/02`'s to discharge; this task
   declares `satisfies: [1]` and its own criterion is about the type
   signature, which holds.

4. **Two contract ambiguities remain unruled and are raised on the PR,
   not settled in it.** A3, unpaired surrogate escapes, where the kernel
   and the TypeScript runner refuse the document and the reference model
   preserves it; and A1, the shape of a true verdict. The kernel's
   behaviour on A3 is refusal, which alters no input, and the code says
   so where it happens. Neither touches this task's criteria. They are
   founder rulings on `contract/CONTRACT.md` and belong on `main` as
   binding prose.

## Verdict

**PASS.** All four acceptance criteria discharged, each by a command run
by the verifier at the implementation head. The outside check was run as
written and three additional attempts to break the implementation failed
to. Findings 1 through 4 are recorded and none of them falls a criterion.
