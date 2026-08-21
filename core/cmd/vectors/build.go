package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/kernel/fixture"
)

// canonicalizationInputs are the inputs, and only the inputs. Every
// expected output below is produced by the kernel, so a case is added by
// naming what it discriminates rather than by hand-computing bytes that
// nobody could check anyway. What a case is FOR is the name.
var canonicalizationInputs = []struct {
	name     string
	input    string
	rejected bool
}{
	{name: "empty object", input: `{}`},
	{name: "empty array", input: `[]`},
	{name: "top level string", input: `"grain"`},
	{name: "top level number", input: `1.0`},
	{name: "top level true", input: `true`},
	{name: "top level null", input: `null`},
	// Rule 2 sorts member names by UTF-16 code unit, so the three cases
	// below fix the order for ASCII, for the supplementary planes, and
	// across a normalization pair that rule 1 keeps distinct.
	{name: "member order in the basic multilingual plane", input: `{"é":1,"a":2,"Z":3,"A":4}`},
	// The discriminating case for rule 2's UTF-16 clause. U+10000 encodes
	// as the surrogate pair D800 DC00, so it sorts BELOW U+FFFD in UTF-16
	// code units and ABOVE it by code point or UTF-8 byte. An
	// implementation that sorted bytes would put these the other way round.
	{name: "member order across the supplementary planes", input: `{"�":1,"𐀀":2}`},
	// Rule 1: no Unicode normalization, so the precomposed and decomposed
	// spellings are two members and not a duplicate.
	{name: "precomposed and decomposed spellings stay distinct members", input: `{"å":1,"å":2}`},
	// Rule 2's number placement, every branch of ECMAScript
	// Number::toString that the contract calls out by name.
	{name: "numbers follow ecmascript placement", input: `{` +
		`"negativeZero":-0,` +
		`"integerFromDecimal":1.0,` +
		`"maxSafeInteger":9007199254740991,` +
		`"exponentThresholdHigh":1e21,` +
		`"belowExponentThresholdHigh":1e20,` +
		`"exponentThresholdLow":1e-7,` +
		`"aboveExponentThresholdLow":1e-6,` +
		`"plainDecimal":0.000001,` +
		`"negativeSmall":-1.5e-9,` +
		`"manyDigits":333333333333333333333,` +
		`"fraction":1.5,` +
		`"hundred":100` +
		`}`},
	// Rule 3.2.2.2 of RFC 8785: the two mandatory escapes, the five short
	// control forms, \u00xx for the rest of C0, and nothing else. The
	// solidus and U+007F are here because a JSON writer that escaped
	// either would still look correct to a casual reader.
	{name: "escapes are only the ones the contract allows", input: `{"s":"\"\\\/\b\f\n\r\t\u0000\u001f\u007f/"}`},
	{name: "nested structures", input: `{"b":[{"d":1,"c":[true,null]},[]],"a":{"z":{},"y":[]}}`},
	{name: "rejected: duplicate member name", input: `{"a":1,"a":2}`, rejected: true},
	{name: "rejected: bytes after the document", input: `{"a":1} {"b":2}`, rejected: true},
	{name: "rejected: truncated document", input: `{"a":`, rejected: true},
	{name: "rejected: not json at all", input: `grain`, rejected: true},
	// Decision 082's rule 1 amendment, cross-language: a document with an
	// unpaired surrogate is refused, never altered and never escaped. The
	// escape is written literally here (a backtick string), so the input is
	// the six characters of a JSON \uXXXX escape, not a Go string that
	// already tried to hold a lone surrogate.
	{name: "rejected: unpaired surrogate escape", input: `{"a":"\ud800"}`, rejected: true},
}

// signInputs are the payloads signed, without a key identifier: the
// identifier is the signer's to supply (decision 019), so a vector that
// carried one would be testing the wrong shape.
var signInputs = []struct {
	name        string
	signerKeyID string
	payload     string
	rejected    bool
}{
	{name: "minimal payload", signerKeyID: fixture.KeyID1, payload: `{"subject":"person-1"}`},
	{
		name:        "payload with nested members and numbers",
		signerKeyID: fixture.KeyID1,
		payload:     `{"subject":"person-1","issued_at":"2026-08-21T00:00:00Z","measures":[1,2.5],"nested":{"b":1,"a":2}}`,
	},
	// The same payload under the other key. The signed bytes differ
	// because the identifier is inside them, which is the property the
	// tampered cases below turn into a failure.
	{name: "minimal payload under the second key", signerKeyID: fixture.KeyID2, payload: `{"subject":"person-1"}`},
	// Signing canonicalizes the raw payload first, so it refuses whatever
	// canonicalization refuses before it embeds a key. A duplicate member
	// and an over-range number are the two a naive JSON.parse would sign
	// over silently: parse keeps the last of the duplicate, and turns the
	// number into Infinity. Both implementations must refuse to sign.
	{name: "rejected: duplicate member name in the payload", signerKeyID: fixture.KeyID1, payload: `{"a":1,"a":2}`, rejected: true},
	{name: "rejected: over-range number in the payload", signerKeyID: fixture.KeyID1, payload: `{"z":1e400}`, rejected: true},
}

func build() (CanonicalizationVectors, SignVerifyVectors, error) {
	canonicalization := CanonicalizationVectors{
		Contract:  "contract/CONTRACT.md rules 1 and 2",
		Generator: "core/cmd/vectors",
	}
	for _, input := range canonicalizationInputs {
		testCase := CanonicalizationCase{Name: input.name, Input: input.input, Rejected: input.rejected}
		canonical, err := kernel.Canonicalize([]byte(input.input))
		switch {
		case input.rejected && err == nil:
			return canonicalization, SignVerifyVectors{}, fmt.Errorf("case %q is marked rejected and was accepted", input.name)
		case input.rejected:
		case err != nil:
			return canonicalization, SignVerifyVectors{}, fmt.Errorf("case %q: %w", input.name, err)
		default:
			testCase.Canonical = string(canonical)
		}
		canonicalization.Cases = append(canonicalization.Cases, testCase)
	}

	falseVerdict, err := json.Marshal(kernel.Invalid())
	if err != nil {
		return canonicalization, SignVerifyVectors{}, err
	}
	// The true verdict is generated from a Verdict deliberately carrying a
	// key identifier and payload, so the pin proves those never reach the
	// wire: the bytes must still be exactly {"valid":true} (decision 082).
	trueVerdict, err := json.Marshal(kernel.Verdict{Valid: true, KeyID: "leak", Payload: json.RawMessage(`"leak"`)})
	if err != nil {
		return canonicalization, SignVerifyVectors{}, err
	}
	signVerify := SignVerifyVectors{
		Contract:        "contract/CONTRACT.md rules 3 and 4",
		Generator:       "core/cmd/vectors",
		ProtectedHeader: kernel.ProtectedHeader,
		KeyIDField:      kernel.KeyIDField,
		FalseVerdict:    string(falseVerdict),
		TrueVerdict:     string(trueVerdict),
	}

	signers := map[string]*fixture.Signer{}
	for _, key := range fixture.Keys() {
		signVerify.Keys = append(signVerify.Keys, VectorKey{ID: key.ID, PrivateHex: key.PrivateHex, PublicHex: key.PublicHex})
		signer, err := fixture.NewSigner(key)
		if err != nil {
			return canonicalization, signVerify, err
		}
		signers[key.ID] = signer
	}

	genuine := map[string]string{}
	for _, input := range signInputs {
		compact, err := kernel.Sign([]byte(input.payload), signers[input.signerKeyID])
		if input.rejected {
			if err == nil {
				return canonicalization, signVerify, fmt.Errorf("case %q is marked rejected and was signed", input.name)
			}
			signVerify.Sign = append(signVerify.Sign, SignCase{
				Name:        input.name,
				SignerKeyID: input.signerKeyID,
				Payload:     input.payload,
				Rejected:    true,
			})
			continue
		}
		if err != nil {
			return canonicalization, signVerify, fmt.Errorf("case %q: %w", input.name, err)
		}
		genuine[input.name] = compact
		signVerify.Sign = append(signVerify.Sign, SignCase{
			Name:          input.name,
			SignerKeyID:   input.signerKeyID,
			Payload:       input.payload,
			SignedPayload: payloadOf(compact),
			Compact:       compact,
		})
	}

	base := genuine["minimal payload"]
	other := genuine["minimal payload under the second key"]
	signVerify.Verify = []VerifyCase{
		{Name: "genuine signature", Compact: base, Valid: true, KeyID: fixture.KeyID1},
		{Name: "genuine signature under the second key", Compact: other, Valid: true, KeyID: fixture.KeyID2},
		{
			Name:    "payload key identifier swapped for the other key",
			Compact: repayload(base, strings.NewReplacer(fixture.KeyID1, fixture.KeyID2).Replace),
			Valid:   false,
		},
		{
			Name:    "payload key identifier names a key nobody holds",
			Compact: repayload(base, strings.NewReplacer(fixture.KeyID1, "fixture-key-absent").Replace),
			Valid:   false,
		},
		{
			Name:    "payload content altered under an untouched key identifier",
			Compact: repayload(base, strings.NewReplacer(`"person-1"`, `"person-2"`).Replace),
			Valid:   false,
		},
		{Name: "signature byte flipped", Compact: flipSignatureByte(base), Valid: false},
		{
			Name:    "protected header carries a key identifier member",
			Compact: reheader(base, `{"alg":"EdDSA","kid":"`+fixture.KeyID1+`"}`),
			Valid:   false,
		},
		{Name: "protected header names another algorithm", Compact: reheader(base, `{"alg":"none"}`), Valid: false},
		{Name: "segment missing", Compact: strings.Join(strings.Split(base, ".")[:2], "."), Valid: false},
		// Decision 082's base64url rule, cross-language: the signature bytes
		// are unchanged, but the segment carries a nonzero slack bit in its
		// final character, so it decodes to the same signature and does not
		// survive a decode/re-encode round trip. A lenient verifier accepts
		// it; a strict one refuses it before the signature is even checked.
		{Name: "non-canonical base64url in the signature segment", Compact: slackSignatureSegment(base), Valid: false},
	}
	return canonicalization, signVerify, nil
}

// slackSignatureSegment re-spells the signature segment with a nonzero
// slack bit so it decodes to identical bytes but is not its own canonical
// base64url form. A 64-byte signature encodes to 86 characters whose last
// character holds two significant bits and four slack bits that the
// canonical spelling leaves zero; setting them changes the character
// without changing the decoded signature.
func slackSignatureSegment(compact string) string {
	parts := strings.Split(compact, ".")
	segment := parts[2]
	const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	last := segment[len(segment)-1]
	idx := strings.IndexByte(alphabet, last)
	// The final character of a 64-byte encoding carries four slack bits;
	// the canonical spelling leaves them zero, so setting them is guaranteed
	// to name a different character that decodes to the same bytes.
	parts[2] = segment[:len(segment)-1] + string(alphabet[idx|0x0f])
	return strings.Join(parts, ".")
}

// repayload rewrites the payload segment and leaves the signature alone,
// which is what a tampering attempt looks like from the wire.
func repayload(compact string, mutate func(string) string) string {
	parts := strings.Split(compact, ".")
	parts[1] = base64.RawURLEncoding.EncodeToString([]byte(mutate(payloadOf(compact))))
	return strings.Join(parts, ".")
}

// reheader replaces the protected header, the case contract rule 3's
// byte-for-byte comparison exists to catch.
func reheader(compact, header string) string {
	parts := strings.Split(compact, ".")
	parts[0] = base64.RawURLEncoding.EncodeToString([]byte(header))
	return strings.Join(parts, ".")
}

func flipSignatureByte(compact string) string {
	parts := strings.Split(compact, ".")
	signature, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return compact
	}
	signature[0] ^= 0x01
	parts[2] = base64.RawURLEncoding.EncodeToString(signature)
	return strings.Join(parts, ".")
}
