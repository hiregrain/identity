# The platform seam

Where Grain's components stop and the system's begin, on iOS and on Android,
with the mechanism named on each side.

Written against the published platform documentation read on 2026-08-20, cited
inline. Decision 047 ruled that the component language stays Grain's own and
that platform mechanics are owed but undrawn; this document is the owed half,
narrowed by the founder ruling recorded below.

## TLDR

**The seam is not "Grain's look, the platform's plumbing." It is one test: Grain
keeps a control only where the platform's version is worse, never where it is
merely different.** Different is not a reason. Worse has to be shown, and in
this document it is shown exactly twice: the switch, which fails a contrast
target the platform's own switch cannot meet, and the record itself, which
exists to render identically on both phones.

**Two published rules contradict the design system, and one of them cannot be
satisfied by drawing more carefully.** Apple's current guidance tells apps not
to give a toolbar a background at all, and tells them not to put the app's name
in the bar. `DESIGN.md` §7 forbids the floating material Apple offers instead,
and the worker app's masthead is the Grain lockup. The first resolves through
the hard scroll edge effect. The second was ruled on review: the lockup is not
on the record at all.

**The bar ends up carrying two marks and nothing else.** No title, no lockup, no
word, no count: a sharing mark and an account mark, split across the two edges.
Each thing removed was removed for its own reason, argued below, and the quiet
strip is the result rather than the goal.

**Text entry goes to the system without exception, including the one-time
code.** The six ruled fields are the highest-cost component in the app: they
defeat the SMS autofill that both platforms provide, in a product whose
population is on cheap handsets and shared phones.

## The rule, and why it is a test rather than a list

A list of adopted components ages badly and invites litigation per component.
The test does not:

> Grain keeps a control only where the platform's version is worse. Worse means
> a named failure against a target this repo already committed to, not an
> aesthetic preference.

The target that does the work is decision 046, WCAG 2.2 AA and the EAA. It is
measurable, it is already binding, and it is the only ground on which "worse"
can be argued without taste entering. Everything in the table below resolves
under that test.

Three things sit outside the test entirely and stay Grain's by construction,
because they are the record rather than the interface to it: the imprint, the
provenance marks, and the ledger row. Decision 047's reason still governs them.
A pending record must not be able to pass as a verified one because it is being
read on a different phone.

## Where the platform documentation contradicts the design system

### Apple does not want the bar to have a background

`DESIGN.md` §7 says depth presses down, nothing floats, and sheets get a
hairline and a contact line rather than an elevation shadow. The masthead is
drawn as an opaque paper band with a 1px ink rule under it.

Apple's Toolbars guidance says the opposite, and says it about custom
backgrounds specifically:

> Reduce the use of toolbar backgrounds and tinted controls. Any custom
> backgrounds and appearances you use might overlay or interfere with background
> effects that the system provides. Instead, use the content layer to inform the
> color and appearance of the toolbar, and use a `ScrollEdgeEffectStyle` when
> necessary to distinguish the toolbar area from the content area.

The Layout page repeats it as a positive instruction: controls and navigation
appear on top of content rather than on the same plane, and "instead of a
background, use a scroll edge effect to provide a transition between content and
the control area." The Materials page names what fills that layer: Liquid Glass,
which "floats above the content layer" and lets content "scroll and peek
through."

Note also that the page a reader would look for does not exist any more.
`human-interface-guidelines/navigation-bars` redirects to `toolbars`. The
navigation bar is no longer its own component in Apple's model; it is a toolbar
along the top edge.

**This resolves, and §7 survives.** The Scroll views page, updated 2026-06-08,
gives the scroll edge effect three styles: automatic, hard and soft. The **hard
style** is the system's own mechanism for an opaque-reading separation between
content and the bar area. Taking it means Grain gives the toolbar no background,
which is what Apple asks, and still gets a definite edge rather than a floating
pane of glass, which is what §7 asks. Nothing floats, no elevation shadow, no
custom background. Apple prefers the automatic style, so choosing hard is a
deliberate divergence and is recorded here as one.

What Grain does not get is the material. Liquid Glass is refused, and the reason
is not brand preference: the thing that would pass under a translucent bar is
the imprint, which is a hairline drawing, and a blurred hairline is not a
degraded hairline but an absent one. That is a legibility argument, so it holds
under the test in the section above.

### Apple says the app's name is not a title

> Don't title windows with your app name. Your app's name doesn't provide useful
> information about your content hierarchy or any window or area in your app, so
> it doesn't work well as a title.

The masthead's left-hand element is the GRAIN lockup, which is the app's name.
The same page asks for a title under 15 characters.

This one is not resolved by a technique. It is a call about where the brand sits
on the surface a worker screenshots, and it is raised as a decision gate below.
The arrangement proposed in this document assumes it goes Apple's way, and shows
what the lockup does instead.

## The seam, behaviour by behaviour

Owner is who draws it. Mechanism is what it resolves to on each platform.

| Behaviour | Owner | iOS mechanism | Android mechanism |
|---|---|---|---|
| Safe areas and insets | System | Safe area layout guide | `WindowInsets`, system bars, cutout, gesture |
| Edge to edge | System | Default since the notch | Enforced targeting SDK 35 on Android 15 and up |
| Status bar glyph colour | Grain sets, system draws | Dark content on paper | Light-theme system bar icons |
| Top bar container | System | Toolbar, no background, hard scroll edge effect | Top app bar behind the status bar, opaque paper container |
| Top bar contents | Grain | Two marks, sharing and account | Two marks, sharing and account |
| Bar contents on a pushed screen | Split | Back, with the previous screen's title | Back, with the previous screen's title |
| Scroll physics and indicators | System | Scroll view | Scroll container |
| Pull to refresh | Neither, refused | Record is push-updated | Record is push-updated |
| Back | System | Interactive pop, left edge | Predictive back, `OnBackPressedDispatcher` |
| Sheets | System | Sheet presentation, detents, grabber | Modal bottom sheet, drag handle |
| Destructive confirmation | System | Alert | Dialog |
| Share out | System | Activity view | Share sheet |
| Text entry and keyboard | System, Grain skin | `UITextField`, keyboard type, return key | `EditText` or `TextField`, IME action |
| One-time code | System | Single field, `oneTimeCode` content type | Single field, SMS OTP autofill hint |
| Month selection | System presentation, Grain contents | Sheet with month and year | Dialog with month and year |
| Switch | **Grain** | Fails 2.5.8 at the platform size | Fails 2.5.8 at the platform size |
| Text scaling | System | Dynamic Type to accessibility sizes | System font scale |
| Screen reader order and naming | Grain declares, system reads | VoiceOver | TalkBack |
| Haptics | Grain names, system plays | `UIImpactFeedbackGenerator` | `HapticFeedbackConstants` |
| Deep links | System | Universal links | App Links |
| The record: rows, marks, imprint | **Grain** | Drawn | Drawn, identically |

Two rows carry Grain in bold, and both earn it under the test. The switch fails
WCAG 2.2 2.5.8 at the platform's own 26px height, which decision 047 already
recorded. The record is the subject of 047's reason and is not reopened here.

Three mechanism claims in that table were read as API names rather than seen
working, and are marked here rather than presented as verified: the iOS
one-time-code content type, the Android SMS OTP autofill hint, and whether the
iOS toolbar carries a subtitle slot beneath a large title. The first two are
load-bearing for the ruling on the one-time code and should be confirmed against
a running device before any plan binds them.

## The record's home page, rearranged

The instruction was not to paste the existing screen into a device frame. What
follows changes what each piece is, not where it sits.

**The name stays in the record and does not rise into the bar.** The first draft
handed it to the platform's large-title mechanism, which collapses a title into
the bar on scroll. Drawn and driven, that was wrong twice over. The transition
itself was ugly for a reason worth recording: the bar's backing was fading in
over 180ms, so the title was visible *through* the bar for the whole time it
passed underneath. A hard scroll edge effect is a state, not a fade. And once
the transition was fixed the collapsed title still earned nothing: a record is
one person's document, unlike the list-shaped screens the pattern exists for, so
there is nothing to lose track of.

**The lockup is not on the record.** Apple rules it out of the bar. A colophon
at the foot was drawn as the alternative and cut on review, on the same ground
that removed the masthead: a product signing someone else's record is the
objection, and moving it lower only makes it quieter. Grain's name lives on the
app icon, the launch screen, the public page and the share surface. The worker's
record carries the worker's record.

**Sharing is a mark, and it carries no count.** A number beside a glyph is a
badge, and this product refuses to compress a graded fact into a symbol
everywhere else. How many parties hold a grant, until when, and whether the
public page is on are facts, so they are stated in words on the sharing surface.
An exposure sentence at the foot of the record was drawn and cut for the same
reason decision 045 moved sharing off the record in the first place.

**The two marks split across the two edges**, account leading and sharing
trailing, so that identity and action are not a matched pair of glyphs at the
same weight. A 19px mark centred in a 44px target needs the bar inset at 7.5px
for its edge to land on the record's own 20px margin; at 12px it sat 4.5px
inside the text column, which is the kind of misalignment that reads as
carelessness without being nameable.

**The provenance sentence stays in the content, directly under the title.**
"Identity document checked, which says nothing about the work below" is the
sentence decision 055 fought for, and it belongs next to the name it qualifies,
not in chrome. Whether a title subtitle slot exists is one of the unverified
items above; the sentence does not depend on it.

**Sharing and account stay as the bar's trailing items.** Two items is inside
Apple's crowding guidance, and 048 already settled that the account glyph is an
account glyph rather than a hamburger.

**The imprint keeps the top of the content, and drops to the small-tier mark
past a text-size threshold.** Decision 044 already defines a two-state imprint at
small sizes, so the mechanism exists. The threshold and the drawn result are
owed and are not asserted here; the founder ruling was that the figure gives way
to type, and the drawing has to prove the mark does not read as a demotion.

**Nothing else about the record moves.** Order is decision 035's, and 048's
finding still stands: the space chrome vacates goes back to the record.

## Android, where it differs and why that is allowed

Android's own guidance asks the top app bar to stretch to the top edge and draw
behind the status bar, and permits it to shrink to the status bar's height as
content scrolls. It does not carry Apple's instruction against bar backgrounds,
and there is no Liquid Glass equivalent, so an opaque paper container with a
fixed colour is ordinary Android rather than a fight.

The consequence is that the two bars will not look identical, and that is
correct. 047 binds the record to render identically, not the chrome. A bar that
matched across both platforms by ignoring both would be the copy-paste the
founder ruling rejected.

Three Android mechanics are not optional and are recorded so a plan cannot
discover them late:

**Edge to edge is enforced.** Targeting SDK 35 on Android 15 and up, the window
draws behind the system bars whether the app asks or not, and the opt-out is
going away. Insets have to be handled rather than avoided. `enableEdgeToEdge`
makes the system bars transparent, gives three-button navigation a translucent
scrim, and picks icon colours from the light or dark theme. Paper is a light
ground, so the light theme's dark icons are the correct pairing, and the founder
ruling requires that a dark surface reaching the status bar flip the appearance
rather than being forbidden outright.

**Predictive back is on by default**, and the developer option that used to gate
its animations was removed in Android 15. Intercepting `KEYCODE_BACK` is no
longer supported. Every pushed screen has to be a real navigation destination
reached through `OnBackPressedDispatcher` or `OnBackInvokedCallback`, or the
system has nothing to animate a preview of. This is a build constraint that
falls out of a design decision, which is why it is written here.

**Haptics go through `View.performHapticFeedback` with `HapticFeedbackConstants`
rather than the `Vibrator` API.** Google's guidance discourages `createOneShot`
and `createWaveform` as too loud for ordinary feedback, and the constants route
needs no `VIBRATE` permission and honours the user's system setting. §7's one
hard haptic at the seat still needs its constant named on both platforms, which
`design/08` §3 flagged and this document does not close.

## Buttons, once the sheet is the platform's

The question a borrowed sheet raises immediately: if the container is the
system's, whose are the controls inside it. The test in this document already
answers it, and the answer is not "follow the platform because we borrowed the
frame."

**The sheet's chrome is the platform's. The sheet's contents are Grain's.**
The grabber, the detent, the swipe to dismiss, the corner radius, the focus
trap and the leading Cancel are all presentation, and the platform's versions
are not worse. The primary action is a control with Grain's own verb on it,
sitting in Grain's own type, and `DESIGN.md` §8's button is not worse than a
platform button: it clears 2.5.8 at 44px and 1.4.3 at full ink on paper. So it
stays.

**The press behaviour stays too, and it is the reason to be careful here.**
§7 makes depth press down and rigidity express permanence: a verified row has
zero give, and that is product meaning rather than decoration. Platform bar
buttons inside the sheet, Cancel above all, take the platform's own highlight,
because they are the platform's controls. A Grain button keeps `.press`. The
two live in one sheet without conflict because they are different objects
doing different jobs.

**One action, once.** The sheet carried a leading Cancel, a trailing Send and a
Grain primary reading "Send the request": the same action twice, which Apple's
own sheets guidance warns against. Cancel keeps its leading position, the verb
keeps Grain's button, and the duplicate is gone.

**There is no red.** A proposal to choose between "the platform's red and ours"
for destructive actions has no ground to stand on: §5's palette is ink, paper,
rule, hairline and page, and the danger treatment is ink inversion rather than
hue. Destructive confirmation goes to a system alert, per the table above, and
a system alert is the system's surface entirely, so it uses the system's
styling. Inside Grain's own surfaces there is no red to clash with it.

## What is not settled

**Where the two marks sit** is the one thing still open on the bar: split across
the edges, which is what the prototype does, or sharing moved to a bottom
toolbar. The cost of the second is decision 048's arithmetic, which it does not
escape.

**Amendment owed to `DESIGN.md` §7.** Two sentences: a sheet takes the platform's
radius because it is not paper, and the top bar takes no background, with the
hard scroll edge effect standing in for the removed rule. Neither is written yet
and §7 currently contradicts both.

**The figure is the record's index.** A work-history row opens the imprint at
that ring rather than opening a chapter, and the chapter discloses in place
inside the figure's own list. There is no chapter screen: four facts is not a
destination, and the review that produced this said so. That makes the imprint
the way into the record rather than an illustration above it, which is a claim
about what the figure is FOR and wants a decisions entry rather than a
prototype.

**The identity sentence left the record.** Decision 055 put "Identity document
checked, which says nothing about the work below" on the record deliberately,
because that is the surface a worker screenshots and the careful version
belonged where it cost Grain something to say it. It was cut on review as
clutter. The defence is that saying nothing is safer than saying anything when
027's worry is a graded fact reading as a yes, and the check is stated on the
account surface. Either way 055 is live and this needs a superseding entry, not
a quiet deletion.

**Decisions owed, all of them raised by drawing rather than by planning:** the
055 supersession above; the figure-as-index claim; §7's two amendments, the
sheet's platform radius and the bar's absent background; and §8's icon rule,
which the chassis contradicts on every existing screen because `.iconbtn svg`
forces butt terminals over `.icon`'s square ones.

**The dynamic-type threshold for the imprint** is a number nobody has picked,
and the two-state result is undrawn at 100% and at 200%.

**The seat's haptic** still has no named constant on either platform, unchanged
from `design/08` §3.

**Right to left, and Devanagari.** Neither is touched here. `DESIGN.md` gap 7
remains launch-blocking for Hindi and no companion face is chosen.

## Sources

All read 2026-08-20.

- Apple, Human Interface Guidelines, Toolbars: https://developer.apple.com/design/human-interface-guidelines/toolbars
- Apple, Human Interface Guidelines, Layout: https://developer.apple.com/design/human-interface-guidelines/layout
- Apple, Human Interface Guidelines, Materials: https://developer.apple.com/design/human-interface-guidelines/materials
- Apple, Human Interface Guidelines, Scroll views: https://developer.apple.com/design/human-interface-guidelines/scroll-views
- Apple, Human Interface Guidelines, Sheets: https://developer.apple.com/design/human-interface-guidelines/sheets
- Apple, Human Interface Guidelines, Text fields: https://developer.apple.com/design/human-interface-guidelines/text-fields
- Apple, Human Interface Guidelines, Typography: https://developer.apple.com/design/human-interface-guidelines/typography
- Apple, Human Interface Guidelines, Playing haptics: https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- Android, Display content edge to edge: https://developer.android.com/develop/ui/views/layout/edge-to-edge
- Android, Predictive back gesture: https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture
- Android, Haptic feedback: https://developer.android.com/develop/ui/views/haptics/haptic-feedback
- Android, Optimize autofill: https://developer.android.com/identity/autofill/autofill-optimize
