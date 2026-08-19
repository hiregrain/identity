// Package keys is the key-provider seam (foundation/05, decision 011):
// software keys for local/CI, a real KMS in production, swapped by
// configuration only. Business logic (core/envelope) holds a Provider
// and never branches on which implementation is behind it; operational
// code may know — observability, audit records, and incident response
// legitimately need to (decision 017) — which is why Name exists.
//
// A provider manages one wrapping key per scope. The scope is the
// person's ledger id: per-person wrapping keys are what make destroy a
// crypto-shred (foundation/05) rather than a bookkeeping flag. A
// destroyed scope is destroyed forever — Wrap and Unwrap against it fail
// from then on, and no call re-creates it. That matches decision 014's
// never-reissue rule: a person id, once tombstoned, never carries key
// material again.
//
// The conformance suite (core/keys/conformance) states this contract as
// executable checks. Both in-repo providers pass it in CI; the real KMS
// provider must pass the same suite in an ephemeral environment before
// first production use — the provisioning-gate mitigation for decision
// 011's no-staging ruling.
package keys

import (
	"context"
	"errors"
	"fmt"
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

// FromConfig returns the provider a configuration value names. This is
// the one place a provider name is interpreted — the config seam of
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
