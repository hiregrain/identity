//go:build db

// The deletion-mechanics acceptance tests (foundation/08; layer
// criterion foundation-6, and the restore-side half of foundation-7's
// promise). Run by `make deletion-test` against both live planes,
// requiring Docker, Go and Node (the backup/restore scripts are
// db/backup.mjs and db/restore.mjs, driven here exactly as an operator
// runs them). The restore scenario recreates the payload container from
// a real pg_dump backup mid-test. On the green path the suite leaves
// both planes migrated and consistent; on a failure the next
// `make db-reset && make migrate` rebuilds from empty.
package deletion_test

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/hiregrain/identity/core/deletion"
	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/transport"
)

const repoRoot = "../.."

// --- plumbing ------------------------------------------------------------
//
// Every database invocation goes through core/transport (trust-kernel/08,
// decision 065), the one seam every SQL path in the repo crosses. node
// (the operator scripts, db/backup.mjs and db/restore.mjs) is not a
// database invocation and stays a direct exec.Command.

// ownerSQL runs a statement as the owner role, harness setup and
// out-of-band inspection only, never the path under test.
func ownerSQL(t *testing.T, plane, sql string) string {
	t.Helper()
	lines, err := transport.Query(plane, "identity", sql)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.Join(lines, "\n")
}

// roleSQL runs a raw statement as the given role, returning the error
// for red-path assertions.
func roleSQL(plane, role, sql string) (string, error) {
	lines, err := transport.Query(plane, role, sql)
	if err != nil {
		return "", err
	}
	return strings.Join(lines, "\n"), nil
}

// node runs one of the operator scripts (db/backup.mjs, db/restore.mjs)
// from the repo root, exactly as an operator would.
func node(t *testing.T, args ...string) string {
	t.Helper()
	cmd := exec.Command("node", args...)
	cmd.Dir = repoRoot
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("node %s: %v:\n%s", strings.Join(args, " "), err, out)
	}
	return string(out)
}

// fullDump returns a complete schema+data pg_dump of a plane.
func fullDump(t *testing.T, plane string) string {
	t.Helper()
	out, err := transport.Dump(plane)
	if err != nil {
		t.Fatalf("pg_dump(%s): %v", plane, err)
	}
	return out
}

func newEnv(t *testing.T) (*envelope.Envelope, keys.Provider) {
	t.Helper()
	name, _ := keys.ConfiguredProviderName()
	p, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	return envelope.New(transport.EnvelopeQuerier{Plane: "payload", Role: "identity_app"}, p), p
}

func newPersonID(t *testing.T) string {
	t.Helper()
	raw := ownerSQL(t, "payload", "SELECT gen_random_uuid()")
	return strings.TrimSpace(raw)
}

// contentTable creates the harness-scoped payload content table (no
// product content table exists yet by design, foundation/05's stated
// boundary) and registers its drop.
func contentTable(t *testing.T) string {
	t.Helper()
	name := "deletion_harness_content"
	ownerSQL(t, "payload", `CREATE TABLE IF NOT EXISTS `+name+` (
        subject_person_id spine_object_id NOT NULL,
        body bytea NOT NULL,
        residency_region residency_region NOT NULL DEFAULT 'us')`)
	t.Cleanup(func() {
		_, _ = transport.Query("payload", "identity", "DROP TABLE IF EXISTS "+name)
	})
	return name
}

func provisionWithContent(t *testing.T, env *envelope.Envelope, table, marker string) (person string, ciphertext []byte) {
	t.Helper()
	ctx := context.Background()
	person = newPersonID(t)
	if err := env.Provision(ctx, person); err != nil {
		t.Fatalf("Provision: %v", err)
	}
	ciphertext, err := env.Encrypt(ctx, person, []byte(marker))
	if err != nil {
		t.Fatalf("Encrypt: %v", err)
	}
	if _, err := roleSQL("payload", "identity_app", fmt.Sprintf(
		`INSERT INTO %s (subject_person_id, body) VALUES ('%s', E'\\x%x')`,
		table, person, ciphertext)); err != nil {
		t.Fatalf("content insert as identity_app: %v", err)
	}
	return person, ciphertext
}

func grepAbsent(t *testing.T, dump, marker, where string) {
	t.Helper()
	forms := map[string]string{
		"plaintext": marker,
		"hex":       hex.EncodeToString([]byte(marker)),
	}
	for form, needle := range forms {
		if strings.Contains(dump, needle) {
			t.Fatalf("%s dump contains the marker in %s form", where, form)
		}
	}
}

// --- criterion: restore + replay leaves nothing readable; a restored
// --- system that has not replayed refuses traffic ----------------------

func TestRestoreReplayGateEndToEnd(t *testing.T) {
	ctx := context.Background()
	env, provider := newEnv(t)
	table := contentTable(t)

	deletedMarker := "DELETED-PERSON-MARKER-8f4c1f0e"
	livingMarker := "LIVING-PERSON-MARKER-2b9d7a31"
	deleted, deletedCipher := provisionWithContent(t, env, table, deletedMarker)
	living, _ := provisionWithContent(t, env, table, livingMarker)

	// A real pg_dump backup, taken BEFORE the deletion, the scenario
	// decision 017 exists for.
	backups := filepath.Join(t.TempDir(), "backups")
	node(t, "db/backup.mjs", backups)
	entries, err := os.ReadDir(backups)
	if err != nil || len(entries) != 1 {
		t.Fatalf("expected exactly one dump in %s: %v", backups, err)
	}
	dumpFile := filepath.Join(backups, entries[0].Name())

	// Destroy: journal first (spine), then the payload keys.
	if err := deletion.Destroy(ctx, env, []string{deleted}, "worker"); err != nil {
		t.Fatalf("Destroy: %v", err)
	}
	journal := ownerSQL(t, "spine", fmt.Sprintf(
		"SELECT requester_class FROM deletion_journal WHERE person_id = '%s'", deleted))
	if journal != "worker" {
		t.Fatalf("journal row missing or wrong: %q", journal)
	}
	if _, err := env.Decrypt(ctx, deleted, deletedCipher); !errors.Is(err, envelope.ErrNoActiveDEK) {
		t.Fatalf("post-destroy Decrypt: want ErrNoActiveDEK, got %v", err)
	}

	// Restore the pre-deletion backup: the person is back at the byte
	// level, the wrapped DEK row exists again, which is exactly the
	// resurrection the gate and the replay exist to close.
	node(t, "db/restore.mjs", dumpFile)
	resurrected := ownerSQL(t, "payload", fmt.Sprintf(
		"SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'created'", deleted))
	if resurrected != "1" {
		t.Fatalf("restored backup does not hold the pre-deletion created row (count %s), scenario broken", resurrected)
	}
	if destroyed := ownerSQL(t, "payload", fmt.Sprintf(
		"SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'destroyed'", deleted)); destroyed != "0" {
		t.Fatalf("restored backup already holds a destroyed row, the backup was not pre-deletion")
	}

	// GATED: a restored system that has not replayed refuses traffic on
	// every serving path, including for the living person, and the
	// refusal is ErrNotServing, never "this person was deleted".
	if _, err := env.Decrypt(ctx, living, deletedCipher); !errors.Is(err, envelope.ErrNotServing) {
		t.Fatalf("restored-without-replay Decrypt: want ErrNotServing, got %v", err)
	}
	if _, err := env.Encrypt(ctx, living, []byte("no")); !errors.Is(err, envelope.ErrNotServing) {
		t.Fatalf("restored-without-replay Encrypt: want ErrNotServing, got %v", err)
	}
	if err := env.Provision(ctx, newPersonID(t)); !errors.Is(err, envelope.ErrNotServing) {
		t.Fatalf("restored-without-replay Provision: want ErrNotServing, got %v", err)
	}
	open, err := deletion.OpenRestores()
	if err != nil || len(open) != 1 {
		t.Fatalf("expected exactly one open restore, got %v (%v)", open, err)
	}

	// The replay: re-destroys every journaled person, then, and only
	// then, balances the gate.
	if _, err := deletion.Replay(ctx, env); err != nil {
		t.Fatalf("Replay: %v", err)
	}
	if open, err := deletion.OpenRestores(); err != nil || len(open) != 0 {
		t.Fatalf("gate still open after replay: %v (%v)", open, err)
	}

	// Nothing readable for the deleted person: the read path fails
	// closed at the registry, and the registry-bypass path, pulling
	// the restored wrapped DEK as the owner and unwrapping at the
	// provider, fails at the crypto-shred.
	if _, err := env.Decrypt(ctx, deleted, deletedCipher); !errors.Is(err, envelope.ErrNoActiveDEK) {
		t.Fatalf("post-replay Decrypt for the deleted person: want ErrNoActiveDEK, got %v", err)
	}
	wrappedHex := ownerSQL(t, "payload", fmt.Sprintf(
		`SELECT encode(wrapped_dek, 'hex') FROM dek_registry WHERE person_id = '%s' AND event = 'created'`, deleted))
	wrapped, err := hex.DecodeString(wrappedHex)
	if err != nil {
		t.Fatalf("wrapped dek hex: %v", err)
	}
	if dek, err := provider.Unwrap(ctx, deleted, wrapped); err == nil || dek != nil {
		t.Fatal("provider unwrapped the restored DEK after replay, the crypto-shred did not hold")
	}

	// The living person is served again, content intact.
	storedHex := ownerSQL(t, "payload", fmt.Sprintf(
		"SELECT encode(body, 'hex') FROM %s WHERE subject_person_id = '%s'", table, living))
	stored, err := hex.DecodeString(storedHex)
	if err != nil {
		t.Fatalf("stored body hex: %v", err)
	}
	if got, err := env.Decrypt(ctx, living, stored); err != nil || !bytes.Equal(got, []byte(livingMarker)) {
		t.Fatalf("post-replay Decrypt for the living person: %v", err)
	}

	// The raw-dump floor, both planes: no marker in plaintext or hex.
	grepAbsent(t, fullDump(t, "payload"), deletedMarker, "payload")
	grepAbsent(t, fullDump(t, "payload"), livingMarker, "payload")
	grepAbsent(t, fullDump(t, "spine"), deletedMarker, "spine")
	grepAbsent(t, fullDump(t, "spine"), livingMarker, "spine")

	// A second replay is a harmless no-op.
	if _, err := deletion.Replay(ctx, env); err != nil {
		t.Fatalf("second Replay: %v", err)
	}
}

// --- criterion: only the purge role holds DELETE on payload tables -----

func TestOnlyPurgeRoleHoldsDeleteOnPayloadTables(t *testing.T) {
	// The complete set of UPDATE/DELETE/TRUNCATE grants to non-owner
	// roles on the payload plane equals the one licensed exemption.
	grants := ownerSQL(t, "payload", `
		SELECT n.nspname || '.' || c.relname || ' ' || a.privilege_type || ' -> ' ||
		       CASE WHEN a.grantee = 0 THEN 'PUBLIC' ELSE a.grantee::regrole::text END
		FROM pg_class c
		JOIN pg_namespace n ON n.oid = c.relnamespace,
		LATERAL aclexplode(coalesce(c.relacl, acldefault(
		  (CASE WHEN c.relkind = 'S' THEN 'S' ELSE 'r' END)::"char", c.relowner))) a
		WHERE c.relkind IN ('r', 'p', 'v', 'm', 'f', 'S')
		  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
		  AND a.privilege_type IN ('UPDATE', 'DELETE', 'TRUNCATE')
		  AND a.grantee <> c.relowner
		ORDER BY 1`)
	if grants != "public.dek_registry DELETE -> identity_purge" {
		t.Fatalf("payload mutation grants are not exactly the licensed purge exemption:\n%s", grants)
	}

	// The serving role cannot DELETE anywhere, the registry included.
	if _, err := roleSQL("payload", "identity_app", "DELETE FROM dek_registry"); err == nil ||
		!strings.Contains(err.Error(), "permission denied") {
		t.Fatalf("identity_app DELETE on dek_registry: want permission denied, got %v", err)
	}

	// The purge role's DELETE does not extend past the licensed table.
	for _, table := range []string{"restore_gate", "purge_audit", "schema_migrations", "database_residency"} {
		if _, err := roleSQL("payload", "identity_purge", "DELETE FROM "+table); err == nil ||
			!strings.Contains(err.Error(), "permission denied") {
			t.Fatalf("identity_purge DELETE on %s: want permission denied, got %v", table, err)
		}
	}

	// The purge role is boxed in like the serving role: no escalation
	// attribute, no role membership, no SET ROLE to the owner.
	attrs := ownerSQL(t, "payload", `SELECT rolsuper::text || rolcreaterole::text || rolcreatedb::text || rolreplication::text || rolbypassrls::text
		FROM pg_roles WHERE rolname = 'identity_purge'`)
	if attrs != "falsefalsefalsefalsefalse" {
		t.Fatalf("identity_purge holds an escalation attribute: %s", attrs)
	}
	if memberships := ownerSQL(t, "payload", `SELECT count(*) FROM pg_auth_members m
		JOIN pg_roles r ON r.oid = m.member WHERE r.rolname = 'identity_purge'`); memberships != "0" {
		t.Fatalf("identity_purge holds %s role membership(s)", memberships)
	}
	if _, err := roleSQL("payload", "identity_purge", "SET ROLE identity"); err == nil {
		t.Fatal("identity_purge can SET ROLE to the owner")
	}

	// The standing append-only proof, with the exemption enumerated,
	// still passes on both planes.
	out := node(t, "test/append-only.test.mjs")
	if !strings.Contains(out, "assertions passed on both planes") {
		t.Fatalf("append-only standing proof did not pass:\n%s", out)
	}
}

// --- criterion: a purge run is fully audited and attributable ----------

func TestPurgeRemovesShreddedRowsAndAudits(t *testing.T) {
	ctx := context.Background()
	env, _ := newEnv(t)

	shredded := newPersonID(t)
	livingPerson := newPersonID(t)
	for _, p := range []string{shredded, livingPerson} {
		if err := env.Provision(ctx, p); err != nil {
			t.Fatalf("Provision: %v", err)
		}
	}
	if err := deletion.Destroy(ctx, env, []string{shredded}, "support"); err != nil {
		t.Fatalf("Destroy: %v", err)
	}

	// The licensed set, counted out-of-band before the run.
	expected := ownerSQL(t, "payload", `SELECT count(*) FROM dek_registry d
		WHERE d.event = 'created' AND EXISTS (
		  SELECT 1 FROM dek_registry x
		   WHERE x.person_id = d.person_id AND x.event = 'destroyed')`)

	result, err := deletion.Purge("deletion-harness")
	if err != nil {
		t.Fatalf("Purge: %v", err)
	}
	if fmt.Sprint(result.RowsDeleted) != expected || result.RowsDeleted < 1 {
		t.Fatalf("purge removed %d row(s), licensed set held %s", result.RowsDeleted, expected)
	}

	// Scope: the shredded created row is gone; the destroyed row and the
	// living person's created row survive.
	state := ownerSQL(t, "payload", fmt.Sprintf(`SELECT
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'created') || '/' ||
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'destroyed') || '/' ||
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'created')`,
		shredded, shredded, livingPerson))
	if state != "0/1/1" {
		t.Fatalf("post-purge registry state wrong (shredded-created/shredded-destroyed/living-created): %s", state)
	}

	// Audit: one row, attributable, in the same transaction as the
	// deletes (a committed purge without it is not representable).
	audit := ownerSQL(t, "payload", fmt.Sprintf(
		`SELECT purged_table || '|' || rows_deleted || '|' || initiated_by || '|' || executed_as || '|' || residency_region
		 FROM purge_audit WHERE run_id = '%s'`, result.RunID))
	want := fmt.Sprintf("dek_registry|%d|deletion-harness|identity_purge|us", result.RowsDeleted)
	if audit != want {
		t.Fatalf("audit row wrong:\n got %s\nwant %s", audit, want)
	}

	// A run that removes nothing is still audited. The schedule's
	// execution is itself auditable.
	second, err := deletion.Purge("deletion-harness")
	if err != nil {
		t.Fatalf("second Purge: %v", err)
	}
	if second.RowsDeleted != 0 {
		t.Fatalf("second purge removed %d row(s); the licensed set was empty", second.RowsDeleted)
	}
	if runs := ownerSQL(t, "payload", fmt.Sprintf(
		"SELECT count(*) FROM purge_audit WHERE run_id IN ('%s', '%s')",
		result.RunID, second.RunID)); runs != "2" {
		t.Fatalf("expected both runs audited, found %s row(s)", runs)
	}

	// The audit trail is append-only for the purge role too.
	if _, err := roleSQL("payload", "identity_purge",
		fmt.Sprintf("UPDATE purge_audit SET initiated_by = 'x' WHERE run_id = '%s'", result.RunID)); err == nil {
		t.Fatal("identity_purge can UPDATE purge_audit")
	}

	// Row security is the backstop, not the runner's WHERE clause: an
	// unqualified DELETE issued raw as the purge role removes exactly
	// the licensed set, here a fresh shredded row, and nothing else.
	rlsShredded := newPersonID(t)
	rlsLiving := newPersonID(t)
	for _, p := range []string{rlsShredded, rlsLiving} {
		if err := env.Provision(ctx, p); err != nil {
			t.Fatalf("Provision: %v", err)
		}
	}
	if err := deletion.Destroy(ctx, env, []string{rlsShredded}, "worker"); err != nil {
		t.Fatalf("Destroy: %v", err)
	}
	if _, err := roleSQL("payload", "identity_purge", "DELETE FROM dek_registry"); err != nil {
		t.Fatalf("unqualified DELETE as identity_purge: %v", err)
	}
	state = ownerSQL(t, "payload", fmt.Sprintf(`SELECT
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'created') || '/' ||
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'destroyed') || '/' ||
		(SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'created')`,
		rlsShredded, rlsShredded, rlsLiving))
	if state != "0/1/1" {
		t.Fatalf("unqualified purge-role DELETE escaped the licensed set: %s", state)
	}

	// An unattributable run is refused before any SQL.
	if _, err := deletion.Purge(""); err == nil {
		t.Fatal("Purge accepted an empty initiator")
	}
	if _, err := deletion.Purge("x'; DROP TABLE dek_registry; --"); err == nil {
		t.Fatal("Purge accepted an initiator outside the validated shape")
	}
}

// --- criterion: the deletion journal carries nothing identifying -------

func TestDeletionJournalCarriesNothingIdentifying(t *testing.T) {
	// The column set is exactly what a replay needs: who (the ledger
	// id the spine retains forever anyway), when, requester class.
	cols := ownerSQL(t, "spine", `SELECT column_name || ':' || data_type
		FROM information_schema.columns
		WHERE table_schema = 'public' AND table_name = 'deletion_journal'
		ORDER BY ordinal_position`)
	want := "person_id:uuid\nrequester_class:text\nrecorded_at:timestamp with time zone"
	if cols != want {
		t.Fatalf("deletion_journal column set drifted:\n got:\n%s\nwant:\n%s", cols, want)
	}

	// requester_class is a closed vocabulary. Free text cannot reach
	// the spine through it.
	person := newPersonID(t)
	if _, err := roleSQL("spine", "identity_app", fmt.Sprintf(
		`INSERT INTO deletion_journal (person_id, requester_class) VALUES ('%s', 'Jane Doe asked')`, person)); err == nil ||
		!strings.Contains(err.Error(), "check constraint") {
		t.Fatalf("free-text requester_class was not refused by CHECK: %v", err)
	}

	// One row per person, by constraint.
	if idx := ownerSQL(t, "spine", `SELECT count(*) FROM pg_indexes
		WHERE tablename = 'deletion_journal' AND indexname = 'deletion_journal_one_per_person'`); idx != "1" {
		t.Fatal("deletion_journal_one_per_person index missing")
	}

	// Append-only like the rest of the spine: no UPDATE or DELETE for
	// the serving role, so the journal outlives everything.
	if _, err := roleSQL("spine", "identity_app", "DELETE FROM deletion_journal"); err == nil ||
		!strings.Contains(err.Error(), "permission denied") {
		t.Fatalf("identity_app DELETE on deletion_journal: want permission denied, got %v", err)
	}
}

// --- input validation on the destroy path ------------------------------

func TestDestroyValidation(t *testing.T) {
	ctx := context.Background()
	env, _ := newEnv(t)
	if err := deletion.Destroy(ctx, env, []string{newPersonID(t)}, "employer"); err == nil {
		t.Fatal("Destroy accepted a requester class outside the vocabulary")
	}
	if err := deletion.Destroy(ctx, env, nil, "worker"); err == nil {
		t.Fatal("Destroy accepted an empty closure")
	}
	if err := deletion.Destroy(ctx, env, []string{"not-a-uuid"}, "worker"); err == nil {
		t.Fatal("Destroy accepted a malformed person id")
	}
	// Nothing above reached the journal.
	if count := ownerSQL(t, "spine",
		"SELECT count(*) FROM deletion_journal WHERE requester_class NOT IN ('worker', 'support')"); count != "0" {
		t.Fatalf("an invalid requester class reached the journal: %s row(s)", count)
	}
}
