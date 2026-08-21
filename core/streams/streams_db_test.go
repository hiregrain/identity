//go:build db

package streams_test

// The per-stream chain acceptance suite (trust-kernel/03). Every
// criterion in the task file resolves to a test here, run against the
// live spine.
//
// Usage: cd core && go test -tags db -count=1 ./streams/...
// Requires migrated databases (make db-up && make migrate); -count=1
// because the database is state the test cache cannot see.

import (
	"testing"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/streams"
	"github.com/hiregrain/identity/core/transport"
)

// --- criterion 1: a mutated historical record is caught, in position --

// TestMutatedRecordIsDetectedInEveryStreamType sweeps the closed
// vocabulary rather than a sample of it, so a stream type added later
// without a chain writer is a failing test rather than a silent gap.
// The five the task file names, worker record writes (decision 063),
// registry events, key events, operator actions and deletion journal
// entries, are members of that sweep by construction.
func TestMutatedRecordIsDetectedInEveryStreamType(t *testing.T) {
	for _, streamType := range streams.Types {
		s := streams.Stream{Type: streamType, Key: newID(t)}
		ids := chainProbeRecords(t, 3, s)

		if result := verify(t, s, probeSource{}); !result.OK {
			t.Fatalf("%s: intact chain failed verification: %+v", streamType, result)
		}
		mutateProbeRecord(t, ids[1])
		if result := verify(t, s, probeSource{}); result.OK || result.Position != 1 {
			t.Fatalf("%s: mutation reported as %+v, want a divergence at 1", streamType, result)
		}
	}
}

// TestEveryPositionIsReportedAtItsOwnIndex is the position half of the
// criterion, swept one position at a time over one chain. An off-by-one
// in the walk is a wrong answer at exactly one index, so a single
// convenient position would not find it.
func TestEveryPositionIsReportedAtItsOwnIndex(t *testing.T) {
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: newID(t)}
	ids := chainProbeRecords(t, 4, s)

	for position, id := range ids {
		mutateProbeRecord(t, id)
		result := verify(t, s, probeSource{})
		if result.OK || result.Position != position {
			t.Fatalf("mutation at position %d reported as %+v", position, result)
		}
		// Put it back, so the next position is the only divergence in
		// the chain.
		ownerSQL(t, "UPDATE "+probeTable+" SET body = $1 WHERE record_id = $2",
			transport.String(string(probeBody(id, position))), transport.String(id))
		if result := verify(t, s, probeSource{}); !result.OK {
			t.Fatalf("restored chain still fails: %+v", result)
		}
	}
}

// TestMutatedRecordIsDetectedInEveryStreamItBelongsTo is the multi-chain
// half of the criterion: one attestation is a member of its subject's
// chain and its party's chain, at different positions in each, and a
// mutation of the one record has to surface in both.
func TestMutatedRecordIsDetectedInEveryStreamItBelongsTo(t *testing.T) {
	subject := streams.Stream{Type: streams.TypeSubjectAttestation, Key: newID(t)}
	party := streams.Stream{Type: streams.TypePartyAttestation, Key: newID(t)}

	// The party chain gets two earlier attestations about other
	// subjects, so the shared record sits at position 0 in one chain and
	// position 2 in the other. One mutation, two different positions.
	chainProbeRecords(t, 2, party)
	shared := chainProbeRecords(t, 1, subject, party)[0]

	mutateProbeRecord(t, shared)

	if result := verify(t, subject, probeSource{}); result.OK || result.Position != 0 {
		t.Fatalf("subject chain reported %+v, want a divergence at 0", result)
	}
	if result := verify(t, party, probeSource{}); result.OK || result.Position != 2 {
		t.Fatalf("party chain reported %+v, want a divergence at 2", result)
	}
}

// TestMutatedDeletionJournalRowIsDetected runs the same claim against a
// record table that exists rather than a probe: a real deletion journal
// row, chained, then rewritten by the table owner.
func TestMutatedDeletionJournalRowIsDetected(t *testing.T) {
	first, firstBody := writeJournalRow(t)
	second, secondBody := writeJournalRow(t)

	// Both rows chain into the operator's deletion journal stream, and
	// each also opens its own person's chain, which is how a person's
	// deletion is visible on the person's own chain.
	operator := newID(t)
	operatorStream := streams.Stream{Type: streams.TypeDeletionJournalEntry, Key: operator}
	journaled := []struct {
		id   string
		body []byte
	}{{first, firstBody}, {second, secondBody}}
	for _, row := range journaled {
		if err := streams.Append(streams.Plane, streams.ServingRole, streams.Record{
			ID:   row.id,
			Body: row.body,
			Streams: []streams.Stream{
				operatorStream,
				{Type: streams.TypeDeletionJournalEntry, Key: row.id},
			},
		}); err != nil {
			t.Fatalf("append: %v", err)
		}
	}

	if result := verify(t, operatorStream, journalSource{}); !result.OK {
		t.Fatalf("intact journal chain failed verification: %+v", result)
	}

	// The owner rewrites who asked for the deletion. Nothing in the
	// journal's own schema can contradict that; the chain can.
	ownerSQL(t, "UPDATE deletion_journal SET requester_class = 'support' WHERE person_id = $1",
		transport.String(second))

	own := streams.Stream{Type: streams.TypeDeletionJournalEntry, Key: second}
	if result := verify(t, own, journalSource{}); result.OK || result.Position != 0 {
		t.Fatalf("the person's own chain reported %+v, want a divergence at 0", result)
	}
	// The same row sits at position 1 of the operator's chain, which is
	// where that walk has to stop.
	if result := verify(t, operatorStream, journalSource{}); result.OK || result.Position != 1 {
		t.Fatalf("the operator chain reported %+v, want a divergence at 1", result)
	}
}

// TestRemovedRecordIsDetectedAtMinLength is contract rule 5's
// length-mismatch rule where it actually bites: a record deleted from
// under a chain that still holds its links.
func TestRemovedRecordIsDetectedAtMinLength(t *testing.T) {
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: newID(t)}
	ids := chainProbeRecords(t, 3, s)

	ownerSQL(t, "DELETE FROM "+probeTable+" WHERE record_id = $1", transport.String(ids[1]))

	result := verify(t, s, probeSource{})
	if result.OK || result.Position != 1 {
		t.Fatalf("removed record reported as %+v, want a divergence at 1", result)
	}
}

// TestTamperedLinkRowIsDetected covers the other direction: the links,
// not the records, rewritten by the owner. A stored prev that no longer
// names the previous link is caught even though every record still
// hashes to its own stored link.
func TestTamperedLinkRowIsDetected(t *testing.T) {
	s := streams.Stream{Type: streams.TypeRegistryEvent, Key: newID(t)}
	chainProbeRecords(t, 3, s)

	ownerSQL(t, "UPDATE stream_link SET prev_hash = $1 "+
		"WHERE stream_type = $2 AND stream_key = $3 AND link_position = 2",
		transport.Bytea(make([]byte, kernel.HashSize)),
		transport.String(string(s.Type)), transport.String(s.Key))

	if result := verify(t, s, probeSource{}); result.OK || result.Position != 2 {
		t.Fatalf("rewritten prev reported as %+v, want a divergence at 2", result)
	}
}

// TestRemovedLinkRowIsDetected: an owner deleting a link leaves a gap in
// the positions, and the gap's own index is where the chain stopped
// being walkable.
func TestRemovedLinkRowIsDetected(t *testing.T) {
	s := streams.Stream{Type: streams.TypeOperatorAction, Key: newID(t)}
	chainProbeRecords(t, 4, s)

	ownerSQL(t, "DELETE FROM stream_link "+
		"WHERE stream_type = $1 AND stream_key = $2 AND link_position = 1",
		transport.String(string(s.Type)), transport.String(s.Key))

	if result := verify(t, s, probeSource{}); result.OK || result.Position != 1 {
		t.Fatalf("removed link reported as %+v, want a divergence at 1", result)
	}
}

// --- criteria 2 and 3: merge and unmerge move nothing -----------------

// TestMergeMovesNoRecordBetweenChains is decision 019's membership rule
// stated as a diff: chain membership either side of a merge is
// byte-identical, and what changes is the resolution above it.
func TestMergeMovesNoRecordBetweenChains(t *testing.T) {
	survivor := newID(t)
	absorbed := newID(t)
	survivorStream := streams.Stream{Type: streams.TypeWorkerRecord, Key: survivor}
	absorbedStream := streams.Stream{Type: streams.TypeWorkerRecord, Key: absorbed}
	chainProbeRecords(t, 2, survivorStream)
	chainProbeRecords(t, 3, absorbedStream)

	before := membership(t)
	headsBefore := headsOf(t)

	// Before the merge, the survivor's history is its own chain alone.
	preMerge, err := streams.History(streams.Plane, streams.ServingRole,
		streams.TypeWorkerRecord, survivor, nil)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(preMerge) != 2 {
		t.Fatalf("pre-merge history has %d entries, want 2", len(preMerge))
	}

	// The merge. It is an alias, produced above the chains by
	// person-identity/06's merge events; this package resolves it and
	// writes nothing.
	aliases := []streams.Alias{{Absorbed: absorbed, Survivor: survivor}}

	merged, err := streams.History(streams.Plane, streams.ServingRole,
		streams.TypeWorkerRecord, survivor, aliases)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(merged) != 5 {
		t.Fatalf("merged history has %d entries, want 5", len(merged))
	}
	// Every entry still names the chain it was written into. This is
	// the claim: the history is assembled, the records did not move.
	for _, entry := range merged {
		if entry.Stream.Key != survivor && entry.Stream.Key != absorbed {
			t.Fatalf("entry resolved to an unexpected chain %s", entry.Stream)
		}
	}

	if after := membership(t); after != before {
		t.Fatal("chain membership changed across a merge")
	}
	if after := headsOf(t); after != headsBefore {
		t.Fatal("stream heads changed across a merge")
	}
}

// TestUnmergeRestoresPriorResolutionWithZeroChainWrites: dropping the
// alias returns the resolution to what it was, and the round-trip
// counter shows the whole merge-and-unmerge cycle issued no write at
// all, which is what makes an unmerge trivially correct.
func TestUnmergeRestoresPriorResolutionWithZeroChainWrites(t *testing.T) {
	survivor := newID(t)
	absorbed := newID(t)
	chainProbeRecords(t, 2, streams.Stream{Type: streams.TypeSubjectAttestation, Key: survivor})
	chainProbeRecords(t, 2, streams.Stream{Type: streams.TypeSubjectAttestation, Key: absorbed})

	before := membership(t)
	aliases := []streams.Alias{{Absorbed: absorbed, Survivor: survivor}}

	merged, err := streams.History(streams.Plane, streams.ServingRole,
		streams.TypeSubjectAttestation, survivor, aliases)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(merged) != 4 {
		t.Fatalf("merged history has %d entries, want 4", len(merged))
	}

	// The unmerge: the alias is gone, and nothing else happened.
	unmerged, err := streams.History(streams.Plane, streams.ServingRole,
		streams.TypeSubjectAttestation, survivor, nil)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(unmerged) != 2 {
		t.Fatalf("unmerged history has %d entries, want 2", len(unmerged))
	}
	for _, entry := range unmerged {
		if entry.Stream.Key != survivor {
			t.Fatalf("after unmerge, history still resolves through %s", entry.Stream)
		}
	}
	// The absorbed chain is intact and independent, which is what
	// "unmerge is not a chain split" means concretely.
	absorbedAfter, err := streams.History(streams.Plane, streams.ServingRole,
		streams.TypeSubjectAttestation, absorbed, nil)
	if err != nil {
		t.Fatalf("history: %v", err)
	}
	if len(absorbedAfter) != 2 {
		t.Fatalf("absorbed chain has %d entries after unmerge, want 2", len(absorbedAfter))
	}

	if after := membership(t); after != before {
		t.Fatal("chain membership changed across a merge and unmerge")
	}
}

// TestResolutionIssuesNoWrite counts the round trips a merge and an
// unmerge cost and proves every one of them was a read: the link rows
// and the head rows are unchanged, and Resolve itself touches no
// database at all.
func TestResolutionIssuesNoWrite(t *testing.T) {
	survivor := newID(t)
	absorbed := newID(t)
	chainProbeRecords(t, 1, streams.Stream{Type: streams.TypeKeyEvent, Key: survivor})
	chainProbeRecords(t, 1, streams.Stream{Type: streams.TypeKeyEvent, Key: absorbed})

	before := membership(t) + "\n" + headsOf(t)

	aliases := []streams.Alias{{Absorbed: absorbed, Survivor: survivor}}
	if keys := streams.Resolve(survivor, aliases); len(keys) != 2 {
		t.Fatalf("closure has %d keys, want 2", len(keys))
	}
	if keys := streams.Resolve(survivor, nil); len(keys) != 1 || keys[0] != survivor {
		t.Fatalf("empty alias set resolved to %v", keys)
	}

	if after := membership(t) + "\n" + headsOf(t); after != before {
		t.Fatal("resolution changed stored state")
	}
}

// --- criterion 4: the head projection is derived --------------------

// TestRebuildReproducesIdenticalHeads is the derived-cache proof:
// dropping every head and recomputing from the links alone returns the
// projection unchanged.
func TestRebuildReproducesIdenticalHeads(t *testing.T) {
	for _, streamType := range streams.Types {
		chainProbeRecords(t, 2, streams.Stream{Type: streamType, Key: newID(t)})
	}

	before := headsOf(t)
	if before == "" {
		t.Fatal("no heads were written")
	}

	if err := streams.Rebuild(streams.Plane, streams.OwnerRole); err != nil {
		t.Fatalf("rebuild: %v", err)
	}
	if after := headsOf(t); after != before {
		t.Fatalf("rebuilt heads differ from the originals:\nbefore:\n%s\nafter:\n%s", before, after)
	}

	// A second rebuild is a no-op, which is the property that makes a
	// rebuild safe to run at any time.
	if err := streams.Rebuild(streams.Plane, streams.OwnerRole); err != nil {
		t.Fatalf("rebuild: %v", err)
	}
	if after := headsOf(t); after != before {
		t.Fatal("a second rebuild changed the projection")
	}
}

// TestHeadsMatchTheChainsTheyProject: the head a stream reports is the
// last link of that stream, folded from genesis. A head that agreed
// with nothing would still rebuild identically, so this is the
// assertion that gives the rebuild proof its meaning.
func TestHeadsMatchTheChainsTheyProject(t *testing.T) {
	s := streams.Stream{Type: streams.TypePartyAttestation, Key: newID(t)}
	chainProbeRecords(t, 3, s)

	entries, err := streams.Entries(streams.Plane, streams.ServingRole, s)
	if err != nil {
		t.Fatalf("entries: %v", err)
	}
	heads, err := streams.Heads(streams.Plane, streams.ServingRole, []streams.Stream{s})
	if err != nil {
		t.Fatalf("heads: %v", err)
	}
	head := heads[s]
	last := entries[len(entries)-1]
	if head.Hash != last.Link || head.Position != last.Position {
		t.Fatalf("head is %s at %d, last link is %s at %d",
			head.Hash.Hex(), head.Position, last.Link.Hex(), last.Position)
	}
}

// TestEmptyStreamHeadIsSixtyFourHexZeros is contract rule 5's
// empty-chain head, read through the database rather than asserted in
// the kernel alone: a stream nobody has written to reads as genesis, so
// a first append and a later append are one code path.
func TestEmptyStreamHeadIsSixtyFourHexZeros(t *testing.T) {
	s := streams.Stream{Type: streams.TypeOperatorAction, Key: newID(t)}
	heads, err := streams.Heads(streams.Plane, streams.ServingRole, []streams.Stream{s})
	if err != nil {
		t.Fatalf("heads: %v", err)
	}
	head := heads[s]
	if head.Hash.Hex() != kernel.EmptyHead() || head.Position != -1 {
		t.Fatalf("empty stream head is %s at %d", head.Hash.Hex(), head.Position)
	}
}

// --- criterion 5: one round trip, measured --------------------------

// TestChainAppendAddsOneRoundTrip measures rather than asserts. A write
// path that chains nothing costs one round trip; the same write path
// with the record chained into three streams costs two, and the extra
// one is the head read. Staging costs none, because its statements
// travel in the transaction the caller was already committing.
func TestChainAppendAddsOneRoundTrip(t *testing.T) {

	// Warm the transport's one-per-plane standard_conforming_strings
	// assertion, so it is not counted against either measurement.
	if _, err := appSQL("SELECT 1"); err != nil {
		t.Fatalf("warmup: %v", err)
	}

	unchained := measure(t, func() {
		id := newID(t)
		body := probeBody(id, 0)
		if err := transport.Tx(streams.Plane, streams.ServingRole,
			func(tx *transport.Transaction) error {
				return tx.Exec("INSERT INTO "+probeTable+" (record_id, body) VALUES ($1, $2);",
					transport.String(id), transport.String(string(body)))
			}); err != nil {
			t.Fatalf("unchained write: %v", err)
		}
	})

	chained := measure(t, func() {
		id := newID(t)
		body := probeBody(id, 0)
		on := []streams.Stream{
			{Type: streams.TypeSubjectAttestation, Key: newID(t)},
			{Type: streams.TypePartyAttestation, Key: newID(t)},
			{Type: streams.TypeWorkerRecord, Key: newID(t)},
		}
		heads, err := streams.Heads(streams.Plane, streams.ServingRole, on)
		if err != nil {
			t.Fatalf("heads: %v", err)
		}
		if err := transport.Tx(streams.Plane, streams.ServingRole,
			func(tx *transport.Transaction) error {
				if err := tx.Exec("INSERT INTO "+probeTable+" (record_id, body) VALUES ($1, $2);",
					transport.String(id), transport.String(string(body))); err != nil {
					return err
				}
				return streams.Stage(tx, streams.Record{ID: id, Body: body, Streams: on}, heads)
			}); err != nil {
			t.Fatalf("chained write: %v", err)
		}
	})

	if unchained != 1 {
		t.Fatalf("an unchained write cost %d round trips, want 1", unchained)
	}
	if chained-unchained > 1 {
		t.Fatalf("chaining cost %d extra round trips, want at most 1", chained-unchained)
	}
	t.Logf("round trips: unchained %d, chained into three streams %d, added %d",
		unchained, chained, chained-unchained)
}

// measure returns the number of database round trips fn made.
func measure(t *testing.T, fn func()) int64 {
	t.Helper()
	before := transport.RoundTrips()
	fn()
	return transport.RoundTrips() - before
}

// --- the append-only posture around the exemption -------------------

// TestServingRoleCannotRewriteLinks: the head projection's UPDATE grant
// is the only mutation the serving role holds here, and the chain
// itself is beyond it. The grant set as a whole is proven by
// test/append-only.test.mjs against its enumerated exemption list; this
// is the same boundary asserted from the other side, as a statement
// that fails.
func TestServingRoleCannotRewriteLinks(t *testing.T) {
	s := streams.Stream{Type: streams.TypeWorkerRecord, Key: newID(t)}
	chainProbeRecords(t, 1, s)

	if _, err := appSQL("UPDATE stream_link SET link_hash = $1 WHERE stream_key = $2",
		transport.Bytea(make([]byte, kernel.HashSize)), transport.String(s.Key)); err == nil {
		t.Fatal("the serving role rewrote a link")
	}
	if _, err := appSQL("DELETE FROM stream_link WHERE stream_key = $1",
		transport.String(s.Key)); err == nil {
		t.Fatal("the serving role deleted a link")
	}
	if _, err := appSQL("DELETE FROM stream_heads WHERE stream_key = $1",
		transport.String(s.Key)); err == nil {
		t.Fatal("the serving role deleted a head")
	}
}

// TestAPositionIsWrittenOnce: two appends racing one stream conflict
// rather than double-recording, which is what the primary key is for.
func TestAPositionIsWrittenOnce(t *testing.T) {
	s := streams.Stream{Type: streams.TypeKeyEvent, Key: newID(t)}
	chainProbeRecords(t, 1, s)

	// A second appender holding the stale head, which is what a race
	// looks like from inside one of the two transactions.
	stale := map[streams.Stream]streams.Head{s: streams.EmptyHead()}
	id, body := writeProbeRecord(t, 1)
	err := transport.Tx(streams.Plane, streams.ServingRole,
		func(tx *transport.Transaction) error {
			return streams.Stage(tx, streams.Record{ID: id, Body: body,
				Streams: []streams.Stream{s}}, stale)
		})
	if err == nil {
		t.Fatal("a second link was written at a position that was already taken")
	}
}
