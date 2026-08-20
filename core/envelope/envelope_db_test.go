//go:build db

// The envelope acceptance tests (foundation/05), run against the live
// payload plane under whichever provider GRAIN_KEY_PROVIDER names.
// `make envelope-test` runs the whole file once per provider, which is
// acceptance criterion 6's mechanism. Requires both planes up and
// migrated (make db-up && make migrate).
package envelope_test

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"sync"
	"testing"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
)

// Criterion 1: after destroy, no payload row for the person is readable
// through any code path. The evidence is stronger than a dump grep.
func TestDestroyLeavesNothingReadable(t *testing.T) {
	ctx := context.Background()
	env, provider := newEnv(t)
	table := contentTable(t)
	person := newPersonID(t)

	marker := []byte("PLANTED-PLAINTEXT-MARKER-" + person)
	if err := env.Provision(ctx, person); err != nil {
		t.Fatalf("Provision: %v", err)
	}

	// Write path: content columns store ciphertext this package produced.
	ciphertext, err := env.Encrypt(ctx, person, marker)
	if err != nil {
		t.Fatalf("Encrypt: %v", err)
	}
	if bytes.Contains(ciphertext, marker) {
		t.Fatal("ciphertext contains the plaintext")
	}
	if _, err := appSQL(fmt.Sprintf(
		`INSERT INTO %s (subject_person_id, body) VALUES ('%s', E'\\x%x')`,
		table, person, ciphertext)); err != nil {
		t.Fatalf("content insert as identity_app: %v", err)
	}

	// Read path works while the DEK is active.
	stored := readBody(t, table, person)
	got, err := env.Decrypt(ctx, person, stored)
	if err != nil || !bytes.Equal(got, marker) {
		t.Fatalf("pre-destroy Decrypt: %v", err)
	}

	// Every content column is ciphertext under the expected key scope:
	// the stored body authenticates under the subject's DEK (above) and
	// under no other person's (asserted structurally in the two-person
	// test); and no derived or denormalized plaintext column exists.
	// The table's only content-bearing column is the one bytea.
	cols := ownerSQL(t, `SELECT column_name || ':' || data_type FROM information_schema.columns
        WHERE table_schema='public' AND table_name='`+table+`' ORDER BY ordinal_position`)
	want := "subject_person_id:uuid\ncounterparty_person_id:uuid\nbody:bytea\nresidency_region:text"
	if cols != want {
		t.Fatalf("content table grew a column the harness did not define:\n%s", cols)
	}

	if err := env.Destroy(ctx, []string{person}); err != nil {
		t.Fatalf("Destroy: %v", err)
	}

	// Path 1: the read path fails closed and returns nothing.
	if got, err := env.Decrypt(ctx, person, stored); err == nil {
		t.Fatal("Decrypt succeeded after destroy")
	} else {
		if got != nil {
			t.Fatal("Decrypt returned material after destroy")
		}
		assertNoMarker(t, err.Error(), marker)
	}

	// Path 2: the write path is closed too.
	if _, err := env.Encrypt(ctx, person, []byte("more")); err == nil {
		t.Fatal("Encrypt succeeded after destroy")
	}

	// Path 3: bypassing the registry state and unwrapping the stored
	// wrapped DEK directly at the provider fails, the crypto-shred, not
	// just bookkeeping.
	wrappedHex := ownerSQL(t, fmt.Sprintf(
		`SELECT wrapped_dek FROM dek_registry WHERE person_id = '%s' AND event = 'created'`, person))
	wrapped := mustHex(t, wrappedHex)
	if _, err := provider.Unwrap(ctx, person, wrapped); err == nil {
		t.Fatal("provider unwrapped the stored DEK after destroy")
	} else {
		assertNoMarker(t, err.Error(), marker)
	}

	// Path 4: re-provisioning a destroyed person is refused, so the id
	// can never carry a fresh key that would matter. Two fail-closed
	// gates stand in the way; which one answers depends on process
	// history. In this process the provider refuses the destroyed scope
	// (keys.ErrScopeDestroyed); a fresh process's provider has never
	// seen the scope, and the registry's destroyed row refuses instead
	// (ErrAlreadyKeyed). Either refusal satisfies the criterion.
	if err := env.Provision(ctx, person); !errors.Is(err, envelope.ErrAlreadyKeyed) && !errors.Is(err, keys.ErrScopeDestroyed) {
		t.Fatalf("Provision after destroy: got %v, want a fail-closed refusal", err)
	}

	// And the dump grep, as the floor not the ceiling: neither the
	// plaintext nor its hex form appears anywhere in a full data dump.
	dump := payloadDump(t)
	if strings.Contains(dump, string(marker)) || strings.Contains(dump, fmt.Sprintf("%x", marker)) {
		t.Fatal("planted marker appears in a full payload dump")
	}
}

// Criterion 2: a row about two people is readable only via the subject's
// key; no second wrap exists, asserted at the schema level.
func TestTwoPersonRowKeyedToSubjectAlone(t *testing.T) {
	ctx := context.Background()
	env, _ := newEnv(t)
	table := contentTable(t)
	subject := newPersonID(t)
	counterparty := newPersonID(t)

	for _, p := range []string{subject, counterparty} {
		if err := env.Provision(ctx, p); err != nil {
			t.Fatalf("Provision(%s): %v", p, err)
		}
	}
	body := []byte("attestation about subject, written by counterparty")
	ciphertext, err := env.Encrypt(ctx, subject, body)
	if err != nil {
		t.Fatalf("Encrypt: %v", err)
	}
	if _, err := appSQL(fmt.Sprintf(
		`INSERT INTO %s (subject_person_id, counterparty_person_id, body) VALUES ('%s', '%s', E'\\x%x')`,
		table, subject, counterparty, ciphertext)); err != nil {
		t.Fatalf("content insert: %v", err)
	}
	stored := readBody(t, table, subject)

	// Readable via the subject's key alone.
	if got, err := env.Decrypt(ctx, subject, stored); err != nil || !bytes.Equal(got, body) {
		t.Fatalf("Decrypt as subject: %v", err)
	}
	if _, err := env.Decrypt(ctx, counterparty, stored); err == nil {
		t.Fatal("the counterparty's key read the subject's row")
	}

	// Schema level: the registry can hold one wrapped key per row and
	// one row per person-event. There is no column a second wrap could
	// live in, and the partial unique indexes are present as CONSTRAINTS.
	regCols := ownerSQL(t, `SELECT column_name FROM information_schema.columns
        WHERE table_schema='public' AND table_name='dek_registry' ORDER BY ordinal_position`)
	if regCols != "person_id\nevent\nwrapped_dek\nkey_provider\nrecorded_at\nresidency_region" {
		t.Fatalf("dek_registry columns changed; a second person or wrap column would break single-owner keying:\n%s", regCols)
	}
	indexes := ownerSQL(t, `SELECT indexname FROM pg_indexes
        WHERE tablename='dek_registry' AND indexname LIKE 'dek_registry_one_%' ORDER BY indexname`)
	if indexes != "dek_registry_one_created\ndek_registry_one_destroyed" {
		t.Fatalf("the registry's uniqueness constraints are missing:\n%s", indexes)
	}

	// Destroying the SUBJECT makes the two-person row unreadable to
	// everyone, the issuing party included (decisions 014/017).
	if err := env.Destroy(ctx, []string{subject}); err != nil {
		t.Fatalf("Destroy(subject): %v", err)
	}
	if _, err := env.Decrypt(ctx, subject, stored); err == nil {
		t.Fatal("row readable after subject destroy")
	}
	// The counterparty's own DEK is untouched by the subject's deletion.
	if _, err := env.Encrypt(ctx, counterparty, []byte("still keyed")); err != nil {
		t.Fatalf("counterparty collateral damage: %v", err)
	}
}

// Criterion 3: destroy is idempotent, and a read racing a destroy either
// completes or fails closed, never partial plaintext.
func TestDestroyIdempotentAndSafeUnderConcurrentReads(t *testing.T) {
	ctx := context.Background()
	env, _ := newEnv(t)
	person := newPersonID(t)
	if err := env.Provision(ctx, person); err != nil {
		t.Fatalf("Provision: %v", err)
	}
	plaintext := []byte("race body: the full message or nothing")
	ciphertext, err := env.Encrypt(ctx, person, plaintext)
	if err != nil {
		t.Fatalf("Encrypt: %v", err)
	}

	// Readers race the destroy.
	var wg sync.WaitGroup
	results := make(chan error, 64)
	for r := 0; r < 4; r++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for i := 0; i < 4; i++ {
				got, err := env.Decrypt(ctx, person, ciphertext)
				if err == nil && !bytes.Equal(got, plaintext) {
					results <- errors.New("a read returned something other than the exact plaintext")
					return
				}
				if err != nil && got != nil {
					results <- errors.New("a failed read returned material")
					return
				}
			}
			results <- nil
		}()
	}
	if err := env.Destroy(ctx, []string{person}); err != nil {
		t.Fatalf("Destroy during reads: %v", err)
	}
	wg.Wait()
	close(results)
	for err := range results {
		if err != nil {
			t.Fatal(err)
		}
	}

	// Idempotent: a second (and third) destroy is a no-op, no error,
	// no second row.
	if err := env.Destroy(ctx, []string{person}); err != nil {
		t.Fatalf("second Destroy: %v", err)
	}
	if err := env.Destroy(ctx, []string{person}); err != nil {
		t.Fatalf("third Destroy: %v", err)
	}
	count := ownerSQL(t, fmt.Sprintf(
		`SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'destroyed'`, person))
	if count != "1" {
		t.Fatalf("destroyed rows for the person: %s, want exactly 1", count)
	}
	if _, err := env.Decrypt(ctx, person, ciphertext); err == nil {
		t.Fatal("readable after destroy")
	}
}

// Criterion 4: destroying a merged person destroys every DEK in the
// alias closure. The closure is an input set (the documented contract in
// envelope.Destroy). Merge machinery belongs to person-identity, so the
// closure here is synthetic.
func TestDestroyMergedPersonDestroysWholeClosure(t *testing.T) {
	ctx := context.Background()
	env, provider := newEnv(t)
	closure := []string{newPersonID(t), newPersonID(t), newPersonID(t)}

	bodies := map[string][]byte{}
	ciphertexts := map[string][]byte{}
	for _, alias := range closure {
		if err := env.Provision(ctx, alias); err != nil {
			t.Fatalf("Provision(%s): %v", alias, err)
		}
		bodies[alias] = []byte("pre-merge record under " + alias)
		c, err := env.Encrypt(ctx, alias, bodies[alias])
		if err != nil {
			t.Fatalf("Encrypt(%s): %v", alias, err)
		}
		ciphertexts[alias] = c
	}

	if err := env.Destroy(ctx, closure); err != nil {
		t.Fatalf("Destroy(closure): %v", err)
	}

	for _, alias := range closure {
		if _, err := env.Decrypt(ctx, alias, ciphertexts[alias]); err == nil {
			t.Fatalf("alias %s still readable, a surviving pre-merge key", alias)
		}
		wrapped := mustHex(t, ownerSQL(t, fmt.Sprintf(
			`SELECT wrapped_dek FROM dek_registry WHERE person_id = '%s' AND event = 'created'`, alias)))
		if _, err := provider.Unwrap(ctx, alias, wrapped); err == nil {
			t.Fatalf("alias %s's DEK still unwraps at the provider", alias)
		}
		destroyed := ownerSQL(t, fmt.Sprintf(
			`SELECT count(*) FROM dek_registry WHERE person_id = '%s' AND event = 'destroyed'`, alias))
		if destroyed != "1" {
			t.Fatalf("alias %s: %s destroyed rows, want 1", alias, destroyed)
		}
	}

	if err := env.Destroy(ctx, nil); !errors.Is(err, envelope.ErrEmptyClosure) {
		t.Fatalf("Destroy(nil closure): got %v, want ErrEmptyClosure", err)
	}
}

// Criterion 5: at most one active DEK per person, enforced by the
// DATABASE. A raw second 'created' insert as the serving role fails on
// the constraint, with no application code in the path.
func TestOneActiveDEKEnforcedByConstraint(t *testing.T) {
	ctx := context.Background()
	env, provider := newEnv(t)
	person := newPersonID(t)
	if err := env.Provision(ctx, person); err != nil {
		t.Fatalf("Provision: %v", err)
	}

	// The application path refuses a second key.
	if err := env.Provision(ctx, person); !errors.Is(err, envelope.ErrAlreadyKeyed) {
		t.Fatalf("second Provision: got %v, want ErrAlreadyKeyed", err)
	}

	// The raw path fails on the constraint itself.
	if out, err := appSQL(fmt.Sprintf(
		`INSERT INTO dek_registry (person_id, event, wrapped_dek, key_provider, residency_region)
         VALUES ('%s', 'created', E'\\x00', '%s', 'us')`, person, provider.Name())); err == nil {
		t.Fatal("a raw second 'created' row was accepted; the constraint is missing")
	} else if !strings.Contains(err.Error(), "dek_registry_one_created") {
		t.Fatalf("second 'created' failed for the wrong reason: %v %s", err, out)
	}

	// Same shape for the destroyed side: the no-op-ness of a second
	// destroy comes from a constraint, not from code checking first.
	if err := env.Destroy(ctx, []string{person}); err != nil {
		t.Fatalf("Destroy: %v", err)
	}
	if _, err := appSQL(fmt.Sprintf(
		`INSERT INTO dek_registry (person_id, event, wrapped_dek, key_provider, residency_region)
         VALUES ('%s', 'destroyed', NULL, '%s', 'us')`, person, provider.Name())); err == nil {
		t.Fatal("a raw second 'destroyed' row was accepted; the constraint is missing")
	}

	// The registry records which provider wrapped the key. This is the
	// operational surface decision 017 allows; asserted here so the
	// column cannot silently go stale.
	recorded := ownerSQL(t, fmt.Sprintf(
		`SELECT key_provider FROM dek_registry WHERE person_id = '%s' AND event = 'created'`, person))
	if recorded != provider.Name() {
		t.Fatalf("registry records provider %q, active provider is %q", recorded, provider.Name())
	}
}

// readBody fetches the stored ciphertext for a subject via the serving
// role.
func readBody(t *testing.T, table, subject string) []byte {
	t.Helper()
	out, err := appSQL(fmt.Sprintf(
		`SELECT body FROM %s WHERE subject_person_id = '%s'`, table, subject))
	if err != nil {
		t.Fatalf("content read as identity_app: %v", err)
	}
	return mustHex(t, strings.TrimRight(out, "\n"))
}

func mustHex(t *testing.T, s string) []byte {
	t.Helper()
	s = strings.TrimSpace(s)
	if !strings.HasPrefix(s, `\x`) {
		t.Fatalf("expected a hex bytea value, got %q", s)
	}
	b, err := hex.DecodeString(s[2:])
	if err != nil {
		t.Fatalf("hex decode: %v", err)
	}
	return b
}

func assertNoMarker(t *testing.T, errText string, marker []byte) {
	t.Helper()
	if strings.Contains(errText, string(marker)) || strings.Contains(errText, fmt.Sprintf("%x", marker)) {
		t.Fatalf("an error message carries plaintext material: %s", errText)
	}
}
