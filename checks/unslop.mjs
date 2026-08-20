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
// SCANNED_ROOTS is scoped today to the trees swept in decision 052's
// code-sweep PR. It widens to the whole repo (`["."]`), the CLAUDE.md
// commitment, once the parallel docs sweep lands, in that sweep's own
// final commit.
//
// Usage: node checks/unslop.mjs [root-or-file...]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const SCANNED_ROOTS = [
  "core",
  "db",
  "checks",
  "test",
  "Makefile",
  ".github",
  "copy/deletion.md",
  "imprint/imprint.py",
  "mark/mark.py",
  "design/10-worker-app-screens/gen.py",
  "design/10-worker-app-screens/build.py",
];

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
// The five decisions-log files below are exempt, always, for a
// different reason: they hold the literal `## NNN — Title` heading
// format decisions/LOG.md still uses today, which
// checks/decisions-index.mjs parses by that exact em-dash-separated
// shape. decisions/LOG.md itself is outside this sweep (the parallel
// docs sweep owns it); when that sweep changes the heading format,
// checks/decisions-index.mjs and these fixtures move together in that
// same change, and this exemption comes out.
const EXCLUDED_FILES = new Set([
  "checks/unslop.mjs",
  "checks/decisions-index.mjs",
  "test/fixtures/greenpath/decisions-marked-gap.md",
  "test/fixtures/redpath/decisions/contradicted-marker.md",
  "test/fixtures/redpath/decisions/duplicate.md",
  "test/fixtures/redpath/decisions/unmarked-gap.md",
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

  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNumber = i + 1;

    if (EM_DASH.test(line)) {
      failures.push(
        `${path}:${lineNumber}: em dash (U+2014) used as a separator`,
      );
    }
    EM_DASH.lastIndex = 0;

    if (SPACED_EN_DASH.test(line)) {
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
