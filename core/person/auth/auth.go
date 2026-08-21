// Package auth is authentication and sessions (person-identity/02,
// decisions 013, 084, 086, 089): two ways into an account, one kind of
// session out.
//
// The rule that shapes everything here is decision 013's, and it is a
// product ruling rather than a security one: passkeys are preferred and
// one-time codes are an always-available EQUAL path. Equal is the load
// bearing word. A worker on a shared handset with no platform
// authenticator is not a second-class account holder, so nothing in this
// package reads how a session was authenticated in order to decide what
// it may do. The method is recorded, because a worker looking at their
// own session list deserves to know which device signed in; it is never
// an input to a decision (hygiene_test.go fails the package if it
// becomes one).
//
// Step-up and session assurance are not here, and their absence is
// ruled rather than forgotten: decision 086 moved both to the
// verification layer, whose task 04 owns the assurance ladder, because
// the criterion that stood here required a document-verified account and
// decision 071 rules those cannot exist in first-product.
//
// Where this package stops: it answers "who is this" and nothing else.
// Authenticate turns a bearer token into a person, and every other call
// takes the person id that came out of it. Deciding whether a request
// may do a thing belongs to whatever serves the request, which no plan
// layer has built yet. The one place that rule would be easy to break is
// a session's own list and inventory, so Sessions, Credentials, Events
// and Revoke all read the id they are given and Revoke refuses a session
// that belongs to somebody else outright.
//
// Everything this package holds lives on the payload plane (migration
// 0037). Nothing reaches the spine, which holds a person's id, issuance
// time and lifecycle transitions and nothing else (0010-person-core).
// Every statement crosses core/transport, the one seam any SQL path in
// this repo may use (trust-kernel/08, decision 065).
package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// The plane and the role every statement here runs as. identity_app
// holds SELECT and INSERT (migration 0002), which is the whole
// vocabulary authentication needs: a revoked session is a following row
// and a code attempt is a row, so nothing here wants an UPDATE.
const (
	payloadPlane = "payload"
	servingRole  = "identity_app"
)

// Errors. Each names a rule a caller can act on, and none distinguishes
// a channel that exists from one that does not.
var (
	ErrAddressShape = errors.New("auth: address is not a well-formed address for its kind")
	// ErrCodeRejected is the one answer every failing code submission
	// gets: wrong code, expired challenge, locked-out challenge, no
	// challenge, and no such account are one error on purpose.
	ErrCodeRejected = errors.New("auth: code rejected")
	ErrNoSession    = errors.New("auth: no live session for this token")
	ErrNotYours     = errors.New("auth: session does not belong to this person")
	ErrNoCredential = errors.New("auth: person has no enrolled credential")
)

// The authentication methods, as stored and as shown to the worker.
// Recorded, never compared against.
const (
	MethodPasskey = "passkey"
	MethodCode    = "code"
)

// The stated defaults. None of these is a policy: no decisions entry
// rules a number for any of them, and person-identity/01 set the
// precedent of recording the value in force with its reasoning rather
// than inventing a ruling (DefaultVelocityThreshold). A later policy
// changes these and can be reasoned about against accounts that predate
// it, because every challenge and every attempt is a row.
const (
	// CodeDigits: six is what workers are used to typing and what fits
	// on one line of an SMS. The space it leaves, a million values, is
	// only safe next to the attempt limit and the expiry below; those
	// three numbers are one decision and moving any of them alone is a
	// mistake.
	CodeDigits = 6
	// CodeTTL: long enough for a slow SMS route and a worker who put the
	// handset down, short enough that an outstanding code is not a
	// standing key to the account.
	CodeTTL = 10 * time.Minute
	// MaxAttemptsPerChallenge: the lockout. Five guesses against a
	// million values is a one in two hundred thousand chance per
	// challenge, and the challenge is dead afterwards whether or not the
	// worker asks for another.
	MaxAttemptsPerChallenge = 5
	// MaxChallengesPerWindow, ChallengeWindow: the request limit, which
	// is what stops an attacker from buying more guesses by asking for
	// more codes. Three in a quarter of an hour leaves room for a worker
	// who mistyped their address once and asked again.
	MaxChallengesPerWindow = 3
	ChallengeWindow        = 15 * time.Minute
	// SessionTTL: a worker's own record is a thing they come back to
	// every few months, and being signed out between visits is the
	// friction that pushes people onto a password they reuse. Revocation
	// is what ends a session early, and it is one tap in the session
	// list.
	SessionTTL = 30 * 24 * time.Hour
	// CodeUniformFloor is what makes the code endpoints uniform in time
	// as well as in wording. Both endpoints run the same two statements
	// whether or not the address resolves to a person, which narrows the
	// difference to what a writable statement costs over a read-only one;
	// the floor absorbs that, and the jitter of a container round trip.
	//
	// The number has to sit above the SLOWER branch's worst case, not its
	// typical case: a floor the slow branch runs past stops padding and
	// leaks exactly the difference it exists to hide. A first attempt at
	// 400 ms did that, with the resolving branch measured at 525 ms
	// against 401 ms for the branch that writes nothing. This value is
	// several times the observed cost of the slower branch, so a loaded
	// machine has room before it clips, and the acceptance suite fails
	// loudly rather than quietly if it ever does.
	//
	// It is spent once per login screen, next to the seconds an email or
	// an SMS takes to arrive, which is why buying the margin here is
	// cheap.
	CodeUniformFloor = 1500 * time.Millisecond
)

// The relying party this ledger is, for every WebAuthn ceremony
// (decision 084). Not configurable, and that is the point: a credential
// binds to the origin that created it, so a deployment that quietly
// changed the origin would invalidate every passkey ever enrolled. The
// worker's app has its own origin, separate from the party console and
// the operator console, because decision 083 gives those separate
// principals and one origin would give all three one cookie jar.
const (
	RelyingPartyID          = "app.grainidentity.com"
	RelyingPartyOrigin      = "https://app.grainidentity.com"
	RelyingPartyDisplayName = "Grain"
)

// Vault seals and opens worker content under the person's own DEK.
// Satisfied by *envelope.Envelope (foundation/05).
type Vault interface {
	Encrypt(ctx context.Context, person string, plaintext []byte) ([]byte, error)
	Decrypt(ctx context.Context, person string, ciphertext []byte) ([]byte, error)
}

// Deliverer hands a one-time code to the channel it was requested on.
//
// The contract is hand-off, not delivery: an implementation queues the
// message and returns. Blocking on a mail or SMS provider here would
// make the request endpoint's timing a function of whether the address
// resolved to a person, which is the leak the whole path is arranged to
// avoid.
type Deliverer interface {
	Deliver(ctx context.Context, kind person.ChannelKind, address, code string) error
}

// Service authenticates people and issues sessions.
type Service struct {
	vault   Vault
	index   *person.ChannelIndex
	mac     person.Macer
	deliver Deliverer
}

// New binds the seal path, the channel lookup index, the key provider
// behind code commitments, and the code deliverer. The payload plane is
// reached through core/transport, which no caller injects.
func New(vault Vault, index *person.ChannelIndex, mac person.Macer, deliver Deliverer) *Service {
	return &Service{vault: vault, index: index, mac: mac, deliver: deliver}
}

// Token is a bearer session token. It exists in the clear exactly once,
// in the return value of the call that issued it; what the ledger keeps
// is its commitment.
type Token string

// Session is one session as the worker's own session list shows it.
type Session struct {
	ID        string
	PersonID  string
	Method    string
	IssuedAt  time.Time
	ExpiresAt time.Time
	Live      bool
}

// Event is one authentication event, as the worker's own account
// activity shows it.
type Event struct {
	Method     string
	Kind       string
	RecordedAt time.Time
}

// Authenticate resolves a bearer token to its session. A revoked or
// expired session has no row in auth_session_live (migration 0037), so
// both die the same way and neither can be missed by checking one and
// forgetting the other.
//
// Nothing here reads Method. Both paths reach the same identity and the
// same session, which is decision 013's equal-path rule expressed as the
// one function every request runs through.
func (s *Service) Authenticate(_ context.Context, token Token) (Session, error) {
	lines, err := transport.Query(payloadPlane, servingRole, `
SELECT session_id, person_id, method, issued_at, expires_at
  FROM auth_session_live
 WHERE token_commitment = $1`,
		transport.Bytea(tokenCommitment(token)))
	if err != nil {
		return Session{}, err
	}
	if len(lines) == 0 {
		return Session{}, ErrNoSession
	}
	fields := transport.SplitRow(lines[0], 5)
	if len(fields) != 5 {
		return Session{}, fmt.Errorf("auth: session row has %d fields", len(fields))
	}
	issued, err := parseStamp(fields[3])
	if err != nil {
		return Session{}, err
	}
	expires, err := parseStamp(fields[4])
	if err != nil {
		return Session{}, err
	}
	return Session{
		ID:        fields[0],
		PersonID:  fields[1],
		Method:    fields[2],
		IssuedAt:  issued,
		ExpiresAt: expires,
		Live:      true,
	}, nil
}

// Sessions lists a person's sessions, live and dead, newest first. The
// worker's own inventory: what is signed in, on which path, and since
// when.
func (s *Service) Sessions(_ context.Context, personID string) ([]Session, error) {
	if err := person.ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
SELECT s.session_id, s.method, s.issued_at, s.expires_at,
       (r.session_id IS NULL AND s.expires_at > now())
  FROM auth_session s
  LEFT JOIN auth_session_revocation r ON r.session_id = s.session_id
 WHERE s.person_id = $1
 ORDER BY s.issued_at DESC, s.session_id`,
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	sessions := make([]Session, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 5)
		if len(fields) != 5 {
			return nil, fmt.Errorf("auth: session row has %d fields", len(fields))
		}
		issued, err := parseStamp(fields[2])
		if err != nil {
			return nil, err
		}
		expires, err := parseStamp(fields[3])
		if err != nil {
			return nil, err
		}
		sessions = append(sessions, Session{
			ID:        fields[0],
			PersonID:  personID,
			Method:    fields[1],
			IssuedAt:  issued,
			ExpiresAt: expires,
			Live:      fields[4] == "t",
		})
	}
	return sessions, nil
}

// Revoke ends one of the person's own sessions. Revoking a session that
// is already revoked changes nothing and is not an error: the worker
// tapped twice, and the record already says what they wanted it to say.
//
// A session belonging to somebody else is ErrNotYours and no row is
// written, so the call cannot be used to discover whether an id exists.
func (s *Service) Revoke(_ context.Context, personID, sessionID string) error {
	if err := person.ValidID(personID); err != nil {
		return err
	}
	if err := person.ValidID(sessionID); err != nil {
		return err
	}
	eventID, err := person.NewID()
	if err != nil {
		return err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
WITH owned AS (
  SELECT session_id, person_id FROM auth_session
   WHERE session_id = $1 AND person_id = $2
), revoked AS (
  INSERT INTO auth_session_revocation (session_id)
  SELECT session_id FROM owned
  ON CONFLICT DO NOTHING
  RETURNING session_id
), noted AS (
  INSERT INTO auth_event (event_id, person_id, method, kind)
  SELECT $3, o.person_id, 'session', 'session-revoked'
    FROM owned o JOIN revoked r ON r.session_id = o.session_id
  RETURNING event_id
)
SELECT session_id FROM owned`,
		transport.String(sessionID), transport.String(personID),
		transport.String(eventID))
	if err != nil {
		return err
	}
	if len(lines) == 0 {
		return ErrNotYours
	}
	return nil
}

// Events lists a person's authentication events, oldest first. Closed
// vocabularies only: no address, no device string, no network address
// (migration 0037 says why).
func (s *Service) Events(_ context.Context, personID string) ([]Event, error) {
	if err := person.ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
SELECT method, kind, recorded_at FROM auth_event
 WHERE person_id = $1
 ORDER BY recorded_at, event_id`,
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	events := make([]Event, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 3)
		if len(fields) != 3 {
			return nil, fmt.Errorf("auth: event row has %d fields", len(fields))
		}
		stamp, err := parseStamp(fields[2])
		if err != nil {
			return nil, err
		}
		events = append(events, Event{Method: fields[0], Kind: fields[1], RecordedAt: stamp})
	}
	return events, nil
}

// newToken returns a fresh bearer token: 32 bytes from the system
// CSPRNG, rendered base64url so it survives a header and a URL
// unescaped.
func newToken() (Token, error) {
	raw := make([]byte, 32)
	if _, err := rand.Read(raw); err != nil {
		return "", fmt.Errorf("auth: token generation: %w", err)
	}
	return Token(base64.RawURLEncoding.EncodeToString(raw)), nil
}

// tokenCommitment is what the ledger stores instead of the token.
//
// A plain SHA-256, deliberately, where the channel index and the code
// commitment are both keyed. The difference is the input: a token is 256
// bits of CSPRNG output with no guessable space, so there is nothing for
// an attacker holding the table to enumerate and a key would protect
// nothing. A key is load bearing only where the value being committed to
// is one a person chose or a machine drew from a small set.
func tokenCommitment(token Token) []byte {
	sum := sha256.Sum256([]byte(token))
	return sum[:]
}

// newCode returns a fresh one-time code: CodeDigits decimal digits from
// the system CSPRNG, drawn uniformly. Leading zeros are kept, so every
// value in the space is reachable and the code is always the same
// length on screen.
func newCode() (string, error) {
	digits := make([]byte, CodeDigits)
	for i := range digits {
		n, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", fmt.Errorf("auth: code generation: %w", err)
		}
		digits[i] = byte('0' + n.Int64())
	}
	return string(digits), nil
}

// parseStamp reads a Postgres timestamptz as psql renders it.
func parseStamp(value string) (time.Time, error) {
	for _, layout := range []string{
		"2006-01-02 15:04:05.999999-07",
		"2006-01-02 15:04:05.999999-07:00",
	} {
		if stamp, err := time.Parse(layout, value); err == nil {
			return stamp, nil
		}
	}
	return time.Time{}, fmt.Errorf("auth: unreadable timestamp %q", value)
}

// interval renders a Go duration as a Postgres interval literal, so the
// stated defaults above are the only place a number lives and no SQL
// string carries a second copy of one.
func interval(d time.Duration) string {
	return fmt.Sprintf("%d milliseconds", d.Milliseconds())
}
