// checks/decision-citations.mjs verifies that every citation of a
// decisions/LOG.md entry points at an entry that exists.
//
// Why this exists: decision numbers 029 and 030 were consumed in the
// 2026-08-19 two-checkout collision and never assigned, and the log carries an
// italic note saying so. Four worker-app templates nevertheless cited "029 §B1",
// "029 §B4", "029 §A" and "decision 030" for a year of edits, and an outside
// review then argued from "029 §B4" as if it were authority. The rulings were
// real; they live at 035 and 036. A citation to a number the log never assigned
// is unfalsifiable, and reading cannot catch it because the number looks
// plausible. Decision 060.
//
// Two high-precision patterns, chosen so design-document references do not trip
// it. This repo cites design docs with two digits (`design/07 §3`, `06 §9`) and
// decisions with three (`decision 035`, `035 §B4`), so requiring three digits
// separates them:
//
//   * `decision 035` / `decisions 035` / `entry 035`
//   * `035 §B4`, three digits immediately before a section sign
//
// Known limit, stated rather than hidden: a bare parenthesised `(029)` with no
// section sign and no "decision" prefix is not matched, because `(402)` and
// `(320)` appear all over the design tree as pixel values and the false-positive
// rate would make the check useless. Two of the five citations this was written
// for had that shape and were fixed by reading. Widening the pattern needs a
// convention that a bare number in parentheses is never a citation.
//
// Usage: node checks/decision-citations.mjs [root...]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const LOG = "decisions/LOG.md";
const ROOTS = process.argv.length > 2 ? process.argv.slice(2)
  : ["design", "plans", "model", "imprint", "mark", "copy", "CLAUDE.md", "THESIS.md", "DESIGN.md"];
const SKIP = new Set(["node_modules", ".git", ".claude", "handoff", "research", "counsel"]);
const TEXT = /\.(md|tpl|part|py|mjs|js|ts|tsx|json|html|css|txt|yml|yaml)$/;

const log = readFileSync(LOG, "utf8");
const assigned = new Set([...log.matchAll(/^## (\d{3}) — /gm)].map((m) => m[1]));
const never = new Set(
  [...log.matchAll(/\*Numbers (\d{3}) and (\d{3}) were never assigned\./g)]
    .flatMap((m) => [m[1], m[2]]),
);

const CITES = [/\b(?:decisions?|entry|entries)\s+(\d{3})\b/g, /\b(\d{3})\s*§/g];

function* files(root) {
  let st;
  try { st = statSync(root); } catch { return; }
  if (st.isFile()) { if (TEXT.test(root)) yield root; return; }
  for (const name of readdirSync(root)) {
    if (SKIP.has(name)) continue;
    yield* files(join(root, name));
  }
}

const failures = [];
let scanned = 0;
for (const root of ROOTS) {
  for (const file of files(root)) {
    if (relative(".", file) === LOG) continue;
    scanned++;
    const lines = readFileSync(file, "utf8").split("\n");
    lines.forEach((line, i) => {
      for (const re of CITES) {
        re.lastIndex = 0;
        for (const m of line.matchAll(re)) {
          const n = m[1];
          if (assigned.has(n)) continue;
          const why = never.has(n)
            ? `entry ${n} was never assigned (the log records the gap as permanent)`
            : `entry ${n} does not exist in ${LOG}`;
          failures.push(`${file}:${i + 1}: cites "${m[0].trim()}" but ${why}`);
        }
      }
    });
  }
}

for (const f of failures) console.error(`FAIL ${f}`);
console.log(
  failures.length
    ? `decision-citations: ${failures.length} bad citation(s) in ${scanned} file(s)`
    : `decision-citations: every cited entry exists (${scanned} file(s) scanned, ${assigned.size} entries assigned, ${never.size} permanently unassigned)`,
);
process.exit(failures.length ? 1 : 0);
