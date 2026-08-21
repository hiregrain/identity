// Package deletion is the deletion-promise runner (foundation/08,
// decisions 014, 017; design ledger-design-0.1 §2.5). foundation/05
// owns the destroy PRIMITIVE (core/envelope: destroy the key, content
// becomes unreadable); this package owns what makes the PROMISE true.
// That is the spine deletion journal, the restore-time replay that gates a
// restored payload plane, and the scheduled physical purge of shredded
// rows.
//
// Write ordering for a destruction, executed by Destroy: the journal
// row commits FIRST on the spine (migration 0021, the record a future
// restore replays), then the payload-plane destroy (core/envelope:
// registry row, then provider shred). Every half is idempotent, so a
// crash anywhere is retried forward by running Destroy again with the
// same closure, the same recovery grammar as the cross-plane outbox
// (foundation/07), and for the same reason there is no compensation
// path: the spine is append-only.
//
// Replay is a GATE, not a cleanup step: db/restore.mjs appends a
// restore_gate 'restored' row inside the restore transaction itself,
// core/envelope refuses every serving path while any 'restored' row is
// unbalanced, and Replay appends the balancing 'replayed' row only
// after re-destroying every journaled person. A crash mid-replay leaves
// the gate closed and the rerun is a no-op over what already completed.
//
// Purge runs as identity_purge, the only role holding DELETE on any
// payload table (0022's licensed exemption, enumerated in
// test/append-only.test.mjs), and row security narrows even that role
// to shredded 'created' rows. The deletes and the purge_audit row
// commit in ONE transaction: a purge that removed rows without its
// audit row is not representable. The schedule is the stated number in
// db/deletion-policy.json (purge_interval_days); until real scheduling
// infrastructure exists, running `deletion purge` on that cadence is an
// operational duty, exactly as the reconciler's alert is an exit code
// (core/outbox).
//
// Database access goes through core/transport (trust-kernel/08,
// decision 065), the one seam every SQL path in the repo crosses:
// journal, gate and registry statements run as identity_app
// (SELECT+INSERT only), the purge transaction as identity_purge. No
// owner or migration credential appears here (checks/serving-credentials.mjs).
package deletion

import (
	"context"
	"crypto/rand"
	"fmt"
	"regexp"
	"strings"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/transport"
)

// RequesterClasses is the closed vocabulary of who a destruction is
// recorded for (migration 0021's CHECK): 'worker', the in-app control
// that files the deletion request (decision 038); 'support', the
// support-mediated execution path (decision 036).
var RequesterClasses = []string{"worker", "support"}

// Destroy records and executes the destruction of every person id in
// the alias closure. The closure contract is envelope.Destroy's: the
// caller supplies the COMPLETE closure, canonical id included; an
// unmerged person is the single-element set. Journal first, per id
// (idempotent, deletion_journal_one_per_person plus ON CONFLICT DO
// NOTHING), then the payload destroy for the whole closure. Retry
// forward on any failure by calling Destroy again.
//
// The envelope is the caller's: foundation/05 owns the destroy
// primitive, and this package runs it rather than constructing its own.
// One provider instance per process is also what makes the software
// provider's in-memory shred coherent (decision 011). The CLI builds
// one with NewEnvelope.
func Destroy(ctx context.Context, env *envelope.Envelope, closure []string, requester string) error {
	if !validRequester(requester) {
		return fmt.Errorf("deletion: requester class %q is not one of %s",
			requester, strings.Join(RequesterClasses, ", "))
	}
	if len(closure) == 0 {
		return fmt.Errorf("deletion: destroy requires a non-empty alias closure")
	}
	for _, person := range closure {
		if !validUUID(person) {
			return fmt.Errorf("deletion: person id %q is not a lowercase uuid", person)
		}
	}
	for _, person := range closure {
		if _, err := transport.Query("spine", "identity_app", `
			INSERT INTO deletion_journal (person_id, requester_class)
			VALUES ($1, $2)
			ON CONFLICT (person_id) DO NOTHING;`,
			transport.String(person), transport.String(requester)); err != nil {
			return fmt.Errorf("deletion: journal %s: %w", person, err)
		}
	}
	if err := env.Destroy(ctx, closure); err != nil {
		return fmt.Errorf("deletion: payload destroy: %w", err)
	}
	return nil
}

// Replay re-applies the whole deletion journal to the payload plane and
// then balances every open restore gate. Order is the point: no
// 'replayed' row is written until every journaled person is
// re-destroyed, so a crash mid-replay leaves the restored system still
// refusing traffic and the rerun completes idempotently. Run against a
// never-restored system it is a harmless no-op that re-destroys
// already-destroyed people.
func Replay(ctx context.Context, env *envelope.Envelope) (replayed int, err error) {
	people, err := transport.Query("spine", "identity_app",
		"SELECT person_id FROM deletion_journal ORDER BY recorded_at, person_id")
	if err != nil {
		return 0, fmt.Errorf("deletion: replay: reading the journal: %w", err)
	}
	for _, person := range people {
		// One id per call: the journal already holds every member of a
		// destroyed closure as its own row (Destroy journals per id),
		// so no closure computation happens here.
		if err := env.Destroy(ctx, []string{person}); err != nil {
			return replayed, fmt.Errorf("deletion: replay %s: %w", person, err)
		}
		replayed++
	}
	open, err := openRestores()
	if err != nil {
		return replayed, err
	}
	for _, restoreID := range open {
		if _, err := transport.Query("payload", "identity_app", `
			INSERT INTO restore_gate (restore_id, event, residency_region)
			SELECT $1, 'replayed', residency_region FROM database_residency
			ON CONFLICT (restore_id, event) DO NOTHING;`,
			transport.String(restoreID)); err != nil {
			return replayed, fmt.Errorf("deletion: replay: balancing restore %s: %w", restoreID, err)
		}
		fmt.Printf("replay: restore %s balanced, the payload plane serves again\n", restoreID)
	}
	fmt.Printf("replay: %d journaled destruction(s) re-applied, %d open restore(s) balanced\n",
		len(people), len(open))
	return replayed, nil
}

// PurgeResult is one audited purge run.
type PurgeResult struct {
	RunID       string
	RowsDeleted int
}

// Purge physically removes every shredded 'created' registry row,
// dead wrapped-DEK ciphertext whose person already holds a 'destroyed'
// row, and writes the run's purge_audit row in the same transaction,
// all as identity_purge. The WHERE clause states the intent; row
// security (0022) enforces the same boundary even without it. A run
// that removes nothing still writes its audit row, so the stated
// schedule's execution is itself auditable. initiatedBy names who asked
// for the run and is recorded alongside session_user.
func Purge(initiatedBy string) (PurgeResult, error) {
	if !validInitiator(initiatedBy) {
		return PurgeResult{}, fmt.Errorf(
			"deletion: initiated-by %q must be 1-200 characters of [A-Za-z0-9._@-]", initiatedBy)
	}
	runID, err := newUUID()
	if err != nil {
		return PurgeResult{}, err
	}
	if err := transport.Tx("payload", "identity_purge", func(tx *transport.Transaction) error {
		return tx.Exec(`
			WITH removed AS (
			  DELETE FROM dek_registry
			   WHERE event = 'created' AND dek_destroyed(person_id)
			   RETURNING 1)
			INSERT INTO purge_audit
			  (run_id, purged_table, rows_deleted, initiated_by, executed_as, residency_region)
			SELECT $1, 'dek_registry', count(*), $2, session_user,
			       (SELECT residency_region FROM database_residency)
			  FROM removed;`,
			transport.String(runID), transport.String(initiatedBy))
	}); err != nil {
		return PurgeResult{}, fmt.Errorf("deletion: purge run %s: %w", runID, err)
	}
	counted, err := transport.Query("payload", "identity_app",
		"SELECT rows_deleted FROM purge_audit WHERE run_id = $1 AND purged_table = 'dek_registry'",
		transport.String(runID))
	if err != nil || len(counted) != 1 {
		return PurgeResult{}, fmt.Errorf("deletion: purge run %s committed but its audit row is unreadable: %w", runID, err)
	}
	deleted := 0
	if _, err := fmt.Sscanf(counted[0], "%d", &deleted); err != nil {
		return PurgeResult{}, fmt.Errorf("deletion: purge run %s: malformed audit count %q", runID, counted[0])
	}
	fmt.Printf("purge: run %s removed %d shredded row(s) from dek_registry (audited, initiated by %s)\n",
		runID, deleted, initiatedBy)
	return PurgeResult{RunID: runID, RowsDeleted: deleted}, nil
}

// OpenRestores lists the restore_ids of restores that have not been
// replayed, the state core/envelope's serving gate refuses on. Empty
// means serving.
func OpenRestores() ([]string, error) { return openRestores() }

func openRestores() ([]string, error) {
	ids, err := transport.Query("payload", "identity_app", `
		SELECT r.restore_id FROM restore_gate r
		 WHERE r.event = 'restored'
		   AND NOT EXISTS (
		     SELECT 1 FROM restore_gate g
		      WHERE g.restore_id = r.restore_id AND g.event = 'replayed')
		 ORDER BY r.noted_at, r.restore_id`)
	if err != nil {
		return nil, fmt.Errorf("deletion: reading the restore gate: %w", err)
	}
	return ids, nil
}

// --- envelope plumbing -------------------------------------------------

// NewEnvelope builds the destroy primitive over the payload plane as
// identity_app, under the configured key provider (GRAIN_KEY_PROVIDER,
// default software, the same configuration seam as everywhere else).
// The Querier is transport's production implementation of envelope's
// interface, wired at composition (decision 065): envelope's own
// package stays transport-free.
func NewEnvelope() (*envelope.Envelope, error) {
	name, _ := keys.ConfiguredProviderName()
	provider, err := keys.FromConfig(name)
	if err != nil {
		return nil, fmt.Errorf("deletion: key provider: %w", err)
	}
	return envelope.New(transport.EnvelopeQuerier{Plane: "payload", Role: "identity_app"}, provider), nil
}

// --- validation --------------------------------------------------------

var (
	uuidPattern = regexp.MustCompile(
		`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)
	initiatorPattern = regexp.MustCompile(`^[A-Za-z0-9._@-]{1,200}$`)
)

func validUUID(s string) bool { return uuidPattern.MatchString(s) }

func validRequester(s string) bool {
	for _, r := range RequesterClasses {
		if s == r {
			return true
		}
	}
	return false
}

func validInitiator(s string) bool { return initiatorPattern.MatchString(s) }

// newUUID generates a lowercase v4 uuid for a purge run id.
func newUUID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", fmt.Errorf("deletion: uuid: %w", err)
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}
