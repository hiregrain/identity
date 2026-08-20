// checks/unslop.mjs enforces the mechanical half of decision 052's prose
// standard (CLAUDE.md "Prose standard"). It flags, anywhere in a scanned
// file: an em
// dash (U+2014), a spaced en dash used as a separator (space, U+2013,
// space), a curly quote (U+2018/2019/201C/201D), an emoji in a markdown
// heading, and the tell words "delve"/"utilize" (word-boundary,
// case-insensitive). Numeric ranges keep their bare en dash untouched,
// because the banned pattern requires the surrounding spaces. The
// judgment patterns (hedging, filler, restating labels) are review
// defects, not mechanical failures, and are out of this check's scope.
//
// SCANNED_ROOTS is the whole repo (the CLAUDE.md commitment), reached
// once the code sweep and the parallel docs sweep both landed. Structural
// exceptions below, markdown-only unless noted, carry documented,
// quoted, or ranged dashes that are not this repo's own prose choice:
// a decisions-log heading, a fenced code block, a linked or cited
// external title, a blockquote, a quoted excerpt (inline or wrapped
// across lines), and a date range (not markdown-only, since dated spans
// also occur in generated UI copy under design/10-worker-app-screens/).
//
// Usage: node checks/unslop.mjs [root-or-file...]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const SCANNED_ROOTS = ["."];

// Always skipped, regardless of which roots are scanned: version control,
// dependencies, restore-scenario scratch space, and the two generated
// trees (typegen output, never hand-written prose).
const EXCLUDED_DIRS = new Set([
  ".git",
  "node_modules",
  "backups",
  "core/gen",
  "db/gen",
]);

// This file is exempt from its own scan, always, however it is invoked.
// Its pattern definitions must hold the literal banned characters and
// the literal tell words to name what they ban; that is code defining a
// rule, not prose slipping past one.
//
// checks/decisions-index.mjs is exempt for the same reason: its parser
// holds the `## NNN — Title` shape as a regex literal and an error
// string, not as a markdown heading line, so the structural skip below
// (a) does not reach it. The markdown fixtures that use that heading
// shape as real headings need no file-level exemption; (a) covers them.
const EXCLUDED_FILES = new Set([
  "checks/unslop.mjs",
  "checks/decisions-index.mjs",
  // Same reason as decisions-index: its parser holds the `## NNN — Title`
  // shape as a regex literal to read the log's entry numbers, which is code
  // defining a rule rather than prose slipping past one (decision 060).
  "checks/decision-citations.mjs",
]);

// This check's own red-path fixture: it exists to fail, and is excluded
// only from the DEFAULT scan (so a bare `node checks/unslop.mjs` stays
// green); `make check-red` invokes it directly by path, which bypasses
// this exclusion, same as every other check's red-path fixtures bypass
// that check's own defaults.
const DEFAULT_SCAN_ONLY_EXCLUDED_FILES = new Set([
  "test/fixtures/redpath/unslop/violations.md",
]);

// Each pattern also matches its JSON/JS \uXXXX escape form: a JSON string
// value commonly encodes a non-ASCII character that way instead of as a
// raw UTF-8 byte, and the escaped form renders identically once parsed.
const TELL_WORDS = /\b(delve|utilize)\b/gi;
const EM_DASH = /—|\\u2014/gi;
const SPACED_EN_DASH = / – | \\u2013 /gi;
const CURLY_QUOTE = /[‘’“”]|\\u201[89cCdD]/gi;
const HEADING_EMOJI =
  /[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{1F1E6}-\u{1F1FF}]/u;

// Structural skips, markdown-only, each a documented shape this repo's
// own prose does not choose: (a) a decisions-log entry heading, the
// exact shape checks/decisions-index.mjs parses; (b) toggled around a
// fenced code block, whose contents are code, not prose; (c) a markdown
// link whose bracketed text quotes an external title verbatim, or a
// bibliography line citing one before its URL; (d) a blockquote, a
// quoted external source.
const FENCE_LINE = /^\s*(```|~~~)/;
const DECISIONS_HEADING = /^## \d{3} — /;
const BLOCKQUOTE_LINE = /^>\s/;
const QUOTED_TITLE_LINE = /\[[^\]]*—[^\]]*\]\(|— (https?:\/\/|via )\S/;
// A straight-quoted or backtick-quoted span containing a dash, opened
// and (usually) closed on the same line: an external title, a real git
// commit subject, or a short verbatim excerpt quoted inline (decision
// 052 targets dashes used as this repo's own separator, not one sitting
// inside a source it quotes). A `"..."` excerpt too long to fit one
// line is caught instead by the inQuote state tracked in checkFile.
const QUOTED_INLINE_TITLE = /"[^"\n]*[—–]|`[^`\n]*[—–]/;
const DOUBLE_QUOTE_CHAR = /"/g;

// Not markdown-gated, because these two shapes also occur in generated
// worker-facing UI copy (design/10-worker-app-screens/*.tpl, *.dc.html):
// a date-range spaced en dash ("Mar 2019 – Sep 2021", "Jan 2025 –
// present") is the numeric-range exemption decision 052 already states,
// generalized to month-year and "present"; a line matching it is
// exempted from the spaced-en-dash pattern specifically, not from every
// pattern, since a date range cannot also carry a curly quote or a
// tell word by construction.
const MONTH_YEAR =
  "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\\.?\\s+(?:19|20)\\d{2}";
const DATE_TOKEN = `(?:${MONTH_YEAR}|(?:19|20)\\d{2})`;
const DATE_RANGE_EN_DASH = new RegExp(
  `${DATE_TOKEN}\\s+–\\s+(?:present\\b|${DATE_TOKEN})`,
  "i",
);

const usingDefaultRoots = process.argv.length <= 2;
const roots = usingDefaultRoots ? SCANNED_ROOTS : process.argv.slice(2);

const failures = [];
let filesScanned = 0;

for (const root of roots) {
  walk(root);
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  console.error(
    `unslop: ${failures.length} violation(s) in ${filesScanned} file(s) scanned`,
  );
  process.exit(1);
}
console.log(
  `unslop: ${filesScanned} file(s) carry none of the banned patterns`,
);

function isExcluded(path) {
  const norm = relative(".", path);
  if (EXCLUDED_FILES.has(norm)) return true;
  if (usingDefaultRoots && DEFAULT_SCAN_ONLY_EXCLUDED_FILES.has(norm))
    return true;
  for (const dir of EXCLUDED_DIRS) {
    if (norm === dir || norm.startsWith(dir + "/")) return true;
  }
  return false;
}

function walk(path) {
  if (isExcluded(path)) return;
  let stats;
  try {
    stats = statSync(path);
  } catch {
    return; // a listed root that does not exist is not this check's problem
  }
  if (stats.isDirectory()) {
    for (const entry of readdirSync(path, { withFileTypes: true })) {
      if (entry.name === ".git" || entry.name === "node_modules") continue;
      walk(join(path, entry.name));
    }
    return;
  }
  checkFile(path);
}

// A file is treated as binary, and skipped, when a NUL byte appears in
// its first 8000 bytes; every text file this check cares about is plain
// UTF-8 source or prose and never contains one.
function isBinary(buffer) {
  const window = buffer.subarray(0, 8000);
  return window.includes(0);
}

function checkFile(path) {
  const buffer = readFileSync(path);
  if (isBinary(buffer)) return;
  const text = buffer.toString("utf8");
  filesScanned += 1;

  const isMarkdown = path.endsWith(".md");
  let inFence = false;
  // An unclosed "..." quotation carried in from an earlier line, for a
  // long verbatim excerpt (a regulatory ruling, a statute) that wraps
  // across several lines. Bounded to one paragraph: a blank line resets
  // it, so a stray unmatched quote cannot leak past where prose resumes.
  let inQuote = false;
  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNumber = i + 1;

    if (isMarkdown && line.trim() === "") inQuote = false;

    if (isMarkdown && FENCE_LINE.test(line)) {
      inFence = !inFence; // (b) toggled around the fence; the marker line itself is not prose either
      continue;
    }
    if (isMarkdown && inFence) continue; // (b) fenced code block content
    if (isMarkdown && DECISIONS_HEADING.test(line)) continue; // (a) decisions-log entry heading
    if (isMarkdown && BLOCKQUOTE_LINE.test(line)) continue; // (d) blockquote, a quoted external source
    if (isMarkdown && QUOTED_TITLE_LINE.test(line)) continue; // (c) linked or cited external title, quoted verbatim

    const startedInQuote = isMarkdown && inQuote;
    if (isMarkdown) {
      const quoteMarks = line.match(DOUBLE_QUOTE_CHAR) ?? [];
      if (quoteMarks.length % 2 === 1) inQuote = !inQuote;
    }
    if (startedInQuote) continue; // a wrapped verbatim excerpt, opened on an earlier line
    if (isMarkdown && QUOTED_INLINE_TITLE.test(line)) continue; // quoted external title or excerpt

    if (EM_DASH.test(line)) {
      failures.push(
        `${path}:${lineNumber}: em dash (U+2014) used as a separator`,
      );
    }
    EM_DASH.lastIndex = 0;

    if (SPACED_EN_DASH.test(line) && !DATE_RANGE_EN_DASH.test(line)) {
      failures.push(
        `${path}:${lineNumber}: spaced en dash used as a separator`,
      );
    }
    SPACED_EN_DASH.lastIndex = 0;

    if (CURLY_QUOTE.test(line)) {
      failures.push(`${path}:${lineNumber}: curly quote`);
    }
    CURLY_QUOTE.lastIndex = 0;

    TELL_WORDS.lastIndex = 0;
    for (const match of line.matchAll(TELL_WORDS)) {
      failures.push(`${path}:${lineNumber}: tell word "${match[0]}"`);
    }

    if (
      path.endsWith(".md") &&
      /^\s{0,3}#{1,6}\s/.test(line) &&
      HEADING_EMOJI.test(line)
    ) {
      failures.push(`${path}:${lineNumber}: emoji in a markdown heading`);
    }
  }
}
