package outbox

import (
	"strings"
	"testing"
)

const entryID = "6f1a2b3c-4d5e-4f60-8a9b-0c1d2e3f4a5b"

func TestApplySQLIsDeterministicAndKeyed(t *testing.T) {
	in, err := Parse([]byte(`{"table":"outbox_probe_target","row":{"content":"hello","weight":2,"live":true,"note":null}}`))
	if err != nil {
		t.Fatal(err)
	}
	first, err := in.ApplySQL(entryID)
	if err != nil {
		t.Fatal(err)
	}
	second, _ := in.ApplySQL(entryID)
	if first != second {
		t.Fatalf("same instruction rendered two statements:\n%s\n%s", first, second)
	}
	for _, want := range []string{
		"INSERT INTO outbox_probe_target (outbox_entry_id, content, live, note, weight)",
		"VALUES ('" + entryID + "', 'hello', true, NULL, 2)",
		"ON CONFLICT (outbox_entry_id) DO NOTHING;",
	} {
		if !strings.Contains(first, want) {
			t.Fatalf("rendered SQL missing %q:\n%s", want, first)
		}
	}
}

// ConflictConstraint is a documented, per-table opt-in: empty leaves
// the default outbox_entry_id target untouched, which is what keeps a
// caller like person_record (person-identity/01, migration
// 0036-person-record-and-channels) raising on a duplicate person_id
// exactly as it always did. A prior version of this package instead
// widened the default itself, which caught that same duplicate silently
// where it used to error (person-identity/04's fourth verification
// pass); this test is that regression, pinned so it cannot come back.
func TestApplySQLDefaultsToOutboxEntryIDConflictTarget(t *testing.T) {
	in, err := Parse([]byte(`{"table":"person_record","row":{"person_id":"x"}}`))
	if err != nil {
		t.Fatal(err)
	}
	sql, err := in.ApplySQL(entryID)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(sql, "ON CONFLICT (outbox_entry_id) DO NOTHING;") {
		t.Fatalf("did not target the default outbox_entry_id conflict:\n%s", sql)
	}
	if strings.Contains(sql, "ON CONSTRAINT") {
		t.Fatalf("named a constraint with no ConflictConstraint set:\n%s", sql)
	}
}

// A named ConflictConstraint renders ON CONFLICT ON CONSTRAINT against
// exactly that name, name_index_entry's own opt-in (core/person).
func TestApplySQLHonorsANamedConflictConstraint(t *testing.T) {
	in := Instruction{
		Table: "name_index_entry", Row: map[string]any{"a": float64(1)},
		ConflictConstraint: "name_index_entry_dedup_key",
	}
	sql, err := in.ApplySQL(entryID)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(sql, "ON CONFLICT ON CONSTRAINT name_index_entry_dedup_key DO NOTHING;") {
		t.Fatalf("did not target the named constraint:\n%s", sql)
	}
	if strings.Contains(sql, "ON CONFLICT (outbox_entry_id)") {
		t.Fatalf("still targeted the default alongside the named constraint:\n%s", sql)
	}
}

func TestApplySQLRejectsAMalformedConflictConstraint(t *testing.T) {
	in := Instruction{
		Table: "t", Row: map[string]any{"a": 1},
		ConflictConstraint: "t; DROP TABLE t",
	}
	if _, err := in.ApplySQL(entryID); err == nil {
		t.Fatal("a malformed conflict_constraint was accepted")
	}
}

func TestApplySQLQuotesStrings(t *testing.T) {
	in, err := Parse([]byte(`{"table":"t","row":{"content":"O'Brien'; DROP TABLE t; --"}}`))
	if err != nil {
		t.Fatal(err)
	}
	sql, err := in.ApplySQL(entryID)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(sql, "'O''Brien''; DROP TABLE t; --'") {
		t.Fatalf("quotes not doubled:\n%s", sql)
	}
}

func TestParseRejects(t *testing.T) {
	cases := map[string]string{
		"bad table":        `{"table":"t; DROP","row":{"a":1}}`,
		"bad column":       `{"table":"t","row":{"a b":1}}`,
		"empty row":        `{"table":"t","row":{}}`,
		"reserved column":  `{"table":"t","row":{"outbox_entry_id":"x"}}`,
		"chosen residency": `{"table":"t","row":{"residency_region":"zz"}}`,
		"not JSON":         `nope`,
		"uppercase table":  `{"table":"Widgets","row":{"a":1}}`,
		"quoted injection": `{"table":"t\"","row":{"a":1}}`,
	}
	for name, raw := range cases {
		if _, err := Parse([]byte(raw)); err == nil {
			t.Errorf("%s: parsed without error", name)
		}
	}
}

func TestApplySQLRejectsNestedValues(t *testing.T) {
	in, err := Parse([]byte(`{"table":"t","row":{"a":{"nested":1}}}`))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := in.ApplySQL(entryID); err == nil {
		t.Fatal("nested object rendered as a literal")
	}
}

// The entry statement Enqueue runs and the one a caller composes into
// its own spine transaction (core/person's signup) are one builder's
// output, whole. Asserted here in full, because a caller checking only
// the leading phrase would not notice the two drifting apart.
func TestInsertStatementIsTheWholeEntryStatement(t *testing.T) {
	statement, err := InsertStatement(entryID, []byte(`{"table":"t","row":{"a":1}}`))
	if err != nil {
		t.Fatalf("InsertStatement: %v", err)
	}
	want := "INSERT INTO cross_plane_outbox (entry_id, target_plane, instruction)\n" +
		"VALUES ('" + entryID + "', 'payload', decode('eyJ0YWJsZSI6InQiLCJyb3ciOnsiYSI6MX19', 'base64'));"
	if statement != want {
		t.Fatalf("entry statement:\n got  %q\n want %q", statement, want)
	}
	if _, err := InsertStatement("not-a-uuid", nil); err == nil {
		t.Fatal("InsertStatement accepted an entry id that is not a uuid")
	}
}

func TestValidUUIDGatesEntryIDs(t *testing.T) {
	for _, bad := range []string{"", "not-a-uuid", strings.ToUpper(entryID), entryID + "'; --"} {
		if err := validUUID(bad); err == nil {
			t.Errorf("accepted %q", bad)
		}
	}
	if err := validUUID(entryID); err != nil {
		t.Errorf("rejected a valid id: %v", err)
	}
}
