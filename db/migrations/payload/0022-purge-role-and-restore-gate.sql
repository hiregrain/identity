-- 0022-purge-role-and-restore-gate (foundation/08; decisions 014, 017;
-- design ledger-design-0.1 §2.5): the deletion PROMISE's payload-plane
-- half, the scheduled physical purge and the restore-time replay gate.
-- Number 0022 on the payload chain under the one shared numbering
-- sequence. The destroy primitive itself is foundation/05 (0005, the
-- DEK registry); the crypto-shredding legal position is recorded at the
-- deletion journal's schema site (0021, spine chain).
--
-- The objects landing here:
--
--   1. identity_purge, the ONLY role holding DELETE on any payload
--      table, so dead ciphertext does not accumulate forever. The
--      schedule is stated as a number in db/deletion-policy.json
--      (purge_interval_days); the runner is core/deletion (CLI
--      `deletion purge`), and every run writes an audit row in the same
--      transaction as its deletes.
--   2. restore_gate, the append-only state that makes the deletion
--      replay a GATE rather than a cleanup step: a restore appends a
--      'restored' row (db/restore.mjs, inside the restore transaction
--      itself), and only a completed journal replay appends the
--      balancing 'replayed' row. core/envelope refuses every serving
--      read and write while any 'restored' row is unbalanced. A
--      restored system that has not replayed does not serve.
--   3. purge_audit, the append-only audit trail of every purge run.
--
-- EXEMPTION LICENSE (foundation/03, migration 0002's header; decision
-- 017). UPDATE or DELETE for the application plane is granted only as a
-- documented exemption: per table, by name, to a named role, in the
-- migration that licenses it, citing the licensing decision, and
-- enumerated in test/append-only.test.mjs. The DELETE grant below is
-- exactly the exemption decision 017 ruled for the payload purge role
-- ("the purge role the only role holding DELETE on payload tables",
-- also the concrete answer to foundation/04's placeholder "exemptions
-- where deletion requires it"), and its entry in the standing proof's
-- EXEMPTIONS list lands in the same PR as this file. A future payload
-- content table that is purgeable licenses its own DELETE, by name, in
-- its own migration, and extends both the EXEMPTIONS list and the purge
-- run. There is no blanket grant to inherit.

-- The purge role. LOGIN with a throwaway local password for the same
-- reason identity_app has one (0002): the compose databases are
-- loopback-only development containers and real credentials are a
-- managed-Postgres concern behind the founder gate in plans/ORDER.md.
-- Every escalation attribute is explicitly off. Payload plane only.
-- This migration is on the payload chain, so no spine cluster ever
-- holds this role: the spine has no purge, its residue for a deleted
-- person being unreadable by construction (0021's header).
CREATE ROLE identity_purge
  LOGIN PASSWORD 'identity_purge'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;

DO $$
BEGIN
  EXECUTE format(
    'GRANT CONNECT ON DATABASE %I TO identity_purge',
    current_database()
  );
END
$$;

GRANT USAGE ON SCHEMA public TO identity_purge;

-- What the purge role may see and remove. SELECT on dek_registry is
-- what a predicated DELETE requires; SELECT on database_residency is
-- what stamping the audit row's residency requires. No INSERT on
-- dek_registry, no privilege of any kind on any other existing table:
-- the purge role can remove licensed rows and record having done so,
-- nothing else. Note the deliberate absence of TRUNCATE anywhere.
-- Truncation is not a per-row purge and no role serves it.
GRANT SELECT ON dek_registry TO identity_purge;
GRANT SELECT ON database_residency TO identity_purge;

-- THE LICENSED EXEMPTION (see the license header above): DELETE on
-- dek_registry, to identity_purge, by name. What is purgeable is not
-- "rows the purge process chooses": row-level security below narrows
-- this grant to shredded 'created' rows, wrapped-DEK ciphertext whose
-- person already holds a 'destroyed' row. The 'destroyed' rows
-- themselves are NOT deletable by anyone: they are what keeps every
-- read failing closed and the person id permanently unprovisionable
-- (0005, decision 014's never-reissue), so removing one would undo the
-- deletion it records.
GRANT DELETE ON dek_registry TO identity_purge;

-- dek_destroyed: does this person hold a 'destroyed' registry row?
-- SECURITY DEFINER (owner-executed) so the row-security policy below
-- can consult the registry without self-referential policy recursion,
-- which Postgres refuses. Body is a single SELECT. The append-only
-- proof scans SECURITY DEFINER bodies and admits no mutation keyword
-- (test/append-only.test.mjs, decision 017).
CREATE FUNCTION dek_destroyed(p spine_object_id) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = public
  AS $fn$
    SELECT EXISTS (
      SELECT 1 FROM dek_registry
       WHERE person_id = p AND event = 'destroyed')
  $fn$;

-- Row security narrows the DELETE grant to what decision 017 licensed.
-- ENABLE (not FORCE): the owner keeps its ordinary access, so
-- migrations and verification tooling are unaffected. identity_app's
-- envelope path is unchanged by the permissive catch-all policy; the
-- purge role sees every row but can remove only a shredded 'created'
-- row. An unpredicated DELETE issued by the purge role removes exactly
-- the licensed set and nothing else, enforced by the database rather
-- than by the purge runner's WHERE clause.
ALTER TABLE dek_registry ENABLE ROW LEVEL SECURITY;

CREATE POLICY dek_registry_app_all ON dek_registry
  FOR ALL TO identity_app
  USING (true) WITH CHECK (true);

CREATE POLICY dek_registry_purge_select ON dek_registry
  FOR SELECT TO identity_purge
  USING (true);

CREATE POLICY dek_registry_purge_licensed_rows ON dek_registry
  FOR DELETE TO identity_purge
  USING (event = 'created' AND dek_destroyed(person_id));

-- The restore gate. Append-only event pairs keyed by restore_id:
--
--   A restored payload plane is SERVING iff no 'restored' row lacks a
--   'replayed' row for the same restore_id.
--
-- That sentence is executed in exactly one place, core/envelope's
-- serving gate query, and derived nowhere else. A never-restored
-- database has zero rows and serves. db/restore.mjs appends the
-- 'restored' row INSIDE the single restore transaction, so at no
-- instant does a restored database hold data without holding the row
-- that gates it; core/deletion's `replay` appends the balancing
-- 'replayed' row only after every journal entry is re-destroyed. The
-- primary key admits one row per (restore_id, event), making both
-- writes idempotent under ON CONFLICT DO NOTHING. Nothing is ever
-- updated; identity_app writes 'replayed' with the INSERT grant it
-- inherits from 0002's default privileges, and this migration grants
-- nothing beyond that posture.
CREATE TABLE restore_gate (
    restore_id spine_object_id NOT NULL,
    event text NOT NULL
      CHECK (event IN ('restored', 'replayed')),
    noted_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL,
    PRIMARY KEY (restore_id, event)
);

-- The purge audit trail: one row per (run, purged table), written by
-- identity_purge IN THE SAME TRANSACTION as the run's deletes. A purge
-- that removed rows without its audit row is not representable, and a
-- run that removed nothing still writes its row (rows_deleted = 0), so
-- the schedule's execution is itself auditable. Attribution is two
-- fields: initiated_by (who asked for the run, required by the CLI)
-- and executed_as (the session role, stamped from session_user by the
-- insert, which the database guarantees is the role that held the
-- DELETE). Append-only: INSERT below is the only privilege the purge
-- role gains here, and no role holds UPDATE or DELETE on this table.
CREATE TABLE purge_audit (
    run_id uuid NOT NULL,
    purged_table text NOT NULL,
    rows_deleted bigint NOT NULL CHECK (rows_deleted >= 0),
    initiated_by text NOT NULL CHECK (initiated_by <> ''),
    executed_as text NOT NULL,
    executed_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL,
    PRIMARY KEY (run_id, purged_table)
);

GRANT INSERT ON purge_audit TO identity_purge;
