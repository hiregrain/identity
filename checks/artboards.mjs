// checks/artboards.mjs holds the canvas manifest, the templates and the built
// artboards to each other.
//
// Why this exists: the review artifact claimed "two screens are blocked and say
// so in place" when one did; the directory README claimed nine of fifty-two
// surfaces were drawn when fifty-seven were; and a screen was published to the
// canvas that no template produced. All three are the same failure: prose about
// the artifact, believed because it was written down. Nothing checked whether a
// claim about the screens matched the screens, so an outside reviewer had to.
//
// Three rules:
//
//   1. Every template builds an artboard, and every artboard has a template.
//   2. Every artboard is placed on the canvas exactly once, and every canvas
//      entry names a file that exists.
//   3. A screen the inventory marks BLOCKED carries a visible block notice on
//      its own surface. "Blocked" that only exists in a plan is a screen a
//      reviewer will read as finished, and one did.
//
// Usage: node checks/artboards.mjs [screens-dir]
// Dependency-free Node, no database.

import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2] ?? "design/10-worker-app-screens";
const TPL = join(dir, "tpl");
const PARTS = /^_/;

const templates = readdirSync(TPL)
  .filter((f) => f.endsWith(".tpl") && !PARTS.test(f))
  .map((f) => f.replace(/\.tpl$/, ""));
const built = readdirSync(dir)
  .filter((f) => f.endsWith(".dc.html"))
  .map((f) => f.replace(/\.dc\.html$/, ""));

const failures = [];

for (const t of templates)
  if (!built.includes(t)) failures.push(`${t}.tpl builds no artboard`);
for (const b of built)
  if (!templates.includes(b)) failures.push(`${b}.dc.html has no template`);

const canvas = JSON.parse(readFileSync(join(dir, "canvas.json"), "utf8"));
const placed = canvas.artboards.map((a) => a.file);
for (const f of placed)
  if (!existsSync(join(dir, f)))
    failures.push(`canvas places ${f}, which does not exist`);
for (const b of built)
  if (!placed.includes(`${b}.dc.html`))
    failures.push(`${b}.dc.html is on no canvas page`);
const dupes = placed.filter((f, i) => placed.indexOf(f) !== i);
for (const f of new Set(dupes))
  failures.push(`canvas places ${f} more than once`);

const pages = new Set(canvas.pages.map((p) => p.id));
for (const a of canvas.artboards)
  if (!pages.has(a.page))
    failures.push(`${a.file} sits on page "${a.page}", which is not declared`);

// 3. A blocked surface says so where a reader will see it. The inventory names
// which surfaces are blocked; the screen has to carry the notice itself.
const inventory = readFileSync(join(dir, "..", "08-app-inventory.md"), "utf8");
const blockedRows = [
  ...inventory.matchAll(/^\|[^|]*\|([^|]*)\|\s*BLOCKED[^|]*\|/gm),
].map((m) => m[1].trim());
const NOTICE = /not finished|cannot ship|Not ready|BLOCKED/i;
for (const row of blockedRows) {
  // Match on the row's LEADING clause only. Substring matching read "App icon
  // and launch screen" as the Launch artboard, which is a built screen, and
  // reported it blocked. A blocked row names its own surface first or it names
  // something that is not a screen at all.
  const lead = row.split(/[,.(]/)[0].trim().toLowerCase();
  const ALIAS = { "consent instrument": "Consent", language: "Language" };
  const hit =
    templates.find((t) => lead === t.toLowerCase()) ??
    ALIAS[Object.keys(ALIAS).find((k) => lead.startsWith(k)) ?? ""] ??
    null;
  if (!hit) continue; // rows with no screen of their own, e.g. the app icon
  const text = readFileSync(join(dir, `${hit}.dc.html`), "utf8");
  if (!NOTICE.test(text))
    failures.push(
      `${hit}.dc.html is BLOCKED in the inventory and carries no block notice on its surface`,
    );
}

for (const f of failures) console.error(`FAIL ${f}`);
console.log(
  failures.length
    ? `artboards: ${failures.length} disagreement(s) between the manifest, the templates and the tree`
    : `artboards: ${built.length} artboards, all templated, all placed once, and every blocked surface says so`,
);
process.exit(failures.length ? 1 : 0);
