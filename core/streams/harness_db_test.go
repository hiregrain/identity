//go:build db

package streams_test

// The test-side plumbing for the per-stream chain suite
// (trust-kernel/03). Every statement crosses core/transport, the one
// seam any SQL path in this repo may use (trust-kernel/08, decision
// 065); nothing here constructs a database invocation of its own, which
// is what checks/transport-seam.mjs enforces with no test-file
// exemption.
//
// The package under test runs as identity_app, the serving role holding
// SELECT and INSERT plus the one named UPDATE on stream_heads
// (0007-stream-heads). Owner statements appear here only where the test
// is playing the adversary the chain exists to catch: the table owner,
// who can rewrite history and whom nothing but the chain can contradict.
//
// Two record sources are used. The probe table is a test-scoped table
// created and dropped by the owner, standing in for the record tables
// whose own tasks have not landed yet (attestations, registry events,
// key events, operator actions, worker record writes); this is the same
// posture 0020-cross-plane-outbox took while there was no content table
// to carry. The deletion journal is real, so the deletion journal
// stream is exercised against the table that actually holds its
// records.

import (
	"crypto/rand"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/streams"
	"github.com/hiregrain/identity/core/transport"
)

const probeTable = "stream_record_probe"

// newID returns a random UUIDv4 (decision 075), the id shape every
// stream key and record id takes.
func newID(t *testing.T) string {
	t.Helper()
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		t.Fatalf("id generation: %v", err)
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

// ownerSQL runs a statement as the table owner: harness setup, and the
// adversary's own hand where a test mutates history.
func ownerSQL(t *testing.T, sql string, args ...transport.Arg) []string {
	t.Helper()
	lines, err := transport.Query(streams.Plane, streams.OwnerRole, sql, args...)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return lines
}

// appSQL runs a statement as the serving role and hands back the error,
// which is what the posture assertions read.
func appSQL(sql string, args ...transport.Arg) ([]string, error) {
	return transport.Query(streams.Plane, streams.ServingRole, sql, args...)
}

// TestMain creates the test-scoped record table once and drops it when
// the package's tests are done. Every stream and record id in this
// suite is a fresh UUIDv4, so tests share the table without sharing
// state. A failing run exits non-zero and the next `make db-reset`
// rebuilds from empty, so nothing leaks into a green pipeline, which is
// the same guarantee test/append-only.test.mjs makes about its probe
// objects.
//
// Once, not per test, because a round trip here is a `docker compose
// exec`: setup that costs one invocation per test is setup that
// dominates the suite.
func TestMain(m *testing.M) {
	if err := transport.Tx(streams.Plane, streams.OwnerRole,
		func(tx *transport.Transaction) error {
			if err := tx.Exec("DROP TABLE IF EXISTS " + probeTable + ";"); err != nil {
				return err
			}
			return tx.Exec("CREATE TABLE " + probeTable +
				" (record_id uuid PRIMARY KEY, body text NOT NULL);")
		}); err != nil {
		fmt.Fprintf(os.Stderr, "probe table setup: %v\n", err)
		os.Exit(1)
	}
	code := m.Run()
	if _, err := transport.Query(streams.Plane, streams.OwnerRole,
		"DROP TABLE IF EXISTS "+probeTable); err != nil {
		fmt.Fprintf(os.Stderr, "probe table cleanup: %v\n", err)
		if code == 0 {
			code = 1
		}
	}
	os.Exit(code)
}

// probeSource reads a record back from the probe table. Verification
// recomputes the chain from the record where it lives, so a mutation
// made in this table is exactly the tampering the chain must catch.
type probeSource struct{}

func (probeSource) Records(ids []string) (map[string][]byte, error) {
	return readBodies("SELECT record_id, body FROM "+probeTable+" WHERE record_id IN (", ids)
}

// readBodies runs one two-column id-to-body query over an id list and
// returns what it found. A record that is gone is absent from the map,
// which is how a removed record reaches the min-length rule.
func readBodies(prefix string, ids []string) (map[string][]byte, error) {
	bodies := map[string][]byte{}
	if len(ids) == 0 {
		return bodies, nil
	}
	args := make([]transport.Arg, 0, len(ids))
	placeholders := make([]string, 0, len(ids))
	for i, id := range ids {
		placeholders = append(placeholders, fmt.Sprintf("$%d", i+1))
		args = append(args, transport.String(id))
	}
	lines, err := transport.Query(streams.Plane, streams.ServingRole,
		prefix+strings.Join(placeholders, ", ")+")", args...)
	if err != nil {
		return nil, err
	}
	for _, line := range lines {
		fields := transport.SplitRow(line, 2)
		if len(fields) != 2 {
			return nil, fmt.Errorf("record row has %d columns, want 2", len(fields))
		}
		bodies[fields[0]] = []byte(fields[1])
	}
	return bodies, nil
}

// probeBody is the record a probe id stands for at a given position.
// One expression, used by the writer and by the test that restores a
// record it mutated, so the two cannot drift into two spellings.
func probeBody(id string, n int) []byte {
	return []byte(fmt.Sprintf(`{"kind":"probe","n":%d,"record_id":%q}`, n, id))
}

// writeProbeRecord inserts one record and returns its id and body.
func writeProbeRecord(t *testing.T, n int) (string, []byte) {
	t.Helper()
	id := newID(t)
	body := probeBody(id, n)
	if _, err := appSQL(
		"INSERT INTO "+probeTable+" (record_id, body) VALUES ($1, $2)",
		transport.String(id), transport.String(string(body))); err != nil {
		t.Fatalf("probe insert: %v", err)
	}
	return id, []byte(body)
}

// chainProbeRecords writes n records and appends each to every named
// stream, returning the record ids in position order.
//
// The whole run is one head read and one transaction, which is both
// what a real write path does (the record and its links commit
// together) and what keeps this suite's cost bounded: a round trip here
// is a `docker compose exec`.
func chainProbeRecords(t *testing.T, n int, on ...streams.Stream) []string {
	t.Helper()
	heads, err := streams.Heads(streams.Plane, streams.ServingRole, on)
	if err != nil {
		t.Fatalf("heads: %v", err)
	}
	ids := make([]string, 0, n)
	err = transport.Tx(streams.Plane, streams.ServingRole,
		func(tx *transport.Transaction) error {
			for i := 0; i < n; i++ {
				id := newID(t)
				body := probeBody(id, i)
				if err := tx.Exec(
					"INSERT INTO "+probeTable+" (record_id, body) VALUES ($1, $2);",
					transport.String(id), transport.String(string(body))); err != nil {
					return err
				}
				if err := streams.Stage(tx, streams.Record{
					ID: id, Body: body, Streams: on}, heads); err != nil {
					return err
				}
				ids = append(ids, id)
			}
			return nil
		})
	if err != nil {
		t.Fatalf("chain append: %v", err)
	}
	return ids
}

// mutateProbeRecord rewrites a record in place as the table owner: the
// adversary the chain exists to catch.
func mutateProbeRecord(t *testing.T, id string) {
	t.Helper()
	ownerSQL(t, "UPDATE "+probeTable+" SET body = $1 WHERE record_id = $2",
		transport.String(fmt.Sprintf(`{"kind":"probe","n":9999,"record_id":%q}`, id)),
		transport.String(id))
}

// journalSource reads a deletion journal row back as the record its
// chain committed to. The rendering is one SQL expression used for both
// the write and the read, so the two cannot drift into two spellings of
// one row.
type journalSource struct{}

const journalBodySQL = "SELECT person_id, json_build_object(" +
	"'person_id', person_id, " +
	"'requester_class', requester_class, " +
	"'recorded_at', recorded_at)::text FROM deletion_journal WHERE person_id IN ("

func (journalSource) Records(ids []string) (map[string][]byte, error) {
	return readBodies(journalBodySQL, ids)
}

// writeJournalRow files one real deletion journal row and returns the
// person id, which is both the record id and the stream key for the
// deletion journal chain. The rows are removed by the owner when the
// test ends: the journal is append-only in service, and a test that
// left rows in it would hand the deletion suite's replay a person that
// never existed.
func writeJournalRow(t *testing.T) (string, []byte) {
	t.Helper()
	personID := newID(t)
	if _, err := appSQL(
		"INSERT INTO deletion_journal (person_id, requester_class) VALUES ($1, 'worker')",
		transport.String(personID)); err != nil {
		t.Fatalf("journal insert: %v", err)
	}
	t.Cleanup(func() {
		if _, err := transport.Query(streams.Plane, streams.OwnerRole,
			"DELETE FROM deletion_journal WHERE person_id = $1",
			transport.String(personID)); err != nil {
			t.Errorf("journal cleanup: %v", err)
		}
	})
	bodies, err := journalSource{}.Records([]string{personID})
	if err != nil {
		t.Fatalf("journal read back: %v", err)
	}
	body, found := bodies[personID]
	if !found {
		t.Fatal("journal row did not read back")
	}
	return personID, body
}

// headsOf renders the head projection for comparison across a rebuild.
// updated_at is deliberately absent: a rebuild writes a new one, and
// the claim under test is that the chain facts come back identical, not
// that the note of when they were written does.
func headsOf(t *testing.T) string {
	t.Helper()
	rows, err := streams.AllHeads(streams.Plane, streams.ServingRole)
	if err != nil {
		t.Fatalf("all heads: %v", err)
	}
	rendered := make([]string, 0, len(rows))
	for _, row := range rows {
		rendered = append(rendered, fmt.Sprintf("%s\t%d\t%s",
			row.Stream, row.Position, row.Hash.Hex()))
	}
	return strings.Join(rendered, "\n")
}

// membership reads every link's chain membership as one comparable
// string.
func membership(t *testing.T) string {
	t.Helper()
	out, err := streams.Membership(streams.Plane, streams.ServingRole)
	if err != nil {
		t.Fatalf("membership: %v", err)
	}
	return out
}

// verify walks one stream and returns the verdict.
func verify(t *testing.T, s streams.Stream, source streams.Source) streams.Result {
	t.Helper()
	result, err := streams.Verify(streams.Plane, streams.ServingRole, s, source)
	if err != nil {
		t.Fatalf("verify %s: %v", s, err)
	}
	return result
}
