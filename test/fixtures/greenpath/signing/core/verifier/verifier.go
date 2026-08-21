// Package verifier is a synthetic green-path fixture
// (trust-kernel/02): a package outside the kernel that imports
// crypto/ed25519 and verifies signatures, which checks/signing-seam.mjs
// must pass. The lint bans producing a signature, not checking one; a
// lint that banned the import would push verification behind a wrapper
// for nothing. Nothing builds this.
package verifier

import "crypto/ed25519"

func verify(public ed25519.PublicKey, message, signature []byte) bool {
	return len(public) == ed25519.PublicKeySize &&
		ed25519.Verify(public, message, signature)
}
