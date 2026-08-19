# The worker app — full inventory

2026-08-19. Every screen, component and state the app needs end to end, with
what exists, what does not, and what is blocked. Companion to
[`06-worker-app-ia.md`](06-worker-app-ia.md) (the structure) and
[`07-worker-app-design-review.md`](07-worker-app-design-review.md) (the defects
found in round 1).

**Status key.** `BUILT` — an artboard exists and has survived review round 1.
`TO BUILD` — specified here, not drawn. `BLOCKED` — needs a ruling or a gap
closed first, named inline.

---

## 0. Settled — recorded here because the reasoning is load-bearing

**All four items in this section were closed on 2026-08-19** by decisions 031 and
034. They are kept rather than deleted because each one cost real evidence, and
because §0.2 in particular is the kind of constraint a later reader will
rediscover the hard way. Read the resolutions first:

- **0.1 Platform** — native supersedes "PWA before native"; the PWA stays
  first-class from the same codebase; the web app is built in parallel
  (decision 031). Framework ratified as Expo SDK 57 + Skia (decision 034).
- **0.2 The right edge** — resolved by demoting the edge index to an accelerator,
  plus a local Expo module for `setSystemGestureExclusionRects`. The 200dp budget
  is worse than it reads: shared across every window on the display, per edge,
  walked bottom-up, silently truncated with no error. Nothing depends on hitting
  the strip.
- **0.3 Dark mode** — ships at v1 as a *second palette*, not a mechanical
  inversion (decision 031). §5's rule does not survive arithmetic.
- **0.4 Dynamic Type** — still the open engineering problem, now carried by
  `app-shell` AC-AS4. iOS AX5 Body is 3.12× the default; Android 14+ is
  non-linear and its docs warn against reproducing it with a scalar.

## 0-original. Four things to settle before building

**0.1 Platform. `plans/worker-surface/LAYER.md` says "responsive web first…
installable PWA before native."** Native iOS and Android deployment is a
different target and supersedes that line if taken. The design consequences are
real and not cosmetic: safe areas, system back, Dynamic Type, platform haptics,
app icon and launch screen, push permission timing, and store review. This
document assumes **native, with the PWA as the same design at a different
runtime** — but the LAYER needs amending either way, because it currently
records the opposite.

**0.2 The right edge is the system's, not ours.** Android 10+ gesture navigation
takes a back-swipe from **both** the left and right screen edges. The edge index
in `06` §4 lives at the right edge. On any gesture-nav Android device — which is
the target population's hardware — every attempt to use it will fire the system
back gesture instead. iOS only claims the left edge, so this is Android-specific
and it is disqualifying as drawn. Three ways out: move the index to the left
edge (fights iOS back instead), inset it far enough from the edge to clear the
~20dp system gesture zone, or replace it with a different affordance. **Needs a
decision; the current design does not survive contact with Android.**

**0.3 Dark mode is `DESIGN.md` gap 6 — "rule defined, never rendered."**
Decision 028 says "light by default, dark fully supported." Both stores expect a
dark appearance and both platforms hand it to the app automatically. Nothing has
been drawn. Every screen in this inventory needs a second appearance, and §5's
inversion rule ("the ink becomes the ground") is a sentence, not a palette —
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
| A1 | Launch / splash | TO BUILD |
| A2 | Signed-out lander | TO BUILD |
| A3 | Identifier — email or phone, verified control of one (`research/11`) | TO BUILD |
| A4 | One-time code entry | TO BUILD |
| A5 | Welcome back — recalled identity, masked, one tap | TO BUILD |
| A6 | Consent instrument, seven mechanics | BUILT |
| A7 | Full name — one field, any script | TO BUILD |
| A8 | Empty record | BUILT |
| A9 | First chapter — add by hand, or import a résumé | TO BUILD |
| A10 | Résumé upload and parse progress | TO BUILD |
| A11 | Imported chapters, review before commit | BUILT |
| A12 | Claim the address | BUILT |

### B · The record

| | Screen | Status |
|---|---|---|
| B1 | Core screen | BUILT |
| B2 | **Chapter detail** — every raw fact, every attestation, superseded versions | TO BUILD |
| B3 | Imprint, expanded — measures and standing | BUILT |
| B4 | Attestation landing ceremony | BUILT |

### C · Chapter management

| | Screen | Status |
|---|---|---|
| C1 | Add a chapter — party search, or a name we do not know | TO BUILD |
| C2 | Add a position inside a chapter | TO BUILD |
| C3 | Minor edits (028: only minor edits after commit) | TO BUILD |
| C4 | Why a chapter cannot be removed | TO BUILD |

### D · Getting work verified

| | Screen | Status |
|---|---|---|
| D1 | Outstanding verification (section of B1) | BUILT |
| D2 | Request attestation — registered party | TO BUILD |
| D3 | Ask a manager — invite, work-email path | TO BUILD |
| D4 | Ask a coworker | TO BUILD |
| D5 | Request sent, and its state afterwards | TO BUILD |

### E · The attester's side — moved to the web (decision 032)

Decision 029 gave every attester an account, which this document originally
scoped as six screens inside the app. **Decision 032 withdrew that.** An
invitation link opens the web attestation flow; the attester creates an account
and attests there; the app is where they later hold their own record if they
choose to. These surfaces belong to `public-web`, and the form itself to
`peer-references` — ledger-authored, no free-response field (decision 025).

Listed here only so the boundary is visible: invitation landing · sign-up as an
attester · work-email confirmation for the manager tier, which also verifies
their own chapter · the seven-measure form · submitted · their own empty record.
**None of them are app screens.**

### F · Identity verification

| | Screen | Status |
|---|---|---|
| F1 | Why now, what is taken, what is kept | TO BUILD |
| F2 | Document type and issuing country | TO BUILD |
| F3 | Capture, in Grain's chrome, vendor named | TO BUILD |
| F4 | Checking | TO BUILD |
| F5 | Result, and what a partner now sees | TO BUILD |
| F6 | Liveness — separate, declinable, after the document passes | TO BUILD |
| F7 | Could not verify — what to do next | TO BUILD |

### G · Sharing

| | Screen | Status |
|---|---|---|
| G1 | Sharing (section of B1) | BUILT |
| G2 | Public page management — on/off, imprint on/off, preview | TO BUILD |
| G3 | The public page, signed-in view | BUILT |
| G4 | The public page, logged-out and crawler view (029: reduced) | TO BUILD |
| G5 | Create a grant or a share link — expiry, what they receive | TO BUILD |
| G6 | Grant detail and revocation (sheet in B1) | BUILT |

### H · Account

| | Screen | Status |
|---|---|---|
| H1 | Account, read-only | BUILT |
| H2 | Notification preferences | TO BUILD |
| H3 | Language | TO BUILD |
| H4 | Ask for an export — 24 hours, by email (030) | TO BUILD |
| H5 | Ask who has read the record — the Art. 15(1)(c) disclosure record | TO BUILD |
| H6 | Contact support — the route for every account change (030) | TO BUILD |
| H7 | Ask us to delete everything — **files the request, never executes it** (032) | TO BUILD |
| H7a | Deletion requested — the grace-period state, and what resets it | TO BUILD |
| H7b | Unlock — biometrics or device passcode, declinable, default on (032) | TO BUILD |
| H8 | Sign out | TO BUILD |

### I · System and platform

| | Screen | Status |
|---|---|---|
| I1 | Offline — the record still readable from cache (§12) | TO BUILD |
| I2 | Something went wrong, with a retry | TO BUILD |
| I3 | Address not found — a handle that does not resolve | TO BUILD |
| I4 | Update required | TO BUILD |
| I5 | Signed out unexpectedly | TO BUILD |
| I6 | Camera permission | TO BUILD |
| I7 | Notification permission | TO BUILD |
| I8 | Push notification content, per event | TO BUILD |
| I9 | App icon and launch screen | BLOCKED — `mark/README.md` lobe count and break angle are provisional |
| I10 | Terms, privacy, how the record works | TO BUILD |

**App count: 9 built, 36 to build, 1 blocked.** Six further surfaces sit on the web (§E).

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

- **The person-mark** — every human rendered as their own mini-imprint rather
  than a photo or initials. Needed the moment attesters exist (E4, E5) and on
  chapter detail (B2). This is the element §9 calls the person-mark and it has
  no drawing.
- **Loading as an arc scribing** — §12 says loading is the scribing arc, never a
  spinner. Nothing uses it; A10, F4 and I1 all need it.
- **Progress as a band closing** — needed by A10 and F4.
- **The place mark** for any location reference.
- **Rhumb connectors** for relationships — the attester-to-worker link in E and
  B2 is exactly this.
- **Tab indicators as arc segments** — needed when Work and Earnings arrive.

### Not specified anywhere, and required

- **One-time-code input** (A4) — six boxes, paste handling, resend timer.
- **Phone input with country selection** (A3) — and `research/11` says treat a
  Philippine RA 11934 number as higher assurance, which the control must carry.
- **Month picker** (C1, C2) — month precision only, never day, per the schema.
- **Party search** (C1) — registered parties, plus a free-text fallback that
  never auto-resolves to a `party_ref`.
- **Toggle** (G2, H2) — must use the state grammar, not a platform switch.
- **Toast or inline confirmation** — nothing in the system acknowledges a
  completed action.
- **Skeleton or placeholder state** for every list.
- **Camera frame** (F3) — the plate's registration corners have an honest job
  here, which is the one place they are not decoration.
- **Pull to refresh**, or a deliberate refusal of it.
- **Search within work history** — probably a refusal; most records are small.
- **Segmented control** — probably a refusal; the state grammar covers it.
- **Icons.** §8 allows roughly eight, drawn in-house, 24px grid, 1.5px hairline,
  square terminals, never filled. Three exist (close, index, capture). The set
  needs: back, add, camera, share, external link, check-free confirmation.

### Every surface needs five states

Currently drawn once, on one screen each, and missing everywhere else:
**loading** (the scribing arc) · **empty** · **error with a retry** ·
**offline** (§12: a micro-caption band, record still readable from cache) ·
**permission denied**.

---

## 3. Platform chrome

**Safe areas.** Every artboard is a 360×800 rectangle with no insets. Both
platforms require top and bottom insets; the plate's footer band and the fixed
CTA blocks all currently sit where the home indicator and the gesture bar go.

**Back.** iOS takes the left edge; Android gesture nav takes both. See 0.2.
Beyond the edge index, nothing in the app draws a back affordance — the sheets
have a Close, the pushed screens do not exist yet.

**Haptics.** §7 requires "one hard haptic at contact" on the seat and §10
requires the haptic survive `prefers-reduced-motion`. Nothing implements it, and
the design record never specifies which haptic — iOS `UIImpactFeedbackGenerator`
has three weights, Android `VibrationEffect` has predefined effects. **The seat's
haptic needs naming per platform or it will be picked by an engineer.**

**Deep links.** `hiregrain.com/u/<handle>` must open the app when installed and
the web page when not — universal links on iOS, App Links on Android, both
requiring a hosted association file. This also decides what a viewer without the
app sees, which ties to G4.

**Localisation.** EN, then TL and HI. TL is Latin. **HI is Devanagari, and
Archivo does not cover it** — `DESIGN.md` gap 7, recorded as launch-blocking.
Nothing can ship in Hindi until a companion face is chosen, and §6's whole
hierarchy rests on a width axis the fallback stack does not have.

**Notifications.** Per `plans/worker-surface/LAYER.md`, three events: a party
attested, a grant is about to expire, a dispute deadline. Decision 029 removes
read events. Each needs written content, and the permission prompt needs a
moment — asking at launch is the pattern that gets denied.

---

## 4. What this inventory changes

Two things follow from writing it down that were not visible before.

**The attester side was roughly a fifth of the remaining app work, and decision
032 moved it off the app entirely.** It was created by a decision about trust
rather than about design (029, reversing 028), and putting it on the web removes
the app's dependency on the product's scarcest action being completable on a
phone. It is still the growth loop, and still not deferrable — it is simply
`public-web`'s problem.

**Nine of fifty-two screens are drawn.** The nine that exist are the ones that
argue the thesis; the forty-two that do not are the ones that make it an app. The
gap between "the design is settled" and "ready for deployment" is that ratio.
