// checks/decisions-index.mjs enforces decisions/LOG.md entry numbering
// (foundation/06, adapted from Dispatch). The log is append-only and
// numbered; a reversal is a new entry, never an edit. What a file
// snapshot can prove of that:
//
//   * no entry number appears twice;
//   * the numbers form an unbroken run from 001 to the highest. A
//     missing number is an entry that was silently removed or never
//     written, both of which append-only forbids.
//   * EXCEPT a number the log itself marks as never assigned. One such
//     gap exists deliberately: 029/030 were consumed in the 2026-08-19
//     two-checkout collision, and an italic note between 028 and 031
//     records the gap as permanent. The check keys on that note's form,
//     an emphasized paragraph "*Numbers NNN and NNN were never
//     assigned. …*", so a marked gap passes and an unmarked one still
//     fails. A marked number that nonetheless has an entry is a
//     contradiction and fails too.
//
// File ORDER of entries is deliberately not checked: entries 012–014
// stand out of numeric order on main, frozen there because rewriting a
// published log costs more than the inconsistency (ORDER.md's grammar
// binds forward only). Numbering, not position, is what evidence cites.
//
// Usage: node checks/decisions-index.mjs [log-file]
// Dependency-free Node, no database.

import { readFileSync } from "node:fs";

const logFile = process.argv[2] ?? "decisions/LOG.md";
const text = readFileSync(logFile, "utf8");
const failures = [];

// --- entries ------------------------------------------------------------

const seen = new Map(); // number -> heading line
for (const match of text.matchAll(/^## (\d{3}) — .+$/gm)) {
  const number = Number(match[1]);
  if (seen.has(number)) {
    failures.push(
      `${logFile}: entry ${match[1]} appears twice ("${seen.get(number)}" ` +
        `and "${match[0]}"). The log is append-only and numbered, a ` +
        `number is used once`,
    );
  } else {
    seen.set(number, match[0]);
  }
}
if (seen.size === 0) {
  failures.push(`${logFile}: no "## NNN — " entry headings found`);
}

// --- never-assigned markers ---------------------------------------------

const neverAssigned = new Set();
for (const match of text.matchAll(
  /^\*Numbers?\s+([\d\s,and]+?)\s+(?:was|were)\s+never\s+assigned\./gm,
)) {
  for (const number of match[1].matchAll(/\d{3}/g)) {
    neverAssigned.add(Number(number[0]));
  }
}

// --- the run is unbroken except where marked ----------------------------

const max = Math.max(0, ...seen.keys());
for (let number = 1; number <= max; number++) {
  const padded = String(number).padStart(3, "0");
  if (seen.has(number)) {
    if (neverAssigned.has(number)) {
      failures.push(
        `${logFile}: entry ${padded} exists but the log marks it "never ` +
          `assigned". The marker and the entry contradict each other`,
      );
    }
  } else if (!neverAssigned.has(number)) {
    failures.push(
      `${logFile}: entry ${padded} is missing and not marked never ` +
        `assigned. An unmarked gap in an append-only numbered log means ` +
        `an entry was lost or a number was skipped silently`,
    );
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `decisions-index: entries 001..${String(max).padStart(3, "0")} are ` +
    `unbroken (${seen.size} entries` +
    (neverAssigned.size > 0
      ? `; ${[...neverAssigned]
          .sort((a, b) => a - b)
          .map((n) => String(n).padStart(3, "0"))
          .join(", ")} marked never assigned`
      : "") +
    `), no duplicates`,
);
