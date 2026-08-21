package kernel

import (
	"crypto/ed25519"
	"encoding/base64"
	"encoding/json"
	"errors"
	"reflect"
	"strings"
	"testing"
)

// The protected header is 15 bytes and those bytes exactly (contract rule
// 3). This is the constant every other claim in this file rests on, so it
// is asserted rather than assumed.
func TestProtectedHeaderIsTheContractBytes(t *testing.T) {
	if ProtectedHeader != `{"alg":"EdDSA"}` {
		t.Fatalf("protected header is %s", ProtectedHeader)
	}
	if len(ProtectedHeader) != 15 {
		t.Fatalf("protected header is %d bytes, the contract freezes 15", len(ProtectedHeader))
	}
}

// Decision 019's structural claim, checked against the type itself: the
// signing path has no parameter a key could be passed through, so signing
// with another party's key is unexpressible rather than rejected at run
// time. The compile-side half of this is the red path in the Makefile,
// which builds a caller that tries to pass one.
func TestSigningPathExposesNoKeyParameter(t *testing.T) {
	keyTypes := map[reflect.Type]string{
		reflect.TypeOf(ed25519.PrivateKey(nil)): "ed25519.PrivateKey",
		reflect.TypeOf(ed25519.PublicKey(nil)):  "ed25519.PublicKey",
	}

	signMethod, found := reflect.TypeOf((*Signer)(nil)).Elem().MethodByName("Sign")
	if !found {
		t.Fatal("Signer has no Sign method")
	}
	assertNoKeyParameter(t, "Signer.Sign", signMethod.Type, keyTypes)
	assertNoKeyParameter(t, "kernel.Sign", reflect.TypeOf(Sign), keyTypes)

	// Verification is the opposite shape on purpose: it names its key.
	verifyWithKey := reflect.TypeOf(VerifyWithKey)
	if verifyWithKey.In(1) != reflect.TypeOf(ed25519.PublicKey(nil)) {
		t.Fatalf("VerifyWithKey does not take a public key as its second parameter")
	}
}

func assertNoKeyParameter(t *testing.T, name string, signature reflect.Type, keyTypes map[reflect.Type]string) {
	t.Helper()
	for i := 0; i < signature.NumIn(); i++ {
		if named, isKey := keyTypes[signature.In(i)]; isKey {
			t.Fatalf("%s takes a %s at parameter %d", name, named, i)
		}
		if signature.In(i).Kind() == reflect.Slice && signature.In(i).Elem().Kind() == reflect.Uint8 && i > 0 {
			t.Fatalf("%s takes a second byte slice at parameter %d, which a key could travel in", name, i)
		}
	}
}

// Contract rule 3's false verdict: exactly one member, and that member is
// valid.
func TestFalseVerdictCarriesNothingElse(t *testing.T) {
	encoded, err := json.Marshal(Invalid())
	if err != nil {
		t.Fatal(err)
	}
	if string(encoded) != `{"valid":false}` {
		t.Fatalf("false verdict serializes to %s", encoded)
	}
}

func TestSignPlacesTheKeyIdentifierInsideTheSignedBytes(t *testing.T) {
	signer := testSigner(t, "key-a")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}

	payload := decodePayload(t, compact)
	if !strings.Contains(payload, `"`+KeyIDField+`":"key-a"`) {
		t.Fatalf("signed payload does not name the key: %s", payload)
	}
	// The payload is canonical, so the identifier lands in sorted position
	// rather than appended.
	if payload != `{"kid":"key-a","subject":"person-1"}` {
		t.Fatalf("signed payload is %s", payload)
	}

	resolver := testResolver(t, signer)
	if verdict := Verify(compact, resolver); !verdict.Valid || verdict.KeyID != "key-a" {
		t.Fatalf("genuine signature did not verify: %+v", verdict)
	}
}

func TestAlteringTheKeyIdentifierBreaksTheSignature(t *testing.T) {
	signer := testSigner(t, "key-a")
	other := testSigner(t, "key-b")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}

	parts := strings.Split(compact, ".")
	altered := strings.Replace(decodePayload(t, compact), "key-a", "key-b", 1)
	parts[1] = base64.RawURLEncoding.EncodeToString([]byte(altered))
	tampered := strings.Join(parts, ".")

	resolver := testResolver(t, signer, other)
	if verdict := Verify(tampered, resolver); verdict.Valid {
		t.Fatal("a record whose key identifier was rewritten still verified")
	}
}

// The header is compared and never parsed, so a header that a JSON reader
// would call equivalent is still refused.
func TestVerifyRefusesAnyOtherHeaderBytes(t *testing.T) {
	signer := testSigner(t, "key-a")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}
	resolver := testResolver(t, signer)

	for _, header := range []string{
		`{"alg": "EdDSA"}`,
		`{"alg":"EdDSA","kid":"key-a"}`,
		`{"typ":"JWT","alg":"EdDSA"}`,
	} {
		parts := strings.Split(compact, ".")
		parts[0] = base64.RawURLEncoding.EncodeToString([]byte(header))
		if verdict := Verify(strings.Join(parts, "."), resolver); verdict.Valid {
			t.Fatalf("header %s was accepted", header)
		}
	}
}

func TestVerifyWithKeyRefusesAKeyThePayloadDoesNotName(t *testing.T) {
	signer := testSigner(t, "key-a")
	other := testSigner(t, "key-b")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}

	if verdict := VerifyWithKey(compact, signer.public, "key-a"); !verdict.Valid {
		t.Fatal("the genuine key did not verify")
	}
	if verdict := VerifyWithKey(compact, other.public, "key-b"); verdict.Valid {
		t.Fatal("a record verified against a key its payload does not name")
	}
}

func TestSignRefusesAPayloadThatChoosesItsOwnKey(t *testing.T) {
	signer := testSigner(t, "key-a")
	_, err := Sign([]byte(`{"kid":"key-b","subject":"person-1"}`), signer)
	if !errors.Is(err, ErrKeyIDPresent) {
		t.Fatalf("payload naming its own key was accepted, err = %v", err)
	}
}

func TestSignRefusesANonObjectPayload(t *testing.T) {
	signer := testSigner(t, "key-a")
	for _, payload := range []string{`[1,2]`, `"grain"`, `{"a":1,"a":2}`} {
		if _, err := Sign([]byte(payload), signer); err == nil {
			t.Fatalf("payload %s was accepted", payload)
		}
	}
}

// A rotation between the two provider calls would sign with a key the
// payload does not name. The kernel refuses rather than emitting a record
// that can never verify.
func TestSignRefusesAKeyRotationMidSignature(t *testing.T) {
	signer := testSigner(t, "key-a")
	signer.rotateTo = "key-b"
	if _, err := Sign([]byte(`{"subject":"person-1"}`), signer); !errors.Is(err, ErrKeyRotatedMidSign) {
		t.Fatalf("a mid-signature rotation was not caught, err = %v", err)
	}
}

func TestVerifyRefusesMalformedSerializations(t *testing.T) {
	signer := testSigner(t, "key-a")
	resolver := testResolver(t, signer)
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}
	parts := strings.Split(compact, ".")

	for _, name := range []string{
		"",
		"a.b",
		compact + ".extra",
		parts[0] + "." + parts[1] + ".",
		parts[0] + ".!!!." + parts[2],
	} {
		if verdict := Verify(name, resolver); verdict.Valid {
			t.Fatalf("malformed serialization %q verified", name)
		}
	}
}

// A signer over one generated key, with a hook for the rotation case. The
// fixture package's signer is deliberately not used here: these tests are
// about the kernel's own behaviour, not about the vectors.
type keyedSigner struct {
	keyID    string
	rotateTo string
	private  ed25519.PrivateKey
	public   ed25519.PublicKey
}

func (s *keyedSigner) CurrentKeyID() (string, error) { return s.keyID, nil }

func (s *keyedSigner) Sign(signingInput []byte) ([]byte, string, error) {
	keyID := s.keyID
	if s.rotateTo != "" {
		keyID = s.rotateTo
	}
	return ed25519.Sign(s.private, signingInput), keyID, nil
}

func testSigner(t *testing.T, keyID string) *keyedSigner {
	t.Helper()
	public, private, err := ed25519.GenerateKey(nil)
	if err != nil {
		t.Fatal(err)
	}
	return &keyedSigner{keyID: keyID, private: private, public: public}
}

type mapResolver map[string]ed25519.PublicKey

func (r mapResolver) PublicKey(keyID string) (ed25519.PublicKey, bool) {
	public, found := r[keyID]
	return public, found
}

func testResolver(t *testing.T, signers ...*keyedSigner) mapResolver {
	t.Helper()
	resolver := mapResolver{}
	for _, signer := range signers {
		resolver[signer.keyID] = signer.public
	}
	return resolver
}

func decodePayload(t *testing.T, compact string) string {
	t.Helper()
	decoded, err := base64.RawURLEncoding.DecodeString(strings.Split(compact, ".")[1])
	if err != nil {
		t.Fatal(err)
	}
	return string(decoded)
}
