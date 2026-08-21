package operatorkey

import (
	"crypto/ed25519"

	"github.com/hiregrain/identity/core/kernel"
)

// stubKMSKeyPrefix stands in for the resource-name shape a real KMS key
// identifier carries. It makes the stub's identifiers visibly distinct
// from the software provider's, so a test that swaps providers by
// configuration cannot pass by the two being one implementation in two
// coats. core/keys/stubkms.go carries the same posture for its wrapped
// blobs, and for the same reason.
const stubKMSKeyPrefix = "stub-kms/v1/"

// StubKMS stands in for the production KMS signing provider until the
// cloud ruling lands (decision 011). It mimics the contract the
// conformance suite states over in-memory key material: keys minted and
// named by the provider, a signing call that never names a key, rotation
// the caller cannot see, and every key it has ever held still
// resolvable. The real KMS provider replaces it behind FromConfig after
// passing the same suite in an ephemeral environment, which is the
// provisioning gate.
//
// What the stub does not model, stated so nobody reads its passing as
// more than it is: a remote call, an IAM boundary, and a key whose
// private half never enters this process at all. Those are exactly what
// the ephemeral-environment run at provisioning exists to exercise.
type StubKMS struct {
	ring keyring
}

// NewStubKMS returns a provider holding one freshly generated key,
// already current.
func NewStubKMS() (*StubKMS, error) {
	s := &StubKMS{ring: keyring{identify: stubKMSKeyID}}
	if _, err := s.ring.generate(); err != nil {
		return nil, err
	}
	return s, nil
}

// Name implements Provider.
func (s *StubKMS) Name() string { return nameStubKMS }

// CurrentKeyID implements Provider.
func (s *StubKMS) CurrentKeyID() (string, error) { return s.ring.currentKeyID() }

// Sign implements Provider.
func (s *StubKMS) Sign(signingInput []byte) ([]byte, string, error) {
	return s.ring.sign(signingInput)
}

// PublicKey implements Provider.
func (s *StubKMS) PublicKey(keyID string) (ed25519.PublicKey, bool) {
	return s.ring.publicKey(keyID)
}

// Rotate implements Provider.
func (s *StubKMS) Rotate() (string, error) { return s.ring.generate() }

func stubKMSKeyID(public ed25519.PublicKey) string {
	return stubKMSKeyPrefix + kernel.PublicKeyHex(public)
}
