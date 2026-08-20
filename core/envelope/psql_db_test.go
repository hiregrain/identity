//go:build db

package envelope_test

// The test-side Querier: psql over `docker compose exec`, matching the
// rest of the local pipeline (db/migrate.mjs, the checks). No driver
// dependency exists in core yet, and adding one is not this task's call.
// Envelope statements run as identity_app, the serving role, so every
// assertion here also exercises the append-only posture: the whole
// read/write path works with SELECT and INSERT alone.
//
// Args are substituted as quoted literals. That is safe here because
// core/envelope validates every argument's shape before any SQL (uuid,
// hex, provider name, see the Querier contract in envelope.go), and the
// substitution still refuses a quote character outright.

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
)

const repoRoot = "../.."

// psqlQuerier implements envelope.Querier as the given role on the
// payload plane.
type psqlQuerier struct{ role string }

func (q psqlQuerier) Query(_ context.Context, sql string, args ...string) ([][]string, error) {
	// Highest index first so $10 could never be clobbered by $1.
	for i := len(args); i >= 1; i-- {
		arg := args[i-1]
		if strings.ContainsAny(arg, "'\\\x00") && !isHexLiteral(arg) {
			return nil, fmt.Errorf("psql querier: arg %d contains characters the literal substitution refuses", i)
		}
		sql = strings.ReplaceAll(sql, fmt.Sprintf("$%d", i), quoteLiteral(arg))
	}
	out, err := composePsql(q.role, sql)
	if err != nil {
		return nil, err
	}
	var rows [][]string
	for _, line := range strings.Split(strings.TrimRight(out, "\n"), "\n") {
		if line == "" {
			continue
		}
		rows = append(rows, strings.Split(line, "|"))
	}
	return rows, nil
}

// isHexLiteral admits the one backslash-bearing arg shape (bytea hex).
func isHexLiteral(s string) bool {
	if !strings.HasPrefix(s, `\x`) {
		return false
	}
	_, err := hex.DecodeString(s[2:])
	return err == nil
}

// quoteLiteral renders a validated arg as a SQL literal. Hex bytea args
// use the E-prefixed escape-string form so the backslash survives.
func quoteLiteral(s string) string {
	if isHexLiteral(s) {
		return `E'\\x` + s[2:] + `'`
	}
	return "'" + s + "'"
}

// composePsql runs one statement through the plane container's psql.
func composePsql(role, sql string) (string, error) {
	cmd := exec.Command("docker", "compose", "exec", "-T", "payload",
		"psql", "-U", role, "-d", "payload", "-Atq", "-v", "ON_ERROR_STOP=1", "-c", sql)
	cmd.Dir = repoRoot
	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("psql (%s): %v: %s", role, err, out)
	}
	return string(out), nil
}

// ownerSQL runs a statement as the owner role, test harness setup and
// out-of-band inspection only, never the path under test.
func ownerSQL(t *testing.T, sql string) string {
	t.Helper()
	out, err := composePsql("identity", sql)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.TrimRight(out, "\n")
}

// appSQL runs a raw statement as the serving role, returning the error
// for red-path assertions.
func appSQL(sql string) (string, error) { return composePsql("identity_app", sql) }

// payloadDump returns a full data dump of the payload database.
func payloadDump(t *testing.T) string {
	t.Helper()
	cmd := exec.Command("docker", "compose", "exec", "-T", "payload",
		"pg_dump", "-U", "identity", "payload")
	cmd.Dir = repoRoot
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("pg_dump: %v: %s", err, out)
	}
	return string(out)
}

// newEnv builds the Envelope under the configured provider. The provider
// is chosen by configuration alone (GRAIN_KEY_PROVIDER, default
// software). The tests never construct a concrete provider type, which
// is the swap-by-config-only claim exercised.
func newEnv(t *testing.T) (*envelope.Envelope, keys.Provider) {
	t.Helper()
	name := os.Getenv("GRAIN_KEY_PROVIDER")
	if name == "" {
		name = keys.NameSoftware
	}
	p, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	return envelope.New(psqlQuerier{role: "identity_app"}, p), p
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
