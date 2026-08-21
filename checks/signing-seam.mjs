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
// repo root. What it catches: a call to ed25519.Sign, ed25519.GenerateKey,
// or ed25519.NewKeyFromSeed. What it cannot catch: a signature produced
// through crypto.Signer held behind an interface, or a third-party
// library. That gap is accepted the way checks/transport-seam.mjs and
// checks/serving-credentials.mjs accept theirs: a loud, early failure on
// the ordinary case, not the only enforcement layer.
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

const PATTERNS = [
  { pattern: /ed25519\.Sign\s*\(/g, what: "ed25519.Sign call" },
  {
    pattern: /ed25519\.GenerateKey\s*\(/g,
    what: "ed25519.GenerateKey call",
  },
  {
    pattern: /ed25519\.NewKeyFromSeed\s*\(/g,
    what: "ed25519.NewKeyFromSeed call",
  },
];

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
    for (const { pattern, what } of PATTERNS) {
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
