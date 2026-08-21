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
	compact, usedKeyID, err := SignEnvelope(bound, signer)
	if err != nil {
		return "", err
	}
	// A rotation between the two provider calls would sign with a key the
	// payload does not name, producing a record that can never verify.
	// Enforced here, and by the fixture signer's rotation test.
	if usedKeyID != keyID {
		return "", fmt.Errorf("%w: reported %q, embedded %q", ErrKeyRotatedMidSign, usedKeyID, keyID)
	}
	return compact, nil
}

// SignEnvelope is contract rule 3's envelope and nothing else: canonicalize
// the payload, sign the compact signing input, return the serialization and
// the key that signed it. It knows nothing about key identifiers, because
// the contract does not; the payload it signs is the payload it is given.
//
// Separate from Sign because decision 019's key-identifier member is this
// repo's policy on top of rule 3, not part of rule 3. The differential
// harness compares the two implementations against the contract, so the
// kernel adapter (core/cmd/kernel-adapter) has to be able to reach rule 3
// without the policy wrapped around it. Sign is that policy, and it is the
// entry point everything in the product uses.
func SignEnvelope(payload []byte, signer Signer) (compact string, keyID string, err error) {
	canonical, err := Canonicalize(payload)
	if err != nil {
		return "", "", err
	}
	signingInput := protectedHeaderB64 + "." + base64.RawURLEncoding.EncodeToString(canonical)
	signature, keyID, err := signer.Sign([]byte(signingInput))
	if err != nil {
		return "", "", err
	}
	return signingInput + "." + base64.RawURLEncoding.EncodeToString(signature), keyID, nil
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
	// `null` unmarshals into a nil map with no error, so the guard above
	// misses it; a nil map is not an object and assigning to it panics.
	// A JSON array unmarshals into a map with an error and is caught above.
	if members == nil {
		return nil, fmt.Errorf("%w: payload is null, not an object", ErrPayloadNotObject)
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

// Verdict is the outcome of verification. It serializes to exactly
// {"valid":true} or {"valid":false} and nothing else, which contract rule 3
// requires of both (decision 082 fixed the true verdict's shape; the false
// one was already fixed and never says why). The `json:"-"` on the other two
// fields is what makes that true: KeyID and Payload are carried for a Go
// caller that verified and now wants them, never onto the wire, where an
// extra member would break the byte-exact verdict. The vector runners
// compare the serialized form, so this is held by the true- and
// false-verdict pins in contract/vectors.
type Verdict struct {
	Valid   bool            `json:"valid"`
	KeyID   string          `json:"-"`
	Payload json.RawMessage `json:"-"`
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
	// ed25519.Verify panics on a wrong-length key, so a resolver that hands
	// back a malformed one must fail the verdict, not the process.
	if len(publicKey) != ed25519.PublicKeySize {
		return Invalid()
	}
	if !ed25519.Verify(publicKey, signingInput, signature) {
		return Invalid()
	}
	return Verdict{Valid: true, KeyID: keyID, Payload: payload}
}

// VerifyEnvelope is contract rule 3's verification and nothing else: the
// header bytes, the segments, and the signature under the key it is given.
// It answers with a bare yes or no, because that is all rule 3 asks.
//
// Separate from Verify for the reason SignEnvelope is separate from Sign:
// binding a record to the key identifier inside its payload is decision
// 019's policy, and the differential harness compares implementations
// against the contract.
func VerifyEnvelope(compact string, publicKey ed25519.PublicKey) bool {
	_, signingInput, signature, ok := splitEnvelope(compact)
	return ok &&
		len(publicKey) == ed25519.PublicKeySize &&
		ed25519.Verify(publicKey, signingInput, signature)
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
	// ed25519.Verify panics on a wrong-length key; a malformed one is a
	// false verdict, never a crash.
	if len(publicKey) != ed25519.PublicKeySize {
		return Invalid()
	}
	if !ed25519.Verify(publicKey, signingInput, signature) {
		return Invalid()
	}
	return Verdict{Valid: true, KeyID: keyID, Payload: payload}
}

// splitEnvelope takes a compact serialization apart under contract rule 3
// and nothing else. The protected header is compared byte-for-byte against
// the frozen bytes and never parsed, so a header carrying an extra member
// is rejected rather than tolerated. The payload is decoded but never
// re-canonicalized, also rule 3: the signature covers the bytes that were
// transmitted, so re-deriving them would verify a different document.
func splitEnvelope(compact string) (payload json.RawMessage, signingInput, signature []byte, ok bool) {
	parts := strings.Split(compact, ".")
	if len(parts) != 3 {
		return nil, nil, nil, false
	}
	header, ok := decodeSegment(parts[0])
	if !ok || !bytes.Equal(header, []byte(ProtectedHeader)) {
		return nil, nil, nil, false
	}
	payload, ok = decodeSegment(parts[1])
	if !ok {
		return nil, nil, nil, false
	}
	signature, ok = decodeSegment(parts[2])
	if !ok || len(signature) != ed25519.SignatureSize {
		return nil, nil, nil, false
	}
	return payload, []byte(parts[0] + "." + parts[1]), signature, true
}

// decodeSegment decodes one base64url segment and requires it to be the
// canonical spelling of the bytes it carries: it must survive a decode and
// re-encode round trip. Go's decoder is lenient about the unused trailing
// bits of a final character, so without this one envelope has several
// spellings, and rule 3's whole posture on the header is that it has one.
//
// Decision 082 ruled this (the reference model's ambiguity A2, base64url):
// a segment that does not survive a decode and re-encode round trip,
// including one with padding or slack final-character bits, does not verify.
// One envelope has one spelling. Covered cross-language by the
// non-canonical-segment verify vector in contract/vectors.
func decodeSegment(segment string) ([]byte, bool) {
	decoded, err := base64.RawURLEncoding.DecodeString(segment)
	if err != nil {
		return nil, false
	}
	if base64.RawURLEncoding.EncodeToString(decoded) != segment {
		return nil, false
	}
	return decoded, true
}

// split is splitEnvelope plus decision 019's key identifier, which every
// caller in the product needs and the contract knows nothing about.
func split(compact string) (payload json.RawMessage, keyID string, signingInput, signature []byte, ok bool) {
	payload, signingInput, signature, ok = splitEnvelope(compact)
	if !ok {
		return nil, "", nil, nil, false
	}
	var members map[string]json.RawMessage
	if err := json.Unmarshal(payload, &members); err != nil {
		return nil, "", nil, nil, false
	}
	if err := json.Unmarshal(members[KeyIDField], &keyID); err != nil || keyID == "" {
		return nil, "", nil, nil, false
	}
	return payload, keyID, signingInput, signature, true
}
