package kernel_test

// The chain primitive's own suite (trust-kernel/03). Contract rule 5 is
// four separate claims and each one gets a test: the genesis prev, the
// empty-stream head, the domain tag's position in the preimage, and the
// length-mismatch index rule. The database-facing half of the task
// (streams, heads, merge resolution) is core/streams and is proven
// against the live spine, not here.

import (
	"crypto/sha256"
	"testing"

	"github.com/hiregrain/identity/core/kernel"
)

func TestGenesisPrevIsThirtyTwoZeroBytes(t *testing.T) {
	prev := kernel.GenesisPrev()
	if len(prev) != 32 {
		t.Fatalf("genesis prev is %d bytes, want 32", len(prev))
	}
	for i, b := range prev {
		if b != 0 {
			t.Fatalf("genesis prev byte %d is %#x, want zero", i, b)
		}
	}
}

func TestEmptyHeadIsSixtyFourHexZerosAndMatchesGenesis(t *testing.T) {
	head := kernel.EmptyHead()
	if len(head) != 64 {
		t.Fatalf("empty head is %d characters, want 64", len(head))
	}
	for i := 0; i < len(head); i++ {
		if head[i] != '0' {
			t.Fatalf("empty head character %d is %q, want '0'", i, head[i])
		}
	}
	if got := kernel.GenesisPrev().Hex(); got != head {
		t.Fatalf("genesis prev spells %q, empty head is %q", got, head)
	}
}

func TestLinkPreimageIsTagPrevCanonical(t *testing.T) {
	// The preimage is asserted against a hash computed here from the
	// three parts in order, so the constant and the order are both
	// pinned by something other than the implementation calling itself.
	record := []byte(`{"b":2,"a":1}`)
	canonical, err := kernel.Canonicalize(record)
	if err != nil {
		t.Fatalf("canonicalize: %v", err)
	}
	if string(canonical) != `{"a":1,"b":2}` {
		t.Fatalf("canonical form is %q", canonical)
	}
	prev := kernel.GenesisPrev()
	want := sha256.Sum256(append(append([]byte{0x02}, prev[:]...), canonical...))

	got, err := kernel.Link(prev, record)
	if err != nil {
		t.Fatalf("link: %v", err)
	}
	if kernel.Hash(want) != got {
		t.Fatalf("link is %s, want %x", got.Hex(), want)
	}
}

func TestLinkCanonicalizesTheRecord(t *testing.T) {
	// Two spellings of one record chain to one link: the caller cannot
	// chain bytes that are not the canonical spelling of what it appended.
	a, err := kernel.Link(kernel.GenesisPrev(), []byte(`{"b":2,"a":1}`))
	if err != nil {
		t.Fatalf("link: %v", err)
	}
	b, err := kernel.Link(kernel.GenesisPrev(), []byte("{\n  \"a\": 1,\n  \"b\": 2\n}"))
	if err != nil {
		t.Fatalf("link: %v", err)
	}
	if a != b {
		t.Fatalf("two spellings of one record chained differently: %s vs %s", a.Hex(), b.Hex())
	}
}

func TestLinkRefusesAMalformedRecord(t *testing.T) {
	if _, err := kernel.Link(kernel.GenesisPrev(), []byte(`{"a":`)); err == nil {
		t.Fatal("a malformed record chained without error")
	}
}

func TestHeadOverNoRecordsIsThePrev(t *testing.T) {
	head, err := kernel.Head(kernel.GenesisPrev(), nil)
	if err != nil {
		t.Fatalf("head: %v", err)
	}
	if head.Hex() != kernel.EmptyHead() {
		t.Fatalf("empty fold is %s, want the empty head", head.Hex())
	}
}

// chainOf folds records from genesis and returns both the links and the
// head, the shape a stream holds.
func chainOf(t *testing.T, records [][]byte) ([]kernel.Hash, kernel.Hash) {
	t.Helper()
	links := make([]kernel.Hash, 0, len(records))
	current := kernel.GenesisPrev()
	for _, record := range records {
		next, err := kernel.Link(current, record)
		if err != nil {
			t.Fatalf("link: %v", err)
		}
		links = append(links, next)
		current = next
	}
	return links, current
}

func records(bodies ...string) [][]byte {
	out := make([][]byte, len(bodies))
	for i, body := range bodies {
		out[i] = []byte(body)
	}
	return out
}

func TestVerifyChainAcceptsAnIntactChain(t *testing.T) {
	bodies := records(`{"n":1}`, `{"n":2}`, `{"n":3}`)
	links, head := chainOf(t, bodies)
	result, err := kernel.VerifyChain(kernel.GenesisPrev(), bodies, links)
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if !result.OK || result.FirstBadIndex != -1 || result.Length != 3 {
		t.Fatalf("intact chain verified as %+v", result)
	}
	if head != links[len(links)-1] {
		t.Fatal("the fold's head is not the last link")
	}
}

func TestVerifyChainReportsTheMutatedPosition(t *testing.T) {
	bodies := records(`{"n":1}`, `{"n":2}`, `{"n":3}`, `{"n":4}`)
	links, _ := chainOf(t, bodies)
	for position := 0; position < len(bodies); position++ {
		mutated := make([][]byte, len(bodies))
		copy(mutated, bodies)
		mutated[position] = []byte(`{"n":99}`)
		result, err := kernel.VerifyChain(kernel.GenesisPrev(), mutated, links)
		if err != nil {
			t.Fatalf("verify: %v", err)
		}
		if result.OK || result.FirstBadIndex != position {
			t.Fatalf("mutation at %d reported as %+v", position, result)
		}
	}
}

func TestVerifyChainReportsMinLengthOnAMismatch(t *testing.T) {
	bodies := records(`{"n":1}`, `{"n":2}`, `{"n":3}`)
	links, _ := chainOf(t, bodies)

	// A record removed from under the chain: the walk agrees and then
	// runs out, at min(len) per contract rule 5.
	short, err := kernel.VerifyChain(kernel.GenesisPrev(), bodies[:2], links)
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if short.OK || short.FirstBadIndex != 2 {
		t.Fatalf("missing record reported as %+v, want firstBadIndex 2", short)
	}

	// A link removed from under the records: the same rule, the other way.
	long, err := kernel.VerifyChain(kernel.GenesisPrev(), bodies, links[:1])
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if long.OK || long.FirstBadIndex != 1 {
		t.Fatalf("missing link reported as %+v, want firstBadIndex 1", long)
	}
}

func TestVerifyChainRefusesAReorder(t *testing.T) {
	// Order is what the chain commits to. Two records swapped is a
	// divergence at the first swapped position, not a pass.
	bodies := records(`{"n":1}`, `{"n":2}`, `{"n":3}`)
	links, _ := chainOf(t, bodies)
	swapped := records(`{"n":2}`, `{"n":1}`, `{"n":3}`)
	result, err := kernel.VerifyChain(kernel.GenesisPrev(), swapped, links)
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if result.OK || result.FirstBadIndex != 0 {
		t.Fatalf("reorder reported as %+v", result)
	}
}

func TestParseHashRoundTripsAndRefusesShortInput(t *testing.T) {
	link, err := kernel.Link(kernel.GenesisPrev(), []byte(`{"n":1}`))
	if err != nil {
		t.Fatalf("link: %v", err)
	}
	parsed, err := kernel.ParseHash(link.Hex())
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	if parsed != link {
		t.Fatal("hash did not round-trip through its hex spelling")
	}
	for _, bad := range []string{"", "00", link.Hex()[:63], "ZZ" + link.Hex()[2:]} {
		if _, err := kernel.ParseHash(bad); err == nil {
			t.Fatalf("parsed %q as a hash", bad)
		}
	}
}
