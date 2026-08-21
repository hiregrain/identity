// Package outbox is the cross-plane write worker (foundation/07,
// decision 017): it enqueues spine-first transactional outbox entries,
// drains them into idempotent payload applies, and reconciles
// stragglers. The spine commit of an outbox row is what "recorded"
// means; an entry is acknowledged only when both planes are durable,
// which is a queryable state (the cross_plane_acknowledged view,
// migration 0020), never a callback.
//
// Database access goes through core/transport (trust-kernel/08,
// decision 065), the one seam every SQL path in the repo crosses. That
// package's compose-exec adapter matches db/connections.json's posture
// and the rest of this repo's dependency-free pipeline. identity_app
// holds SELECT+INSERT only (migration 0002), which is the whole
// vocabulary this worker needs: completion is a following row, never
// an UPDATE.
//
// Crash points: every mid-flight step names an injection point
// (CrashPoints) at which the process exits immediately when the
// -crash-point flag matches, via transport.Tx's CrashPoint. This is how
// the acceptance harness (test/cross-plane-outbox.test.mjs) and the
// outside check kill the worker deterministically between the two
// planes.
package outbox

import (
	"encoding/base64"
	"fmt"
	"os"
	"strings"

	"github.com/hiregrain/identity/core/transport"
)

// Crash injection points, in flight order. "" disables injection.
const (
	CrashBeforeSpineCommit  = "before-spine-commit"  // enqueue: spine txn open, not committed
	CrashBeforePayloadApply = "before-payload-apply" // drain: entry selected, payload untouched
	CrashMidPayloadApply    = "mid-payload-apply"    // drain: payload txn open, not committed
	CrashAfterPayloadApply  = "after-payload-apply"  // drain: payload committed, no ack row yet
)

// CrashPoints enumerates the valid -crash-point values.
var CrashPoints = []string{
	CrashBeforeSpineCommit,
	CrashBeforePayloadApply,
	CrashMidPayloadApply,
	CrashAfterPayloadApply,
}

// crash exits the process mid-flight when the configured point matches,
// for the one crash point (CrashBeforePayloadApply) that has no
// statement of its own to flush first.
func crash(configured, point string) {
	if configured != point {
		return
	}
	fmt.Fprintf(os.Stderr, "crash-point %s: exiting mid-flight (test injection)\n", point)
	os.Exit(3)
}

// Enqueue writes the outbox entry in one spine transaction. The caller
// composes any accompanying spine writes into the same script when they
// exist; today the entry is the spine write. With crashPoint set to
// CrashBeforeSpineCommit the process exits with the transaction open,
// which must leave nothing on either plane.
func Enqueue(entryID string, instruction []byte, crashPoint string) error {
	if err := validUUID(entryID); err != nil {
		return err
	}
	b64 := base64.StdEncoding.EncodeToString(instruction)
	return transport.Tx("spine", "identity_app", func(tx *transport.Transaction) error {
		if err := tx.Exec(
			`INSERT INTO cross_plane_outbox (entry_id, target_plane, instruction)
			 VALUES ($1, 'payload', decode($2, 'base64'));`,
			transport.String(entryID), transport.String(b64)); err != nil {
			return err
		}
		tx.CrashPoint(crashPoint, CrashBeforeSpineCommit)
		return nil
	})
}

// Pending lists outbox entries with no 'applied' row, oldest first.
func Pending() ([]Entry, error) {
	lines, err := transport.Query("spine", "identity_app", `
		SELECT o.entry_id, replace(encode(o.instruction, 'base64'), E'\n', '')
		  FROM cross_plane_outbox o
		 WHERE NOT EXISTS (
		    SELECT 1 FROM cross_plane_outbox_attempts a
		     WHERE a.entry_id = o.entry_id AND a.state = 'applied')
		 ORDER BY o.created_at, o.entry_id`)
	if err != nil {
		return nil, err
	}
	entries := make([]Entry, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 2)
		if len(fields) != 2 {
			return nil, fmt.Errorf("pending: malformed row %q", line)
		}
		id, b64 := fields[0], fields[1]
		raw, err := base64.StdEncoding.DecodeString(b64)
		if err != nil {
			return nil, fmt.Errorf("pending: entry %s: %w", id, err)
		}
		entries = append(entries, Entry{ID: id, Instruction: raw})
	}
	return entries, nil
}

// Entry is one drained outbox row.
type Entry struct {
	ID          string
	Instruction []byte
}

// Get fetches one entry by id, acknowledged or not. This is the manual-replay
// path: re-applying an acknowledged entry must be a payload no-op.
func Get(entryID string) (Entry, error) {
	if err := validUUID(entryID); err != nil {
		return Entry{}, err
	}
	lines, err := transport.Query("spine", "identity_app",
		"SELECT replace(encode(instruction, 'base64'), E'\\n', '') FROM cross_plane_outbox WHERE entry_id = $1",
		transport.String(entryID))
	if err != nil {
		return Entry{}, err
	}
	if len(lines) == 0 {
		return Entry{}, fmt.Errorf("get: no outbox entry %s", entryID)
	}
	raw, err := base64.StdEncoding.DecodeString(lines[0])
	if err != nil {
		return Entry{}, fmt.Errorf("get: entry %s: %w", entryID, err)
	}
	return Entry{ID: entryID, Instruction: raw}, nil
}

// Apply applies one entry's instruction to the payload plane in one
// payload transaction. Idempotent by the database, not by memory: the
// INSERT carries ON CONFLICT (outbox_entry_id) DO NOTHING against the
// target table's unique idempotency key, so applying the same entry any
// number of times produces one payload row.
func Apply(entry Entry, crashPoint string) error {
	instruction, err := Parse(entry.Instruction)
	if err != nil {
		return err
	}
	insert, err := instruction.ApplySQL(entry.ID)
	if err != nil {
		return err
	}
	return transport.Tx("payload", "identity_app", func(tx *transport.Transaction) error {
		tx.ExecLiteral(insert)
		tx.CrashPoint(crashPoint, CrashMidPayloadApply)
		return nil
	})
}

// note appends a progress row. Append-only: completion and failure are
// both FOLLOWING rows in cross_plane_outbox_attempts, never updates.
// The guard skips already-acknowledged entries so a raced or replayed
// worker cannot double-acknowledge.
func note(entryID, state, detail string) error {
	_, err := transport.Query("spine", "identity_app", `
		INSERT INTO cross_plane_outbox_attempts (entry_id, attempt, state, detail)
		SELECT $1,
		       coalesce((SELECT max(attempt) FROM cross_plane_outbox_attempts
		                  WHERE entry_id = $1), 0) + 1,
		       $2, $3
		 WHERE NOT EXISTS (
		    SELECT 1 FROM cross_plane_outbox_attempts
		     WHERE entry_id = $1 AND state = 'applied');`,
		transport.String(entryID), transport.String(state), transport.String(detail))
	return err
}

// Drain processes every pending entry once: apply to payload, then
// acknowledge with an 'applied' row. A failed apply is recorded as a
// 'failed' row and the drain moves on. Surfacing persistent failures
// is Reconcile's job, and retrying is simply draining again. The return
// counts what happened; the error is reserved for the worker's own
// plumbing failing, not for entries failing.
func Drain(crashPoint string) (applied, failed int, err error) {
	entries, err := Pending()
	if err != nil {
		return 0, 0, err
	}
	for _, entry := range entries {
		crash(crashPoint, CrashBeforePayloadApply)
		if applyErr := Apply(entry, crashPoint); applyErr != nil {
			failed++
			fmt.Printf("drain: entry %s attempt failed: %s\n", entry.ID, firstLine(applyErr.Error()))
			if noteErr := note(entry.ID, "failed", firstLine(applyErr.Error())); noteErr != nil {
				return applied, failed, noteErr
			}
			continue
		}
		crash(crashPoint, CrashAfterPayloadApply)
		if noteErr := note(entry.ID, "applied", ""); noteErr != nil {
			return applied, failed, noteErr
		}
		applied++
		fmt.Printf("drain: entry %s applied and acknowledged\n", entry.ID)
	}
	fmt.Printf("drain: %d applied, %d failed, %d pending seen\n", applied, failed, len(entries))
	return applied, failed, nil
}

// Reconcile surfaces every entry unacknowledged for longer than the
// threshold: one queue-item line per entry and a non-zero result when
// any exist. Silent backlog is the failure mode this exists to prevent.
// Until real alerting infrastructure exists, "surfaces as an alert"
// means this command's non-zero exit in a pipeline, with the threshold
// documented at the call site (Makefile).
func Reconcile(thresholdSeconds int) (stragglers int, err error) {
	lines, err := transport.Query("spine", "identity_app", `
		SELECT o.entry_id,
		       floor(extract(epoch FROM now() - o.created_at))::bigint,
		       coalesce((SELECT max(a.attempt) FROM cross_plane_outbox_attempts a
		                  WHERE a.entry_id = o.entry_id), 0),
		       coalesce((SELECT a.detail FROM cross_plane_outbox_attempts a
		                  WHERE a.entry_id = o.entry_id
		                  ORDER BY a.attempt DESC LIMIT 1), '')
		  FROM cross_plane_outbox o
		 WHERE NOT EXISTS (
		    SELECT 1 FROM cross_plane_outbox_attempts a
		     WHERE a.entry_id = o.entry_id AND a.state = 'applied')
		   AND now() - o.created_at > ($1 || ' seconds')::interval
		 ORDER BY o.created_at, o.entry_id`,
		transport.Float(float64(thresholdSeconds)))
	if err != nil {
		return 0, err
	}
	for _, line := range lines {
		parts := transport.SplitRow(line, 4)
		if len(parts) < 3 {
			return 0, fmt.Errorf("reconcile: malformed row %q", line)
		}
		detail := ""
		if len(parts) == 4 {
			detail = parts[3]
		}
		fmt.Printf("reconcile: QUEUE entry %s unacknowledged for %ss, %s attempt(s), last detail: %s\n",
			parts[0], parts[1], parts[2], detail)
	}
	if len(lines) > 0 {
		fmt.Printf("reconcile: ALERT %d entrie(s) past the %ds threshold\n", len(lines), thresholdSeconds)
	} else {
		fmt.Printf("reconcile: no entries past the %ds threshold\n", thresholdSeconds)
	}
	return len(lines), nil
}

// Acknowledged reports whether an entry appears in the queryable
// acknowledgment state (the cross_plane_acknowledged view).
func Acknowledged(entryID string) (bool, error) {
	if err := validUUID(entryID); err != nil {
		return false, err
	}
	lines, err := transport.Query("spine", "identity_app",
		"SELECT 1 FROM cross_plane_acknowledged WHERE entry_id = $1", transport.String(entryID))
	if err != nil {
		return false, err
	}
	return len(lines) > 0, nil
}

// firstLine truncates error text to its sanitized first line. Postgres
// first lines name relations, constraints and privileges, not row
// values, which is the write-site discipline the detail column's
// justification (migration 0020) records.
func firstLine(s string) string {
	line := strings.TrimSpace(s)
	if i := strings.IndexByte(line, '\n'); i >= 0 {
		line = line[:i]
	}
	const maxLen = 200
	if len(line) > maxLen {
		line = line[:maxLen]
	}
	return line
}
