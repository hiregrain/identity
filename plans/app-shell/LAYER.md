---
id: app-shell
type: layer
status: ready
milestone: first-product
depends_on: [foundation]
soft_depends_on: [worker-surface, public-web]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#081
  - decisions/LOG.md#039
  - decisions/LOG.md#040
  - decisions/LOG.md#044
  - decisions/LOG.md#046
  - decisions/LOG.md#047
  - decisions/LOG.md#049
  - design/09-app-framework-evaluation.md
  - decisions/LOG.md#028
  - decisions/LOG.md#041
  - decisions/LOG.md#036
  - design/08-app-inventory.md
  - DESIGN.md#12
soft_blocks: [app-distribution]
evidence: []
verified_by: null
---

# app-shell

The native iOS and Android clients, and the platform contract every surface
inside them must satisfy. Split out of `worker-surface` on 2026-08-19 because
that layer scopes *what the worker sees* and explicitly assumed "responsive web
first, installable PWA before native" (a target that no longer holds), and a body
of work no layer owned.

**This layer owns the runtime, never the content.** Screens belong to
`worker-surface`, `peer-references` and `public-web`. What lives here is
everything that is true of every screen on a real device.

**The framework is ratified (decision 040): Expo SDK 57 (React Native 0.86,
React 19.2.3) with CNG and config plugins, expo-router, and
`@shopify/react-native-skia` as the imprint renderer.** Pin SDK 57; take 58
deliberately. The New Architecture is not a decision. RN 0.82 made it the only
architecture. `react-native-svg` is disqualified from source: it cannot express
hairline mode at all (`strokeWidth == 0` returns early), and hairline mode is what
`DESIGN.md` gap 10a requires.

**Local Expo modules, not ejecting.** `setSystemGestureExclusionRects` has no
wrapper anywhere in the ecosystem, verified against the published tarballs of
`react-native-screens`, `react-native-gesture-handler` and `react-native-svg`, and
react-native-gesture-handler closed the request `not_planned` in October 2024. It
needs a local Expo module of roughly 25 lines of Kotlin, no-op on iOS and web. Its
budget is also worse than the number suggests: 200dp **shared across every window
on the display**, per edge, walked bottom-up, silently truncated with no error.
Decision 037's second half, the index as an accelerator, never the only path,
is what actually satisfies criterion 2.

**Haptics are named.** `.rigid` (`UIImpactFeedbackGenerator.FeedbackStyle`) on
iOS, which is literally the seat's semantics, and `HapticFeedbackConstants.CONFIRM`
on Android. Recorded correction: `DESIGN.md` §10's premise that reduced motion
suppresses haptics is **unverified on both platforms** and is product policy, not
platform behaviour.

Scope: **the shells**: one design, three runtimes (iOS, Android, installable
PWA), with the PWA remaining a first-class target rather than a fallback, since
`06-worker-app-ia.md` §3 makes an arriving link the most common first session and
a link must not require an install; **safe areas and system chrome**: top and
bottom insets, status-bar appearance, the home indicator and the gesture bar,
none of which the 360×800 design frame accounts for; **system navigation**:
back on both platforms, and the edge-index collision recorded in
`design/08-app-inventory.md` §0.2 (Android 10+ takes a back-swipe from *both*
edges, and the app's only navigation sits on the right one); **dark mode**,
which `DESIGN.md` gap 6 defines as a rule and has never rendered, and which both
stores hand the app automatically; **text scaling**: iOS Dynamic Type and
Android font scaling to 200%+, against a type scale expressed entirely in fixed
px, and a reflow rule for the ledger row's `nowrap` figure column; **haptics**:
§7's "one hard haptic at contact" named per platform, and retained under
`prefers-reduced-motion` per §10; and **offline**: §12's rule that the record
stays readable from cache, which needs a storage and staleness contract.

**Reachability and distribution moved out (eng review, 2026-08-19).** Deep
links, push, launch identity and store submission are `app-distribution`. They
gate on the mark's open items and on counsel rather than on engineering, and
bundling them here made one grilling cover eleven unrelated problems against
`plans/ORDER.md`'s four-to-eight guidance.

**Localisation is shared, not owned here.** EN, then TL and HI. TL is Latin; **HI
is Devanagari and Archivo does not cover it** (`DESIGN.md` gap 7, recorded as
launch-blocking). This layer carries the platform plumbing; the companion
typeface is a founder gate.

**The mockup gate does not apply to this layer.** It owns the runtime, not the
content, and its criteria are assertions about how any screen behaves on a
device. Screens are gated in `worker-surface` and `public-web`.

Acceptance. Each of these is checkable from the code by someone who has never
seen this layer before. Where a check genuinely needs a phone, it says so.

1. **Nothing sits under the system's own furniture.** No interactive element's
   layout rectangle overlaps the safe-area insets: the notch, the home
   indicator, the Android gesture bar. Read from the layout tree, not from a
   screenshot.

2. **Moving around the record does not trigger the Android back gesture.** No
   touch target lies inside the system gesture zone unless the app has claimed
   that region, and no destination is reachable only through a target at the
   screen edge. Both are readable from the layout; the second is the one that
   matters, because the PWA cannot claim the region at all.

3. **Dark works because the numbers work, not because it looks fine.** Every
   colour pair in the dark palette clears the same contrast floors `DESIGN.md`
   §12 sets for light, computed from the tokens. No state is distinguishable in
   one appearance and not the other.

4. **Nothing breaks when text gets big.** No meaning-bearing text or spacing is
   a fixed pixel value, and no row that carries record data can clip or truncate
   at the largest system text setting. iOS AX5 Body is 3.12× the default and
   Android 14+ scales on a curve its own documentation warns against
   reproducing with a multiplier. The ledger row's right-hand figure column is
   `nowrap` today and has no reflow story, so it is the first thing to fix.

5. **The seat's haptic fires, including when motion is off.** `.rigid` on iOS,
   `HapticFeedbackConstants.CONFIRM` on Android, asserted at the call site.
   `DESIGN.md` §10 says the meaning survives without the motion, and this is
   what makes that true. Note that §10's assumption that reduced motion
   suppresses haptics is unverified on both platforms and is our policy, not the
   platform's behaviour.

6. **The record is still readable with no network.** On iOS this holds only for
   an installed Home Screen web app: WebKit deletes IndexedDB, local storage,
   the cache and the service worker after seven days without interaction, and
   exempts installed web apps by name. Installing is the storage model, not a
   distribution preference. On Android the app must claim persistent storage,
   because eviction is least-recently-used under disk pressure.

7. **The ratified renderer survives the hardware this product is for.** Two
   things need a real device and nothing in the code can stand in for them:
   whether the imprint's threads survive a dpr-1 panel in daylight, and whether
   Skia crashes on the PowerVR and MediaTek hardware this population carries.
   Both are open in `design/09` §6 and neither has been run. `design/09` records
   that the adversarial auditor argued nothing should be ratified before they
   did, and that it was right about the evidence. **Owned by `app-shell/00`,
   which every other task in this layer depends on**, because building a shell
   on an untested renderer is how a week of device time becomes a pilot
   failure.

**Outside check.** On a gesture-navigation Android under 3 GB of RAM, in
daylight: the shell boots, the record renders from cache with the network off,
the system text size at its largest does not clip a row, dark mode holds its
contrast, and no swipe from either edge reaches a destination that has no other
route to it.

**The end-to-end walkthrough moved.** An earlier version of this check asked a
stranger to open a shared link, create an account, add a chapter and find who
could read their record. **This layer owns none of that** (outside voice,
decision 079's review): no account flow, no chapter flow, no deep links, no
permissions surface. That walkthrough is `worker-surface`'s outside check and
belongs there, on the layer that builds every surface it touches.
