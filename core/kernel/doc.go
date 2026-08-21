// Package kernel is the frozen core (trust-kernel, decision 019): the
// primitives that touch signatures, chains, and checkpoints.
// trust-kernel/01 lands the first two, canonical serialization and the
// Ed25519 JWS envelope; chain append/verify and tree construction land in
// trust-kernel/03 and /04.
//
// Everything in this package directory is under the line budget and the
// two-human review rule. Orchestration that calls in (schedulers,
// publishers, reconciliation, per-party root assembly) belongs outside it
// under ordinary review, so the expensive discipline stays concentrated
// where a subtle bug is unrecoverable. The budget is enforced by
// checks/kernel-budget.mjs, which counts this directory's non-test files
// and not its subpackages.
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
