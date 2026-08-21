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
//
// Hex here means lowercase hex. Rule 4 does not say so, and admitting
// uppercase would give one key two spellings, which is the thing rule 3
// refuses for the header and rule 1 refuses for a string. Both the
// TypeScript runner and the reference model read it the same way; the Go
// side accepting uppercase was a disagreement between this repo's own two
// implementations, found by the differential harness.

// ParsePrivateKeyHex expands a 32-byte lowercase hex seed into an Ed25519
// private key.
func ParsePrivateKeyHex(seedHex string) (ed25519.PrivateKey, error) {
	seed, err := decodeKeyHex(seedHex, ed25519.SeedSize, "private key seed")
	if err != nil {
		return nil, err
	}
	return ed25519.NewKeyFromSeed(seed), nil
}

// ParsePublicKeyHex reads a 32-byte raw lowercase hex public key.
func ParsePublicKeyHex(publicHex string) (ed25519.PublicKey, error) {
	raw, err := decodeKeyHex(publicHex, ed25519.PublicKeySize, "public key")
	if err != nil {
		return nil, err
	}
	return ed25519.PublicKey(raw), nil
}

func decodeKeyHex(value string, size int, what string) ([]byte, error) {
	for i := 0; i < len(value); i++ {
		c := value[i]
		if !(c >= '0' && c <= '9') && !(c >= 'a' && c <= 'f') {
			return nil, fmt.Errorf("kernel: %s is not lowercase hex", what)
		}
	}
	raw, err := hex.DecodeString(value)
	if err != nil {
		return nil, fmt.Errorf("kernel: %s is not hex: %w", what, err)
	}
	if len(raw) != size {
		return nil, fmt.Errorf("kernel: %s is %d bytes, want %d", what, len(raw), size)
	}
	return raw, nil
}

// PublicKeyHex renders a public key in the contract's form.
func PublicKeyHex(publicKey ed25519.PublicKey) string {
	return hex.EncodeToString(publicKey)
}
