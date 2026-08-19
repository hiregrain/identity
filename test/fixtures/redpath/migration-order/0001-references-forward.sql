-- Red-path fixture: this migration references future_table, which the
-- higher-numbered 0002-creates-late creates. checks/migration-order.mjs
-- must fail: a referencing migration carries the higher number.
INSERT INTO future_table (id) VALUES (1);
