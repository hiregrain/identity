# App framework, evaluation record

2026-08-19. The evidence behind decision 040. Method follows
`design/stack-litigation/`: advocacy briefs for each position, an adversarial
audit, and independent verification of the facts both briefs would rest on.
Binds nothing; decision 040 binds.

**Instruments.** An advocate's brief for Expo/React Native. An advocate's brief
for native Swift + Kotlin twins, briefed to confront ratified D2 head-on. An
adversarial risk auditor advocating for neither. Four verification agents on the
IDV SDKs, the gesture and renderer APIs, Skia's capability surface, and the
hairline / OTA / PWA questions.

**Standing limitation.** Nothing was rendered on target hardware. Every
performance conclusion below is architectural or from a published third-party
benchmark, and the two spikes named in §6 remain the only way to close that.

---

## 1. What decided it

Not performance. **The verify loop.**

`plans/ORDER.md`'s execution protocol runs on clean-context verifier sessions
that re-run mechanical criteria, an implementer session, then a separate
verifier given only the task file and the diff. That protocol has a hard
platform asymmetry:

| runtime | agent's pixel-level verify loop |
|---|---|
| Web | Playwright on Linux, official Docker images. Cheap. |
| Android / Compose | Paparazzi, Roborazzi, Compose Preview screenshot tests, plain JVM on Linux, no device or emulator. Cheap. |
| **iOS / SwiftUI** | **None off macOS.** No Linux→Apple build path exists; the Static Linux SDK docs state plainly that no such SDK exists for Apple platforms. Snapshot tests are simulator-identity-bound. macOS CI runs ~10× the per-minute cost of Linux. |

Compounding it: **Kotlin and Compose have published agent benchmarks**, JetBrains'
105-task real-repo Kotlin benchmark, and Google's Android Bench where 41% of the
100 tasks are Compose, verified by unit *and* instrumentation tests. **Swift and
SwiftUI have neither a benchmark nor a leaderboard.** Swift and Kotlin are absent
from SWE-bench Multilingual, Multi-SWE-bench and Aider polyglot; TypeScript is in
all three.

The native advocate stated this against its own side, and it is the finding that
should survive this document: **if native twins were taken, Android is the
low-risk half and iOS is the risk.**

## 2. What did not decide it, though it was expected to

**Rendering control.** Android Chrome *is* Skia. The rasterizer under Compose
Canvas and the rasterizer under a PWA are the same code. There is no native
rendering advantage on the platform that matters most to this population.

**The gesture API.** Decision 037 had already demoted the edge index to an
accelerator, which is what satisfies `app-shell` criterion 2. The native
advocate scored its own headline platform argument at zero.

**App size.** The 15.8MB-vs-2.0MB download gap between React Native and Kotlin
Multiplatform on a Huawei P40 Lite is real, but four of five target markets sit in
the world's cheapest per-GB data tier. The auditor called this argument noise and
predicted the native brief would overweight it.

## 3. The renderer, settled from source

`react-native-svg` was read, not benchmarked. It rasterizes via
`Bitmap.createBitmap` + `new Canvas(bitmap)`, never hardware-accelerated on
Android, and any child prop change nulls the bitmap and re-rasterizes
everything, allocating ~920KB per frame at the record screen's size. Two open
Fabric bugs hit the exact ceremony property: `strokeDasharray` cannot be cleared
on a recycled view, and `useAnimatedProps` on `<Svg>` lands only the final value
on iOS Fabric.

Decisively, `RenderableView.setupStrokePaint` returns early when
`strokeWidth == 0`. **It cannot express hairline mode**, and hairline mode is
what `DESIGN.md` gap 10a requires. Skia reaches `SkPaint::setStrokeWidth(0)`,
documented as *"always exactly one pixel wide in device space… thickness does not
change as the canvas is scaled."* Skia also supplies the ceremony a better
mechanism than the broken one: `<Path start end>` **trim**, driven by a Reanimated
shared value on the UI thread, instead of `strokeDashoffset`.

## 4. Two facts that were wrong all session, corrected

**The imprint is 5× heavier than every brief assumed.** Counted across the repo's
own 14 reference renders: **5,327 vertices at first attestation, 15,981 at a
median mature record, 24,352 worst case**, 364KB of path data. The "~5,000"
figure came from the sparse case and propagated everywhere.

**At 4× zoom the figure facets.** `imprint.py` fixes `samples=760` per thread
regardless of radius; at 4× that yields **8.3-device-pixel chords**, and the
guilloché visibly becomes polygons. The figure must be re-tessellated per zoom
level, which a static SVG DOM cannot do. This makes adaptive sampling by radius a
**correctness fix rather than an optimisation**, and it independently cuts total
vertices 2–3× invisibly, with Bézier fitting to `r(t)` worth ~10×.

## 5. Where native genuinely wins, taken as design guidance regardless

**Text scaling.** `UIFontMetrics.scaledValue(for:)` scales arbitrary layout
values, not only type, and `isAccessibilityCategory` lets a layout branch.
Android 14+ applies a documented **non-linear** curve its own docs warn against
reproducing with a scalar. The web can be scaled but cannot read the setting,
cannot branch, and applies a single linear multiplier. Against a nine-register
fixed-px scale with a `nowrap` figure column at iOS AX5's 3.12×, this is the
acceptance criterion most likely to fail, on the chosen framework. It is
carried as `app-shell` criterion 4 and it is real work.

**Haptics**, which also closed an open gap: `.rigid` on iOS is literally the
seat's semantics, `HapticFeedbackConstants.CONFIRM` on Android. With the
correction that `DESIGN.md` §10's premise that reduced motion suppresses haptics
is **unverified on both platforms**.

**Vendor SDK currency.** Sumsub's React Native wrapper trails its native SDKs by
a full minor version and ~5 weeks, structurally, and ships stale toolchain
requirements. Persona's RN SDK tracks the iOS 2.x line while native iOS is at
3.7.0. Neither vendor's RN module declares `codegenConfig`. Both are
legacy-bridge modules against an RN line that has begun deleting legacy classes.
Native twins would consume the same vendors' native SDKs and skip that interop
layer. **This is the best-evidenced argument the native brief made.**

## 6. What remains unmeasured, and the two spikes that close it

The adversarial auditor's position, that neither brief should be ratified before
these run, is recorded here because it was right about the evidence even though
the decision went ahead:

1. **The imprint at 24,352 vertices on a sub-$120 gesture-nav Android**, through
   the 1080ms scribe and a pinch, with frame times captured. Skia's own tracker
   carries a `SIGSEGV` crash-loop on a Xiaomi Redmi 9C, PowerVR GE8320, MediaTek
   Helio G35, that took three and a half months to close, and Shopify ships
   precompiled binaries an app cannot patch.
2. **Both vendor SDKs smoke-tested on SDK 57**, including Sumsub's unresolved iOS
   nil-modal crash, and the real APK/AAB size delta measured with an actual build.
   No credible published number exists for it.

Both are one week, before a screen is built. `design/07` §3's NEEDS RENDER flag
is still open and is load-bearing for all of this.

## 7. Findings that had nothing to do with frameworks

Recorded because they emerged here and would otherwise be lost:

- **`imprint/README.md` §8's patent clearance lost a limb.** It clears SAP US
  10712908 B2 partly on the ground that "the figure is generated
  non-interactively." Decision 035's expanded imprint made it interactive. The transpose and
  ratings-source arguments stand independently; counsel was told otherwise and
  needs correcting.
- **Neither IDV vendor permits capture in the host app's chrome**, on any
  runtime. Decision 036 flagged that shape as "designed, not ruled"; decision 040
  ruled it.
- **openapi-generator's plain `typescript` generator is experimental**;
  `typescript-fetch` and `typescript-axios` are the stable ones. A live defect in
  the existing TS plan, not the new one.
- **A prompt-injection pattern was encountered on `docs.expo.dev`.** Page text
  phrased as an instruction to an AI reader. It was treated as data and the
  underlying claim verified elsewhere. Recorded because any future agent fetching
  that page will meet it too.

### 6.1 The device spike's hardware evidence, waived (decision 085)

The Redmi 9C-class measurement and the dpr-1 daylight check this section
kept open were cut by founder ruling on 2026-08-21: the spike runs on the
founder's personal iPhone and Pixel instead. The GE8320 SIGSEGV question
and the dpr-1 thread-separability question are therefore accepted open
risks, not retired ones. Nothing in a clean iPhone or Pixel run speaks to
either. If a pilot puts this app on sub-$120 PowerVR hardware, this is
the paragraph that says nobody measured it first.

### 6.2 Spike 1 findings: the stack builds on both platforms (app-shell/00)

Recorded per decision 085's routing (findings land here as their own
docs commit, never inside the implementation diff). Build evidence in
`log/2026-08-21-app-shell-00-build-proof.md` on PR #17's branch.

The ratified stack (Expo SDK 57, React Native 0.86, React 19.2.3,
Skia 2.6.2 as bundled) resolves and produces real builds on both
platforms: iOS via prebuild, pod install and xcodebuild (exit 0), and
Android via assembleDebug and assembleRelease under JDK 17 (both
successful, all four ABIs). On an iPhone 17 Pro simulator the figure
carried 23,585 path commands across 89 threads through the full
1080 ms scribe and a pinch with no crash. The 24,352-vertex polyline
this section previously cited is superseded by the Bezier fit
(decision 088); 23,585 is the 2x-pinch equivalent, and the payload is
984 KB against the polyline's 364 KB, an open size concern 088 names.
The GE8320 SIGSEGV question stays open per 085 (see 6.1). Founder
handset attestation (criterion 6) is recorded in the task's
verification, not here.

Toolchain conditions the builds surfaced, each recorded in the build
log: the iOS build dies on a checkout path containing a space (an
Expo pod script defect); pod install needs LANG=en_US.UTF-8; Gradle
needs JDK 17 where the machine default is 25; and under pnpm's
isolated layout babel-preset-expo must be a declared dependency or
release bundling fails while debug builds stay silently green.
