// Package person is signup and id issuance (person-identity/01,
// decisions 013, 017, 075): one verified contact channel in, an opaque
// permanent ledger person id out.
//
// What "instantly" means here, stated once because the word was hiding
// three different claims (decision 020):
//
//	The id is issued and returned at SPINE COMMIT. The person row, its
//	'active' lifecycle transition, and the outbox entries carrying the
//	payload half all commit in one spine transaction, and that commit is
//	when the account exists. The payload rows follow through the outbox
//	worker (core/outbox). The account is usable immediately; anything
//	that needs payload waits on the acknowledgment watermark, which is
//	the cross_plane_acknowledged view and not a callback.
//
// There is no shared transaction across the planes (decision 011), so
// this is the only honest ordering: spine first, retry forward, never a
// compensating write into an append-only ledger.
//
// Content never reaches the payload plane in the clear. A channel
// address and a display name are sealed under the person's own DEK
// (core/envelope) before they enter an outbox instruction, so the
// spine's append-only residue of the instruction dies with the key when
// the person is deleted. That is migration 0020's write-site rule, and
// this package is its first real caller.
//
// The minimum to hold an identity is one verified contact channel. No
// name, no date of birth, nothing else (decision 013). Request is shaped
// so that is visible in the type: everything except the email channel is
// a pointer or a zero value.
package person

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/hiregrain/identity/core/outbox"
)

// Errors. Every one names a rule a caller can fix; none carries an
// address, a name, or key material.
var (
	ErrNoVerifiedChannel = errors.New("person: signup requires one verified contact channel")
	ErrChannelKind       = errors.New("person: channel kind must be email or phone")
	ErrAddressShape      = errors.New("person: channel address is not a well-formed address for its kind")
	ErrAddressTooLong    = errors.New("person: channel address exceeds its stated bound")
	ErrDisplayNameLength = errors.New("person: display name exceeds its stated bound")
	ErrRiskSignal        = errors.New("person: risk signal is outside its closed vocabulary")
	ErrInvalidPersonID   = errors.New("person: person id is not a lowercase uuid")
)

// ChannelKind is the closed vocabulary of contact channels. Email is
// primary and phone is optional; neither is ever an identity anchor
// (decision 013: channel possession buys almost no uniqueness).
type ChannelKind string

const (
	KindEmail ChannelKind = "email"
	KindPhone ChannelKind = "phone"
)

// Line types. Email channels carry LineEmail so the column has one
// meaning for every row; a telephone line carries what the lookup
// returned, and "unknown" is an honest answer rather than a gap.
const (
	LineEmail    = "email"
	LineMobile   = "mobile"
	LineLandline = "landline"
	LineVOIP     = "voip"
	LineUnknown  = "unknown"
)

// Carrier reputation values. A fact about a telephone carrier, never a
// judgment about a person (checks/scored-columns.mjs draws that line).
const (
	CarrierUnknown = "unknown"
	CarrierClear   = "clear"
	CarrierFlagged = "flagged"
)

// Assurance values. AssuranceChannelControl says exactly what was
// proven: somebody controlled this channel at that moment.
// AssurancePHSIMRegistered is decision 013's recorded exception: a
// Philippine SIM is bound to a government ID under RA 11934, so a
// verified PH mobile is a higher-assurance signal and is recorded as
// one instead of being flattened into "a phone was verified".
const (
	AssuranceChannelControl  = "channel-control"
	AssurancePHSIMRegistered = "ph-sim-registered"
)

// DefaultVelocityThreshold is the signups-per-window count above which a
// channel is worth a second look. v1 records the signals and the
// threshold in force; what to do at the threshold is the anti-fraud
// work, and no decisions entry rules a number, so this is a stated
// default rather than a policy. It is written to every channel row so a
// later escalation policy can be reasoned about against accounts that
// predate it.
const DefaultVelocityThreshold = 5

// Bounds, with their reasoning, on worker-submittable free text
// (decision 020: "no length cap" is not an implementable instruction,
// and over-length input is rejected loudly, never truncated silently).
const (
	// MaxAddressLength: RFC 5321 caps a forward path at 254 octets, and
	// E.164 caps a subscriber number at 15 digits plus a leading '+'.
	// One bound covers both at the larger of the two.
	MaxAddressLength = 254
	// MaxDisplayNameRunes: runes rather than bytes, since a bound in
	// bytes is a bound on alphabet. Set well above the longest
	// documented personal names, which run to a few hundred characters,
	// so no real name meets it. The full name model with its own bounds
	// is person-identity/04.
	MaxDisplayNameRunes = 300
)

// RiskSignals is the channel risk scoring hook at signup: the real
// anti-Sybil control (decision 013). v1 records what was observed and
// the threshold in force. Nothing here judges the person.
type RiskSignals struct {
	// LineType is the line-type lookup result. VOIP is the signal that
	// matters most, since it is the cheap end of the SMS-PVA market.
	LineType string
	// Country is the line's ISO 3166-1 alpha-2 code, lowercase, for a
	// phone channel. Empty for email.
	Country string
	// CarrierReputation is the carrier-level lookup result.
	CarrierReputation string
	// VelocityObserved is how many signups this channel's bucket was
	// seen in the observation window. The caller measures it; this
	// package records it.
	VelocityObserved int
	// VelocityThreshold is the threshold in force at signup. Zero means
	// DefaultVelocityThreshold.
	VelocityThreshold int
}

// Channel is one contact channel with proof of control already in hand.
// VerifiedAt is not optional: an unverified channel has no row to sit in
// (migration 0010-person-core), so "verified control of one channel"
// is enforced by the schema rather than promised by a comment. What
// produces the proof, one-time codes and their rate limits, is
// person-identity/02's.
type Channel struct {
	Kind       ChannelKind
	Address    string
	VerifiedAt time.Time
	Risk       RiskSignals
}

// Request is everything signup accepts. Email is the one required
// field; a request with nothing else set is a complete request, which
// is the criterion stated as a type.
type Request struct {
	Email       Channel
	Phone       *Channel
	DisplayName string
}

// Spine executes statements against the spine plane as the serving role
// (identity_app: SELECT and INSERT, migration 0002, which is the whole
// vocabulary this package needs). Script runs a multi-statement script,
// which is how the person row, its lifecycle transition, and the outbox
// entries reach one transaction. Rows returns tuples-only lines.
//
// Implementations transmit statements as given. Every value this
// package interpolates is validated first: a uuid, a member of a closed
// vocabulary, a hex-encoded ciphertext, an RFC 3339 timestamp, or a
// decimal integer. The database transport that will own this seam is
// trust-kernel/08; until it lands, the local implementation is psql
// through docker compose, matching core/outbox and core/envelope.
type Spine interface {
	Script(ctx context.Context, sql string) error
	Rows(ctx context.Context, query string) ([]string, error)
}

// Sealer seals worker content under the person's own DEK. Satisfied by
// *envelope.Envelope (foundation/05). Provision registers the person's
// key; Encrypt seals under it. Nothing in this package holds payload
// content in the clear past the call that seals it.
type Sealer interface {
	Provision(ctx context.Context, person string) error
	Encrypt(ctx context.Context, person string, plaintext []byte) ([]byte, error)
}

// Service issues identities.
type Service struct {
	spine  Spine
	sealer Sealer
}

// New binds the spine and the seal path.
func New(s Spine, sealer Sealer) *Service { return &Service{spine: s, sealer: sealer} }

var (
	uuidShape    = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`)
	emailShape   = regexp.MustCompile(`^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$`)
	phoneShape   = regexp.MustCompile(`^\+[1-9][0-9]{6,14}$`)
	countryShape = regexp.MustCompile(`^[a-z]{2}$`)
)

// NewID returns a fresh ledger person id: random UUIDv4 (decision 075).
// Not time-ordered, deliberately. A UUIDv7 or a ULID would carry
// enrollment order and volume inside a value that travels to every
// party that ever reads the record, and hash-prefixing answers the
// insert-locality objection without removing the readable timestamp.
// Locality is the price and it was paid on purpose.
//
// Reuse is impossible on both sides of the pair: this function reads
// only the system CSPRNG, so it cannot return a spent id by any input,
// and the person table's primary key refuses a second INSERT of one
// that was issued, because a person row is never deleted, tombstoned
// included (decision 013: spine signatures reference an id forever).
func NewID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", fmt.Errorf("person: id generation: %w", err)
	}
	b[6] = (b[6] & 0x0f) | 0x40 // version 4
	b[8] = (b[8] & 0x3f) | 0x80 // RFC 9562 variant
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}

// Assurance derives a channel's assurance marker. The rule is one
// sentence and it is publishable, which is what lets the ledger compute
// it without becoming a scorer:
//
//	A channel carries ph-sim-registered exactly when it is a mobile line
//	in the Philippines; every other channel carries channel-control.
//
// The database refuses the elevated marker on anything else (migration
// 0010-person-core), so a bug here cannot promote an account.
func Assurance(kind ChannelKind, r RiskSignals) string {
	if kind == KindPhone && r.LineType == LineMobile && r.Country == "ph" {
		return AssurancePHSIMRegistered
	}
	return AssuranceChannelControl
}

// normalize fills the signals a caller of an email-only signup never
// supplies. A zero RiskSignals must be a valid one, or "an email and
// nothing else" would be false in the type before it was false in the
// database.
func (c *Channel) normalize() {
	if c.Risk.LineType == "" {
		if c.Kind == KindEmail {
			c.Risk.LineType = LineEmail
		} else {
			c.Risk.LineType = LineUnknown
		}
	}
	if c.Risk.CarrierReputation == "" {
		c.Risk.CarrierReputation = CarrierUnknown
	}
	if c.Risk.VelocityThreshold == 0 {
		c.Risk.VelocityThreshold = DefaultVelocityThreshold
	}
}

// validate checks one channel. Rejection is loud and names the rule;
// nothing is silently repaired beyond the unset defaults normalize
// fills.
func (c Channel) validate() error {
	switch c.Kind {
	case KindEmail:
		if !emailShape.MatchString(c.Address) {
			return fmt.Errorf("%w: email", ErrAddressShape)
		}
		if c.Risk.LineType != LineEmail || c.Risk.Country != "" {
			return fmt.Errorf("%w: an email channel carries no telephone line metadata", ErrRiskSignal)
		}
	case KindPhone:
		if !phoneShape.MatchString(c.Address) {
			return fmt.Errorf("%w: phone must be E.164", ErrAddressShape)
		}
		switch c.Risk.LineType {
		case LineMobile, LineLandline, LineVOIP, LineUnknown:
		default:
			return fmt.Errorf("%w: line type %q", ErrRiskSignal, c.Risk.LineType)
		}
		if c.Risk.Country != "" && !countryShape.MatchString(c.Risk.Country) {
			return fmt.Errorf("%w: country %q is not a lowercase ISO 3166-1 alpha-2 code", ErrRiskSignal, c.Risk.Country)
		}
	default:
		return ErrChannelKind
	}
	if len(c.Address) > MaxAddressLength {
		return ErrAddressTooLong
	}
	if c.VerifiedAt.IsZero() {
		return ErrNoVerifiedChannel
	}
	switch c.Risk.CarrierReputation {
	case CarrierUnknown, CarrierClear, CarrierFlagged:
	default:
		return fmt.Errorf("%w: carrier reputation %q", ErrRiskSignal, c.Risk.CarrierReputation)
	}
	if c.Risk.VelocityObserved < 0 || c.Risk.VelocityThreshold < 1 {
		return fmt.Errorf("%w: velocity", ErrRiskSignal)
	}
	return nil
}

// prepare normalizes and validates the whole request.
func (r *Request) prepare() error {
	r.Email.Kind = KindEmail
	r.Email.normalize()
	if err := r.Email.validate(); err != nil {
		return err
	}
	if r.Phone != nil {
		r.Phone.Kind = KindPhone
		r.Phone.normalize()
		if err := r.Phone.validate(); err != nil {
			return err
		}
	}
	if utf8.RuneCountInString(r.DisplayName) > MaxDisplayNameRunes {
		return ErrDisplayNameLength
	}
	return nil
}

// Signup issues an identity and returns its id. The id is returned at
// spine commit; the payload rows follow through the outbox.
//
// Ordering, and why it is the only one available: the payload rows must
// travel as ciphertext inside the outbox instruction, so the person's
// DEK is provisioned and the content sealed before the spine
// transaction opens. A failure after provisioning and before the commit
// leaves a key registered for an id that was never issued and never
// returned. That key protects nothing, because no path can reach an
// unissued id, and the id itself is inert: random generation never
// returns it again and the person table never held it.
func (s *Service) Signup(ctx context.Context, req Request) (string, error) {
	if err := req.prepare(); err != nil {
		return "", err
	}
	id, err := NewID()
	if err != nil {
		return "", err
	}
	if err := s.sealer.Provision(ctx, id); err != nil {
		return "", fmt.Errorf("person: provisioning the person's key: %w", err)
	}

	var instructions []outbox.Instruction

	record := map[string]any{"person_id": id, "display_name_ciphertext": nil}
	if req.DisplayName != "" {
		sealed, err := s.sealer.Encrypt(ctx, id, []byte(req.DisplayName))
		if err != nil {
			return "", fmt.Errorf("person: sealing the display name: %w", err)
		}
		record["display_name_ciphertext"] = hexLiteral(sealed)
	}
	instructions = append(instructions, outbox.Instruction{Table: "person_record", Row: record})

	channels := []Channel{req.Email}
	if req.Phone != nil {
		channels = append(channels, *req.Phone)
	}
	for _, channel := range channels {
		row, err := s.channelRow(ctx, id, channel)
		if err != nil {
			return "", err
		}
		instructions = append(instructions, outbox.Instruction{Table: "person_contact_channel", Row: row})
	}

	script, err := issueScript(id, instructions)
	if err != nil {
		return "", err
	}
	if err := s.spine.Script(ctx, script); err != nil {
		return "", fmt.Errorf("person: issuing the id: %w", err)
	}
	return id, nil
}

// channelRow seals the address and renders one channel as an outbox row.
func (s *Service) channelRow(ctx context.Context, id string, c Channel) (map[string]any, error) {
	sealed, err := s.sealer.Encrypt(ctx, id, []byte(c.Address))
	if err != nil {
		return nil, fmt.Errorf("person: sealing a channel address: %w", err)
	}
	row := map[string]any{
		"person_id":          id,
		"channel_kind":       string(c.Kind),
		"address_ciphertext": hexLiteral(sealed),
		"verified_at":        c.VerifiedAt.UTC().Format(time.RFC3339Nano),
		"line_type":          c.Risk.LineType,
		"line_country":       nil,
		"carrier_reputation": c.Risk.CarrierReputation,
		"velocity_observed":  float64(c.Risk.VelocityObserved),
		"velocity_threshold": float64(c.Risk.VelocityThreshold),
		"assurance":          Assurance(c.Kind, c.Risk),
	}
	if c.Risk.Country != "" {
		row["line_country"] = c.Risk.Country
	}
	return row, nil
}

// Tombstone records the lifecycle transition that spends an id. It is
// write-once: the (person_id, state) key means a second call conflicts
// rather than overwriting, and no path anywhere removes the row.
// Destroying the person's content and their DEK is the deletion
// subsystem's (foundation/08); this marks the id.
func (s *Service) Tombstone(ctx context.Context, id string) error {
	if err := ValidID(id); err != nil {
		return err
	}
	return s.spine.Script(ctx, fmt.Sprintf(
		"INSERT INTO person_lifecycle_transition (person_id, state) VALUES ('%s', 'tombstoned');", id))
}

// Tombstoned reports whether an id is spent, read through the view that
// is the queryable form of that fact (migration 0010-person-core).
func (s *Service) Tombstoned(ctx context.Context, id string) (bool, error) {
	if err := ValidID(id); err != nil {
		return false, err
	}
	lines, err := s.spine.Rows(ctx, fmt.Sprintf(
		"SELECT 1 FROM person_tombstoned WHERE person_id = '%s'", id))
	if err != nil {
		return false, err
	}
	return len(lines) > 0, nil
}

// issueScript renders the one spine transaction that issues an id: the
// person row, its 'active' transition, and one outbox entry per payload
// row. Its COMMIT is the issuance event, which is what makes "instantly"
// a single claim.
func issueScript(id string, instructions []outbox.Instruction) (string, error) {
	if err := ValidID(id); err != nil {
		return "", err
	}
	var b strings.Builder
	b.WriteString("BEGIN;\n")
	fmt.Fprintf(&b, "INSERT INTO person (person_id) VALUES ('%s');\n", id)
	fmt.Fprintf(&b, "INSERT INTO person_lifecycle_transition (person_id, state) VALUES ('%s', 'active');\n", id)
	for _, instruction := range instructions {
		entryID, err := NewID()
		if err != nil {
			return "", err
		}
		raw, err := json.Marshal(instruction)
		if err != nil {
			return "", fmt.Errorf("person: encoding an instruction: %w", err)
		}
		// Parse is the same validation the worker applies on the way
		// out, run here so a malformed instruction fails at signup
		// rather than sitting undrainable in the outbox.
		if _, err := outbox.Parse(raw); err != nil {
			return "", err
		}
		fmt.Fprintf(&b,
			"INSERT INTO cross_plane_outbox (entry_id, target_plane, instruction)\n"+
				"VALUES ('%s', 'payload', decode('%s', 'base64'));\n",
			entryID, base64.StdEncoding.EncodeToString(raw))
	}
	b.WriteString("COMMIT;\n")
	return b.String(), nil
}

// ValidID gates every id this package interpolates into SQL, and pins
// the version and variant nibbles: an id that is not a UUIDv4 is not one
// of ours (decision 075).
func ValidID(id string) error {
	if !uuidShape.MatchString(id) {
		return fmt.Errorf("%w: %q", ErrInvalidPersonID, id)
	}
	return nil
}

// hexLiteral renders sealed bytes in Postgres bytea hex input form. It
// carries no quote or backslash-escape hazard, which is what lets a
// ciphertext ride an outbox instruction as an ordinary JSON string.
func hexLiteral(b []byte) string { return `\x` + hex.EncodeToString(b) }
