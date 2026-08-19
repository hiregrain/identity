-- 0002-roles-and-default-privileges (foundation/03; decisions 005, 017).
--
-- The database itself guarantees append-only: the application role holds
-- SELECT and INSERT and nothing else, on every table, present and future.
-- Adopts Dispatch's proven role/default-privileges pattern (its 0002/0006)
-- in structure. Plane-agnostic, applied to both databases under the shared
-- numbering sequence, like 0001: both planes need the identical posture,
-- and one file keeps the number unique in the filesystem.
--
-- Who may do what, from here forward:
--
--   * The application role (`identity_app`) is the only role serving
--     processes run as. SELECT and INSERT, nothing else. It never holds
--     owner or migration credentials (asserted by
--     checks/serving-credentials.mjs and test/append-only.test.mjs).
--   * Migrations keep running as the table owner (the compose `identity`
--     user), which retains UPDATE/DELETE — schema evolution stays
--     ordinary tooling, per Dispatch's trigger-rejection reasoning.
--   * UPDATE or DELETE for the application plane is granted only as a
--     documented exemption: per table, by name, to a named role, in the
--     migration that creates or licenses the table, with a comment citing
--     the licensing decision. Each exemption is enumerated in
--     test/append-only.test.mjs, so granting one requires editing the
--     standing proof. No blanket exemption class exists (the inherited
--     derived/cache clause was dropped by decision 017). Exemptions
--     already ruled but landing at their own migration sites:
--     `party_users` erasure (decision 016), the payload purge role
--     (foundation/08), `stream_heads` rebuildable projection
--     (trust-kernel/03, decision 019).
--   * SECURITY DEFINER functions may only INSERT; their bodies are
--     scanned by test/append-only.test.mjs.
--
-- Default privileges are per granting role and per schema. This file
-- covers the (identity, public) pair that exists today. Every future
-- migration that creates a schema or introduces a new owner role MUST
-- repeat this pattern for the new (owner, schema) pair:
--
--   GRANT USAGE ON SCHEMA <schema> TO identity_app;
--   ALTER DEFAULT PRIVILEGES FOR ROLE <owner> IN SCHEMA <schema>
--     GRANT SELECT, INSERT ON TABLES TO identity_app;
--   ALTER DEFAULT PRIVILEGES FOR ROLE <owner> IN SCHEMA <schema>
--     GRANT USAGE, SELECT ON SEQUENCES TO identity_app;
--
-- unless the schema is a member of a declared incompatible pair
-- (db/incompatible-schema-pairs.json, decision 017), in which case the
-- creating migration grants per that pair's disjoint-readers rule
-- instead. That is a once-per-schema migration statement, not a
-- per-table step: a table created later in a covered schema inherits the
-- restriction with no action at all, which is what
-- test/append-only.test.mjs proves.

-- The serving role. LOGIN with a throwaway local password: the compose
-- databases are loopback-only development containers (docker-compose.yml)
-- and in-container access is trust-authenticated; real serving
-- credentials are a managed-Postgres concern behind the founder gate in
-- plans/ORDER.md. Every escalation attribute is explicitly off.
CREATE ROLE identity_app
  LOGIN PASSWORD 'identity_app'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;

-- Database name differs per plane, so the CONNECT grant derives it.
DO $$
BEGIN
  EXECUTE format(
    'GRANT CONNECT ON DATABASE %I TO identity_app',
    current_database()
  );
END
$$;

-- The (identity, public) pair that exists as of this migration.
GRANT USAGE ON SCHEMA public TO identity_app;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO identity_app;
-- Sequence USAGE is what nextval() needs; without it INSERT into a table
-- with an identity/serial column fails, which would make "INSERT is
-- granted" false in practice. No UPDATE (setval) is granted.
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO identity_app;
ALTER DEFAULT PRIVILEGES FOR ROLE identity IN SCHEMA public
  GRANT SELECT, INSERT ON TABLES TO identity_app;
ALTER DEFAULT PRIVILEGES FOR ROLE identity IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO identity_app;
