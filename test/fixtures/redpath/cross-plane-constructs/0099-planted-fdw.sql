-- Red-path fixture (foundation/07): a migration creating a foreign data
-- wrapper connection to the other plane. checks/cross-plane-constructs.mjs
-- (file mode) must fail on this file.
CREATE EXTENSION postgres_fdw;
CREATE SERVER other_plane FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '127.0.0.1', port '5434', dbname 'payload');
