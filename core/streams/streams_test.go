package streams_test

// The database-free half of the streams suite: alias resolution, which
// is the whole of what a merge does to chains, and the validation that
// keeps a stream key or a stream type from reaching a statement. The
// chain walks themselves are proven against the live spine in
// streams_db_test.go.

import (
	"errors"
	"testing"

	"github.com/hiregrain/identity/core/streams"
)

const (
	idA = "1f2e3d4c-5b6a-4978-8765-4321fedcba98"
	idB = "2f2e3d4c-5b6a-4978-8765-4321fedcba98"
	idC = "3f2e3d4c-5b6a-4978-8765-4321fedcba98"
)

func TestResolveWithoutAliasesIsTheIdItself(t *testing.T) {
	keys := streams.Resolve(idA, nil)
	if len(keys) != 1 || keys[0] != idA {
		t.Fatalf("resolved to %v", keys)
	}
}

func TestResolveFollowsAbsorbedEdgesTransitively(t *testing.T) {
	// A merged into B, then B merged into C: C's history is all three
	// chains, and none of them moved.
	aliases := []streams.Alias{
		{Absorbed: idA, Survivor: idB},
		{Absorbed: idB, Survivor: idC},
	}
	keys := streams.Resolve(idC, aliases)
	if len(keys) != 3 {
		t.Fatalf("closure is %v, want three keys", keys)
	}
	for i := 1; i < len(keys); i++ {
		if keys[i-1] >= keys[i] {
			t.Fatalf("closure is not sorted: %v", keys)
		}
	}
}

func TestResolveDoesNotFollowSurvivorEdgesBackwards(t *testing.T) {
	// An absorbed id resolves to itself alone. Reading through an
	// absorbed id and landing on the survivor is the resolution layer's
	// job above this one; the closure here is what a survivor's history
	// is assembled from.
	aliases := []streams.Alias{{Absorbed: idA, Survivor: idB}}
	keys := streams.Resolve(idA, aliases)
	if len(keys) != 1 || keys[0] != idA {
		t.Fatalf("absorbed id resolved to %v", keys)
	}
}

func TestResolveTerminatesOnACycle(t *testing.T) {
	// A well-formed merge history cannot produce this. The closure
	// visits each key once, so a malformed one terminates rather than
	// hanging a read path.
	aliases := []streams.Alias{
		{Absorbed: idA, Survivor: idB},
		{Absorbed: idB, Survivor: idA},
	}
	if keys := streams.Resolve(idA, aliases); len(keys) != 2 {
		t.Fatalf("cycle resolved to %v", keys)
	}
}

func TestEmptyHeadIsGenesisAtPositionBeforeZero(t *testing.T) {
	head := streams.EmptyHead()
	if head.Position != -1 {
		t.Fatalf("empty head position is %d, want -1", head.Position)
	}
	if head.Hash.Hex() != "0000000000000000000000000000000000000000000000000000000000000000" {
		t.Fatalf("empty head hash is %s", head.Hash.Hex())
	}
}

func TestStageRefusesAnUnknownTypeAndAMalformedKey(t *testing.T) {
	// Validation happens before any statement is built, so neither an
	// unknown stream type nor a key that is not a UUIDv4 can reach the
	// renderer. No database is touched: a nil transaction would panic if
	// one of these got past the check.
	bad := []streams.Stream{
		{Type: "not_a_stream", Key: idA},
		{Type: streams.TypeWorkerRecord, Key: "'; DROP TABLE stream_link; --"},
		{Type: streams.TypeWorkerRecord, Key: "1F2E3D4C-5B6A-4978-8765-4321FEDCBA98"},
		{Type: streams.TypeWorkerRecord, Key: idA[:len(idA)-1]},
	}
	for _, s := range bad {
		err := streams.Stage(nil, streams.Record{
			ID:      idA,
			Body:    []byte(`{"n":1}`),
			Streams: []streams.Stream{s},
		}, map[streams.Stream]streams.Head{s: streams.EmptyHead()})
		if err == nil {
			t.Fatalf("staged a record into %q/%q", s.Type, s.Key)
		}
	}
}

func TestStageRefusesARecordIdThatIsNotAUuid(t *testing.T) {
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: idA}
	err := streams.Stage(nil, streams.Record{
		ID:      "not-an-id",
		Body:    []byte(`{"n":1}`),
		Streams: []streams.Stream{s},
	}, map[streams.Stream]streams.Head{s: streams.EmptyHead()})
	if err == nil {
		t.Fatal("staged a record with a malformed id")
	}
}

func TestStageRefusesADuplicateStreamInOneRecord(t *testing.T) {
	// One record naming the same (Type, Key) twice is refused before any
	// statement is added, so a nil transaction never gets touched: the
	// duplicate is caught in the pre-pass. Staging both would write two
	// consecutive links for one record into one chain and inflate
	// link_position with a link the walk cannot tell from real history.
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: idA}
	err := streams.Stage(nil, streams.Record{
		ID:      idB,
		Body:    []byte(`{"n":1}`),
		Streams: []streams.Stream{s, s},
	}, map[streams.Stream]streams.Head{s: streams.EmptyHead()})
	if !errors.Is(err, streams.ErrDuplicateStream) {
		t.Fatalf("a record naming one stream twice returned %v, want ErrDuplicateStream", err)
	}
}

func TestStageRefusesAStreamWithNoHeadRead(t *testing.T) {
	// A head that was never read is a chain the caller does not know the
	// end of. Appending to it would write position 0 over an existing
	// chain, so it is refused rather than guessed.
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: idA}
	err := streams.Stage(nil, streams.Record{
		ID:      idB,
		Body:    []byte(`{"n":1}`),
		Streams: []streams.Stream{s},
	}, map[streams.Stream]streams.Head{})
	if err == nil {
		t.Fatal("staged a record into a stream whose head was never read")
	}
}

func TestTypesCoversTheDeclaredVocabulary(t *testing.T) {
	// The list Go ranges over and the constants it names are the same
	// set. The database's CHECK constraint is the enforcement; this
	// catches a constant added without being added to Types, which would
	// silently drop a stream type out of every sweep.
	declared := []streams.Type{
		streams.TypeSubjectAttestation,
		streams.TypePartyAttestation,
		streams.TypeWorkerRecord,
		streams.TypeRegistryEvent,
		streams.TypeKeyEvent,
		streams.TypeOperatorAction,
		streams.TypeDeletionJournalEntry,
	}
	if len(declared) != len(streams.Types) {
		t.Fatalf("Types has %d entries, the declared constants are %d",
			len(streams.Types), len(declared))
	}
	for i, want := range declared {
		if streams.Types[i] != want {
			t.Fatalf("Types[%d] is %q, want %q", i, streams.Types[i], want)
		}
	}
}
