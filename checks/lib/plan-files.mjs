// checks/lib/plan-files.mjs — the one frontmatter reader the plan checks
// share (foundation/06). Three checks (frontmatter, plan-graph,
// migration-order) read the same blocks; parsing them three ways is how
// the readings drift apart, so the reader lives here once. Dependency-free.
//
// The parser handles exactly the shapes the plan files use, loudly, and
// nothing more: `key: value`, `key: [a, b]`, a flow list continued across
// lines (`key:` then `[`, entries, `]`), and a block list (`key:` then
// `  - item` lines). Anything else in a frontmatter block is a parse
// failure the caller reports, never a silent skip.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

// Read every .md file inside the layer directories under `root`.
// Returns [{ path, dir, name, fields, errors }] where `fields` maps each
// frontmatter key to { raw, list } — `list` is the parsed array for list
// values and null for scalars — and `errors` carries parse problems.
export function readPlanFiles(root) {
  const out = [];
  for (const entry of readdirSync(root)) {
    const dir = join(root, entry);
    if (!statSync(dir).isDirectory()) continue;
    for (const name of readdirSync(dir)) {
      if (!name.endsWith(".md")) continue;
      const path = join(dir, name);
      out.push({ path, dir: entry, name, ...parseFrontmatter(path) });
    }
  }
  return out;
}

export function parseFrontmatter(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  const fields = new Map();
  const errors = [];
  if (lines[0] !== "---") {
    return { fields, errors: ["does not open with a frontmatter block"] };
  }
  const end = lines.indexOf("---", 1);
  if (end === -1) {
    return { fields, errors: ["frontmatter block never closes"] };
  }

  for (let i = 1; i < end; i++) {
    const line = lines[i];
    const match = /^([a-z_]+):(.*)$/.exec(line);
    if (!match) {
      errors.push(`frontmatter line ${i + 1} ("${line}") is not a field`);
      continue;
    }
    const key = match[1];
    let value = match[2].trim();

    // Collect continuation lines (indented) into the value.
    const continuation = [];
    while (i + 1 < end && /^\s/.test(lines[i + 1])) {
      continuation.push(lines[i + 1].trim());
      i++;
    }

    if (fields.has(key)) errors.push(`field ${key} appears twice`);

    if (continuation.length === 0) {
      fields.set(key, { raw: value, list: parseFlowList(value) });
    } else if (value === "" && continuation[0].startsWith("- ")) {
      // Block list.
      const items = [];
      for (const item of continuation) {
        if (!item.startsWith("- ")) {
          errors.push(`field ${key}: block-list line "${item}" is not - item`);
          continue;
        }
        items.push(unquote(item.slice(2).trim()));
      }
      fields.set(key, { raw: continuation.join(" "), list: items });
    } else {
      // Flow list continued across lines.
      const joined = (value + " " + continuation.join(" ")).trim();
      const list = parseFlowList(joined);
      if (list === null) {
        errors.push(`field ${key}: multi-line value is not a [] list`);
      }
      fields.set(key, { raw: joined, list });
    }
  }
  return { fields, errors };
}

// "[a, b]" -> ["a", "b"]; "[]" -> []; anything else -> null.
function parseFlowList(raw) {
  if (!raw.startsWith("[") || !raw.endsWith("]")) return null;
  const inner = raw.slice(1, -1).trim();
  if (inner === "") return [];
  return inner
    .split(",")
    .map((item) => unquote(item.trim()))
    .filter((item) => item !== "");
}

function unquote(text) {
  const match = /^"(.*)"$/.exec(text) ?? /^'(.*)'$/.exec(text);
  return match ? match[1] : text;
}
