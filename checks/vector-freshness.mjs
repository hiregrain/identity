// checks/vector-freshness.mjs proves the committed golden vectors are what
// the generator produces right now (trust-kernel/01).
//
// Why this is a check and not only a Go test. The vectors live outside the
// `core` module, so `go test` does not treat them as inputs to the package
// that reads them. With a warm build cache, `make go-check` reports
// `ok ... cmd/vectors (cached)` and never opens the files, and
// `actions/setup-go` caches by default, so CI has the same window. A
// semantic edit is still caught, because the TypeScript runner has no such
// cache. A NON-semantic edit is caught by neither: renaming a case leaves
// both language runners green while the file no longer matches a fresh
// generation. This check closes that window, because `go run` executes the
// generator every time and this program reads the committed bytes every
// time. Recorded in log/2026-08-21-trust-kernel-01-verification.md,
// finding 1.
//
// The comparison is bytes, not meaning. The generator writes stably
// ordered, indented JSON with a trailing newline, so any difference at all
// (a renamed case, a reordered member, a stray space) is a difference.
//
// Usage: node checks/vector-freshness.mjs [vectors-dir]
// Needs the Go toolchain. No database.

import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const VECTORS = process.argv[2] ?? "contract/vectors";
const FILES = ["canonicalization.json", "sign-verify.json"];

const fresh = mkdtempSync(join(tmpdir(), "grain-vectors-"));
try {
  const generated = spawnSync(
    "go",
    ["run", "./cmd/vectors", "generate", fresh],
    { cwd: "core", encoding: "utf8" },
  );
  if (generated.error) {
    fail(`cannot run the generator: ${generated.error}`);
  }
  if (generated.status !== 0) {
    fail(
      `the generator exited ${generated.status}: ${generated.stderr.trim()}`,
    );
  }

  const stale = [];
  for (const name of FILES) {
    const committed = readFileSync(join(VECTORS, name));
    const regenerated = readFileSync(join(fresh, name));
    if (!committed.equals(regenerated)) {
      stale.push(
        `${join(VECTORS, name)}: ${committed.length} bytes committed, ` +
          `${regenerated.length} bytes regenerated, and they differ`,
      );
    }
  }

  if (stale.length > 0) {
    for (const entry of stale) console.error(`FAIL vector-freshness: ${entry}`);
    console.error(
      "FAIL vector-freshness: run `make vectors` and commit the result",
    );
    process.exit(1);
  }
  console.log(
    `vector-freshness: ${VECTORS} is byte-identical to a fresh generation (${FILES.join(", ")})`,
  );
} finally {
  rmSync(fresh, { recursive: true, force: true });
}

function fail(message) {
  console.error(`FAIL vector-freshness: ${message}`);
  rmSync(fresh, { recursive: true, force: true });
  process.exit(1);
}
