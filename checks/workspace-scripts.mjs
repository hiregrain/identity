// Workspace-script enforcement for the ts stage. `pnpm -r run <script>`
// silently skips a package that never declared the script, so a surface
// could dodge typecheck/test forever without failing anything. This check
// makes the ts stage honest: it states explicitly when zero workspace
// packages matched (allowed — surfaces/ is an empty seed until its own
// tasks land), and fails if any workspace package lacks a `typecheck` or
// `test` script.
//
// Usage: node checks/workspace-scripts.mjs

import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join, dirname } from "node:path";

const REQUIRED_SCRIPTS = ["typecheck", "test"];

const packages = workspacePackages("pnpm-workspace.yaml");
if (packages.length === 0) {
  console.log(
    "workspace-scripts: zero workspace packages matched (surfaces/ is an empty seed; allowed)",
  );
  process.exit(0);
}

const failures = [];
for (const pkgPath of packages) {
  const pkg = JSON.parse(readFileSync(pkgPath, "utf8"));
  for (const script of REQUIRED_SCRIPTS) {
    if (typeof pkg.scripts?.[script] !== "string") {
      failures.push(
        `${pkgPath}: missing script "${script}" — pnpm -r would silently skip it`,
      );
    }
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  `workspace-scripts: every workspace package declares ${REQUIRED_SCRIPTS.join(", ")}`,
);

// Resolves the workspace globs to package.json paths. Only the `dir/*`
// glob form is supported because it is the only form the workspace file
// uses; an unrecognized form fails loudly rather than matching nothing.
function workspacePackages(workspaceFile) {
  const globs = readFileSync(workspaceFile, "utf8")
    .split("\n")
    .map((line) => /^\s+-\s+["']?([^"'#]+?)["']?\s*$/.exec(line)?.[1])
    .filter((glob) => glob !== undefined);

  const found = [];
  for (const glob of globs) {
    if (!glob.endsWith("/*") || glob.includes("**")) {
      console.error(
        `FAIL ${workspaceFile}: glob "${glob}" is not the supported dir/* form`,
      );
      process.exit(1);
    }
    const parent = dirname(glob);
    if (!existsSync(parent)) continue;
    for (const entry of readdirSync(parent)) {
      const pkgPath = join(parent, entry, "package.json");
      if (statSync(join(parent, entry)).isDirectory() && existsSync(pkgPath)) {
        found.push(pkgPath);
      }
    }
  }
  return found;
}
