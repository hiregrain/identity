// test/cross-plane-outbox.test.mjs proves the cross-plane write consistency
// scenarios (foundation/07; layer criterion foundation-5).
//
// Drives the real worker binary (core/cmd/outbox, built here) against
// both live planes and proves, in order:
//
//   1. Enqueue is atomic on the spine: a crash before the spine commit
//      leaves nothing on either plane.
//   2. A crash between the spine commit and the payload apply is
//      recoverable: the entry sits pending, a restarted worker
//      completes it with no operator action and no duplicate.
//   3. A crash inside the payload transaction leaves the payload plane
//      untouched; restart completes.
//   4. A crash after the payload commit but before the acknowledgment
//      row: restart re-applies as a no-op (one payload row, by count)
//      and acknowledges.
//   5. Manual replay: applying an already-acknowledged entry twice more
//      produces one payload row, asserted by row count.
//   6. A permanently failing apply surfaces through the reconciler
//      within its threshold, producing a queue-item line per entry and a
//      non-zero exit. Recovery is forward-only: fix the cause,
//      drain again, reconciler goes quiet.
//   7. Nothing acknowledges before both planes are durable: with the
//      payload apply artificially stalled (an owner transaction holding
//      an exclusive lock on the target table), the entry never appears
//      in cross_plane_acknowledged; when the stall lifts, the same
//      worker run completes and the acknowledgment appears.
//
// The payload plane deliberately has no product content tables yet
// (foundation/05 owns the DEK registry; later layers own content), so
// the apply target is a test-scoped table created and dropped here,
// carrying the two columns the outbox mechanism requires of any target:
// a UNIQUE `outbox_entry_id spine_object_id` (the idempotency key) and
// `residency_region` NOT NULL (foundation/04). Probe objects are
// dropped on the green path; on a failure the next `make db-reset`
// rebuilds from empty.
//
// Usage: node test/cross-plane-outbox.test.mjs
// Requires both databases up and migrated, Docker, and Go.

import { execFileSync, spawn } from "node:child_process";
import { randomUUID } from "node:crypto";
import { setTimeout as delay } from "node:timers/promises";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const TARGET = "outbox_probe_target";
let assertions = 0;

// --- helpers -----------------------------------------------------------

function psql(plane, user, query) {
  const args = [
    "compose",
    "exec",
    "-T",
    plane,
    "psql",
    "-v",
    "ON_ERROR_STOP=1",
    "-U",
    user,
    "-d",
    plane,
    "-tA",
    "-c",
    query,
  ];
  try {
    return execFileSync("docker", args, {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch (error) {
    console.error(error.stderr?.toString() ?? error.message);
    throw error;
  }
}

const owner = (plane, query) => psql(plane, "identity", query);
const app = (plane, query) => psql(plane, "identity_app", query);

function worker(args, { stdin, expectExit = 0 } = {}) {
  try {
    const out = execFileSync(binary, args, {
      encoding: "utf8",
      input: stdin,
      stdio: ["pipe", "pipe", "pipe"],
    });
    assert(
      expectExit === 0,
      `worker ${args.join(" ")} exited 0, wanted ${expectExit}`,
    );
    return out;
  } catch (error) {
    assert(
      error.status === expectExit,
      `worker ${args.join(" ")} exited ${error.status}, wanted ${expectExit}` +
        `\n${error.stderr?.toString() ?? ""}`,
    );
    return (error.stdout?.toString() ?? "") + (error.stderr?.toString() ?? "");
  }
}

function assert(condition, message) {
  assertions += 1;
  if (!condition) {
    console.error(`FAIL ${message}`);
    process.exitCode = 1;
    throw new Error(message);
  }
  console.log(`  ok: ${message}`);
}

const rowCount = (id) =>
  Number(
    app(
      "payload",
      `SELECT count(*) FROM ${TARGET} WHERE outbox_entry_id = '${id}'`,
    ),
  );
const acked = (id) =>
  app(
    "spine",
    `SELECT count(*) FROM cross_plane_acknowledged WHERE entry_id = '${id}'`,
  ) === "1";
const outboxCount = () =>
  Number(app("spine", "SELECT count(*) FROM cross_plane_outbox"));
const instruction = (content) =>
  JSON.stringify({ table: TARGET, row: { content } });
const enqueue = (id, json, extra = []) =>
  worker(["enqueue", "-entry-id", id, ...extra], {
    stdin: json,
    expectExit: extra.length ? 3 : 0,
  });
const sleep = delay;

// --- setup: build the worker, create the test-scoped target -----------

const buildDir = mkdtempSync(join(tmpdir(), "outbox-"));
const binary = join(buildDir, "outbox");
console.log("setup: building core/cmd/outbox");
execFileSync("go", ["build", "-o", binary, "./cmd/outbox"], {
  cwd: "core",
  stdio: "inherit",
});

owner("payload", `DROP TABLE IF EXISTS ${TARGET}`);
owner("payload", "DROP TABLE IF EXISTS outbox_probe_missing");
owner(
  "payload",
  `CREATE TABLE ${TARGET} (
     outbox_entry_id spine_object_id NOT NULL UNIQUE,
     residency_region residency_region NOT NULL DEFAULT 'us',
     content text NOT NULL
   )`,
);

try {
  // --- 1. enqueue atomicity -------------------------------------------
  console.log(
    "\nscenario 1: a crash before the spine commit leaves nothing anywhere",
  );
  const before = outboxCount();
  const a = randomUUID();
  enqueue(a, instruction("atomicity probe"), [
    "-crash-point",
    "before-spine-commit",
  ]);
  assert(
    outboxCount() === before,
    "spine outbox unchanged after pre-commit crash",
  );
  assert(rowCount(a) === 0, "payload untouched after pre-commit crash");

  // --- 2. kill between spine commit and payload apply -----------------
  console.log(
    "\nscenario 2: crash between spine commit and payload apply is completed by restart",
  );
  enqueue(a, instruction("recovered write"));
  assert(outboxCount() === before + 1, "spine commit recorded the entry");
  worker(["drain", "-crash-point", "before-payload-apply"], { expectExit: 3 });
  assert(rowCount(a) === 0, "payload untouched at the crash point");
  assert(!acked(a), "entry not acknowledged while only the spine is durable");
  worker(["drain"]);
  assert(
    rowCount(a) === 1,
    "restarted worker completed the payload apply, no operator action",
  );
  assert(acked(a), "entry acknowledged once both planes are durable");
  worker(["drain"]);
  assert(rowCount(a) === 1, "a further drain adds no duplicate");

  // --- 3. crash inside the payload transaction ------------------------
  console.log(
    "\nscenario 3: crash inside the payload transaction leaves payload untouched",
  );
  const b = randomUUID();
  enqueue(b, instruction("mid-transaction probe"));
  worker(["drain", "-crash-point", "mid-payload-apply"], { expectExit: 3 });
  assert(rowCount(b) === 0, "aborted payload transaction kept nothing");
  assert(!acked(b), "no acknowledgment for an aborted apply");
  worker(["drain"]);
  assert(
    rowCount(b) === 1 && acked(b),
    "restart completed and acknowledged the entry",
  );

  // --- 4. crash after payload commit, before the ack row --------------
  console.log(
    "\nscenario 4: crash after payload commit re-applies as a no-op, then acknowledges",
  );
  const c = randomUUID();
  enqueue(c, instruction("post-commit probe"));
  worker(["drain", "-crash-point", "after-payload-apply"], { expectExit: 3 });
  assert(rowCount(c) === 1, "payload row durable at the crash point");
  assert(
    !acked(c),
    "not acknowledged before the spine acknowledgment row exists",
  );
  worker(["drain"]);
  assert(
    rowCount(c) === 1,
    "restart produced no duplicate payload row (by count)",
  );
  assert(acked(c), "restart acknowledged the completed entry");

  // --- 5. manual replay is idempotent by row count --------------------
  console.log(
    "\nscenario 5: manually applying the same entry twice produces one payload row",
  );
  worker(["apply", "-entry-id", c]);
  worker(["apply", "-entry-id", c]);
  assert(
    rowCount(c) === 1,
    "two manual replays, one payload row, asserted by count",
  );

  // --- 6. permanent failure surfaces through the reconciler -----------
  console.log(
    "\nscenario 6: a permanently failing apply surfaces; recovery is forward-only",
  );
  const d = randomUUID();
  enqueue(
    d,
    JSON.stringify({
      table: "outbox_probe_missing",
      row: { content: "straggler" },
    }),
  );
  worker(["drain"]);
  worker(["drain"]);
  const attempts = Number(
    app(
      "spine",
      `SELECT count(*) FROM cross_plane_outbox_attempts WHERE entry_id = '${d}' AND state = 'failed'`,
    ),
  );
  assert(attempts === 2, "each failed attempt recorded as a following row");
  const report = worker(["reconcile", "-threshold", "0"], { expectExit: 1 });
  assert(
    report.includes(d) && report.includes("QUEUE"),
    "reconciler lists the entry as a queue item",
  );
  assert(
    report.includes("ALERT"),
    "reconciler raises the alert line and exits non-zero",
  );
  owner(
    "payload",
    `CREATE TABLE outbox_probe_missing (
       outbox_entry_id spine_object_id NOT NULL UNIQUE,
       residency_region residency_region NOT NULL DEFAULT 'us',
       content text NOT NULL
     )`,
  );
  worker(["drain"]);
  assert(
    acked(d),
    "forward fix + drain completed the straggler, no compensation path",
  );
  worker(["reconcile", "-threshold", "0"]);
  console.log("  ok: reconciler is quiet again (exit 0)");
  assertions += 1;

  // --- 7. nothing acknowledges before both planes are durable ---------
  console.log(
    "\nscenario 7: with the payload apply stalled, no acknowledgment appears",
  );
  const e = randomUUID();
  enqueue(e, instruction("stalled write"));
  // The stall: an owner transaction holds an exclusive lock on the
  // target table for 6 seconds, so the worker's INSERT blocks inside
  // the payload plane, durable nowhere until the lock lifts.
  const stall = spawn(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      "payload",
      "psql",
      "-v",
      "ON_ERROR_STOP=1",
      "-U",
      "identity",
      "-d",
      "payload",
      "-c",
      `BEGIN; LOCK TABLE ${TARGET} IN ACCESS EXCLUSIVE MODE; SELECT pg_sleep(6); COMMIT;`,
    ],
    { stdio: "ignore" },
  );
  const stallDone = new Promise((resolve) => stall.on("exit", resolve));
  await sleep(1000); // let the lock land
  const drain = spawn(binary, ["drain"], { stdio: "ignore" });
  const drainDone = new Promise((resolve) => drain.on("exit", resolve));
  await sleep(2500); // worker is now blocked inside the payload apply
  assert(drain.exitCode === null, "worker is stalled inside the payload apply");
  assert(!acked(e), "no acknowledgment while the payload apply is stalled");
  const drainExit = await drainDone;
  assert(drainExit === 0, "worker completed once the stall lifted");
  assert(
    rowCount(e) === 1 && acked(e),
    "acknowledgment appeared only after both planes were durable",
  );
  await stallDone;

  console.log(`\ncross-plane-outbox: ${assertions} assertions passed`);
} finally {
  owner("payload", `DROP TABLE IF EXISTS ${TARGET}`);
  owner("payload", "DROP TABLE IF EXISTS outbox_probe_missing");
  rmSync(buildDir, { recursive: true, force: true });
}
