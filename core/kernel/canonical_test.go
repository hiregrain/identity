package kernel

import (
	"errors"
	"testing"
)

// Hand-written expectations, so this test says something the generated
// vectors cannot: the vectors record what this code does, and these record
// what the contract says it should do.
func TestCanonicalize(t *testing.T) {
	cases := []struct {
		name  string
		input string
		want  string
	}{
		{name: "empty object", input: `{}`, want: `{}`},
		{name: "members sort, they do not keep input order", input: `{"b":1,"a":2}`, want: `{"a":2,"b":1}`},
		{name: "whitespace is dropped", input: "{ \"a\" : [ 1 , 2 ] }", want: `{"a":[1,2]}`},
		{name: "array order is preserved", input: `[3,1,2]`, want: `[3,1,2]`},
		{
			name:  "member names sort by utf-16 code unit, not by code point",
			input: `{"�":1,"𐀀":2}`,
			want:  "{\"\U00010000\":2,\"�\":1}",
		},
		{
			name:  "no normalization, so the two spellings are two members",
			input: `{"å":1,"å":2}`,
			want:  "{\"å\":2,\"å\":1}",
		},
		{
			name:  "only the escapes the contract allows",
			input: `{"a":"A\/\u007f\u0000\u001f\b\t\n\f\r\"\\"}`,
			want:  "{\"a\":\"A/\\u0000\\u001f\\b\\t\\n\\f\\r\\\"\\\\\"}",
		},
		{name: "nested containers are canonical throughout", input: `{"b":{"d":1,"c":2},"a":[{"f":1,"e":2}]}`, want: `{"a":[{"e":2,"f":1}],"b":{"c":2,"d":1}}`},
		{name: "numbers are reformatted", input: `{"a":1.0,"b":1e21,"c":-0}`, want: `{"a":1,"b":1e+21,"c":0}`},
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

func TestCanonicalizeIsIdempotent(t *testing.T) {
	once, err := Canonicalize([]byte(`{"b":[1.0,{"d":1,"c":"A"}],"a":1e21}`))
	if err != nil {
		t.Fatal(err)
	}
	twice, err := Canonicalize(once)
	if err != nil {
		t.Fatal(err)
	}
	if string(once) != string(twice) {
		t.Fatalf("canonicalizing twice changed the bytes: %s then %s", once, twice)
	}
}

func TestCanonicalizeRejects(t *testing.T) {
	cases := []struct {
		name  string
		input string
		want  error
	}{
		{name: "duplicate member name", input: `{"a":1,"a":2}`, want: ErrDuplicateKey},
		{name: "duplicate after escape decoding", input: `{"a":1,"\u0061":2}`, want: ErrDuplicateKey},
		{name: "bytes after the document", input: `{"a":1} {"b":2}`, want: ErrTrailingBytes},
		{name: "truncated", input: `{"a":`, want: ErrNotJSON},
		{name: "empty input", input: ``, want: ErrNotJSON},
		{name: "not json", input: `grain`, want: ErrNotJSON},
	}

	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			if _, err := Canonicalize([]byte(testCase.input)); !errors.Is(err, testCase.want) {
				t.Fatalf("Canonicalize(%s) err = %v, want %v", testCase.input, err, testCase.want)
			}
		})
	}
}
