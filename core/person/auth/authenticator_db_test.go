//go:build db

package auth_test

// A virtual authenticator: the smallest thing that produces the bytes a
// real passkey produces.
//
// This exists because the alternative is asserting that the WebAuthn
// path "works" without ever running a ceremony through it, which is the
// kind of criterion this repo rejects. Everything here is the client
// half, the part a browser and a security key do, so the ledger's half
// is exercised by real attestation and real assertion bytes rather than
// by a stub standing in for the library.
//
// It signs with ES256 over the P-256 curve and attests with the "none"
// format, which is what a platform authenticator on a phone actually
// sends: an attestation statement identifying the device model is the
// exception, not the rule, and a test built on one would exercise a path
// most workers never take.

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/fxamacker/cbor/v2"
	"github.com/go-webauthn/webauthn/protocol"
	"github.com/hiregrain/identity/core/person/auth"
)

// Authenticator data flags, from the specification's §6.1. Set on every
// response this authenticator produces: the user was present, the user
// was verified, and (on registration) attested credential data follows.
const (
	flagUserPresent  = 0x01
	flagUserVerified = 0x04
	flagAttestedData = 0x40
)

type authenticator struct {
	aaguid    []byte
	key       *ecdsa.PrivateKey
	credID    []byte
	signCount uint32
}

func newAuthenticator(t *testing.T) *authenticator {
	t.Helper()
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatalf("authenticator key: %v", err)
	}
	a := &authenticator{
		aaguid: make([]byte, 16),
		key:    key,
		credID: make([]byte, 32),
	}
	if _, err := rand.Read(a.aaguid); err != nil {
		t.Fatalf("aaguid: %v", err)
	}
	if _, err := rand.Read(a.credID); err != nil {
		t.Fatalf("credential id: %v", err)
	}
	return a
}

// register produces the registration response for a challenge, in the
// JSON shape a browser posts, and parses it with the library's own
// parser. Nothing here shortcuts the wire format.
func (a *authenticator) register(t *testing.T, challenge string) *protocol.ParsedCredentialCreationData {
	t.Helper()
	clientData := a.clientData(t, "webauthn.create", challenge)
	authData := a.authData(t, flagUserPresent|flagUserVerified|flagAttestedData, true)
	attestation, err := cbor.Marshal(map[string]any{
		"fmt":      "none",
		"attStmt":  map[string]any{},
		"authData": authData,
	})
	if err != nil {
		t.Fatalf("attestation object: %v", err)
	}
	body, err := json.Marshal(map[string]any{
		"id":                      b64(a.credID),
		"rawId":                   b64(a.credID),
		"type":                    "public-key",
		"authenticatorAttachment": "platform",
		"clientExtensionResults":  map[string]any{},
		"response": map[string]any{
			"clientDataJSON":    b64(clientData),
			"attestationObject": b64(attestation),
			"transports":        []string{"internal"},
		},
	})
	if err != nil {
		t.Fatalf("registration body: %v", err)
	}
	parsed, err := protocol.ParseCredentialCreationResponseBytes(body)
	if err != nil {
		t.Fatalf("the library refused this authenticator's registration response: %v", err)
	}
	return parsed
}

// assert produces the assertion response for a challenge.
func (a *authenticator) assert(t *testing.T, challenge, personID string) *protocol.ParsedCredentialAssertionData {
	t.Helper()
	a.signCount++
	clientData := a.clientData(t, "webauthn.get", challenge)
	authData := a.authData(t, flagUserPresent|flagUserVerified, false)
	clientDataHash := sha256.Sum256(clientData)
	signed := append(append([]byte{}, authData...), clientDataHash[:]...)
	digest := sha256.Sum256(signed)
	signature, err := ecdsa.SignASN1(rand.Reader, a.key, digest[:])
	if err != nil {
		t.Fatalf("assertion signature: %v", err)
	}
	body, err := json.Marshal(map[string]any{
		"id":                     b64(a.credID),
		"rawId":                  b64(a.credID),
		"type":                   "public-key",
		"clientExtensionResults": map[string]any{},
		"response": map[string]any{
			"clientDataJSON":    b64(clientData),
			"authenticatorData": b64(authData),
			"signature":         b64(signature),
			"userHandle":        b64([]byte(personID)),
		},
	})
	if err != nil {
		t.Fatalf("assertion body: %v", err)
	}
	parsed, err := protocol.ParseCredentialRequestResponseBytes(body)
	if err != nil {
		t.Fatalf("the library refused this authenticator's assertion response: %v", err)
	}
	return parsed
}

// clientData is the collected client data a browser hands the
// authenticator. The origin is the ledger's own (decision 084), and a
// wrong one here is what a phishing site would produce.
func (a *authenticator) clientData(t *testing.T, ceremony, challenge string) []byte {
	t.Helper()
	raw, err := json.Marshal(map[string]any{
		"type":        ceremony,
		"challenge":   challenge,
		"origin":      auth.RelyingPartyOrigin,
		"crossOrigin": false,
	})
	if err != nil {
		t.Fatalf("client data: %v", err)
	}
	return raw
}

// authData is the authenticator data structure: the relying party id
// hash, the flags, the signature counter, and on registration the
// attested credential data carrying the public key.
func (a *authenticator) authData(t *testing.T, flags byte, attested bool) []byte {
	t.Helper()
	rpIDHash := sha256.Sum256([]byte(auth.RelyingPartyID))
	data := append([]byte{}, rpIDHash[:]...)
	data = append(data, flags)
	counter := make([]byte, 4)
	binary.BigEndian.PutUint32(counter, a.signCount)
	data = append(data, counter...)
	if !attested {
		return data
	}
	data = append(data, a.aaguid...)
	length := make([]byte, 2)
	binary.BigEndian.PutUint16(length, uint16(len(a.credID)))
	data = append(data, length...)
	data = append(data, a.credID...)
	data = append(data, a.coseKey(t)...)
	return data
}

// coseKey renders the public key in COSE_Key form for ES256 over P-256,
// the encoding the credential public key travels in.
func (a *authenticator) coseKey(t *testing.T) []byte {
	t.Helper()
	x := make([]byte, 32)
	y := make([]byte, 32)
	a.key.PublicKey.X.FillBytes(x)
	a.key.PublicKey.Y.FillBytes(y)
	encoded, err := cbor.Marshal(map[int]any{
		1:  2,  // kty: EC2
		3:  -7, // alg: ES256
		-1: 1,  // crv: P-256
		-2: x,
		-3: y,
	})
	if err != nil {
		t.Fatalf("cose key: %v", err)
	}
	return encoded
}

func b64(raw []byte) string { return base64.RawURLEncoding.EncodeToString(raw) }

// String makes a failed comparison readable without dumping key bytes.
func (a *authenticator) String() string {
	return fmt.Sprintf("authenticator(cred %s)", b64(a.credID)[:8])
}
