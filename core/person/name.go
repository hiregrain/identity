// The name model (person-identity/04; decisions 013, 020; research/11,
// cited in the task file as research/13, a stale number this package
// does not correct on its own: the fence reserves research and plan
// prose to human/agent authorship). FHIR HumanName is the adopted shape,
// because it is temporal, multi-valued, and purpose-tagged, which is
// what an append-only ledger needs: a name change is a new row that
// names the row it replaces (supersedes_outbox_entry_id), which is what
// end-dates the prior row without a write ever touching it.
//
// Three layers, never collapsed (decision 013):
//
//	person_name    worker-owned, structured, append-only, many rows per
//	               person distinguished by use and, for CJK, by which
//	               script they render in.
//	document_name  immutable per verified document, in ICAO Doc 9303's
//	               own primary/secondary identifier vocabulary, never
//	               first/last name.
//	name_index     derived, regenerable, never authoritative: candidates
//	               for a later matching layer (person-identity/05) to
//	               consume, never a decision this package makes.
//
// Every worker-supplied string is sealed under the person's own DEK
// before it reaches the payload plane (migration 0011-names), the same
// posture as person_record.display_name_ciphertext and
// person_contact_channel.address_ciphertext. Bounds are explicit,
// generous, and enforced here rather than by a column width, because a
// ciphertext column cannot express a length bound (decision 020):
// over-length input is rejected loudly, and nothing in this package
// truncates.
package person

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/hiregrain/identity/core/outbox"
	"github.com/hiregrain/identity/core/transport"
)

// Errors. Every one names the bound or rule a caller can fix, mirroring
// person.go's posture: none carries the name content that failed.
var (
	ErrNameTextLength      = fmt.Errorf("name: text exceeds its stated bound")
	ErrNamePartLength      = fmt.Errorf("name: a decomposed part exceeds its stated bound")
	ErrTooManyGivenNames   = fmt.Errorf("name: given names exceed their stated bound")
	ErrNameUse             = fmt.Errorf("name: use is outside the closed vocabulary")
	ErrNameRepresentation  = fmt.Errorf("name: representation is outside the closed vocabulary")
	ErrNamePeriod          = fmt.Errorf("name: period end precedes period start")
	ErrPartsNotInText      = fmt.Errorf("name: a decomposed part is absent from text")
	ErrEmptyNameText       = fmt.Errorf("name: text is empty")
	ErrDocumentFieldLength = fmt.Errorf("name: a document field exceeds its stated bound")
	ErrMRZLineLength       = fmt.Errorf("name: an MRZ line exceeds its stated bound")
	ErrMRZCharset          = fmt.Errorf("name: an MRZ line contains a character outside A-Z, 0-9, <")
	ErrDocumentType        = fmt.Errorf("name: document type exceeds its stated bound")
	ErrIssuingCountry      = fmt.Errorf("name: issuing country is not a lowercase ISO 3166-1 alpha-2 code")
	ErrScriptCode          = fmt.Errorf("name: script code is not a 4-letter ISO 15924 code")
	ErrDocumentSource      = fmt.Errorf("name: source is outside the closed vocabulary")
)

// Bounds, explicit and generous, with the reasoning decision 020
// requires living at the schema site. "No length cap" was never an
// implementable instruction; these numbers are the implementable form
// of "well above any documented real-world name."
const (
	// MaxNameTextRunes: the same bound as person_record's display name
	// (MaxDisplayNameRunes), for the same reason: documented real names
	// run to a few hundred characters, and no genuine name meets 300.
	MaxNameTextRunes = 300
	// MaxNamePartRunes: one decomposed token, a family name or a single
	// given/prefix/suffix entry. Shorter than the whole-text bound
	// because a token is one component, not the rendered name, and 100
	// runes is generous for any single documented component.
	MaxNamePartRunes = 100
	// MaxGivenNames: cultures with several simultaneous given names
	// (Spanish, Arabic, some Southeast Asian naming) are documented; ten
	// is generous headroom above the longest observed case.
	MaxGivenNames = 10
	// MaxDocumentFieldRunes: ICAO VIZ-derived free text (primary and
	// secondary identifier, the native-script and Latin raw strings).
	// Bounded above the MRZ's own 39-character name field, since the VIZ
	// routinely carries more than the MRZ can hold.
	MaxDocumentFieldRunes = 200
	// MaxMRZLineLength: TD3 (passport) allocates 44 characters to a full
	// MRZ line; TD1 (ID card) allocates 30. One bound at the larger
	// covers both formats without guessing which one produced a line.
	MaxMRZLineLength = 44
)

// Use is FHIR HumanName's closed vocabulary for why a name is held
// (decision 013).
type Use string

const (
	UseUsual     Use = "usual"
	UseOfficial  Use = "official"
	UseOld       Use = "old"
	UseMaiden    Use = "maiden"
	UseNickname  Use = "nickname"
	UseAnonymous Use = "anonymous"
	UseTemp      Use = "temp"
)

// Representation is the CJK mechanism: which of the ideographic,
// romanized, or phonetic renderings this row carries. A person with a
// CJK name holds one person_name row per representation, same use,
// never one row trying to hold all three.
type Representation string

const (
	RepresentationIdeographic Representation = "IDE"
	RepresentationRomanized   Representation = "ABC"
	RepresentationPhonetic    Representation = "SYL"
)

// Relation distinguishes a person's own lineage surname from one taken
// through marriage. Part of Parts, the extension mechanism, never a core
// column (the task's own rule for "own-name vs partner-name").
type Relation string

const (
	RelationOwn     Relation = "own"
	RelationPartner Relation = "partner"
)

// Parts is the optional decomposition of a name. family, given, prefix
// and suffix are FHIR HumanName's own fields; fathers_family and
// mothers_family are the one mechanism that covers both the
// Spanish/Portuguese two-surname convention and the PhilSys maternal
// middle name, which is why the task requires them to share it rather
// than each getting a bespoke field. Marshaled as one JSON blob and
// sealed as one ciphertext (migration 0011-names): the parts are an
// extension of the name, not columns of their own.
type Parts struct {
	Family        string   `json:"family,omitempty"`
	Given         []string `json:"given,omitempty"`
	Prefix        []string `json:"prefix,omitempty"`
	Suffix        []string `json:"suffix,omitempty"`
	FathersFamily string   `json:"fathers_family,omitempty"`
	MothersFamily string   `json:"mothers_family,omitempty"`
	Relation      Relation `json:"relation,omitempty"`
}

// tokens returns every non-empty token in the parts, the set the
// text-contains-every-part invariant checks.
func (p *Parts) tokens() []string {
	if p == nil {
		return nil
	}
	out := make([]string, 0, 4+len(p.Given)+len(p.Prefix)+len(p.Suffix))
	add := func(s string) {
		if s != "" {
			out = append(out, s)
		}
	}
	add(p.Family)
	add(p.FathersFamily)
	add(p.MothersFamily)
	for _, g := range p.Given {
		add(g)
	}
	for _, pr := range p.Prefix {
		add(pr)
	}
	for _, s := range p.Suffix {
		add(s)
	}
	return out
}

func (p *Parts) validate() error {
	if p == nil {
		return nil
	}
	if len(p.Given) > MaxGivenNames {
		return ErrTooManyGivenNames
	}
	for _, tok := range p.tokens() {
		if utf8.RuneCountInString(tok) > MaxNamePartRunes {
			return ErrNamePartLength
		}
	}
	return nil
}

// Name is one person_name assertion (decision 013's worker-owned layer).
// ID is the row's outbox_entry_id once read back; empty on a Name being
// appended for the first time. Supersedes is the outbox_entry_id of the
// row this one replaced, empty for a name's first assertion; Append
// computes it, a caller never sets it. PeriodEnd, once read back, is the
// EFFECTIVE end date (person_name_effective, migration 0011-names): the
// source's own stated end if it had one, else derived from whichever row
// supersedes this one, else nil (this name is current). The underlying
// column a caller's own write touched is never itself updated; a row
// with a non-nil PeriodEnd here was end-dated by a later append, not by
// a write against it.
type Name struct {
	ID             string
	Text           string
	Parts          *Parts
	Use            Use
	Representation Representation
	Supersedes     string
	PeriodStart    *time.Time
	PeriodEnd      *time.Time
	AssertedAt     time.Time
}

// validate enforces the bounds and the text-contains-every-part
// invariant (the migration's own comment on person_name.text_ciphertext).
// Rejection is loud; nothing here truncates or repairs silently
// (decision 020).
func (n Name) validate() error {
	if n.Text == "" {
		return ErrEmptyNameText
	}
	if utf8.RuneCountInString(n.Text) > MaxNameTextRunes {
		return ErrNameTextLength
	}
	switch n.Use {
	case UseUsual, UseOfficial, UseOld, UseMaiden, UseNickname, UseAnonymous, UseTemp:
	default:
		return ErrNameUse
	}
	switch n.Representation {
	case RepresentationIdeographic, RepresentationRomanized, RepresentationPhonetic:
	default:
		return ErrNameRepresentation
	}
	if n.PeriodStart != nil && n.PeriodEnd != nil && n.PeriodEnd.Before(*n.PeriodStart) {
		return ErrNamePeriod
	}
	if err := n.Parts.validate(); err != nil {
		return err
	}
	for _, tok := range n.Parts.tokens() {
		if !strings.Contains(n.Text, tok) {
			return fmt.Errorf("%w: %q", ErrPartsNotInText, tok)
		}
	}
	return nil
}

// DocumentName is one immutable capture from a verified document, in
// ICAO Doc 9303's own vocabulary: primary_identifier / secondary_identifier,
// never first/last name, because a mononym is the spec's normal path
// and ICAO deliberately does not define what a surname is (per-issuer
// partition). ID is the row's outbox_entry_id once read back.
type DocumentName struct {
	ID                  string
	DocumentType        string
	IssuingCountry      string // lowercase ISO 3166-1 alpha-2
	ScriptCode          string // ISO 15924, e.g. "Latn", "Hani"
	Source              string // MRZ | VIZ | BARCODE | SELF_ATTESTED
	PrimaryIdentifier   string
	SecondaryIdentifier string
	IsMononym           bool
	NativeScriptName    string
	LatinNameRaw        string
	MRZLine1            string
	MRZLine2            string
	PossiblyTruncated   bool
	CapturedAt          time.Time
}

var (
	countryCodeShape = regexp.MustCompile(`^[a-z]{2}$`)
	scriptCodeShape  = regexp.MustCompile(`^[A-Z][a-z]{3}$`)
	mrzCharset       = regexp.MustCompile(`^[A-Z0-9<]*$`)
)

func (d DocumentName) validate() error {
	if len(d.DocumentType) == 0 || len(d.DocumentType) > 64 {
		return ErrDocumentType
	}
	if !countryCodeShape.MatchString(d.IssuingCountry) {
		return ErrIssuingCountry
	}
	if !scriptCodeShape.MatchString(d.ScriptCode) {
		return ErrScriptCode
	}
	switch d.Source {
	case "MRZ", "VIZ", "BARCODE", "SELF_ATTESTED":
	default:
		return ErrDocumentSource
	}
	for _, field := range []string{d.PrimaryIdentifier, d.SecondaryIdentifier, d.NativeScriptName, d.LatinNameRaw} {
		if utf8.RuneCountInString(field) > MaxDocumentFieldRunes {
			return ErrDocumentFieldLength
		}
	}
	for _, line := range []string{d.MRZLine1, d.MRZLine2} {
		if line == "" {
			continue
		}
		if len(line) > MaxMRZLineLength {
			return ErrMRZLineLength
		}
		if !mrzCharset.MatchString(line) {
			return ErrMRZCharset
		}
	}
	return nil
}

// MRZName is the result of splitting one MRZ name field into ICAO's
// primary and secondary identifiers. IsMononym is the field's own
// asserted state: only true when the field carries no "<<" separator at
// all, ICAO's normal encoding for a single-identifier name. SeparatorPresent
// distinguishes the shape that produced an empty Secondary from the one
// that produced no Secondary in the first place: false means the field
// had no "<<" anywhere (the canonical mononym encoding this task names);
// true with an empty Secondary means the field DID carry the separator,
// followed by nothing but pad (an issuer explicitly asserting an empty
// secondary identifier, a different fact from "there was no separator").
// document_name.is_mononym exists to record which state a row asserts
// rather than infer it from a null secondary_identifier (the migration's
// own reasoning); collapsing these two shapes into one IsMononym value
// with no way to tell them apart would be exactly that inference, one
// layer up. A caller that cares about the distinction reads
// SeparatorPresent; one that only needs "is this a mononym for
// rendering purposes" reads IsMononym, which is true in both shapes,
// since both are, structurally, one identifier.
type MRZName struct {
	Primary          string
	Secondary        string
	IsMononym        bool
	SeparatorPresent bool
}

// ParseMRZName implements ICAO Doc 9303's own separator, "<<", and only
// that separator, for the primary/secondary boundary. This is the
// mononym parsing trap the task names: three of six major IDV vendors
// corrupt a mononym MRZ (no "<<" anywhere, e.g. "SATRIYA<SUDARPA")
// because their parser treats every "<" as a splittable boundary and
// assigns the whole field to a surname with an empty given name. Here, a
// field with no "<<" is the mononym's normal path: the entire field
// becomes the primary identifier, its internal "<" characters become
// spaces (ICAO's own word-filler convention), and nothing is assigned
// away from it.
func ParseMRZName(field string) MRZName {
	if i := strings.Index(field, "<<"); i >= 0 {
		primary := mrzWords(field[:i])
		secondary := mrzWords(field[i+2:])
		return MRZName{
			Primary: primary, Secondary: secondary,
			IsMononym: secondary == "", SeparatorPresent: true,
		}
	}
	return MRZName{Primary: mrzWords(field), IsMononym: true, SeparatorPresent: false}
}

// mrzWords strips one identifier's trailing pad and turns its internal
// "<" filler into spaces, the two-word mononym case ("SATRIYA SUDARPA")
// included.
func mrzWords(s string) string {
	return strings.ReplaceAll(strings.TrimRight(s, "<"), "<", " ")
}

// PossiblyTruncated implements the ICAO truncation signal exactly as
// documented: ambiguous by design. An alphabetic character occupying the
// last position of a full-width MRZ line MAY mean the name was cut to
// fit the field, and is indistinguishable from a name that exactly fills
// it. A line shorter than the field's own width cannot have been
// truncated by that field. This function answers the question ICAO
// leaves open by recording the honest "maybe" rather than picking a
// side; core/person never treats the MRZ as authoritative over the VIZ
// on the strength of this flag or its absence.
func PossiblyTruncated(mrzLine string) bool {
	if len(mrzLine) != MaxMRZLineLength {
		return false
	}
	last := mrzLine[len(mrzLine)-1]
	return last >= 'A' && last <= 'Z'
}

// diacriticFold maps common precomposed Latin diacritics to their base
// letter. Hand-rolled rather than drawn from a Unicode normalization
// library: this module holds no dependency, and the standard library
// ships none. The table is deliberately not exhaustive; a rune it does
// not know passes through unchanged, which is correct for a non-Latin
// script (never phonetic-hash one, the task's own rule) rather than a
// gap to fill in later.
var diacriticFold = map[rune]rune{
	'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A', 'Ą': 'A',
	'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ą': 'a',
	'Ç': 'C', 'Ć': 'C', 'Č': 'C', 'ç': 'c', 'ć': 'c', 'č': 'c',
	'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', 'Ę': 'E',
	'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ę': 'e',
	'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
	'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
	'Ñ': 'N', 'Ń': 'N', 'ñ': 'n', 'ń': 'n',
	'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O', 'Ø': 'O',
	'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o',
	'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
	'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
	'Ý': 'Y', 'ý': 'y', 'ÿ': 'y',
	'Ł': 'L', 'ł': 'l', 'Ś': 'S', 'ś': 's', 'Š': 'S', 'š': 's',
	'Ź': 'Z', 'ź': 'z', 'Ż': 'Z', 'ż': 'z', 'Ž': 'Z', 'ž': 'z',
}

// foldDiacritics returns text with every precomposed diacritic this
// table knows folded to its base letter.
func foldDiacritics(s string) string {
	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		if folded, ok := diacriticFold[r]; ok {
			b.WriteRune(folded)
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// IndexGeneratorVersion is stamped on every name_index_entry row this
// package writes, so a later change to GenerateIndexTokens is
// reconstructable against rows a prior version produced.
const IndexGeneratorVersion = 1

// IndexToken is one candidate token GenerateIndexTokens derives from one
// source string.
type IndexToken struct {
	Kind  string // "original" | "diacritic_folded"
	Value string
}

// GenerateIndexTokens is the regenerable derivation decision 013
// requires: the original token is stored ALONGSIDE any transliteration,
// never replaced by one, and no phonetic hashing runs on any input,
// Latin or otherwise. The same input always yields the same output,
// which is what "dropping and regenerating name_index reproduces it
// exactly" means as a property of this function rather than of any
// database state.
func GenerateIndexTokens(text string) []IndexToken {
	text = strings.TrimSpace(text)
	if text == "" {
		return nil
	}
	tokens := []IndexToken{{Kind: "original", Value: text}}
	if folded := foldDiacritics(text); folded != text {
		tokens = append(tokens, IndexToken{Kind: "diacritic_folded", Value: folded})
	}
	return tokens
}

// DerivedToken is one index token traced back to the source row it came
// from, the shape both DeriveIndexTokens (computed fresh from
// person_name/document_name) and StoredIndexTokens (read back from
// name_index_entry) return, so the two can be compared directly.
type DerivedToken struct {
	SourceTable         string // "person_name" | "document_name"
	SourceOutboxEntryID string
	Kind                string
	Value               string
}

// Cipher seals and opens content under a person's own DEK. Satisfied by
// *envelope.Envelope. Distinct from Sealer (Provision + Encrypt only,
// person.go): the name model reads its own writes back, for current-name
// rendering and index regeneration, which Signup never needs to do.
type Cipher interface {
	Encrypt(ctx context.Context, person string, plaintext []byte) ([]byte, error)
	Decrypt(ctx context.Context, person string, ciphertext []byte) ([]byte, error)
}

// Names is the name model's service (person-identity/04).
type Names struct {
	cipher Cipher
}

// NewNames binds the seal path. Reached through core/transport for
// every statement, same as Service.
func NewNames(cipher Cipher) *Names { return &Names{cipher: cipher} }

// Append writes one person_name assertion. It never mutates a prior row:
// before sealing anything, it looks up whichever row is currently
// current for (personID, n.Use, n.Representation) and, if one exists,
// names it in the new row's own supersedes_outbox_entry_id. That single
// column, on the row being appended, is the entire end-dating mechanism
// (migration 0011-names, person_name_effective): the prior row's own
// columns are never touched, and its effective period_end derives, at
// read time, from the new row naming it rather than from anything
// written to it. A prior name is never deleted or edited, so it remains
// queryable for matching (AllNames, which reads the effective view and
// carries every row's derived period) while the query layer alone
// withholds it from an employer-facing read (CurrentNames, effective
// period_end IS NULL).
//
// The lookup and the append are not one transaction (core/outbox has no
// read-then-write primitive; every write is its own spine transaction),
// so two concurrent Appends for the same (person, use, representation)
// can both read "no current row yet" and both write with
// supersedes_outbox_entry_id NULL. The table's UNIQUE constraint on that
// column stops a row from being claimed as superseded twice, not from
// this race; the ordinary single-writer path this repo's other append-only
// tables assume is what's being followed here too.
func (nm *Names) Append(ctx context.Context, personID string, n Name) error {
	if err := ValidID(personID); err != nil {
		return err
	}
	if err := n.validate(); err != nil {
		return err
	}
	supersedes, err := nm.currentEntryID(ctx, personID, n.Use, n.Representation)
	if err != nil {
		return fmt.Errorf("name: looking up the name to supersede: %w", err)
	}
	textCipher, err := nm.cipher.Encrypt(ctx, personID, []byte(n.Text))
	if err != nil {
		return fmt.Errorf("name: sealing text: %w", err)
	}
	row := map[string]any{
		"person_id":                  personID,
		"text_ciphertext":            hexLiteral(textCipher),
		"parts_ciphertext":           nil,
		"use":                        string(n.Use),
		"representation":             string(n.Representation),
		"supersedes_outbox_entry_id": nil,
		"period_start":               nil,
		"period_end":                 nil,
	}
	if supersedes != "" {
		row["supersedes_outbox_entry_id"] = supersedes
	}
	if n.Parts != nil {
		raw, err := json.Marshal(n.Parts)
		if err != nil {
			return fmt.Errorf("name: encoding parts: %w", err)
		}
		partsCipher, err := nm.cipher.Encrypt(ctx, personID, raw)
		if err != nil {
			return fmt.Errorf("name: sealing parts: %w", err)
		}
		row["parts_ciphertext"] = hexLiteral(partsCipher)
	}
	if n.PeriodStart != nil {
		row["period_start"] = n.PeriodStart.UTC().Format(time.RFC3339Nano)
	}
	if n.PeriodEnd != nil {
		row["period_end"] = n.PeriodEnd.UTC().Format(time.RFC3339Nano)
	}
	return enqueueRow(personID, "person_name", row)
}

// currentEntryID returns the outbox_entry_id of whichever person_name
// row is currently current for (use, representation), or "" if this is
// the name's first assertion. This is Append's read half of end-dating:
// whatever it returns becomes the new row's supersedes_outbox_entry_id.
func (nm *Names) currentEntryID(ctx context.Context, personID string, use Use, representation Representation) (string, error) {
	lines, err := transport.Query(namesPlane, servingRole, `
		SELECT outbox_entry_id FROM person_name_current
		 WHERE person_id = $1 AND "use" = $2 AND representation = $3`,
		transport.String(personID), transport.String(string(use)), transport.String(string(representation)))
	if err != nil {
		return "", err
	}
	if len(lines) == 0 {
		return "", nil
	}
	return lines[0], nil
}

// AppendDocumentName writes one immutable document capture. Both the MRZ
// and the VIZ are retained verbatim: no vendor documents a precedence
// rule between them, and core/person picks none.
func (nm *Names) AppendDocumentName(ctx context.Context, personID string, d DocumentName) error {
	if err := ValidID(personID); err != nil {
		return err
	}
	if err := d.validate(); err != nil {
		return err
	}
	fields := documentFields{
		PrimaryIdentifier:   d.PrimaryIdentifier,
		SecondaryIdentifier: d.SecondaryIdentifier,
		NativeScriptName:    d.NativeScriptName,
		LatinNameRaw:        d.LatinNameRaw,
		MRZLine1:            d.MRZLine1,
		MRZLine2:            d.MRZLine2,
	}
	raw, err := json.Marshal(fields)
	if err != nil {
		return fmt.Errorf("name: encoding document fields: %w", err)
	}
	sealed, err := nm.cipher.Encrypt(ctx, personID, raw)
	if err != nil {
		return fmt.Errorf("name: sealing document fields: %w", err)
	}
	row := map[string]any{
		"person_id":          personID,
		"document_type":      d.DocumentType,
		"issuing_country":    d.IssuingCountry,
		"script_code":        d.ScriptCode,
		"source":             d.Source,
		"is_mononym":         d.IsMononym,
		"possibly_truncated": d.PossiblyTruncated,
		"name_ciphertext":    hexLiteral(sealed),
	}
	return enqueueRow(personID, "document_name", row)
}

// documentFields is the sealed blob behind document_name.name_ciphertext.
type documentFields struct {
	PrimaryIdentifier   string `json:"primary_identifier"`
	SecondaryIdentifier string `json:"secondary_identifier,omitempty"`
	NativeScriptName    string `json:"native_script_name,omitempty"`
	LatinNameRaw        string `json:"latin_name_raw,omitempty"`
	MRZLine1            string `json:"mrz_line_1,omitempty"`
	MRZLine2            string `json:"mrz_line_2,omitempty"`
}

// enqueueRow renders one outbox instruction for table/row and enqueues
// it through core/outbox, the same idempotent spine-first path every
// post-signup payload write in this repo uses.
func enqueueRow(personID, table string, row map[string]any) error {
	instruction := outbox.Instruction{Table: table, Row: row}
	raw, err := json.Marshal(instruction)
	if err != nil {
		return fmt.Errorf("name: encoding instruction: %w", err)
	}
	if _, err := outbox.Parse(raw); err != nil {
		return err
	}
	entryID, err := NewID()
	if err != nil {
		return err
	}
	if err := outbox.Enqueue(entryID, raw, ""); err != nil {
		return fmt.Errorf("name: enqueuing %s: %w", table, err)
	}
	return nil
}

const namesPlane = "payload"

// CurrentNames reads the employer-safe view: one row per (person_id,
// use, representation) triple, whichever row nothing has superseded
// (person_name_current, effective period_end IS NULL). A prior name
// never appears here, which is the query-layer withholding the task
// requires (gender transition, marriage), enforced by which view this
// function reads rather than by anything a caller must remember.
func (nm *Names) CurrentNames(ctx context.Context, personID string) ([]Name, error) {
	return nm.queryNames(ctx, personID, "person_name_current")
}

// AllNames reads every asserted name, prior ones included, through
// person_name_effective so each row's PeriodEnd carries its derived
// value: nil for a row nothing supersedes, the superseding row's
// asserted_at otherwise. Matching (person-identity/05) reads through
// here; an employer-facing surface never should.
func (nm *Names) AllNames(ctx context.Context, personID string) ([]Name, error) {
	return nm.queryNames(ctx, personID, "person_name_effective")
}

// RenderFor is CurrentNames narrowed to one use and one representation:
// the CJK case stated as a call, since a CJK person's ideographic,
// romanized, and phonetic entries all sit in CurrentNames at once and a
// caller renders one of them "per purpose" by naming which. Returns
// false if no current row matches.
func (nm *Names) RenderFor(ctx context.Context, personID string, use Use, representation Representation) (Name, bool, error) {
	names, err := nm.CurrentNames(ctx, personID)
	if err != nil {
		return Name{}, false, err
	}
	for _, n := range names {
		if n.Use == use && n.Representation == representation {
			return n, true, nil
		}
	}
	return Name{}, false, nil
}

func (nm *Names) queryNames(ctx context.Context, personID, table string) ([]Name, error) {
	if err := ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(namesPlane, servingRole, fmt.Sprintf(`
		SELECT outbox_entry_id, encode(text_ciphertext, 'hex'),
		       coalesce(encode(parts_ciphertext, 'hex'), ''),
		       "use", representation, coalesce(supersedes_outbox_entry_id::text, ''),
		       coalesce(period_start::text, ''), coalesce(period_end::text, ''),
		       asserted_at
		  FROM %s WHERE person_id = $1 ORDER BY asserted_at`, table),
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	names := make([]Name, 0, len(lines))
	for _, line := range lines {
		f := transport.SplitRow(line, 9)
		id := f[0]
		text, err := nm.openHex(ctx, personID, f[1])
		if err != nil {
			return nil, err
		}
		var parts *Parts
		if f[2] != "" {
			raw, err := nm.openHex(ctx, personID, f[2])
			if err != nil {
				return nil, err
			}
			parts = &Parts{}
			if err := json.Unmarshal(raw, parts); err != nil {
				return nil, fmt.Errorf("name: decoding parts: %w", err)
			}
		}
		n := Name{
			ID:             id,
			Text:           string(text),
			Parts:          parts,
			Use:            Use(f[3]),
			Representation: Representation(f[4]),
			Supersedes:     f[5],
		}
		if f[6] != "" {
			t, err := time.Parse("2006-01-02 15:04:05.999999-07", f[6])
			if err == nil {
				n.PeriodStart = &t
			}
		}
		if f[7] != "" {
			t, err := time.Parse("2006-01-02 15:04:05.999999-07", f[7])
			if err == nil {
				n.PeriodEnd = &t
			}
		}
		if t, err := time.Parse("2006-01-02 15:04:05.999999-07", f[8]); err == nil {
			n.AssertedAt = t
		}
		names = append(names, n)
	}
	return names, nil
}

// DocumentNames reads every document capture for a person, oldest first.
func (nm *Names) DocumentNames(ctx context.Context, personID string) ([]DocumentName, error) {
	if err := ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(namesPlane, servingRole, `
		SELECT outbox_entry_id, document_type, issuing_country, script_code,
		       source, is_mononym, possibly_truncated,
		       encode(name_ciphertext, 'hex'), captured_at
		  FROM document_name WHERE person_id = $1 ORDER BY captured_at`,
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	docs := make([]DocumentName, 0, len(lines))
	for _, line := range lines {
		f := transport.SplitRow(line, 9)
		raw, err := nm.openHex(ctx, personID, f[7])
		if err != nil {
			return nil, err
		}
		var fields documentFields
		if err := json.Unmarshal(raw, &fields); err != nil {
			return nil, fmt.Errorf("name: decoding document fields: %w", err)
		}
		d := DocumentName{
			ID:                  f[0],
			DocumentType:        f[1],
			IssuingCountry:      f[2],
			ScriptCode:          f[3],
			Source:              f[4],
			IsMononym:           f[5] == "t",
			PossiblyTruncated:   f[6] == "t",
			PrimaryIdentifier:   fields.PrimaryIdentifier,
			SecondaryIdentifier: fields.SecondaryIdentifier,
			NativeScriptName:    fields.NativeScriptName,
			LatinNameRaw:        fields.LatinNameRaw,
			MRZLine1:            fields.MRZLine1,
			MRZLine2:            fields.MRZLine2,
		}
		if t, err := time.Parse("2006-01-02 15:04:05.999999-07", f[8]); err == nil {
			d.CapturedAt = t
		}
		docs = append(docs, d)
	}
	return docs, nil
}

// openHex decrypts a hex-encoded ciphertext column.
func (nm *Names) openHex(ctx context.Context, personID, encoded string) ([]byte, error) {
	raw, err := hex.DecodeString(encoded)
	if err != nil {
		return nil, fmt.Errorf("name: decoding stored ciphertext: %w", err)
	}
	opened, err := nm.cipher.Decrypt(ctx, personID, raw)
	if err != nil {
		return nil, fmt.Errorf("name: opening stored ciphertext: %w", err)
	}
	return opened, nil
}

// DeriveIndexTokens computes the index fresh from every current source
// row: every person_name.Text and every document_name identifier field
// (primary, secondary, native-script, and Latin-raw), so a same-script
// match (a CJK passport's native-script capture against another CJK
// document) has a token to key on, not only the Latin-transliterated
// fields. Calling this twice against unchanged source rows returns the
// same set both times, which is the regeneration property the task's
// mechanical criterion asks for.
func (nm *Names) DeriveIndexTokens(ctx context.Context, personID string) ([]DerivedToken, error) {
	names, err := nm.AllNames(ctx, personID)
	if err != nil {
		return nil, err
	}
	docs, err := nm.DocumentNames(ctx, personID)
	if err != nil {
		return nil, err
	}
	var out []DerivedToken
	for _, n := range names {
		for _, tok := range GenerateIndexTokens(n.Text) {
			out = append(out, DerivedToken{
				SourceTable: "person_name", SourceOutboxEntryID: n.ID,
				Kind: tok.Kind, Value: tok.Value,
			})
		}
	}
	for _, d := range docs {
		for _, field := range []string{d.PrimaryIdentifier, d.SecondaryIdentifier, d.NativeScriptName, d.LatinNameRaw} {
			for _, tok := range GenerateIndexTokens(field) {
				out = append(out, DerivedToken{
					SourceTable: "document_name", SourceOutboxEntryID: d.ID,
					Kind: tok.Kind, Value: tok.Value,
				})
			}
		}
	}
	return out, nil
}

// WriteIndex derives the index fresh (DeriveIndexTokens) and persists
// every token as its own name_index_entry row, sealed under the
// person's own key. name_index_entry is append-only like every other
// table this migration adds; nothing here deletes a prior generation's
// rows; a caller comparing generator versions is how a future consumer
// tells old rows from new ones apart.
func (nm *Names) WriteIndex(ctx context.Context, personID string) error {
	tokens, err := nm.DeriveIndexTokens(ctx, personID)
	if err != nil {
		return err
	}
	for _, tok := range tokens {
		sealed, err := nm.cipher.Encrypt(ctx, personID, []byte(tok.Value))
		if err != nil {
			return fmt.Errorf("name: sealing index token: %w", err)
		}
		row := map[string]any{
			"person_id":              personID,
			"source_table":           tok.SourceTable,
			"source_outbox_entry_id": tok.SourceOutboxEntryID,
			"token_kind":             tok.Kind,
			"generator_version":      float64(IndexGeneratorVersion),
			"token_ciphertext":       hexLiteral(sealed),
		}
		if err := enqueueRow(personID, "name_index_entry", row); err != nil {
			return err
		}
	}
	return nil
}

// StoredIndexTokens reads back every persisted name_index_entry row,
// decrypted, in the same shape DeriveIndexTokens returns, so a caller
// can prove the two agree: dropping and regenerating reproduces the
// index exactly.
func (nm *Names) StoredIndexTokens(ctx context.Context, personID string) ([]DerivedToken, error) {
	if err := ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(namesPlane, servingRole, `
		SELECT source_table, source_outbox_entry_id, token_kind,
		       encode(token_ciphertext, 'hex')
		  FROM name_index_entry WHERE person_id = $1`,
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	out := make([]DerivedToken, 0, len(lines))
	for _, line := range lines {
		f := transport.SplitRow(line, 4)
		value, err := nm.openHex(ctx, personID, f[3])
		if err != nil {
			return nil, err
		}
		out = append(out, DerivedToken{
			SourceTable: f[0], SourceOutboxEntryID: f[1], Kind: f[2], Value: string(value),
		})
	}
	return out, nil
}
