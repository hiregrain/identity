-- 0001-migration-infrastructure: the migrations bookkeeping table.
--
-- Plane-agnostic: this file sits at the chain root and the runner applies
-- it to every database before that database's own chain, so both planes
-- record their applied migrations in the same shape. It occupies number
-- 0001 once — the two chains share one numbering sequence (decision 017),
-- and a file applied to both databases is still one number.
--
-- Executes as the table owner, like every migration; foundation/03
-- constrains the application role separately.

CREATE TABLE schema_migrations (
    number integer PRIMARY KEY,
    name text NOT NULL,
    applied_at timestamptz NOT NULL DEFAULT now()
);
