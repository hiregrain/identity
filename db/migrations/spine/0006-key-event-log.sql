-- 0006-key-event-log (trust-kernel/02; decisions 011, 015, 016, 019): the
-- append-only key-event log. Number 0006 under the one shared numbering
-- sequence, claimed by the task frontmatter.
--
-- What this table is for: it is the ordering authority the
-- compromise-vs-backdating rule reads. D3's consolidated log-contents
-- ruling (design/stack-litigation/d3-verdict.md (e)) names "key
-- registered / rotated / compromised" as one of the three entry families
-- anchored from day one, and D6, ruled with D3, makes the anchored
-- checkpoint sequence the ordering authority behind the rule. The rule
-- itself is core/kernel/keyevent.go; this table is where its input lives.
--
-- Nothing here is ever updated or deleted. identity_app holds SELECT and
-- INSERT (0002) and this migration grants nothing further and exempts
-- nothing: a key's history is following rows, never an edited column.
-- The standing proof is test/append-only.test.mjs, whose EXEMPTIONS list
-- gains no entry for this table.
--
-- Two timestamps, and they are not interchangeable. Question 2 of the
-- foundation/04 correlation checklist, answered for both columns of
-- spine_ledger_timestamp here:
--
--   ledger_ts is the ledger's own stamp, defaulted to now() and never
--   supplied by a caller. It is the only column validity is computed
--   from. Full timestamptz precision: an adversary holding the spine
--   learns when the ledger recorded a key event, which is the fact the
--   log exists to publish.
--
--   effective_at is the reporting party's declared moment. It is
--   recorded provenance and it never drives validity. That split IS the
--   backdating defence: a party reporting today that its key was
--   compromised a year ago writes effective_at a year back and gets a
--   ledger_ts of today, and every signature the ledger stamped before
--   today stays valid. Full precision, and it carries whatever
--   granularity the party claimed, which is why it is disclosed as a
--   claim rather than read as a fact.
--
-- The primary key is what makes each event write-once per key: a key is
-- registered at most once, rotated out at most once, revoked at most
-- once, and reported compromised at most once. A second INSERT of the
-- same (party_id, key_id, event) conflicts rather than overwriting, so
-- there is no second compromise report to disagree with the first, and
-- no path to moving one. Same shape as person_lifecycle_transition
-- (0010-person-core), for the same reason.
--
-- party_id carries no REFERENCES clause: the party table lands with
-- party-registry, which is not in this graph yet. The operator's own
-- key events are the first rows written (decisions 015/016 give the
-- operator a single registry self-entry it signs with), and the
-- constraint arrives with the table it would point at.
--
-- justify-column: key_event.key_id (text)
--   1 ordering: none. A key identifier is opaque to this table and
--     order between a key's events comes from ledger_ts.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: the identifier names a signing key, not a
--     person. It is public by destiny (it travels inside every signed
--     payload under decision 019 and is anchored in the public log), so
--     it discloses nothing a reader of the log does not already hold.
--   4 commitment-salt-reuse: not a commitment; no salt. The same
--     identifier repeats across a key's own event rows by design, which
--     is the linkage the rule walks.
--   5 partial-dataset-adversary: an adversary holding the spine learns
--     which key identifiers exist and what happened to them. Accepted:
--     that is the published fact, and it describes a key, not a person.
--   Why text rather than a domain: a key identifier's shape belongs to
--   the provider that minted it. The software provider derives one from
--   its public key; a real KMS names its own (decision 011 leaves the
--   cloud open). Pinning a uuid domain here would force every provider
--   through one shape no ruling has picked.
--
-- justify-column: key_event.event (text)
--   1 ordering: none; the column is a closed vocabulary, CHECK-enforced,
--     and order comes from ledger_ts.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: the vocabulary is impersonal and closed; no
--     party-derived or person-derived value can reach this column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns that a key was
--     registered, rotated out, revoked, or reported compromised.
--     Accepted for the same reason as key_id: this is the log's purpose.

CREATE TABLE key_event (
    party_id spine_object_id NOT NULL,
    key_id text NOT NULL,
    event text NOT NULL CHECK (event IN ('registered', 'rotated', 'revoked', 'compromised')),
    effective_at spine_ledger_timestamp NOT NULL,
    ledger_ts spine_ledger_timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (party_id, key_id, event)
);

-- The rule walks one key's events, and a key is (party_id, key_id),
-- never the identifier alone: the identifier is public, so a read on it
-- alone returns rows another party wrote about a key it does not own.
-- The index leads with the pair the read predicates on. The primary key
-- already covers that pair; this adds the ledger_ts ordering the read
-- asks for.
CREATE INDEX key_event_by_key ON key_event (party_id, key_id, ledger_ts);

-- ledger_ts is the ledger's stamp, and this is what makes that a
-- property of the database rather than of the writing code's manners.
-- The default privileges from 0002 grant identity_app INSERT on the
-- whole table, and a table-level grant covers every column, so narrowing
-- it means revoking the table grant and re-granting the four columns a
-- caller may name. An INSERT naming ledger_ts is then permission-denied
-- for the serving role, and the value can only come from the DEFAULT.
--
-- This is a narrowing of an existing grant, not a new one, so it adds no
-- entry to test/append-only.test.mjs's EXEMPTIONS: that list enumerates
-- UPDATE, DELETE and TRUNCATE grants, and nothing here grants any.
REVOKE INSERT ON key_event FROM identity_app;
GRANT INSERT (party_id, key_id, event, effective_at) ON key_event TO identity_app;
