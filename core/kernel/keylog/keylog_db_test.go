//go:build db

package keylog_test

// The key-event log against the live spine (trust-kernel/02). What the
// pure table-driven test in core/kernel cannot show is that the database
// half holds: that ledger_ts is the ledger's and not a caller's, that the
// log is append-only in the database rather than by manners, and that a
// compromise report cannot be written twice and then disagree with
// itself.
//
// Every statement crosses core/transport, the one seam any SQL path in
// this repo may use (trust-kernel/08, decision 065), including the
// harness statements below.

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/kernel/keylog"
	"github.com/hiregrain/identity/core/transport"
)

const (
	spinePlane  = "spine"
	servingRole = "identity_app"
	ownerRole   = "identity"
)

// plantEvent writes one row as the owner with an explicit ledger_ts.
// This is the harness playing the ledger: it is the one way to lay down
// a history whose instants the test chose, and it is deliberately not
// available to the serving role, which is what the permission assertion
// below proves.
func plantEvent(t *testing.T, partyID, keyID string, event kernel.KeyEventKind, effectiveAt, ledgerTS time.Time) {
	t.Helper()
	_, err := transport.Query(spinePlane, ownerRole,
		"INSERT INTO key_event (party_id, key_id, event, effective_at, ledger_ts) VALUES ($1, $2, $3, $4, $5)",
		transport.String(partyID),
		transport.String(keyID),
		transport.String(string(event)),
		transport.String(effectiveAt.UTC().Format(time.RFC3339Nano)),
		transport.String(ledgerTS.UTC().Format(time.RFC3339Nano)))
	if err != nil {
		t.Fatalf("planting %s: %v", event, err)
	}
}

// newParty returns a fresh spine_object_id. Random, per 0003-spine-core's
// convention for the domain.
func newParty(t *testing.T) string {
	t.Helper()
	raw := make([]byte, 16)
	if _, err := rand.Read(raw); err != nil {
		t.Fatalf("party id: %v", err)
	}
	raw[6] = (raw[6] & 0x0f) | 0x40
	raw[8] = (raw[8] & 0x3f) | 0x80
	h := hex.EncodeToString(raw)
	return fmt.Sprintf("%s-%s-%s-%s-%s", h[0:8], h[8:12], h[12:16], h[16:20], h[20:32])
}

// newKeyID returns an identifier unique to one test, so tests sharing a
// database never read each other's rows.
func newKeyID(t *testing.T) string {
	t.Helper()
	raw := make([]byte, 12)
	if _, err := rand.Read(raw); err != nil {
		t.Fatalf("key id: %v", err)
	}
	return "keylog-test-" + hex.EncodeToString(raw)
}

// Append writes what it was given, the database stamps ledger_ts, and
// EventsForKey reads both back.
func TestAppendRoundTrip(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)
	// Deliberately backdated: Append stores the claim as given.
	claimed := time.Now().UTC().Add(-72 * time.Hour).Truncate(time.Second)

	before := time.Now().UTC().Add(-time.Minute)
	if err := keylog.Append(ctx, party, key, kernel.KeyRegistered, claimed); err != nil {
		t.Fatalf("Append: %v", err)
	}
	after := time.Now().UTC().Add(time.Minute)

	events, err := keylog.Events(ctx, party, key)
	if err != nil {
		t.Fatalf("Events: %v", err)
	}
	if len(events) != 1 {
		t.Fatalf("read %d events, want 1", len(events))
	}
	got := events[0]
	if got.PartyID != party || got.KeyID != key || got.Event != kernel.KeyRegistered {
		t.Fatalf("read back %+v, want the row just written", got)
	}
	if !got.EffectiveAt.Equal(claimed) {
		t.Fatalf("effective_at read back as %v, want the claim %v", got.EffectiveAt, claimed)
	}
	if got.LedgerTS.Before(before) || got.LedgerTS.After(after) {
		t.Fatalf("ledger_ts %v is not the moment of the write, so it is not the ledger's stamp", got.LedgerTS)
	}
	if !got.LedgerTS.After(got.EffectiveAt) {
		t.Fatal("the backdated claim moved ledger_ts, which is exactly what the rule must not allow")
	}
}

// The serving role may not supply ledger_ts. Enforced by the column-level
// INSERT grant in 0006-key-event-log, not by this package declining to
// write it.
func TestTheServingRoleCannotSupplyTheLedgerStamp(t *testing.T) {
	party, key := newParty(t), newKeyID(t)
	_, err := transport.Query(spinePlane, servingRole,
		"INSERT INTO key_event (party_id, key_id, event, effective_at, ledger_ts)"+
			" VALUES ($1, $2, 'registered', now(), now() - interval '1 year')",
		transport.String(party), transport.String(key))
	if err == nil {
		t.Fatal("the serving role wrote its own ledger_ts, so the ledger's stamp is a caller's claim")
	}
	if !strings.Contains(err.Error(), "permission denied") {
		t.Fatalf("the write failed for some other reason than permission: %v", err)
	}
}

// The log is append-only in the database. identity_app holds SELECT and
// INSERT alone (migration 0002) and 0006 grants nothing further, so a
// planted compromise report can never be moved or removed.
func TestTheLogCannotBeEditedOrErased(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)
	if err := keylog.Append(ctx, party, key, kernel.KeyCompromised, time.Now().UTC()); err != nil {
		t.Fatalf("Append: %v", err)
	}
	for _, statement := range []string{
		"UPDATE key_event SET ledger_ts = now() + interval '1 year' WHERE key_id = $1",
		"DELETE FROM key_event WHERE key_id = $1",
	} {
		_, err := transport.Query(spinePlane, servingRole, statement, transport.String(key))
		if err == nil {
			t.Fatalf("the serving role ran %q against the key-event log", statement)
		}
		if !strings.Contains(err.Error(), "permission denied") {
			t.Fatalf("%q failed for some other reason than permission: %v", statement, err)
		}
	}
}

// One event of each kind per key, enforced by the primary key. A second
// compromise report cannot stand beside the first and disagree with it.
func TestASecondEventOfOneKindIsRefused(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)
	if err := keylog.Append(ctx, party, key, kernel.KeyCompromised, time.Now().UTC()); err != nil {
		t.Fatalf("first Append: %v", err)
	}
	if err := keylog.Append(ctx, party, key, kernel.KeyCompromised, time.Now().UTC()); err == nil {
		t.Fatal("a second compromise report for one key was accepted")
	}
}

// The closed vocabulary is refused twice over: by this package before any
// SQL is built, and by the CHECK constraint for anything that reaches the
// database another way.
func TestTheEventVocabularyIsClosed(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)
	if err := keylog.Append(ctx, party, key, kernel.KeyEventKind("suspended"), time.Now().UTC()); err == nil {
		t.Fatal("keylog.Append accepted an event outside the closed vocabulary")
	}
	_, err := transport.Query(spinePlane, ownerRole,
		"INSERT INTO key_event (party_id, key_id, event, effective_at) VALUES ($1, $2, 'suspended', now())",
		transport.String(party), transport.String(key))
	if err == nil {
		t.Fatal("the CHECK constraint accepted an event outside the closed vocabulary")
	}
}

// The rule over a real history: a compromise report at T invalidates
// signatures the ledger stamped after T and leaves pre-T signatures
// valid. Same claim the table-driven test in core/kernel makes, run here
// against rows that made a round trip through the database, so a
// timestamp lost or coarsened on the way in or out would show up.
func TestTheCompromiseCutHoldsOverRowsReadBack(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)

	registered := time.Now().UTC().Add(-10 * time.Hour).Truncate(time.Microsecond)
	reported := time.Now().UTC().Add(-4 * time.Hour).Truncate(time.Microsecond)

	plantEvent(t, party, key, kernel.KeyRegistered, registered, registered)
	// Backdated on its face: the party claims the compromise was
	// effective before the key was even registered. Only the ledger's
	// stamp counts.
	plantEvent(t, party, key, kernel.KeyCompromised, registered.Add(-time.Hour), reported)

	cases := []struct {
		name   string
		stamp  time.Time
		expect bool
	}{
		{"before registration", registered.Add(-time.Second), false},
		{"at registration", registered, true},
		{"between registration and the report", reported.Add(-time.Hour), true},
		{"one microsecond before the report", reported.Add(-time.Microsecond), true},
		{"at the report", reported, false},
		{"after the report", reported.Add(time.Hour), false},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			valid, err := keylog.SignatureValid(ctx, party, key, c.stamp)
			if err != nil {
				t.Fatalf("SignatureValid: %v", err)
			}
			if valid != c.expect {
				t.Fatalf("SignatureValid = %v, want %v", valid, c.expect)
			}
		})
	}
}

// Rotation closes a window without touching the compromise cut, over
// rows read back the same way.
func TestRotationClosesTheWindowOverRowsReadBack(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)

	registered := time.Now().UTC().Add(-8 * time.Hour).Truncate(time.Microsecond)
	rotated := time.Now().UTC().Add(-2 * time.Hour).Truncate(time.Microsecond)
	plantEvent(t, party, key, kernel.KeyRegistered, registered, registered)
	plantEvent(t, party, key, kernel.KeyRotated, rotated, rotated)

	valid, err := keylog.SignatureValid(ctx, party, key, rotated.Add(-time.Minute))
	if err != nil {
		t.Fatalf("SignatureValid: %v", err)
	}
	if !valid {
		t.Fatal("a record signed before the key was rotated out is not valid")
	}
	valid, err = keylog.SignatureValid(ctx, party, key, rotated)
	if err != nil {
		t.Fatalf("SignatureValid: %v", err)
	}
	if valid {
		t.Fatal("a record stamped at the instant of rotation is still valid")
	}
}

// One party cannot retire another party's key, proven against the
// database that lets it write the rows.
//
// The attack this closes: a key identifier is public. Decision 019 puts
// it inside every signed payload, and the log is public by destiny. The
// log's primary key is (party_id, key_id, event), so a stranger writing
// a revocation and a compromise report for somebody else's key
// identifier under their OWN party id takes no conflict and is refused
// by nothing at the database. If the read or the rule matched on the
// identifier alone, those rows would permanently retire a key the
// stranger does not own, with no undo, since the log is append-only.
//
// The rows below are written through the ordinary serving path, not
// planted as the owner, because writing them is precisely what a
// stranger can do.
func TestOnePartyCannotRetireAnotherPartysKey(t *testing.T) {
	ctx := context.Background()
	owner, stranger := newParty(t), newParty(t)
	key := newKeyID(t)

	registered := time.Now().UTC().Add(-6 * time.Hour).Truncate(time.Microsecond)
	plantEvent(t, owner, key, kernel.KeyRegistered, registered, registered)

	// The stranger writes every retiring event it can, naming the
	// owner's key identifier under its own party id. Each must succeed:
	// the point is that the database does not stop it and the read does.
	for _, event := range []kernel.KeyEventKind{kernel.KeyRevoked, kernel.KeyCompromised, kernel.KeyRotated} {
		if err := keylog.Append(ctx, stranger, key, event, time.Now().UTC()); err != nil {
			t.Fatalf("the stranger's %s was refused by the database, so this test is no longer testing the read: %v", event, err)
		}
	}

	// The owner's key is untouched, before and after the stranger's
	// rows landed.
	for _, stamp := range []time.Time{registered, registered.Add(time.Hour), time.Now().UTC()} {
		valid, err := keylog.SignatureValid(ctx, owner, key, stamp)
		if err != nil {
			t.Fatalf("SignatureValid(owner): %v", err)
		}
		if !valid {
			t.Fatalf("the stranger retired the owner's key: a record stamped %v is no longer valid", stamp)
		}
	}

	// The read is scoped, so the owner's slice carries none of the
	// stranger's rows.
	events, err := keylog.Events(ctx, owner, key)
	if err != nil {
		t.Fatalf("Events(owner): %v", err)
	}
	if len(events) != 1 || events[0].Event != kernel.KeyRegistered {
		t.Fatalf("the owner's event slice carries the stranger's rows: %+v", events)
	}

	// And the stranger gains nothing for itself either: it never
	// registered this identifier, so it has no window.
	valid, err := keylog.SignatureValid(ctx, stranger, key, time.Now().UTC())
	if err != nil {
		t.Fatalf("SignatureValid(stranger): %v", err)
	}
	if valid {
		t.Fatal("the stranger's own unregistered key produced a valid signature")
	}
}

// Timestamps cross the seam as epoch microseconds rather than rendered
// text, so a session on a zone with a sub-hour offset reads the same
// instants as one on UTC. Asia/Kolkata is +05:30, which is the case a
// fixed hour-only layout cannot parse at all.
func TestTimestampsSurviveASubHourSessionTimeZone(t *testing.T) {
	ctx := context.Background()
	party, key := newParty(t), newKeyID(t)
	registered := time.Now().UTC().Add(-3 * time.Hour).Truncate(time.Microsecond)
	plantEvent(t, party, key, kernel.KeyRegistered, registered, registered)

	onUTC, err := keylog.Events(ctx, party, key)
	if err != nil {
		t.Fatalf("Events on the default session zone: %v", err)
	}

	// Move the database's own default, which is what a psql session
	// inherits, then read the same row back.
	if _, err := transport.Query(spinePlane, ownerRole,
		"ALTER DATABASE spine SET TimeZone TO 'Asia/Kolkata'"); err != nil {
		t.Fatalf("setting the session zone: %v", err)
	}
	t.Cleanup(func() {
		if _, err := transport.Query(spinePlane, ownerRole,
			"ALTER DATABASE spine RESET TimeZone"); err != nil {
			t.Fatalf("resetting the session zone: %v", err)
		}
	})

	onKolkata, err := keylog.Events(ctx, party, key)
	if err != nil {
		t.Fatalf("Events on a +05:30 session zone: %v", err)
	}
	if len(onKolkata) != 1 {
		t.Fatalf("read %d events on the +05:30 zone, want 1", len(onKolkata))
	}
	if !onKolkata[0].LedgerTS.Equal(onUTC[0].LedgerTS) ||
		!onKolkata[0].EffectiveAt.Equal(onUTC[0].EffectiveAt) {
		t.Fatalf("the same row read as %v on the +05:30 zone and %v on the default", onKolkata[0], onUTC[0])
	}
	if !onKolkata[0].LedgerTS.Equal(registered) {
		t.Fatalf("ledger_ts read back as %v, want %v", onKolkata[0].LedgerTS, registered)
	}
}

// A key with no events at all is never valid, read through the database
// rather than asserted about an empty slice.
func TestAKeyWithNoEventsIsNeverValid(t *testing.T) {
	ctx := context.Background()
	valid, err := keylog.SignatureValid(ctx, newParty(t), newKeyID(t), time.Now().UTC())
	if err != nil {
		t.Fatalf("SignatureValid: %v", err)
	}
	if valid {
		t.Fatal("a key the log has never heard of produced a valid signature")
	}
}
