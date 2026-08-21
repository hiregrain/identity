-- 0010-person-core (person-identity/01; decisions 013, 017, 075): the
-- person's spine half. Number 0010 under the one shared numbering
-- sequence, claimed by the task frontmatter. The payload half carries
-- the same number and name in the payload chain
-- (db/migrations/payload/0010-person-core.sql), because signup is one
-- migration across the split rather than two; the numbering check reads
-- a number and a name, and both files declare the same pair.
--
-- What the spine holds for a person: the id, when it was issued, and the
-- lifecycle transitions that id has passed through. Nothing else. Every
-- contact channel, every name, every risk signal is payload content and
-- lives on the other plane behind the person's DEK (foundation/05).
--
-- The id is random UUIDv4 (decision 075, superseding the UUIDv7 wording
-- that stood in this layer's plans). A time-ordered id leaks enrollment
-- order and volume in a value that circulates, and hash-prefixing
-- answers the insert-locality objection without removing the readable
-- timestamp. Locality is given up deliberately. The hot-range warning
-- stays recorded here as the reason, never as a licence to reintroduce
-- ordering: an id that sorts is an id that discloses.
--
-- created_at is the ledger's own column rather than bits inside the id,
-- which is the whole point of the pair. Question 2 of the foundation/04
-- correlation checklist, answered for this column: full timestamptz
-- precision, so an adversary holding the spine learns signup order and
-- rate. Accepted because the ledger controls the column and can coarsen
-- it at write time later, and because the alternative that was rejected,
-- a time-ordered id, would have published the same fact inside a value
-- that travels to every party that ever reads the record.
--
-- Nothing here is ever updated. identity_app holds SELECT and INSERT
-- (0002) and this migration grants nothing further and exempts nothing:
-- lifecycle is a following row, never an edited column.
--
-- justify-column: person_lifecycle_transition.state (text)
--   1 ordering: none; the column is a closed vocabulary, CHECK-enforced,
--     and order between transitions comes from recorded_at.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: the vocabulary is impersonal and closed
--     ('active', 'tombstoned'); no person-derived value can reach this
--     column, so it joins to nothing external.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary holding the spine learns
--     that an id was issued and whether it has been tombstoned. Risk
--     accepted, because that is the fact the spine exists to carry: a
--     tombstoned id is never reissued, and the row proving it is what
--     makes the promise checkable. It describes the id, not the person.

-- One row per person, written in the same spine transaction as the
-- outbox entries that carry the payload half (0020-cross-plane-outbox).
-- That commit is when the id is issued: the account is usable from that
-- moment, and anything needing payload waits on the acknowledgment
-- watermark (cross_plane_acknowledged). This is what "instantly" means
-- here, stated once so the word cannot mean three things.
--
-- The primary key is what makes reuse impossible at the table. A person
-- row is never deleted, tombstoned included, so an issued id occupies
-- its key forever and a second INSERT of it fails. Deletion destroys the
-- person's payload content and their DEK (foundation/08); the spine's
-- record that the id was used survives, because spine signatures
-- reference it forever (decision 013).
CREATE TABLE person (
    person_id spine_object_id PRIMARY KEY,
    created_at spine_ledger_timestamp NOT NULL DEFAULT now()
);

-- Lifecycle as write-once transition rows, never an editable column.
-- The (person_id, state) primary key is the write-once part: a state is
-- entered at most once, a second attempt conflicts rather than
-- overwriting, and the current state is read as the latest row rather
-- than trusted from a field somebody could have set.
--
-- The 'tombstoned' row IS the tombstone marker. A separate marker column
-- would be a second mechanism for one fact, and the two would drift.
CREATE TABLE person_lifecycle_transition (
    person_id spine_object_id NOT NULL REFERENCES person (person_id),
    state text NOT NULL CHECK (state IN ('active', 'tombstoned')),
    recorded_at spine_ledger_timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (person_id, state)
);

-- The queryable form of "this id is spent". A tombstoned id appears
-- here and never leaves, so the issuance path has one place to ask.
CREATE VIEW person_tombstoned AS
SELECT person_id
  FROM person_lifecycle_transition
 WHERE state = 'tombstoned';
