// Package keys is the key-provider seam (foundation/05, decision 011):
// software keys for local/CI, a real KMS in production, swapped by
// configuration only. Business logic (core/envelope) holds a Provider
// and never branches on which implementation is behind it; operational
// code may know. Observability, audit records, and incident response
// legitimately need to (decision 017), which is why Name exists.
//
// A provider manages one wrapping key per scope. The scope is the
// person's ledger id: per-person wrapping keys are what make destroy a
// crypto-shred (foundation/05) rather than a bookkeeping flag. A
// destroyed scope is destroyed forever. Wrap and Unwrap against it fail
// from then on, and no call re-creates it. That matches decision 014's
// never-reissue rule: a person id, once tombstoned, never carries key
// material again.
//
// The conformance suite (core/keys/conformance) states this contract as
// executable checks. Both in-repo providers pass it in CI; the real KMS
// provider must pass the same suite in an ephemeral environment before
// first production use, the provisioning-gate mitigation for decision
// 011's no-staging ruling.
package keys

import (
	"context"
	"errors"
	"fmt"
	"os"
)

// Provider wraps and unwraps data-encryption keys under a per-scope
// wrapping key, and destroys a scope's wrapping key irreversibly.
type Provider interface {
	// Name identifies the implementation for operational surfaces
	// (registry rows, audit records). Never a business branch.
	Name() string

	// Wrap encrypts a DEK under the scope's wrapping key, creating the
	// wrapping key if the scope has never been seen. Wrapping under a
	// destroyed scope fails with ErrScopeDestroyed.
	Wrap(ctx context.Context, scope string, dek []byte) ([]byte, error)

	// Unwrap recovers a DEK wrapped under the scope's wrapping key.
	// After Destroy(scope) it fails with ErrScopeDestroyed; a blob not
	// produced by Wrap under this scope fails with ErrUnwrapFailed.
	Unwrap(ctx context.Context, scope string, wrapped []byte) ([]byte, error)

	// Destroy irreversibly destroys the scope's wrapping key. Idempotent:
	// destroying a destroyed or never-seen scope succeeds and changes
	// nothing.
	Destroy(ctx context.Context, scope string) error
}

// Errors a provider reports. Messages carry the scope and never any key
// or content material.
var (
	ErrScopeDestroyed = errors.New("keys: scope destroyed")
	ErrUnwrapFailed   = errors.New("keys: unwrap failed")
)

// Provider names, as configuration values and as Name() results.
const (
	NameSoftware = "software"
	NameStubKMS  = "stub-kms"
)

// ProviderEnvVar is the one environment variable that selects a key
// provider. One ruling (decision 011) governs key custody, so one
// variable governs both key families: the DEK providers here and the
// ledger signing providers in core/kernel/operatorkey. A deployment that
// wrapped DEKs in a KMS and signed with a software key is unspellable.
const ProviderEnvVar = "GRAIN_KEY_PROVIDER"

// ConfiguredProviderName reads that variable, falling back to the
// software provider, which is the local and CI default decision 011
// names. It reports whether the variable was actually set, because a
// test proving a provider swap has to be able to tell "the environment
// asked for software" from "the environment asked for nothing": a CI
// change that dropped the variable would otherwise leave both runs of a
// two-provider suite on software with the second provider silently
// untested.
//
// This exists because the getenv-else-software block had been hand
// copied to five call sites (core/deletion, core/envelope's and
// core/deletion's db tests, core/person's harness, and
// core/kernel/operatorkey's suite), which is four chances for the
// default to drift from this one.
func ConfiguredProviderName() (name string, set bool) {
	name = os.Getenv(ProviderEnvVar)
	if name == "" {
		return NameSoftware, false
	}
	return name, true
}

// FromConfig returns the provider a configuration value names. This is
// the one place a provider name is interpreted, the config seam of
// decision 011's software/KMS split. The real KMS provider registers
// here when the cloud ruling lands and it has passed the conformance
// suite.
func FromConfig(name string) (Provider, error) {
	switch name {
	case NameSoftware:
		return NewSoftware(), nil
	case NameStubKMS:
		return NewStubKMS(), nil
	default:
		return nil, fmt.Errorf("keys: unknown provider %q (known: %s, %s)", name, NameSoftware, NameStubKMS)
	}
}
