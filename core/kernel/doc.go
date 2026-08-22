// Package kernel is the frozen core (trust-kernel, decision 019): the
// primitives that touch signatures, chains, and checkpoints.
// trust-kernel/01 lands canonical serialization and the Ed25519 JWS
// envelope, trust-kernel/03 the chain link and its verification
// (chain.go); tree construction lands in trust-kernel/04. Where a
// chain's links are stored, how its head is kept and how a merge
// resolves several chains into one history are core/streams, outside
// this directory and under ordinary review.
//
// Everything in this package directory is under the line budget, enforced
// by checks/kernel-budget.mjs, which counts this directory's non-test files
// and not its subpackages. Orchestration that calls in (schedulers,
// publishers, reconciliation, per-party root assembly) belongs outside it
// under ordinary review, so the expensive discipline stays concentrated
// where a subtle bug is unrecoverable.
//
// Decision 019 also put this directory under a two-human review rule, and
// decision 087 superseded that rule's enforcement without touching its
// intent: every pull request here is authored under the founder's own
// account and the host forbids approving your own, so required approvals
// were unsatisfiable by the only human in the repository. Kernel review is
// carried by the loop's gates now, clean-context verification, code review,
// and the founder's read at merge. What the host enforces, and what
// checks/kernel-governance.mjs asserts by querying it, is a ruleset
// blocking force pushes and branch deletion on the default branch.
//
// The normative rules this package implements are contract/CONTRACT.md,
// preserved from the T1 spike (decision 012). The golden vectors under
// contract/vectors/ are generated from this implementation by
// core/cmd/vectors and run by both this package's tests and the
// TypeScript runner in contract/runner, so a rule broken in one language
// shows up as a diff rather than as a disagreement nobody notices.
//
// Two shapes here are decision 019 and not convenience:
//
//   - Sign takes no key parameter. Key selection lives inside the operator
//     provider, which makes another party's key unexpressible rather than
//     rejected at runtime.
//   - The key identifier is a field inside the signed payload, not a JWS
//     header field. Contract rule 3 freezes the protected header to exact
//     bytes, so there is nowhere in the header to put it, and putting it in
//     the payload means nobody can change which key a record claims without
//     breaking the signature.
package kernel
