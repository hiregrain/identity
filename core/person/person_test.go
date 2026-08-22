// The database-free half of person-identity/01's proofs: id generation,
// the assurance rule, and the validation that keeps a malformed request
// out of the ledger. Run by `make go-check`, no Docker.
package person

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"sort"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/outbox"
)

func TestNewIDIsRandomVersion4(t *testing.T) {
	const batch = 50000
	seen := make(map[string]bool, batch)
	for i := 0; i < batch; i++ {
		id, err := NewID()
		if err != nil {
			t.Fatalf("id generation: %v", err)
		}
		if err := ValidID(id); err != nil {
			t.Fatalf("generated id fails its own gate: %v", err)
		}
		if seen[id] {
			t.Fatalf("id generation repeated %s", id)
		}
		seen[id] = true
	}
}

// A time-ordered id would sort by issuance. Decision 075 gave up insert
// locality precisely so it does not, and the property is cheap to state:
// ids generated in order do not arrive in order.
func TestIDsDoNotSortByIssuanceOrder(t *testing.T) {
	previous, err := NewID()
	if err != nil {
		t.Fatalf("id generation: %v", err)
	}
	descents := 0
	for i := 0; i < 1000; i++ {
		next, err := NewID()
		if err != nil {
			t.Fatalf("id generation: %v", err)
		}
		if next < previous {
			descents++
		}
		previous = next
	}
	if descents < 300 {
		t.Fatalf("ids look time-ordered: only %d of 1000 descended", descents)
	}
}

func TestValidIDRejectsWhatIsNotOurs(t *testing.T) {
	for _, id := range []string{
		"",
		"not-a-uuid",
		"00000000-0000-0000-0000-000000000000", // nil uuid, no version
		"018f3a2b-7c00-7000-8000-0123456789ab", // version 7
		"0123456789AB-0000-4000-8000-0123456789ab", // upper case, wrong shape
		"'; DROP TABLE person; --",                 // the reason the gate exists
		"0123456f-89ab-4cde-c012-3456789abcde",     // wrong variant nibble
	} {
		if err := ValidID(id); err == nil {
			t.Fatalf("ValidID accepted %q", id)
		}
	}
}

func TestAssuranceRule(t *testing.T) {
	cases := []struct {
		kind ChannelKind
		risk RiskSignals
		want string
	}{
		{KindPhone, RiskSignals{LineType: LineMobile, Country: "ph"}, AssurancePHSIMRegistered},
		{KindPhone, RiskSignals{LineType: LineMobile, Country: "us"}, AssuranceChannelControl},
		{KindPhone, RiskSignals{LineType: LineLandline, Country: "ph"}, AssuranceChannelControl},
		{KindPhone, RiskSignals{LineType: LineVOIP, Country: "ph"}, AssuranceChannelControl},
		{KindPhone, RiskSignals{LineType: LineUnknown, Country: "ph"}, AssuranceChannelControl},
		{KindEmail, RiskSignals{LineType: LineEmail}, AssuranceChannelControl},
	}
	for _, c := range cases {
		if got := Assurance(c.kind, c.risk); got != c.want {
			t.Fatalf("Assurance(%s, %+v) = %s, want %s", c.kind, c.risk, got, c.want)
		}
	}
}

// An email and nothing else is a complete request: the zero RiskSignals
// normalizes to a valid one rather than failing validation.
func TestEmailAloneIsACompleteRequest(t *testing.T) {
	req := Request{Email: Channel{Address: "worker@example.test", VerifiedAt: time.Now()}}
	if err := req.prepare(); err != nil {
		t.Fatalf("an email and nothing else was rejected: %v", err)
	}
	if req.Email.Risk.LineType != LineEmail ||
		req.Email.Risk.CarrierReputation != CarrierUnknown ||
		req.Email.Risk.VelocityThreshold != DefaultVelocityThreshold {
		t.Fatalf("normalized signals: %+v", req.Email.Risk)
	}
}

func TestRequestValidation(t *testing.T) {
	verified := time.Now()
	cases := []struct {
		name    string
		request Request
		want    error
	}{
		{
			"unverified email",
			Request{Email: Channel{Address: "worker@example.test"}},
			ErrNoVerifiedChannel,
		},
		{
			"malformed email",
			Request{Email: Channel{Address: "worker.example.test", VerifiedAt: verified}},
			ErrAddressShape,
		},
		{
			"over-length address",
			Request{Email: Channel{Address: strings.Repeat("a", 250) + "@example.test", VerifiedAt: verified}},
			ErrAddressTooLong,
		},
		{
			"over-length display name",
			Request{
				Email:       Channel{Address: "worker@example.test", VerifiedAt: verified},
				DisplayName: strings.Repeat("x", MaxDisplayNameRunes+1),
			},
			ErrDisplayNameLength,
		},
		{
			"phone that is not E.164",
			Request{
				Email: Channel{Address: "worker@example.test", VerifiedAt: verified},
				Phone: &Channel{Address: "0917 123 4567", VerifiedAt: verified},
			},
			ErrAddressShape,
		},
		{
			"unverified phone",
			Request{
				Email: Channel{Address: "worker@example.test", VerifiedAt: verified},
				Phone: &Channel{Address: "+639171234567"},
			},
			ErrNoVerifiedChannel,
		},
		{
			"line type outside the vocabulary",
			Request{
				Email: Channel{Address: "worker@example.test", VerifiedAt: verified},
				Phone: &Channel{
					Address:    "+639171234567",
					VerifiedAt: verified,
					Risk:       RiskSignals{LineType: "satellite"},
				},
			},
			ErrRiskSignal,
		},
		{
			"country that is not an alpha-2 code",
			Request{
				Email: Channel{Address: "worker@example.test", VerifiedAt: verified},
				Phone: &Channel{
					Address:    "+639171234567",
					VerifiedAt: verified,
					Risk:       RiskSignals{LineType: LineMobile, Country: "PHL"},
				},
			},
			ErrRiskSignal,
		},
	}
	for _, c := range cases {
		request := c.request
		err := request.prepare()
		if err == nil {
			t.Fatalf("%s: accepted", c.name)
		}
		if !strings.Contains(err.Error(), c.want.Error()) {
			t.Fatalf("%s: %v, want %v", c.name, err, c.want)
		}
	}
}

// A display name at the bound is accepted, so the rejection above is a
// bound and not a ban.
func TestDisplayNameAtTheBoundIsAccepted(t *testing.T) {
	req := Request{
		Email:       Channel{Address: "worker@example.test", VerifiedAt: time.Now()},
		DisplayName: strings.Repeat("\u4e2d", MaxDisplayNameRunes),
	}
	if err := req.prepare(); err != nil {
		t.Fatalf("a name at the bound was rejected: %v", err)
	}
}

// The issuance transaction's statements: the person row, the 'active'
// transition, and one outbox entry per payload row. If the person row
// ever left this transaction, "issued at spine commit" would stop being
// one claim. Every entry statement must be outbox.InsertStatement's
// output verbatim, not a lookalike this package composed: the two paths
// that write an outbox entry, signup and the worker's Enqueue, run one
// builder.
func TestIssueStatementsComeFromTheOutboxBuilder(t *testing.T) {
	id, err := NewID()
	if err != nil {
		t.Fatalf("id generation: %v", err)
	}
	entries := []entry{
		{ID: "11111111-1111-4111-8111-111111111111", Raw: []byte(`{"table":"person_record","row":{"a":1}}`)},
		{ID: "22222222-2222-4222-8222-222222222222", Raw: []byte(`{"table":"person_contact_channel","row":{"b":2}}`)},
	}
	statements, err := issueStatements(id, entries)
	if err != nil {
		t.Fatalf("issueStatements: %v", err)
	}
	if len(statements) != len(entries)+2 {
		t.Fatalf("statements: %d, want the person row, the transition, and one per entry", len(statements))
	}
	if want := "INSERT INTO person (person_id) VALUES ('" + id + "');"; statements[0] != want {
		t.Fatalf("person row statement:\n got  %q\n want %q", statements[0], want)
	}
	want := "INSERT INTO person_lifecycle_transition (person_id, state) VALUES ('" + id + "', 'active');"
	if statements[1] != want {
		t.Fatalf("transition statement:\n got  %q\n want %q", statements[1], want)
	}
	for i, e := range entries {
		built, err := outbox.InsertStatement(e.ID, e.Raw)
		if err != nil {
			t.Fatalf("InsertStatement: %v", err)
		}
		if statements[i+2] != built {
			t.Fatalf("entry statement %d is not the builder's:\n got  %q\n want %q",
				i, statements[i+2], built)
		}
	}
}

func TestIssueStatementsRefuseAnIDNotOurs(t *testing.T) {
	if _, err := issueStatements("'; DROP TABLE person; --", nil); err == nil {
		t.Fatal("issueStatements accepted an id that is not a uuid")
	}
}

// stubSealer records what it was asked to seal and hands back a
// deterministic ciphertext, so the instruction shape can be asserted
// with no database and no key provider.
type stubSealer struct {
	mu     sync.Mutex
	sealed []string
	fail   bool
}

func (s *stubSealer) Provision(context.Context, string) error { return nil }

// stubMacer stands in for the key provider behind the channel lookup
// index, deterministic and keyless, so the instruction shape can be
// asserted with no key provider. Nothing here proves anything about the
// index's cryptography; keys.Mac's own conformance suite does that.
type stubMacer struct{}

func (stubMacer) Mac(_ context.Context, scope string, message []byte) ([]byte, error) {
	return append([]byte("mac:"+scope+":"), message...), nil
}

// stubIndex is the index every no-database test in this file uses.
func stubIndex() *ChannelIndex { return NewChannelIndex(stubMacer{}) }

func (s *stubSealer) Encrypt(_ context.Context, _ string, plaintext []byte) ([]byte, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.fail {
		return nil, errors.New("stub sealer refused")
	}
	s.sealed = append(s.sealed, string(plaintext))
	return append([]byte("sealed:"), plaintext...), nil
}

// An email-only signup seals exactly the address, and the record row
// carries an explicit absent display name rather than an empty string.
// Nothing names residency_region: the region is the database's, and an
// instruction carrying it is refused by core/outbox.
func TestInstructionsForAnEmailAloneSignup(t *testing.T) {
	sealer := &stubSealer{}
	svc := New(sealer, stubIndex())
	req := Request{Email: Channel{Address: "worker@example.test", VerifiedAt: time.Now()}}
	if err := req.prepare(); err != nil {
		t.Fatalf("prepare: %v", err)
	}
	id, err := NewID()
	if err != nil {
		t.Fatalf("id generation: %v", err)
	}
	instructions, err := svc.instructions(context.Background(), id, req)
	if err != nil {
		t.Fatalf("instructions: %v", err)
	}
	if len(instructions) != 2 {
		t.Fatalf("instructions: %d, want the record row and one channel", len(instructions))
	}
	if len(sealer.sealed) != 1 || sealer.sealed[0] != "worker@example.test" {
		t.Fatalf("sealed: %v, want the address alone", sealer.sealed)
	}
	record := instructions[0]
	if record.Table != "person_record" || record.Row["display_name_ciphertext"] != nil {
		t.Fatalf("record instruction: %+v", record)
	}
	for _, instruction := range instructions {
		if _, present := instruction.Row["residency_region"]; present {
			t.Fatalf("%s names residency_region, which is the database's", instruction.Table)
		}
		raw, err := json.Marshal(instruction)
		if err != nil {
			t.Fatalf("marshal: %v", err)
		}
		if _, err := outbox.Parse(raw); err != nil {
			t.Fatalf("%s does not survive the worker's own validation: %v", instruction.Table, err)
		}
	}
	channel := instructions[1].Row
	if channel["address_ciphertext"] != `\x`+hex.EncodeToString([]byte("sealed:worker@example.test")) {
		t.Fatalf("address ciphertext: %v", channel["address_ciphertext"])
	}
	if channel["assurance"] != AssuranceChannelControl || channel["line_country"] != nil {
		t.Fatalf("channel row: %+v", channel)
	}
}

// A phone signup seals both addresses and the display name, and a
// failure in any concurrent seal aborts before anything is issued.
func TestInstructionsSealEveryValueAndAbortTogether(t *testing.T) {
	sealer := &stubSealer{}
	svc := New(sealer, stubIndex())
	req := Request{
		Email:       Channel{Address: "worker@example.test", VerifiedAt: time.Now()},
		Phone:       &Channel{Address: "+639171234567", VerifiedAt: time.Now()},
		DisplayName: "Maria",
	}
	if err := req.prepare(); err != nil {
		t.Fatalf("prepare: %v", err)
	}
	id, _ := NewID()
	instructions, err := svc.instructions(context.Background(), id, req)
	if err != nil {
		t.Fatalf("instructions: %v", err)
	}
	if len(instructions) != 3 {
		t.Fatalf("instructions: %d, want the record row and both channels", len(instructions))
	}
	sort.Strings(sealer.sealed)
	if got := strings.Join(sealer.sealed, ","); got != "+639171234567,Maria,worker@example.test" {
		t.Fatalf("sealed: %q", got)
	}
	if instructions[0].Row["display_name_ciphertext"] == nil {
		t.Fatal("the display name was not sealed into the record row")
	}

	failing := &stubSealer{fail: true}
	if _, err := New(failing, stubIndex()).instructions(context.Background(), id, req); err == nil {
		t.Fatal("a failed seal did not abort before issuance")
	}
}
