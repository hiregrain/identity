package transport

import (
	"strconv"
	"strings"
	"testing"
)

// The renderer's red-path suite (trust-kernel/08, criterion 4): every
// typed-arg rule decision 065 states, proven directly against Literal
// without a database.

func TestStringRendersInertAndRoundTrips(t *testing.T) {
	injection := `O'Brien'; DROP TABLE t; --`
	lit, err := Literal(String(injection))
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	want := `'O''Brien''; DROP TABLE t; --'`
	if lit != want {
		t.Fatalf("got %q, want %q", lit, want)
	}
	// Round-trips byte-identical: undoing the quote-doubling recovers
	// the exact original bytes.
	inner := strings.TrimSuffix(strings.TrimPrefix(lit, "'"), "'")
	if strings.ReplaceAll(inner, "''", "'") != injection {
		t.Fatalf("did not round-trip byte-identical: %q", lit)
	}
}

func TestStringRefusesNUL(t *testing.T) {
	if _, err := Literal(String("before\x00after")); err == nil {
		t.Fatal("a NUL byte was accepted")
	}
}

func TestNullRendersKeywordNotText(t *testing.T) {
	lit, err := Literal(Null)
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	if lit != "NULL" {
		t.Fatalf("got %q, want the bare keyword NULL, not a quoted string", lit)
	}
}

func TestBoolRoundTripsTyped(t *testing.T) {
	for _, b := range []bool{true, false} {
		lit, err := Literal(Bool(b))
		if err != nil {
			t.Fatalf("Literal: %v", err)
		}
		if lit != strconv.FormatBool(b) {
			t.Fatalf("Bool(%v) rendered %q unquoted-bare expected", b, lit)
		}
		if strings.Contains(lit, "'") {
			t.Fatalf("Bool(%v) rendered as a quoted string: %q", b, lit)
		}
	}
}

func TestNumericsRoundTripTyped(t *testing.T) {
	intLit, err := Literal(Int(-42))
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	if intLit != "-42" || strings.Contains(intLit, "'") {
		t.Fatalf("Int(-42) rendered %q, want the bare literal -42", intLit)
	}
	floatLit, err := Literal(Float(3.5))
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	if floatLit != "3.5" || strings.Contains(floatLit, "'") {
		t.Fatalf("Float(3.5) rendered %q, want the bare literal 3.5", floatLit)
	}
}

func TestBackslashXStringRendersAsText(t *testing.T) {
	// A worker-supplied string shaped like hex bytea must never be
	// reinterpreted as bytea by the renderer's own initiative: hex
	// rendering happens only through Bytea, never inferred from a
	// string's shape.
	shape := `\x68656c6c6f`
	lit, err := Literal(String(shape))
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	want := `'\x68656c6c6f'`
	if lit != want {
		t.Fatalf("got %q, want the plain quoted text %q (no hex-escape form)", lit, want)
	}
}

func TestByteaRendersOnlyThroughTheWrapper(t *testing.T) {
	lit, err := Literal(Bytea([]byte{0xde, 0xad, 0xbe, 0xef}))
	if err != nil {
		t.Fatalf("Literal: %v", err)
	}
	want := `'\xdeadbeef'`
	if lit != want {
		t.Fatalf("got %q, want %q", lit, want)
	}
	// No other Arg constructor reaches this rendering: String on the
	// same shape (proven above) renders as plain text, never hex.
}

func TestSplitRowIsBoundedWithLastFieldUnbounded(t *testing.T) {
	// A detail field containing the separator is not corrupted: the
	// bounded split keeps trailing tabs inside the last column.
	line := "id-1\t3\t2\tdetail with a\ttab and a|pipe intact"
	fields := SplitRow(line, 4)
	if len(fields) != 4 {
		t.Fatalf("got %d fields, want 4", len(fields))
	}
	if fields[3] != "detail with a\ttab and a|pipe intact" {
		t.Fatalf("last field corrupted by an unbounded split: %q", fields[3])
	}
}
