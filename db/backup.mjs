// Backup of the payload plane (foundation/08, decision 017). A real
// pg_dump, plain SQL format, taken through the compose container like
// every other database access in this repo — and the enforcement site
// of the bounded retention decision 017 ruled: every run prunes any
// dump older than db/deletion-policy.json's backup_retention_days, so
// the residual window the worker-facing copy states (copy/deletion.md,
// held equal by checks/deletion-copy.mjs) is the window this script
// keeps true. A backup that outlives the stated window is a copy of a
// deleted person nothing promised, which is why pruning is not a
// separate maintenance step anyone could forget.
//
// The dump is data + schema of the payload database only. Roles are
// cluster-level and outside pg_dump's scope — db/restore.mjs recreates
// the serving roles before applying a dump, and documents why. The
// spine is deliberately not backed up here: this task owns the payload
// promise, and the deletion journal (0021, spine) must OUTLIVE payload
// backups for the restore replay to mean anything.
//
// Plain format, deliberately: db/restore.mjs applies the dump and the
// restore-gate row in ONE psql transaction, so at no instant does a
// restored database hold data without the row that gates it — a
// custom-format archive would force pg_restore, which cannot carry the
// extra statement.
//
// Usage: node db/backup.mjs [backupsDir]
//   Default backupsDir: backups/ (gitignored). Writes
//   payload-<UTC stamp>.sql, then prunes expired dumps by the stamp in
//   their filename. Requires the payload database up.

import { execFileSync } from "node:child_process";
import {
  mkdirSync,
  readdirSync,
  readFileSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";

const backupsDir = process.argv[2] ?? "backups";
const policy = JSON.parse(readFileSync("db/deletion-policy.json", "utf8"));
const retentionDays = policy.backup_retention_days;
if (!Number.isInteger(retentionDays) || retentionDays <= 0) {
  console.error(
    `backup: db/deletion-policy.json backup_retention_days must be a ` +
      `positive integer, got ${JSON.stringify(retentionDays)}`,
  );
  process.exit(1);
}

mkdirSync(backupsDir, { recursive: true });

const stamp = new Date()
  .toISOString()
  .replace(/\.\d{3}Z$/, "Z")
  .replaceAll(":", "-"); // filename-safe UTC stamp, second precision
const file = join(backupsDir, `payload-${stamp}.sql`);

const dump = execFileSync(
  "docker",
  [
    "compose",
    "exec",
    "-T",
    "payload",
    "pg_dump",
    "-U",
    "identity",
    "-d",
    "payload",
  ],
  { encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 },
);
writeFileSync(file, dump);
console.log(`backup: wrote ${file}`);

// Retention: the stamp in the filename is the record of when the dump
// was taken (an mtime survives neither copy nor restore of the backups
// directory). Anything older than the stated window is removed now.
const cutoff = Date.now() - retentionDays * 24 * 60 * 60 * 1000;
let pruned = 0;
for (const name of readdirSync(backupsDir)) {
  const match = /^payload-(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z)\.sql$/.exec(
    name,
  );
  if (!match) continue;
  const taken = Date.parse(
    match[1].replace(/T(\d{2})-(\d{2})-(\d{2})Z/, "T$1:$2:$3Z"),
  );
  if (taken < cutoff) {
    unlinkSync(join(backupsDir, name));
    console.log(`backup: pruned ${name} (older than ${retentionDays} days)`);
    pruned += 1;
  }
}
console.log(
  `backup: retention ${retentionDays} days enforced, ${pruned} dump(s) pruned`,
);
