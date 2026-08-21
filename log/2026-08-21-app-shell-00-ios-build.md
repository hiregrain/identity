# app-shell/00: the iOS build proof

Task: `plans/app-shell/00-device-spike.md`, criterion 4.
Head: `661414f`.
Recorded by the implementing session, not a verifier. The verifier re-runs
these; nothing here is a substitute for that.

## What was run, in order

    pnpm install
    cd surfaces/app-shell
    npx expo prebuild --clean --platform ios
    cd ios
    xcodebuild -workspace Grain.xcworkspace -scheme Grain \
      -configuration Debug -sdk iphonesimulator \
      -destination "platform=iOS Simulator,name=iPhone 17 Pro" \
      -derivedDataPath build build

`xcodebuild` exited 0, printed `** BUILD SUCCEEDED **`, and the log carries
no `error:` line. Toolchain: Xcode 26.6 (17F113), Node v24.16.0, pnpm 10.14.0,
CocoaPods 1.16.2, 102 pods installed.

## Two environment conditions, both of which the verifier will hit

**The build must run from a path with no space in it.** Expo SDK 57's
EXConstants pod emits a build phase whose script path is over-escaped, so
`/bin/sh -c` splits it on the space:

> bash: /Users/kylechoy/Desktop/Programming: No such file or directory
> Command PhaseScriptExecution failed with a nonzero exit code

It fails after the pods install, so it presents as a compile failure rather
than as a path problem. The build above was run from a copy of the tree at
`/private/tmp/grain-spike`, made with `rsync -a --exclude .git --exclude
node_modules`. The defect is in the pod, not in the harness.

**`pod install` needs a UTF-8 locale.** Without `LANG=en_US.UTF-8` CocoaPods
1.16.2 on Ruby 4.0.5 raises `Encoding::CompatibilityError` out of
`unicode_normalize` before it reads the Podfile.

## What the built product did

Installed to an iPhone 17 Pro simulator with `simctl install` and launched with
`simctl launch com.hiregrain.appshell`. Metro bundled 1,968 modules. The screen
rendered the figure and its own caption, `23585 path commands, 89 threads`.

A two-finger pinch driven through the simulator zoomed the figure without a
crash, and the merged band separated into individually resolvable hairlines,
which is the property `strokeWidth={0}` is there for.

## What this does not establish

The Android half of criterion 4 is unrun: the machine has no Android toolchain
and no JDK 17. Criterion 6 is unrun: it is attested by the founder on his own
iPhone and Pixel, and a simulator is not a handset.

Nothing here is evidence about the PowerVR GE8320. Decision 085 waived that
evidence and left the risk open in `design/09` §6.
