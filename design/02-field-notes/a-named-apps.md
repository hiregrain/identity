# Field Notes A, Named Apps as Screens (Duolingo, Flighty, X)

Method: every note below is grounded in a screenshot captured from official sources
(App Store listings, blog.duolingo.com, flighty.com, X's own embed component) and
saved under `assets/a-named-apps/`. Mechanisms only; no trend articles consulted.

---

## Duolingo, the celebration economy

**1. Celebration is metered by a state ladder, not sprinkled.**
The in-lesson progress bar has discrete visual states: normal green fill; then at
a combo threshold the bar itself turns gold with sparkle particles around it
(`duolingo-lesson-screens-progressbar-states.png`, 4th phone). The reward is a
*state change of an existing element*, not a new overlay, cheap to notice,
impossible to miss, and it withholds until earned: the first three phones show the
same bar staying plain green.

**2. Buttons are physical objects: 2px darker bottom border as a "thickness" edge.**
Answer tiles and CTA buttons all carry a slightly darker bottom edge simulating
depth, and the selected tile swaps to a blue fill + blue border pair
(`duolingo-lesson-screens-progressbar-states.png`). The press interaction reads as
pushing the edge flat. The haptic pairs with a visible compression. Word-bank
chips change fill color (gray → green) when placed correctly: state = color swap
on the same shape, never a new shape.

**3. One active node; celebration color is reserved for the earned past.**
On the path screen, exactly one node has the "START" ring with an offset halo;
completed nodes are green check coins with gold stars beneath; future nodes are
gray (`duolingo-core-tabs-path-quests-leaderboard.png`). Gold appears only on
earned artifacts. Attention has a single destination per screen.

**4. The reward is drawn at the end of the progress bar.**
Quest bars are rounded pills with the fraction ("26/30", "270/300") printed inside
the bar and a treasure-chest icon docked at the bar's end
(`duolingo-core-tabs-path-quests-leaderboard.png`). The payoff is spatially
attached to the meter, so filling the meter visually approaches the prize.

**5. "You" is one full-row highlight in a factual list.**
The leaderboard renders every competitor as a plain row (rank, avatar, name,
right-aligned XP); the user's own row gets a full-width green tint and green XP
text, the only tinted row on screen
(`duolingo-core-tabs-path-quests-leaderboard.png`). Personal placement is a
background color, not a bigger font.

**6. Rarity is a material, and the number is embossed into the artifact.**
Personal-record badges are one mascot silhouette re-rendered in different
materials, lava/fire for Longest Streak 365, molten gold for Daily Most XP 624,
green slime for Perfect Lessons, holographic pastel for Highest League #3, each
with a soft glow halo on a dark field, with the record number rendered as part of
the badge itself (`duolingo-personal-record-badge-materials.png`). Achievement =
object you own, not stat you read.

**7. Escalating emotional state as retention pressure; the icon carries risk state.**
The home-screen widget is: streak flame + count, one short line, and Duo's face,
which degrades through the day from cheerful ("Let's get rolling!") to pleading to
sobbing to "Last chance!" with flames as midnight nears; the flame icon itself
turns red with an "!" when the streak is at risk
(`duolingo-widget-streak-escalation-states.png`). A single number + a character's
emotion encodes the whole state machine; no text explanation needed.

**8. Celebration as a social verb.**
In the friend feed, a milestone entry ("Did more than 10 lessons in a day") ships
with a bordered "CELEBRATE" button and stacked emoji reactions with counts
(`duolingo-core-tabs-path-quests-leaderboard.png`, feed phone). Duolingo per its
own blog reserves fresh animation spends for exactly three moments: streak
milestones, friend streaks, and lesson-end screens. Everything else stays static.

---

## Flighty, the live ledger and the passport

**9. Color is a state grammar applied to typographic facts.**
The flight detail screen prints times huge; green = confirmed actual ("11:40AM"
with the superseded "11:30AM" struck through beside it), pink/magenta with a
sparkle glyph = prediction ("Predicting 12:10AM ・ Departs in 1h 15m"), yellow
chips = physical facts (gate "F4", baggage "2"), gray = static metadata ("5h 50m ・
2,586 mi") (`flighty-flight-detail-prediction-colors.png`). Strikethrough keeps
the old value on screen, so every row shows its own change history, ledger, not
dashboard.

**10. Every alert carries its cause.**
The delay banner is two lines: bold state ("✦ Delayed 30m") then mechanism
("Grounded by thunderstorm until 12:00PM")
(`flighty-flight-detail-prediction-colors.png`). Same pattern in airport cards:
"Flights to JFK Grounded" + probability of extension ("30-60%")
(`flighty-inbound-plane-chain-timeline.png`). Stating the cause converts an
anxiety event into an information event. This is the "truth" register the whole
app trades on.

**11. Provenance chain: your row is the tail of a visible history.**
"Where's My Plane?" renders the aircraft's whole day as a vertical rail, prior
legs as rows ("San Diego to New York / Arrived 8:00AM", "New York to San
Francisco / Landing in 1h 10m") each with a right-aligned red lateness figure
("52m Late"), your flight at top with its predicted consequence
(`flighty-inbound-plane-chain-timeline.png`). The plane itself is an entity with
identity: type, tail number, age, even a name ("Airbus A321neo ・ N2002J ・ 3 years
old ・ Named 'Pretty Fly for a Blue Guy'"). Records feel alive because they point
at a specific physical thing that is somewhere right now.

**12. The shareable borrows the material language of official documents.**
The Flighty Passport card ends in a real machine-readable zone, monospaced
`2023<<<MARKUS<<<<<MEMBER12AUG19<<<<@FLIGHTYAPP<<` chevron-padded lines exactly
like a passport's MRZ, under a trilingual caps label ("PASSPORT ・ PASS ・
PASAPORTE") and an all-caps stat grid where units are set in a lighter weight than
digits ("93 931km", "132h 30m") (`flighty-passport-card-mrz-detail.png`). The
delay report card uses split-flap flip digits ("32 HRS lost to delays") and an
amber dot-matrix LED strip for the worst delay ("12 HOURS AU2317 VIE-MEX"); the
aircraft card is drawn as a blueprint with a seat map and class-split bar
(`flighty-passport-delay-aircraft-cards.png`). Pride mechanism: your data is
typeset as an *official artifact of a real-world system* (passport, departure
board, engineering drawing), so screenshotting it feels like showing a document,
not a stat screen. Even the marketing page background is a split-flap departure
board texture.

**13. Personal records are framed as comparable, arguable scoreboards.**
The delay report's framing ("Worst airline: United ・ 67 hours late in total",
bar-raced against other airlines) is built for the group chat argument. The
share card anticipates its social use
(`flighty-passport-delay-aircraft-cards.png`).

**14. The compact live row: route + two times + one status word.**
The Live Activity is one row, "SFO 09:10 → 17:12 JFK", "T1 ・ On Time" in green,
"Gate Departure in 43m", one yellow chip, legible at lock-screen glance
(`flighty-lockscreen-live-activity-forecast.png`). Its big sibling screen sets
times in terminal-green with strikethroughs and per-row chevrons; the punctuality
forecast is a histogram whose rows (Early / On Time / 15m late / ... / Canceled)
carry a green→amber→red color ramp, a probability distribution rendered as a
timetable (`flighty-lockscreen-live-activity-forecast.png`).

---

## X, what the restraint consists of

**15. Content is the largest type on screen; chrome is text.**
In the official tweet component, the tweet body is set larger than the author
name; author line is bold-name + gray @handle + gray timestamp all at one size;
metadata below in gray (`x-tweet-component-dark-light.png`). Feed tabs are plain
words, active = bold white with a short blue underline, inactive = gray, no
pills, no backgrounds (`x-feed-density-detail.png`).

**16. Two text colors + one accent, and the accent is meaning-bearing.**
The entire surface runs on primary text, secondary gray, and blue. Blue is
never decoration: it marks verification, links, and the active tab. Red exists
only as engaged-heart state (79K in red = you liked it)
(`x-feed-density-detail.png`, `x-tweet-component-dark-light.png`). Because color
is scarce, every colored pixel is information.

**17. What they deleted: containers.**
Tweets have no cards, borders, or alternating backgrounds in the feed. Rows
separate by hairline + whitespace; the only boxed element is a quoted tweet,
which gets a rounded hairline inset card, i.e. the container itself signals
"embedded object" (`x-feed-density-detail.png`). Buttons are ghost icons with
gray counts; the sole brand mark is a small centered logo in the top bar; bottom
nav is unlabeled monochrome outline icons
(`x-appstore-gallery-feed-profile.png`).

**18. Density via a fixed row anatomy, not smaller type.**
Every tweet repeats one anatomy: avatar left; name-line; body; action row of
icon+count pairs (reply, repost, like, views) spread across the full width;
bookmark/share right-aligned; "..." overflow top-right
(`x-feed-density-detail.png`). Scanning cost stays flat because the grid never
varies. Big numbers are compressed ("7.4M", "145K") and set gray so scale reads
without shouting; on the profile, the follower count is the hero figure
(`x-appstore-gallery-feed-profile.png`).

---

## Cross-cutting: what the three share mechanically

- **Single-accent discipline.** Duolingo's gold, Flighty's prediction-pink, X's
  blue: each app reserves one color for its highest-value signal and keeps it off
  everything else. The signal color is never used decoratively.
- **State changes mutate existing elements** (bar turns gold, time gets
  struck through and replaced, heart fills red) rather than spawning new UI.
  Change-in-place is what makes a screen feel "live."
- **Numbers carry the identity; labels are small caps or gray.** Duolingo streak
  counts, Flighty's stat grids, X's follower/engagement counts: digits big and
  heavy, units/labels light, a shared "instrument panel" typography.
- **The shareable artifact imitates a physical document class.** Flighty's
  passport/MRZ and split-flap board; Duolingo's badges as minted physical medals
  in different materials. Pride ≈ owning an object, so the pixel treatment
  borrows from objects (emboss, material, machine-print) rather than from charts.
- **Right-aligned fact columns produce the "timetable read."** Duolingo's XP
  column, Flighty's lateness column, X's action counts: scannable ledgers are
  left-text, right-number.

## Assets

All in `design/02-field-notes/assets/a-named-apps/`:

- `duolingo-lesson-screens-progressbar-states.png`, App Store gallery: tile physics, progress bar plain vs gold-sparkle state
- `duolingo-core-tabs-path-quests-leaderboard.png`, blog.duolingo.com core-tabs refresh: path nodes, quest bars with chest, "you" row highlight, CELEBRATE feed button
- `duolingo-personal-record-badge-materials.png`, personal-record badges as material-swapped mascot medals
- `duolingo-widget-streak-escalation-states.png`, widget states: Duo's mood + flame risk-state escalation
- `flighty-passport-card-mrz-detail.png`, passport shareable close-up with MRZ lines and stat grid
- `flighty-passport-delay-aircraft-cards.png`, passport / split-flap delay report / blueprint aircraft cards
- `flighty-flight-detail-prediction-colors.png`, flight detail: green actuals, pink predictions, strikethrough history, causal alert
- `flighty-inbound-plane-chain-timeline.png`, Where's My Plane inbound-leg provenance chain; named aircraft
- `flighty-lockscreen-live-activity-forecast.png`, lock-screen Live Activity row; punctuality histogram
- `x-appstore-gallery-feed-profile.png`, X App Store gallery: feed, community, profile screens
- `x-feed-density-detail.png`, feed density crop: tab underline, row anatomy, quote-tweet inset card
- `x-tweet-component-dark-light.png`, official embed component in dark + light: type hierarchy, two-gray + blue palette
