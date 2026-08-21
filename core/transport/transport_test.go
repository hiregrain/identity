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

// TestRenderDoesNotRescanSubstitutedLiterals is the multi-argument
// render red path (trust-kernel/08 verification finding): a repeated
// whole-string ReplaceAll substitution rescans literals it already
// inserted, so a String argument containing the text "$1" is
// reinterpreted as a placeholder on a later substitution pass and
// replaced again, breaking a quoted literal open. This plants exactly
// that shape, a $k-shaped payload at $2 alongside an injection payload
// at $1, and asserts the SQL Postgres would receive keeps the payload
// as data inside one quoted literal, never as a second statement.
func TestRenderDoesNotRescanSubstitutedLiterals(t *testing.T) {
	injection := "; CREATE TABLE verifier_injected(x int); --"
	rendered, err := render("SELECT $1, $2", []Arg{String(injection), String("$1")})
	if err != nil {
		t.Fatalf("render: %v", err)
	}
	// The only correct single-pass rendering: each placeholder is
	// substituted exactly once, at its own position, from the
	// UNMODIFIED source text, so $2's literal is never re-scanned for
	// the $1 it happens to contain.
	want := "SELECT '; CREATE TABLE verifier_injected(x int); --', '$1'"
	if rendered != want {
		t.Fatalf("render rescanned a substituted literal:\n got:  %q\nwant: %q", rendered, want)
	}
	// The payload never appears unquoted: every byte of it sits inside
	// exactly one pair of single quotes, so Postgres reads it as one
	// text literal, not a second statement.
	quoted := "'" + injection + "'"
	if !strings.Contains(rendered, quoted) {
		t.Fatalf("injection payload is not enclosed in a single quoted literal: %q", rendered)
	}
	if strings.Count(rendered, "''") != 0 {
		t.Fatalf("an empty-string literal artifact ('') appeared, the signature of the rescan bug: %q", rendered)
	}

	// A second shape: the injection payload itself sits at the HIGHER
	// index ($2), so a highest-index-first substitution pass writes it
	// into the statement before the $1 pass runs, and a naive
	// whole-string rescan on that later pass would find and replace
	// the "$1" text embedded inside the already-inserted payload.
	rendered2, err := render("SELECT $1, $2", []Arg{String("$1"), String(injection)})
	if err != nil {
		t.Fatalf("render: %v", err)
	}
	want2 := "SELECT '$1', '; CREATE TABLE verifier_injected(x int); --'"
	if rendered2 != want2 {
		t.Fatalf("render rescanned a substituted literal:\n got:  %q\nwant: %q", rendered2, want2)
	}
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
