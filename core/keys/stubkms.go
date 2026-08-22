package keys

import (
	"bytes"
	"context"
	"crypto/aes"
	"crypto/rand"
	"sync"
)

// stubKMSHeader prefixes every stub-wrapped blob, standing in for the
// key-id/version header a real KMS token carries. It makes the stub's
// wire format visibly distinct from the software provider's, so a test
// that swaps providers by config cannot pass by the two being the same
// code in two coats. It also gives Unwrap a KMS-shaped failure mode
// (token not from this KMS) separate from a bad ciphertext.
var stubKMSHeader = []byte("stub-kms/v1\x00")

// StubKMS stands in for the production KMS provider until the cloud
// ruling lands (decision 011). It mimics the KMS contract the
// conformance suite states over in-memory key material. That contract is
// remote-call shape (context honored before any cryptography), per-scope
// keys, schedule-free irreversible destruction, and idempotent destroy. The
// real KMS provider replaces it behind FromConfig after passing the
// same conformance suite in an ephemeral environment (the provisioning
// gate).
type StubKMS struct {
	mu        sync.Mutex
	kek       map[string][]byte
	destroyed map[string]bool
}

// NewStubKMS returns a fresh stub with no scopes.
func NewStubKMS() *StubKMS {
	return &StubKMS{kek: map[string][]byte{}, destroyed: map[string]bool{}}
}

// Name implements Provider.
func (s *StubKMS) Name() string { return NameStubKMS }

// Wrap implements Provider.
func (s *StubKMS) Wrap(ctx context.Context, scope string, dek []byte) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	kek, err := s.scopeKEK(scope, true)
	if err != nil {
		return nil, err
	}
	sealed, err := gcmSeal(kek, scope, dek)
	if err != nil {
		return nil, err
	}
	return append(append([]byte{}, stubKMSHeader...), sealed...), nil
}

// Unwrap implements Provider.
func (s *StubKMS) Unwrap(ctx context.Context, scope string, wrapped []byte) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if !bytes.HasPrefix(wrapped, stubKMSHeader) {
		return nil, ErrUnwrapFailed
	}
	kek, err := s.scopeKEK(scope, false)
	if err != nil {
		return nil, err
	}
	return gcmOpen(kek, scope, wrapped[len(stubKMSHeader):])
}

// Mac implements Provider. Context is honored before any cryptography,
// the remote-call shape the rest of this stub keeps.
func (s *StubKMS) Mac(ctx context.Context, scope string, message []byte) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	kek, err := s.scopeKEK(scope, true)
	if err != nil {
		return nil, err
	}
	return scopeMac(kek, scope, message), nil
}

// Destroy implements Provider. Immediate and irreversible, the stub
// models the post-schedule state a real KMS reaches, not the pending
// window, because the conformance contract is about the end state.
func (s *StubKMS) Destroy(ctx context.Context, scope string) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if kek, ok := s.kek[scope]; ok {
		clear(kek)
		delete(s.kek, scope)
	}
	s.destroyed[scope] = true
	return nil
}

func (s *StubKMS) scopeKEK(scope string, create bool) ([]byte, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.destroyed[scope] {
		return nil, ErrScopeDestroyed
	}
	if kek, ok := s.kek[scope]; ok {
		return kek, nil
	}
	if !create {
		return nil, ErrUnwrapFailed
	}
	kek := make([]byte, 2*aes.BlockSize)
	if _, err := rand.Read(kek); err != nil {
		return nil, err
	}
	s.kek[scope] = kek
	return kek, nil
}
