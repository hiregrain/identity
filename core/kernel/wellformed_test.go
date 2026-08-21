package kernel

import (
	"errors"
	"testing"
)

// Rule 1 forbids normalization, and Go's JSON decoder would substitute
// U+FFFD for an unpaired surrogate escape or for an invalid UTF-8 byte,
// which is a normalization: the document would come back altered and
// canonicalization would report success on it. Refused instead.
//
// Found by the differential harness against the reference model, which
// reads ambiguity A3 the other way and preserves the surrogate as an
// escape. Both readings are open. Silently altering the input is wrong
// under either, which is why this refusal does not wait on the ruling.
//
// Every case is written with an escaped backslash rather than a Go rune
// escape, so what the test feeds Canonicalize is the six characters of a
// JSON \uXXXX escape and not a Go string that already tried to hold one.
func TestCanonicalizeRefusesIllFormedUnicode(t *testing.T) {
	cases := []struct {
		name  string
		input string
	}{
		{name: "lone high surrogate", input: "{\"a\":\"\\ud800\"}"},
		{name: "lone low surrogate", input: "{\"a\":\"\\udfff\"}"},
		{name: "surrogates in the wrong order", input: "{\"a\":\"\\udc00\\ud800\"}"},
		{name: "high surrogate followed by an ordinary escape", input: "{\"a\":\"\\ud800\\u0041\"}"},
		{name: "lone surrogate in a member name", input: "{\"\\ud800\":1}"},
		{name: "uppercase spelling of the same escape", input: "\"\\uD800\""},
		{name: "invalid utf-8 byte", input: "{\"a\":\"\xff\"}"},
	}

	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			if _, err := Canonicalize([]byte(testCase.input)); !errors.Is(err, ErrNotWellFormed) {
				t.Fatalf("Canonicalize(%s) err = %v, want ErrNotWellFormed", testCase.input, err)
			}
		})
	}
}

// The refusal is narrow. A correctly paired escape is the supplementary
// plane and must still work, and a literal backslash that only looks like
// the start of an escape is not one.
func TestCanonicalizeAcceptsPairedAndLiteralEscapes(t *testing.T) {
	cases := []struct {
		name  string
		input string
		want  string
	}{
		{
			name:  "surrogate pair is one supplementary code point",
			input: "{\"a\":\"\\ud800\\udc00\"}",
			want:  "{\"a\":\"\U00010000\"}",
		},
		{
			name:  "escaped backslash before a u is not an escape",
			input: "{\"a\":\"\\\\ud800\"}",
			want:  "{\"a\":\"\\\\ud800\"}",
		},
		{
			name:  "two pairs in a row",
			input: "{\"a\":\"\\ud800\\udc00\\ud800\\udc00\"}",
			want:  "{\"a\":\"\U00010000\U00010000\"}",
		},
	}

	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			got, err := Canonicalize([]byte(testCase.input))
			if err != nil {
				t.Fatalf("Canonicalize(%s): %v", testCase.input, err)
			}
			if string(got) != testCase.want {
				t.Fatalf("Canonicalize(%s) = %s, want %s", testCase.input, got, testCase.want)
			}
		})
	}
}
