// checks/svg-refs.mjs verifies that every SVG <use href="#id"> in a built
// artboard resolves to an id defined in the same file.
//
// Why this exists: a dangling <use> is silent. The element renders as nothing,
// the layout keeps its box, and the screen looks merely sparse. Four artboards
// referenced the provenance swatches with no <defs> block of their own, Grant
// among them, so the marks decision 055 made the sole carrier of provenance
// were absent from the employer's own view and from the record. A fifth did it
// again the same day, after the shared partial existed. Reading did not catch
// any of them; rendering caught two, and only because someone looked at the
// right row. Decision 060's sibling: a reference to something that does not
// exist should fail the build, not the reader.
//
// Usage: node checks/svg-refs.mjs [glob-root]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const root = process.argv[2] ?? "design/10-worker-app-screens";

function* built(dir) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) continue;
    if (name.endsWith(".dc.html")) yield p;
  }
}

const failures = [];
let scanned = 0;
for (const file of built(root)) {
  scanned++;
  const text = readFileSync(file, "utf8");
  const defined = new Set([...text.matchAll(/\bid=["']([^"']+)["']/g)].map((m) => m[1]));
  const seen = new Set();
  for (const m of text.matchAll(/<use\b[^>]*\bhref=["']#([^"']+)["']/g)) {
    if (defined.has(m[1]) || seen.has(m[1])) continue;
    seen.add(m[1]);
    failures.push(`${file}: <use href="#${m[1]}"> resolves to nothing in this file`);
  }
}

for (const f of failures) console.error(`FAIL ${f}`);
console.log(
  failures.length
    ? `svg-refs: ${failures.length} dangling reference(s) in ${scanned} artboard(s)`
    : `svg-refs: every <use> resolves (${scanned} artboards scanned)`,
);
process.exit(failures.length ? 1 : 0);
