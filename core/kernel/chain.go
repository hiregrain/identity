package kernel

// The hash chain, contract rule 5 (contract/CONTRACT.md), preserved from
// the T1 spike: SHA-256; genesis prev is 32 zero bytes; records are
// JCS-canonicalized before hashing; domain tag 0x02 on chain links;
// length-mismatch verification reports firstBadIndex = min(len);
// empty-chain head is 64 hex zeros.
//
// The link preimage is `0x02 || prev || canonical(record)`, in that
// order. Rule 5 names the ingredients and rule 7 requires the tag to
// lead (that is what makes a chain-link preimage unable to collide with
// a Merkle leaf or internal-node preimage, whose tags also lead), but
// the contract does not spell the order out in a sentence. The reading
// taken here is the one that satisfies both rules with no further
// choice: tag first for domain separation, prev next because a link
// commits the record to what came before, canonical record bytes last
// because rule 5 says the record is canonicalized before hashing rather
// than hashed and then chained. Recorded here because
// `trust-kernel/06`'s reference model is authored against the contract
// alone and will have to reach the same reading, and a divergence there
// is the differential test firing on an ambiguity rather than on a bug.
//
// Stream storage, head bookkeeping and merge resolution are not here:
// they are `core/streams`, kernel-adjacent under ordinary review
// (decision 019). What this file owns is the primitive that a subtle
// bug in would be unrecoverable.

import (
	"crypto/sha256"
	"encoding/hex"
	"strings"
)

// ChainLinkTag is contract rule 5's domain tag, the first byte of every
// chain-link preimage. Merkle's leaf and internal-node tags (0x00 and
// 0x01, contract rule 6) are the other two values in the same space,
// which is rule 7's cross-structure domain separation.
const ChainLinkTag = 0x02

// HashSize is SHA-256's digest length in bytes.
const HashSize = sha256.Size

// Hash is one chain hash: a link hash, or the prev it commits to.
type Hash [HashSize]byte

// GenesisPrev is the prev of a stream's first link: 32 zero bytes.
// A function rather than a package variable, so no caller can assign
// through it.
func GenesisPrev() Hash { return Hash{} }

// EmptyHead is the head of a stream with no links: 64 hex zeros. It is
// the hex spelling of GenesisPrev, which is the property that makes an
// empty stream and a stream about to receive its first link the same
// state to an appender.
func EmptyHead() string { return strings.Repeat("0", 2*HashSize) }

// Hex is the lowercase hex spelling of a hash, the form heads and prevs
// travel in outside the kernel.
func (h Hash) Hex() string { return hex.EncodeToString(h[:]) }

// ParseHash reads a hash back from its hex spelling. A string that is
// not exactly 64 lowercase hex characters is refused rather than
// padded or truncated: a short prev is a corrupted prev.
func ParseHash(value string) (Hash, error) {
	var h Hash
	raw, err := decodeKeyHex(value, HashSize, "hash")
	if err != nil {
		return h, err
	}
	copy(h[:], raw)
	return h, nil
}

// Link computes the link hash committing record to prev:
// SHA-256(0x02 || prev || canonical(record)). The record is
// JCS-canonicalized here rather than by the caller, so a caller cannot
// chain bytes that are not the canonical spelling of the record it
// believes it appended.
func Link(prev Hash, record []byte) (Hash, error) {
	canonical, err := Canonicalize(record)
	if err != nil {
		return Hash{}, err
	}
	digest := sha256.New()
	digest.Write([]byte{ChainLinkTag})
	digest.Write(prev[:])
	digest.Write(canonical)
	var out Hash
	copy(out[:], digest.Sum(nil))
	return out, nil
}

// Head folds records onto prev and returns the resulting head, the
// value a stream's head cache holds after appending all of them. Head
// over an empty slice returns prev unchanged, which is how an empty
// stream's head is EmptyHead.
func Head(prev Hash, records [][]byte) (Hash, error) {
	current := prev
	for _, record := range records {
		next, err := Link(current, record)
		if err != nil {
			return Hash{}, err
		}
		current = next
	}
	return current, nil
}

// ChainResult is a chain verification's verdict. FirstBadIndex is the
// position of the first link that does not recompute, and is -1 exactly
// when OK is true. Length is the number of positions compared, which is
// min(len(records), len(links)) when the two disagree.
type ChainResult struct {
	OK            bool
	FirstBadIndex int
	Length        int
}

// VerifyChain recomputes a chain from prev over records and reports the first
// position whose stored link does not match.
//
// A length mismatch is a divergence at min(len(records), len(links)),
// contract rule 5. That is the case where a record was removed from
// under a chain rather than altered in place: the walk agrees position
// by position and then runs out, and the position it runs out at is the
// answer an auditor needs.
func VerifyChain(prev Hash, records [][]byte, links []Hash) (ChainResult, error) {
	shorter := len(records)
	if len(links) < shorter {
		shorter = len(links)
	}
	current := prev
	for i := 0; i < shorter; i++ {
		next, err := Link(current, records[i])
		if err != nil {
			return ChainResult{}, err
		}
		if next != links[i] {
			return ChainResult{OK: false, FirstBadIndex: i, Length: shorter}, nil
		}
		current = next
	}
	if len(records) != len(links) {
		return ChainResult{OK: false, FirstBadIndex: shorter, Length: shorter}, nil
	}
	return ChainResult{OK: true, FirstBadIndex: -1, Length: shorter}, nil
}
