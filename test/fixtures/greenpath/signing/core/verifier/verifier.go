// Package verifier is a synthetic green-path fixture
// (trust-kernel/02): a package outside the kernel that imports
// crypto/ed25519 and verifies signatures, which checks/signing-seam.mjs
// must pass. The lint bans producing a signature, not checking one; a
// lint that banned the import would push verification behind a wrapper
// for nothing. Nothing builds this.
package verifier

import (
	ed "crypto/ed25519"
)

func verify(public ed.PublicKey, message, signature []byte) bool {
	return len(public) == ed.PublicKeySize &&
		ed.Verify(public, message, signature)
}

// A method named Sign, called on a value rather than on the package.
// The lint binds the qualifier from the import, so `s.Sign(` is not a
// call to the primitive and this file must stay green.
type signerHandle struct{}

func (s signerHandle) Sign(message []byte) ([]byte, error) { return message, nil }

func delegate(s signerHandle, message []byte) ([]byte, error) { return s.Sign(message) }
