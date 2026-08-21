# app-shell

The native client, seeded by `plans/app-shell/00-device-spike.md`. Decision 085
made this the client app's seed rather than a throwaway harness, so it enters
the pnpm workspace and every later task in the layer builds on it.

What it contains today is one screen, and that screen exists to answer one
question: does the renderer decision 040 ratified survive the figure on real
hardware.

## The stack, and why each version is pinned exactly

Decision 040 ratified Expo SDK 57 (React Native 0.86, React 19.2.3) with CNG
and config plugins, expo-router, and `@shopify/react-native-skia` as the
imprint renderer. `test/stack.test.mjs` reads the installed packages and fails
if any of them drifts, because every other task in this layer treats those
versions as settled fact.

The renderer is pinned to the version Expo SDK 57 itself bundles, 2.6.2, not
to the newest published Skia. `bundledNativeModules.json` is the contract
between the managed native runtime and the JS package, and taking a newer one
is the same class of decision as taking SDK 58: deliberate, per 040, not
incidental.

`ios/` and `android/` are not committed. They are `expo prebuild` output, which
is what CNG means.

## The figure the screen draws

`fixtures/imprint-worst-case.json` is generated from `imprint/imprint.py`, the
canonical generator, by `pnpm run fixture`. Nothing in this package recomputes
the geometry; a second implementation of the figure is the thing not to build.

The fixture is the densest reference record at 720 CSS px on a 3x screen:
89 threads, 23,585 path commands. `app-shell/00` asks for the figure at 24,352
vertices, which is decision 040's worst case measured against the fixed
760-sample polyline the generator no longer emits. The Bezier fit that replaced
it draws the same record at 360 CSS px on a 3x screen in 5,852 commands. The
stated load is reached by pinching, and 23,585 is what a 2x pinch costs.

**The screen therefore renders at twice the density its canvas budgets, on
purpose.** At rest the threads merge into solid ink, because thread pitch was
budgeted for a 720 px figure and the canvas is 360. At 2x pinch the figure is
at the density it was drawn for. This is the spike's condition, not a defect,
and it is the state a pinch has to survive.

## Running it

    pnpm --filter @grain/app-shell run ios
    pnpm --filter @grain/app-shell run android

On a real handset, `npx expo run:ios --device` and `npx expo run:android
--device` from this directory.

**Paths with spaces break the iOS build.** Expo SDK 57's EXConstants pod emits
a build phase whose script path is over-escaped, so `/bin/sh` splits it on the
space and the build fails with `bash: /Users/you/Programming: No such file or
directory`. It is a packaging defect in the pod, not in this harness, and it
fails after the pods install so it reads as a compile failure. Build from a
checkout whose path has no spaces until it is fixed upstream.

## What the founder is asked to do, and what a clean run proves

Launch the app, watch the 1080 ms scribe complete, pinch the figure out and
back, and scribe again while zoomed. A clean run proves the ratified stack
builds and the renderer carries the figure on that handset.

It does not prove the renderer survives a PowerVR GE8320. Decision 085 waived
that evidence and left the risk open in `design/09` §6, where Skia's own
tracker carries a SIGSEGV crash-loop on exactly that GPU and Shopify ships
precompiled binaries an app cannot patch. The target population carries those
handsets. A clean iPhone and Pixel run is not evidence about them.
