// checks/counts.mjs flags a hand-written count of a checkable thing
// outside a closed record (CLAUDE.md, foundation/06). "All six layers",
// "seventeen layers", "three objects". Every such count in this repo
// drifted or was wrong within days of being written. The rule is to say
// "every layer", point at the table, or let a check count.
//
// What is flagged, precisely: a numeral or number-word followed by a
// plural noun (one optional modifier between them) naming a CHECKABLE
// repo structure. Layers, tasks, criteria, checks, migrations,
// decisions, and their kin, the enumerated vocabulary below, inside the
// paragraph or heading that IMMEDIATELY precedes an enumerable
// structure: a table, a bulleted or numbered list, or a fenced listing.
// Both narrowings are deliberate and were tuned against the real tree:
//
//   * adjacency, because that is where the prose counts the very thing
//     the structure enumerates, the count that drifts when the
//     structure changes;
//   * the noun vocabulary, because "checkable things" is the rule's own
//     scope (CLAUDE.md): a count of repo structures a check can recount
//     ("all six layers") drifts silently, while prose counts of
//     non-mechanical things ("six steps", "~95 marks inspected", "two
//     agents") are ordinary writing that this check has no authority
//     over. A wolf-crying variant without the vocabulary flagged twelve
//     legitimate phrases on the day it was written.
//
// Scanned: plans/, model/, DESIGN.md, the READMEs outside frozen trees,
// and the leading `--` comment header of every db/migrations/**/*.sql
// file (the SQL statements after it are not prose and are not scanned).
// Excluded, as closed records whose counts are frozen facts:
// decisions/LOG.md (not in the scanned trees), discharged spikes (a
// "**Discharged" banner in the file head), handoff/ (Dispatch's frozen
// package), and blockquotes (quotes of other documents). "One"/"1" is
// not flagged: a count of one does not enumerate.
//
// Usage: node checks/counts.mjs [root-or-file...]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";

const NUMBER_WORDS =
  "two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|" +
  "fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|" +
  "[2-9]|[1-9][0-9]";
// The checkable-structure vocabulary: things a check can recount from
// the tree itself. Extend it when a new checkable structure appears;
// nouns outside it are prose, not bookkeeping.
const CHECKABLE_NOUNS =
  "layers?|tasks?|criteri(?:a|on)|checks?|migrations?|decisions?|" +
  "entr(?:ies|y)|gates?|objects?|fields?|columns?|tables?|schemas?|" +
  "domains?|planes?|databases?|roles?|packages?|stages?|jobs?|" +
  "fixtures?|milestones?|exemptions?|exceptions?";
// number-word + (optional single modifier) + checkable plural noun,
// e.g. "six layers", "three spine objects", "17 open gates".
const COUNT = new RegExp(
  `\\b(?:all\\s+|the\\s+)?(${NUMBER_WORDS})\\s+(?:[a-z][a-z-]*\\s+)?` +
    `(${CHECKABLE_NOUNS})\\b`,
  "gi",
);

const roots =
  process.argv.length > 2
    ? process.argv.slice(2)
    : ["plans", "model", "DESIGN.md", "db/migrations", ...findReadmes(".")];

const failures = [];
let filesScanned = 0;

for (const root of roots) {
  if (!existsSync(root)) continue;
  if (statSync(root).isDirectory()) walk(root);
  else if (root.endsWith(".sql")) checkSqlMigrationHeader(root);
  else checkFile(root);
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `counts: ${filesScanned} file(s) carry no hand-written count adjacent ` +
    `to an enumerable structure`,
);

function findReadmes(root) {
  const skipped = new Set(["node_modules", "handoff", "test", ".git"]);
  const out = [];
  (function descend(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.name.startsWith(".") || skipped.has(entry.name)) continue;
      const path = join(dir, entry.name);
      if (entry.isDirectory()) descend(path);
      else if (entry.name === "README.md") out.push(path);
    }
  })(root);
  return out;
}

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || entry.name === "node_modules") continue;
    const path = join(dir, entry.name);
    if (entry.isDirectory()) walk(path);
    else if (entry.name.endsWith(".md")) checkFile(path);
    else if (entry.name.endsWith(".sql")) checkSqlMigrationHeader(path);
  }
}

// A migration's header is its leading run of `--` comment lines (blank
// comment lines included); the SQL statements after it are not prose
// and are not scanned. Reuses checkFile's list/table adjacency logic
// against the stripped header text.
function checkSqlMigrationHeader(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  const header = []; // [lineNumber, strippedText]
  for (const [i, line] of lines.entries()) {
    if (line.startsWith("--")) {
      header.push([i + 1, line.replace(/^--\s?/, "")]);
    } else if (line.trim() === "" && header.length > 0) {
      header.push([i + 1, ""]);
    } else {
      break;
    }
  }
  if (header.length === 0) return;
  filesScanned += 1;

  let paragraph = [];
  for (let i = 0; i < header.length; i++) {
    const [lineNumber, text] = header[i];
    if (text.trim() === "") continue;
    if (/^\s*([-*+]\s|\d+\.\s)/.test(text)) {
      flagAdjacent(path, paragraph, "a list");
      paragraph = [];
      while (
        i + 1 < header.length &&
        (/^\s*([-*+]\s|\d+\.\s|\s{2,}\S)/.test(header[i + 1][1]) ||
          header[i + 1][1].trim() === "")
      ) {
        if (
          header[i + 1][1].trim() !== "" ||
          (i + 2 < header.length &&
            /^\s*([-*+]\s|\d+\.\s)/.test(header[i + 2][1]))
        ) {
          i++;
        } else break;
      }
      continue;
    }
    if (/^\s*\|/.test(text)) {
      flagAdjacent(path, paragraph, "a table");
      paragraph = [];
      while (i + 1 < header.length && /^\s*\|/.test(header[i + 1][1])) i++;
      continue;
    }
    if (paragraph.length > 0 && header[i - 1]?.[1]?.trim() === "")
      paragraph = [];
    paragraph.push([lineNumber, text]);
  }
}

function checkFile(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  const head = lines.slice(0, 10).join("\n");
  if (head.includes("**Discharged")) return; // a discharged spike is closed
  filesScanned += 1;

  // Strip frontmatter.
  let start = 0;
  if (lines[0] === "---") {
    const end = lines.indexOf("---", 1);
    if (end !== -1) start = end + 1;
  }

  let inFence = false;
  let paragraph = []; // [lineNumber, text] of the running prose block
  for (let i = start; i < lines.length; i++) {
    const line = lines[i];
    if (/^\s*(```|~~~)/.test(line)) {
      if (!inFence) flagAdjacent(path, paragraph, "a fenced listing");
      inFence = !inFence;
      paragraph = [];
      continue;
    }
    if (inFence) continue;
    if (line.trim() === "") {
      // Blank line: the paragraph survives to be tested against the
      // next structural line, so do not reset it here.
      continue;
    }
    if (line.startsWith(">")) {
      paragraph = []; // blockquotes are quoted, frozen prose
      continue;
    }
    if (/^\s*([-*+]\s|\d+\.\s)/.test(line)) {
      flagAdjacent(path, paragraph, "a list");
      paragraph = [];
      // Consume the whole list so its items are not treated as prose.
      while (
        i + 1 < lines.length &&
        (/^\s*([-*+]\s|\d+\.\s|\s{2,}\S)/.test(lines[i + 1]) ||
          lines[i + 1].trim() === "")
      ) {
        if (
          lines[i + 1].trim() !== "" ||
          (i + 2 < lines.length && /^\s*([-*+]\s|\d+\.\s)/.test(lines[i + 2]))
        ) {
          i++;
        } else break;
      }
      continue;
    }
    if (/^\s*\|/.test(line)) {
      flagAdjacent(path, paragraph, "a table");
      paragraph = [];
      while (i + 1 < lines.length && /^\s*\|/.test(lines[i + 1])) i++;
      continue;
    }
    // Ordinary prose or heading: extend/replace the running paragraph.
    if (paragraph.length > 0 && lines[i - 1]?.trim() === "") paragraph = [];
    paragraph.push([i + 1, line]);
  }
}

function flagAdjacent(path, paragraph, structure) {
  for (const [lineNumber, rawLine] of paragraph) {
    const line = rawLine.replace(/`[^`]*`/g, "`code`"); // inline code is not prose
    COUNT.lastIndex = 0;
    for (const match of line.matchAll(COUNT)) {
      failures.push(
        `${path}:${lineNumber}: "${match[0].trim()}" is a hand-written ` +
          `count immediately preceding ${structure}; say "every", point ` +
          `at the structure, or let a check count (CLAUDE.md)`,
      );
    }
  }
}
