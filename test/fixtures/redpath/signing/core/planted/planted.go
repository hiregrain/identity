// Package planted is a synthetic fixture (trust-kernel/02's red path):
// signing primitives reached outside the kernel, the three shapes
// checks/signing-seam.mjs must fail on. It is a fixture rather than a
// program and nothing builds it.
package planted

import "crypto/ed25519"

// A second signing path, with its own key handling and none of the
// contract's rules. This is what the seam exists to catch.
func signHere(private ed25519.PrivateKey, message []byte) []byte {
	return ed25519.Sign(private, message)
}

func mintAKeyHere() (ed25519.PublicKey, ed25519.PrivateKey, error) {
	return ed25519.GenerateKey(nil)
}

func reviveAKeyHere(seed []byte) ed25519.PrivateKey {
	return ed25519.NewKeyFromSeed(seed)
}

// Verification is not a violation: the lint bans producing a signature,
// not checking one, and a resolver holding a public key is ordinary.
func verifyHere(public ed25519.PublicKey, message, signature []byte) bool {
	return ed25519.Verify(public, message, signature)
}
