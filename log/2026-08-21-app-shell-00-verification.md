# app-shell/00 verification

Task: `plans/app-shell/00-device-spike.md`
PR: #17, branch `task/app-shell-00`
Implementation head verified: `3d55113cf661cab7c5071b7a5294245a7348d736`
Verifier: clean context, no access to the implementer's session.
Verdict: **pass**, criteria 4 and 5.

Criteria 1 through 3 are cut by decision 085. Criterion 6 is deferred by
decision 090 and is not verified here; 090 makes 4 and 5 the done-condition
and requires the handset attestation to land as an addendum to this record
before `app-distribution` goes `ready`.

Everything below was run by this session on a fresh export of `3d55113`,
in `/private/tmp/grain-verify17*`, because the founder's checkout path
contains a space and the iOS build dies on that.

## Precondition: `make check`

    cd /private/tmp/grain-verify17-clean && make check
    -> exit 0, "check: green"

Two earlier runs of the same command on the same tree failed, neither on
the diff:

- the first failed in `lint` because the tree had been prebuilt: `make
  lint`'s prettier glob `surfaces/**/*.{ts,tsx,js,json}` matches the
  generated `surfaces/app-shell/android/**` output that the package's own
  `.gitignore` excludes and that eslint's ignore list excludes. Finding 2.
- the second failed in `migrate` with `FATAL: the database system is
  shutting down` while other agents' compose stacks were up. Environmental.

## Criterion 4: the ratified stack resolves and builds

Mechanical. Discharged on both platforms from real builds.

**Resolve.**

    cd /private/tmp/grain-verify17 && pnpm install --frozen-lockfile
    pnpm -r run test
    -> 11 tests, 11 pass, 0 fail

`surfaces/app-shell/test/stack.test.mjs` asserts Expo 57.0.15, React Native
0.86.2, React 19.2.3, expo-router 57.0.15 and Skia 2.6.2 from the installed
package manifests, and that each is declared as an exact pin. Three planted
violations were run against it rather than trusting it:

    installed react-native/package.json version -> 0.87.0
    -> ✖ react-native resolves to the ratified 0.86.2 (actual 0.87.0)

    declared dependency react-native -> "^0.86.2"
    -> ✖ the declared dependency on each ratified package is an exact pin

    fixtures/imprint-worst-case.json paths truncated to 40 threads
    -> ✖ the fixture carries the vertex count the spike is for
    -> ✖ the declared vertex count is the one the path data actually contains

All three restored; the suite is green again.

**Build, iOS.** `npx expo prebuild --clean --platform ios` then, after the
locale condition below, `pod install`, then

    xcodebuild -workspace Grain.xcworkspace -scheme Grain \
      -configuration Debug -sdk iphonesimulator \
      -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
      -derivedDataPath build build
    -> exit 0, "** BUILD SUCCEEDED **", zero `error:` lines

The product was installed on a booted iPhone 17 Pro simulator with `simctl
install` and launched with `simctl launch com.hiregrain.appshell`. Metro
bundled 1,968 modules, matching the implementer's figure. A screenshot shows
the figure drawn and the screen's own caption reading `23585 path commands,
89 threads`, with the threads merged into a solid band, which is the state
the README says to expect at rest.

The prebuild reproduced the recorded locale condition exactly: `pod install`
under the default locale raised `Encoding::CompatibilityError` out of
`unicode_normalize`; `LANG=en_US.UTF-8 pod install` completed.

**Build, Android.** `npx expo prebuild --clean --platform android` then

    JAVA_HOME=/opt/homebrew/opt/openjdk@17 ./gradlew assembleDebug --no-daemon
    -> first run: FAILURE at :app:packageDebug
       (PackageAndroidArtifact$IncrementalSplitterRunnable), while the iOS
       build was compiling concurrently on the same machine
    -> re-run: exit 0, "BUILD SUCCESSFUL in 30s", 505 tasks

    ./gradlew assembleRelease --no-daemon
    -> exit 0, "BUILD SUCCESSFUL in 14m 26s"

Both artifacts were opened rather than trusted:

    app-debug.apk    lib/{arm64-v8a,armeabi-v7a,x86,x86_64}/librnskia.so
    app-release.apk  the same four, plus assets/index.android.bundle

which is the part of the ratified stack no lockfile assertion reaches, and
the part that makes the release APK sideloadable without Metro.

**The fixture is generated, not hand-made.** `python3
surfaces/app-shell/fixtures/generate.py` rewrote the committed file
byte-identically (md5 `b2caa93d40a6c76a6928da0b8da53c86` before and after),
so the 89 threads and 23,585 path commands come out of `imprint/imprint.py`
rather than out of a README.

## Criterion 5: the result is written down either way

Mechanical. Discharged on `main`, not in this diff, which is what decision
085 requires.

    git show --stat 301d09a
    -> docs(design): spike 1 finds the stack builds on both platforms
       (app-shell/00), design/09-app-framework-evaluation.md, +27

The added §6.2 records the resolve, both builds, the 23,585-command figure
through the scribe and a pinch, the four toolchain conditions, the
supersession of the 24,352-vertex polyline figure and the 984 KB payload it
costs, and states that the GE8320 question stays open per 085 and that the
handset attestation is not covered. It is a `docs(design):` commit of its
own on `main` and carries nothing else.

## Outside check

The task's outside check is the spike itself: the result cannot be produced
by reading the code. It was run, not read. Both builds were executed from
this session on this hardware, the iOS product was launched and rendered,
both APKs were unzipped, the fixture was regenerated from the canonical
generator, and three planted violations were confirmed to fail the tests
that claim to catch them.

## Findings

None of these fails criterion 4 or 5. All are for the layer or the founder
to rule on.

1. **The `evidence` frontmatter cites a superseded commit.** It carries
   `diff:PR #17 @ 661414f`; the head is `3d55113`, two commits later, and
   the Android half of the proof is in `3d55113`. Corrected in this
   session's bookkeeping commit.
2. **`make lint` fails on any checkout that has been prebuilt.** The
   README's own instructions produce `surfaces/app-shell/android/` and
   `ios/`, and the prettier invocation in `Makefile`'s `lint` target has no
   ignore for them while `eslint.config.mjs` does. Reproduced: prettier
   reports the generated `autolinking.json` and hundreds of Gradle
   intermediates. CI checks out a clean tree, so this is a developer-machine
   defect only, which is the same shape as the condition the eslint comment
   already describes.
3. **eslint no longer parses `surfaces/**/*.{ts,tsx}`.** The diff moves
   those files out of eslint entirely and covers them with `tsc --noEmit`,
   which checks types and no lint rule. The implementer named it as a call
   for the layer to make rather than for this task; it is real coverage lost
   and the layer should rule on typescript-eslint before more surface code
   lands.
4. **The task file has diverged from `main` on the same lines.** `main`'s
   `ebc0031` amended criterion 6 to record decision 090's deferral; the
   branch added the `evidence` block and an `## Evidence` section. The merge
   needs a rebase, and the branch's `## Evidence` section still says
   criterion 5 is "not discharged", which stopped being true when `301d09a`
   landed. Corrected in this session's bookkeeping commit.
5. **The Android debug build failed once at `:app:packageDebug` under
   concurrent load and passed on re-run.** Recorded because a reader hitting
   it should not read it as a stack defect; nothing in the failure names the
   ratified packages.
6. **The screen's second caption line is clipped at the left edge** on an
   iPhone 17 Pro: "twice the density this canvas budgets; pinch to 2x to see
   it as drawn" wraps outside the centred column. Cosmetic on a spike
   screen, and `app-shell/01` owns safe areas and layout.
