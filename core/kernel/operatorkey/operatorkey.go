// Package operatorkey is the ledger signing key's custody seam
// (trust-kernel/02, decision 011): software keys for local and CI, a real
// KMS in production, swapped by configuration only. It is the real
// implementation of kernel.Signer, which core/kernel/jws.go declares and
// core/kernel/fixture stands in for while generating the golden vectors.
//
// It sits beside the frozen core rather than inside it, the split
// decision 019 asked for: custody is orchestration, the primitives are
// the kernel. Being a subpackage is also what keeps
// checks/kernel-budget.mjs measuring the frozen core rather than its
// scaffolding.
//
// Three shapes here are rulings, not convenience:
//
//   - Sign takes no key parameter (decision 019). Key selection lives
//     inside the provider, so signing with another party's key is
//     unexpressible rather than rejected by a runtime check somebody can
//     later regress. checks/signing-seam.mjs holds the other half: no
//     package outside this one and the kernel reaches an Ed25519 signing
//     primitive at all.
//   - Rotation is internal. There is no key argument to move, so a
//     caller cannot notice a rotation except by reading the identifier
//     Sign reports back. Rotate exists for the operator, not the
//     signing path.
//   - A rotated-out key stays resolvable. PublicKey answers for every
//     key this provider has ever held, because verification of a record
//     signed last year must still work after this year's rotation. What
//     stops that key signing again is the key-event log's rule
//     (core/kernel/keyevent.go), not the provider forgetting it.
//
// The conformance suite (core/kernel/operatorkey/conformance) states the
// contract as executable checks. Both in-repo providers pass it in CI;
// the real KMS provider must pass the same suite in an ephemeral
// environment before first production use, which is the mitigation
// decision 011's no-staging ruling forces.
package operatorkey

import (
	"crypto/ed25519"
	"errors"
	"fmt"

	"github.com/hiregrain/identity/core/keys"
)

// Provider signs with the operator's own current key and resolves any
// key it has held. It satisfies kernel.Signer and kernel.Resolver.
type Provider interface {
	// Name identifies the implementation for operational surfaces
	// (audit records, key-event rows). Never a business branch, the
	// same rule core/keys states for its own Name (decision 017).
	Name() string

	// CurrentKeyID reports the key Sign would use now. Sign cannot
	// report it first, because decision 019 puts the identifier inside
	// the payload, so it has to be known before the payload is signed.
	CurrentKeyID() (string, error)

	// Sign signs signingInput with the current active key and reports
	// which key that was. No key parameter: see the package comment.
	Sign(signingInput []byte) (signature []byte, keyID string, err error)

	// PublicKey resolves an identifier to a key this provider holds or
	// has held, and reports false for anything else.
	PublicKey(keyID string) (ed25519.PublicKey, bool)

	// Rotate generates a fresh key, makes it current, and returns its
	// identifier. The prior key stays resolvable for verification.
	Rotate() (keyID string, err error)
}

// Provider names, as configuration values and as Name() results. They
// are core/keys' constants rather than copies, so the claim that one
// configuration value selects both key families is enforced by the
// compiler instead of by two lists staying in step.
const (
	nameSoftware = keys.NameSoftware
	nameStubKMS  = keys.NameStubKMS
)

// ErrNoActiveKey reports a provider asked to sign before it holds a key.
// Both in-repo providers generate one at construction, so this is the
// error a future provider whose backing store is unreachable reports.
var ErrNoActiveKey = errors.New("operatorkey: no active signing key")

// FromConfig returns the signing provider a configuration value names.
// The vocabulary is core/keys': one ruling (decision 011) governs both
// key families, so one configuration value selects both and a
// half-software half-KMS deployment is unspellable. This is the one
// place a provider name is interpreted on the signing side; the real KMS
// provider registers here when the cloud ruling lands and it has passed
// the conformance suite.
func FromConfig(name string) (Provider, error) {
	switch name {
	case keys.NameSoftware:
		return NewSoftware()
	case keys.NameStubKMS:
		return NewStubKMS()
	default:
		return nil, fmt.Errorf("operatorkey: unknown provider %q (known: %s, %s)", name, keys.NameSoftware, keys.NameStubKMS)
	}
}
