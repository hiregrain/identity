// Package aliased is a synthetic fixture (trust-kernel/02's red path):
// the signing primitives reached through an ALIASED import. A code
// review found that a check matching the literal text `ed25519.` scanned
// this green, so the alias shapes have their own fixture file. Nothing
// builds it.
package aliased

import ed "crypto/ed25519"

func signHere(private ed.PrivateKey, message []byte) []byte {
	return ed.Sign(private, message)
}

func mintAKeyHere() (ed.PublicKey, ed.PrivateKey, error) {
	return ed.GenerateKey(nil)
}

func reviveAKeyHere(seed []byte) ed.PrivateKey {
	return ed.NewKeyFromSeed(seed)
}
