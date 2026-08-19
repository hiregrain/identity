-- Red-path fixture (make check-red-db): a DECOY. This file is NOT the
-- migration the fixture allow-list's exception names
-- (9998-planted-exception), yet it carries a complete justification
-- block for that exception's column. The lint must refuse the match:
-- a justification counts only in the migration the exception's
-- `migration` field names, so pointing the lint at this dir (with no
-- 9998 file present) must fail. Applied by nothing, ever.
--
-- justify-column: planted_exception.blob (bytea)
--   1 ordering: decoy — no ordering exists.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: decoy value, joins to nothing.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: risk accepted, because this block sits
--     in the wrong file and must never satisfy the lint.

SELECT 1;
