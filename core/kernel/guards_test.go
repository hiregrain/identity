package kernel

import (
	"crypto/ed25519"
	"encoding/json"
	"errors"
	"strings"
	"testing"
)

// The guards below are each a crash the frozen kernel must not carry: a
// null payload, a wrong-length key, and unbounded nesting all used to reach
// a panic or a fatal stack overflow. Code review reproduced every one.

// Finding 1: `null` unmarshals into a nil map with no error, so the old
// object guard missed it and the assignment panicked.
func TestSignRefusesNullPayloadWithoutPanicking(t *testing.T) {
	signer := testSigner(t, "key-a")
	_, err := Sign([]byte("null"), signer)
	if !errors.Is(err, ErrPayloadNotObject) {
		t.Fatalf("Sign(null) err = %v, want ErrPayloadNotObject", err)
	}
}

// Finding 2: ed25519.Verify panics on a wrong-length key, so a resolver or
// caller handing back a malformed one must fail the verdict, not the
// process.
func TestVerifyRefusesAWrongLengthKeyWithoutPanicking(t *testing.T) {
	signer := testSigner(t, "key-a")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}

	// A resolver that returns a three-byte key.
	shortResolver := mapResolver{"key-a": ed25519.PublicKey{1, 2, 3}}
	if verdict := Verify(compact, shortResolver); verdict.Valid {
		t.Fatal("Verify accepted a wrong-length key")
	}
	if verdict := VerifyWithKey(compact, ed25519.PublicKey{1, 2, 3}, "key-a"); verdict.Valid {
		t.Fatal("VerifyWithKey accepted a wrong-length key")
	}
	// VerifyEnvelope already had the guard; confirm it still holds.
	if VerifyEnvelope(compact, ed25519.PublicKey{1, 2, 3}) {
		t.Fatal("VerifyEnvelope accepted a wrong-length key")
	}
}

// Finding 3: unbounded nesting overflows the goroutine stack, a fatal error
// recover cannot catch. The limit turns it into an ordinary error. The
// input is built past MaxDepth but far short of a real stack overflow, so
// the test proves the limit fires rather than the stack's own ceiling.
func TestCanonicalizeRefusesNestingPastTheLimit(t *testing.T) {
	tooDeep := strings.Repeat("[", MaxDepth+1) + strings.Repeat("]", MaxDepth+1)
	if _, err := Canonicalize([]byte(tooDeep)); !errors.Is(err, ErrTooDeep) {
		t.Fatalf("Canonicalize past the limit err = %v, want ErrTooDeep", err)
	}

	// One under the limit still canonicalizes.
	atLimit := strings.Repeat("[", MaxDepth) + strings.Repeat("]", MaxDepth)
	if _, err := Canonicalize([]byte(atLimit)); err != nil {
		t.Fatalf("Canonicalize at the limit: %v", err)
	}
}

// Finding 4: the true verdict on the wire is exactly {"valid":true}. The
// key identifier and payload the kernel carries for a Go caller must not
// reach the serialized form (decision 082 rule 3).
func TestVerdictSerializesToExactlyValidAndNothingElse(t *testing.T) {
	loud := Verdict{Valid: true, KeyID: "key-a", Payload: json.RawMessage(`{"subject":"person-1"}`)}
	encoded, err := json.Marshal(loud)
	if err != nil {
		t.Fatal(err)
	}
	if string(encoded) != `{"valid":true}` {
		t.Fatalf("true verdict serialized to %s, want {\"valid\":true}", encoded)
	}
	if encoded, _ := json.Marshal(Invalid()); string(encoded) != `{"valid":false}` {
		t.Fatalf("false verdict serialized to %s", encoded)
	}

	// The fields are still there for a Go caller that verified.
	signer := testSigner(t, "key-a")
	compact, err := Sign([]byte(`{"subject":"person-1"}`), signer)
	if err != nil {
		t.Fatal(err)
	}
	verdict := Verify(compact, testResolver(t, signer))
	if !verdict.Valid || verdict.KeyID != "key-a" || len(verdict.Payload) == 0 {
		t.Fatalf("a Go caller lost the verified fields: %+v", verdict)
	}
}
