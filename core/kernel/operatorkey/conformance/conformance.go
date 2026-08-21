// Package conformance is the executable statement of the signing
// provider contract (trust-kernel/02). It exists for the reason
// core/keys/conformance exists: decision 011 ruled out a standing
// staging environment, so no environment exercises the real KMS before
// production. The mitigation is a suite every provider must pass. The
// two in-repo providers pass it in CI on every run; the real KMS signing
// provider must pass the same suite in an ephemeral environment before
// first production use, as part of the provisioning gate.
//
// The contract, as checks:
//
//  1. A signature from the provider verifies under the public key the
//     provider resolves for the identifier it reported.
//  2. Sign reports the identifier CurrentKeyID reports, absent a
//     rotation between the two calls.
//  3. The provider signs whatever bytes it is handed, empty input
//     included, and different inputs produce different signatures.
//  4. Rotation is invisible to the signing path: Sign keeps working
//     across a rotation with no caller change and reports the new
//     identifier.
//  5. A key rotated out stays resolvable, so records it signed can
//     still be verified.
//  6. A signature made after rotation does not verify under the prior
//     key, and one made before does not verify under the new one.
//  7. An identifier the provider has never held resolves to nothing.
//  8. The provider drives kernel.Sign and kernel.Verify end to end: a
//     record signed through the kernel verifies against the provider as
//     resolver, and the identifier lands inside the signed payload.
//  9. Name is non-empty and stable across instances.
package conformance

import (
	"crypto/ed25519"
	"encoding/json"
	"testing"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/kernel/operatorkey"
)

// Run executes the provider contract against a fresh provider from
// factory. Callers pass a factory, not an instance, so the suite starts
// from a provider in its constructed state and check 9 can compare two.
func Run(t *testing.T, factory func() operatorkey.Provider) {
	t.Helper()
	p := factory()

	const message = "conformance signing input"

	// 1+2. Round trip, and the two identifier paths agree.
	reported, err := p.CurrentKeyID()
	if err != nil {
		t.Fatalf("CurrentKeyID: %v", err)
	}
	signature, used, err := p.Sign([]byte(message))
	if err != nil {
		t.Fatalf("Sign: %v", err)
	}
	if used != reported {
		t.Fatalf("Sign used %q, CurrentKeyID reported %q", used, reported)
	}
	public, resolved := p.PublicKey(used)
	if !resolved {
		t.Fatalf("PublicKey(%q) did not resolve the key that just signed", used)
	}
	if !ed25519.Verify(public, []byte(message), signature) {
		t.Fatal("the provider's signature does not verify under the key it resolves")
	}

	// 3. Whatever bytes it is handed, and distinct inputs differ.
	empty, _, err := p.Sign(nil)
	if err != nil {
		t.Fatalf("Sign(nil): %v", err)
	}
	if !ed25519.Verify(public, nil, empty) {
		t.Fatal("the signature over empty input does not verify")
	}
	other, _, err := p.Sign([]byte(message + "!"))
	if err != nil {
		t.Fatalf("Sign(other): %v", err)
	}
	if string(other) == string(signature) {
		t.Fatal("two different inputs produced the same signature")
	}

	// 4. Rotation is invisible to the signing path. The call below is
	// byte-for-byte the call made before the rotation.
	rotatedTo, err := p.Rotate()
	if err != nil {
		t.Fatalf("Rotate: %v", err)
	}
	if rotatedTo == used {
		t.Fatal("Rotate returned the identifier it was supposed to replace")
	}
	afterSignature, afterUsed, err := p.Sign([]byte(message))
	if err != nil {
		t.Fatalf("Sign after Rotate: %v", err)
	}
	if afterUsed != rotatedTo {
		t.Fatalf("Sign after Rotate used %q, want the new key %q", afterUsed, rotatedTo)
	}

	// 5. The rotated-out key is still resolvable, and what it signed
	// still verifies.
	if _, stillResolved := p.PublicKey(used); !stillResolved {
		t.Fatalf("PublicKey(%q) stopped resolving after rotation, so records it signed can no longer be verified", used)
	}
	if !ed25519.Verify(public, []byte(message), signature) {
		t.Fatal("a signature made before rotation stopped verifying")
	}

	// 6. The two keys are not interchangeable in either direction.
	afterPublic, resolved := p.PublicKey(rotatedTo)
	if !resolved {
		t.Fatalf("PublicKey(%q) did not resolve the new key", rotatedTo)
	}
	if ed25519.Verify(public, []byte(message), afterSignature) {
		t.Fatal("a signature made after rotation verified under the prior key")
	}
	if ed25519.Verify(afterPublic, []byte(message), signature) {
		t.Fatal("a signature made before rotation verified under the new key")
	}

	// 7. An identifier the provider has never held.
	if _, resolved := p.PublicKey("operatorkey-conformance-never-held"); resolved {
		t.Fatal("PublicKey resolved an identifier the provider never held")
	}

	// 8. End to end through the kernel, which is the only way this
	// provider is ever used in the product.
	compact, err := kernel.Sign([]byte(`{"claim":"conformance"}`), p)
	if err != nil {
		t.Fatalf("kernel.Sign: %v", err)
	}
	verdict := kernel.Verify(compact, p)
	if !verdict.Valid {
		t.Fatal("a record signed through the kernel did not verify against the provider as resolver")
	}
	if verdict.KeyID != rotatedTo {
		t.Fatalf("the verified record names key %q, want the provider's current key %q", verdict.KeyID, rotatedTo)
	}
	var payload map[string]json.RawMessage
	if err := json.Unmarshal(verdict.Payload, &payload); err != nil {
		t.Fatalf("verified payload is not an object: %v", err)
	}
	if _, present := payload[kernel.KeyIDField]; !present {
		t.Fatalf("the key identifier is not inside the signed payload (decision 019)")
	}

	// 9. Name is non-empty and stable (operational surfaces record it).
	if p.Name() == "" || p.Name() != factory().Name() {
		t.Fatal("Name must be non-empty and stable across instances")
	}
}
