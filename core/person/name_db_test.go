//go:build db

// The name model's acceptance suite (person-identity/04). Run by
// `make person-test` against both live planes (there is no separate
// name-test target; person-test's own Makefile comment says why): signup
// provisions the
// person and their key (person-identity/01), and every scenario here
// drives Names against the real payload plane through core/envelope and
// core/outbox, exactly like person_db_test.go does for signup.
package person_test

import (
	"context"
	"sort"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/outbox"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// freshPersonAndNames signs up a usable identity and hands back its id
// alongside a Names service sharing the exact envelope Signup
// provisioned the person's key under. The software key provider holds
// its wrapping key in process memory, scoped to the *envelope.Envelope
// instance that constructed it (core/keys/software.go), so a second,
// independently constructed envelope cannot unwrap a DEK the first one
// wrapped: this is why every scenario below gets its id and its Names
// from one call here rather than composing newService and a fresh
// person.NewNames separately.
func freshPersonAndNames(t *testing.T) (string, *person.Names) {
	t.Helper()
	svc, env := newService(t)
	id, err := svc.Signup(context.Background(), person.Request{
		Email: person.Channel{Address: addresses(), VerifiedAt: time.Now().UTC()},
	})
	if err != nil {
		t.Fatalf("signup: %v", err)
	}
	return id, person.NewNames(env)
}

// TestMononymRoundTripsWithoutAnEmptySurname is the task's own named
// test end to end: an MRZ with no "<<" parses to a mononym, stores, and
// reads back with the whole two-word name in the primary identifier and
// an empty secondary, never a name split into surname-plus-nothing. The
// index derivation does not fragment it either.
func TestMononymRoundTripsWithoutAnEmptySurname(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	parsed := person.ParseMRZName("SATRIYA<SUDARPA")
	if !parsed.IsMononym || parsed.Secondary != "" {
		t.Fatalf("parser: %+v", parsed)
	}

	if err := nm.AppendDocumentName(ctx, id, person.DocumentName{
		DocumentType: "national_id", IssuingCountry: "id", ScriptCode: "Latn",
		Source: "MRZ", IsMononym: parsed.IsMononym,
		PrimaryIdentifier: parsed.Primary, SecondaryIdentifier: parsed.Secondary,
		MRZLine1: "I<IDN" + "SATRIYA<SUDARPA" + repeatFiller(44-5-16),
	}); err != nil {
		t.Fatalf("append document name: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Satriya Sudarpa", Use: person.UseUsual, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append person name: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	docs, err := nm.DocumentNames(ctx, id)
	if err != nil || len(docs) != 1 {
		t.Fatalf("document names: %v, %v", docs, err)
	}
	got := docs[0]
	if !got.IsMononym {
		t.Fatal("is_mononym did not survive the round trip")
	}
	if got.SecondaryIdentifier != "" {
		t.Fatalf("a mononym acquired a non-empty secondary identifier: %q", got.SecondaryIdentifier)
	}
	if got.PrimaryIdentifier != "SATRIYA SUDARPA" {
		t.Fatalf("primary identifier: got %q, want %q", got.PrimaryIdentifier, "SATRIYA SUDARPA")
	}

	names, err := nm.CurrentNames(ctx, id)
	if err != nil || len(names) != 1 || names[0].Text != "Satriya Sudarpa" {
		t.Fatalf("current names: %+v, %v", names, err)
	}
	if names[0].Parts != nil && names[0].Parts.Family != "" {
		t.Fatalf("a mononym acquired a non-empty family part: %+v", names[0].Parts)
	}

	// Matching step: the index carries the mononym as one token, never
	// split into a surname-only fragment.
	tokens, err := nm.DeriveIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("derive index tokens: %v", err)
	}
	found := false
	for _, tok := range tokens {
		if tok.Kind == "original" && tok.Value == "Satriya Sudarpa" {
			found = true
		}
		if tok.Value == "SATRIYA" || tok.Value == "SUDARPA" || tok.Value == "Sudarpa" || tok.Value == "Satriya" {
			t.Fatalf("the mononym was fragmented into a token: %+v", tok)
		}
	}
	if !found {
		t.Fatalf("no index token carried the whole mononym: %+v", tokens)
	}
}

func repeatFiller(n int) string {
	if n < 0 {
		n = 0
	}
	b := make([]byte, n)
	for i := range b {
		b[i] = '<'
	}
	return string(b)
}

// TestNameIndexRegenerationReproducesExactly: the mechanical criterion
// stated as a run. name_index_entry is append-only like every other
// table this migration adds, so "dropping and regenerating" is proven
// at the level the serving role can actually reach: an independent,
// fresh derivation from the source rows (DeriveIndexTokens) must equal
// what was persisted (StoredIndexTokens) exactly, as a set. Deleting the
// row and reinserting it is foundation/08's privilege, not
// identity_app's, and this is the property that survives that fact.
func TestNameIndexRegenerationReproducesExactly(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	if err := nm.Append(ctx, id, person.Name{
		Text: "María Núñez", Use: person.UseUsual, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append: %v", err)
	}
	if err := nm.AppendDocumentName(ctx, id, person.DocumentName{
		DocumentType: "passport", IssuingCountry: "es", ScriptCode: "Latn", Source: "VIZ",
		PrimaryIdentifier: "NUÑEZ", SecondaryIdentifier: "MARÍA",
		NativeScriptName: "Núñez Martínez",
	}); err != nil {
		t.Fatalf("append document: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	before, err := nm.DeriveIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("derive before write: %v", err)
	}
	nativeScriptIndexed := false
	for _, tok := range before {
		if tok.Kind == "original" && tok.Value == "Núñez Martínez" {
			nativeScriptIndexed = true
		}
	}
	if !nativeScriptIndexed {
		t.Fatalf("native_script_name did not produce an index token: %+v", before)
	}
	if err := nm.WriteIndex(ctx, id); err != nil {
		t.Fatalf("write index: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	stored, err := nm.StoredIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("stored index tokens: %v", err)
	}
	regenerated, err := nm.DeriveIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("derive after write: %v", err)
	}

	if len(before) == 0 || len(stored) == 0 {
		t.Fatalf("no tokens produced: before=%v stored=%v", before, stored)
	}
	assertSameTokenSet(t, "before vs stored", before, stored)
	assertSameTokenSet(t, "stored vs regenerated", stored, regenerated)
}

func assertSameTokenSet(t *testing.T, label string, a, b []person.DerivedToken) {
	t.Helper()
	if len(a) != len(b) {
		t.Fatalf("%s: %d tokens vs %d", label, len(a), len(b))
	}
	sort.Slice(a, func(i, j int) bool { return tokenKey(a[i]) < tokenKey(a[j]) })
	sort.Slice(b, func(i, j int) bool { return tokenKey(b[i]) < tokenKey(b[j]) })
	for i := range a {
		if a[i] != b[i] {
			t.Fatalf("%s: token %d differs:\n got  %+v\n want %+v", label, i, b[i], a[i])
		}
	}
}

func tokenKey(t person.DerivedToken) string {
	return t.SourceTable + "|" + t.SourceOutboxEntryID + "|" + t.Kind + "|" + t.Value
}

// TestNameChangeAppendsAndEndDatesWithoutMutation: a name change is a
// new row, never an UPDATE of the old one. The prior name still matches
// (AllNames) but is absent from the employer-facing render
// (CurrentNames), which is the query-layer withholding the task
// requires, not a delete and not an edit.
func TestNameChangeAppendsAndEndDatesWithoutMutation(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	if err := nm.Append(ctx, id, person.Name{
		Text: "Jordan Smith", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append v1: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Jordan Rivera", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append v2: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil || len(current) != 1 || current[0].Text != "Jordan Rivera" {
		t.Fatalf("current names: %+v, %v, want only the latest", current, err)
	}
	if current[0].PeriodEnd != nil {
		t.Fatalf("the current name carries an effective period_end: %+v", current[0])
	}

	all, err := nm.AllNames(ctx, id)
	if err != nil || len(all) != 2 {
		t.Fatalf("all names: %+v, %v, want both rows still present", all, err)
	}
	var prior, latest person.Name
	for _, n := range all {
		switch n.Text {
		case "Jordan Smith":
			prior = n
		case "Jordan Rivera":
			latest = n
		default:
			t.Fatalf("unexpected row: %+v", n)
		}
	}
	if prior.ID == "" || latest.ID == "" {
		t.Fatalf("both names must remain queryable for matching: %+v", all)
	}

	// The end-dating conjunct: the appending row (v2) names the row it
	// replaces, and the prior row's EFFECTIVE period_end (read through
	// person_name_effective, which AllNames selects) is that append's
	// asserted_at, not nil. v2 itself supersedes nothing before it and
	// carries no effective end.
	if latest.Supersedes != prior.ID {
		t.Fatalf("the new row does not name the row it replaces: got %q, want %q", latest.Supersedes, prior.ID)
	}
	if prior.Supersedes != "" {
		t.Fatalf("the prior row unexpectedly supersedes something: %q", prior.Supersedes)
	}
	if prior.PeriodEnd == nil {
		t.Fatal("the prior name's effective period_end is nil: it was never end-dated")
	}
	if !prior.PeriodEnd.Equal(latest.AssertedAt) {
		t.Fatalf("prior period_end %v does not match the superseding append's asserted_at %v",
			prior.PeriodEnd, latest.AssertedAt)
	}
	if latest.PeriodEnd != nil {
		t.Fatalf("the latest name carries an effective period_end: %v", latest.PeriodEnd)
	}

	// The non-mutation conjunct, proven at the strongest level available:
	// the prior row's OWN period_end column, read raw rather than through
	// person_name_effective, is still NULL. Nothing wrote to that row;
	// the end-date above is entirely a derivation from the new row's own
	// supersedes_outbox_entry_id.
	rawPeriodEnd := ownerSQL(t, "payload", `
		SELECT coalesce(period_end::text, 'null') FROM person_name
		 WHERE outbox_entry_id = $1`, transport.String(prior.ID))
	if rawPeriodEnd != "null" {
		t.Fatalf("the prior row's own period_end column was written to: %s", rawPeriodEnd)
	}

	// The table holds exactly two rows for this person, one per append,
	// never one row edited in place.
	count := ownerSQL(t, "payload", `
		SELECT count(*) FROM person_name WHERE person_id = $1`,
		transport.String(id))
	if count != "2" {
		t.Fatalf("person_name row count: got %s, want 2 (append-only, no mutation)", count)
	}
}

// TestCJKThreeRepresentationsRenderPerPurpose: an ideographic, a
// romanized, and a phonetic entry for the same use coexist as three
// simultaneously current rows, and each renders correctly when a caller
// names which purpose (representation) it wants.
func TestCJKThreeRepresentationsRenderPerPurpose(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	entries := []struct {
		representation person.Representation
		text           string
	}{
		{person.RepresentationIdeographic, "张伟"},
		{person.RepresentationRomanized, "Zhang Wei"},
		{person.RepresentationPhonetic, "ㄓㄤ ㄨㄟˇ"},
	}
	for _, e := range entries {
		if err := nm.Append(ctx, id, person.Name{
			Text: e.text, Use: person.UseUsual, Representation: e.representation,
		}); err != nil {
			t.Fatalf("append %s: %v", e.representation, err)
		}
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil || len(current) != 3 {
		t.Fatalf("current names: %+v, %v, want all three representations current at once", current, err)
	}

	for _, e := range entries {
		rendered, ok, err := nm.RenderFor(ctx, id, person.UseUsual, e.representation)
		if err != nil || !ok {
			t.Fatalf("render %s: %v, ok=%v", e.representation, err, ok)
		}
		if rendered.Text != e.text {
			t.Fatalf("render %s: got %q, want %q", e.representation, rendered.Text, e.text)
		}
	}
}

// TestOverLengthNameTextIsRejectedLoudlyAtTheServiceBoundary: decision
// 020 end to end. Append refuses before anything reaches the database.
func TestOverLengthNameTextIsRejectedLoudlyAtTheServiceBoundary(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	oversized := make([]rune, person.MaxNameTextRunes+1)
	for i := range oversized {
		oversized[i] = 'x'
	}
	err := nm.Append(ctx, id, person.Name{
		Text: string(oversized), Use: person.UseUsual, Representation: person.RepresentationRomanized,
	})
	if err == nil {
		t.Fatal("an over-length name was accepted")
	}

	names, err := nm.AllNames(ctx, id)
	if err != nil {
		t.Fatalf("all names: %v", err)
	}
	if len(names) != 0 {
		t.Fatalf("a rejected name reached storage anyway: %+v", names)
	}
}
