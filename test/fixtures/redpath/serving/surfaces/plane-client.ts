// Red-path fixture (foundation/03): a serving-tree file holding the
// owner credential. checks/serving-credentials.mjs pointed at
// test/fixtures/redpath/serving must exit 1 on this file. Never imported.
export const dsn = "postgres://identity:identity@127.0.0.1:5433/spine";
