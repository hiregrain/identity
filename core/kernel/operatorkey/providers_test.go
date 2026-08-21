package operatorkey_test

// The signing-provider suite (trust-kernel/02). Every test below that
// needs one provider takes the CONFIGURED provider, chosen by
// GRAIN_KEY_PROVIDER alone and defaulting to software, exactly as
// core/person's harness does it. `make signing-test` runs this file once
// per provider with that variable as the only difference between the two
// runs, which is the acceptance clause "provider swap is config-only;
// suite green under both". A test that named a provider itself would
// make the variable decorative.

import (
	"os"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/kernel/operatorkey"
	"github.com/hiregrain/identity/core/kernel/operatorkey/conformance"
	"github.com/hiregrain/identity/core/keys"
)

// The configured provider passes the conformance suite. This is the same
// suite the real KMS signing provider must pass at the provisioning gate
// (core/kernel/operatorkey/conformance).
func TestConfiguredProviderConformance(t *testing.T) {
	conformance.Run(t, func() operatorkey.Provider { return configured(t) })
}

// FromConfig is the config seam (decision 011): each known name yields
// its provider, an unknown name is an error, never a silent default.
func TestFromConfig(t *testing.T) {
	for _, name := range []string{keys.NameSoftware, keys.NameStubKMS} {
		p, err := operatorkey.FromConfig(name)
		if err != nil {
			t.Fatalf("FromConfig(%q): %v", name, err)
		}
		if p.Name() != name {
			t.Fatalf("FromConfig(%q).Name() = %q", name, p.Name())
		}
	}
	if _, err := operatorkey.FromConfig("hardware-token"); err == nil {
		t.Fatal("FromConfig accepted an unknown provider name")
	}
}

// The two providers mint visibly different identifiers, so a swap that
// silently did nothing would fail here rather than pass by the two being
// one implementation in two coats. This is the one test that names both
// providers, because the claim is about the difference between them.
func TestTheTwoProvidersMintDistinguishableIdentifiers(t *testing.T) {
	software := named(t, keys.NameSoftware)
	stub := named(t, keys.NameStubKMS)

	softwareID, err := software.CurrentKeyID()
	if err != nil {
		t.Fatalf("CurrentKeyID(software): %v", err)
	}
	stubID, err := stub.CurrentKeyID()
	if err != nil {
		t.Fatalf("CurrentKeyID(stub-kms): %v", err)
	}
	if !strings.HasPrefix(stubID, "stub-kms/") {
		t.Fatalf("the stub KMS identifier %q does not carry its own shape", stubID)
	}
	if strings.HasPrefix(softwareID, "stub-kms/") {
		t.Fatalf("the software identifier %q carries the stub KMS shape", softwareID)
	}
	if _, resolved := software.PublicKey(stubID); resolved {
		t.Fatal("the software provider resolved the stub KMS provider's identifier")
	}
}

// Rotation is invisible to callers (the third acceptance clause). The
// call under test is the product's own entry point, kernel.Sign, and it
// is byte-for-byte the same call on both sides of the rotation: no key
// argument exists for a caller to change, which is decision 019.
func TestRotationIsInvisibleToCallers(t *testing.T) {
	p := configured(t)
	payload := []byte(`{"claim":"rotation is invisible"}`)

	before, err := kernel.Sign(payload, p)
	if err != nil {
		t.Fatalf("kernel.Sign before rotation: %v", err)
	}
	beforeVerdict := kernel.Verify(before, p)
	if !beforeVerdict.Valid {
		t.Fatal("the pre-rotation record does not verify")
	}

	rotatedTo, err := p.Rotate()
	if err != nil {
		t.Fatalf("Rotate: %v", err)
	}

	after, err := kernel.Sign(payload, p)
	if err != nil {
		t.Fatalf("kernel.Sign after rotation: %v", err)
	}
	afterVerdict := kernel.Verify(after, p)
	if !afterVerdict.Valid {
		t.Fatal("the post-rotation record does not verify")
	}
	if afterVerdict.KeyID != rotatedTo {
		t.Fatalf("the post-rotation record names key %q, want %q", afterVerdict.KeyID, rotatedTo)
	}
	if afterVerdict.KeyID == beforeVerdict.KeyID {
		t.Fatal("the record signed after rotation names the key that was rotated out")
	}
	// The pre-rotation record still verifies: the provider keeps
	// resolving a key it has rotated out, and what stops that key
	// signing again is custody, not the resolver forgetting it.
	if !kernel.Verify(before, p).Valid {
		t.Fatal("the pre-rotation record stopped verifying after a rotation")
	}
}

// A provider is usable for signing the moment it is constructed: it
// mints its first key there rather than waiting for a caller to ask, so
// ErrNoActiveKey is reachable only by a provider whose backing store is
// unreachable.
func TestAProviderSignsImmediatelyAfterConstruction(t *testing.T) {
	if _, _, err := configured(t).Sign([]byte("first")); err != nil {
		t.Fatalf("Sign immediately after construction: %v", err)
	}
}

// configured builds the provider the environment names, the one place
// this file reads the configuration.
func configured(t *testing.T) operatorkey.Provider {
	t.Helper()
	name := os.Getenv("GRAIN_KEY_PROVIDER")
	if name == "" {
		name = keys.NameSoftware
	}
	return named(t, name)
}

func named(t *testing.T, name string) operatorkey.Provider {
	t.Helper()
	p, err := operatorkey.FromConfig(name)
	if err != nil {
		t.Fatalf("FromConfig(%q): %v", name, err)
	}
	return p
}
