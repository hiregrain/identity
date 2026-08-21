package kernel

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"slices"
	"strings"
	"unicode/utf16"
	"unicode/utf8"
)

// Errors Canonicalize reports. Each names the contract rule it enforces so
// a failure reads as a rule violation rather than a parser complaint.
var (
	ErrNotJSON       = errors.New("kernel: input is not one JSON document")
	ErrDuplicateKey  = errors.New("kernel: object has a duplicate member name")
	ErrTrailingBytes = errors.New("kernel: input carries bytes after the JSON document")
	ErrNotWellFormed = errors.New("kernel: input is not well-formed Unicode")
	ErrTooDeep       = errors.New("kernel: JSON nesting exceeds the depth limit")
)

// MaxDepth bounds JSON nesting. parseFrom recurses once per open bracket,
// so a document of a few million open brackets would exhaust the goroutine
// stack, and a stack overflow in Go is a fatal runtime error that recover()
// cannot catch: it kills the process, which for the streaming
// kernel-adapter means a crash mid-differential-run rather than one bad
// answer. The limit converts that into a normal error.
//
// 256 is far above any real record. A grain attestation is a flat object of
// a dozen members with at most a small array of measures; nothing the
// product writes nests past single digits. The bound exists for hostile
// input, not for depth the product would ever reach, so it is set where no
// legitimate document is near it and a malicious one stops well short of
// the stack.
const MaxDepth = 256

// checkWellFormed refuses the two inputs Go's JSON decoder would repair
// into something else: invalid UTF-8 bytes, and an unpaired surrogate
// escape. Both would come back as U+FFFD, which is a normalization rule 1
// forbids. A correctly paired escape is untouched, which is what keeps the
// supplementary-plane member-ordering case working.
func checkWellFormed(document []byte) error {
	if !utf8.Valid(document) {
		return fmt.Errorf("%w: not valid UTF-8", ErrNotWellFormed)
	}
	for i := 0; i+5 < len(document)+1; i++ {
		high, ok := surrogateEscapeAt(document, i)
		if !ok {
			continue
		}
		if high >= 0xdc00 {
			return fmt.Errorf("%w: unpaired low surrogate escape at byte %d", ErrNotWellFormed, i)
		}
		low, ok := surrogateEscapeAt(document, i+6)
		if !ok || low < 0xdc00 {
			return fmt.Errorf("%w: unpaired high surrogate escape at byte %d", ErrNotWellFormed, i)
		}
		i += 11 // The whole pair is accounted for; resume past it.
	}
	return nil
}

// surrogateEscapeAt reports the code unit of a \uXXXX escape at offset i
// when that escape names a surrogate, and whether it found one. A preceding
// backslash would make the sequence a literal rather than an escape, so an
// odd run of backslashes before it disqualifies the match.
func surrogateEscapeAt(document []byte, i int) (uint32, bool) {
	if i+6 > len(document) || document[i] != '\\' || document[i+1] != 'u' {
		return 0, false
	}
	backslashes := 0
	for j := i - 1; j >= 0 && document[j] == '\\'; j-- {
		backslashes++
	}
	if backslashes%2 == 1 {
		return 0, false
	}
	var unit uint32
	for _, c := range document[i+2 : i+6] {
		digit := strings.IndexByte("0123456789abcdef", lowerHex(c))
		if digit < 0 {
			return 0, false
		}
		unit = unit<<4 | uint32(digit)
	}
	if unit < 0xd800 || unit > 0xdfff {
		return 0, false
	}
	return unit, true
}

func lowerHex(c byte) byte {
	if c >= 'A' && c <= 'F' {
		return c + ('a' - 'A')
	}
	return c
}

// Canonicalize returns the RFC 8785 (JCS) canonical form of one JSON
// document, which is contract rules 1 and 2: no Unicode normalization, so
// NFC and NFD stay distinct strings and distinct keys; ECMAScript number
// formatting; member names sorted by UTF-16 code unit.
//
// The input is JSON text rather than a Go value because the canonical form
// is a property of the document, and routing it through a Go map would lose
// duplicate members and reorder nothing reproducibly.
//
// A document carrying an unpaired surrogate, or a byte sequence that is not
// valid UTF-8, is REFUSED rather than repaired. Decision 082 ruled rule 1's
// silence this way: input containing an unpaired surrogate is refused, never
// altered and never escaped. Go's JSON decoder would substitute U+FFFD for
// either, and substitution is a normalization, which rule 1 forbids, so
// canonicalization would otherwise report success on a document it had
// altered. Enforced by checkWellFormed below, and covered cross-language by
// the rejected surrogate vector in contract/vectors.
func Canonicalize(document []byte) ([]byte, error) {
	if err := checkWellFormed(document); err != nil {
		return nil, err
	}
	decoder := json.NewDecoder(bytes.NewReader(document))
	decoder.UseNumber()

	value, err := parseValue(decoder, 0)
	if err != nil {
		return nil, err
	}
	if _, err := decoder.Token(); !errors.Is(err, io.EOF) {
		return nil, ErrTrailingBytes
	}

	var out strings.Builder
	if err := writeValue(&out, value); err != nil {
		return nil, err
	}
	return []byte(out.String()), nil
}

// member is one object entry, kept in a slice rather than a map so the
// sort below is the only thing that decides order.
type member struct {
	name  string
	value any
}

func parseValue(decoder *json.Decoder, depth int) (any, error) {
	token, err := decoder.Token()
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrNotJSON, err)
	}
	return parseFrom(decoder, token, depth)
}

// parseFrom recurses once per open bracket. depth is checked before
// descending, so a document deeper than MaxDepth returns ErrTooDeep rather
// than overflowing the stack (a fatal error recover() cannot catch).
func parseFrom(decoder *json.Decoder, token json.Token, depth int) (any, error) {
	delim, isDelim := token.(json.Delim)
	if !isDelim {
		return token, nil
	}
	if depth >= MaxDepth {
		return nil, fmt.Errorf("%w: deeper than %d", ErrTooDeep, MaxDepth)
	}

	switch delim {
	case '{':
		members := []member{}
		seen := map[string]bool{}
		for {
			key, err := decoder.Token()
			if err != nil {
				return nil, fmt.Errorf("%w: %v", ErrNotJSON, err)
			}
			if closing, ok := key.(json.Delim); ok && closing == '}' {
				return members, nil
			}
			name, ok := key.(string)
			if !ok {
				return nil, ErrNotJSON
			}
			if seen[name] {
				return nil, fmt.Errorf("%w: %q", ErrDuplicateKey, name)
			}
			seen[name] = true
			value, err := parseValue(decoder, depth+1)
			if err != nil {
				return nil, err
			}
			members = append(members, member{name: name, value: value})
		}
	case '[':
		elements := []any{}
		for {
			token, err := decoder.Token()
			if err != nil {
				return nil, fmt.Errorf("%w: %v", ErrNotJSON, err)
			}
			if closing, ok := token.(json.Delim); ok && closing == ']' {
				return elements, nil
			}
			element, err := parseFrom(decoder, token, depth+1)
			if err != nil {
				return nil, err
			}
			elements = append(elements, element)
		}
	default:
		return nil, ErrNotJSON
	}
}

func writeValue(out *strings.Builder, value any) error {
	switch typed := value.(type) {
	case nil:
		out.WriteString("null")
	case bool:
		if typed {
			out.WriteString("true")
		} else {
			out.WriteString("false")
		}
	case string:
		writeString(out, typed)
	case json.Number:
		asFloat, err := typed.Float64()
		if err != nil {
			return fmt.Errorf("kernel: number %s is not an IEEE 754 double: %w", typed, err)
		}
		formatted, err := formatNumber(asFloat)
		if err != nil {
			return err
		}
		out.WriteString(formatted)
	case []any:
		out.WriteByte('[')
		for i, element := range typed {
			if i > 0 {
				out.WriteByte(',')
			}
			if err := writeValue(out, element); err != nil {
				return err
			}
		}
		out.WriteByte(']')
	case []member:
		sorted := make([]member, len(typed))
		copy(sorted, typed)
		sortMembers(sorted)
		out.WriteByte('{')
		for i, entry := range sorted {
			if i > 0 {
				out.WriteByte(',')
			}
			writeString(out, entry.name)
			out.WriteByte(':')
			if err := writeValue(out, entry.value); err != nil {
				return err
			}
		}
		out.WriteByte('}')
	default:
		return fmt.Errorf("kernel: unexpected JSON value of type %T", value)
	}
	return nil
}

// sortMembers orders member names by UTF-16 code unit, contract rule 2's
// second half. slices.SortFunc is n log n; the comparator allocates
// nothing, so a large or reverse-ordered object costs n log n comparisons
// rather than the n^2 an insertion sort charged. Member names in one object
// are unique (duplicates are refused), so the sort's lack of stability
// changes nothing. Sorting by UTF-8 bytes instead would pass every test
// inside the basic multilingual plane and diverge on the supplementary
// planes, where a surrogate pair's leading unit (0xd800) sorts below U+E000
// and its UTF-8 bytes sort above.
func sortMembers(members []member) {
	slices.SortFunc(members, func(a, b member) int {
		return compareUTF16(a.name, b.name)
	})
}

// compareUTF16 orders two strings by their UTF-16 code units without
// allocating, walking each with a cursor that yields one code unit at a
// time. It returns the same order lessUTF16 did (a []uint16 comparison),
// which the existing member-ordering tests and the large-object test hold.
func compareUTF16(a, b string) int {
	ca, cb := utf16Cursor{s: a}, utf16Cursor{s: b}
	for {
		ua, oka := ca.next()
		ub, okb := cb.next()
		if !oka || !okb {
			switch {
			case oka == okb:
				return 0
			case !oka:
				return -1
			default:
				return 1
			}
		}
		if ua != ub {
			if ua < ub {
				return -1
			}
			return 1
		}
	}
}

// utf16Cursor walks a UTF-8 string yielding UTF-16 code units. A
// supplementary code point yields its two surrogate units across two calls,
// which is why the low unit is held pending rather than returned with the
// high one. The string is already well-formed (checkWellFormed refused
// invalid UTF-8 and unpaired surrogates), so DecodeRuneInString never
// returns a substitution here.
type utf16Cursor struct {
	s       string
	i       int
	low     uint16
	pending bool
}

func (c *utf16Cursor) next() (uint16, bool) {
	if c.pending {
		c.pending = false
		return c.low, true
	}
	if c.i >= len(c.s) {
		return 0, false
	}
	r, size := utf8.DecodeRuneInString(c.s[c.i:])
	c.i += size
	if r > 0xffff {
		high, low := utf16.EncodeRune(r)
		c.low, c.pending = uint16(low), true
		return uint16(high), true
	}
	return uint16(r), true
}

const hexDigits = "0123456789abcdef"

// writeString writes a JSON string with exactly the escapes RFC 8785
// §3.2.2.2 allows: the two mandatory ones, the five short control forms,
// and \u00xx for every other C0 control. Everything else is literal UTF-8,
// so no escape is ever chosen where a literal would do.
func writeString(out *strings.Builder, s string) {
	out.WriteByte('"')
	for i := 0; i < len(s); i++ {
		c := s[i]
		switch {
		case c == '"':
			out.WriteString(`\"`)
		case c == '\\':
			out.WriteString(`\\`)
		case c == '\b':
			out.WriteString(`\b`)
		case c == '\t':
			out.WriteString(`\t`)
		case c == '\n':
			out.WriteString(`\n`)
		case c == '\f':
			out.WriteString(`\f`)
		case c == '\r':
			out.WriteString(`\r`)
		case c < 0x20:
			out.WriteString(`\u00`)
			out.WriteByte(hexDigits[c>>4])
			out.WriteByte(hexDigits[c&0x0f])
		default:
			out.WriteByte(c)
		}
	}
	out.WriteByte('"')
}
