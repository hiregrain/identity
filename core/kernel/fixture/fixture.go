// Package fixture holds the deterministic signer and key resolver the
// golden vectors are generated with (trust-kernel/01).
//
// It is deliberately not part of the frozen core: the real signing
// provider is trust-kernel/02 and the real resolver reads the party
// registry, which lands in party-registry. Keeping the fixtures in their
// own package is also what keeps the kernel's line budget measuring the
// frozen core rather than its scaffolding, which is the split decision 019
// asked for.
//
// Every key here is derived from a printable label by SHA-256, so the
// vectors regenerate byte-identically on any machine and no seed in this
// repo is a number somebody chose and nobody can re-derive. These keys are
// public by construction and are usable for nothing but the vectors.
package fixture

import (
	"crypto/ed25519"
	"crypto/sha256"
	"encoding/hex"
	"errors"

	"github.com/hiregrain/identity/core/kernel"
)

// Key is one fixture key in the contract's own encoding (rule 4).
type Key struct {
	ID         string
	PrivateHex string
	PublicHex  string
}

// Labels the seeds derive from. They name the task that created them, so a
// reader can tell where a key came from without a lookup table.
const (
	labelPrefix = "grain trust-kernel/01 vector key "

	// KeyID1 signs the vectors. KeyID2 exists so the vectors can carry a
	// wrong-key case, which is the only way to show that verification is
	// bound to the identifier inside the payload.
	KeyID1 = "fixture-key-1"
	KeyID2 = "fixture-key-2"
)

// Keys returns the fixture keys in a fixed order.
func Keys() []Key {
	return []Key{derive(KeyID1, "1"), derive(KeyID2, "2")}
}

func derive(id, suffix string) Key {
	seed := sha256.Sum256([]byte(labelPrefix + suffix))
	private := ed25519.NewKeyFromSeed(seed[:])
	return Key{
		ID:         id,
		PrivateHex: hex.EncodeToString(seed[:]),
		PublicHex:  kernel.PublicKeyHex(private.Public().(ed25519.PublicKey)),
	}
}

// Signer is a kernel.Signer over one fixture key. It takes no key
// parameter on the signing path for the same reason the real provider does
// not (decision 019): the key is chosen when the signer is constructed, not
// when a caller asks for a signature.
type Signer struct {
	keyID   string
	private ed25519.PrivateKey
}

// NewSigner builds a signer over one fixture key.
func NewSigner(key Key) (*Signer, error) {
	private, err := kernel.ParsePrivateKeyHex(key.PrivateHex)
	if err != nil {
		return nil, err
	}
	return &Signer{keyID: key.ID, private: private}, nil
}

// CurrentKeyID reports the key Sign will use.
func (s *Signer) CurrentKeyID() (string, error) { return s.keyID, nil }

// Sign signs the prepared bytes and reports the key used.
func (s *Signer) Sign(signingInput []byte) ([]byte, string, error) {
	return ed25519.Sign(s.private, signingInput), s.keyID, nil
}

// ErrUnknownKey is what a resolver reports through its found result; it
// exists so a caller can say why a lookup failed in a message.
var ErrUnknownKey = errors.New("fixture: no such key identifier")

// Resolver is a kernel.Resolver over a fixed key set, standing in for the
// party-registry lookup until that layer lands.
type Resolver map[string]ed25519.PublicKey

// NewResolver builds a resolver over the given keys.
func NewResolver(keys ...Key) (Resolver, error) {
	resolver := Resolver{}
	for _, key := range keys {
		public, err := kernel.ParsePublicKeyHex(key.PublicHex)
		if err != nil {
			return nil, err
		}
		resolver[key.ID] = public
	}
	return resolver, nil
}

// PublicKey resolves an identifier to its public key.
func (r Resolver) PublicKey(keyID string) (ed25519.PublicKey, bool) {
	public, found := r[keyID]
	return public, found
}
