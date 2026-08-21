// Command kernel-adapter joins the kernel to the differential harness
// (trust-kernel/01 scope, founder ruling; harness from trust-kernel/06).
//
//	make differential KERNEL_ADAPTER='cd core && go run ./cmd/kernel-adapter'
//
// The protocol is documented at the top of reference/adapter.ts and this
// program is written to that document, not to the reference model's Go
// equivalent, of which there is none. Line-delimited JSON: one request
// object per line on stdin, one response object per line on stdout, in
// order, one response per request.
//
//	{"op":"canonicalize","value":<any JSON value>}
//	{"op":"sign","payload":<any JSON value>,"seedHex":"<64 hex>"}
//	{"op":"verify","envelope":"<compact JWS>","publicKeyHex":"<64 hex>"}
//	{"op":"publicKey","seedHex":"<64 hex>"}
//	-> {"ok":true,"out":"<lowercase hex>"} | {"ok":false,"error":"<free text>"}
//
// Three things this program does that are worth knowing before reading it.
//
// The payload is never re-serialized. `value` and `payload` are held as
// raw bytes from the request line and handed to the kernel as they arrived.
// Parsing them into Go values and re-encoding would destroy negative zero
// and every other number spelling, which is the first thing contract rule
// 2 names, and the harness would then report agreement on rule 2 forever.
// The reference model hit the same trap from the other side; see encodeJson
// in reference/adapter.ts.
//
// It reaches the kernel's contract-level primitives, SignEnvelope and
// VerifyEnvelope, not Sign and Verify. Decision 019's key identifier is
// this repo's policy on top of rule 3 and the contract knows nothing about
// it, so signing through Sign would add a member the reference never adds
// and every sign request would diverge on something that is not a contract
// disagreement.
//
// The verdict it reports is `{"valid":true}` or `{"valid":false}`, which
// is the protocol's shape and the reference's reading of ambiguity A1.
// The kernel's own Verdict carries the key identifier and the payload on
// the true path. That difference is A1, which nobody has ruled on, and it
// is raised on the task rather than settled here. What the adapter must
// never do is disagree about the verdict itself, and it does not: a
// kernel that said valid where the reference says invalid still diverges.
//
// Output is pure ASCII with every other code point escaped, because the
// harness reads with Node's readline, which splits on U+2028 and U+2029 as
// well as on newline, and rule 1's terrain carries both.
package main

import (
	"bufio"
	"crypto/ed25519"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"unicode/utf16"

	"github.com/hiregrain/identity/core/kernel"
)

type request struct {
	Op           string          `json:"op"`
	Value        json.RawMessage `json:"value"`
	Payload      json.RawMessage `json:"payload"`
	Envelope     string          `json:"envelope"`
	PublicKeyHex string          `json:"publicKeyHex"`
	SeedHex      string          `json:"seedHex"`
}

type response struct {
	OK    bool   `json:"ok"`
	Out   string `json:"out,omitempty"`
	Error string `json:"error,omitempty"`
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	// The harness sends whole JSON documents on one line, and rule 1's
	// corpus makes some of them long. The default 64KB limit would split
	// one into two requests and desynchronize the whole run.
	in.Buffer(make([]byte, 0, 1<<20), 1<<24)
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()

	for in.Scan() {
		line := strings.TrimSpace(in.Text())
		if line == "" {
			continue
		}
		fmt.Fprintln(out, encodeLine(answer([]byte(line))))
		// Flushed per line so the harness, which writes every request
		// before draining, cannot deadlock against a full pipe buffer.
		if err := out.Flush(); err != nil {
			fmt.Fprintf(os.Stderr, "kernel-adapter: %v\n", err)
			os.Exit(1)
		}
	}
	if err := in.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "kernel-adapter: %v\n", err)
		os.Exit(1)
	}
}

// answer converts a request line into a response, and a panic into a
// failure response rather than a crash. The harness feeds every request
// before draining, so one adapter process dying mid-stream desynchronizes
// the entire run; a catchable panic must not do that. A stack overflow is
// fatal and recover cannot catch it, which is why the kernel bounds nesting
// with MaxDepth rather than relying on this: the deep-input case returns an
// ordinary error and never reaches a panic here.
func answer(line []byte) (result response) {
	defer func() {
		if r := recover(); r != nil {
			result = failure(fmt.Errorf("panic: %v", r))
		}
	}()

	var req request
	if err := json.Unmarshal(line, &req); err != nil {
		return failure(fmt.Errorf("unreadable request: %w", err))
	}

	switch req.Op {
	case "canonicalize":
		canonical, err := kernel.Canonicalize(req.Value)
		if err != nil {
			return failure(err)
		}
		return success(canonical)

	case "sign":
		signer, err := newSeedSigner(req.SeedHex)
		if err != nil {
			return failure(err)
		}
		compact, _, err := kernel.SignEnvelope(req.Payload, signer)
		if err != nil {
			return failure(err)
		}
		return success([]byte(compact))

	case "verify":
		// A key that will not parse is not a verdict of invalid on
		// somebody's signature, it is a request this adapter cannot
		// answer. The reference reports the same case as a false verdict
		// because its own key loader throws inside verifyEnvelope, so
		// this returns a verdict too rather than an error.
		publicKey, err := kernel.ParsePublicKeyHex(req.PublicKeyHex)
		if err != nil {
			return verdict(false)
		}
		return verdict(kernel.VerifyEnvelope(req.Envelope, publicKey))

	case "publicKey":
		signer, err := newSeedSigner(req.SeedHex)
		if err != nil {
			return failure(err)
		}
		return success([]byte(kernel.PublicKeyHex(signer.public)))

	default:
		return failure(fmt.Errorf("unknown op %q", req.Op))
	}
}

// verdict answers with the protocol's verdict shape, canonicalized by the
// kernel so the bytes the harness compares are the kernel's own output and
// not this program's spelling of them.
func verdict(valid bool) response {
	document := `{"valid":false}`
	if valid {
		document = `{"valid":true}`
	}
	canonical, err := kernel.Canonicalize([]byte(document))
	if err != nil {
		return failure(err)
	}
	return success(canonical)
}

func success(out []byte) response {
	return response{OK: true, Out: hex.EncodeToString(out)}
}

func failure(err error) response {
	return response{OK: false, Error: err.Error()}
}

// seedSigner is a kernel.Signer over one seed from the wire. Signing with
// a caller-supplied key through a Signer implementation is the provider
// seam decision 019 describes, not a way around it: the kernel still has
// no key parameter, and this adapter is a test harness rather than a
// product path.
type seedSigner struct {
	private ed25519.PrivateKey
	public  ed25519.PublicKey
}

func newSeedSigner(seedHex string) (*seedSigner, error) {
	private, err := kernel.ParsePrivateKeyHex(seedHex)
	if err != nil {
		return nil, err
	}
	return &seedSigner{private: private, public: private.Public().(ed25519.PublicKey)}, nil
}

// CurrentKeyID is unused on this path: the protocol has no key identifier,
// because the contract has none.
func (s *seedSigner) CurrentKeyID() (string, error) { return "", nil }

func (s *seedSigner) Sign(signingInput []byte) ([]byte, string, error) {
	return ed25519.Sign(s.private, signingInput), "", nil
}

// encodeLine writes the response as JSON with every non-ASCII and every
// control code point escaped, which the protocol requires in both
// directions.
func encodeLine(value any) string {
	encoded, err := json.Marshal(value)
	if err != nil {
		return `{"ok":false,"error":"unencodable response"}`
	}
	var line strings.Builder
	for _, r := range string(encoded) {
		if r >= 0x20 && r < 0x7f {
			line.WriteRune(r)
			continue
		}
		// The protocol's \uXXXX escapes are UTF-16 code units, so a
		// supplementary-plane rune becomes its surrogate pair rather than a
		// five-digit escape no JSON reader accepts. utf16.EncodeRune returns
		// one BMP rune as (U+FFFD, U+FFFD), so a BMP code point is written
		// directly and only a supplementary one is split.
		if r <= 0xffff {
			fmt.Fprintf(&line, `\u%04x`, uint16(r))
			continue
		}
		high, low := utf16.EncodeRune(r)
		fmt.Fprintf(&line, `\u%04x\u%04x`, uint16(high), uint16(low))
	}
	return line.String()
}
