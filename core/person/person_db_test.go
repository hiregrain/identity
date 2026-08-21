//go:build db

// The signup and id-issuance acceptance suite (person-identity/01). Run
// by `make person-test` against both live planes, requiring Docker and
// Go. Each scenario drives the real path: the spine transaction that
// issues an id, the outbox worker that carries the payload half, and
// core/envelope's per-person key underneath both.
package person_test

import (
	"context"
	"encoding/hex"
	"strings"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/outbox"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// The address a signup uses is unique per run so a repeated suite never
// reads a prior run's row.
func addresses() (email string) {
	return "worker+" + time.Now().UTC().Format("20060102150405.000000000") + "@example.test"
}

// TestSignupWithEmailAloneYieldsAUsableIdentity is the criterion stated
// as a run: an email and nothing else in, an id out, usable at spine
// commit, with every optional field absent rather than defaulted.
func TestSignupWithEmailAloneYieldsAUsableIdentity(t *testing.T) {
	ctx := context.Background()
	svc, env := newService(t)

	email := addresses()
	verifiedAt := time.Now().UTC().Truncate(time.Second)

	// Everything except the verified email channel is left at its zero
	// value. If any other field were required, this call would fail.
	id, err := svc.Signup(ctx, person.Request{
		Email: person.Channel{Address: email, VerifiedAt: verifiedAt},
	})
	if err != nil {
		t.Fatalf("signup with an email alone: %v", err)
	}
	if err := person.ValidID(id); err != nil {
		t.Fatalf("issued id: %v", err)
	}
	idArg := transport.String(id)

	// Issued at spine commit: the person row and its 'active' transition
	// are there the moment Signup returns.
	if got := ownerSQL(t, "spine",
		"SELECT count(*) FROM person WHERE person_id = $1", idArg); got != "1" {
		t.Fatalf("person row at spine commit: got %q", got)
	}
	if got := ownerSQL(t, "spine",
		"SELECT string_agg(state, ',' ORDER BY state) FROM person_lifecycle_transition WHERE person_id = $1",
		idArg); got != "active" {
		t.Fatalf("lifecycle transitions: got %q, want active", got)
	}
	if got := ownerSQL(t, "spine",
		"SELECT created_at IS NOT NULL FROM person WHERE person_id = $1", idArg); got != "t" {
		t.Fatalf("created_at: got %q", got)
	}

	// Usable immediately: the person's key is active, so content seals
	// and opens before the payload rows have landed at all.
	sealed, err := env.Encrypt(ctx, id, []byte("usable at spine commit"))
	if err != nil {
		t.Fatalf("encrypt under a freshly issued id: %v", err)
	}
	opened, err := env.Decrypt(ctx, id, sealed)
	if err != nil || string(opened) != "usable at spine commit" {
		t.Fatalf("decrypt under a freshly issued id: %q, %v", opened, err)
	}

	// The payload half follows through the outbox, and until it is
	// drained the entries are unacknowledged. This is the whole of what
	// "instantly" claims and does not claim.
	if got := ownerSQL(t, "payload",
		"SELECT count(*) FROM person_record WHERE person_id = $1", idArg); got != "0" {
		t.Fatalf("payload row before the drain: got %q, want 0", got)
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}

	// The payload row, with every optional field absent.
	record := ownerSQL(t, "payload",
		"SELECT display_name_ciphertext IS NULL, residency_region FROM person_record WHERE person_id = $1",
		idArg)
	if record != "t\tus" {
		t.Fatalf("person_record: got %q, want t/us (display name absent, residency stamped)", record)
	}

	channel := ownerSQL(t, "payload", `
		SELECT channel_kind, line_type, coalesce(line_country, 'absent'),
		       carrier_reputation, velocity_observed, velocity_threshold,
		       assurance, verified_at IS NOT NULL, residency_region
		  FROM person_contact_channel WHERE person_id = $1`, idArg)
	want := strings.Join([]string{
		"email", "email", "absent", "unknown", "0", "5",
		"channel-control", "t", "us",
	}, "\t")
	if channel != want {
		t.Fatalf("person_contact_channel:\n got  %q\n want %q", channel, want)
	}

	// The address is recoverable by the person's key and by nothing
	// else: it reaches the payload plane as ciphertext inside the outbox
	// instruction, so neither plane holds it in the clear.
	stored := ownerSQL(t, "payload",
		"SELECT encode(address_ciphertext, 'hex') FROM person_contact_channel WHERE person_id = $1",
		idArg)
	raw := decodeHex(t, stored)
	back, err := env.Decrypt(ctx, id, raw)
	if err != nil {
		t.Fatalf("decrypt the stored channel address: %v", err)
	}
	if string(back) != email {
		t.Fatalf("channel address round trip: got %q, want %q", back, email)
	}
	if strings.Contains(payloadDump(t), email) {
		t.Fatal("the payload dump holds the address in plaintext")
	}
	if strings.Contains(ownerSQL(t, "spine",
		"SELECT coalesce(string_agg(encode(instruction, 'escape'), ' '), '') FROM cross_plane_outbox"), email) {
		t.Fatal("a spine outbox instruction holds the address in plaintext")
	}
}

// TestUnverifiedChannelIsRefused: "verified control of one channel" is
// enforced, not promised. The package refuses the request and the
// column refuses the row.
func TestUnverifiedChannelIsRefused(t *testing.T) {
	svc, _ := newService(t)

	_, err := svc.Signup(context.Background(), person.Request{
		Email: person.Channel{Address: addresses()},
	})
	if err == nil {
		t.Fatal("signup accepted a channel with no proof of control")
	}

	if _, err := roleSQL("payload", "identity", `
		INSERT INTO person_contact_channel
		  (outbox_entry_id, person_id, channel_kind, address_ciphertext,
		   verified_at, line_type, carrier_reputation, velocity_observed,
		   velocity_threshold, assurance)
		VALUES (gen_random_uuid(), gen_random_uuid(), 'email', $1,
		        NULL, 'email', 'unknown', 0, 5, 'channel-control')`,
		transport.Bytea([]byte{0})); err == nil {
		t.Fatal("the channel table accepted a row with no verified_at")
	}
}

// TestTombstonedIDIsNeverIssuedAgain drives the criterion from both
// sides it can fail on: the generator, which must not be able to return
// a spent id, and the table, which must refuse one that is offered.
func TestTombstonedIDIsNeverIssuedAgain(t *testing.T) {
	ctx := context.Background()
	svc, _ := newService(t)

	spent, err := svc.Signup(ctx, person.Request{
		Email: person.Channel{Address: addresses(), VerifiedAt: time.Now().UTC()},
	})
	if err != nil {
		t.Fatalf("signup: %v", err)
	}
	if err := svc.Tombstone(ctx, spent); err != nil {
		t.Fatalf("tombstone: %v", err)
	}
	tombstoned, err := svc.Tombstoned(ctx, spent)
	if err != nil || !tombstoned {
		t.Fatalf("tombstoned state: %v, %v", tombstoned, err)
	}

	// The generator: it reads the CSPRNG and nothing else, so no input
	// steers it at a spent id. A large batch is unique and none of it
	// collides with the id just spent.
	const batch = 20000
	seen := make(map[string]bool, batch)
	for i := 0; i < batch; i++ {
		id, err := person.NewID()
		if err != nil {
			t.Fatalf("id generation: %v", err)
		}
		if err := person.ValidID(id); err != nil {
			t.Fatalf("generated id: %v", err)
		}
		if seen[id] {
			t.Fatalf("id generation repeated %s", id)
		}
		if id == spent {
			t.Fatalf("id generation returned the tombstoned id %s", spent)
		}
		seen[id] = true
	}

	// The table: the spent id occupies its key forever, because a person
	// row is never deleted, tombstoned included. Offering it again fails
	// for the serving role and for the owner alike.
	for _, role := range []string{"identity_app", "identity"} {
		if _, err := roleSQL("spine", role,
			"INSERT INTO person (person_id) VALUES ($1)",
			transport.String(spent)); err == nil {
			t.Fatalf("the person table accepted the tombstoned id again as %s", role)
		}
	}

	// Tombstoning one id spends that id and nothing more: the next
	// signup still works.
	if _, err := svc.Signup(ctx, person.Request{
		Email: person.Channel{Address: addresses(), VerifiedAt: time.Now().UTC()},
	}); err != nil {
		t.Fatalf("signup after a tombstone: %v", err)
	}
}

// TestAssuranceFollowsTheLine: a PH mobile carries the RA 11934 marker
// (decision 013) and a US mobile does not, end to end, plus the
// database's refusal to hold the marker on anything else.
func TestAssuranceFollowsTheLine(t *testing.T) {
	ctx := context.Background()
	svc, _ := newService(t)

	cases := []struct {
		name     string
		number   string
		country  string
		lineType string
		want     string
	}{
		{"PH mobile", "+639171234567", "ph", person.LineMobile, person.AssurancePHSIMRegistered},
		{"US mobile", "+14155550142", "us", person.LineMobile, person.AssuranceChannelControl},
		{"PH landline", "+63288887777", "ph", person.LineLandline, person.AssuranceChannelControl},
	}
	ids := make([]string, len(cases))
	for i, c := range cases {
		id, err := svc.Signup(ctx, person.Request{
			Email: person.Channel{Address: addresses(), VerifiedAt: time.Now().UTC()},
			Phone: &person.Channel{
				Address:    c.number,
				VerifiedAt: time.Now().UTC(),
				Risk: person.RiskSignals{
					LineType:          c.lineType,
					Country:           c.country,
					CarrierReputation: person.CarrierClear,
					VelocityObserved:  1,
				},
			},
		})
		if err != nil {
			t.Fatalf("%s: signup: %v", c.name, err)
		}
		ids[i] = id
	}
	if _, _, err := outbox.Drain(""); err != nil {
		t.Fatalf("drain: %v", err)
	}
	for i, c := range cases {
		idArg := transport.String(ids[i])
		got := ownerSQL(t, "payload",
			"SELECT assurance FROM person_contact_channel WHERE person_id = $1 AND channel_kind = 'phone'",
			idArg)
		if got != c.want {
			t.Fatalf("%s: assurance %q, want %q", c.name, got, c.want)
		}
		// The email channel on the same account is never promoted.
		if got := ownerSQL(t, "payload",
			"SELECT assurance FROM person_contact_channel WHERE person_id = $1 AND channel_kind = 'email'",
			idArg); got != person.AssuranceChannelControl {
			t.Fatalf("%s: the email channel carries %q", c.name, got)
		}
	}

	// The marker is unreachable on a line that does not qualify, whatever
	// a write site believes. The unknown-country case is here because it
	// is the one that got through: a CHECK admits NULL, so comparing a
	// nullable country with = made the rule neither true nor false and
	// the row landed carrying the marker.
	for _, country := range []struct {
		name  string
		value transport.Arg
	}{
		{"a US mobile", transport.String("us")},
		{"a mobile of unknown country", transport.Null},
	} {
		if _, err := roleSQL("payload", "identity", `
			INSERT INTO person_contact_channel
			  (outbox_entry_id, person_id, channel_kind, address_ciphertext,
			   verified_at, line_type, line_country, carrier_reputation,
			   velocity_observed, velocity_threshold, assurance)
			VALUES (gen_random_uuid(), gen_random_uuid(), 'phone', $1,
			        now(), 'mobile', $2, 'clear', 0, 5, 'ph-sim-registered')`,
			transport.Bytea([]byte{0}), country.value); err == nil {
			t.Fatalf("the channel table accepted the elevated marker on %s", country.name)
		}
	}
}

// TestResidencyIsNotTheCallersToChoose: the region is the database's own
// declaration. An instruction naming the column is refused before it can
// reach a row, so the default is binding rather than customary.
func TestResidencyIsNotTheCallersToChoose(t *testing.T) {
	_, err := outbox.Instruction{
		Table: "person_record",
		Row: map[string]any{
			"person_id":        "00000000-0000-4000-8000-000000000000",
			"residency_region": "zz",
		},
	}.ApplySQL("00000000-0000-4000-8000-000000000001")
	if err == nil {
		t.Fatal("an instruction was allowed to choose its own residency region")
	}
	if !strings.Contains(err.Error(), "residency_region") {
		t.Fatalf("refusal does not name the column: %v", err)
	}
}

// decodeHex reads psql's hex output back to bytes.
func decodeHex(t *testing.T, s string) []byte {
	t.Helper()
	raw, err := hex.DecodeString(s)
	if err != nil {
		t.Fatalf("not hex: %v", err)
	}
	return raw
}
