// Package keylog is the append-only key-event log's read and write path
// (trust-kernel/02, migration 0006-key-event-log). The rule the log
// exists to feed is core/kernel's SignatureValid; this package is where
// its input is written and read.
//
// It sits beside the frozen core rather than inside it: reading a
// database is orchestration, the rule is the primitive. The split is
// what keeps checks/kernel-budget.mjs measuring the frozen core rather
// than its scaffolding (decision 019).
//
// Two properties this package deliberately does not implement, because
// the database does:
//
//   - Append-only. identity_app holds SELECT and INSERT alone (migration
//     0002) and 0006 grants nothing further, so there is no UPDATE or
//     DELETE for this package to refrain from. The standing proof is
//     test/append-only.test.mjs, which fails if this table ever appears
//     in a grant.
//   - One event of each kind per key. The primary key
//     (party_id, key_id, event) refuses the second, so a compromise
//     report cannot be superseded by a later one that disagrees.
//     Append reports that conflict rather than swallowing it.
//
// ledger_ts is never written by this package. It defaults to now() in
// the database, which is what makes it the ledger's stamp rather than a
// caller's claim, and that split is the backdating defence the rule
// rests on (core/kernel/keyevent.go).
//
// Every statement here crosses core/transport, the one seam any SQL path
// in this repo may use (trust-kernel/08, decision 065).
package keylog

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/transport"
)

// The plane and role every statement here runs as. The spine carries
// ordering and commitments, which is what a key event is; identity_app
// is the serving role holding SELECT and INSERT alone.
const (
	spinePlane  = "spine"
	servingRole = "identity_app"
)

// Timestamps cross this seam as microseconds since the epoch, never as
// rendered text. psql renders a timestamptz in the session's TimeZone,
// and a session on a zone with a sub-hour offset (Asia/Kolkata is
// +05:30) renders an offset no fixed hour-only layout can parse, so a
// layout-based reader fails ledger-wide on a setting nothing in this
// repo controls. core/outbox already crosses the same seam with
// extract(epoch) for this reason. Microseconds rather than seconds
// because Postgres stores timestamptz to the microsecond and the
// compromise cut is a strict comparison: truncating to the second would
// move records across it.

// ledgerTSExpr renders one timestamptz column as an integer count of
// microseconds since the epoch, which has one spelling in every session.
// The column name is never caller-supplied: the two call sites below
// pass literals.
func ledgerTSExpr(column string) string {
	return "(extract(epoch FROM " + column + ") * 1000000)::bigint"
}

// parseLedgerTS reads one such value. Any unparsable field is an error
// and never a zero time: a zero time would silently read as "no event
// recorded", which for a compromise report is the permissive answer.
func parseLedgerTS(field, what string) (time.Time, error) {
	micros, err := strconv.ParseInt(field, 10, 64)
	if err != nil {
		return time.Time{}, fmt.Errorf("keylog: %s %q is not an epoch microsecond count: %w", what, field, err)
	}
	return time.UnixMicro(micros).UTC(), nil
}

// Append records one key event. effectiveAt is the reporting party's
// declared moment and is stored as given, backdated or not; the ledger
// timestamp the rule reads is the database's own.
//
// A second event of the same kind for the same party and key is refused
// by the primary key, and the error says so rather than being reported
// as a generic write failure: an operator retrying a compromise report
// needs to know the first one already stands.
func Append(_ context.Context, partyID, keyID string, event kernel.KeyEventKind, effectiveAt time.Time) error {
	if !kernel.ValidKeyEventKind(event) {
		return fmt.Errorf("%w: %q", kernel.ErrUnknownKeyEvent, event)
	}
	_, err := transport.Query(spinePlane, servingRole,
		"INSERT INTO key_event (party_id, key_id, event, effective_at) VALUES ($1, $2, $3, $4)",
		transport.String(partyID),
		transport.String(keyID),
		transport.String(string(event)),
		transport.String(effectiveAt.UTC().Format(time.RFC3339Nano)))
	if err != nil {
		return fmt.Errorf("keylog: recording %s for key %s: %w", event, keyID, err)
	}
	return nil
}

// Events reads one key's events, which is the slice SignatureValid folds
// over. A key is (partyID, keyID) and the predicate names both: the
// identifier alone is public and shared by nobody's consent, so a query
// on it alone returns rows another party wrote about a key it does not
// own. See SignatureValid's comment for what that would let anyone do.
//
// Ordered by the ledger's own stamp so a reader looking at the rows sees
// the order the rule computes with, though the rule's answer does not
// depend on the order they arrive in.
func Events(_ context.Context, partyID, keyID string) ([]kernel.KeyEvent, error) {
	lines, err := transport.Query(spinePlane, servingRole,
		"SELECT party_id, key_id, event, "+
			ledgerTSExpr("effective_at")+", "+ledgerTSExpr("ledger_ts")+
			" FROM key_event WHERE party_id = $1 AND key_id = $2"+
			" ORDER BY ledger_ts, event",
		transport.String(partyID), transport.String(keyID))
	if err != nil {
		return nil, fmt.Errorf("keylog: reading events for key %s: %w", keyID, err)
	}
	events := make([]kernel.KeyEvent, 0, len(lines))
	for _, line := range lines {
		event, err := parseRow(line)
		if err != nil {
			return nil, err
		}
		events = append(events, event)
	}
	return events, nil
}

// SignatureValid answers the rule for one record against the log as it
// stands now. It is the composition callers want, and it is deliberately
// thin: every judgment lives in core/kernel, and this reads rows.
func SignatureValid(ctx context.Context, partyID, keyID string, recordLedgerTS time.Time) (bool, error) {
	events, err := Events(ctx, partyID, keyID)
	if err != nil {
		return false, err
	}
	return kernel.SignatureValid(events, partyID, keyID, recordLedgerTS), nil
}

func parseRow(line string) (kernel.KeyEvent, error) {
	const columns = 5
	fields := transport.SplitRow(line, columns)
	if len(fields) != columns {
		return kernel.KeyEvent{}, fmt.Errorf("keylog: key_event row has %d fields, want %d", len(fields), columns)
	}
	effectiveAt, err := parseLedgerTS(fields[3], "effective_at")
	if err != nil {
		return kernel.KeyEvent{}, err
	}
	ledgerTS, err := parseLedgerTS(fields[4], "ledger_ts")
	if err != nil {
		return kernel.KeyEvent{}, err
	}
	return kernel.KeyEvent{
		PartyID:     fields[0],
		KeyID:       fields[1],
		Event:       kernel.KeyEventKind(fields[2]),
		EffectiveAt: effectiveAt,
		LedgerTS:    ledgerTS,
	}, nil
}
