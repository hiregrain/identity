-- 0005-dek-registry (foundation/05; decisions 011, 014, 017): the
-- per-person wrapped-DEK registry, on the payload chain under the shared
-- numbering sequence.
--
-- The registry is an append-only event log, like every payload table
-- under migration 0002's posture: the application role holds SELECT and
-- INSERT only, inherited from the standing default privileges, and this
-- migration GRANTS NOTHING. Destruction is therefore a new row, never an
-- update — a 'destroyed' event appended after the 'created' event.
--
-- The single state-derivation rule (the only one; core/envelope
-- documents and executes the same sentence):
--
--   A person's DEK is ACTIVE iff the registry holds a 'created' row for
--   the person and no 'destroyed' row for the person; otherwise there is
--   no usable DEK and every read fails closed.
--
-- "At most one ACTIVE DEK per person" is enforced by CONSTRAINT, not
-- convention: the partial unique index dek_registry_one_created admits
-- at most one 'created' row per person, ever, which implies at most one
-- active under the rule above. This is deliberately the strongest form —
-- no decisions entry rules DEK rotation, and a re-registration after
-- deletion is a NEW person id (decision 014: a tombstoned id is never
-- reissued), so a second 'created' row for one id has no legitimate
-- meaning today. If rotation is ever ruled, it arrives as its own
-- migration against that decision.
--
-- Idempotent destruction is likewise a constraint plus an insert shape:
-- dek_registry_one_destroyed admits at most one 'destroyed' row per
-- person, and the destroy path inserts with ON CONFLICT DO NOTHING
-- against it — a second destroy is a no-op, not an error and not a
-- second row.
--
-- Subject-scoped, single owner (decision 017, grounded in 014): a row
-- carries exactly one person_id and exactly one wrapped_dek. There is no
-- second key column and no co-owner column, so a dual wrap is not
-- representable in this schema — a payload row about two people is keyed
-- to the SUBJECT alone, and destroying the subject's DEK makes the row
-- unreadable to everyone, the issuing party included.
--
-- The wrapped_dek is ciphertext under the active key provider's per-scope
-- wrapping key (core/keys). key_provider records which provider wrapped
-- it — observability and incident response legitimately need to know
-- (decision 017's corrected invariant); no business path branches on it.
--
-- residency_region carries no DEFAULT: every insert stamps the value the
-- database itself declares (SELECT residency_region FROM
-- database_residency), so the checked assertion cannot drift from the
-- authority even on a hand-typed insert that forgot the column — it
-- would fail NOT NULL rather than silently defaulting.

CREATE TABLE dek_registry (
    person_id spine_object_id NOT NULL,
    event text NOT NULL
      CHECK (event IN ('created', 'destroyed')),
    -- Key material travels only on 'created'; a destruction row carries
    -- none — recording a destruction must never re-record the key.
    wrapped_dek bytea
      CHECK ((event = 'created') = (wrapped_dek IS NOT NULL)),
    key_provider text NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
);

-- At most one 'created' row per person, ever (see header: implies at
-- most one ACTIVE DEK per person).
CREATE UNIQUE INDEX dek_registry_one_created
  ON dek_registry (person_id)
  WHERE event = 'created';

-- At most one 'destroyed' row per person; the destroy path's ON CONFLICT
-- DO NOTHING arbiter, which is what makes a second destroy a no-op.
CREATE UNIQUE INDEX dek_registry_one_destroyed
  ON dek_registry (person_id)
  WHERE event = 'destroyed';
