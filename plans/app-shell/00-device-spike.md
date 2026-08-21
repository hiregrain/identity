---
id: app-shell/00
type: task
layer: app-shell
satisfies: [7]
status: in_progress
depends_on: []
binds:
  - decisions/LOG.md#040
  - decisions/LOG.md#044
  - design/09-app-framework-evaluation.md
evidence: []
verified_by: null
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

- **The imprint on the hardware.** The figure at 24,352 vertices through the
  1080 ms scribe and a pinch, on a sub-$120 gesture-navigation Android, with
  frame times captured rather than judged. Skia's own tracker carries a
  `SIGSEGV` crash-loop on a Xiaomi Redmi 9C, PowerVR GE8320, MediaTek Helio
  G35, which took three and a half months to close, and **Shopify ships
  precompiled binaries an app cannot patch**, so a recurrence is not something
  the app can work around.
- **The threads on a dpr-1 panel in daylight.** Whether the imprint's thread
  separation survives a one-device-pixel-ratio screen outdoors, which is the
  viewing condition this population actually has and which 044's pitch
  arithmetic assumes away.
- **A build proof for the ratified stack.** Expo SDK 57, React Native 0.86 and
  React 19.2.3 are treated as settled fact by every task here and by decision
  040. This spike resolves and builds them before anything assumes they compose
  cleanly, because a version that does not resolve blocks the layer entirely.

**Moved out of this spike.** The vendor SDK smoke test, Sumsub's iOS nil-modal
crash and the APK/AAB size delta were in an earlier draft of this task. They
are identity and distribution concerns, not renderer risk, and they belong to
`worker-identity-surface` and `app-distribution`. They are named in
`design/09` §6 and stay there; this task does not carry them.

## Acceptance

1. **The imprint survives the scribe and a pinch on named hardware.**
   (mechanical) on a **Xiaomi Redmi 9C or a device carrying the same PowerVR
   GE8320 and MediaTek Helio G35 pairing**, which is the exact configuration
   `design/09` records the `SIGSEGV` against, the figure renders through a full
   1080 ms scribe and a pinch across **20 consecutive cold starts** with zero
   crashes. Frame times are written to a trace file, not described.
2. **The scribe holds a stated frame budget.** (mechanical) during the scribe,
   **p95 frame time is at or below 33 ms and no single frame exceeds 100 ms**,
   read from the trace. Budgets are the layer's first measurement and may be
   revised once, in writing, before any task depends on them; they may not be
   revised after a run to make a result pass.
3. **The threads are countable on a dpr-1 panel outdoors.** (adjudicated) a
   verifier photographs the figure on a dpr-1 handset in daylight and states
   whether adjacent threads are separable. If they are not, 044's pitch rule
   needs the arithmetic redone at dpr 1 and that is the finding.
4. **The ratified stack resolves and builds.** (mechanical) Expo SDK 57, React
   Native 0.86 and React 19.2.3 resolve and produce a running debug build on
   both platforms, asserted from a real build rather than from the lockfile.
5. **The result is written down either way.** (mechanical) the findings land in
   `design/09` §6 as evidence, including a negative result. A spike that runs
   and records nothing has not run.

## What a bad result means, pre-committed

Recorded now so it is not argued after the fact, which is the discipline
`plans/t1-spike.md` used. An earlier draft of this task said a bad result
blocked nothing, while the layer said every task depended on it. **That made
the dependency performative and it is corrected here**: each outcome names what
it stops.

- **The imprint crashes, or misses criterion 2's frame budget.** Decision 040's
  renderer choice reopens and this layer **returns to `draft`**. Tasks 02 and
  03 may continue, because the palette and the type scale do not depend on the
  renderer. Task 01 continues. Task 05 continues. Nothing that draws the figure
  proceeds until 040 is re-ruled.
- **The threads are not separable at dpr 1.** Decision 044's pitch rule changes
  and the figure's meaning does not. The layer stays `ready`; `worker-surface`
  task 01 gains the revised pitch. Nothing here stops.
- **The stack does not resolve or build.** Everything stops. Decision 040's
  framework ruling reopens in full and the layer returns to `draft`, because no
  task in it can be written against a stack that does not exist.

This is why every other task declares `app-shell/00` as a dependency: not as a
formality, but because two of the three outcomes above change what those tasks
are allowed to assume.

## Outside check

The spike is itself an outside check: it is the one thing in this layer whose
result cannot be produced by reading the code.
