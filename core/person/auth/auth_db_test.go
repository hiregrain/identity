//go:build db

package auth_test

// The acceptance suite for person-identity/02, driven end to end against
// both live planes: signup writes the channel and its lookup value, and
// authentication reads them back through the same seam a server would.

import (
	"context"
	"errors"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/person/auth"
	"github.com/hiregrain/identity/core/transport"
)

// Criterion 1, first half: both paths authenticate the same identity.
//
// One account, one enrolled passkey, one verified email. Signing in
// either way produces a session, and both sessions resolve to the same
// person id.
func TestAuthBothPathsReachTheSameIdentity(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)
	device := w.enroll(t, personID, "the test handset")

	byPasskey := w.passkeyLogin(t, personID, device)
	byCode := w.codeLogin(t, email)
	if byPasskey == byCode {
		t.Fatal("two logins produced one token")
	}

	first, err := w.auth.Authenticate(ctx, byPasskey)
	if err != nil {
		t.Fatalf("Authenticate(passkey session): %v", err)
	}
	second, err := w.auth.Authenticate(ctx, byCode)
	if err != nil {
		t.Fatalf("Authenticate(code session): %v", err)
	}
	if first.PersonID != personID || second.PersonID != personID {
		t.Fatalf("passkey session %s and code session %s, want both %s",
			first.PersonID, second.PersonID, personID)
	}
	if first.Method != auth.MethodPasskey || second.Method != auth.MethodCode {
		t.Fatalf("methods recorded as %q and %q", first.Method, second.Method)
	}
	if first.ID == second.ID {
		t.Fatal("two logins produced one session")
	}
}

// Criterion 1, second half: a session revoked by the worker fails on its
// next request.
//
// Revocation is checked mid-flight rather than at issuance: the session
// authenticates, then is revoked, then the same token is presented again
// and must fail. Both paths are run, so neither can be the one that
// keeps working.
func TestAuthRevokedSessionFailsItsNextRequest(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)
	device := w.enroll(t, personID, "")

	for _, c := range []struct {
		name  string
		token auth.Token
	}{
		{"passkey", w.passkeyLogin(t, personID, device)},
		{"code", w.codeLogin(t, email)},
	} {
		live, err := w.auth.Authenticate(ctx, c.token)
		if err != nil {
			t.Fatalf("%s: the session did not authenticate before revocation: %v", c.name, err)
		}
		if err := w.auth.Revoke(ctx, personID, live.ID); err != nil {
			t.Fatalf("%s: Revoke: %v", c.name, err)
		}
		if _, err := w.auth.Authenticate(ctx, c.token); !errors.Is(err, auth.ErrNoSession) {
			t.Fatalf("%s: the revoked token still authenticates: %v", c.name, err)
		}
		// Revoking again is not an error: the worker tapped twice and the
		// record already says what they wanted it to say.
		if err := w.auth.Revoke(ctx, personID, live.ID); err != nil {
			t.Fatalf("%s: second Revoke: %v", c.name, err)
		}
	}

	// A session belonging to somebody else cannot be revoked, and the
	// refusal writes nothing.
	stranger := w.signup(t, address(t))
	mine := w.codeLogin(t, email)
	session, err := w.auth.Authenticate(ctx, mine)
	if err != nil {
		t.Fatalf("Authenticate: %v", err)
	}
	if err := w.auth.Revoke(ctx, stranger, session.ID); !errors.Is(err, auth.ErrNotYours) {
		t.Fatalf("a stranger revoked a session: %v", err)
	}
	if _, err := w.auth.Authenticate(ctx, mine); err != nil {
		t.Fatalf("the refused revocation took effect anyway: %v", err)
	}
}

// Criterion 2: the code endpoints resist enumeration.
//
// Uniform in three ways, each asserted separately, because two of them
// can hold while the third leaks:
//
//   - the return value is identical for an address on an account and one
//     on no account,
//   - nothing is written for the address on no account, so a later reader
//     of the tables cannot tell which addresses were probed,
//   - the time taken does not separate the two.
//
// A fresh account per round, so no round runs into the request limit and
// changes which branch the known address takes.
func TestAuthCodeEndpointsResistEnumeration(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)

	const rounds = 5
	known := make([]string, rounds)
	unknown := make([]string, rounds)
	for i := 0; i < rounds; i++ {
		known[i] = address(t)
		w.signup(t, known[i])
		unknown[i] = address(t)
	}

	var onAccount, offAccount []time.Duration
	for i := 0; i < rounds; i++ {
		for _, c := range []struct {
			address string
			samples *[]time.Duration
		}{
			{known[i], &onAccount},
			{unknown[i], &offAccount},
		} {
			started := time.Now()
			err := w.auth.RequestCode(ctx, person.KindEmail, c.address)
			*c.samples = append(*c.samples, time.Since(started))
			if err != nil {
				t.Fatalf("RequestCode returned %v; both cases must return nil", err)
			}
		}
	}

	// The submissions are uniform too, and a wrong code on a real account
	// is the third case that must not be distinguishable from either.
	for _, target := range []string{known[0], unknown[0]} {
		if _, err := w.auth.SubmitCode(ctx, person.KindEmail, target, "000000"); !errors.Is(err, auth.ErrCodeRejected) {
			t.Fatalf("SubmitCode returned %v, want ErrCodeRejected", err)
		}
	}

	// Nothing was recorded against an address on no account. The
	// challenge and event tables are keyed by person, and no person
	// exists, so a probe that left a trace could only have invented one.
	for _, probe := range []struct{ table, sql string }{
		{"auth_code_challenge", `
SELECT count(*) FROM auth_code_challenge c
 WHERE NOT EXISTS (SELECT 1 FROM person_contact_channel p
                    WHERE p.person_id = c.person_id)`},
		{"auth_event", `
SELECT count(*) FROM auth_event e
 WHERE NOT EXISTS (SELECT 1 FROM person_contact_channel p
                    WHERE p.person_id = e.person_id)`},
		{"auth_code_attempt", `
SELECT count(*) FROM auth_code_attempt a
  JOIN auth_code_challenge c ON c.challenge_id = a.challenge_id
 WHERE NOT EXISTS (SELECT 1 FROM person_contact_channel p
                    WHERE p.person_id = c.person_id)`},
	} {
		if orphans := ownerSQL(t, probe.sql); orphans != "0" {
			t.Fatalf("%s holds %s row(s) for no person", probe.table, orphans)
		}
	}

	assertIndistinguishable(t, "RequestCode", onAccount, offAccount)
}

// Criterion 3: a device with no passkey support completes login start to
// finish.
//
// Decision 013's equal path, driven as a worker on such a device
// experiences it: no credential is ever enrolled, no WebAuthn ceremony
// is ever run, and the account is reached, used, listed and signed out
// of entirely through the code path.
func TestAuthLoginWithoutAPasskeyCompletesEndToEnd(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)

	// The device cannot enroll, and asking to sign in with a passkey it
	// does not have is refused cleanly rather than crashing the flow.
	if _, _, err := w.auth.BeginPasskeyLogin(ctx, personID); !errors.Is(err, auth.ErrNoCredential) {
		t.Fatalf("BeginPasskeyLogin with no credential: %v, want ErrNoCredential", err)
	}

	token := w.codeLogin(t, email)
	session, err := w.auth.Authenticate(ctx, token)
	if err != nil {
		t.Fatalf("Authenticate: %v", err)
	}
	if session.PersonID != personID {
		t.Fatalf("session belongs to %s, want %s", session.PersonID, personID)
	}
	credentials, err := w.auth.Credentials(ctx, personID)
	if err != nil {
		t.Fatalf("Credentials: %v", err)
	}
	if len(credentials) != 0 {
		t.Fatalf("a device with no passkey support ended up with %d credential(s)", len(credentials))
	}
	sessions, err := w.auth.Sessions(ctx, personID)
	if err != nil {
		t.Fatalf("Sessions: %v", err)
	}
	if len(sessions) != 1 || !sessions[0].Live || sessions[0].Method != auth.MethodCode {
		t.Fatalf("session list: %+v", sessions)
	}
	if err := w.auth.Revoke(ctx, personID, session.ID); err != nil {
		t.Fatalf("Revoke: %v", err)
	}
	if _, err := w.auth.Authenticate(ctx, token); !errors.Is(err, auth.ErrNoSession) {
		t.Fatalf("signing out did not end the session: %v", err)
	}
}

// Criterion 4: routine operations from a code session are never blocked.
//
// Stated as a comparison rather than as a list of allowed operations,
// because a list is a thing that drifts: every operation this package
// exposes to a signed-in worker is run from a code session and from a
// passkey session on the same account, and the two must agree on every
// one. An operation added later that reads the method fails here without
// anybody remembering to add it to a list.
func TestAuthCodeSessionIsNeverBlocked(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)
	device := w.enroll(t, personID, "the test handset")

	codeToken := w.codeLogin(t, email)
	passkeyToken := w.passkeyLogin(t, personID, device)
	codeSession := mustAuthenticate(t, w, codeToken)
	passkeySession := mustAuthenticate(t, w, passkeyToken)
	if codeSession.Method != auth.MethodCode || passkeySession.Method != auth.MethodPasskey {
		t.Fatalf("the two sessions are not one of each: %q and %q",
			codeSession.Method, passkeySession.Method)
	}

	operations := []struct {
		name string
		run  func(personID string, token auth.Token) error
	}{
		{"read the account's own session list", func(id string, _ auth.Token) error {
			_, err := w.auth.Sessions(ctx, id)
			return err
		}},
		{"read the credential inventory", func(id string, _ auth.Token) error {
			_, err := w.auth.Credentials(ctx, id)
			return err
		}},
		{"read the account's own activity", func(id string, _ auth.Token) error {
			_, err := w.auth.Events(ctx, id)
			return err
		}},
		// Credential enrollment is the operation decision 020 once put
		// behind step-up. Decision 086 moved that ruling to the
		// verification layer, so until it returns, a code session
		// enrolls, and this line is where the day it changes will show.
		{"start enrolling another credential", func(id string, _ auth.Token) error {
			_, _, err := w.auth.BeginEnrollment(ctx, id)
			return err
		}},
		{"start a passkey sign-in", func(id string, _ auth.Token) error {
			_, _, err := w.auth.BeginPasskeyLogin(ctx, id)
			return err
		}},
		{"present the bearer token again", func(_ string, token auth.Token) error {
			_, err := w.auth.Authenticate(ctx, token)
			return err
		}},
	}
	for _, op := range operations {
		fromCode := op.run(codeSession.PersonID, codeToken)
		fromPasskey := op.run(passkeySession.PersonID, passkeyToken)
		if (fromCode == nil) != (fromPasskey == nil) {
			t.Fatalf("%s: code session got %v, passkey session got %v; the code path is not equal",
				op.name, fromCode, fromPasskey)
		}
		if fromCode != nil {
			t.Fatalf("%s: refused from a code session: %v", op.name, fromCode)
		}
	}
}

// Both paths issue the same kind of session. The two INSERT statements
// live in two files, because the code path writes its session inside the
// statement that records the attempt, so this compares the rows they
// produce rather than trusting the two to stay in step.
func TestAuthBothPathsIssueTheSameKindOfSession(t *testing.T) {
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)
	device := w.enroll(t, personID, "")

	byPasskey := mustAuthenticate(t, w, w.passkeyLogin(t, personID, device))
	byCode := mustAuthenticate(t, w, w.codeLogin(t, email))

	shape := func(id string) string {
		return ownerSQL(t, `
SELECT person_id, length(token_commitment), residency_region,
       (expires_at - issued_at)
  FROM auth_session WHERE session_id = $1`, transport.String(id))
	}
	if a, b := shape(byPasskey.ID), shape(byCode.ID); a != b {
		t.Fatalf("the two paths write different session rows:\n passkey %s\n code    %s", a, b)
	}
}

// Multiple credentials per person, and the inventory the worker sees.
func TestAuthCredentialInventory(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	personID := w.signup(t, address(t))
	w.enroll(t, personID, "the phone")
	laptop := w.enroll(t, personID, "the laptop")
	w.enroll(t, personID, "")

	inventory, err := w.auth.Credentials(ctx, personID)
	if err != nil {
		t.Fatalf("Credentials: %v", err)
	}
	if len(inventory) != 3 {
		t.Fatalf("inventory holds %d credential(s), want the three enrolled", len(inventory))
	}
	labels := []string{}
	for _, c := range inventory {
		labels = append(labels, c.Label)
	}
	sort.Strings(labels)
	if strings.Join(labels, "|") != "|the laptop|the phone" {
		t.Fatalf("labels: %v", labels)
	}

	// Any of them signs in, which is what "losing one device does not
	// lose the account" means in practice.
	if _, err := w.auth.Authenticate(ctx, w.passkeyLogin(t, personID, laptop)); err != nil {
		t.Fatalf("the second credential does not sign in: %v", err)
	}

	// The labels are sealed: the payload plane holds no readable copy.
	stored := ownerSQL(t, `
SELECT coalesce(string_agg(encode(credential_ciphertext, 'escape'), ' '), '')
       || coalesce(string_agg(encode(label_ciphertext, 'escape'), ' '), '')
  FROM auth_credential WHERE person_id = $1`, transport.String(personID))
	for _, secret := range []string{"the phone", "the laptop"} {
		if strings.Contains(stored, secret) {
			t.Fatalf("a credential label is readable in the payload plane: %q", secret)
		}
	}
}

// An enrollment ceremony excludes the credentials the person already
// holds, so one authenticator cannot enroll twice and appear in the
// inventory as two devices.
//
// The exclusion is asserted on the ceremony options rather than on a
// rejected second registration: the virtual authenticator here crafts
// response bytes directly and does not consult the exclude list a real
// platform authenticator would, so the check is that the list the
// browser receives is populated and grows with each enrolled credential.
func TestAuthEnrollmentExcludesExistingCredentials(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	personID := w.signup(t, address(t))

	// A first enrollment has nothing to exclude yet.
	first, _, err := w.auth.BeginEnrollment(ctx, personID)
	if err != nil {
		t.Fatalf("BeginEnrollment: %v", err)
	}
	if n := len(first.Response.CredentialExcludeList); n != 0 {
		t.Fatalf("first enrollment excludes %d credential(s), want none", n)
	}

	// After one device is enrolled, the next ceremony excludes it; after
	// two, it excludes both.
	w.enroll(t, personID, "the phone")
	second, _, err := w.auth.BeginEnrollment(ctx, personID)
	if err != nil {
		t.Fatalf("BeginEnrollment: %v", err)
	}
	if n := len(second.Response.CredentialExcludeList); n != 1 {
		t.Fatalf("second enrollment excludes %d credential(s), want the one enrolled", n)
	}
	w.enroll(t, personID, "the laptop")
	third, _, err := w.auth.BeginEnrollment(ctx, personID)
	if err != nil {
		t.Fatalf("BeginEnrollment: %v", err)
	}
	if n := len(third.Response.CredentialExcludeList); n != 2 {
		t.Fatalf("third enrollment excludes %d credential(s), want the two enrolled", n)
	}
}

// Rate limiting and lockout on the code paths.
func TestAuthCodeRateLimitAndLockout(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)

	// The request limit. Asking past it is silent, which is what keeps
	// the endpoint uniform, so the assertions are that no further code
	// was delivered and that the refusal was recorded.
	for i := 0; i < auth.MaxChallengesPerWindow+2; i++ {
		if err := w.auth.RequestCode(ctx, person.KindEmail, email); err != nil {
			t.Fatalf("RequestCode: %v", err)
		}
	}
	if delivered := w.post.count(); delivered != auth.MaxChallengesPerWindow {
		t.Fatalf("%d code(s) delivered, want the request limit", delivered)
	}
	if limited := ownerSQL(t, `
SELECT count(*) FROM auth_event
 WHERE person_id = $1 AND kind = 'code-rate-limited'`, transport.String(personID)); limited != "2" {
		t.Fatalf("%s rate-limit event(s) recorded, want the two refused requests", limited)
	}

	// The lockout. The newest challenge is the live one; wrong codes
	// against it are counted until it is spent, and then the right code
	// no longer works either.
	delivered := w.post.last(t)
	wrong := "000000"
	if delivered.code == wrong {
		wrong = "111111"
	}
	for i := 0; i < auth.MaxAttemptsPerChallenge; i++ {
		if _, err := w.auth.SubmitCode(ctx, person.KindEmail, email, wrong); !errors.Is(err, auth.ErrCodeRejected) {
			t.Fatalf("wrong code %d: %v", i, err)
		}
	}
	if _, err := w.auth.SubmitCode(ctx, person.KindEmail, email, delivered.code); !errors.Is(err, auth.ErrCodeRejected) {
		t.Fatalf("the right code still worked after the lockout: %v", err)
	}
	if _, err := w.auth.Authenticate(ctx, ""); !errors.Is(err, auth.ErrNoSession) {
		t.Fatalf("an empty token authenticated: %v", err)
	}
}

// Every authentication event is recorded, in one closed vocabulary, in
// the order the events happened.
func TestAuthEventsAreRecorded(t *testing.T) {
	ctx := context.Background()
	w := newWorld(t)
	email := address(t)
	personID := w.signup(t, email)
	device := w.enroll(t, personID, "")
	token := w.passkeyLogin(t, personID, device)
	session, err := w.auth.Authenticate(ctx, token)
	if err != nil {
		t.Fatalf("Authenticate: %v", err)
	}
	if err := w.auth.Revoke(ctx, personID, session.ID); err != nil {
		t.Fatalf("Revoke: %v", err)
	}
	w.codeLogin(t, email)

	events, err := w.auth.Events(ctx, personID)
	if err != nil {
		t.Fatalf("Events: %v", err)
	}
	kinds := []string{}
	for _, e := range events {
		kinds = append(kinds, e.Method+"/"+e.Kind)
	}
	want := []string{
		"passkey/credential-enrolled",
		"passkey/authenticated",
		"session/session-revoked",
		"code/code-requested",
		"code/authenticated",
	}
	if strings.Join(kinds, " ") != strings.Join(want, " ") {
		t.Fatalf("events:\n got  %s\n want %s",
			strings.Join(kinds, " "), strings.Join(want, " "))
	}
}

// mustAuthenticate resolves a token or fails the test.
func mustAuthenticate(t *testing.T, w *world, token auth.Token) auth.Session {
	t.Helper()
	session, err := w.auth.Authenticate(context.Background(), token)
	if err != nil {
		t.Fatalf("Authenticate: %v", err)
	}
	return session
}

// assertIndistinguishable fails when two timing samples separate. The
// tolerance is a fraction of CodeUniformFloor rather than a bare
// millisecond count, because the floor is the mechanism: both branches
// finish under it, both therefore take the floor, and what is left
// between their means is jitter.
func assertIndistinguishable(t *testing.T, what string, a, b []time.Duration) {
	t.Helper()
	meanA, maxA := summarize(a)
	meanB, maxB := summarize(b)
	gap := meanA - meanB
	if gap < 0 {
		gap = -gap
	}
	tolerance := auth.CodeUniformFloor / 8
	if gap > tolerance {
		t.Fatalf("%s separates the two cases in time: means %v and %v, gap %v over a tolerance of %v",
			what, meanA, meanB, gap, tolerance)
	}
	// Every sample sits at the floor by construction, so a sample much
	// past it means the branch's own work outran the floor. At that point
	// the floor has stopped padding and the difference between the
	// branches is showing through, whatever the means happen to say.
	for _, longest := range []time.Duration{maxA, maxB} {
		if longest > auth.CodeUniformFloor+tolerance {
			t.Fatalf("%s ran to %v against a floor of %v; the floor is too low for this machine "+
				"and has stopped hiding the difference between the branches",
				what, longest, auth.CodeUniformFloor)
		}
	}
}

func summarize(samples []time.Duration) (mean, longest time.Duration) {
	var total time.Duration
	for _, s := range samples {
		total += s
		if s > longest {
			longest = s
		}
	}
	return total / time.Duration(len(samples)), longest
}
