package operatorkey

import (
	"crypto/ed25519"
	"crypto/rand"
	"sync"

	"github.com/hiregrain/identity/core/kernel"
)

// Software is the local and CI provider (decision 011): Ed25519 keys
// generated in memory and held for the life of the process, ephemeral by
// ruling, so a restart forgets every key and no private key material is
// ever written anywhere in this repository.
type Software struct {
	ring keyring
}

// NewSoftware returns a provider holding one freshly generated key,
// already current.
func NewSoftware() (*Software, error) {
	s := &Software{ring: keyring{identify: softwareKeyID}}
	if _, err := s.ring.generate(); err != nil {
		return nil, err
	}
	return s, nil
}

// Name implements Provider.
func (s *Software) Name() string { return nameSoftware }

// CurrentKeyID implements Provider.
func (s *Software) CurrentKeyID() (string, error) { return s.ring.currentKeyID() }

// Sign implements Provider.
func (s *Software) Sign(signingInput []byte) ([]byte, string, error) {
	return s.ring.sign(signingInput)
}

// PublicKey implements Provider.
func (s *Software) PublicKey(keyID string) (ed25519.PublicKey, bool) {
	return s.ring.publicKey(keyID)
}

// Rotate implements Provider.
func (s *Software) Rotate() (string, error) { return s.ring.generate() }

// softwareKeyID derives the identifier from the key itself, in contract
// rule 4's encoding (core/kernel/keyhex.go). Derived rather than
// assigned: two identifiers are equal exactly when the keys are, and
// nothing has to allocate, persist, or agree on a counter. A real KMS
// names its own keys instead, which is why the identifier's shape is
// each provider's and the log column that holds it is opaque text
// (0006-key-event-log).
func softwareKeyID(public ed25519.PublicKey) string {
	return kernel.PublicKeyHex(public)
}

// keyring is the key custody both in-repo providers share: an ordered
// generation of Ed25519 keys, the newest current, every one of them
// still resolvable. The wire-visible difference between the providers is
// the identifier each mints, which is `identify`.
type keyring struct {
	mu       sync.Mutex
	identify func(ed25519.PublicKey) string
	current  string
	held     map[string]ed25519.PrivateKey
}

// generate mints a fresh key and makes it current, leaving every earlier
// key resolvable.
func (r *keyring) generate() (string, error) {
	public, private, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return "", err
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.held == nil {
		r.held = map[string]ed25519.PrivateKey{}
	}
	id := r.identify(public)
	r.held[id] = private
	r.current = id
	return id, nil
}

func (r *keyring) currentKeyID() (string, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.current == "" {
		return "", ErrNoActiveKey
	}
	return r.current, nil
}

// sign reads the current key and signs under one lock hold, so a
// concurrent Rotate cannot land between the read and the signature and
// produce a signature attributed to the key it replaced.
func (r *keyring) sign(signingInput []byte) ([]byte, string, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.current == "" {
		return nil, "", ErrNoActiveKey
	}
	private, held := r.held[r.current]
	if !held {
		return nil, "", ErrNoActiveKey
	}
	return ed25519.Sign(private, signingInput), r.current, nil
}

func (r *keyring) publicKey(keyID string) (ed25519.PublicKey, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	private, held := r.held[keyID]
	if !held {
		return nil, false
	}
	return private.Public().(ed25519.PublicKey), true
}
