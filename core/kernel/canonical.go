package kernel

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"
	"unicode/utf16"
)

// Errors Canonicalize reports. Each names the contract rule it enforces so
// a failure reads as a rule violation rather than a parser complaint.
var (
	ErrNotJSON       = errors.New("kernel: input is not one JSON document")
	ErrDuplicateKey  = errors.New("kernel: object has a duplicate member name")
	ErrTrailingBytes = errors.New("kernel: input carries bytes after the JSON document")
)

// Canonicalize returns the RFC 8785 (JCS) canonical form of one JSON
// document, which is contract rules 1 and 2: no Unicode normalization, so
// NFC and NFD stay distinct strings and distinct keys; ECMAScript number
// formatting; member names sorted by UTF-16 code unit.
//
// The input is JSON text rather than a Go value because the canonical form
// is a property of the document, and routing it through a Go map would lose
// duplicate members and reorder nothing reproducibly.
//
// One representational limit, and it is the reason no vector exercises it:
// an unpaired surrogate escape survives ECMAScript's well-formed
// JSON.stringify and does not survive Go's JSON decoder, which substitutes
// U+FFFD. Inputs carrying one are outside what the two implementations can
// agree on, so they are outside the contract rather than silently divergent.
func Canonicalize(document []byte) ([]byte, error) {
	decoder := json.NewDecoder(bytes.NewReader(document))
	decoder.UseNumber()

	value, err := parseValue(decoder)
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

func parseValue(decoder *json.Decoder) (any, error) {
	token, err := decoder.Token()
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrNotJSON, err)
	}
	return parseFrom(decoder, token)
}

func parseFrom(decoder *json.Decoder, token json.Token) (any, error) {
	delim, isDelim := token.(json.Delim)
	if !isDelim {
		return token, nil
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
			value, err := parseValue(decoder)
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
			element, err := parseFrom(decoder, token)
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
// second half. Insertion sort because objects here are small and the
// comparison, not the algorithm, is what the rule is about. Sorting by
// UTF-8 bytes instead would pass every test that stays inside the basic
// multilingual plane and diverge on the supplementary planes, where a
// surrogate pair's leading unit (0xD800) sorts below U+E000 and its UTF-8
// bytes sort above.
func sortMembers(members []member) {
	for i := 1; i < len(members); i++ {
		for j := i; j > 0 && lessUTF16(members[j].name, members[j-1].name); j-- {
			members[j], members[j-1] = members[j-1], members[j]
		}
	}
}

func lessUTF16(a, b string) bool {
	left := utf16.Encode([]rune(a))
	right := utf16.Encode([]rune(b))
	for i := 0; i < len(left) && i < len(right); i++ {
		if left[i] != right[i] {
			return left[i] < right[i]
		}
	}
	return len(left) < len(right)
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
