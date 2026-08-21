// Package dotimported is a synthetic fixture (trust-kernel/02's red
// path): the signing primitives reached through a DOT import, where
// there is no qualifier in the call at all. The other half of the
// evasion the alias fixture covers. Nothing builds it.
package dotimported

import (
	"fmt"

	. "crypto/ed25519"
)

func signHere(private PrivateKey, message []byte) []byte {
	return Sign(private, message)
}

func mintAKeyHere() (PublicKey, PrivateKey, error) {
	return GenerateKey(nil)
}

func reviveAKeyHere(seed []byte) PrivateKey {
	return NewKeyFromSeed(seed)
}

// A method call whose name happens to be Sign is not a bare call to the
// dot-imported primitive, and the check must not read it as one. It is
// here so the dot-import pattern's guard has something to be wrong
// about.
type recorder struct{}

func (r recorder) Sign(message []byte) { fmt.Println(len(message)) }

func callTheMethod(r recorder) { r.Sign(nil) }
