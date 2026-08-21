package person

// The keyed lookup index over contact channels (decision 089).
//
// Signup seals every address under the person's own DEK, which is what
// makes an address unreadable to this ledger and unreadable to anyone
// holding the payload database. It also made "which person holds this
// address" unanswerable, and one-time-code login is exactly that
// question, so without an index the code path could not be built at all
// and would have been demoted to a fallback. Decision 013 forbids that,
// which is why the index exists rather than the path being cut.
//
// The form is decision 020's, ruled there for safety markers and carried
// over here: an HMAC of the canonicalized address under a key held in
// the key management service and never in the database
// (keys.ScopeChannelLookup). A plain hash of an email address is
// enumerable by anyone with a wordlist, and a salt stored beside the
// column does nothing against an attacker who holds the column.
//
// What this costs is recorded with the ruling that created it: one index
// value links every account that ever held one address, across the whole
// population. Its licensed uses are login (person-identity/02) and
// duplicate detection (person-identity/05). A third use is a new
// decision, not an extension of this one.

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/hiregrain/identity/core/keys"
)

// ErrAddressCanonical: the address does not canonicalize, so no index
// value exists for it. Only a malformed address reaches this, since
// Channel.validate has already refused the shapes that cannot be
// canonicalized.
var ErrAddressCanonical = errors.New("person: address does not canonicalize")

// Macer computes a keyed code under a named scope. Satisfied by
// keys.Provider, and named here as a one-verb interface so this package
// takes the capability it uses rather than the whole provider.
type Macer interface {
	Mac(ctx context.Context, scope string, message []byte) ([]byte, error)
}

// ChannelIndex derives the lookup value for a contact channel.
type ChannelIndex struct {
	provider Macer
}

// NewChannelIndex binds the index to a key provider.
func NewChannelIndex(mac Macer) *ChannelIndex { return &ChannelIndex{provider: mac} }

// Canonicalize reduces an address to the one spelling the index is
// computed over. Decision 020's requirement, in its own words: one
// address written two ways must yield one key, or matching does not
// work.
//
// The rules, and where each stops:
//
//   - Surrounding whitespace goes, on both kinds. It is typing, not
//     address.
//   - An email address is lowercased whole. The local part is
//     case-sensitive per RFC 5321, and no mail provider in use treats it
//     that way; a worker who signs up as Worker@example.com and later
//     types worker@example.com is one person, and refusing to match them
//     would fail the login this index exists to serve.
//   - Nothing else about an email is touched. Dot-stripping and
//     plus-tag-stripping are one provider's routing policy, not a
//     property of addresses, and applying them here would collapse two
//     accounts that are genuinely two accounts at every other provider.
//   - A phone number is already E.164 by the time it reaches a channel
//     row (Channel.validate), so there is nothing left to canonicalize
//     beyond the trim.
func Canonicalize(kind ChannelKind, address string) (string, error) {
	trimmed := strings.TrimSpace(address)
	if trimmed == "" {
		return "", fmt.Errorf("%w: empty", ErrAddressCanonical)
	}
	switch kind {
	case KindEmail:
		return strings.ToLower(trimmed), nil
	case KindPhone:
		return trimmed, nil
	default:
		return "", fmt.Errorf("%w: %w", ErrAddressCanonical, ErrChannelKind)
	}
}

// Lookup returns the index value for one channel address. The kind is
// bound into the authenticated message, so an email and a telephone
// number that happened to be spelled alike could not share a value.
func (c *ChannelIndex) Lookup(ctx context.Context, kind ChannelKind, address string) ([]byte, error) {
	canonical, err := Canonicalize(kind, address)
	if err != nil {
		return nil, err
	}
	message := append([]byte(kind), 0)
	message = append(message, canonical...)
	// The one call site of the population-wide scope in this package, so
	// the scope constant appears once and a reader finds every use of it
	// by finding this line.
	value, err := c.provider.Mac(ctx, keys.ScopeChannelLookup, message)
	if err != nil {
		return nil, fmt.Errorf("person: channel lookup: %w", err)
	}
	return value, nil
}
