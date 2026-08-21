//go:build db

package person_test

// The test-side plumbing: core/transport, the one seam every SQL path in
// this repo crosses (trust-kernel/08, decision 065). Nothing here
// constructs a database invocation of its own, which is what
// checks/transport-seam.mjs enforces with no test-file exemption.
//
// Every statement the package under test issues runs as identity_app,
// the serving role holding SELECT and INSERT alone (migration 0002), so
// these tests also exercise the claim that signup needs no wider
// privilege than the append-only posture allows.

import (
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// ownerSQL runs a statement as the owner role: harness inspection only,
// never the path under test.
func ownerSQL(t *testing.T, plane, sql string, args ...transport.Arg) string {
	t.Helper()
	lines, err := transport.Query(plane, "identity", sql, args...)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.Join(lines, "\n")
}

// roleSQL runs a raw statement as the given role and hands back the
// error, which is what the red-path assertions read.
func roleSQL(plane, role, sql string, args ...transport.Arg) (string, error) {
	lines, err := transport.Query(plane, role, sql, args...)
	if err != nil {
		return "", err
	}
	return strings.Join(lines, "\n"), nil
}

// payloadDump returns a full data dump of the payload database, the
// plaintext-absence probe's input.
func payloadDump(t *testing.T) string {
	t.Helper()
	out, err := transport.Dump("payload")
	if err != nil {
		t.Fatalf("pg_dump: %v", err)
	}
	return out
}

// newService builds the service under the configured key provider. The
// provider is chosen by configuration alone (GRAIN_KEY_PROVIDER,
// default software), exactly as core/envelope's suite does it.
func newService(t *testing.T) (*person.Service, *envelope.Envelope) {
	t.Helper()
	name, _ := keys.ConfiguredProviderName()
	p, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	env := envelope.New(
		transport.EnvelopeQuerier{Plane: "payload", Role: "identity_app"}, p)
	return person.New(env, person.NewChannelIndex(p)), env
}
