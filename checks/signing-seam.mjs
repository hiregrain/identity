// checks/signing-seam.mjs asserts the kernel is the only place a
// signature can be produced (trust-kernel/02, layer criterion 5's first
// half; decision 019).
//
// Criterion 5's other half, that no non-operator party key is invokable,
// is carried structurally: kernel.Sign takes no key parameter, so the
// wrong key is unexpressible rather than rejected at runtime, and red
// path 18 proves the fixture that tries does not compile. That covers
// signing THROUGH the kernel. It says nothing about a package reaching
// past the kernel to the Ed25519 primitive directly, which is what this
// lint is for: a second signing path would have its own key handling,
// its own header bytes, and none of the contract's rules.
//
// This is a lexical lint over every Go file in the repo, walked from the
// repo root. It reads each file's import of crypto/ed25519, binds
// whatever qualifier that import established (the package name, an
// alias, or nothing at all for a dot import), and flags a call to Sign,
// GenerateKey, or NewKeyFromSeed through it. Matching the import rather
// than the literal text `ed25519.` is what closes the two-line evasion a
// code-review finding found in the first version, and it is the shape
// checks/transport-seam.mjs already uses.
//
// What it cannot catch: a signature produced through crypto.Signer held
// behind an interface, or a third-party library. That gap is accepted
// the way checks/transport-seam.mjs and checks/serving-credentials.mjs
// accept theirs: a loud, early failure on the ordinary case, not the
// only enforcement layer.
//
// Importing "crypto/ed25519" is not itself a violation. Verification
// needs the package, every resolver holds an ed25519.PublicKey, and a
// lint that banned the import would push verification behind a wrapper
// for nothing.
//
// Usage: node checks/signing-seam.mjs [rootDir]
//   rootDir defaults to the repo root; the fixture red path passes
//   test/fixtures/redpath/signing, a synthetic Go tree.

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, relative, sep } from "node:path";

const root = process.argv[2] ?? ".";

// Paths (repo-relative, posix-separated) excluded from the scan. Each is
// a subtree, so everything under it is excluded with it.
//
//   core/kernel         the frozen core and its two kernel-adjacent
//                       subpackages: operatorkey, the custody seam that
//                       IS the signing implementation, and fixture, the
//                       deterministic signer the golden vectors are
//                       generated with. "No code path outside the
//                       kernel" is the criterion's own wording, and this
//                       directory is what it names. Everything here is
//                       under decision 019's frozen-core review.
//   core/cmd/kernel-adapter
//                       the differential harness's stdio adapter
//                       (trust-kernel/06). It signs with a key the
//                       harness hands it over stdin, holds no operator
//                       key, and is built by the harness rather than
//                       linked into any serving path. Exempt with that
//                       reason rather than silently, because it is the
//                       one signing path in the repo outside the kernel
//                       directory.
//   core/gen            generated code.
const EXEMPT_PATHS = new Set([
  "core/kernel",
  "core/cmd/kernel-adapter",
  "core/gen",
]);

// Directory names excluded at any depth: version control, dependency
// trees no Go source lives in, and test/, which holds this check's own
// red-path fixture alongside every other check's. The red-path
// invocation passes a path inside test/ directly as rootDir, which is
// scanned normally; this exemption only prunes test/ when it is
// encountered as a descendant of the scan root.
const EXEMPT_NAMES = new Set([".git", "node_modules", "test"]);

// The signing primitives, by the name they carry inside crypto/ed25519.
// The qualifier they are reached through is whatever the file's import
// bound, which is why it is computed per file rather than written here.
const PRIMITIVES = ["Sign", "GenerateKey", "NewKeyFromSeed"];

const ED25519_PATH = "crypto/ed25519";

// One import spec: an optional binding (an alias, `.`, or `_`) followed
// by a quoted path. Matches inside a parenthesised import block and in
// the single-line `import "path"` form alike, which is why the block is
// not parsed as a block.
//
// The lookahead is load-bearing: without it the keyword in
// `import "crypto/ed25519"` is itself read as the binding, the check
// then looks for `import.Sign(`, and the plain form scans green. That is
// the same hole in a second costume and it is the reason this pattern
// has its own test below.
const IMPORT_SPEC = /(?:^|[(\s])(?:(?!import\b)([.\w]+)\s+)?"([^"]+)"/gm;

// bindingsFor returns the qualifiers this file can reach the ed25519
// primitives through, given what it imported.
//
// The prior version of this check matched the literal text
// `ed25519.Sign(`, which a code-review finding showed was two lines of
// evasion wide: `import ed "crypto/ed25519"` then `ed.Sign(...)` scanned
// green, and a dot import scanned green with no qualifier at all.
// checks/transport-seam.mjs closes the analogous hole by matching the
// import path, and this now does the same. The import is what a Go file
// cannot avoid writing.
//
//   "crypto/ed25519"      binds the package name, ed25519
//   ed "crypto/ed25519"   binds the alias
//   _ "crypto/ed25519"    binds nothing and nothing is callable, so it
//                         is not a violation and not a hole either
//
// A DOT import is handled separately and is refused outright rather than
// given a binding: it makes Sign, GenerateKey and NewKeyFromSeed
// reachable with no qualifier at all, so telling them apart from an
// ordinary method named Sign means guessing at Go's scope rules with a
// regular expression. There is no legitimate reason to dot-import
// crypto/ed25519, so the import itself is the finding. That is a rule
// with no false negatives instead of a guess with both kinds of error.
const DOT_IMPORT = ".";

function bindingsFor(content) {
  const bindings = [];
  IMPORT_SPEC.lastIndex = 0;
  let match;
  while ((match = IMPORT_SPEC.exec(content)) !== null) {
    const [, binding, path] = match;
    if (path !== ED25519_PATH) continue;
    if (binding === undefined) bindings.push("ed25519");
    else if (binding !== "_") bindings.push(binding);
  }
  return bindings;
}

// patternsFor turns one binding into the call shapes it makes reachable.
function patternsFor(binding) {
  if (binding === DOT_IMPORT) return [];
  return PRIMITIVES.map((name) => ({
    pattern: new RegExp(String.raw`\b${binding}\.${name}\s*\(`, "g"),
    what: `${binding}.${name} call`,
  }));
}

let filesScanned = 0;
let violations = 0;

if (existsSync(root) && statSync(root).isDirectory()) {
  walk(root);
}

if (violations > 0) {
  console.error(
    `signing-seam: ${violations} signing primitive(s) reached outside the kernel; ` +
      `only core/kernel produces a signature (trust-kernel/02, decision 019)`,
  );
  process.exit(1);
}

console.log(
  `signing-seam: ${filesScanned} Go file(s) scanned, no signing primitive outside the kernel`,
);

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (EXEMPT_NAMES.has(entry.name)) continue;
    const path = join(dir, entry.name);
    const relPath = relative(root, path).split(sep).join("/");
    if (EXEMPT_PATHS.has(relPath)) continue;
    if (entry.isDirectory()) {
      walk(path);
      continue;
    }
    if (!entry.isFile() || !entry.name.endsWith(".go")) continue;
    filesScanned += 1;
    const content = readFileSync(path, "utf8");
    const bindings = bindingsFor(content);
    if (bindings.includes(DOT_IMPORT)) {
      console.error(
        `signing-seam: ${path}: dot import of ${ED25519_PATH}, which makes ` +
          `${PRIMITIVES.join(", ")} reachable with no qualifier`,
      );
      violations += 1;
    }
    for (const { pattern, what } of bindings.flatMap(patternsFor)) {
      pattern.lastIndex = 0;
      let match;
      while ((match = pattern.exec(content)) !== null) {
        const line = content.slice(0, match.index).split("\n").length;
        console.error(
          `signing-seam: ${path}:${line}: ${what} (${match[0].trim()})`,
        );
        violations += 1;
      }
    }
  }
}
