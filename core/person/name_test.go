// The database-free half of person-identity/04's proofs: MRZ parsing
// (the mononym trap named as a required test), the truncation signal,
// bound rejection, the parts-in-text invariant, and index-token
// determinism. Run by `make go-check`, no Docker.
package person

import (
	"strings"
	"testing"
)

// TestMononymMRZWithNoDoubleFillerIsNotSplit is the task's own named
// test: a mononym MRZ contains no "<<" at all, and a parser that splits
// on "<<" or, worse, on every "<", corrupts it by assigning the whole
// name to the surname with an empty given name. Three of six major IDV
// vendors do exactly this.
func TestMononymMRZWithNoDoubleFillerIsNotSplit(t *testing.T) {
	got := ParseMRZName("SATRIYA<SUDARPA")
	if !got.IsMononym {
		t.Fatal("a field with no << was not recognized as a mononym")
	}
	if got.Secondary != "" {
		t.Fatalf("a mononym acquired a non-empty secondary identifier: %q", got.Secondary)
	}
	if got.Primary != "SATRIYA SUDARPA" {
		t.Fatalf("primary identifier: got %q, want %q (both words kept, joined by a space)", got.Primary, "SATRIYA SUDARPA")
	}
}

// A single-word mononym round-trips the same way.
func TestSingleWordMononymMRZ(t *testing.T) {
	got := ParseMRZName("BUDI")
	if !got.IsMononym || got.Primary != "BUDI" || got.Secondary != "" {
		t.Fatalf("got %+v", got)
	}
}

// The ordinary two-identifier case: "<<" is the boundary, and each
// side's own internal "<" is a word separator, not a further split.
func TestOrdinaryMRZNameSplitsOnDoubleFiller(t *testing.T) {
	got := ParseMRZName("GARCIA<LOPEZ<<MARIA<DEL<CARMEN")
	if got.IsMononym {
		t.Fatal("a two-identifier name was reported as a mononym")
	}
	if got.Primary != "GARCIA LOPEZ" {
		t.Fatalf("primary: got %q", got.Primary)
	}
	if got.Secondary != "MARIA DEL CARMEN" {
		t.Fatalf("secondary: got %q", got.Secondary)
	}
}

// A secondary identifier that is present but empty after the boundary
// (an issuer's own way of encoding a mononym) is still a mononym.
func TestMRZWithExplicitEmptySecondaryIsAMononym(t *testing.T) {
	got := ParseMRZName("BUDI<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	if !got.IsMononym || got.Secondary != "" || got.Primary != "BUDI" {
		t.Fatalf("got %+v", got)
	}
}

// Trailing pad filler on an ordinary name is stripped, not turned into
// trailing spaces.
func TestTrailingFillerIsStripped(t *testing.T) {
	got := ParseMRZName("MUELLER<<HANS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	if got.Primary != "MUELLER" || got.Secondary != "HANS" {
		t.Fatalf("got %+v", got)
	}
}

// PossiblyTruncated is ambiguous by design: a full-width line ending in
// a letter MAY have been cut, and a short line cannot have been, by that
// field's own width.
func TestPossiblyTruncated(t *testing.T) {
	cases := []struct {
		name string
		line string
		want bool
	}{
		{"full width, ends in a letter", strings.Repeat("A", 44), true},
		{"full width, ends in filler", strings.Repeat("A", 43) + "<", false},
		{"shorter than the field", strings.Repeat("A", 30), false},
		{"empty", "", false},
	}
	for _, c := range cases {
		if got := PossiblyTruncated(c.line); got != c.want {
			t.Errorf("%s: got %v, want %v", c.name, got, c.want)
		}
	}
}

// TestNameTextAtTheBoundIsAccepted: the rejection below is a bound, not
// a ban.
func TestNameTextAtTheBoundIsAccepted(t *testing.T) {
	n := Name{
		Text: strings.Repeat("中", MaxNameTextRunes),
		Use:  UseUsual, Representation: RepresentationIdeographic,
	}
	if err := n.validate(); err != nil {
		t.Fatalf("a name at the bound was rejected: %v", err)
	}
}

// TestNameTextOverTheBoundIsRejectedLoudly: decision 020's rule, stated
// as a test. Nothing truncates.
func TestNameTextOverTheBoundIsRejectedLoudly(t *testing.T) {
	n := Name{
		Text: strings.Repeat("x", MaxNameTextRunes+1),
		Use:  UseUsual, Representation: RepresentationRomanized,
	}
	err := n.validate()
	if err == nil {
		t.Fatal("an over-length name text was accepted")
	}
	if !strings.Contains(err.Error(), ErrNameTextLength.Error()) {
		t.Fatalf("wrong error: %v", err)
	}
}

func TestNamePartOverTheBoundIsRejected(t *testing.T) {
	n := Name{
		Text:  strings.Repeat("x", MaxNamePartRunes+1),
		Parts: &Parts{Family: strings.Repeat("x", MaxNamePartRunes+1)},
		Use:   UseUsual, Representation: RepresentationRomanized,
	}
	if err := n.validate(); err == nil || !strings.Contains(err.Error(), ErrNamePartLength.Error()) {
		t.Fatalf("got %v, want ErrNamePartLength", err)
	}
}

func TestTooManyGivenNamesIsRejected(t *testing.T) {
	given := make([]string, MaxGivenNames+1)
	text := ""
	for i := range given {
		given[i] = "A"
		text += "A "
	}
	n := Name{
		Text: strings.TrimSpace(text), Parts: &Parts{Given: given},
		Use: UseUsual, Representation: RepresentationRomanized,
	}
	if err := n.validate(); err == nil || !strings.Contains(err.Error(), ErrTooManyGivenNames.Error()) {
		t.Fatalf("got %v, want ErrTooManyGivenNames", err)
	}
}

// The invariant the migration's own comment states: when both text and
// parts are present, text contains nothing absent from a part.
func TestPartAbsentFromTextIsRejected(t *testing.T) {
	n := Name{
		Text:  "Maria Santos",
		Parts: &Parts{Family: "Cruz"}, // not a substring of the text
		Use:   UseUsual, Representation: RepresentationRomanized,
	}
	if err := n.validate(); err == nil || !strings.Contains(err.Error(), ErrPartsNotInText.Error()) {
		t.Fatalf("got %v, want ErrPartsNotInText", err)
	}
}

// A mononym with parts holding the same single string as text is valid:
// the family field is legitimately empty and never required.
func TestMononymWithNoDecomposedFamilyIsValid(t *testing.T) {
	n := Name{
		Text: "Satriya Sudarpa", Parts: &Parts{Given: []string{"Satriya", "Sudarpa"}},
		Use: UseUsual, Representation: RepresentationRomanized,
	}
	if err := n.validate(); err != nil {
		t.Fatalf("a mononym-shaped name with no family part was rejected: %v", err)
	}
	if n.Parts.Family != "" {
		t.Fatal("the family part was not empty")
	}
}

func TestNameUseAndRepresentationAreClosedVocabularies(t *testing.T) {
	if err := (Name{Text: "x", Use: "spouse", Representation: RepresentationRomanized}).validate(); err == nil {
		t.Fatal("an unknown use was accepted")
	}
	if err := (Name{Text: "x", Use: UseUsual, Representation: "XYZ"}).validate(); err == nil {
		t.Fatal("an unknown representation was accepted")
	}
}

func TestDocumentNameBounds(t *testing.T) {
	base := DocumentName{
		DocumentType: "passport", IssuingCountry: "id", ScriptCode: "Latn", Source: "MRZ",
		PrimaryIdentifier: "SATRIYA SUDARPA",
	}
	if err := base.validate(); err != nil {
		t.Fatalf("a well-formed document name was rejected: %v", err)
	}

	overLong := base
	overLong.PrimaryIdentifier = strings.Repeat("x", MaxDocumentFieldRunes+1)
	if err := overLong.validate(); err == nil || !strings.Contains(err.Error(), ErrDocumentFieldLength.Error()) {
		t.Fatalf("got %v, want ErrDocumentFieldLength", err)
	}

	longMRZ := base
	longMRZ.MRZLine1 = strings.Repeat("A", MaxMRZLineLength+1)
	if err := longMRZ.validate(); err == nil || !strings.Contains(err.Error(), ErrMRZLineLength.Error()) {
		t.Fatalf("got %v, want ErrMRZLineLength", err)
	}

	badCharset := base
	badCharset.MRZLine1 = "p<idnSATRIYA<<SUDARPA<<<<<<<<<<<<<<<<<<<<<<"
	if err := badCharset.validate(); err == nil || !strings.Contains(err.Error(), ErrMRZCharset.Error()) {
		t.Fatalf("got %v, want ErrMRZCharset (MRZ is upper-case-only)", err)
	}

	badCountry := base
	badCountry.IssuingCountry = "IDN"
	if err := badCountry.validate(); err == nil || !strings.Contains(err.Error(), ErrIssuingCountry.Error()) {
		t.Fatalf("got %v, want ErrIssuingCountry", err)
	}

	badScript := base
	badScript.ScriptCode = "latin"
	if err := badScript.validate(); err == nil || !strings.Contains(err.Error(), ErrScriptCode.Error()) {
		t.Fatalf("got %v, want ErrScriptCode", err)
	}

	badSource := base
	badSource.Source = "GUESS"
	if err := badSource.validate(); err == nil || !strings.Contains(err.Error(), ErrDocumentSource.Error()) {
		t.Fatalf("got %v, want ErrDocumentSource", err)
	}
}

// A 39-character boundary name (the MRZ name field's own width on a TD3
// line, once the 5-character document/country prefix is excluded) is
// exactly the case the outside check's fixture set names.
func TestBoundaryLengthMRZName(t *testing.T) {
	name39 := strings.Repeat("A", 20) + "<<" + strings.Repeat("B", 17) // 39 chars total
	if len(name39) != 39 {
		t.Fatalf("fixture is %d chars, want 39", len(name39))
	}
	got := ParseMRZName(name39)
	if got.IsMononym {
		t.Fatal("a two-identifier 39-char name was reported as a mononym")
	}
	if got.Primary != strings.Repeat("A", 20) || got.Secondary != strings.Repeat("B", 17) {
		t.Fatalf("got %+v", got)
	}
}

// GenerateIndexTokens: the original is always kept, a diacritic-folded
// form is added alongside it (never replacing it) exactly when folding
// changes something, and calling it twice on the same input reproduces
// the same output, the property the mechanical criterion needs.
func TestGenerateIndexTokensIsDeterministic(t *testing.T) {
	for _, text := range []string{"Müller", "Satriya Sudarpa", "张伟", "  spaced  ", ""} {
		a := GenerateIndexTokens(text)
		b := GenerateIndexTokens(text)
		if len(a) != len(b) {
			t.Fatalf("%q: non-deterministic token count %d vs %d", text, len(a), len(b))
		}
		for i := range a {
			if a[i] != b[i] {
				t.Fatalf("%q: token %d differs: %+v vs %+v", text, i, a[i], b[i])
			}
		}
	}
}

func TestGenerateIndexTokensKeepsTheOriginalAlongsideAFold(t *testing.T) {
	tokens := GenerateIndexTokens("Müller")
	if len(tokens) != 2 {
		t.Fatalf("got %d tokens, want 2 (original + folded): %+v", len(tokens), tokens)
	}
	if tokens[0].Kind != "original" || tokens[0].Value != "Müller" {
		t.Fatalf("original token: %+v", tokens[0])
	}
	if tokens[1].Kind != "diacritic_folded" || tokens[1].Value != "Muller" {
		t.Fatalf("folded token: %+v", tokens[1])
	}
}

// Non-Latin script text with nothing to fold produces the original
// token alone: no phonetic hash, no fabricated romanization.
func TestGenerateIndexTokensNeverPhoneticHashesNonLatinScript(t *testing.T) {
	tokens := GenerateIndexTokens("张伟")
	if len(tokens) != 1 || tokens[0].Kind != "original" || tokens[0].Value != "张伟" {
		t.Fatalf("got %+v, want the original alone", tokens)
	}
}

func TestGenerateIndexTokensOnEmptyText(t *testing.T) {
	if tokens := GenerateIndexTokens("   "); tokens != nil {
		t.Fatalf("blank text produced tokens: %+v", tokens)
	}
}
