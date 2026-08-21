// The database-free half of person-identity/01's proofs: id generation,
// the assurance rule, and the validation that keeps a malformed request
// out of the ledger. Run by `make go-check`, no Docker.
package person

import (
	"strings"
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

// The issuance transaction: the person row, the 'active' transition and
// one outbox entry per payload row, all inside one BEGIN/COMMIT. If the
// person row ever left this transaction, "issued at spine commit" would
// stop being one claim.
func TestIssueScriptIsOneTransaction(t *testing.T) {
	id, err := NewID()
	if err != nil {
		t.Fatalf("id generation: %v", err)
	}
	script, err := issueScript(id, []outbox.Instruction{
		{Table: "person_record", Row: map[string]any{"person_id": id}},
		{Table: "person_contact_channel", Row: map[string]any{"person_id": id}},
	})
	if err != nil {
		t.Fatalf("issueScript: %v", err)
	}
	if !strings.HasPrefix(script, "BEGIN;\n") || !strings.HasSuffix(script, "COMMIT;\n") {
		t.Fatalf("script is not one transaction:\n%s", script)
	}
	for _, want := range []string{
		"INSERT INTO person (person_id) VALUES ('" + id + "');",
		"INSERT INTO person_lifecycle_transition (person_id, state) VALUES ('" + id + "', 'active');",
	} {
		if !strings.Contains(script, want) {
			t.Fatalf("script is missing %q:\n%s", want, script)
		}
	}
	if got := strings.Count(script, "INSERT INTO cross_plane_outbox"); got != 2 {
		t.Fatalf("outbox entries: %d, want one per payload row", got)
	}
}

func TestIssueScriptRefusesAnIDItDidNotIssue(t *testing.T) {
	if _, err := issueScript("'; DROP TABLE person; --", nil); err == nil {
		t.Fatal("issueScript accepted an id that is not a uuid")
	}
}
