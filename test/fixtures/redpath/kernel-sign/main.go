// This file must not compile. Decision 019 requires that signing with a
// key the caller chose is unexpressible rather than rejected at run time,
// and the only way to show "unexpressible" is to write the call and let
// the compiler refuse it. The Makefile red path builds this directory and
// requires a non-zero exit.
package main

import (
	"crypto/ed25519"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/kernel/fixture"
)

func main() {
	signer, err := fixture.NewSigner(fixture.Keys()[0])
	if err != nil {
		panic(err)
	}
	_, stolen, err := ed25519.GenerateKey(nil)
	if err != nil {
		panic(err)
	}

	// The attempt: hand the kernel another party's key and ask it to sign
	// with that one. There is no parameter for it.
	if _, err := kernel.Sign([]byte(`{"subject":"person-1"}`), signer, stolen); err != nil {
		panic(err)
	}
}
