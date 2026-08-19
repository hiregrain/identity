// Migration-number uniqueness under the one shared numbering sequence
// (decision 017). The spine and payload chains draw from a single global
// sequence: gaps within one chain are expected — the other chain's
// numbers fall there — but a number used twice anywhere is a failure.
// Honors at-authoring claims: a `migrations:` list in task frontmatter
// reserves its numbers, so two tasks cannot claim one number and a landed
// file cannot squat on another task's claim. A claim matching its own
// landed file (same number, same name) is the claim materializing.
//
// Also enforces the filename grammar, NNNN-<kebab-noun-phrase>.sql.
//
// Adopted early from Dispatch's check (the full checks port is
// foundation/06); dependency-free Node, no database.
//
// Usage: node checks/migration-numbers.mjs [db-migrations-root] [plans-root]

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const NAME = /^(\d{4})-[a-z0-9]+(?:-[a-z0-9]+)*$/;

const dbRoot = process.argv[2] ?? "db/migrations";
const plansRoot = process.argv[3] ?? "plans";

const failures = [];
const byNumber = new Map(); // number -> Map(name -> [sources])

for (const { name, source } of [...landedFiles(dbRoot), ...claims(plansRoot)]) {
  const match = NAME.exec(name);
  if (!match) {
    failures.push(
      `${source}: "${name}" does not match NNNN-<kebab-noun-phrase>`,
    );
    continue;
  }
  const number = match[1];
  if (!byNumber.has(number)) byNumber.set(number, new Map());
  const names = byNumber.get(number);
  if (!names.has(name)) names.set(name, []);
  names.get(name).push(source);
}

for (const [number, names] of byNumber) {
  if (names.size > 1) {
    const uses = [...names.entries()]
      .map(([name, sources]) => `${name} (${sources.join(", ")})`)
      .join(" vs ");
    failures.push(
      `number ${number} used twice under the shared sequence: ${uses}`,
    );
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`FAIL ${failure}`);
  process.exit(1);
}
console.log(
  "migration-numbers: every number is globally unique across both chains and all claims",
);

function landedFiles(root) {
  const files = [];
  walk(root, files);
  return files.map((path) => ({
    name: path
      .split("/")
      .pop()
      .replace(/\.sql$/, ""),
    source: path,
  }));
}

function walk(dir, out) {
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return; // no migrations directory yet — nothing landed
  }
  for (const entry of entries) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) walk(path, out);
    else if (entry.name.endsWith(".sql")) out.push(path);
  }
}

function claims(root) {
  const out = [];
  let layers;
  try {
    layers = readdirSync(root);
  } catch {
    return out;
  }
  for (const layer of layers) {
    const dir = join(root, layer);
    if (!statSync(dir).isDirectory()) continue;
    for (const file of readdirSync(dir)) {
      if (!file.endsWith(".md")) continue;
      const path = join(dir, file);
      const match = /^migrations:\s*\[([^\]]*)\]/m.exec(
        readFileSync(path, "utf8"),
      );
      if (!match || match[1].trim() === "") continue;
      for (const name of match[1].split(",")) {
        out.push({ name: name.trim(), source: path });
      }
    }
  }
  return out;
}
