-- Red-path fixture (make check-red-db): the same planted exception WITH
-- a complete five-question justification block, proving the lint's pass
-- path is the block's presence, not a fixture quirk. Applied to the live
-- spine directly by check-red-db, never by the migration runner.
--
-- justify-column: planted_exception.blob (bytea)
--   1 ordering: fixture, no ordering exists.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: fixture value, joins to nothing.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: risk accepted, because the table exists
--     only for the duration of a red-path run.

CREATE TABLE planted_exception (
    blob bytea
);
