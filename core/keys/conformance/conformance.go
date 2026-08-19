// Package conformance is the executable statement of the key-provider
// contract (foundation/05). It exists because decision 011 ruled out a
// standing staging environment, so no environment exercises the real KMS
// before production: the mitigation is this suite, which every provider
// must pass — the two in-repo providers pass it in CI on every run, and
// the real KMS provider must pass it in an ephemeral environment before
// first production use, as part of the provisioning gate. It is a
// deliverable of foundation/05, not a TODO.
//
// The contract, as checks:
//
//  1. A wrapped DEK unwraps to the original under its own scope.
//  2. A wrapped blob is not the DEK in the clear and never contains it.
//  3. A blob wrapped under one scope does not unwrap under another.
//  4. A tampered blob does not unwrap.
//  5. Destroy makes Unwrap fail for the scope — the crypto-shred.
//  6. Destroy makes Wrap fail for the scope — a destroyed scope never
//     carries key material again (decision 014: ids are never reissued).
//  7. Destroy is idempotent, including on a never-seen scope.
//  8. Other scopes survive a destroy untouched.
//  9. No provider error message carries DEK or plaintext material.
package conformance

import (
	"bytes"
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/keys"
)

// Run executes the provider contract against a fresh provider from
// factory. Callers pass a factory, not an instance, so the suite starts
// from a provider with no scopes.
func Run(t *testing.T, factory func() keys.Provider) {
	t.Helper()
	ctx := context.Background()
	p := factory()

	// A recognizable marker: if any error message ever carries it, key
	// material leaked into an error path.
	dek := []byte("CONFORMANCE-DEK-MARKER-0123456789abcdef")
	const subject = "scope-subject"
	const bystander = "scope-bystander"

	// 1. Round trip under the owning scope.
	wrapped, err := p.Wrap(ctx, subject, dek)
	if err != nil {
		t.Fatalf("Wrap: %v", err)
	}
	unwrapped, err := p.Unwrap(ctx, subject, wrapped)
	if err != nil {
		t.Fatalf("Unwrap after Wrap: %v", err)
	}
	if !bytes.Equal(unwrapped, dek) {
		t.Fatal("Unwrap did not return the wrapped DEK")
	}

	// 2. The blob is ciphertext, not the DEK.
	if bytes.Equal(wrapped, dek) || bytes.Contains(wrapped, dek) {
		t.Fatal("wrapped blob contains the DEK in the clear")
	}

	// 3. Scope binding: the subject's blob does not unwrap for a
	// bystander scope, even after that scope holds its own key.
	if _, err := p.Wrap(ctx, bystander, []byte("bystander-dek")); err != nil {
		t.Fatalf("Wrap(bystander): %v", err)
	}
	if got, err := p.Unwrap(ctx, bystander, wrapped); err == nil {
		t.Fatal("a blob wrapped for one scope unwrapped under another")
	} else {
		assertNoMaterial(t, err, dek, got)
	}

	// 4. Tamper resistance.
	tampered := append([]byte{}, wrapped...)
	tampered[len(tampered)-1] ^= 0xff
	if got, err := p.Unwrap(ctx, subject, tampered); err == nil {
		t.Fatal("a tampered blob unwrapped")
	} else {
		assertNoMaterial(t, err, dek, got)
	}

	// 5+6. Destroy: unwrap and wrap both fail for the scope afterward.
	if err := p.Destroy(ctx, subject); err != nil {
		t.Fatalf("Destroy: %v", err)
	}
	if got, err := p.Unwrap(ctx, subject, wrapped); err == nil {
		t.Fatal("Unwrap succeeded after Destroy — destruction is not a crypto-shred")
	} else {
		if !errors.Is(err, keys.ErrScopeDestroyed) {
			t.Fatalf("Unwrap after Destroy: got %v, want ErrScopeDestroyed", err)
		}
		assertNoMaterial(t, err, dek, got)
	}
	if _, err := p.Wrap(ctx, subject, dek); !errors.Is(err, keys.ErrScopeDestroyed) {
		t.Fatalf("Wrap after Destroy: got %v, want ErrScopeDestroyed — a destroyed scope never carries key material again", err)
	}

	// 7. Idempotent, including a scope the provider has never seen.
	if err := p.Destroy(ctx, subject); err != nil {
		t.Fatalf("second Destroy of the same scope: %v", err)
	}
	if err := p.Destroy(ctx, "scope-never-seen"); err != nil {
		t.Fatalf("Destroy of a never-seen scope: %v", err)
	}

	// 8. The bystander scope is untouched by the subject's destruction.
	bWrapped, err := p.Wrap(ctx, bystander, []byte("bystander-dek-2"))
	if err != nil {
		t.Fatalf("Wrap(bystander) after destroying subject: %v", err)
	}
	if _, err := p.Unwrap(ctx, bystander, bWrapped); err != nil {
		t.Fatalf("Unwrap(bystander) after destroying subject: %v", err)
	}

	// Name is stable and non-empty (operational surfaces record it).
	if p.Name() == "" || p.Name() != factory().Name() {
		t.Fatal("Name must be non-empty and stable across instances")
	}
}

// assertNoMaterial fails if a failed operation returned key material or
// an error message carrying it (contract check 9).
func assertNoMaterial(t *testing.T, err error, dek, got []byte) {
	t.Helper()
	if got != nil {
		t.Fatal("a failed operation returned non-nil material")
	}
	if strings.Contains(err.Error(), string(dek)) {
		t.Fatalf("error message carries DEK material: %v", err)
	}
}
