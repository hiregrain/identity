package auth

// The one-time-code path. Decision 013 makes it an always-available
// equal path, not a fallback, so it is built to the same standard as the
// passkey path and is never refused an operation the other is allowed.
//
// How this path avoids telling an attacker who has an account, which is
// the whole of criterion 2:
//
//  1. Both endpoints return the same value for an address that resolves
//     to a person and one that does not. RequestCode returns nil in
//     both, SubmitCode returns ErrCodeRejected in both, and the same
//     error covers a wrong code, an expired challenge, a locked-out
//     challenge and an account that was never there.
//  2. Both endpoints run the same two statements in both cases. The
//     lookup runs first and its result decides which person id the
//     second statement carries; when nothing resolved, the second
//     statement carries a fresh random id that matches no row, so it
//     runs, writes nothing and returns nothing. Same statement text,
//     same shape, same round trips.
//  3. What is left, the jitter of a container round trip and a row
//     count, is absorbed by CodeUniformFloor.
//
// The one thing that IS allowed to differ is an address with no
// canonical form at all, an empty string or an unknown channel kind,
// which is ErrAddressShape. That leaks nothing: it is a function of the
// caller's own input and any attacker can compute it offline without
// asking. A merely wrong address, one that is well formed and belongs to
// nobody, goes down the ordinary path and is indistinguishable from one
// that does.

import (
	"context"
	"time"

	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// codeCommitmentLabel domain-separates a code commitment from every
// other use of a person's key, so a commitment can never be mistaken for
// or replayed as anything else computed under it.
const codeCommitmentLabel = "auth/code/v1"

// resolveSQL is the first of the two statements both code endpoints run.
// The newest verified channel wins where a person has more than one row
// for an address, which is the ordinary state after a re-verification.
const resolveSQL = `
SELECT person_id FROM person_contact_channel
 WHERE address_lookup = $1
 ORDER BY verified_at DESC, outbox_entry_id
 LIMIT 1`

// RequestCode issues a one-time code to a verified channel and hands it
// to the deliverer.
//
// It returns nil whether or not the address belongs to anyone, whether
// or not the person is over the request limit, and whether or not a code
// was actually sent. That is not error swallowing: the caller is a login
// screen, the only honest thing it can say is "if that address is on an
// account, a code is on its way", and any narrower answer is the
// enumeration oracle criterion 2 forbids.
func (s *Service) RequestCode(ctx context.Context, kind person.ChannelKind, address string) error {
	defer floor(time.Now())
	who, err := s.resolve(ctx, kind, address)
	if err != nil {
		return err
	}
	code, err := newCode()
	if err != nil {
		return err
	}
	commitment, err := s.codeCommitment(ctx, who.real, who.id, code)
	if err != nil {
		return err
	}
	challengeID, err := person.NewID()
	if err != nil {
		return err
	}
	eventID, err := person.NewID()
	if err != nil {
		return err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
WITH resolved AS (
  SELECT person_id FROM person_contact_channel
   WHERE person_id = $1
   LIMIT 1
), recent AS (
  SELECT r.person_id,
         (SELECT count(*) FROM auth_code_challenge c
           WHERE c.person_id = r.person_id
             AND c.issued_at > now() - $2::interval) AS live
    FROM resolved r
), created AS (
  INSERT INTO auth_code_challenge
              (challenge_id, person_id, code_commitment, expires_at)
  SELECT $3, person_id, $4, now() + $5::interval
    FROM recent WHERE live < $6
  RETURNING challenge_id
), noted AS (
  INSERT INTO auth_event (event_id, person_id, method, kind)
  SELECT $7, r.person_id, 'code',
         CASE WHEN EXISTS (SELECT 1 FROM created)
              THEN 'code-requested' ELSE 'code-rate-limited' END
    FROM resolved r
  RETURNING event_id
)
SELECT challenge_id FROM created`,
		transport.String(who.id),
		transport.String(interval(ChallengeWindow)),
		transport.String(challengeID),
		transport.Bytea(commitment),
		transport.String(interval(CodeTTL)),
		transport.Float(MaxChallengesPerWindow),
		transport.String(eventID))
	if err != nil {
		return err
	}
	if len(lines) == 0 {
		// Nobody to deliver to, or the person is over the request limit.
		// Both are silent by design; the event row records which.
		return nil
	}
	return s.deliver.Deliver(ctx, kind, address, code)
}

// SubmitCode exchanges a code for a session.
//
// Every failure is ErrCodeRejected, including an address that belongs to
// nobody. The attempt row is what enforces the lockout: it is written
// whether the code matched or not, and the next submission counts the
// rows rather than reading a counter somebody could reset.
func (s *Service) SubmitCode(ctx context.Context, kind person.ChannelKind, address, code string) (Token, error) {
	defer floor(time.Now())
	who, err := s.resolve(ctx, kind, address)
	if err != nil {
		return "", err
	}
	commitment, err := s.codeCommitment(ctx, who.real, who.id, code)
	if err != nil {
		return "", err
	}
	token, err := newToken()
	if err != nil {
		return "", err
	}
	attemptID, err := person.NewID()
	if err != nil {
		return "", err
	}
	sessionID, err := person.NewID()
	if err != nil {
		return "", err
	}
	eventID, err := person.NewID()
	if err != nil {
		return "", err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
WITH live AS (
  SELECT c.challenge_id, c.person_id, c.code_commitment
    FROM auth_code_challenge c
   WHERE c.person_id = $1
     AND c.expires_at > now()
     AND (SELECT count(*) FROM auth_code_attempt a
           WHERE a.challenge_id = c.challenge_id) < $2
   ORDER BY c.issued_at DESC, c.challenge_id
   LIMIT 1
), matched AS (
  SELECT challenge_id, person_id FROM live WHERE code_commitment = $3
), attempted AS (
  INSERT INTO auth_code_attempt (attempt_id, challenge_id, outcome)
  SELECT $4, challenge_id,
         CASE WHEN EXISTS (SELECT 1 FROM matched)
              THEN 'accepted' ELSE 'rejected' END
    FROM live
  RETURNING attempt_id
), issued AS (
  INSERT INTO auth_session
              (session_id, person_id, token_commitment, method, expires_at)
  SELECT $5, person_id, $6, 'code', now() + $7::interval FROM matched
  RETURNING session_id
), noted AS (
  INSERT INTO auth_event (event_id, person_id, method, kind)
  SELECT $8, person_id, 'code',
         CASE WHEN EXISTS (SELECT 1 FROM matched)
              THEN 'authenticated' ELSE 'code-rejected' END
    FROM live
  RETURNING event_id
)
SELECT session_id FROM issued`,
		transport.String(who.id),
		transport.Float(MaxAttemptsPerChallenge),
		transport.Bytea(commitment),
		transport.String(attemptID),
		transport.String(sessionID),
		transport.Bytea(tokenCommitment(token)),
		transport.String(interval(SessionTTL)),
		transport.String(eventID))
	if err != nil {
		return "", err
	}
	if len(lines) == 0 {
		return "", ErrCodeRejected
	}
	return token, nil
}

// subject is the outcome of the address lookup: an id that is always
// syntactically a person id, and a flag saying whether it names one.
// Both endpoints carry it through the same code afterwards, which is
// what keeps the two branches identical in shape.
type subject struct {
	id   string
	real bool
}

// resolve turns a typed address into a subject. When nothing matched it
// returns a fresh random id, which no person row can hold: every
// downstream statement keys off it and therefore writes nothing and
// returns nothing, without any branch in Go.
func (s *Service) resolve(ctx context.Context, kind person.ChannelKind, address string) (subject, error) {
	lookup, err := s.index.Lookup(ctx, kind, address)
	if err != nil {
		return subject{}, ErrAddressShape
	}
	lines, err := transport.Query(payloadPlane, servingRole, resolveSQL, transport.Bytea(lookup))
	if err != nil {
		return subject{}, err
	}
	if len(lines) == 1 {
		if err := person.ValidID(lines[0]); err != nil {
			return subject{}, err
		}
		return subject{id: lines[0], real: true}, nil
	}
	absent, err := person.NewID()
	if err != nil {
		return subject{}, err
	}
	return subject{id: absent, real: false}, nil
}

// codeCommitment is what the ledger stores instead of an outstanding
// code.
//
// Keyed, and keyed under the PERSON's own scope. A six-digit code has a
// million values, so a plain hash of one is a table an attacker holding
// the database could precompute in seconds; and binding the person into
// the key means two people holding the same code do not hold the same
// commitment, so a code an attacker legitimately holds for their own
// account tells them nothing about anybody else's row. It also means
// destroying a person's key destroys the ability to check their
// outstanding codes, which is the behaviour deletion should have.
//
// When no person resolved, the code is committed under the channel-index
// scope instead of under the random id: same call, same cost, no branch
// in the timing, and no key created for an address somebody merely
// typed. A real key management service creates a key the first time a
// scope is used, so committing under made-up ids would let anyone at the
// login screen fill the key store one probe at a time.
func (s *Service) codeCommitment(ctx context.Context, real bool, personID, code string) ([]byte, error) {
	scope := personID
	if !real {
		scope = keys.ScopeChannelLookup
	}
	message := append([]byte(codeCommitmentLabel), 0)
	message = append(message, code...)
	return s.mac.Mac(ctx, scope, message)
}

// floor holds the caller until CodeUniformFloor has passed since started.
// Deferred at the top of both code endpoints, so it covers every return
// path including the early ones.
func floor(started time.Time) {
	if remaining := CodeUniformFloor - time.Since(started); remaining > 0 {
		time.Sleep(remaining)
	}
}
