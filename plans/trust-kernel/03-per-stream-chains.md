---
id: trust-kernel/03
type: task
layer: trust-kernel
satisfies: [2, 6]
status: in_progress
depends_on: [trust-kernel/01, foundation/04, trust-kernel/08]
migrations: [0007-stream-heads]
binds: [contract/CONTRACT.md, decisions/LOG.md#019]
evidence:
  [
    "test:cd core && go test ./kernel/... -- the chain primitive against contract rule 5 (genesis prev / empty head / link preimage / min-length rule)",
    "test:cd core && go test -tags db -count=1 ./streams/... -- the acceptance suite against the live spine; every test passes",
    "test:cd core && go test -tags db -count=1 -run TestChainAppendAddsOneRoundTrip ./streams/... -- unchained write 1 round trip; chained into three streams 2; added 1",
    "test:node test/append-only.test.mjs -- the stream_heads exemption is enumerated and the grant set still equals the list",
    "test:make check -- green end to end on the head commit",
    "diff:PR #20 @ b278006",
  ]
verified_by: null
---

# Per-stream hash chains

## Objective

Append-only per-subject and per-party chains over spine records, per
contract rule 5, the structure the D1/D3 verdicts called
unretrofittable.

## Scope

- Chain append inside the spine write transaction, alongside the outbox row
  (foundation/07): each record carries `prev_hash` for every stream it
  belongs to; genesis and empty-stream semantics per contract.
- **Streams cover every governing event, not only attestations** (decision
  019). D3's anchored contents are broader than the attestation record, and
  D4's dispositive argument depends on registry manipulation being visible
  in the log, which is false if registry events are unchained. Streams:
  per-subject and per-party attestation chains; **worker record writes
  (added by decision 063, so self-asserted claims chain from day one);
  registry and party
  lifecycle events; key events; privileged operator actions; deletion
  journal entries**. An audited-but-unanchored operator action is alterable
  by the operator, and the operator is the party a dispute distrusts.
- **Chain membership is fixed at write time and never re-keyed** (decision
  019). A record stays in the chain it was written into, keyed to the
  `ledger_person_id` that was live at that moment, forever. Merge adds
  alias resolution *above* the chains; it never moves a record between
  them. Re-keying would mean rewriting records already hashed into
  published checkpoints, breaking every existing inclusion proof. Cost
  accepted: a merged person's full history is a walk over several chains
  combined at the resolution layer, and unmerge is trivially correct
  because chain membership was never touched.
- `0007-stream-heads`: current head per stream, rebuildable from the
  records. **Granted as a named, role-scoped exemption in this migration.**
  Decision 017 dropped foundation/03's blanket derived/cache clause, so
  this table is licensed by name to a named role with its rationale at the
  site, not by a general category. Generalized over the stream types above,
  not just subject and party.
- Full-chain verification (used by the production auditor later): walks a
  stream, reports first divergence position.
- Subject-keyed layout with random UUIDv4 ids (decision 075; layout
  rationale documented at the schema site, per decision-50-style
  at-the-site rule).

## Acceptance

- AC (mechanical): a mutated historical record (simulated as table owner)
  is detected at the correct position in every stream it belongs to,
  including a worker record write (decision 063), a registry event, a key
  event, an operator action, and a
  deletion journal entry.
- AC (mechanical): a merge moves no record between chains. Chain
  membership before and after is byte-identical; resolution changes, chains
  do not.
- AC (mechanical): an unmerge restores prior resolution with zero chain
  writes.
- AC (mechanical): dropping stream heads and rebuilding reproduces
  identical heads (derived-cache proof).
- AC: chain append adds one round trip max to the write path (measured).

## Outside check

Verifier mutates one record as owner in each stream type, runs verification
on every affected stream, executes a merge and diffs chain membership
before and after, unmerges and confirms no chain write occurred, and
re-runs the rebuild diff.

## Evidence

The chain primitive is `core/kernel/chain.go`, inside the frozen core
(canonicalization, sign/verify, chain append/verify, tree construction;
decision 019). Storage, heads, the verification walk, the rebuild and
alias resolution are `core/streams`, kernel-adjacent under ordinary
review. `db/migrations/spine/0007-stream-heads.sql` creates `stream_link`
(one row per record-and-stream membership, carrying that stream's
`prev_hash` and the link it produced) and `stream_heads` (the head
projection). The acceptance suite is
`cd core && go test -tags db -count=1 ./streams/...`, wired into
`make check` as `streams-test`.

- Mutation criterion: `TestMutatedRecordIsDetectedInEveryStreamType`
  ranges over `streams.Types`, the closed vocabulary the migration's
  CHECK constraint enforces, so worker record writes (decision 063),
  registry events, key events, operator actions and deletion journal
  entries are each swept rather than sampled.
  `TestEveryPositionIsReportedAtItsOwnIndex` mutates each position of one
  chain in turn and asserts the reported position matches, restoring the
  record between rounds so exactly one divergence exists at a time.
  `TestMutatedRecordIsDetectedInEveryStreamItBelongsTo` puts one record
  in a subject chain and a party chain at different positions and
  asserts both walks report their own position for the single mutation.
  `TestMutatedDeletionJournalRowIsDetected` runs the same claim against
  the one record table that exists today: a real `deletion_journal` row,
  chained, then rewritten by the table owner.
  `TestRemovedRecordIsDetectedAtMinLength` covers contract rule 5's
  length-mismatch rule; `TestTamperedLinkRowIsDetected` and
  `TestRemovedLinkRowIsDetected` cover the link rows themselves. Every
  mutation is executed as the table owner, the adversary the chain
  exists to contradict.
- Merge criterion: `TestMergeMovesNoRecordBetweenChains` renders every
  link's membership (`streams.Membership`) before and after a merge and
  requires the two strings to be identical, while
  `streams.History` assembles both chains under the alias and every
  entry still names the chain it was written into.
  `TestResolutionIssuesNoWrite` re-reads membership and the head
  projection either side of a resolution.
- Unmerge criterion:
  `TestUnmergeRestoresPriorResolutionWithZeroChainWrites` drops the
  alias, requires the survivor's history to return to its own chain and
  the absorbed chain to remain intact and independent, and requires
  membership to be unchanged across the whole cycle. No chain write is
  possible in the cycle because resolution issues no statement against
  `stream_link` at all.
- Rebuild criterion: `TestRebuildReproducesIdenticalHeads` renders the
  projection, runs `streams.Rebuild` (a DELETE and one recomputing
  INSERT over `stream_link`, as the table owner), and requires the
  rendering to come back identical, then requires a second rebuild to be
  a no-op. `updated_at` is excluded from the rendering by design: a
  rebuild writes a new one, and the claim is that the chain facts are
  derived, not that the note of when they were written is.
  `TestHeadsMatchTheChainsTheyProject` is what gives that comparison its
  meaning, since a projection agreeing with nothing would also rebuild
  identically.
- Round-trip criterion: measured, not asserted.
  `core/transport.RoundTrips` counts psql invocations, and
  `TestChainAppendAddsOneRoundTrip` reads it either side of two writes.
  A write path that chains nothing costs one round trip; the same path
  with the record chained into three streams costs two. The extra one is
  the head read, which is a single query however many streams a record
  belongs to; staging costs none, because its statements travel in the
  transaction the caller was already committing.
- Append-only posture: `stream_heads` gains the named, role-scoped
  UPDATE grant decision 019 licensed, and the entry is enumerated in
  `test/append-only.test.mjs`, which fails if the grant exists without
  it or if any wider grant appears.
  `TestServingRoleCannotRewriteLinks` asserts the same boundary from the
  other side, and `TestAPositionIsWrittenOnce` proves two appenders
  racing one stream conflict rather than double-recording.
