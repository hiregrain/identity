-- 0004-payload-us-bootstrap (foundation/04; decisions 011, 017): the
-- payload-us database's base conventions. First file in the payload's
-- own chain (db/migrations/payload/), number 0004 under the one shared
-- numbering sequence.
--
-- Residency rule (decision 017, settled by the foundation/04 spec): the
-- DATABASE is authoritative for residency — a row lives in the region of
-- the database it sits in — and the `residency_region` column is a
-- checked assertion of that fact. The column exists because it is what
-- survives a dump or a restore, exactly when the database name is lost.
-- checks/payload-residency.mjs enforces both halves: every payload table
-- carries `residency_region` NOT NULL, and any row whose column
-- disagrees with the database's declared region is a caught error.
--
-- This migration GRANTS NOTHING beyond 0002's posture. Payload deletion
-- (which payload tables are physically deletable, and by which role) is
-- foundation/08's to define; until it lands, the payload plane is as
-- append-only as the spine.

-- Region grammar: lowercase region codes ('us', later 'eu', ...). The
-- domain does not pin the value to 'us' — the value is per row and per
-- database, and the check compares them; the domain only keeps the
-- vocabulary regular.
CREATE DOMAIN residency_region AS text
  CHECK (VALUE ~ '^[a-z]{2}$');

-- Payload rows are keyed by spine object ID. Same name and base type as
-- the spine's domain (0003), declared per plane because the planes share
-- no catalog — a payload row references a spine object by value, never
-- by SQL join (cross-plane assembly happens in application code;
-- FDW/dblink is banned by foundation/07).
CREATE DOMAIN spine_object_id AS uuid;

-- The database's own residency declaration: one row, written at
-- bootstrap, the value the row-level check compares every
-- `residency_region` column against. The one_row key makes it a
-- singleton — a second INSERT conflicts — so the application role's
-- INSERT grant cannot turn the declaration ambiguous, and no UPDATE
-- grant exists to move it (0002). Changing a database's region is a
-- migration, which is the right amount of ceremony.
CREATE TABLE database_residency (
    one_row boolean PRIMARY KEY DEFAULT true CHECK (one_row),
    residency_region residency_region NOT NULL
);

INSERT INTO database_residency (residency_region) VALUES ('us');

-- Every payload table carries the assertion, bookkeeping included —
-- the lint has no exemption list, which is the point: "every table"
-- stays checkable only while it is literally true. The DEFAULT keeps
-- the migration runner's bookkeeping INSERT (db/migrate.mjs) valid and
-- stamps rows with this database's region.
ALTER TABLE schema_migrations
  ADD COLUMN residency_region residency_region NOT NULL DEFAULT 'us';
