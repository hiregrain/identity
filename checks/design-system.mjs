// checks/design-system.mjs holds the worker-app design system to its own rules.
//
// Why this exists: the system had a coherent vocabulary and no enforcement, and
// the difference showed up as measurement rather than opinion. The ruled input,
// the control the app uses most, existed in ten copies across five already
// divergent variants, produced by one author in one session with the whole
// design in view. Spacing used thirty distinct values between 1px and 70px.
// Thirty-five inline font-size overrides sat at seven sizes that were not
// registers, clustered so tightly that they were plainly asking for two
// registers the system did not have. Every one of those passed ten green checks,
// because no check looked. A design system nothing enforces is a style guide.
//
// Three rules, each mechanical:
//
//   1. NO SHADOWING. A screen may not define a class the chassis already
//      defines. tpl/_chrome.part and tpl/_shared.css are the chassis; a local
//      rule with the same selector silently wins on one screen and nowhere
//      else, which is how .row and .gutter came to mean two different things.
//   2. TYPE COMES FROM A REGISTER. Every font-size in the tree is one of §6's
//      registers, or one of the two documented control exceptions below.
//   3. SPACING COMES FROM THE SCALE. Every padding and margin value is on it.
//
// Frozen boards are exempt and named: the three Handle comparison artboards are
// the record of HOW decision 047 was decided, not screens to build, and they
// must not track the chassis or the comparison they record drifts.
//
// Usage: node checks/design-system.mjs [screens-dir]
// Dependency-free Node, no database.

import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2] ?? "design/10-worker-app-screens";
const TPL = join(dir, "tpl");

const FROZEN = new Set([
  "HandleGrain.tpl",
  "HandlePlatform.tpl",
  "HandleSplit.tpl",
]);
const PARTS = new Set([
  "_chrome.part",
  "_shared.css",
  "_icons.part",
  "_swatches.part",
]);

// §6's registers, read from the stylesheet rather than restated here, so this
// check cannot disagree with the system it is checking.
const shared = readFileSync(join(TPL, "_shared.css"), "utf8");
const registers = new Map();
for (const m of shared.matchAll(/\.(t-[a-z]+)\s*\{([^}]*)\}/g)) {
  const size = m[2].match(/font-size:\s*([\d.]+)px/);
  if (size) registers.set(m[1], Number(size.value ?? size[1]));
}
const REGISTER_SIZES = new Set([...registers.values()]);

// Two control exceptions, each with a reason a reader can check:
//   16px on a text input, because anything smaller makes iOS zoom the viewport
//     on focus and the screen does not come back;
//   18px on the name field, the one place a larger value is the point.
const CONTROL_SIZES = new Set([16, 18]);

const SCALE = new Set([2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40, 56]);

const chassisText = readFileSync(join(TPL, "_chrome.part"), "utf8") + shared;
const chassis = new Set(
  [...chassisText.matchAll(/^\s*\.([a-z][\w-]*)/gm)].map((m) => m[1]),
);

const SPACING =
  /\b((?:padding|margin)(?:-(?:top|bottom|left|right|block|inline))?)\s*:\s*([^;"']*)/g;
const failures = [];
let scanned = 0;

for (const name of readdirSync(TPL)) {
  if (PARTS.has(name) || FROZEN.has(name) || !name.endsWith(".tpl")) continue;
  scanned++;
  const text = readFileSync(join(TPL, name), "utf8");
  const lines = text.split("\n");

  // 1. shadowing, inside the screen's own <style> only
  const helm = text.match(/@@CHROME@@([\s\S]*?)<\/style>/);
  if (helm) {
    const offset = text.slice(0, helm.index).split("\n").length;
    helm[1].split("\n").forEach((line, i) => {
      const m = line.match(/^\s*\.([a-z][\w-]*)/);
      if (m && chassis.has(m[1]))
        failures.push(
          `${name}:${offset + i}: .${m[1]} is defined in the chassis; a local copy wins here and nowhere else`,
        );
    });
  }

  lines.forEach((line, i) => {
    // 2. type
    for (const m of line.matchAll(/font-size:\s*([\d.]+)px/g)) {
      const v = Number(m[1]);
      if (!REGISTER_SIZES.has(v) && !CONTROL_SIZES.has(v))
        failures.push(
          `${name}:${i + 1}: font-size ${v}px is not a §6 register (${[...REGISTER_SIZES].sort((a, b) => b - a).join(", ")})`,
        );
    }
    // 3. spacing
    SPACING.lastIndex = 0;
    for (const m of line.matchAll(SPACING)) {
      for (const n of m[2].matchAll(/(\d+)px/g)) {
        const v = Number(n[1]);
        if (v !== 0 && !SCALE.has(v))
          failures.push(
            `${name}:${i + 1}: ${m[1]}: ${v}px is off the spacing scale`,
          );
      }
    }
  });
}

for (const f of failures.slice(0, 40)) console.error(`FAIL ${f}`);
if (failures.length > 40) console.error(`... and ${failures.length - 40} more`);
console.log(
  failures.length
    ? `design-system: ${failures.length} violation(s) across ${scanned} screens`
    : `design-system: ${scanned} screens hold the chassis, the registers and the scale`,
);
process.exit(failures.length ? 1 : 0);
