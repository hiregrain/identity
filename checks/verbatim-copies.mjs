// checks/verbatim-copies.mjs diffs labeled constraint blockquotes
// exactly against their sources (foundation/06, ported from Dispatch).
// In Dispatch this check is the precondition for quoting any constraint
// into a plan file: a labeled blockquote is an exact copy, `[…]` marks a
// deliberate splice, and commentary sits outside the quote. Identity's
// plan files today carry pointers rather than quotes, so the check has
// nothing to fail on. It is ported anyway, because its absence is what
// makes quoting look free.
//
// The label grammar (this check's contract; the Dispatch source was not
// carried in the handoff, so the grammar is restated here and binds
// forward):
//
//   > **Verbatim from `<repo-relative-path>`:**
//   >
//   > quoted lines …
//
// Every `> `-prefixed line after the label (until the blockquote ends)
// is the quote. The quote, split on `[…]`, must appear in the named file
// as exact substrings in order. Failures: the label names a missing
// file, a segment does not appear verbatim, or segments appear out of
// order. Unlabeled blockquotes are ordinary prose and are not checked.
//
// Usage: node checks/verbatim-copies.mjs [scanRoot...]
//   Defaults to the documentation trees where constraints get quoted:
//   plans, model, design, decisions, THESIS.md, DESIGN.md, CLAUDE.md.
//   Source paths in labels resolve from the repo root. Dependency-free
//   Node, no database.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const LABEL = /^> \*\*Verbatim from `([^`]+)`:\*\*\s*$/;
const SPLICE = "[…]";

const roots =
  process.argv.length > 2
    ? process.argv.slice(2)
    : [
        "plans",
        "model",
        "design",
        "decisions",
        "THESIS.md",
        "DESIGN.md",
        "CLAUDE.md",
      ];

const failures = [];
let quotesChecked = 0;

for (const root of roots) {
  if (!existsSync(root)) continue;
  if (statSync(root).isDirectory()) walk(root);
  else if (root.endsWith(".md")) checkFile(root);
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `verbatim-copies: ${quotesChecked} labeled blockquote(s) diff exactly ` +
    `against their sources`,
);

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || entry.name === "node_modules") continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) walk(path);
    else if (entry.name.endsWith(".md")) checkFile(path);
  }
}

function checkFile(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  for (let i = 0; i < lines.length; i++) {
    const label = LABEL.exec(lines[i]);
    if (!label) continue;
    quotesChecked += 1;
    const source = label[1];

    // Collect the rest of the blockquote as the quote body.
    const body = [];
    for (let j = i + 1; j < lines.length; j++) {
      if (!lines[j].startsWith(">")) break;
      body.push(lines[j].replace(/^> ?/, ""));
      i = j;
    }
    while (body.length > 0 && body[0].trim() === "") body.shift();
    while (body.length > 0 && body[body.length - 1].trim() === "") body.pop();

    if (!existsSync(source)) {
      failures.push(
        `${path}: verbatim label names "${source}", which does not exist. ` +
          `A labeled blockquote is an exact copy of a real source`,
      );
      continue;
    }
    if (body.length === 0) {
      failures.push(
        `${path}: verbatim label for "${source}" has no quoted lines under it`,
      );
      continue;
    }

    const sourceText = readFileSync(source, "utf8");
    const segments = body.join("\n").split(SPLICE);
    let cursor = 0;
    for (const rawSegment of segments) {
      const segment = rawSegment.replace(/^\s+|\s+$/g, "");
      if (segment === "") continue;
      const at = sourceText.indexOf(segment, cursor);
      if (at === -1) {
        const anywhere = sourceText.indexOf(segment) !== -1;
        failures.push(
          `${path}: quote labeled "Verbatim from ${source}" ` +
            (anywhere
              ? `has segments out of order. ${SPLICE} splices must ` +
                `preserve source order`
              : `is not an exact copy: segment starting ` +
                `"${segment.slice(0, 60)}" does not appear in the source. ` +
                `Fix the quote or drop the Verbatim label`),
        );
        break;
      }
      cursor = at + segment.length;
    }
  }
}
