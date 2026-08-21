# app-shell/00: the build proof, both platforms

Task: `plans/app-shell/00-device-spike.md`, criterion 4.
Recorded by the implementing session, not a verifier. The verifier re-runs
these; nothing here is a substitute for that.

Toolchain: Xcode 26.6 (17F113), Node v24.16.0, pnpm 10.14.0, CocoaPods 1.16.2,
Android SDK platform 35 with build-tools 35.0.0 and NDK 27.1.12297006, Gradle
9.3.1 on OpenJDK 17.0.20. Gradle must run on JDK 17; the machine's default is
Temurin 25 and React Native 0.86 does not accept it.

## iOS

    pnpm install --frozen-lockfile
    cd surfaces/app-shell
    npx expo prebuild --clean --platform ios
    cd ios
    xcodebuild -workspace Grain.xcworkspace -scheme Grain \
      -configuration Debug -sdk iphonesimulator \
      -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
      -derivedDataPath build build

Exits 0, prints `** BUILD SUCCEEDED **`, no `error:` line, 102 pods installed.

The product was installed on an iPhone 17 Pro simulator with `simctl install`
and launched with `simctl launch com.hiregrain.appshell`. Metro bundled 1,968
modules. The screen rendered the figure and its own caption, `23585 path
commands, 89 threads`. A two-finger pinch driven through the simulator zoomed
the figure without a crash, and the merged band separated into individually
resolvable hairlines, which is the property `strokeWidth={0}` is there for.

## Android

    cd surfaces/app-shell
    npx expo prebuild --clean --platform android
    cd android
    ./gradlew assembleDebug --no-daemon
    ./gradlew assembleRelease --no-daemon

Both exit 0 and print `BUILD SUCCESSFUL`. The debug variant runs 625 Gradle
tasks from cold, including CMake for every ABI, and takes 32 minutes on this
machine; incremental runs take seconds.

`librnskia.so` is present for all four ABIs in both artifacts, which is the
part of the ratified stack a lockfile assertion cannot reach.

**Both variants are built, and the release one is the one to sideload.** The
debug APK embeds no `index.android.bundle` and expects a Metro server, so it
cannot be launched standalone on a handset. `assembleRelease` embeds the bundle
and Expo's template signs the release variant with the debug keystore, so it
installs and runs with no Metro and no signing setup. Criterion 4 is discharged
by the debug build; criterion 6 needs the release one.

## Three environment conditions the verifier will hit

**The build must run from a path with no space in it.** Expo SDK 57's
EXConstants pod emits a build phase whose script path is over-escaped, so
`/bin/sh -c` splits it on the space:

> bash: /Users/kylechoy/Desktop/Programming: No such file or directory
> Command PhaseScriptExecution failed with a nonzero exit code

It fails after the pods install, so it presents as a compile failure rather
than as a path problem. Every build above was run from a copy of the tree at
`/private/tmp/grain-spike`, made with `rsync -a --exclude .git --exclude
node_modules`. The defect is in the pod, not in the harness.

**`pod install` needs a UTF-8 locale.** Without `LANG=en_US.UTF-8` CocoaPods
1.16.2 on Ruby 4.0.5 raises `Encoding::CompatibilityError` out of
`unicode_normalize` before it reads the Podfile.

**`babel-preset-expo` has to be a declared dependency of the package.** Babel
resolves presets relative to `@babel/core`, and under pnpm's isolated layout a
transitive copy is not visible from there. `createBundleReleaseJsAndAssets`
failed with `Cannot find module 'babel-preset-expo'` until it was declared.
The debug build embeds no bundle, so it never surfaced this; the release build
did, on the first attempt.

## What this does not establish

Criterion 6 is unrun. It is attested by the founder on his own iPhone and
Pixel, and a simulator is not a handset.

Nothing here is evidence about the PowerVR GE8320. Decision 085 waived that
evidence and left the risk open in `design/09` §6.
