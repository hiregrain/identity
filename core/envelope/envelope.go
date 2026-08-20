// Package envelope is the payload read/write path (foundation/05):
// per-person data-encryption keys wrapping payload content, registered
// in the payload plane's dek_registry (migration 0005) behind the
// key-provider seam (core/keys). Content columns store ciphertext this
// package produced; nothing else in the system may hold payload content
// in the clear.
//
// The single state-derivation rule is identical to the one migration 0005
// documents. This package executes it, never a second one:
//
//	A person's DEK is ACTIVE iff the registry holds a 'created' row for
//	the person and no 'destroyed' row for the person; otherwise there is
//	no usable DEK and every read fails closed.
//
// activeWrappedDEKSQL is that sentence as one query, so every read
// resolves the state in a single statement snapshot: a destroy committed
// before the read sees no key (fail closed), one committed after leaves
// the read completing against the live key, never anything partial.
//
// Business logic here is provider-agnostic (decision 017): the package
// holds a keys.Provider and never branches on which one it is. The
// provider's name is recorded on registry rows because operational
// surfaces legitimately need it; no code path reads it back.
//
// No function logs, and no error carries plaintext or key material.
// Errors name the person id (a ledger uuid, spine-visible by design) and
// the operation, nothing else.
package envelope

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"regexp"
	"strings"

	"github.com/hiregrain/identity/core/keys"
)

// Querier executes one SQL statement with $n placeholders against the
// payload database as the serving role (identity_app, SELECT and
// INSERT only, migration 0002; this package needs nothing more, which
// is the point of an append-only registry). Rows come back as text
// fields, bytea values in Postgres hex form ("\x..."). The production
// implementation arrives with the first server; tests implement it over
// psql. Implementations must transmit args as values (parameters or
// exact literals), never by interpolating into the SQL text. Every arg
// this package passes is a validated uuid, a hex string, or a provider
// name, so a literal-quoting implementation has nothing to escape.
type Querier interface {
	Query(ctx context.Context, sql string, args ...string) ([][]string, error)
}

// Errors. Reads after destruction fail closed with ErrNoActiveDEK; a
// ciphertext that does not authenticate fails with ErrDecryptFailed.
// None ever carries content or key material.
var (
	ErrNoActiveDEK     = errors.New("envelope: no active DEK for person")
	ErrAlreadyKeyed    = errors.New("envelope: person already keyed or destroyed")
	ErrDecryptFailed   = errors.New("envelope: decrypt failed")
	ErrInvalidPersonID = errors.New("envelope: person id is not a lowercase uuid")
	ErrEmptyClosure    = errors.New("envelope: destroy requires a non-empty alias closure")
	// ErrNotServing: the payload plane was restored from a backup and
	// the deletion-journal replay has not completed (foundation/08,
	// decision 017). Every serving path refuses until it has.
	ErrNotServing = errors.New("envelope: payload plane restored without deletion replay; not serving")
)

// The registry statements. The derivation rule lives in
// activeWrappedDEKSQL and nowhere else; both writes stamp
// residency_region from the database's own declaration
// (database_residency), so the checked assertion cannot drift from the
// authority (foundation/04).
const (
	// activeWrappedDEKSQL resolves the person's ACTIVE wrapped DEK per
	// the package rule, in one statement.
	activeWrappedDEKSQL = `
SELECT wrapped_dek FROM dek_registry
 WHERE person_id = $1 AND event = 'created'
   AND NOT EXISTS (
     SELECT 1 FROM dek_registry d
      WHERE d.person_id = $1 AND d.event = 'destroyed')`

	// provisionSQL appends the 'created' row. The WHERE NOT EXISTS
	// refuses a destroyed person (a tombstoned id never carries key
	// material again, decision 014); the ON CONFLICT arbiter is the
	// at-most-one-created constraint, so a concurrent double provision
	// resolves to one row and zero returned rows for the loser.
	provisionSQL = `
INSERT INTO dek_registry (person_id, event, wrapped_dek, key_provider, residency_region)
SELECT $1, 'created', $2, $3, residency_region FROM database_residency
 WHERE NOT EXISTS (
   SELECT 1 FROM dek_registry
    WHERE person_id = $1 AND event = 'destroyed')
ON CONFLICT (person_id) WHERE event = 'created' DO NOTHING
RETURNING person_id`

	// destroySQL appends the 'destroyed' row. ON CONFLICT against the
	// at-most-one-destroyed constraint is what makes a second destroy a
	// no-op, not an error, not a second row. It inserts whether or not
	// a 'created' row exists: a destroyed row for a never-keyed person
	// fails closed too, blocking any later provision.
	destroySQL = `
INSERT INTO dek_registry (person_id, event, wrapped_dek, key_provider, residency_region)
SELECT $1, 'destroyed', NULL, $2, residency_region FROM database_residency
ON CONFLICT (person_id) WHERE event = 'destroyed' DO NOTHING`

	// servingGateSQL executes migration 0022's restore-gate rule. It is the
	// only place that rule is executed:
	//
	//   A restored payload plane is SERVING iff no 'restored' row lacks
	//   a 'replayed' row for the same restore_id.
	//
	// The query returns a row exactly when the system is GATED (an
	// unbalanced restore exists), so a query failure and a returned row
	// both refuse. The gate fails closed in every branch of
	// assertServing.
	servingGateSQL = `
SELECT 1 FROM restore_gate r
 WHERE r.event = 'restored'
   AND NOT EXISTS (
     SELECT 1 FROM restore_gate g
      WHERE g.restore_id = r.restore_id AND g.event = 'replayed')
 LIMIT 1`
)

// Envelope binds a registry connection and a key provider.
type Envelope struct {
	q Querier
	p keys.Provider
}

// New returns an Envelope over the payload plane and the configured
// provider (keys.FromConfig, the only place a provider is chosen).
func New(q Querier, p keys.Provider) *Envelope {
	return &Envelope{q: q, p: p}
}

// Provision creates the person's DEK, wraps it under the person's scope,
// and registers it. Fails with ErrAlreadyKeyed when the person already
// holds a created row or has been destroyed.
func (e *Envelope) Provision(ctx context.Context, person string) error {
	if err := e.assertServing(ctx); err != nil {
		return err
	}
	if err := validPersonID(person); err != nil {
		return err
	}
	dek := make([]byte, 32)
	if _, err := rand.Read(dek); err != nil {
		return fmt.Errorf("envelope: provision %s: %w", person, err)
	}
	wrapped, err := e.p.Wrap(ctx, person, dek)
	if err != nil {
		return fmt.Errorf("envelope: provision %s: %w", person, err)
	}
	rows, err := e.q.Query(ctx, provisionSQL, person, hexArg(wrapped), e.p.Name())
	if err != nil {
		return fmt.Errorf("envelope: provision %s: %w", person, err)
	}
	if len(rows) == 0 {
		return fmt.Errorf("%w: %s", ErrAlreadyKeyed, person)
	}
	return nil
}

// Encrypt seals plaintext under the person's ACTIVE DEK. The ciphertext
// is bound to the person id, so it decrypts under the subject's key
// alone. Fails closed with ErrNoActiveDEK when no active DEK exists.
func (e *Envelope) Encrypt(ctx context.Context, person string, plaintext []byte) ([]byte, error) {
	if err := e.assertServing(ctx); err != nil {
		return nil, err
	}
	dek, err := e.activeDEK(ctx, person)
	if err != nil {
		return nil, err
	}
	sealed, err := seal(dek, person, plaintext)
	if err != nil {
		return nil, fmt.Errorf("envelope: encrypt for %s: %w", person, err)
	}
	return sealed, nil
}

// Decrypt opens ciphertext under the person's ACTIVE DEK. After
// destruction it fails closed with ErrNoActiveDEK (registry) or the
// provider's destruction error, never partial plaintext: the AEAD
// authenticates the whole message or returns nothing.
func (e *Envelope) Decrypt(ctx context.Context, person string, ciphertext []byte) ([]byte, error) {
	if err := e.assertServing(ctx); err != nil {
		return nil, err
	}
	dek, err := e.activeDEK(ctx, person)
	if err != nil {
		return nil, err
	}
	plaintext, err := open(dek, person, ciphertext)
	if err != nil {
		return nil, fmt.Errorf("%w: person %s", ErrDecryptFailed, person)
	}
	return plaintext, nil
}

// Destroy crypto-shreds every person id in the alias closure.
//
// The closure contract: the caller supplies the COMPLETE alias closure,
// meaning every ledger person id that has ever referred to the person,
// canonical id included. This package does not compute closures; merge machinery
// and its closure derivation belong to person-identity, and until it
// lands an unmerged person's closure is the single-element set of their
// own id. Destroying a merged person with a partial closure would leave
// a surviving pre-merge key and the record readable, which is exactly
// what this contract exists to forbid.
//
// Per id, the registry row is appended first (reads fail closed from
// that commit on), then the provider's scope key is destroyed (the
// crypto-shred). Both halves are idempotent, so a partial failure is
// retried by calling Destroy again with the same closure.
//
// Destroy is deliberately NOT behind the serving gate (foundation/08):
// the restore-time deletion replay re-destroys every journaled person
// while the gate is closed. Destruction must always be possible, and
// gating it would deadlock the very step that opens the gate. Every
// serving path (Provision, Encrypt, Decrypt) is gated.
func (e *Envelope) Destroy(ctx context.Context, closure []string) error {
	if len(closure) == 0 {
		return ErrEmptyClosure
	}
	for _, person := range closure {
		if err := validPersonID(person); err != nil {
			return err
		}
	}
	for _, person := range closure {
		if _, err := e.q.Query(ctx, destroySQL, person, e.p.Name()); err != nil {
			return fmt.Errorf("envelope: destroy %s: %w", person, err)
		}
		if err := e.p.Destroy(ctx, person); err != nil {
			return fmt.Errorf("envelope: destroy %s: %w", person, err)
		}
	}
	return nil
}

// assertServing refuses every serving path while the payload plane
// stands restored-but-not-replayed (foundation/08, decision 017): the
// restore gate (migration 0022, restore_gate) is consulted before any
// key is touched, and both failure branches, an unbalanced restore and
// an unqueryable gate, refuse. ErrNotServing is deliberately distinct
// from ErrNoActiveDEK: "this system is not serving anyone" must never
// read as "this person was deleted".
func (e *Envelope) assertServing(ctx context.Context) error {
	rows, err := e.q.Query(ctx, servingGateSQL)
	if err != nil {
		return fmt.Errorf("envelope: serving gate: %w", err)
	}
	if len(rows) > 0 {
		return ErrNotServing
	}
	return nil
}

// activeDEK resolves and unwraps the person's ACTIVE DEK, failing closed
// on every branch.
func (e *Envelope) activeDEK(ctx context.Context, person string) ([]byte, error) {
	if err := validPersonID(person); err != nil {
		return nil, err
	}
	rows, err := e.q.Query(ctx, activeWrappedDEKSQL, person)
	if err != nil {
		return nil, fmt.Errorf("envelope: key lookup for %s: %w", person, err)
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%w: %s", ErrNoActiveDEK, person)
	}
	if len(rows) > 1 || len(rows[0]) != 1 {
		// Unreachable while dek_registry_one_created stands; refuse
		// rather than pick.
		return nil, fmt.Errorf("envelope: key lookup for %s: ambiguous registry state", person)
	}
	wrapped, err := hexValue(rows[0][0])
	if err != nil {
		return nil, fmt.Errorf("envelope: key lookup for %s: %w", person, err)
	}
	dek, err := e.p.Unwrap(ctx, person, wrapped)
	if err != nil {
		return nil, fmt.Errorf("envelope: key lookup for %s: %w", person, err)
	}
	return dek, nil
}

var personIDPattern = regexp.MustCompile(
	`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

// validPersonID enforces the ledger id shape (spine_object_id: uuid,
// lowercase). Validation before any SQL is also what lets a
// literal-quoting Querier be safe: every arg is shape-checked here or a
// hex/provider constant.
func validPersonID(person string) error {
	if !personIDPattern.MatchString(person) {
		return fmt.Errorf("%w: %q", ErrInvalidPersonID, person)
	}
	return nil
}

// hexArg renders bytes as a Postgres hex bytea literal value.
func hexArg(b []byte) string { return `\x` + hex.EncodeToString(b) }

// hexValue parses a Postgres hex bytea value.
func hexValue(s string) ([]byte, error) {
	if !strings.HasPrefix(s, `\x`) {
		return nil, errors.New("bytea value is not in hex form")
	}
	return hex.DecodeString(s[2:])
}

// seal/open: AES-256-GCM over content, nonce prepended, the person id
// bound as additional authenticated data. A ciphertext is verifiable
// only under the subject's DEK and the subject's id, so content cannot
// be replayed under another person even if key material coincided.
func seal(dek []byte, person string, plaintext []byte) ([]byte, error) {
	aead, err := newAEAD(dek)
	if err != nil {
		return nil, err
	}
	nonce := make([]byte, aead.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}
	return aead.Seal(nonce, nonce, plaintext, []byte(person)), nil
}

func open(dek []byte, person string, ciphertext []byte) ([]byte, error) {
	aead, err := newAEAD(dek)
	if err != nil {
		return nil, err
	}
	if len(ciphertext) < aead.NonceSize() {
		return nil, ErrDecryptFailed
	}
	return aead.Open(nil, ciphertext[:aead.NonceSize()], ciphertext[aead.NonceSize():], []byte(person))
}

func newAEAD(key []byte) (cipher.AEAD, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	return cipher.NewGCM(block)
}
