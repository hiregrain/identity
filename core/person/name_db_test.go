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
	"encoding/json"
	"fmt"
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
	return t.SourceTable + "|" + t.SourceOutboxEntryID + "|" + t.SourceField + "|" + t.Kind + "|" + t.Value
}

// TestNameChangeAppendsAndEndDatesWithoutMutation: a name change is a
// new row, never an UPDATE of the old one. The prior name still matches
// (AllNames) but is absent from the employer-facing render
// (CurrentNames), which is the query-layer withholding the task
// requires, not a delete and not an edit.
//
// The two Append calls below have NO drain between them, which is
// exactly the sequence the second verification pass reproduced a
// failure on: an earlier version of this package resolved "the row to
// supersede" with a write-time query against person_name_current, and
// that query cannot see a row still sitting in the spine outbox, so two
// ordinary sequential calls both found nothing to supersede and both
// wrote a pointer to nothing, leaving both rows current after the drain
// that finally applied them. There is nothing concurrent about this
// path: one goroutine, two calls, no drain between them, which the
// public API never forbids. The fix (person_name_effective's
// lead(asserted_at) OVER a (person, use, representation) partition) is a
// pure read-time derivation with no write-time lookup to race, so this
// test drives the exact sequence that broke the prior mechanism and
// asserts the read-time one closes it.
func TestNameChangeAppendsAndEndDatesWithoutMutation(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	if err := nm.Append(ctx, id, person.Name{
		Text: "Jordan Smith", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append v1: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Jordan Rivera", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append v2: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	// Exactly one row is current, and the prior name is absent from the
	// employer-facing render, which is the pair of conjuncts that fell
	// together on the write-time mechanism.
	current, err := nm.CurrentNames(ctx, id)
	if err != nil || len(current) != 1 || current[0].Text != "Jordan Rivera" {
		t.Fatalf("current names: %+v, %v, want exactly one row, the latest", current, err)
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

	// The end-dating conjunct: the prior row's EFFECTIVE period_end
	// (read through person_name_effective, which AllNames selects) is
	// the later row's own asserted_at, derived purely from ordering, not
	// nil. The later row itself has nothing after it and carries no
	// effective end.
	if prior.PeriodEnd == nil {
		t.Fatal("the prior name's effective period_end is nil: it was never end-dated")
	}
	if !prior.PeriodEnd.Equal(latest.AssertedAt) {
		t.Fatalf("prior period_end %v does not match the later row's asserted_at %v",
			prior.PeriodEnd, latest.AssertedAt)
	}
	if latest.PeriodEnd != nil {
		t.Fatalf("the latest name carries an effective period_end: %v", latest.PeriodEnd)
	}

	// The non-mutation conjunct, proven at the strongest level available:
	// the prior row's OWN period_end column, read raw rather than through
	// person_name_effective, is still NULL. Nothing wrote to that row;
	// the end-date above is entirely a derivation from asserted_at
	// ordering across both rows, computed fresh on every read.
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

// TestFutureStoredEndStaysCurrentUntilItPasses is decision 091's window
// semantics, probed shape 1: a name carrying an explicit period_end in
// the future is current, not excluded the instant any period_end is
// stored. Before decision 091, "period_end IS NULL" alone excluded this
// row from CurrentNames the moment it was stored, leaving a solitary
// row with a live, future-dated validity window absent from its own
// employer render.
func TestFutureStoredEndStaysCurrentUntilItPasses(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	start := time.Now().UTC().Add(-time.Hour)
	end := time.Now().UTC().Add(time.Hour)
	if err := nm.Append(ctx, id, person.Name{
		Text: "Alex Rivera", Use: person.UseTemp, Representation: person.RepresentationRomanized,
		PeriodStart: &start, PeriodEnd: &end,
	}); err != nil {
		t.Fatalf("append: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil || len(current) != 1 || current[0].Text != "Alex Rivera" {
		t.Fatalf("current names: %+v, %v, want the future-ended row present", current, err)
	}
	if current[0].PeriodEnd == nil || !current[0].PeriodEnd.Equal(end) {
		t.Fatalf("period_end: got %v, want %v", current[0].PeriodEnd, end)
	}
}

// TestPastEndBesideALiveRowLeavesExactlyOneCurrent is decision 091's
// window semantics, probed shape 2: a row whose own explicit period_end
// has already passed does not drag a genuinely live successor down with
// it, and the key never shows zero current rows while an unsuperseded,
// still-open row exists. Row 1 carries an explicit period_end already
// in the past (an expired temp name); row 2, appended immediately after
// with no stored period of its own, is the live row nothing has
// superseded. Both rows' effective periods are computed independently
// (person_name_effective is per-row), so row 1's own expiry cannot
// affect row 2's derivation.
func TestPastEndBesideALiveRowLeavesExactlyOneCurrent(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	longAgoStart := time.Now().UTC().Add(-48 * time.Hour)
	longAgoEnd := time.Now().UTC().Add(-24 * time.Hour)
	if err := nm.Append(ctx, id, person.Name{
		Text: "Sam Okafor (temp)", Use: person.UseTemp, Representation: person.RepresentationRomanized,
		PeriodStart: &longAgoStart, PeriodEnd: &longAgoEnd,
	}); err != nil {
		t.Fatalf("append the expired row: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Sam Okafor", Use: person.UseTemp, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append the live row: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil {
		t.Fatalf("current names: %v", err)
	}
	if len(current) != 1 {
		t.Fatalf("current names: %+v, want exactly one row, not zero", current)
	}
	if current[0].Text != "Sam Okafor" {
		t.Fatalf("the wrong row is current: %+v", current[0])
	}
	if current[0].PeriodEnd != nil {
		t.Fatalf("the live row carries an effective period_end: %v", current[0].PeriodEnd)
	}
}

// TestNoOverlapInversion is decision 091's window semantics, probed
// shape 3: two rows whose EXPLICIT validity windows are inverted
// relative to assertion order (the row asserted second claims the
// EARLIER real-world period, as backfilled historical data might), and
// both windows have already closed. Each row's effective period_end is
// its own stated end, evaluated independently against now, never
// inferred from the other row's period or from which was asserted
// first; the derivation does not get confused by the inversion, and an
// unsuperseded key with nothing open is correctly zero current rows,
// which decision 091 states outright ("a temporary or document-bounded
// name expires on schedule"), not the zero-current-rows defect the
// ruling fixes (that defect was a live window wrongly excluded, not a
// genuinely closed one).
func TestNoOverlapInversion(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	recentStart := time.Date(2024, 1, 1, 0, 0, 0, 0, time.UTC)
	recentEnd := time.Date(2024, 6, 1, 0, 0, 0, 0, time.UTC)
	olderStart := time.Date(2020, 1, 1, 0, 0, 0, 0, time.UTC)
	olderEnd := time.Date(2020, 6, 1, 0, 0, 0, 0, time.UTC)

	if err := nm.Append(ctx, id, person.Name{
		Text: "Priya Nair (2024 record)", Use: person.UseOld, Representation: person.RepresentationRomanized,
		PeriodStart: &recentStart, PeriodEnd: &recentEnd,
	}); err != nil {
		t.Fatalf("append the first-asserted, later-period row: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Priya Nair (2020 record)", Use: person.UseOld, Representation: person.RepresentationRomanized,
		PeriodStart: &olderStart, PeriodEnd: &olderEnd,
	}); err != nil {
		t.Fatalf("append the second-asserted, earlier-period row: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	all, err := nm.AllNames(ctx, id)
	if err != nil || len(all) != 2 {
		t.Fatalf("all names: %+v, %v, want both rows", all, err)
	}
	for _, n := range all {
		switch n.Text {
		case "Priya Nair (2024 record)":
			if n.PeriodEnd == nil || !n.PeriodEnd.Equal(recentEnd) {
				t.Fatalf("2024 row's own period was not preserved: %+v", n)
			}
		case "Priya Nair (2020 record)":
			if n.PeriodEnd == nil || !n.PeriodEnd.Equal(olderEnd) {
				t.Fatalf("2020 row's own period was not preserved: %+v", n)
			}
		default:
			t.Fatalf("unexpected row: %+v", n)
		}
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil {
		t.Fatalf("current names: %v", err)
	}
	if len(current) != 0 {
		t.Fatalf("current names: %+v, want zero: both windows have closed and neither was superseded", current)
	}
}

// TestSupersededRowWithAFutureStatedEndIsNotCurrent is decision 092
// closing the case decision 091 did not reach, the exact shape the
// fourth verification pass failed on. A row carries its own stated
// period_end far in the future (a document's stated expiry, say), and
// is then superseded by an ordinary replacement with no stated period
// of its own. Under COALESCE(period_end, lead(...)), the stored future
// end always won over the lead-derived one, so the superseded row
// stayed "current" under decision 091's window predicate right
// alongside its replacement: two rows current for one key, and the one
// the criterion names as the thing to withhold (the prior name in a
// gender transition or marriage) is the one still rendered. LEAST
// closes it: a superseded row's effective end is the earlier of its own
// stated end and its successor's asserted_at, so being superseded ends
// it even when its own window would have run longer.
func TestSupersededRowWithAFutureStatedEndIsNotCurrent(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	farFuture := time.Now().UTC().AddDate(1, 0, 0)
	if err := nm.Append(ctx, id, person.Name{
		Text: "Deadname Here", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
		PeriodEnd: &farFuture,
	}); err != nil {
		t.Fatalf("append the row with a future stated end: %v", err)
	}
	if err := nm.Append(ctx, id, person.Name{
		Text: "Chosen Name", Use: person.UseOfficial, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append the replacement: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	current, err := nm.CurrentNames(ctx, id)
	if err != nil {
		t.Fatalf("current names: %v", err)
	}
	if len(current) != 1 || current[0].Text != "Chosen Name" {
		t.Fatalf("current names: %+v, want exactly one row, the replacement; "+
			"the prior name with a future stated end must not leak into the employer render", current)
	}

	all, err := nm.AllNames(ctx, id)
	if err != nil || len(all) != 2 {
		t.Fatalf("all names: %+v, %v, want both rows still present", all, err)
	}
	var prior person.Name
	for _, n := range all {
		if n.Text == "Deadname Here" {
			prior = n
		}
	}
	if prior.ID == "" {
		t.Fatalf("the prior name must remain queryable for matching: %+v", all)
	}
	if prior.PeriodEnd == nil || !prior.PeriodEnd.Before(farFuture) {
		t.Fatalf("the prior row's effective period_end: got %v, want the successor's asserted_at "+
			"(earlier than its own far-future stated end %v)", prior.PeriodEnd, farFuture)
	}

	// Non-mutation: the row's OWN period_end column, read raw rather
	// than through person_name_effective, still holds the far-future
	// value the caller wrote. Being end-dated by a successor is entirely
	// a read-time derivation; nothing was written to this row a second
	// time.
	rawPeriodEnd := ownerSQL(t, "payload", `
		SELECT period_end::text FROM person_name WHERE outbox_entry_id = $1`,
		transport.String(prior.ID))
	wantRaw := farFuture.Format("2006-01-02 15:04:05")
	if rawPeriodEnd[:len(wantRaw)] != wantRaw {
		t.Fatalf("the prior row's own period_end column: got %q, want it to start with %q (unmutated)",
			rawPeriodEnd, wantRaw)
	}
}

// TestWriteIndexTwiceLeavesTheStoredSetUnchanged is code review finding
// 3 on person-identity/04's third verification pass: WriteIndex
// generates a fresh outbox_entry_id per row on every call, so
// outbox_entry_id alone cannot dedupe a second call's rows against the
// first's. name_index_entry's own UNIQUE constraint,
// name_index_entry_dedup_key, on (person_id, source_table,
// source_outbox_entry_id, source_field, token_kind, generator_version)
// is the real idempotency key, named explicitly as this table's
// ConflictConstraint (core/outbox) rather than caught by a blanket,
// unspecified ON CONFLICT DO NOTHING, which once weakened a different
// table's own unique constraint the same way (person-identity/04's
// fourth verification pass).
func TestWriteIndexTwiceLeavesTheStoredSetUnchanged(t *testing.T) {
	ctx := context.Background()
	id, nm := freshPersonAndNames(t)

	if err := nm.Append(ctx, id, person.Name{
		Text: "Idempotent Iris", Use: person.UseUsual, Representation: person.RepresentationRomanized,
	}); err != nil {
		t.Fatalf("append: %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	if err := nm.WriteIndex(ctx, id); err != nil {
		t.Fatalf("write index (first): %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}
	first, err := nm.StoredIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("stored index tokens (first): %v", err)
	}
	if len(first) == 0 {
		t.Fatal("no tokens were written")
	}
	for _, tok := range first {
		if tok.GeneratorVersion != person.IndexGeneratorVersion {
			t.Fatalf("stored generator_version: got %d, want %d", tok.GeneratorVersion, person.IndexGeneratorVersion)
		}
	}

	if err := nm.WriteIndex(ctx, id); err != nil {
		t.Fatalf("write index (second): %v", err)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}
	second, err := nm.StoredIndexTokens(ctx, id)
	if err != nil {
		t.Fatalf("stored index tokens (second): %v", err)
	}
	assertSameTokenSet(t, "first WriteIndex vs second", first, second)

	count := ownerSQL(t, "payload", `
		SELECT count(*) FROM name_index_entry WHERE person_id = $1`,
		transport.String(id))
	if count != fmt.Sprint(len(first)) {
		t.Fatalf("name_index_entry row count: got %s, want %d (a second WriteIndex must not duplicate rows)", count, len(first))
	}
}

// TestDuplicatePersonRecordStillErrorsThroughTheApplyPath proves item 2
// of person-identity/04's fourth verification pass fixed a real
// regression this task's own earlier fix introduced. core/outbox's
// apply path once defaulted to an unspecified ON CONFLICT DO NOTHING to
// give name_index_entry its idempotency, and an unspecified target
// catches a conflict on ANY unique constraint a table has, not only the
// one that needed it: person_record's own UNIQUE(person_id) (migration
// 0036-person-record-and-channels) silently absorbed a second
// person_record for an already-signed-up person, applying with no row
// written and no error, where it used to raise. The fix narrows the
// default back to ON CONFLICT (outbox_entry_id) DO NOTHING and gives
// name_index_entry a named, per-table opt-in instead
// (nameIndexDedupConstraint). This drives person_record through the
// ordinary, unnamed default path a second time and asserts the
// duplicate still fails to apply.
func TestDuplicatePersonRecordStillErrorsThroughTheApplyPath(t *testing.T) {
	id, _ := freshPersonAndNames(t)

	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain the original signup: %v", err)
	}
	before := ownerSQL(t, "payload",
		`SELECT count(*) FROM person_record WHERE person_id = $1`, transport.String(id))
	if before != "1" {
		t.Fatalf("person_record row count before the duplicate: got %s, want 1", before)
	}

	duplicate := outbox.Instruction{
		Table: "person_record",
		Row:   map[string]any{"person_id": id},
	}
	raw, err := json.Marshal(duplicate)
	if err != nil {
		t.Fatalf("encoding the duplicate instruction: %v", err)
	}
	entryID, err := person.NewID()
	if err != nil {
		t.Fatalf("entry id: %v", err)
	}
	if err := outbox.Enqueue(entryID, raw, ""); err != nil {
		t.Fatalf("enqueue the duplicate: %v", err)
	}

	applied, failed, err := outbox.Drain("")
	if err != nil {
		t.Fatalf("drain: %v", err)
	}
	if applied != 0 || failed != 1 {
		t.Fatalf("drain result: applied=%d failed=%d, want applied=0 failed=1 "+
			"(a duplicate person_id must fail to apply, not silently no-op)", applied, failed)
	}

	after := ownerSQL(t, "payload",
		`SELECT count(*) FROM person_record WHERE person_id = $1`, transport.String(id))
	if after != "1" {
		t.Fatalf("person_record row count after the duplicate: got %s, want 1 (still just the original)", after)
	}
}
