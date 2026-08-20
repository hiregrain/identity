# The worker app, full inventory

2026-08-19, revised 2026-08-20 after decisions 053 to 060. Every screen,
component and state the app needs end to end, with what exists, what does not,
and what is blocked. Companion to
[`06-worker-app-ia.md`](06-worker-app-ia.md) (the structure) and
[`07-worker-app-design-review.md`](07-worker-app-design-review.md) (the defects
found in round 1).

**Status key.** `BUILT` means an artboard exists and has survived review round 1.
`TO BUILD` means specified here, not drawn. `BLOCKED` means needs a ruling or a gap
closed first, named inline.

**No count of screens appears in this file.** The original carried three that
disagreed with each other within a day, which is the failure CLAUDE.md names.
Read the tables, or let `ls design/10-worker-app-screens/*.dc.html` count.

---

## 0. Settled, recorded here because the reasoning is load-bearing

**All four items in this section were closed on 2026-08-19** by decisions 037 and
040. They are kept rather than deleted because each one cost real evidence, and
because §0.2 in particular is the kind of constraint a later reader will
rediscover the hard way. Read the resolutions first:

- **0.1 Platform.** Native supersedes "PWA before native"; the PWA stays
  first-class from the same codebase; the web app is built in parallel
  (decision 037). Framework ratified as Expo SDK 57 + Skia (decision 040).
- **0.2 The right edge.** Resolved by demoting the edge index to an accelerator,
  plus a local Expo module for `setSystemGestureExclusionRects`. The 200dp budget
  is worse than it reads: shared across every window on the display, per edge,
  walked bottom-up, silently truncated with no error. Nothing depends on hitting
  the strip.
- **0.3 Dark mode.** Ships at v1 as a *second palette*, not a mechanical
  inversion (decision 037). §5's rule does not survive arithmetic.
- **0.4 Dynamic Type.** Still the open engineering problem, now carried by
  `app-shell` criterion 4. iOS AX5 Body is 3.12× the default; Android 14+ is
  non-linear and its docs warn against reproducing it with a scalar.

## 0-original. Four things to settle before building

**0.1 Platform. `plans/worker-surface/LAYER.md` says "responsive web first…
installable PWA before native."** Native iOS and Android deployment is a
different target and supersedes that line if taken. The design consequences are
real and not cosmetic: safe areas, system back, Dynamic Type, platform haptics,
app icon and launch screen, push permission timing, and store review. This
document assumes **native, with the PWA as the same design at a different
runtime**, but the LAYER needs amending either way, because it currently
records the opposite.

**0.2 The right edge is the system's, not ours.** Android 10+ gesture navigation
takes a back-swipe from **both** the left and right screen edges. The edge index
in `06` §4 lives at the right edge. On any gesture-nav Android device, which is
the target population's hardware, every attempt to use it will fire the system
back gesture instead. iOS only claims the left edge, so this is Android-specific
and it is disqualifying as drawn. Three ways out: move the index to the left
edge (fights iOS back instead), inset it far enough from the edge to clear the
~20dp system gesture zone, or replace it with a different affordance. **Needs a
decision; the current design does not survive contact with Android.**

**0.3 Dark mode is `DESIGN.md` gap 6, "rule defined, never rendered."**
Decision 028 says "light by default, dark fully supported." Both stores expect a
dark appearance and both platforms hand it to the app automatically. Nothing has
been drawn. Every screen in this inventory needs a second appearance, and §5's
inversion rule ("the ink becomes the ground") is a sentence, not a palette.
`--rule` at 3.35:1 on paper is not 3.35:1 inverted, and the imprint's hairlines
behave differently on dark ground.

**0.4 Dynamic Type and font scaling.** Every size in the system is a fixed px
value. iOS Dynamic Type and Android font scaling both go to 200%+, and refusing
to scale is an accessibility failure on both stores. §6's scale needs a
relative-unit expression and a reflow rule for the ledger rows, whose right-hand
figure column has `white-space:nowrap`.

---

## 1. Screens

### A · First run and authentication

| | Screen | Status |
|---|---|---|
| A1 | Launch / splash | BUILT |
| A2 | Signed-out lander | BUILT |
| A3 | Identifier, email or phone, verified control of one (`research/11`) | BUILT |
| A4 | One-time code entry | BUILT |
| A5 | Welcome back, recalled identity, masked, one tap | BUILT |
| A6 | Consent instrument, four mechanics at signup, the rest said where they bind (058) | BLOCKED, decision 054's gate: what consent says about measures collected and not rendered is unwritten |
| A7 | Full name, one field, any script | BUILT |
| A8 | Empty record | BUILT |
| A9 | First chapter, add by hand, or import a résumé | BUILT, the same screen as C1, reached from the empty record |
| A10 | Résumé upload and parse progress | BUILT |
| A11 | Imported chapters, review before commit | BUILT |
| A12 | Claim the address | BUILT |

### B · The record

| | Screen | Status |
|---|---|---|
| B1 | Core screen | BUILT |
| B2 | **Chapter detail**, every raw fact, every attestation, superseded versions | BUILT |
| B3 | Imprint, expanded. A chapter walker and a legend for what the figure encodes; measures no longer render (054) | BUILT |
| B4 | Attestation landing ceremony | BUILT |

### C · Chapter management

| | Screen | Status |
|---|---|---|
| C1 | Add a chapter, party search, or a name we do not know | BUILT |
| C2 | Add a position inside a chapter | BUILT |
| C3 | Minor edits (028: only minor edits after commit) | BUILT |
| C4 | Why a chapter cannot be removed | BUILT |

### D · Getting work verified

| | Screen | Status |
|---|---|---|
| D1 | Outstanding verification (section of B1) | BUILT |
| D2 | Request attestation, registered party | BUILT |
| D3 | Ask a manager, invite, work-email path | BUILT |
| D4 | Ask a coworker | BUILT |
| D5 | Request sent, and its state afterwards | BUILT |

### E · The attester's side, moved to the web (decision 038)

Decision 035 gave every attester an account, which this document originally
scoped as six screens inside the app. **Decision 038 withdrew that.** An
invitation link opens the web attestation flow; the attester creates an account
and attests there; the app is where they later hold their own record if they
choose to. These surfaces belong to `public-web`, and the form itself to
`peer-references`, ledger-authored, no free-response field (decision 025).

Listed here only so the boundary is visible: invitation landing · sign-up as an
attester · work-email confirmation for the manager tier, which also verifies
their own chapter · the seven-measure form · submitted · their own empty record.
**None of them are app screens.**

### F · Identity verification

| | Screen | Status |
|---|---|---|
| F1 | Why now, what is taken, what is kept | BUILT |
| F2 | Document type and issuing country | BUILT |
| F3 | Capture, in Grain's chrome, vendor named | BUILT |
| F4 | Checking | BUILT |
| F5 | Result, and what a partner now sees | BUILT |
| F6 | Liveness, separate, declinable, after the document passes | BUILT |
| F7 | Could not verify, what to do next | BUILT |

### G · Sharing

| | Screen | Status |
|---|---|---|
| G1 | Sharing (section of B1) | BUILT |
| G2 | Public page management, on/off, imprint on/off, preview | BUILT |
| G3 | The public page, signed-in view | BUILT |
| G4 | The public page, logged-out and crawler view (041: reduced). Imprint to human visitors, never to the crawler (056) | BUILT |
| G5 | Send the record to a named person, expiry, what they receive (057) | BUILT |
| G6 | Grant detail and revocation (sheet in B1) | BUILT |
| G7 | The grant as its recipient reads it | BUILT |

### H · Account

| | Screen | Status |
|---|---|---|
| H1 | Account, read-only | BUILT |
| H1a | The ledger, every entry in order (059) | BUILT |
| H2 | Notification preferences | BUILT |
| H3 | Language | BUILT |
| H4 | Ask for an export, 24 hours, by email (036) | BUILT |
| H5 | Ask who has read the record, the Art. 15(1)(c) disclosure record. Required by 035 B4, which surfaces no read events anywhere | BUILT |
| H6 | Contact support, the route for every account change (036) | BUILT |
| H7 | Ask us to delete everything, **files the request, never executes it** (038) | BUILT |
| H7a | Deletion requested, the grace-period state, and what resets it | BUILT |
| H7b | Unlock, biometrics or device passcode, declinable, default on (038) | BUILT |
| H8 | Sign out | BUILT |

### I · System and platform

| | Screen | Status |
|---|---|---|
| I1 | Offline, the record still readable from cache (§12) | BUILT |
| I2 | Something went wrong, with a retry | BUILT |
| I3 | Address not found, a handle that does not resolve | BUILT |
| I4 | Update required | BUILT |
| I5 | Signed out unexpectedly | BUILT |
| I6 | Camera permission | BUILT |
| I7 | Notification permission | BUILT |
| I8 | Push notification content, per event | BUILT |
| I9 | App icon and launch screen | BLOCKED, `mark/README.md` lobe count and break angle are provisional |
| I10 | Terms, privacy, how the record works | BUILT |

Six further surfaces sit on the web (§E).

---

## 2. Components

### Built and reviewed

Type registers (§6, now nine including `data`) · ledger row with state gutter ·
row with positions as inner divisions · section head · the five provenance
swatches · the plate header and footer bands · registration corners (record
surfaces only) · edge index (see 0.2) · primary, secondary and tertiary buttons ·
bottom sheet with scrim · ink-inversion danger block · the ruled input · chips ·
the scale rule as a control · the anchor ladder · the imprint · the mark at two
tiers · the graticule ground.

### Specified in `DESIGN.md` §9 and never built

- ~~The person-mark.~~ **Deleted by decision 044**, not outstanding. A
  per-person figure implies a per-person claim, and an attester is not a subject
  of the record (entry 007). A party is named in words. This entry is struck
  rather than removed because the deletion is the useful fact.
- ~~Loading as an arc scribing.~~ **Built.** `.arc` in the chassis, one lobe
  period of the figure's own wave scribed and released, carrying no percentage,
  because an arc that claims to know how long is the lie a spinner tells.
- ~~Progress as a band closing.~~ **Built.** `.band`, for the one case where the
  length is genuinely known.
- **The place mark** for any location reference.
- **Rhumb connectors** for relationships, the attester-to-worker link in E and
  B2 is exactly this.
- **Tab indicators as arc segments**, needed when Work and Earnings arrive.

### Not specified anywhere, and required

Everything struck below is now in the shared chassis (`tpl/_chrome.part`,
`tpl/_icons.part`, `tpl/_swatches.part`) and drawn on the **Components** board,
which exists so a screen never invents a second version of something the system
already has.

- ~~**One-time-code input** (A4), six boxes, paste handling, resend timer~~ **Built.** **One-time-code input.** Built as six ruled fields rather than six boxes: §8 deletes containers, and a box per digit is six of them.
- ~~**Phone input with country selection** (A3)~~ **Built.** **Phone input with country selection.** Built into A3, showing the country, because `research/11` treats a Philippine RA 11934 number as higher assurance and a field that hides its country cannot carry that.
- ~~**Month picker** (C1, C2), month precision only, never day, per the schema~~ **Built.** **Month picker.** Built into C1 and C2, month precision only.
- ~~**Party search** (C1), registered parties, plus a free-text fallback that
  never auto-resolves to a `party_ref`~~ **Built.** **Party search.** Built into C1, with a free-text fallback that never auto-resolves to a `party_ref`.
- ~~**Toggle** (G2, H2)~~ **Built.** A 26px-high switch is the platform shape and it fails 2.5.8 on both platforms.
- ~~**Toast or inline confirmation~~ **Built.** Under the thing that changed, never a floating toast, which steals focus and leaves before a slow reader has finished.
- ~~**Skeleton or placeholder state** for every list~~ **Built.** Rules at the row rhythm, no shimmer, since §5 forbids a moving gradient.
- ~~**Camera frame** (F3), the plate's registration corners have an honest job
  here, which is the one place they are not decoration~~ **Built.** **Camera frame.** Built, and the registration corners have their one honest job in it.
- **Pull to refresh**, or a deliberate refusal of it.
- **Search within work history.** Probably a refusal; most records are small.
- **Segmented control.** Probably a refusal; the state grammar covers it.
- **Icons.** §8's set is drawn: back, add, camera, link, tick and alert in
  `tpl/_icons.part`, with close, the chevron and share as inline paths in the
  chassis. 24px grid, 1.5px hairline, square terminals, never filled.

### Every surface needs five states

All five are now drawn, each on its own board, and each is in the chassis
rather than in one screen's helmet: **loading** (the scribing arc, and the
closing band where the length is known) · **empty** · **error with a retry** ·
**offline** (§12's micro-caption band, the record still readable from cache) ·
**permission denied** (camera, and notifications). What remains is applying
them per surface, which is a build concern rather than a design gap.

---

## 3. Platform chrome

**Safe areas.** Closed by decision 046. Every artboard is fluid in both axes on
a 752 minimum, the common safe box across iOS and Android with gesture nav, and
the device frames in `ShellIOS`/`ShellAndroid` reserve the insets rather than
painting fake chrome. Verified at 402x874 and 360x640.

**Back.** iOS takes the left edge; Android gesture nav takes both. See 0.2. The
edge index was removed (048) because it sat inside Android's gesture strip. The
sheets have a Close; a pushed screen needs a back affordance that is not an edge
swipe, which is why `.pushhead` exists in the chassis.

**Haptics.** §7 requires "one hard haptic at contact" on the seat and §10
requires the haptic survive `prefers-reduced-motion`. Nothing implements it, and
the design record never specifies which haptic. iOS `UIImpactFeedbackGenerator`
has three weights, Android `VibrationEffect` has predefined effects. **The seat's
haptic needs naming per platform or it will be picked by an engineer.**

**Deep links.** `hiregrain.com/u/<handle>` must open the app when installed and
the web page when not, universal links on iOS, App Links on Android, both
requiring a hosted association file. This also decides what a viewer without the
app sees, which ties to G4.

**Localisation.** EN, then TL and HI. TL is Latin. **HI is Devanagari, and
Archivo does not cover it**, `DESIGN.md` gap 7, recorded as launch-blocking.
Nothing can ship in Hindi until a companion face is chosen, and §6's whole
hierarchy rests on a width axis the fallback stack does not have.

**Notifications.** Per `plans/worker-surface/LAYER.md`, three events: a party
attested, a grant is about to expire, a dispute deadline. Decision 035 B4
removes read events, from notifications and from every surface. Each needs written content, and the permission prompt needs a
moment. Asking at launch is the pattern that gets denied.

---

## 4. What this inventory changes

Two things follow from writing it down that were not visible before.

**The attester side was roughly a fifth of the remaining app work, and decision
038 moved it off the app entirely.** It was created by a decision about trust
rather than about design (041, reversing 028), and putting it on the web removes
the app's dependency on the product's scarcest action being completable on a
phone. It is still the growth loop, and still not deferrable. It is simply
`public-web`'s problem.

**What is drawn is the argument. What is missing is the app.** The screens that
exist are the ones that carry the thesis: the record, what a reader sees, what
the worker controls. The ones that do not are the ones that let a person get in,
put something on it, and ask anybody to sign it.
