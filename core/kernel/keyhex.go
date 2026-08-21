package kernel

import (
	"crypto/ed25519"
	"encoding/hex"
	"fmt"
)

// Key encodings are contract rule 4: an Ed25519 private key is its 32-byte
// seed in hex and a public key is its 32-byte raw value in hex, RFC 8032
// conventions rather than PEM or JWK. The vectors carry keys in this form,
// so both language runners read the same bytes without a format library
// between them.

// ParsePrivateKeyHex expands a 32-byte hex seed into an Ed25519 private key.
func ParsePrivateKeyHex(seedHex string) (ed25519.PrivateKey, error) {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return nil, fmt.Errorf("kernel: private key is not hex: %w", err)
	}
	if len(seed) != ed25519.SeedSize {
		return nil, fmt.Errorf("kernel: private key seed is %d bytes, want %d", len(seed), ed25519.SeedSize)
	}
	return ed25519.NewKeyFromSeed(seed), nil
}

// ParsePublicKeyHex reads a 32-byte raw hex public key.
func ParsePublicKeyHex(publicHex string) (ed25519.PublicKey, error) {
	raw, err := hex.DecodeString(publicHex)
	if err != nil {
		return nil, fmt.Errorf("kernel: public key is not hex: %w", err)
	}
	if len(raw) != ed25519.PublicKeySize {
		return nil, fmt.Errorf("kernel: public key is %d bytes, want %d", len(raw), ed25519.PublicKeySize)
	}
	return ed25519.PublicKey(raw), nil
}

// PublicKeyHex renders a public key in the contract's form.
func PublicKeyHex(publicKey ed25519.PublicKey) string {
	return hex.EncodeToString(publicKey)
}
