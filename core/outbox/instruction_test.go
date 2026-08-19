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
