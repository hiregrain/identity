// Criterion 4's resolve half: the ratified stack is what is actually on disk.
//
// Decision 040 ratified Expo SDK 57, React Native 0.86 and React 19.2.3, and
// every other task in this layer treats those as settled fact. This reads the
// installed packages rather than the lockfile, so a resolution that silently
// drifted to a different major fails here instead of on a phone.
//
// The renderer is pinned to what Expo SDK 57 itself bundles rather than to the
// latest published Skia: the SDK's `bundledNativeModules.json` is the contract
// between the managed native runtime and the JS package, and taking a newer
// Skia is the same class of decision as taking SDK 58, which decision 040 says
// is taken deliberately.

import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import test from "node:test";

const RATIFIED = {
  expo: "57.0.15",
  "react-native": "0.86.2",
  react: "19.2.3",
  "@shopify/react-native-skia": "2.6.2",
  "expo-router": "57.0.15",
};

const PACKAGE_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

// pnpm may place a dependency in this package's node_modules or hoist it to the
// workspace root, so the lookup walks up rather than assuming either.
function installedVersion(name) {
  let dir = PACKAGE_ROOT;
  for (;;) {
    const manifest = join(dir, "node_modules", name, "package.json");
    if (existsSync(manifest))
      return JSON.parse(readFileSync(manifest, "utf8")).version;
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

for (const [name, version] of Object.entries(RATIFIED)) {
  test(`${name} resolves to the ratified ${version}`, () => {
    const installed = installedVersion(name);
    assert.notEqual(installed, null, `${name} is not installed`);
    assert.equal(installed, version);
  });
}

test("the declared dependency on each ratified package is an exact pin", () => {
  const manifest = JSON.parse(
    readFileSync(join(PACKAGE_ROOT, "package.json"), "utf8"),
  );
  for (const name of Object.keys(RATIFIED)) {
    const declared = manifest.dependencies[name];
    assert.equal(
      declared,
      RATIFIED[name],
      `${name} is declared as "${declared}"; a range lets the ratified stack drift`,
    );
  }
});

// The renderer, and the rest of the native stack, are pinned to what Expo SDK
// 57 itself bundles rather than to the latest published version. This reads
// `expo/bundledNativeModules.json`, the SDK's own contract between the managed
// native runtime and the JS package, and asserts our pin against it. Without
// this the comment above is an unchecked claim; with it, a Skia bump away from
// what SDK 57 links fails here rather than at runtime on a device.
//
// bundledNativeModules pins some entries exactly (react, react-native, Skia)
// and others as a `~` range (expo-router). An exact bundled value must equal
// our pin; a `~x.y.z` range must have our pin as its base, which is the
// minimum it accepts. expo itself is not in the file: it is the SDK version.
test("each ratified pin matches Expo SDK 57's bundledNativeModules.json", () => {
  const require = createRequire(join(PACKAGE_ROOT, "package.json"));
  const bundled = JSON.parse(
    readFileSync(require.resolve("expo/bundledNativeModules.json"), "utf8"),
  );
  let asserted = 0;
  for (const [name, pin] of Object.entries(RATIFIED)) {
    const spec = bundled[name];
    if (spec === undefined) continue; // expo is the SDK, not a bundled module
    const base = spec.replace(/^[~^]/, "");
    assert.equal(
      base,
      pin,
      `${name} is pinned to ${pin} but SDK 57 bundles ${spec}`,
    );
    asserted += 1;
  }
  assert.ok(
    asserted >= 3,
    `expected at least react, react-native and Skia in bundledNativeModules; asserted ${asserted}`,
  );
});
