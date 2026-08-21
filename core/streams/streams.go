// Package streams is the per-stream hash chains over spine records
// (trust-kernel/03, decision 019, migration 0007-stream-heads). It is
// kernel-adjacent and under ordinary review: the primitive a subtle bug
// in would be unrecoverable is core/kernel/chain.go, and what lives here
// is where links are stored, how heads are kept, how a chain is walked
// for verification, and how a merge resolves several chains into one
// history without moving a row between them.
//
// Three claims this package exists to make true:
//
//	Every governing event chains, not only attestations (decision 019).
//	D4's dispositive argument depends on registry manipulation being
//	visible in the log, and an audited-but-unanchored operator action is
//	alterable by the operator, who is the party a dispute distrusts. The
//	stream types are the closed vocabulary below; worker record writes
//	are among them by decision 063, so self-asserted claims chain from
//	day one.
//
//	Chain membership is fixed at write time and never re-keyed (decision
//	019). Nothing here writes stream_key twice. Merge is Resolve, which
//	reads; it appends nothing and moves nothing, and unmerge is
//	therefore the removal of an alias rather than a chain split.
//
//	A chain append costs at most one extra round trip on a write path.
//	Heads reads every stream an appending transaction touches in one
//	query; Stage then adds its statements to the transaction the caller
//	was already committing, so the append itself costs none.
//
// Every statement crosses core/transport, the one seam any SQL path in
// this repo may use (trust-kernel/08, decision 065).
package streams

import (
	"errors"
	"fmt"
	"regexp"
	"sort"
	"strconv"
	"strings"

	"github.com/hiregrain/identity/core/kernel"
	"github.com/hiregrain/identity/core/transport"
)

// The plane and roles this package speaks to. Chains live on the spine:
// the spine is the ordering and integrity authority (decision 011), and
// a chain is an ordering claim.
const (
	Plane       = "spine"
	ServingRole = "identity_app"
	OwnerRole   = "identity"
)

// Type is one stream's kind. The vocabulary is closed here and again as
// a CHECK constraint in 0007-stream-heads; the constraint is the
// enforcement and this list is what Go code names it by.
type Type string

const (
	// TypeSubjectAttestation and TypePartyAttestation are the
	// per-subject and per-party attestation chains: one attestation is a
	// member of both, keyed by the subject's ledger person id in one and
	// by the attesting party's id in the other.
	TypeSubjectAttestation Type = "subject_attestation"
	TypePartyAttestation   Type = "party_attestation"

	// TypeWorkerRecord is a worker's own record writes (decision 063),
	// keyed by the worker's ledger person id.
	TypeWorkerRecord Type = "worker_record"

	// TypeRegistryEvent is registry and party lifecycle, keyed by the
	// party. D4's argument depends on these being walkable.
	TypeRegistryEvent Type = "registry_event"

	// TypeKeyEvent is the key event log, keyed by the key's holder.
	TypeKeyEvent Type = "key_event"

	// TypeOperatorAction is a privileged operator action, keyed by the
	// operator identity that took it.
	TypeOperatorAction Type = "operator_action"

	// TypeDeletionJournalEntry is a deletion journal entry, keyed by the
	// person whose record was destroyed.
	TypeDeletionJournalEntry Type = "deletion_journal_entry"
)

// Types is every stream type, in the order they are declared above. A
// caller sweeping every chain (a rebuild, a full audit) ranges over
// this rather than writing its own list.
var Types = []Type{
	TypeSubjectAttestation,
	TypePartyAttestation,
	TypeWorkerRecord,
	TypeRegistryEvent,
	TypeKeyEvent,
	TypeOperatorAction,
	TypeDeletionJournalEntry,
}

// Errors. Each names a rule a caller can fix and none carries record
// content.
var (
	ErrUnknownType = errors.New("streams: stream type is outside the closed vocabulary")
	ErrInvalidKey  = errors.New("streams: stream key is not a lowercase uuid")
	ErrNoHead      = errors.New("streams: no head was read for a stream being appended to")
)

// keyShape pins the id posture decision 075 set: a lowercase UUIDv4,
// version and variant nibbles included. Stream keys are person ids,
// party ids and operator ids, so this is not core/person's ValidID
// under another name; it is the same shape asserted for a wider set of
// subjects, and importing the person package to reach one regular
// expression would tie the kernel's chain storage to person-identity.
var keyShape = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`)

// Stream names one chain: its kind and the id it is keyed to. It is
// comparable, so it is the key of the head map an appending transaction
// carries.
type Stream struct {
	Type Type
	Key  string
}

func (s Stream) validate() error {
	known := false
	for _, t := range Types {
		if t == s.Type {
			known = true
			break
		}
	}
	if !known {
		return fmt.Errorf("%w: %q", ErrUnknownType, s.Type)
	}
	if !keyShape.MatchString(s.Key) {
		return fmt.Errorf("%w: %q", ErrInvalidKey, s.Key)
	}
	return nil
}

// String renders a stream for an error message and a test name.
func (s Stream) String() string { return string(s.Type) + "/" + s.Key }

// Head is a stream's current end: the last link's hash and its
// position. An empty stream has the genesis hash and Position -1, which
// is the state contract rule 5 spells as 64 hex zeros, so a first
// append and a later append are the same code path.
type Head struct {
	Hash     kernel.Hash
	Position int
}

// EmptyHead is the head of a stream with no links.
func EmptyHead() Head { return Head{Hash: kernel.GenesisPrev(), Position: -1} }

// Heads reads the current head of every named stream in ONE query, and
// returns EmptyHead for a stream that has none. One round trip whatever
// the number of streams is the point: it is what holds a chain append
// to one extra round trip on a write path however many chains a record
// belongs to.
func Heads(plane, role string, requested []Stream) (map[Stream]Head, error) {
	heads := map[Stream]Head{}
	if len(requested) == 0 {
		return heads, nil
	}
	args := make([]transport.Arg, 0, 2*len(requested))
	pairs := make([]string, 0, len(requested))
	for i, s := range requested {
		if err := s.validate(); err != nil {
			return nil, err
		}
		heads[s] = EmptyHead()
		pairs = append(pairs, fmt.Sprintf("($%d, $%d)", 2*i+1, 2*i+2))
		args = append(args, transport.String(string(s.Type)), transport.String(s.Key))
	}
	sql := "SELECT stream_type, stream_key, link_position, encode(head_hash, 'hex') " +
		"FROM stream_heads WHERE (stream_type, stream_key) IN (" +
		strings.Join(pairs, ", ") + ")"
	lines, err := transport.Query(plane, role, sql, args...)
	if err != nil {
		return nil, err
	}
	for _, line := range lines {
		fields := transport.SplitRow(line, 4)
		if len(fields) != 4 {
			return nil, fmt.Errorf("streams: head row has %d columns, want 4", len(fields))
		}
		position, err := strconv.Atoi(fields[2])
		if err != nil {
			return nil, fmt.Errorf("streams: head position %q is not a number", fields[2])
		}
		hash, err := kernel.ParseHash(fields[3])
		if err != nil {
			return nil, err
		}
		heads[Stream{Type: Type(fields[0]), Key: fields[1]}] = Head{Hash: hash, Position: position}
	}
	return heads, nil
}

// Record is one governing event about to be chained: the id of the row
// that holds it in its own table, its JSON body, and every stream it
// belongs to. The body is canonicalized by the kernel at link time, so
// a caller cannot chain bytes that are not the canonical spelling of
// what it wrote.
type Record struct {
	ID      string
	Body    []byte
	Streams []Stream
}

// Stage adds one record's chain writes to an open transaction: a link
// row per stream it belongs to, and the head move for each. It issues
// no statement of its own, which is why a chain append inside an
// existing spine write costs no additional round trip. The heads map is
// what Heads returned, and it is advanced in place, so several records
// may be staged into one transaction before it commits.
//
// The head this reads is a cache. Correctness does not rest on it: a
// head that has drifted produces a link that fails verification, and
// the (stream_type, stream_key, link_position) primary key is what
// makes two transactions racing one stream a conflict rather than a
// double-recording.
func Stage(tx *transport.Transaction, record Record, heads map[Stream]Head) error {
	if !keyShape.MatchString(record.ID) {
		return fmt.Errorf("%w: record id %q", ErrInvalidKey, record.ID)
	}
	for _, s := range record.Streams {
		if err := s.validate(); err != nil {
			return err
		}
		head, ok := heads[s]
		if !ok {
			return fmt.Errorf("%w: %s", ErrNoHead, s)
		}
		link, err := kernel.Link(head.Hash, record.Body)
		if err != nil {
			return err
		}
		position := head.Position + 1
		if err := tx.Exec(
			"INSERT INTO stream_link "+
				"(stream_type, stream_key, link_position, record_id, prev_hash, link_hash) "+
				"VALUES ($1, $2, $3, $4, $5, $6);",
			transport.String(string(s.Type)), transport.String(s.Key),
			transport.Float(float64(position)), transport.String(record.ID),
			transport.Bytea(head.Hash[:]), transport.Bytea(link[:]),
		); err != nil {
			return err
		}
		if err := tx.Exec(
			"INSERT INTO stream_heads "+
				"(stream_type, stream_key, link_position, head_hash) "+
				"VALUES ($1, $2, $3, $4) "+
				"ON CONFLICT (stream_type, stream_key) DO UPDATE "+
				"SET link_position = EXCLUDED.link_position, "+
				"head_hash = EXCLUDED.head_hash, updated_at = now();",
			transport.String(string(s.Type)), transport.String(s.Key),
			transport.Float(float64(position)), transport.Bytea(link[:]),
		); err != nil {
			return err
		}
		heads[s] = Head{Hash: link, Position: position}
	}
	return nil
}

// Append is the standalone form: one record, its own transaction. The
// real write paths (an attestation, a registry event, a deletion
// journal row) call Heads and Stage instead, so the chain write commits
// with the spine write it records and with the outbox row beside it
// (foundation/07). This exists for the paths that chain a record and
// write nothing else, and for tests.
func Append(plane, role string, record Record) error {
	heads, err := Heads(plane, role, record.Streams)
	if err != nil {
		return err
	}
	return transport.Tx(plane, role, func(tx *transport.Transaction) error {
		return Stage(tx, record, heads)
	})
}

// Entry is one stored link, as read back.
type Entry struct {
	Stream   Stream
	Position int
	RecordID string
	Prev     kernel.Hash
	Link     kernel.Hash
}

// Source hands back record bodies by id. Verification recomputes the
// chain from the records themselves, so a mutation made by the table
// owner in the table that holds the record is what verification
// detects; a source that read the chain's own copy of the bytes would
// verify nothing.
//
// The whole stream's ids are asked for at once rather than one at a
// time. A chain walk is already a read of every position, and asking
// per position turns a verification of a long chain into a round trip
// per link.
//
// A record whose row is gone is simply absent from the map. That
// shortens the record sequence under a chain that still has its links,
// which contract rule 5 resolves as a divergence at min(len): the
// position the walk ran out at.
type Source interface {
	Records(ids []string) (map[string][]byte, error)
}

// Result is a stream verification's verdict. Position is the first
// divergence, and -1 exactly when OK is true.
type Result struct {
	Stream   Stream
	OK       bool
	Position int
	Length   int
	Detail   string
}

// Entries reads one stream's links in position order.
func Entries(plane, role string, s Stream) ([]Entry, error) {
	if err := s.validate(); err != nil {
		return nil, err
	}
	lines, err := transport.Query(plane, role,
		"SELECT link_position, record_id, encode(prev_hash, 'hex'), "+
			"encode(link_hash, 'hex') FROM stream_link "+
			"WHERE stream_type = $1 AND stream_key = $2 ORDER BY link_position",
		transport.String(string(s.Type)), transport.String(s.Key))
	if err != nil {
		return nil, err
	}
	entries := make([]Entry, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 4)
		if len(fields) != 4 {
			return nil, fmt.Errorf("streams: link row has %d columns, want 4", len(fields))
		}
		position, err := strconv.Atoi(fields[0])
		if err != nil {
			return nil, fmt.Errorf("streams: link position %q is not a number", fields[0])
		}
		prev, err := kernel.ParseHash(fields[2])
		if err != nil {
			return nil, err
		}
		link, err := kernel.ParseHash(fields[3])
		if err != nil {
			return nil, err
		}
		entries = append(entries, Entry{
			Stream:   s,
			Position: position,
			RecordID: fields[1],
			Prev:     prev,
			Link:     link,
		})
	}
	return entries, nil
}

// Verify walks a stream from genesis and reports the position of the
// first divergence. Three kinds of tampering land in the same answer, a
// position:
//
//   - a record altered where it lives: its canonical bytes no longer
//     produce the stored link;
//   - a record removed from under the chain: the walk runs out, and
//     contract rule 5 puts the divergence at min(len);
//   - a link row altered or removed: the stored prev no longer matches
//     the previous link, or the positions are no longer contiguous.
//
// The earliest position of any of them is what is reported, because an
// auditor asks where the chain stopped being true, not how many ways it
// stopped.
func Verify(plane, role string, s Stream, source Source) (Result, error) {
	entries, err := Entries(plane, role, s)
	if err != nil {
		return Result{}, err
	}

	// Positions are contiguous from 0 in an append-only chain. A gap is
	// a deleted link row, and the gap's own index is where the chain
	// stopped being walkable.
	for i, e := range entries {
		if e.Position != i {
			return Result{
				Stream: s, OK: false, Position: i, Length: len(entries),
				Detail: fmt.Sprintf("link position %d found where %d was expected", e.Position, i),
			}, nil
		}
	}

	links := make([]kernel.Hash, len(entries))
	for i, e := range entries {
		links[i] = e.Link
	}
	ids := make([]string, len(entries))
	for i, e := range entries {
		ids[i] = e.RecordID
	}
	bodies, err := source.Records(ids)
	if err != nil {
		return Result{}, err
	}
	records := make([][]byte, 0, len(entries))
	for _, id := range ids {
		body, found := bodies[id]
		if !found {
			break
		}
		records = append(records, body)
	}

	chain, err := kernel.VerifyChain(kernel.GenesisPrev(), records, links)
	if err != nil {
		return Result{}, err
	}

	// A stored prev that disagrees with the previous link is tampering
	// the recomputation above cannot see: it recomputes from its own
	// running prev, not from the stored one. Reported at its own
	// position, and the earlier of the two answers wins.
	prevBad := -1
	for i, e := range entries {
		want := kernel.GenesisPrev()
		if i > 0 {
			want = entries[i-1].Link
		}
		if e.Prev != want {
			prevBad = i
			break
		}
	}

	if !chain.OK && (prevBad == -1 || chain.FirstBadIndex <= prevBad) {
		detail := fmt.Sprintf("record at position %d does not produce its stored link", chain.FirstBadIndex)
		if len(records) != len(links) {
			detail = fmt.Sprintf("chain has %d links and %d records; walk ran out at position %d",
				len(links), len(records), chain.FirstBadIndex)
		}
		return Result{
			Stream: s, OK: false, Position: chain.FirstBadIndex,
			Length: len(entries), Detail: detail,
		}, nil
	}
	if prevBad != -1 {
		return Result{
			Stream: s, OK: false, Position: prevBad, Length: len(entries),
			Detail: fmt.Sprintf("stored prev at position %d is not the previous link", prevBad),
		}, nil
	}
	return Result{Stream: s, OK: true, Position: -1, Length: len(entries)}, nil
}

// Rebuild drops every head and recomputes the projection from the links
// themselves. It is the proof that stream_heads is a cache and not a
// second source of truth, and it runs as the table owner because
// clearing it needs DELETE, which no serving role holds
// (0007-stream-heads, decision 019).
//
// The recomputation is one statement over stream_link, so a rebuild
// cannot drift from the links by reimplementing the fold in Go.
func Rebuild(plane, role string) error {
	return transport.Tx(plane, role, func(tx *transport.Transaction) error {
		if err := tx.Exec("DELETE FROM stream_heads;"); err != nil {
			return err
		}
		return tx.Exec(
			"INSERT INTO stream_heads (stream_type, stream_key, link_position, head_hash) " +
				"SELECT DISTINCT ON (stream_type, stream_key) " +
				"stream_type, stream_key, link_position, link_hash " +
				"FROM stream_link " +
				"ORDER BY stream_type, stream_key, link_position DESC;")
	})
}

// HeadRow is one row of the head projection, without the bookkeeping
// timestamp. A rebuild writes a new updated_at by design, so the
// comparison that proves the projection is derived is over these
// columns: the chain facts, not the note of when they were last
// written.
type HeadRow struct {
	Stream   Stream
	Position int
	Hash     kernel.Hash
}

// AllHeads reads the whole head projection in a deterministic order,
// for the rebuild comparison and for an audit sweep.
func AllHeads(plane, role string) ([]HeadRow, error) {
	lines, err := transport.Query(plane, role,
		"SELECT stream_type, stream_key, link_position, encode(head_hash, 'hex') "+
			"FROM stream_heads ORDER BY stream_type, stream_key")
	if err != nil {
		return nil, err
	}
	rows := make([]HeadRow, 0, len(lines))
	for _, line := range lines {
		fields := transport.SplitRow(line, 4)
		if len(fields) != 4 {
			return nil, fmt.Errorf("streams: head row has %d columns, want 4", len(fields))
		}
		position, err := strconv.Atoi(fields[2])
		if err != nil {
			return nil, fmt.Errorf("streams: head position %q is not a number", fields[2])
		}
		hash, err := kernel.ParseHash(fields[3])
		if err != nil {
			return nil, err
		}
		rows = append(rows, HeadRow{
			Stream:   Stream{Type: Type(fields[0]), Key: fields[1]},
			Position: position,
			Hash:     hash,
		})
	}
	return rows, nil
}

// Membership is every link's chain membership, in a deterministic
// order, rendered as text. Two membership readings taken either side of
// a merge must be identical strings: that is decision 019's "a merge
// moves no record between chains", stated as something a diff can
// answer.
func Membership(plane, role string) (string, error) {
	lines, err := transport.Query(plane, role,
		"SELECT stream_type, stream_key, link_position, record_id, "+
			"encode(prev_hash, 'hex'), encode(link_hash, 'hex') "+
			"FROM stream_link ORDER BY stream_type, stream_key, link_position")
	if err != nil {
		return "", err
	}
	return strings.Join(lines, "\n"), nil
}

// Alias is one absorbed-to-survivor resolution. It is produced ABOVE
// the chains, by person-identity/06's merge events, and never stored
// here: this package's whole posture is that a merge is something read
// at resolution time, not a rewrite of what was written.
type Alias struct {
	Absorbed string
	Survivor string
}

// Resolve returns every chain key that makes up one id's history under
// an alias set: the id itself plus every id absorbed into it,
// transitively, sorted so the answer is stable. It writes nothing, and
// there is no counterpart that moves a link, which is what makes an
// unmerge the removal of an alias rather than a chain split.
//
// A merge of A into B and then B into C resolves C to all three: the
// closure follows the absorbed edges transitively. A cycle, which a
// well-formed merge history cannot produce, terminates because each key
// is visited once.
func Resolve(id string, aliases []Alias) []string {
	closure := map[string]bool{id: true}
	frontier := []string{id}
	for len(frontier) > 0 {
		current := frontier[len(frontier)-1]
		frontier = frontier[:len(frontier)-1]
		for _, a := range aliases {
			if a.Survivor != current || closure[a.Absorbed] {
				continue
			}
			closure[a.Absorbed] = true
			frontier = append(frontier, a.Absorbed)
		}
	}
	keys := make([]string, 0, len(closure))
	for key := range closure {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	return keys
}

// History is the multi-chain walk decision 019 accepted as the cost of
// never re-keying: one id's record of a given kind, assembled across
// every chain in its alias closure. Within a chain the position order
// is authoritative and is preserved. Across chains the order here is by
// stream key, deliberately: two chains written independently share no
// order that this package can assert, and interleaving them by wall
// clock would present a merged order as though the ledger had recorded
// one. A surface that wants a single timeline reads each link's record
// and orders by whatever that record's own timestamps mean.
func History(plane, role string, t Type, id string, aliases []Alias) ([]Entry, error) {
	keys := Resolve(id, aliases)
	entries := make([]Entry, 0, len(keys))
	for _, key := range keys {
		s := Stream{Type: t, Key: key}
		part, err := Entries(plane, role, s)
		if err != nil {
			return nil, err
		}
		entries = append(entries, part...)
	}
	sort.SliceStable(entries, func(i, j int) bool {
		if entries[i].Stream.Key != entries[j].Stream.Key {
			return entries[i].Stream.Key < entries[j].Stream.Key
		}
		return entries[i].Position < entries[j].Position
	})
	return entries, nil
}
