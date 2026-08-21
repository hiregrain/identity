//go:build db

package auth_test

// The test-side plumbing. Every statement crosses core/transport, the
// one seam any SQL path in this repo may use (trust-kernel/08, decision
// 065), and everything the suite drives runs as identity_app, the
// serving role holding SELECT and INSERT alone (migration 0002). So the
// suite also proves that authentication needs no wider privilege than
// the append-only posture allows: a revoked session is a row, not an
// edit.

import (
	"context"
	"os"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/hiregrain/identity/core/envelope"
	"github.com/hiregrain/identity/core/keys"
	"github.com/hiregrain/identity/core/outbox"
	"github.com/hiregrain/identity/core/person"
	"github.com/hiregrain/identity/core/person/auth"
	"github.com/hiregrain/identity/core/transport"
)

// postbox is the code deliverer under test conditions. It records what
// was handed to it, which is the only way a test can learn a code: the
// ledger keeps a commitment and never the code itself.
type postbox struct {
	mu       sync.Mutex
	messages []message
}

type message struct {
	kind    person.ChannelKind
	address string
	code    string
}

func (p *postbox) Deliver(_ context.Context, kind person.ChannelKind, address, code string) error {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.messages = append(p.messages, message{kind: kind, address: address, code: code})
	return nil
}

func (p *postbox) last(t *testing.T) message {
	t.Helper()
	p.mu.Lock()
	defer p.mu.Unlock()
	if len(p.messages) == 0 {
		t.Fatal("no code was delivered")
	}
	return p.messages[len(p.messages)-1]
}

func (p *postbox) count() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	return len(p.messages)
}

// world is one wired-up system: signup, authentication, and the postbox
// between them.
type world struct {
	people *person.Service
	auth   *auth.Service
	post   *postbox
}

func newWorld(t *testing.T) *world {
	t.Helper()
	name := os.Getenv("GRAIN_KEY_PROVIDER")
	if name == "" {
		name = keys.NameSoftware
	}
	provider, err := keys.FromConfig(name)
	if err != nil {
		t.Fatalf("provider config: %v", err)
	}
	env := envelope.New(
		transport.EnvelopeQuerier{Plane: "payload", Role: "identity_app"}, provider)
	index := person.NewChannelIndex(provider)
	post := &postbox{}
	return &world{
		people: person.New(env, index),
		auth:   auth.New(env, index, provider, post),
		post:   post,
	}
}

// signup creates an account with one verified email and drains the
// outbox, so the channel row and its lookup value exist before anything
// tries to sign in. The drain is explicit rather than assumed: the id is
// issued at spine commit and the payload half follows (person-identity/01).
func (w *world) signup(t *testing.T, address string) string {
	t.Helper()
	id, err := w.people.Signup(context.Background(), person.Request{
		Email: person.Channel{Address: address, VerifiedAt: time.Now()},
	})
	if err != nil {
		t.Fatalf("signup: %v", err)
	}
	if _, failed, err := outbox.Drain(""); err != nil || failed != 0 {
		t.Fatalf("outbox drain: failed=%d err=%v", failed, err)
	}
	return id
}

// codeLogin runs the whole code path: request, read the delivered code,
// submit it, take the session.
func (w *world) codeLogin(t *testing.T, address string) auth.Token {
	t.Helper()
	ctx := context.Background()
	if err := w.auth.RequestCode(ctx, person.KindEmail, address); err != nil {
		t.Fatalf("RequestCode: %v", err)
	}
	delivered := w.post.last(t)
	if delivered.address != address {
		t.Fatalf("code went to %q, want %q", delivered.address, address)
	}
	token, err := w.auth.SubmitCode(ctx, person.KindEmail, address, delivered.code)
	if err != nil {
		t.Fatalf("SubmitCode: %v", err)
	}
	return token
}

// enroll runs a registration ceremony for a fresh virtual authenticator.
func (w *world) enroll(t *testing.T, personID, label string) *authenticator {
	t.Helper()
	ctx := context.Background()
	device := newAuthenticator(t)
	creation, session, err := w.auth.BeginEnrollment(ctx, personID)
	if err != nil {
		t.Fatalf("BeginEnrollment: %v", err)
	}
	response := device.register(t, creation.Response.Challenge.String())
	if _, err := w.auth.FinishEnrollment(ctx, personID, *session, response, label); err != nil {
		t.Fatalf("FinishEnrollment: %v", err)
	}
	return device
}

// passkeyLogin runs an assertion ceremony and takes the session.
func (w *world) passkeyLogin(t *testing.T, personID string, device *authenticator) auth.Token {
	t.Helper()
	ctx := context.Background()
	assertion, session, err := w.auth.BeginPasskeyLogin(ctx, personID)
	if err != nil {
		t.Fatalf("BeginPasskeyLogin: %v", err)
	}
	response := device.assert(t, assertion.Response.Challenge.String(), personID)
	token, err := w.auth.FinishPasskeyLogin(ctx, personID, *session, response)
	if err != nil {
		t.Fatalf("FinishPasskeyLogin: %v", err)
	}
	return token
}

// ownerSQL runs a statement as the owner role: harness inspection only,
// never the path under test.
func ownerSQL(t *testing.T, sql string, args ...transport.Arg) string {
	t.Helper()
	lines, err := transport.Query("payload", "identity", sql, args...)
	if err != nil {
		t.Fatalf("owner sql failed: %v", err)
	}
	return strings.Join(lines, "\n")
}

// address returns a fresh address, so tests never collide on the lookup
// index.
func address(t *testing.T) string {
	t.Helper()
	id, err := person.NewID()
	if err != nil {
		t.Fatalf("address: %v", err)
	}
	return "worker-" + id + "@example.test"
}
