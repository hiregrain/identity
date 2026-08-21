package kernel

import (
	"bytes"
	"crypto/ed25519"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
)

// ProtectedHeader is the whole protected header, frozen by contract rule 3.
// Verification compares these bytes and does not parse them, which is why
// there is nowhere in the header for a key identifier (decision 019).
const ProtectedHeader = `{"alg":"EdDSA"}`

// KeyIDField names the key identifier inside the signed payload. Decision
// 019 put it there; the field name follows the repo's existing term for it
// (model/attestation-interface.md and the design tree call an attestation
// kid-bound) and is a single constant so the pending interface amendment
// decision 019 flagged is a one-line change here.
const KeyIDField = "kid"

// protectedHeaderB64 is the first segment of every compact serialization
// this kernel produces or accepts.
var protectedHeaderB64 = base64.RawURLEncoding.EncodeToString([]byte(ProtectedHeader))

// Errors the signing path reports.
var (
	ErrPayloadNotObject  = errors.New("kernel: payload is not a JSON object")
	ErrKeyIDPresent      = errors.New("kernel: payload already carries a key identifier")
	ErrKeyRotatedMidSign = errors.New("kernel: signer used a key other than the one it reported")
)

// Signer is the operator key provider's signing seam. trust-kernel/02
// supplies the real implementation (software locally and in CI, KMS in
// production); core/kernel/fixture supplies the deterministic one the
// golden vectors are generated with.
//
// Sign takes no key parameter, which is decision 019: key selection and
// rotation live inside the provider, so signing with another party's key
// is unexpressible rather than rejected by a runtime check somebody can
// later regress.
type Signer interface {
	// CurrentKeyID reports the key Sign would use now. Sign cannot report
	// it first, because the identifier has to be inside the payload before
	// the payload is signed.
	CurrentKeyID() (string, error)

	// Sign signs signingInput with the provider's current active key and
	// reports which key that was.
	Sign(signingInput []byte) (signature []byte, keyID string, err error)
}

// Sign places the signer's current key identifier inside the payload,
// canonicalizes the result, and returns the JWS compact serialization.
//
// The identifier goes in before the signature is computed, so altering it
// afterwards changes the signed bytes and the signature no longer verifies.
// That is the whole point of decision 019, and contract/vectors' tampered
// cases are what hold it.
func Sign(payload []byte, signer Signer) (string, error) {
	keyID, err := signer.CurrentKeyID()
	if err != nil {
		return "", err
	}

	bound, err := withKeyID(payload, keyID)
	if err != nil {
		return "", err
	}
	canonical, err := Canonicalize(bound)
	if err != nil {
		return "", err
	}

	signingInput := protectedHeaderB64 + "." + base64.RawURLEncoding.EncodeToString(canonical)
	signature, usedKeyID, err := signer.Sign([]byte(signingInput))
	if err != nil {
		return "", err
	}
	// A rotation between the two provider calls would sign with a key the
	// payload does not name, producing a record that can never verify.
	// Enforced here, and by the fixture signer's rotation test.
	if usedKeyID != keyID {
		return "", fmt.Errorf("%w: reported %q, embedded %q", ErrKeyRotatedMidSign, usedKeyID, keyID)
	}

	return signingInput + "." + base64.RawURLEncoding.EncodeToString(signature), nil
}

// withKeyID returns the payload with the key identifier added as a
// top-level member. A payload that already carries one is refused rather
// than overwritten: it is either a re-signing attempt or a caller trying to
// choose a key through the payload, and neither is a thing this kernel does.
func withKeyID(payload []byte, keyID string) ([]byte, error) {
	// Canonicalize first, so a duplicate member or a malformed document is
	// refused here rather than silently collapsed by the map below.
	if _, err := Canonicalize(payload); err != nil {
		return nil, err
	}
	var members map[string]json.RawMessage
	if err := json.Unmarshal(payload, &members); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrPayloadNotObject, err)
	}
	if _, present := members[KeyIDField]; present {
		return nil, ErrKeyIDPresent
	}
	encoded, err := json.Marshal(keyID)
	if err != nil {
		return nil, err
	}
	members[KeyIDField] = encoded
	// Marshalling a map reorders members; Canonicalize is what fixes order,
	// so this intermediate form only has to be valid JSON.
	return json.Marshal(members)
}

// Verdict is the outcome of verification. A false verdict serializes to
// exactly {"valid":false} with no other member, which is contract rule 3;
// the omitempty tags are what make that true, and the vector runners
// compare the serialized form rather than the struct.
type Verdict struct {
	Valid   bool            `json:"valid"`
	KeyID   string          `json:"kid,omitempty"`
	Payload json.RawMessage `json:"payload,omitempty"`
}

// Invalid is the single false verdict.
func Invalid() Verdict { return Verdict{Valid: false} }

// Resolver maps a key identifier to the public key it names. party-registry
// supplies the real one, reading the registry; core/kernel/fixture supplies
// the one the vectors use.
type Resolver interface {
	PublicKey(keyID string) (ed25519.PublicKey, bool)
}

// Verify reads the key identifier out of the signed payload, resolves it,
// and verifies the signature. Reading the identifier from inside the signed
// bytes is what makes it unforgeable: a record cannot claim a key it was
// not signed with.
func Verify(compact string, resolver Resolver) Verdict {
	payload, keyID, signingInput, signature, ok := split(compact)
	if !ok {
		return Invalid()
	}
	publicKey, found := resolver.PublicKey(keyID)
	if !found {
		return Invalid()
	}
	if !ed25519.Verify(publicKey, signingInput, signature) {
		return Invalid()
	}
	return Verdict{Valid: true, KeyID: keyID, Payload: payload}
}

// VerifyWithKey verifies against one public key given directly, the shape
// decision 019 keeps separate from signing: verification names its key,
// signing never does. The payload's key identifier still has to match the
// key offered, or a record signed by one party could be presented as
// another's.
func VerifyWithKey(compact string, publicKey ed25519.PublicKey, keyID string) Verdict {
	payload, embeddedKeyID, signingInput, signature, ok := split(compact)
	if !ok || embeddedKeyID != keyID {
		return Invalid()
	}
	if !ed25519.Verify(publicKey, signingInput, signature) {
		return Invalid()
	}
	return Verdict{Valid: true, KeyID: keyID, Payload: payload}
}

// split takes a compact serialization apart and enforces contract rule 3's
// header check: the protected header is compared byte-for-byte against the
// frozen bytes and never parsed, so a header carrying an extra member is
// rejected rather than tolerated. The payload is decoded and read but never
// re-canonicalized, also rule 3: the signature covers the bytes that were
// transmitted, so re-deriving them would verify a different document.
func split(compact string) (payload json.RawMessage, keyID string, signingInput, signature []byte, ok bool) {
	parts := strings.Split(compact, ".")
	if len(parts) != 3 {
		return nil, "", nil, nil, false
	}
	header, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil || !bytes.Equal(header, []byte(ProtectedHeader)) {
		return nil, "", nil, nil, false
	}
	payloadBytes, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return nil, "", nil, nil, false
	}
	signature, err = base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil || len(signature) != ed25519.SignatureSize {
		return nil, "", nil, nil, false
	}

	var members map[string]json.RawMessage
	if err := json.Unmarshal(payloadBytes, &members); err != nil {
		return nil, "", nil, nil, false
	}
	if err := json.Unmarshal(members[KeyIDField], &keyID); err != nil || keyID == "" {
		return nil, "", nil, nil, false
	}
	return payloadBytes, keyID, []byte(parts[0] + "." + parts[1]), signature, true
}
