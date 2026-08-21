package main

import (
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/kernel"
)

// The differential harness is trust-kernel/06's and is not merged, so
// nothing else in this repo exercises this adapter yet. These tests hold
// the protocol on this side until it is: the shapes are transcribed from
// the document at the top of reference/adapter.ts, and a change here that
// broke the wire format would otherwise be found only by a run nobody in
// this branch can make.

// A seed and its public key, from the vectors' own fixture derivation, so
// the expectations below are not a second set of magic constants.
const seedHex = "0000000000000000000000000000000000000000000000000000000000000001"

func TestCanonicalizePreservesTheRequestBytes(t *testing.T) {
	// Negative zero is the case a re-serializing adapter destroys, and rule
	// 2 names it first. If this adapter ever parsed the request into a Go
	// value and re-encoded it, this is the test that would go red.
	got := decodeOut(t, answer([]byte(`{"op":"canonicalize","value":{"b":1,"a":-0}}`)))
	if got != `{"a":0,"b":1}` {
		t.Fatalf("canonicalize returned %s", got)
	}
}

func TestCanonicalizeReportsRefusalRatherThanRepair(t *testing.T) {
	response := answer([]byte(`{"op":"canonicalize","value":"\ud800"}`))
	if response.OK {
		t.Fatalf("an unpaired surrogate was accepted: %s", response.Out)
	}
}

// The protocol's sign op reaches rule 3's envelope, not decision 019's
// policy on top of it, so the payload it signs is the payload it is given
// and no key identifier is added.
func TestSignAddsNoKeyIdentifier(t *testing.T) {
	compact := decodeOut(t, answer([]byte(`{"op":"sign","payload":{"z":1,"a":2},"seedHex":"`+seedHex+`"}`)))
	segments := strings.Split(compact, ".")
	if len(segments) != 3 {
		t.Fatalf("sign returned %q, which is not a compact serialization", compact)
	}
	payload := decodeSegment(t, segments[1])
	if payload != `{"a":2,"z":1}` {
		t.Fatalf("signed payload is %s, want the canonical payload with nothing added", payload)
	}
	if strings.Contains(payload, kernel.KeyIDField) {
		t.Fatal("the adapter added a key identifier the contract knows nothing about")
	}
}

// Signing then verifying with the matching public key is the round trip
// the harness compares most often, so it is held here directly.
func TestSignedEnvelopeVerifiesUnderItsOwnKey(t *testing.T) {
	publicHex := decodeOut(t, answer([]byte(`{"op":"publicKey","seedHex":"`+seedHex+`"}`)))
	compact := decodeOut(t, answer([]byte(`{"op":"sign","payload":{"a":1},"seedHex":"`+seedHex+`"}`)))

	request, err := json.Marshal(map[string]string{
		"op": "verify", "envelope": compact, "publicKeyHex": publicHex,
	})
	if err != nil {
		t.Fatal(err)
	}
	if got := decodeOut(t, answer(request)); got != `{"valid":true}` {
		t.Fatalf("verify returned %s, want the protocol's true verdict", got)
	}

	// One flipped character in the payload segment, signature untouched.
	segments := strings.Split(compact, ".")
	segments[1] = strings.Replace(segments[1], segments[1][:1], "Z", 1)
	tampered, err := json.Marshal(map[string]string{
		"op": "verify", "envelope": strings.Join(segments, "."), "publicKeyHex": publicHex,
	})
	if err != nil {
		t.Fatal(err)
	}
	if got := decodeOut(t, answer(tampered)); got != `{"valid":false}` {
		t.Fatalf("verify returned %s for a tampered envelope", got)
	}
}

// Rule 4's hex is lowercase. The uppercase spelling of the same bytes is a
// second spelling of one key, and the harness found the Go side accepting
// it while this repo's TypeScript runner did not.
func TestUppercaseKeyHexIsRefused(t *testing.T) {
	// A seed with letters in it, since the all-digit seed above has no
	// uppercase spelling to be refused.
	const mixed = "00000000000000000000000000000000000000000000000000000000000000ab"
	if response := answer([]byte(`{"op":"publicKey","seedHex":"` + mixed + `"}`)); !response.OK {
		t.Fatalf("the lowercase spelling was refused: %s", response.Error)
	}
	if response := answer([]byte(`{"op":"publicKey","seedHex":"` + strings.ToUpper(mixed) + `"}`)); response.OK {
		t.Fatalf("uppercase key hex was accepted: %s", response.Out)
	}
}

func TestUnknownOpAndUnreadableLineAreRejectedNotFatal(t *testing.T) {
	for _, line := range []string{`{"op":"chain"}`, `{"op":`, `[]`} {
		if response := answer([]byte(line)); response.OK {
			t.Fatalf("%s was accepted", line)
		}
	}
}

// Every byte the adapter writes is printable ASCII. Node's readline splits
// a stream on U+2028 and U+2029 as well as on newline, and rule 1's corpus
// carries both, so an unescaped one would desynchronize the whole run.
func TestEveryResponseLineIsPrintableAscii(t *testing.T) {
	lines := []string{
		`{"op":"canonicalize","value":"ok"}`,
		// A supplementary-plane code point, and the two separators
		// Node's readline treats as line breaks.
		"{\"op\":\"canonicalize\",\"value\":{\"\\ud83d\\ude00\":1}}",
		"{\"op\":\"canonicalize\",\"value\":\"\\u2028\\u2029\"}",
		`{"op":"sign","payload":1,"seedHex":"nonsense"}`,
	}
	for _, line := range lines {
		encoded := encodeLine(answer([]byte(line)))
		for i := 0; i < len(encoded); i++ {
			if encoded[i] < 0x20 || encoded[i] >= 0x7f {
				t.Fatalf("response to %s carries byte %#x at %d: %q", line, encoded[i], i, encoded)
			}
		}
		var back response
		if err := json.Unmarshal([]byte(encoded), &back); err != nil {
			t.Fatalf("response to %s is not readable JSON: %v", line, err)
		}
	}
}

func decodeOut(t *testing.T, r response) string {
	t.Helper()
	if !r.OK {
		t.Fatalf("request rejected: %s", r.Error)
	}
	raw, err := hex.DecodeString(r.Out)
	if err != nil {
		t.Fatalf("out is not hex: %v", err)
	}
	return string(raw)
}

func decodeSegment(t *testing.T, segment string) string {
	t.Helper()
	decoded, err := base64.RawURLEncoding.DecodeString(segment)
	if err != nil {
		t.Fatalf("segment %q does not decode: %v", segment, err)
	}
	return string(decoded)
}
