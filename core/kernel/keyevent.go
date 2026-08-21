package kernel

import (
	"errors"
	"time"
)

// The key-event log and the rule it feeds (trust-kernel/02).
//
// The rule, in one sentence: a signature is valid iff the key's activity
// window covers the record's ledger timestamp AND that timestamp
// precedes the ledger timestamp of any compromise report for the key.
//
// Both conjuncts read `ledger_ts` and neither reads `effective_at`, and
// that is the whole backdating defence. `effective_at` is the reporting
// party's declared moment; `ledger_ts` is the ledger's own, defaulted by
// the database and never supplied by a caller (0006-key-event-log). D6,
// ruled with D3, makes the anchored checkpoint sequence the ordering
// authority behind this rule (design/stack-litigation/d3-verdict.md),
// and that sequence orders by when the ledger recorded a thing. A party
// reporting today that its key was compromised a year ago therefore
// invalidates nothing that was already stamped: the report's own
// ledger_ts is today. It matches the ratified interface's neighbouring
// rule that party suspension is never retroactive
// (model/attestation-interface.md).
//
// The two conjuncts are independent rather than one collapsed into the
// other, which is why `compromised` does not itself close the activity
// window. A compromise report can arrive long after a key was rotated
// out, and the rule is written as two clauses because the questions are
// two: was this key in service, and had it been reported compromised.

// KeyEventKind is one entry in the key-event log's closed vocabulary,
// matching the CHECK constraint in 0006-key-event-log.
type KeyEventKind string

// The four key events. Registered opens a key's activity window; rotated
// and revoked close it; compromised is the separate cut described above.
//
// Rotated is recorded against the key being rotated OUT, never the one
// coming in: the successor gets its own Registered event, so recording
// rotation on the successor would be a second spelling of registration
// and the outgoing key would have no closing event at all.
const (
	KeyRegistered  KeyEventKind = "registered"
	KeyRotated     KeyEventKind = "rotated"
	KeyRevoked     KeyEventKind = "revoked"
	KeyCompromised KeyEventKind = "compromised"
)

// ErrUnknownKeyEvent reports a kind outside the closed vocabulary. The
// database CHECK refuses one on the way in; this refuses one that
// reached a caller by some other route.
var ErrUnknownKeyEvent = errors.New("kernel: key event is outside the closed vocabulary")

// KeyEvent is one row of the key-event log.
//
// EffectiveAt is carried because the log records what the party claimed,
// and it is deliberately never read by SignatureValid below. A reader
// wanting the claim reads this field and says it is a claim.
type KeyEvent struct {
	PartyID     string
	KeyID       string
	Event       KeyEventKind
	EffectiveAt time.Time
	LedgerTS    time.Time
}

// ValidKeyEventKind reports whether kind is one of the four.
func ValidKeyEventKind(kind KeyEventKind) bool {
	switch kind {
	case KeyRegistered, KeyRotated, KeyRevoked, KeyCompromised:
		return true
	}
	return false
}

// SignatureValid applies the rule to one record: keyID signed something
// the ledger stamped at recordLedgerTS, and events is the key-event log.
//
// Events carrying another key's identifier are ignored, so a caller may
// pass the whole log or one key's slice and get the same answer. Where
// one kind appears more than once for the key, the earliest is the one
// that counts: the log's primary key admits each kind once per party, so
// a repeat can only come from two parties claiming one identifier, and
// the strictest reading is the safe direction to fail in.
//
// A key with no Registered event is never valid: nothing in the log says
// it was ever in service.
func SignatureValid(events []KeyEvent, keyID string, recordLedgerTS time.Time) bool {
	var registered, closed, compromised time.Time
	for _, event := range events {
		if event.KeyID != keyID {
			continue
		}
		switch event.Event {
		case KeyRegistered:
			registered = earliest(registered, event.LedgerTS)
		case KeyRotated, KeyRevoked:
			closed = earliest(closed, event.LedgerTS)
		case KeyCompromised:
			compromised = earliest(compromised, event.LedgerTS)
		}
	}

	// Window start is inclusive and window end exclusive: a record
	// stamped at the instant of registration was signed by a key already
	// in service, and one stamped at the instant of revocation was not.
	if registered.IsZero() || recordLedgerTS.Before(registered) {
		return false
	}
	if !closed.IsZero() && !recordLedgerTS.Before(closed) {
		return false
	}
	// "Predates" is strict: a record stamped at the same instant as the
	// compromise report does not predate it.
	if !compromised.IsZero() && !recordLedgerTS.Before(compromised) {
		return false
	}
	return true
}

// earliest keeps the earlier of two instants, treating the zero time as
// "none recorded yet" rather than as the beginning of time.
func earliest(current, candidate time.Time) time.Time {
	if current.IsZero() || candidate.Before(current) {
		return candidate
	}
	return current
}
