-- 0007-stream-heads (trust-kernel/03; decisions 017, 019, 063, 075;
-- contract rule 5): the per-stream hash chains and their head
-- projection. Number 0007 under the one shared numbering sequence,
-- claimed by the task frontmatter. It is lower than migrations already
-- applied, which is fine and is what the numbering rule intends: a
-- number belongs to one file forever, the runner applies in number
-- order from empty, and nothing here references an object a
-- higher-numbered migration creates.
--
-- What a stream is. Every governing event this ledger records belongs to
-- one or more append-only chains, and a chain is identified by a stream
-- type and a stream key. Decision 019 widened the streams past
-- attestations for two reasons that are not stylistic: D3's anchored
-- contents are broader than the attestation record, and D4's dispositive
-- argument depends on registry manipulation being visible in the log,
-- which is false if registry events are unchained. An
-- audited-but-unanchored operator action is alterable by the operator,
-- and the operator is the party a dispute distrusts. The stream types
-- are the CHECK vocabulary below, and worker record writes are among
-- them by decision 063, so self-asserted claims chain from day one.
--
-- What a link commits to. Contract rule 5: SHA-256, genesis prev is 32
-- zero bytes, records are JCS-canonicalized before hashing, domain tag
-- 0x02 leads the preimage, and an empty stream's head is 64 hex zeros.
-- core/kernel/chain.go is the implementation and carries the preimage
-- order with its reasoning. The record itself is NOT stored here: it
-- lives in the table that owns it (a deletion journal row, a registry
-- event, a worker record write), and a link commits to the canonical
-- bytes of that record. Verification re-reads the record from its own
-- table, recomputes the chain, and reports the first position that does
-- not match, which is what makes a mutation by the table owner
-- detectable rather than merely discouraged.
--
-- Chain membership is fixed at write time and never re-keyed (decision
-- 019). A link stays in the stream it was written into, keyed to the id
-- that was live at that moment, forever. A merge adds alias resolution
-- ABOVE these chains (core/streams.Resolve) and moves nothing; there is
-- no statement anywhere that rewrites stream_key, and the append-only
-- posture is what makes that a property of the database rather than a
-- convention. Re-keying would rewrite records already hashed into
-- published checkpoints and break every existing inclusion proof. The
-- accepted cost: a merged person's full history is a walk over several
-- chains combined at the resolution layer, and unmerge is trivially
-- correct because membership was never touched.
--
-- Layout (decision 075's id posture, answered for this table). Ids on
-- the spine are random UUIDv4, so there is no insert locality to be had
-- from an id and none is sought here. The primary key is instead
-- subject-keyed, (stream_type, stream_key, link_position): a chain walk,
-- which is the read this table exists to serve, is one index range scan
-- over rows physically adjacent by insertion within a stream, and the
-- scattered writes across streams are the price of ids that do not sort.
-- There is deliberately no surrogate link id: the position within a
-- stream IS the link's identity, and a second identifier would be a
-- second way to name one row.
--
-- Append-only, with one exemption, named here and enumerated in
-- test/append-only.test.mjs. stream_link grants nothing and exempts
-- nothing: identity_app holds SELECT and INSERT from migration 0002 and
-- that is all an append needs. stream_heads is a projection whose rows
-- move, so identity_app holds UPDATE on that table BY NAME. Decision 017
-- dropped foundation/03's blanket derived/cache clause, so this table is
-- licensed as a named, role-scoped exemption with its rationale at the
-- site (decision 019), never as a member of a general category. The
-- grant is UPDATE alone: a rebuild deletes and reinserts, and a rebuild
-- runs as the table owner, so no serving role holds DELETE here.
--
-- justify-column: stream_link.stream_type (text)
--   1 ordering: none; a closed vocabulary, CHECK-enforced, naming which
--     kind of governing event the chain carries.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: the vocabulary is impersonal and closed. No
--     person-derived value can reach this column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary holding a spine dump
--     learns that this ledger chains attestations, worker record
--     writes, registry and key events, operator actions and deletions,
--     which the published contract already states. Risk accepted; it
--     describes the ledger, never a person.
--
-- justify-column: stream_link.link_position (integer)
--   1 ordering: yes, and deliberately: the position IS the chain's
--     order, and verification reports a divergence by position
--     (contract rule 5). Within a stream it reveals how many governing
--     events of that kind that key has accumulated, which is the fact a
--     chain exists to make countable and unforgeable.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: a small counter from 0; joins to nothing
--     external.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns a per-stream event
--     count. Risk accepted, because the count is inherent in an
--     auditable chain: a chain whose length is hidden cannot be walked
--     by the auditor it exists for.
--   Named link_position rather than position because POSITION is a
--   Postgres function keyword, and a column that needs quoting in half
--   its uses is a column that will eventually be quoted wrong.
--
-- justify-column: stream_heads.stream_type (text)
--   1 ordering: none; the same closed CHECK vocabulary stream_link
--     carries, naming which kind of chain this head belongs to.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: impersonal closed vocabulary; no
--     person-derived value can reach this column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: this table is rebuildable from
--     stream_link and holds no value stream_link does not, so an
--     adversary learns exactly what that column's answer already
--     conceded and nothing further.
--
-- justify-column: stream_heads.link_position (integer)
--   1 ordering: yes; it is the position of the stream's last link, the
--     same ordering fact stream_link.link_position carries.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: a small counter from 0; joins to nothing
--     external.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns a per-stream event
--     count, which the chain publishes by being walkable at all. Risk
--     accepted on stream_link.link_position's reasoning; this column
--     restates it and adds nothing.

-- One row per (record, stream) membership: a record belonging to two
-- streams, an attestation in both its subject's and its party's chain,
-- carries a prev_hash in each, which is what "each record carries
-- prev_hash for every stream it belongs to" means physically.
--
-- prev_hash and link_hash are the allow-listed commitment domain: 32
-- opaque bytes each. link_hash = SHA-256(0x02 || prev_hash ||
-- canonical(record)), and no CHECK pins the length here because
-- 0003-spine-core deliberately left spine_commitment unpinned; pinning
-- it would pin the hash algorithm for every commitment on the spine,
-- which no decisions entry has ruled.
--
-- Two concurrent appends to one stream read the same head and try to
-- write the same position. The primary key makes that a conflict, not a
-- double-recording: one transaction commits and the other fails and
-- retries forward, the same recovery grammar as 0020's outbox attempts
-- and for the same reason, the spine is append-only and there is no
-- compensation path.
CREATE TABLE stream_link (
    stream_type text NOT NULL CHECK (stream_type IN (
        'subject_attestation',
        'party_attestation',
        'worker_record',
        'registry_event',
        'key_event',
        'operator_action',
        'deletion_journal_entry'
    )),
    stream_key spine_object_id NOT NULL,
    link_position integer NOT NULL CHECK (link_position >= 0),
    record_id spine_object_id NOT NULL,
    prev_hash spine_commitment NOT NULL,
    link_hash spine_commitment NOT NULL,
    recorded_at spine_ledger_timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (stream_type, stream_key, link_position)
);

-- The current head per stream: a cache of the last link, and nothing a
-- chain's correctness depends on. Dropping every row and recomputing it
-- from stream_link reproduces it exactly (core/streams.Rebuild, proven
-- by the acceptance suite), which is the whole claim a derived table has
-- to make to be allowed to exist on an append-only plane.
--
-- Why it exists at all: an append needs the stream's current head, and
-- without this table that read is an ORDER BY over the chain's links.
-- With it, one indexed lookup answers every stream an appending
-- transaction touches, which is what holds a chain append to one round
-- trip on the write path.
CREATE TABLE stream_heads (
    stream_type text NOT NULL CHECK (stream_type IN (
        'subject_attestation',
        'party_attestation',
        'worker_record',
        'registry_event',
        'key_event',
        'operator_action',
        'deletion_journal_entry'
    )),
    stream_key spine_object_id NOT NULL,
    link_position integer NOT NULL CHECK (link_position >= 0),
    head_hash spine_commitment NOT NULL,
    updated_at spine_ledger_timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (stream_type, stream_key)
);

-- The named, role-scoped exemption (decision 019). identity_app moves a
-- head forward with INSERT ... ON CONFLICT DO UPDATE in the same
-- transaction as the link it records. Enumerated in
-- test/append-only.test.mjs, which fails if this grant exists without an
-- entry there or if any wider grant appears.
GRANT UPDATE ON stream_heads TO identity_app;
