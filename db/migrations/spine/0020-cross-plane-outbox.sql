-- 0020-cross-plane-outbox (foundation/07; decisions 011, 017): the
-- spine-first transactional outbox. Number 0020 under the one shared
-- numbering sequence, claimed by the task frontmatter.
--
-- There is no shared transaction across the two physical databases
-- (decision 011), so a spine+payload write can commit one side and lose
-- the other. Decision 017's ruling: the spine write and an outbox row
-- commit in ONE local spine transaction. The spine is the ordering and
-- integrity authority, so its commit is what "recorded" means. A worker
-- (core/outbox) drains the outbox and applies each instruction to the
-- payload plane idempotently; a reconciler surfaces entries past a
-- threshold. There is no compensation path. The spine is append-only,
-- so recovery is retry forward, never undo.
--
-- Everything here is append-only under the identity_app posture
-- (migration 0002, SELECT+INSERT only): completion of an entry is marked
-- by a FOLLOWING row in cross_plane_outbox_attempts, never an UPDATE.
-- This migration grants nothing and exempts nothing.
--
-- Acknowledgment semantics (owed to `ingestion`): an entry is
-- acknowledged only when both planes are durable. The spine outbox row
-- exists AND an attempt row with state 'applied' exists, that row being
-- written only after the payload transaction committed. The view
-- cross_plane_acknowledged is the queryable form of that state; it is a
-- state to read, never a callback.
--
-- The instruction column is bytea, opaque by type, like spine_commitment
-- (0003): the lint cannot prove a bytea encodes nothing readable, so the
-- write-site rule is recorded here. Once the per-subject DEK envelope
-- (foundation/05) lands, instructions carrying subject content must ride
-- as ciphertext under the subject's key, so the spine's append-only
-- residue of an instruction dies with the key at deletion. Until content
-- tables exist there is no subject content to carry; the harness
-- exercises the mechanism against test-scoped tables.
--
-- The FDW/dblink ban (foundation/07, checked by
-- checks/cross-plane-constructs.mjs) is what keeps this outbox the ONLY
-- cross-plane channel: no migration in either chain may create a
-- foreign data wrapper, foreign server, foreign table, or dblink call.
--
-- justify-column: cross_plane_outbox.target_plane (text)
--   1 ordering: none; the value names a database, not a sequence.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: values come from the closed vocabulary of
--     plane names ('payload', CHECK-enforced); no person-derived value
--     can reach this column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns that this ledger
--     has a payload plane, which docker-compose.yml already publishes;
--     risk accepted, because the vocabulary is closed and impersonal.
--
-- justify-column: cross_plane_outbox.instruction (bytea)
--   1 ordering: none beyond created_at's, answered on its domain (0003).
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: opaque bytes by type. Plaintext subject
--     content here would be joinable, which is why the write-site rule
--     in this migration's header requires subject content to ride as
--     ciphertext under the subject's DEK once foundation/05 lands; the
--     lint cannot prove opacity (decision 017), so generation sites are
--     the review point, exactly as for spine_commitment.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: risk accepted, because decision 017
--     ruled the payload instruction rides the spine outbox (the crash
--     between planes is unrecoverable otherwise), and the ciphertext
--     write-site rule above is what keeps a spine dump unreadable
--     without the payload plane's keys.
--
-- justify-column: cross_plane_outbox_attempts.attempt (integer)
--   1 ordering: reveals how many times one entry was tried, an
--     operational fact about the worker; risk accepted, because it
--     describes infrastructure retries, not any person's activity.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: a small counter starting at 1; joins to
--     nothing external.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns retry counts,
--     which describe payload-plane availability, never a subject.
--
-- justify-column: cross_plane_outbox_attempts.state (text)
--   1 ordering: none; two values, CHECK-enforced.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: closed vocabulary ('applied', 'failed');
--     no person-derived value can reach this column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns whether an apply
--     succeeded, an infrastructure fact; no person is described.
--
-- justify-column: cross_plane_outbox_attempts.detail (text)
--   1 ordering: none.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: values are error text from the payload
--     database. The worker (core/outbox) writes only the first line,
--     truncated, since Postgres first lines name relations, constraints
--     and privileges, not row values, and that write-site discipline is
--     the review point, since the lint cannot prove text content.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns why applies
--     failed (missing table, permission, conflict); risk accepted,
--     because the recorded first line describes schema and
--     infrastructure, and the write-site rule keeps row values out.

-- One row per cross-plane write, inserted in the SAME spine transaction
-- as the spine write it accompanies. Its commit is the recording event.
CREATE TABLE cross_plane_outbox (
    entry_id spine_object_id PRIMARY KEY,
    target_plane text NOT NULL CHECK (target_plane = 'payload'),
    instruction bytea NOT NULL,
    created_at spine_ledger_timestamp NOT NULL DEFAULT now()
);

-- The append-only progress trail. A completed entry is one with a
-- following 'applied' row; a failed attempt is a 'failed' row. Nothing
-- here is ever updated. identity_app cannot (0002), and the worker
-- never needs to. The (entry_id, attempt) key makes the attempt counter
-- collision-safe: two workers racing the same attempt number conflict
-- instead of double-recording.
CREATE TABLE cross_plane_outbox_attempts (
    entry_id spine_object_id NOT NULL
        REFERENCES cross_plane_outbox (entry_id),
    attempt integer NOT NULL CHECK (attempt >= 1),
    state text NOT NULL CHECK (state IN ('applied', 'failed')),
    detail text NOT NULL DEFAULT '',
    noted_at spine_ledger_timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (entry_id, attempt)
);

-- The queryable acknowledgment state: an entry appears here exactly when
-- both planes are durable, because the 'applied' row is written only
-- after the payload transaction commits. `ingestion`'s ack watermark
-- reads this rather than defining its own.
CREATE VIEW cross_plane_acknowledged AS
SELECT o.entry_id
  FROM cross_plane_outbox o
 WHERE EXISTS (
    SELECT 1
      FROM cross_plane_outbox_attempts a
     WHERE a.entry_id = o.entry_id
       AND a.state = 'applied'
 );
