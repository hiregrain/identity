// The fixture carries the load the spike claims to be putting on the renderer.
//
// Without this, "23,585 path commands" is a sentence in a README and the
// harness could quietly ship a sparse figure that proves nothing. The counts
// below are read out of the committed bytes, and `pnpm run fixture`
// regenerates those bytes from `imprint/imprint.py`.

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import test from "node:test";

const PACKAGE_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const fixture = JSON.parse(
  readFileSync(
    join(PACKAGE_ROOT, "fixtures", "imprint-worst-case.json"),
    "utf8",
  ),
);

// The figure at 360 CSS px on a 3x screen, held at 2x pinch. See
// fixtures/generate.py for why this is the load rather than 360 px at rest.
const EXPECTED_VERTICES = 23585;
const EXPECTED_THREADS = 89;

test("the fixture is the densest reference record at the pinched size", () => {
  assert.equal(fixture.case, "12-profile-warehouse");
  assert.equal(fixture.size, 720);
  assert.equal(fixture.dpr, 3);
});

test("the fixture carries the vertex count the spike is for", () => {
  assert.equal(fixture.paths.length, EXPECTED_THREADS);
  assert.equal(fixture.vertices, EXPECTED_VERTICES);
});

test("the declared vertex count is the one the path data actually contains", () => {
  // Counting command letters is exact only because imprint.py emits absolute
  // M and C and a trailing Z, and never L, relative commands, or the shorthand
  // (S/T/A). This guards that assumption so the count cannot silently drift if
  // the generator's emission changes: any command letter outside MCZ fails.
  for (const [index, d] of fixture.paths.entries()) {
    const foreign = d.match(/[A-Za-z]/g)?.filter((c) => !"MCZ".includes(c));
    assert.equal(
      foreign?.length ?? 0,
      0,
      `thread ${index} carries a command outside M/C/Z: ${foreign?.join("")}`,
    );
  }
  const counted = fixture.paths.reduce(
    (total, d) => total + (d.match(/[MLC]/g) ?? []).length,
    0,
  );
  assert.equal(counted, EXPECTED_VERTICES);
});

test("every thread is a closed path of cubics from a single move", () => {
  for (const [index, d] of fixture.paths.entries()) {
    assert.match(
      d,
      /^M-?[\d.]+ -?[\d.]+C/,
      `thread ${index} does not open with a move`,
    );
    assert.match(d, /Z$/, `thread ${index} is not closed`);
    assert.equal(
      (d.match(/M/g) ?? []).length,
      1,
      `thread ${index} has more than one subpath`,
    );
  }
});

test("stroke is a device-pixel hairline, per decision 044", () => {
  assert.equal(fixture.strokePx, 1);
});
