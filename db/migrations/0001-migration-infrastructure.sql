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
--
-- On the spine, every column here is outside the spine allow-list
-- (db/spine-allow-list.json) and is declared there as a per-column
-- exception; the justification blocks below answer foundation/04's
-- five-question correlation checklist for each, in the lint-readable
-- format checks/spine-schema.mjs defines. The content describes the
-- schema and the operator, never a person.
--
-- justify-column: schema_migrations.number (integer)
--   1 ordering: reveals migration apply order, which is already public
--     in this repository's file listing; risk accepted, because the
--     ordering describes the schema, not any person.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: no person-linked value; the only join target
--     is this repository's own migration files.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns which migrations
--     ran, which the public repository already states.
--
-- justify-column: schema_migrations.name (text)
--   1 ordering: none beyond the number column's, answered above.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: values are repository filenames; joinable
--     only to the public repository, never to a roster of people.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: readable text by type, but the values
--     are this repository's migration names; risk accepted, because no
--     person-derived value can reach this column.
--
-- justify-column: schema_migrations.applied_at (timestamp with time zone)
--   1 ordering: duplicates the number column's ordering, answered above.
--   2 timestamp-granularity: full precision reveals when the operator
--     ran migrations; risk accepted, because it is operational metadata
--     about the database, not activity of any subject.
--   3 external-roster-join: joinable only to deployment history, which
--     concerns the operator, not a person on the ledger.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary learns deployment times;
--     risk accepted, no person is described.

CREATE TABLE schema_migrations (
    number integer PRIMARY KEY,
    name text NOT NULL,
    applied_at timestamptz NOT NULL DEFAULT now()
);
