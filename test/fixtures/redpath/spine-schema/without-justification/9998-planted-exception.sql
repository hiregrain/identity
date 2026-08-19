-- Red-path fixture (make check-red-db): a migration introducing a
-- declared allow-list-exception column with NO justification block.
-- Applied to the live spine directly by check-red-db, never by the
-- migration runner. The lint, pointed at this dir plus the fixture
-- allow-list, must fail: the exception is declared but unanswered.

CREATE TABLE planted_exception (
    blob bytea
);
