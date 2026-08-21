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

const (
	theParty = "the-party"
	theKey   = "the-key"
)

func registration() KeyEvent {
	return KeyEvent{PartyID: theParty, KeyID: theKey, Event: KeyRegistered, EffectiveAt: registeredAt, LedgerTS: registeredAt}
}

func TestSignatureValidAcrossTheRuleBoundaries(t *testing.T) {
	compromise := KeyEvent{
		PartyID:     theParty,
		KeyID:       theKey,
		Event:       KeyCompromised,
		EffectiveAt: compromisedAt,
		LedgerTS:    compromisedAt,
	}
	revocation := KeyEvent{
		PartyID:     theParty,
		KeyID:       theKey,
		Event:       KeyRevoked,
		EffectiveAt: revokedAt,
		LedgerTS:    revokedAt,
	}
	rotation := KeyEvent{
		PartyID:     theParty,
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
		{"compromise reported after the key was already rotated out", []KeyEvent{registration(), rotation, {PartyID: theParty, KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(20), LedgerTS: hour(20)}}, hour(15), true},

		// Another key's events never move this key's answer.
		{"another key's compromise report", []KeyEvent{registration(), {PartyID: theParty, KeyID: "another-key", Event: KeyCompromised, EffectiveAt: compromisedAt, LedgerTS: compromisedAt}}, hour(15), true},
		{"another key's registration is not this key's", []KeyEvent{{PartyID: theParty, KeyID: "another-key", Event: KeyRegistered, EffectiveAt: registeredAt, LedgerTS: registeredAt}}, hour(12), false},

		// Another PARTY's events never move this key's answer either.
		// The identifier is public, so this is the case a stranger can
		// actually write rows for.
		{"another party's compromise report for this identifier", []KeyEvent{registration(), {PartyID: "another-party", KeyID: theKey, Event: KeyCompromised, EffectiveAt: compromisedAt, LedgerTS: compromisedAt}}, hour(15), true},
		{"another party's registration of this identifier", []KeyEvent{{PartyID: "another-party", KeyID: theKey, Event: KeyRegistered, EffectiveAt: registeredAt, LedgerTS: registeredAt}}, hour(12), false},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if got := SignatureValid(c.events, theParty, theKey, c.record); got != c.want {
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
		PartyID:     theParty,
		KeyID:       theKey,
		Event:       KeyCompromised,
		EffectiveAt: hour(9), // before the key was even registered
		LedgerTS:    reportedAt,
	}
	events := []KeyEvent{registration(), backdated}

	for _, stamped := range []time.Time{registeredAt, hour(12), hour(19), reportedAt.Add(-time.Nanosecond)} {
		if !SignatureValid(events, theParty, theKey, stamped) {
			t.Fatalf("a record stamped %v was invalidated by a compromise report the ledger only received at %v", stamped, reportedAt)
		}
	}
	for _, stamped := range []time.Time{reportedAt, hour(21)} {
		if SignatureValid(events, theParty, theKey, stamped) {
			t.Fatalf("a record stamped %v survived a compromise report the ledger received at %v", stamped, reportedAt)
		}
	}
}

// Event order in the slice never changes the answer: the rule is a fold
// over the events, not a walk of a sorted list, so a caller reading rows
// in any order gets one answer.
func TestTheRuleIsIndependentOfEventOrder(t *testing.T) {
	compromise := KeyEvent{PartyID: theParty, KeyID: theKey, Event: KeyCompromised, EffectiveAt: compromisedAt, LedgerTS: compromisedAt}
	revocation := KeyEvent{PartyID: theParty, KeyID: theKey, Event: KeyRevoked, EffectiveAt: revokedAt, LedgerTS: revokedAt}

	forward := []KeyEvent{registration(), compromise, revocation}
	backward := []KeyEvent{revocation, compromise, registration()}

	for h := 8; h <= 20; h++ {
		if SignatureValid(forward, theParty, theKey, hour(h)) != SignatureValid(backward, theParty, theKey, hour(h)) {
			t.Fatalf("the rule disagreed with itself at hour %d when the events were reordered", h)
		}
	}
}

// A stranger cannot retire somebody else's key. The key identifier is
// public (decision 019 puts it inside every signed payload), so nothing
// stops another party writing a revocation and a compromise report
// naming it under their own party id. The fold ignores every one of
// them, and the owner's key is untouched.
func TestAnotherPartyCannotRetireThisPartysKey(t *testing.T) {
	const stranger = "the-stranger"
	events := []KeyEvent{
		registration(),
		{PartyID: stranger, KeyID: theKey, Event: KeyRevoked, EffectiveAt: hour(11), LedgerTS: hour(11)},
		{PartyID: stranger, KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(11), LedgerTS: hour(11)},
		{PartyID: stranger, KeyID: theKey, Event: KeyRotated, EffectiveAt: hour(11), LedgerTS: hour(11)},
	}
	for h := 10; h <= 23; h++ {
		if !SignatureValid(events, theParty, theKey, hour(h)) {
			t.Fatalf("a stranger's events retired this party's key at hour %d", h)
		}
	}
	// The stranger's own rows still say nothing about a key the stranger
	// never registered.
	if SignatureValid(events, stranger, theKey, hour(12)) {
		t.Fatal("the stranger's own unregistered key produced a valid signature")
	}
}

// Duplicates of one kind cannot come from the log, whose primary key is
// (party_id, key_id, event); they can only come from a caller that
// concatenated two reads. Each branch folds in the direction that cannot
// widen validity, and those directions are not the same: registration
// takes the latest, closes and compromise reports take the earliest.
func TestDuplicateEventsFoldInTheDirectionThatCannotWidenValidity(t *testing.T) {
	twoRegistrations := []KeyEvent{
		{PartyID: theParty, KeyID: theKey, Event: KeyRegistered, EffectiveAt: hour(10), LedgerTS: hour(10)},
		{PartyID: theParty, KeyID: theKey, Event: KeyRegistered, EffectiveAt: hour(14), LedgerTS: hour(14)},
	}
	if SignatureValid(twoRegistrations, theParty, theKey, hour(12)) {
		t.Fatal("the earlier registration won, widening the window backwards")
	}
	if !SignatureValid(twoRegistrations, theParty, theKey, hour(14)) {
		t.Fatal("the later registration did not open the window")
	}

	twoCloses := []KeyEvent{
		registration(),
		{PartyID: theParty, KeyID: theKey, Event: KeyRevoked, EffectiveAt: hour(14), LedgerTS: hour(14)},
		{PartyID: theParty, KeyID: theKey, Event: KeyRotated, EffectiveAt: hour(18), LedgerTS: hour(18)},
	}
	if SignatureValid(twoCloses, theParty, theKey, hour(16)) {
		t.Fatal("the later close won, widening the window forwards")
	}

	twoReports := []KeyEvent{
		registration(),
		{PartyID: theParty, KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(18), LedgerTS: hour(18)},
		{PartyID: theParty, KeyID: theKey, Event: KeyCompromised, EffectiveAt: hour(12), LedgerTS: hour(12)},
	}
	if SignatureValid(twoReports, theParty, theKey, hour(13)) {
		t.Fatal("the later compromise report won over the earlier one")
	}
	if !SignatureValid(twoReports, theParty, theKey, hour(11)) {
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
