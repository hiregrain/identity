package kernel

import (
	"testing"
	"time"
)

// The compromise-vs-backdating rule, driven across its boundaries
// (trust-kernel/02, first acceptance clause). The table is the
// enumeration of the cases that matter, not a sample: every comparison
// the rule makes is an instant-against-instant test, so each one is
// exercised strictly before, exactly at, and strictly after.

var (
	// One key's story, at hour resolution so the arithmetic in each case
	// reads without a calculator.
	registeredAt  = time.Date(2026, 8, 21, 10, 0, 0, 0, time.UTC)
	compromisedAt = time.Date(2026, 8, 21, 14, 0, 0, 0, time.UTC)
	revokedAt     = time.Date(2026, 8, 21, 16, 0, 0, 0, time.UTC)
)

func hour(h int) time.Time {
	return time.Date(2026, 8, 21, h, 0, 0, 0, time.UTC)
}

const theKey = "the-key"

func registration() KeyEvent {
	return KeyEvent{PartyID: "party", KeyID: theKey, Event: KeyRegistered, EffectiveAt: registeredAt, LedgerTS: registeredAt}
}

func TestSignatureValidAcrossTheRuleBoundaries(t *testing.T) {
	compromise := KeyEvent{
		PartyID:     "party",
		KeyID:       theKey,
		Event:       KeyCompromised,
		EffectiveAt: compromisedAt,
		LedgerTS:    compromisedAt,
	}
	revocation := KeyEvent{
		PartyID:     "party",
		KeyID:       theKey,
		Event:       KeyRevoked,
		EffectiveAt: revokedAt,
		LedgerTS:    revokedAt,
	}
	rotation := KeyEvent{
		PartyID:     "party",
		KeyID:       theKey,
		Event:       KeyRotated,
		EffectiveAt: revokedAt,
		LedgerTS:    revokedAt,
	}

	cases := []struct {
		name   string
		events []KeyEvent
		record time.Time
		want   bool
	}{
		// The rule's first conjunct: the activity window.
		{"no events at all", nil, hour(12), false},
		{"the key was never registered", []KeyEvent{compromise}, hour(12), false},
		{"one hour before registration", []KeyEvent{registration()}, hour(9), false},
		{"at the instant of registration", []KeyEvent{registration()}, registeredAt, true},
		{"one hour after registration", []KeyEvent{registration()}, hour(11), true},
		{"registered and never closed", []KeyEvent{registration()}, hour(23), true},
		{"one hour before revocation", []KeyEvent{registration(), revocation}, hour(15), true},
		{"at the instant of revocation", []KeyEvent{registration(), revocation}, revokedAt, false},
		{"one hour after revocation", []KeyEvent{registration(), revocation}, hour(17), false},
		{"rotation closes the window exactly as revocation does", []KeyEvent{registration(), rotation}, revokedAt, false},
		{"one hour before rotation", []KeyEvent{registration(), rotation}, hour(15), true},

		// The rule's second conjunct: the compromise cut. A compromise
		// report at T invalidates what the ledger stamped after T and
		// leaves what it stamped before T valid.
		{"one hour before the compromise report", []KeyEvent{registration(), compromise}, hour(13), true},
		{"at the instant of the compromise report", []KeyEvent{registration(), compromise}, compromisedAt, false},
		{"one hour after the compromise report", []KeyEvent{registration(), compromise}, hour(15), false},
		{"one nanosecond before the compromise report", []KeyEvent{registration(), compromise}, compromisedAt.Add(-time.Nanosecond), true},
		{"one nanosecond after the compromise report", []KeyEvent{registration(), compromise}, compromisedAt.Add(time.Nanosecond), false},

		// The conjuncts are independent: a compromise report arriving
		// after the key was already rotated out cuts nothing further,
		// and the window still governs.
		{"compromise reported after the key was already rotated out", []KeyEvent{registration(), rotation, {PartyID: "party", KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(20), LedgerTS: hour(20)}}, hour(15), true},

		// Another key's events never move this key's answer.
		{"another key's compromise report", []KeyEvent{registration(), {PartyID: "party", KeyID: "another-key", Event: KeyCompromised, EffectiveAt: compromisedAt, LedgerTS: compromisedAt}}, hour(15), true},
		{"another key's registration is not this key's", []KeyEvent{{PartyID: "party", KeyID: "another-key", Event: KeyRegistered, EffectiveAt: registeredAt, LedgerTS: registeredAt}}, hour(12), false},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if got := SignatureValid(c.events, theKey, c.record); got != c.want {
				t.Fatalf("SignatureValid = %v, want %v", got, c.want)
			}
		})
	}
}

// The backdating case, stated on its own because it is the rule's whole
// reason to exist: a party reporting a compromise today and claiming it
// was effective before every signature it dislikes invalidates none of
// them. Only ledger_ts moves the answer.
func TestABackdatedCompromiseClaimInvalidatesNothing(t *testing.T) {
	reportedAt := hour(20)
	backdated := KeyEvent{
		PartyID:     "party",
		KeyID:       theKey,
		Event:       KeyCompromised,
		EffectiveAt: hour(9), // before the key was even registered
		LedgerTS:    reportedAt,
	}
	events := []KeyEvent{registration(), backdated}

	for _, stamped := range []time.Time{registeredAt, hour(12), hour(19), reportedAt.Add(-time.Nanosecond)} {
		if !SignatureValid(events, theKey, stamped) {
			t.Fatalf("a record stamped %v was invalidated by a compromise report the ledger only received at %v", stamped, reportedAt)
		}
	}
	for _, stamped := range []time.Time{reportedAt, hour(21)} {
		if SignatureValid(events, theKey, stamped) {
			t.Fatalf("a record stamped %v survived a compromise report the ledger received at %v", stamped, reportedAt)
		}
	}
}

// Event order in the slice never changes the answer: the rule is a fold
// over the events, not a walk of a sorted list, so a caller reading rows
// in any order gets one answer.
func TestTheRuleIsIndependentOfEventOrder(t *testing.T) {
	compromise := KeyEvent{PartyID: "party", KeyID: theKey, Event: KeyCompromised, EffectiveAt: compromisedAt, LedgerTS: compromisedAt}
	revocation := KeyEvent{PartyID: "party", KeyID: theKey, Event: KeyRevoked, EffectiveAt: revokedAt, LedgerTS: revokedAt}

	forward := []KeyEvent{registration(), compromise, revocation}
	backward := []KeyEvent{revocation, compromise, registration()}

	for h := 8; h <= 20; h++ {
		if SignatureValid(forward, theKey, hour(h)) != SignatureValid(backward, theKey, hour(h)) {
			t.Fatalf("the rule disagreed with itself at hour %d when the events were reordered", h)
		}
	}
}

// Where a kind appears twice for one key, the earliest is the one that
// counts. The log's primary key admits each kind once per party, so this
// can only arise from two parties claiming one identifier, and failing
// strict is the safe direction.
func TestARepeatedEventKindTakesTheEarliest(t *testing.T) {
	events := []KeyEvent{
		registration(),
		{PartyID: "party-a", KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(18), LedgerTS: hour(18)},
		{PartyID: "party-b", KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(12), LedgerTS: hour(12)},
	}
	if SignatureValid(events, theKey, hour(13)) {
		t.Fatal("the later compromise report won over the earlier one")
	}
	if !SignatureValid(events, theKey, hour(11)) {
		t.Fatal("a record before both reports was invalidated")
	}
}

func TestValidKeyEventKind(t *testing.T) {
	for _, kind := range []KeyEventKind{KeyRegistered, KeyRotated, KeyRevoked, KeyCompromised} {
		if !ValidKeyEventKind(kind) {
			t.Fatalf("%q is one of the four and was refused", kind)
		}
	}
	for _, kind := range []KeyEventKind{"", "suspended", "Registered", "registered "} {
		if ValidKeyEventKind(kind) {
			t.Fatalf("%q is outside the closed vocabulary and was accepted", kind)
		}
	}
}
