//go:build db

package person_test

// The test-side plumbing: psql over `docker compose exec`, mirroring
// core/envelope's and core/deletion's harnesses. No Postgres driver
// exists in core yet, and adding one is trust-kernel/08's call, not
// this task's.
//
// Every statement the package under test issues runs as identity_app,
// the serving role holding SELECT and INSERT alone (migration 0002), so
// these tests also exercise the claim that signup needs no wider
// privilege than the append-only posture allows.

import (
	"context"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/person"
)

// atRepoRoot moves the test process to the repository root for the rest
// of the test. `docker compose` resolves its project from the working
// directory, and core/outbox's worker shells out with no directory of
// its own, so the whole suite runs from the one place both agree on.
func atRepoRoot(t *testing.T) {
	t.Helper()
	t.Chdir("../..")
}

func composePsql(plane, role, sql string) (string, error) {
	cmd := exec.Command("docker", "compose", "exec", "-T", plane,
		"psql", "-U", role, "-d", plane, "-Atq", "-v", "ON_ERROR_STOP=1", "-c", sql)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("psql (%s as %s): %v: %s", plane, role, err, out)
	}
	return string(out), nil
}

// ownerSQL runs a statement as the owner role: harness inspection only,
// never the path under test.
func ownerSQL(t *testing.T, plane, sql string) string {
	t.Helper()
	out, err := composePsql(plane, "identity", sql)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.TrimRight(out, "\n")
}

// roleSQL runs a raw statement as the given role and hands back the
// error, which is what the red-path assertions read.
func roleSQL(plane, role, sql string) (string, error) {
	return composePsql(plane, role, sql)
}

// payloadDump returns a full data dump of the payload database, the
// plaintext-absence probe's input.
func payloadDump(t *testing.T) string {
	t.Helper()
	cmd := exec.Command("docker", "compose", "exec", "-T", "payload",
		"pg_dump", "-U", "identity", "payload")
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("pg_dump: %v: %s", err, out)
	}
	return string(out)
}

// spinePsql implements person.Spine as identity_app on the spine plane.
type spinePsql struct{}

func (spinePsql) Script(_ context.Context, sql string) error {
	cmd := exec.Command("docker", "compose", "exec", "-T", "spine",
		"psql", "-U", "identity_app", "-d", "spine", "-v", "ON_ERROR_STOP=1", "-f", "-")
	cmd.Stdin = strings.NewReader(sql)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("spine script: %v: %s", err, out)
	}
	return nil
}

func (spinePsql) Rows(_ context.Context, query string) ([]string, error) {
	out, err := composePsql("spine", "identity_app", query)
	if err != nil {
		return nil, err
	}
	trimmed := strings.TrimSpace(out)
	if trimmed == "" {
		return nil, nil
	}
	return strings.Split(trimmed, "\n"), nil
}

// payloadQuerier implements envelope.Querier as identity_app on the
// payload plane. Copied in shape from core/envelope's harness: args are
// substituted as quoted literals, which is safe only because
// core/envelope validates every argument's shape first, and the
// substitution still refuses a quote character outright.
type payloadQuerier struct{}

func (payloadQuerier) Query(_ context.Context, sql string, args ...string) ([][]string, error) {
	for i := len(args); i >= 1; i-- {
		arg := args[i-1]
		if strings.ContainsAny(arg, "'\\\x00") && !isHexLiteral(arg) {
			return nil, fmt.Errorf("payload querier: arg %d contains characters the literal substitution refuses", i)
		}
		sql = strings.ReplaceAll(sql, fmt.Sprintf("$%d", i), quoteLiteral(arg))
	}
	out, err := composePsql("payload", "identity_app", sql)
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

func isHexLiteral(s string) bool {
	if !strings.HasPrefix(s, `\x`) {
		return false
	}
	_, err := hex.DecodeString(s[2:])
	return err == nil
}

func quoteLiteral(s string) string {
	if isHexLiteral(s) {
		return `E'\\x` + s[2:] + `'`
	}
	return "'" + s + "'"
}

// newService builds the service under the configured key provider. The
// provider is chosen by configuration alone (GRAIN_KEY_PROVIDER,
// default software), exactly as core/envelope's suite does it.
func newService(t *testing.T) (*person.Service, *envelope.Envelope) {
	t.Helper()
	name := os.Getenv("GRAIN_KEY_PROVIDER")
	if name == "" {
		name = keys.NameSoftware
	}
	p, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	env := envelope.New(payloadQuerier{}, p)
	return person.New(spinePsql{}, env), env
}
