package auth

// The passkey path.
//
// The WebAuthn ceremony parses attacker-supplied CBOR and COSE produced
// by the enrolling device, and hand-rolled parsing of hostile binary
// formats inside identity cryptography is where in-house
// implementations go wrong. Decision 089 licenses go-webauthn as this
// module's first third-party dependency for exactly that reason, and
// pins it. The zero-dependency posture this repo had until now was a
// fact rather than a rule; the next dependency needs its own entry.

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/go-webauthn/webauthn/protocol"
	"github.com/go-webauthn/webauthn/webauthn"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/transport"
)

// Credential is one enrolled passkey as the worker's own credential
// inventory shows it. The authenticator's own identifiers stay sealed
// and never reach this view: a worker needs to know which of their
// devices this is, which is what they called it, and nothing else.
type Credential struct {
	ID         string
	Label      string
	EnrolledAt time.Time
}

// relyingParty returns the one relying party this ledger is. The
// configuration is constant (decision 084), so a failure to build it is
// a programming error rather than a runtime condition, and it is built
// once and reused.
var relyingParty = sync.OnceValues(func() (*webauthn.WebAuthn, error) {
	return webauthn.New(&webauthn.Config{
		RPID:          RelyingPartyID,
		RPDisplayName: RelyingPartyDisplayName,
		RPOrigins:     []string{RelyingPartyOrigin},
		AuthenticatorSelection: protocol.AuthenticatorSelection{
			// Discoverable, so a worker can sign in without typing an
			// address first. That is what makes the passkey path
			// self-sufficient rather than dependent on the code path's
			// lookup.
			ResidentKey: protocol.ResidentKeyRequirementPreferred,
			// Preferred, not required. Requiring user verification would
			// exclude every authenticator without a biometric or a PIN,
			// and decision 013's rule is that no worker is excluded by
			// device class. Decision 083 requires it for operators, who
			// are a different population with issued hardware.
			UserVerification: protocol.VerificationPreferred,
		},
	})
})

// ledgerUser is the WebAuthn user this ledger presents.
//
// Every field the specification calls human-palatable is the person's
// opaque ledger id, and that is deliberate. The name and display name
// travel to the authenticator and are shown in the platform's own
// passkey picker, which is outside this ledger's control and outside its
// deletion promise. The person's address and display name are sealed
// content (migration 0036); putting either here would publish it to a
// surface nothing here can reach again.
type ledgerUser struct {
	id          string
	credentials []webauthn.Credential
}

func (u ledgerUser) WebAuthnID() []byte                         { return []byte(u.id) }
func (u ledgerUser) WebAuthnName() string                       { return u.id }
func (u ledgerUser) WebAuthnDisplayName() string                { return u.id }
func (u ledgerUser) WebAuthnCredentials() []webauthn.Credential { return u.credentials }

// descriptors names the person's already-enrolled credentials, so an
// enrollment ceremony can exclude them. The library's own helper over a
// Credentials slice.
func (u ledgerUser) descriptors() []protocol.CredentialDescriptor {
	return webauthn.Credentials(u.credentials).CredentialDescriptors()
}

// BeginEnrollment starts a registration ceremony for a person who is
// already signed in. The returned session data is the challenge and
// belongs to the caller's own request state; it never touches the
// ledger, because a challenge that outlived one ceremony would be a
// replay window.
func (s *Service) BeginEnrollment(ctx context.Context, personID string) (*protocol.CredentialCreation, *webauthn.SessionData, error) {
	rp, err := relyingParty()
	if err != nil {
		return nil, nil, err
	}
	user, err := s.user(ctx, personID)
	if err != nil {
		return nil, nil, err
	}
	// Exclude the credentials the person already holds, so one
	// authenticator cannot enroll twice on the same account and leave a
	// duplicate row the worker's inventory then shows as two devices.
	// s.user already loaded them, so this costs nothing further.
	return rp.BeginRegistration(user, webauthn.WithExclusions(user.descriptors()))
}

// FinishEnrollment verifies the authenticator's response and stores the
// credential, sealed under the person's own DEK. label is what the
// worker calls the device; an empty label is stored as an absent one
// rather than as an empty string, so a reader can tell "unnamed" from
// "named nothing".
//
// Multiple credentials per person is the normal case, not an edge:
// losing the only enrolled device must not lose the account, and the
// code path is what covers the worker who has lost it anyway.
func (s *Service) FinishEnrollment(
	ctx context.Context,
	personID string,
	session webauthn.SessionData,
	response *protocol.ParsedCredentialCreationData,
	label string,
) (string, error) {
	rp, err := relyingParty()
	if err != nil {
		return "", err
	}
	user, err := s.user(ctx, personID)
	if err != nil {
		return "", err
	}
	credential, err := rp.CreateCredential(user, session, response)
	if err != nil {
		return "", fmt.Errorf("auth: credential rejected: %w", err)
	}
	encoded, err := json.Marshal(credential)
	if err != nil {
		return "", fmt.Errorf("auth: encoding a credential: %w", err)
	}
	sealed, err := s.vault.Encrypt(ctx, personID, encoded)
	if err != nil {
		return "", err
	}
	labelArg := transport.Null
	if label != "" {
		sealedLabel, err := s.vault.Encrypt(ctx, personID, []byte(label))
		if err != nil {
			return "", err
		}
		labelArg = transport.Bytea(sealedLabel)
	}
	credentialID, err := person.NewID()
	if err != nil {
		return "", err
	}
	eventID, err := person.NewID()
	if err != nil {
		return "", err
	}
	if _, err := transport.Query(payloadPlane, servingRole, `
WITH enrolled AS (
  INSERT INTO auth_credential
              (credential_id, person_id, credential_ciphertext, label_ciphertext)
  VALUES ($1, $2, $3, $4)
  RETURNING credential_id, person_id
), noted AS (
  INSERT INTO auth_event (event_id, person_id, method, kind)
  SELECT $5, person_id, 'passkey', 'credential-enrolled' FROM enrolled
  RETURNING event_id
)
SELECT credential_id FROM enrolled`,
		transport.String(credentialID),
		transport.String(personID),
		transport.Bytea(sealed),
		labelArg,
		transport.String(eventID)); err != nil {
		return "", err
	}
	return credentialID, nil
}

// BeginPasskeyLogin starts an assertion ceremony for a person the caller
// has already resolved, by discoverable credential or by the address
// lookup the code path uses.
//
// Caller obligation, the same shape as Sessions/Credentials/Events/Revoke
// carry: when the personID was resolved from an address the visitor typed
// rather than from a discoverable credential, the caller MUST mask
// ErrNoCredential and return the identical response it returns for a
// person who does have a passkey. This method distinguishes the two
// (a challenge versus ErrNoCredential), which is correct for a
// discoverable login where the authenticator already proved possession,
// and an enumeration oracle on a typed address where it did not: without
// the mask a serving layer would answer "this address has a passkey" to
// anyone. The code path's own endpoints are uniform in wording and time
// by construction (code.go); this one is uniform only if its caller makes
// it so, which is why the obligation is stated rather than enforced here,
// the resolution having happened before this call.
func (s *Service) BeginPasskeyLogin(ctx context.Context, personID string) (*protocol.CredentialAssertion, *webauthn.SessionData, error) {
	rp, err := relyingParty()
	if err != nil {
		return nil, nil, err
	}
	user, err := s.user(ctx, personID)
	if err != nil {
		return nil, nil, err
	}
	if len(user.credentials) == 0 {
		return nil, nil, ErrNoCredential
	}
	return rp.BeginLogin(user)
}

// FinishPasskeyLogin verifies the assertion and issues a session.
//
// The session it issues is the same kind of session SubmitCode issues,
// differing only in the method column, which nothing reads. That is
// decision 013's equal-path rule at the one place it could quietly stop
// being true.
func (s *Service) FinishPasskeyLogin(
	ctx context.Context,
	personID string,
	session webauthn.SessionData,
	response *protocol.ParsedCredentialAssertionData,
) (Token, error) {
	rp, err := relyingParty()
	if err != nil {
		return "", err
	}
	user, err := s.user(ctx, personID)
	if err != nil {
		return "", err
	}
	// ValidateLogin returns the updated *webauthn.Credential, carrying the
	// authenticator's new signature counter and its CloneWarning. Both are
	// intentionally not persisted: the worker population this serves signs
	// in with synced platform passkeys (iCloud Keychain, Google Password
	// Manager), which report a signCount of 0 on every assertion, so a
	// stored counter would never advance and a clone check against it would
	// only produce false alarms. Clone detection is a hardware-security-key
	// control, and decision 013 forbids requiring that class of device.
	// This is recorded because every other comparable choice in this file
	// is (the discarded discoverable-login user handle, the unchecked
	// AAGUID); a silent discard here would be the one that is not.
	if _, err := rp.ValidateLogin(user, session, response); err != nil {
		return "", fmt.Errorf("auth: assertion rejected: %w", err)
	}
	return s.issue(ctx, personID, MethodPasskey)
}

// Credentials is the worker's own credential inventory: which devices
// can sign in to this account, and when each was enrolled.
func (s *Service) Credentials(ctx context.Context, personID string) ([]Credential, error) {
	rows, err := s.credentialRows(ctx, personID)
	if err != nil {
		return nil, err
	}
	inventory := make([]Credential, 0, len(rows))
	for _, row := range rows {
		inventory = append(inventory, Credential{
			ID:         row.id,
			Label:      row.label,
			EnrolledAt: row.enrolledAt,
		})
	}
	return inventory, nil
}

// issue writes one session and its event for the passkey path.
//
// The code path does not call this: it writes its session inside the one
// statement that also records the attempt, because an accepted code and
// the session it bought must land together or the lockout could be spent
// without a session to show for it. The two INSERTs are therefore two
// copies of one shape, and the thing that keeps them one shape is
// TestAuthBothPathsIssueTheSameKindOfSession, which compares the rows
// they produce field by field.
func (s *Service) issue(_ context.Context, personID, method string) (Token, error) {
	token, err := newToken()
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
WITH issued AS (
  INSERT INTO auth_session
              (session_id, person_id, token_commitment, method, expires_at)
  VALUES ($1, $2, $3, $4, now() + $5::interval)
  RETURNING session_id, person_id, method
), noted AS (
  INSERT INTO auth_event (event_id, person_id, method, kind)
  SELECT $6, person_id, method, 'authenticated' FROM issued
  RETURNING event_id
)
SELECT session_id FROM issued`,
		transport.String(sessionID),
		transport.String(personID),
		transport.Bytea(tokenCommitment(token)),
		transport.String(method),
		transport.String(interval(SessionTTL)),
		transport.String(eventID))
	if err != nil {
		return "", err
	}
	if len(lines) == 0 {
		return "", fmt.Errorf("auth: session insert returned no row")
	}
	return token, nil
}

// credentialRow is one stored credential, opened.
type credentialRow struct {
	id         string
	label      string
	enrolledAt time.Time
	credential webauthn.Credential
}

// credentialRows loads and opens a person's credentials. Lookup is by
// person and never by the authenticator's credential id, which is sealed
// (migration 0037 says why); the few rows a person holds are opened and
// compared in memory, which is what the WebAuthn library does with them
// anyway.
func (s *Service) credentialRows(ctx context.Context, personID string) ([]credentialRow, error) {
	if err := person.ValidID(personID); err != nil {
		return nil, err
	}
	lines, err := transport.Query(payloadPlane, servingRole, `
SELECT credential_id, encode(credential_ciphertext, 'hex'),
       coalesce(encode(label_ciphertext, 'hex'), ''), enrolled_at
  FROM auth_credential
 WHERE person_id = $1
 ORDER BY enrolled_at, credential_id`,
		transport.String(personID))
	if err != nil {
		return nil, err
	}
	rows := make([]credentialRow, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 4)
		if len(fields) != 4 {
			return nil, fmt.Errorf("auth: credential row has %d fields", len(fields))
		}
		sealed, err := hex.DecodeString(fields[1])
		if err != nil {
			return nil, fmt.Errorf("auth: unreadable credential ciphertext: %w", err)
		}
		opened, err := s.vault.Decrypt(ctx, personID, sealed)
		if err != nil {
			return nil, err
		}
		var credential webauthn.Credential
		if err := json.Unmarshal(opened, &credential); err != nil {
			return nil, fmt.Errorf("auth: decoding a credential: %w", err)
		}
		label := ""
		if fields[2] != "" {
			sealedLabel, err := hex.DecodeString(fields[2])
			if err != nil {
				return nil, fmt.Errorf("auth: unreadable label ciphertext: %w", err)
			}
			openedLabel, err := s.vault.Decrypt(ctx, personID, sealedLabel)
			if err != nil {
				return nil, err
			}
			label = string(openedLabel)
		}
		enrolled, err := parseStamp(fields[3])
		if err != nil {
			return nil, err
		}
		rows = append(rows, credentialRow{
			id:         fields[0],
			label:      label,
			enrolledAt: enrolled,
			credential: credential,
		})
	}
	return rows, nil
}

// user assembles the WebAuthn user for a person: their id and every
// credential they hold.
func (s *Service) user(ctx context.Context, personID string) (ledgerUser, error) {
	rows, err := s.credentialRows(ctx, personID)
	if err != nil {
		return ledgerUser{}, err
	}
	credentials := make([]webauthn.Credential, 0, len(rows))
	for _, row := range rows {
		credentials = append(credentials, row.credential)
	}
	return ledgerUser{id: personID, credentials: credentials}, nil
}
