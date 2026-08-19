package keys

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"sync"
)

// Software is the local/CI provider (decision 011): per-scope wrapping
// keys generated in memory and held for the life of the process —
// ephemeral by ruling, so a restart forgets every key and nothing
// persists outside the registry's wrapped blobs. Wrapping is
// AES-256-GCM with the scope as additional authenticated data, so a
// blob wrapped for one scope cannot unwrap under another even if key
// material were ever shared.
type Software struct {
	mu        sync.Mutex
	kek       map[string][]byte
	destroyed map[string]bool
}

// NewSoftware returns a fresh software provider with no scopes.
func NewSoftware() *Software {
	return &Software{kek: map[string][]byte{}, destroyed: map[string]bool{}}
}

// Name implements Provider.
func (s *Software) Name() string { return NameSoftware }

// Wrap implements Provider.
func (s *Software) Wrap(_ context.Context, scope string, dek []byte) ([]byte, error) {
	kek, err := s.scopeKEK(scope, true)
	if err != nil {
		return nil, err
	}
	return gcmSeal(kek, scope, dek)
}

// Unwrap implements Provider.
func (s *Software) Unwrap(_ context.Context, scope string, wrapped []byte) ([]byte, error) {
	kek, err := s.scopeKEK(scope, false)
	if err != nil {
		return nil, err
	}
	return gcmOpen(kek, scope, wrapped)
}

// Destroy implements Provider. The scope's key material is zeroed and
// dropped, and the scope is marked destroyed forever.
func (s *Software) Destroy(_ context.Context, scope string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if kek, ok := s.kek[scope]; ok {
		clear(kek)
		delete(s.kek, scope)
	}
	s.destroyed[scope] = true
	return nil
}

// scopeKEK returns the scope's wrapping key, creating it when create is
// set and the scope has never been seen. A destroyed scope always fails.
func (s *Software) scopeKEK(scope string, create bool) ([]byte, error) {
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
	kek := make([]byte, 32)
	if _, err := rand.Read(kek); err != nil {
		return nil, err
	}
	s.kek[scope] = kek
	return kek, nil
}

// gcmSeal encrypts plaintext under a 32-byte key with AES-256-GCM,
// nonce prepended, scope bound as AAD. Shared by both in-repo providers;
// the wire format is each provider's own.
func gcmSeal(key []byte, scope string, plaintext []byte) ([]byte, error) {
	aead, err := newAEAD(key)
	if err != nil {
		return nil, err
	}
	nonce := make([]byte, aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}
	return aead.Seal(nonce, nonce, plaintext, []byte(scope)), nil
}

// gcmOpen reverses gcmSeal. Every malformed or mismatched input is
// ErrUnwrapFailed — the error never describes the blob.
func gcmOpen(key []byte, scope string, blob []byte) ([]byte, error) {
	aead, err := newAEAD(key)
	if err != nil {
		return nil, err
	}
	if len(blob) < aead.NonceSize() {
		return nil, ErrUnwrapFailed
	}
	plaintext, err := aead.Open(nil, blob[:aead.NonceSize()], blob[aead.NonceSize():], []byte(scope))
	if err != nil {
		return nil, ErrUnwrapFailed
	}
	return plaintext, nil
}

func newAEAD(key []byte) (cipher.AEAD, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	return cipher.NewGCM(block)
}
