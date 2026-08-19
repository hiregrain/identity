package keys_test

import (
	"testing"

	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/keys/conformance"
)

// Both in-repo providers pass the conformance suite on every CI run —
// the same suite the real KMS provider must pass at the provisioning
// gate (core/keys/conformance).
func TestSoftwareConformance(t *testing.T) {
	conformance.Run(t, func() keys.Provider { return keys.NewSoftware() })
}

func TestStubKMSConformance(t *testing.T) {
	conformance.Run(t, func() keys.Provider { return keys.NewStubKMS() })
}

// FromConfig is the config seam (decision 011): each known name yields
// its provider, an unknown name is an error, never a silent default.
func TestFromConfig(t *testing.T) {
	for _, name := range []string{keys.NameSoftware, keys.NameStubKMS} {
		p, err := keys.FromConfig(name)
		if err != nil {
			t.Fatalf("FromConfig(%q): %v", name, err)
		}
		if p.Name() != name {
			t.Fatalf("FromConfig(%q).Name() = %q", name, p.Name())
		}
	}
	if _, err := keys.FromConfig("hardware-token"); err == nil {
		t.Fatal("FromConfig accepted an unknown provider name")
	}
}
