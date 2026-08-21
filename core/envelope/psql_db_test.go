//go:build db

package envelope_test

// The test-side Querier: core/transport's production adapter, matching
// the rest of the local pipeline (db/migrate.mjs, the checks) and the
// one seam every SQL path in the repo crosses (trust-kernel/08,
// decision 065). No driver dependency exists in core yet, and adding
// one is not this task's call.

import (
	"crypto/rand"
	"fmt"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/transport"
)

// ownerSQL runs a statement as the owner role, test harness setup and
// out-of-band inspection only, never the path under test.
func ownerSQL(t *testing.T, sql string) string {
	t.Helper()
	lines, err := transport.Query("payload", "identity", sql)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.Join(lines, "\n")
}

// appSQL runs a raw statement as the serving role, returning the error
// for red-path assertions.
func appSQL(sql string) (string, error) {
	lines, err := transport.Query("payload", "identity_app", sql)
	if err != nil {
		return "", err
	}
	return strings.Join(lines, "\n"), nil
}

// payloadDump returns a full data dump of the payload database.
func payloadDump(t *testing.T) string {
	t.Helper()
	out, err := transport.Dump("payload")
	if err != nil {
		t.Fatalf("pg_dump: %v", err)
	}
	return out
}

// newEnv builds the Envelope under the configured provider. The provider
// is chosen by configuration alone (GRAIN_KEY_PROVIDER, default
// software). The tests never construct a concrete provider type, which
// is the swap-by-config-only claim exercised.
func newEnv(t *testing.T) (*envelope.Envelope, keys.Provider) {
	t.Helper()
	name, _ := keys.ConfiguredProviderName()
	p, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	return envelope.New(transport.EnvelopeQuerier{Plane: "payload", Role: "identity_app"}, p), p
}

// newPersonID generates a fresh lowercase uuid (v4) ledger id.
func newPersonID(t *testing.T) string {
	t.Helper()
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		t.Fatalf("uuid: %v", err)
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

// contentTable creates the test-scoped content table and registers its
// drop. No payload content table exists in the migration chain yet,
// later layers own product tables, so the read/write path is exercised
// against harness-scoped tables, plus the DEK registry which IS this
// task's migration (foundation/05's stated boundary).
func contentTable(t *testing.T) string {
	t.Helper()
	name := "envelope_harness_content"
	ownerSQL(t, `CREATE TABLE IF NOT EXISTS `+name+` (
        subject_person_id spine_object_id NOT NULL,
        counterparty_person_id spine_object_id,
        body bytea NOT NULL,
        residency_region residency_region NOT NULL DEFAULT 'us')`)
	t.Cleanup(func() { ownerSQL(t, "DROP TABLE IF EXISTS "+name) })
	return name
}
