---
id: app-shell/00
type: task
layer: app-shell
satisfies: [7]
status: done
depends_on: []
binds:
  - decisions/LOG.md#040
  - decisions/LOG.md#044
  - design/09-app-framework-evaluation.md
evidence:
  [
    "diff:PR #17 @ 3d55113",
    "test:surfaces/app-shell/test/stack.test.mjs",
    "test:surfaces/app-shell/test/fixture.test.mjs",
    "log:log/2026-08-21-app-shell-00-build-proof.md",
    "log:design/09-app-framework-evaluation.md#62 @ 301d09a",
    "review:log/2026-08-21-app-shell-00-verification.md",
  ]
verified_by: verify-app-shell-00@2026-08-21
---

# Device spike: does the ratified renderer survive the hardware this is for

## Objective

The two things `app-shell`'s own scope says need a real device and that
nothing in the code can stand in for. Both are open in `design/09` §6 and
**neither has been run**. This task runs them, before a screen is built on
top of the answer.

**Why it is first.** `design/09` records the adversarial auditor's position
that neither brief should be ratified before these run, "because it was right
about the evidence even though the decision went ahead". Decision 040 ratified
Expo SDK 57 and `@shopify/react-native-skia` anyway. That was a defensible call
under time pressure and it is not reopened here. What is not defensible is
building the whole shell on it without ever running the test the evidence asked
for. Every other task in this layer depends on this one.

## Scope

Amended by decision 085: the Redmi-class hardware requirement is cut and
the spike runs on the founder's personal iPhone and Pixel. The GE8320
SIGSEGV risk design/09 §6 records is accepted rather than retired by
measurement, and stays open there.

- **The imprint on the founder's handsets.** The figure at 24,352 vertices
  through the 1080 ms scribe and a pinch, on the founder's personal iPhone
  and Pixel, without a crash.
- **A build proof for the ratified stack.** Expo SDK 57, React Native 0.86 and
  React 19.2.3 are treated as settled fact by every task here and by decision
  040. This spike resolves and builds them before anything assumes they compose
  cleanly, because a version that does not resolve blocks the layer entirely.
- **The harness is the client app's seed** (decision 085): it lives under
  `surfaces/` and enters the pnpm workspace; it is not a throwaway.

**Moved out of this spike.** The vendor SDK smoke test, Sumsub's iOS nil-modal
crash and the APK/AAB size delta were in an earlier draft of this task. They
are identity and distribution concerns, not renderer risk, and they belong to
`worker-identity-surface` and `app-distribution`. They are named in
`design/09` §6 and stay there; this task does not carry them.

## Acceptance

Criteria 1 through 3 as originally written (Redmi-class crash measurement,
frame-time budgets, dpr-1 daylight photograph) are cut by decision 085 and
do not renumber; the identifiers below are stable.

4. **The ratified stack resolves and builds.** (mechanical) Expo SDK 57, React
   Native 0.86 and React 19.2.3 resolve and produce a running debug build on
   both platforms, asserted from a real build rather than from the lockfile.
5. **The result is written down either way.** (mechanical) the findings land in
   `design/09` §6 as evidence, including a negative result, as their own
   `docs(design):` commit on `main`, never inside the implementation diff
   (decision 085). A spike that runs and records nothing has not run.
6. **The imprint survives the scribe and a pinch on the founder's handsets.**
   (adjudicated) the figure renders through a full 1080 ms scribe and a pinch
   on the founder's personal iPhone and Pixel without a crash, attested by the
   founder running the build; decision 085 records that this is not evidence
   about the GE8320 hardware the target population carries.

## What a bad result means, pre-committed

Recorded now so it is not argued after the fact, which is the discipline
`plans/t1-spike.md` used. An earlier draft of this task said a bad result
blocked nothing, while the layer said every task depended on it. **That made
the dependency performative and it is corrected here**: each outcome names what
it stops.

- **The imprint crashes on either of the founder's handsets.** Decision 040's
  renderer choice reopens and this layer **returns to `draft`**. Tasks 02 and
  03 may continue, because the palette and the type scale do not depend on the
  renderer. Task 01 continues. Task 05 continues. Nothing that draws the figure
  proceeds until 040 is re-ruled. (The frame-budget and dpr-1 outcomes are cut
  with their criteria, decision 085.)
- **The stack does not resolve or build.** Everything stops. Decision 040's
  framework ruling reopens in full and the layer returns to `draft`, because no
  task in it can be written against a stack that does not exist.

This is why every other task declares `app-shell/00` as a dependency: not as a
formality, but because two of the three outcomes above change what those tasks
are allowed to assume.

## Outside check

The spike is itself an outside check: it is the one thing in this layer whose
result cannot be produced by reading the code.

## Evidence

- Criterion 4, resolve: `surfaces/app-shell/test/stack.test.mjs` reads the
  installed packages rather than the lockfile and asserts Expo 57.0.15, React
  Native 0.86.2, React 19.2.3, expo-router 57.0.15 and Skia 2.6.2, plus that
  each is declared as an exact pin. Runs in `make check`'s ts-check stage
  through `pnpm -r run test`.
- Criterion 4, build, both platforms:
  `log/2026-08-21-app-shell-00-build-proof.md` records the prebuilds, the pod
  install, the `xcodebuild` invocation that exits 0, the launched iOS product
  rendering the figure and surviving a pinch, and `./gradlew assembleDebug` and
  `assembleRelease` both printing `BUILD SUCCESSFUL` with `librnskia.so` present
  for every ABI. It also records the three environment conditions the builds
  have: a space-free path, a UTF-8 locale, and `babel-preset-expo` declared
  rather than inherited. All three are toolchain defects rather than defects in
  the harness.
- Criterion 5: discharged on `main`, not in this diff, which is what decision
  085 requires. `design/09` §6.2, commit `301d09a`, `docs(design): spike 1
  finds the stack builds on both platforms (app-shell/00)`.
- Criterion 6: **not discharged, deferred by decision 090** until the app is
  usable, and required before `app-distribution` goes `ready`. It is attested
  by the founder running the
  build on his own handsets. `surfaces/app-shell/README.md` states what he is
  asked to do, which artifact to install on each handset, and what a clean run
  does and does not prove.
- The fixture the renderer is loaded with is checked by
  `surfaces/app-shell/test/fixture.test.mjs`: 89 threads, 23,585 path commands,
  counted out of the committed bytes rather than trusted from the declaration,
  every thread a closed single-subpath cubic. `pnpm run fixture` regenerates it
  from `imprint/imprint.py`; the regeneration is not in `make check` because it
  needs Python and CI does not.
