# Worker app design review, round 1

2026-08-19. Six independent reviewers, each given one lens and no sight of the
others, run against the nine artboards of the worker surface. Method follows
`03-design-perspectives.md` and `stack-perspectives/`: a finding reached by two
or more reviewers *independently* is signal; a single-reviewer finding is
evidence. Disagreements are preserved, never averaged.

**Lenses.** W, a worker in the target population on a cheap Android.
B, an adversarial critic auditing against `01-banned-patterns.md` and
`DESIGN.md`'s eight laws, briefed to fail the work. A, accessibility and
low-end-device measurement. I, interaction and information architecture.
T, typography and system rigour. L, an employer reading the record, and a
lawyer checking the interface does not claim more than the system delivers.

**Standing limitation.** No reviewer could render the files. Every size, weight,
colour, spacing and stroke value is explicit in source, so the arithmetic is
firm; anything resting on optical judgement or device rasterisation is marked
NEEDS RENDER and is not settled.

---

## 1. Convergent, five or six reviewers

### 1.1 The state channel is invisible · W B A I T

`--hairline #D3D7D6` on `--paper #F5F6F3` computes to **1.34:1**, against §12's
3:1 floor for meaning-bearing hairlines. It is the unselected half of every
state pair in the system: `.row`→`.row-sel`, the ladder's attained border, the
zoom ticks, the input at rest. Every opacity used as a state signal resolves the
same way, because opacity on a stroke alpha-blends into paper rather than
dimming: `.11` → **1.22:1**, `.28` → 1.74, `.45` → 2.62, `.5` → 2.97, `.4` → 2.31.

Worst instance: `Main`'s `.disclosed::after`, the sole carrier of *a live grant
exists on this record*, is a 1.34:1 line 4px below another line, and
`headerCls` is hardcoded to `'disclosed'`, so the private state never renders
and there is nothing to learn the signal against.

### 1.2 Touch targets · W B A I T

Computed from the real geometry. `Main`'s figure renders at 296px from a 600
viewBox (scale 0.4933), so the seven band hit areas are **18.4, 18.4, 6.1, 6.1,
18.4, 22.5, 19.5 px**. Also failing 44px: edge-index buttons (36px wide),
`Handle` alternates (~28px), `.btn-tertiary` (~17px), the sheet's Close (~12px),
`Expanded`'s zoom rule (20px). `.btn-primary` and `.btn-secondary` both compute
to exactly 44px, which is deliberate and correct.

---

## 2. Convergent, four reviewers

### 2.1 The 9.5px micro-caption is the product's data register · W B A T

`t-micro` is applied **56 times** across nine screens against `t-title`'s 6 and
`t-inst`'s 0; **73 of 117 register applications are 12px or smaller**. It carries
every date span, duration, grant state, expiry, settings value, and the imprint
readout. Because it sets `text-transform:uppercase`, it renders the user's
own name as `LIEZEL MENDOZA` and their permanent address as
`/U/LIEZEL-MENDOZA`, on a handle specified Latin-only lowercase.

B names it the single most pervasive uniform treatment in the set and the first
thing a hostile designer would call AI-generated. T supplies the cause: **§6
defines no register for a tabular data column**, so the caption absorbed the job.

### 2.2 The level numeral reads as a rating · W B I L

`Step ${level} of 6` beside a seven-rung ladder with one rung inked. W read it as
"one out of six" on a dimension whose name sounds like trustworthiness. I found
the axis named two ways, `Slot 4 of 7` and `Step 3 of 6`, against seven rows,
zero-indexed. L noted `Step 0 of 6` renders for "Not exercised", which
`record-schema.md` §4 and `imprint/README.md` §3 both insist is non-pejorative
and which a 0–6 ladder converts into the bottom of a rank. B cites `05` §6:
"anything countable that could read as a rating… the two people who had been
*rated for a living* reached it fastest."

All four exempt the behavioural anchors themselves, which describe work rather
than people. The numeral is the defect; the ladder is the asset.

---

## 3. Convergent, three reviewers

- **The permanence metaphor is dead code · B T A.** `.rigid` is defined in all
  nine files and applied **zero** times, so an attested chapter compresses under
  the thumb exactly like a self-asserted one. `.press:active` declares no
  transition, so §10's 60ms press is 0ms. No file contains `navigator.vibrate`,
  including the artboard whose only purpose is to demonstrate the seat.
- **Opacity carries six variables · B A I.** Decoration, unselected chapter,
  guide lines, level-below-vs-above, active nav section, ceremony progress.
  Law 3 says a channel meaning two things means neither.
- **Absence drawn as diminished magnitude · B I A.** Law 8, listed in `05` §2 as
  non-negotiable. Three instances: `Expanded`'s ladder greys *every* rung when
  nothing is attested; unselected chapters at 11%; `Handle`'s error state makes
  the rule **paler** and sets the error note in `--secondary` while the success
  note is `--ink`, so the error is quieter than the success.
- **The dispute promise has no door · W I L.** Consent row 04 says "You can
  dispute anything"; there is no path anywhere, by ruling. L adds that the
  promise itself over-claims. What exists is the right to attach a statement
  the party may decline and Grain will never adjudicate.
- **The figure may not resolve on target hardware · W A T.** NEEDS RENDER, but
  the arithmetic: threads at 0.70 units × 0.49 scale = **0.32–0.37 CSS px**.
  Skia scales coverage alpha rather than dropping sub-pixel strokes, so at dpr 1
  they paint around **1.9–2.0:1**, at dpr 1.5 roughly 3.8–4.5:1. dpr 1.5 panels
  are live in the named markets. T raises the same question of the gutter
  swatches: 7 threads in a ~9px band is a 1.3px pitch against a 0.9px stroke, so
  2-vs-4 will read and **4-vs-7 may not**, which would put the corroboration
  tier on a channel the eye cannot count.

---

## 4. Convergent, two reviewers

- **Provenance is legible to employers and not to the worker · W I.** `Public`
  prints "Attested and corroborated" / "Self-asserted" in words beside each
  swatch. `Main` shows the swatch bare, with the job title on the second line.
  The teach-by-adjacency mechanism works only on the surface the worker sees
  least.
- **Four surfaces have no entry point · I A.** Ring and row taps only toggle a
  selection; the Settings sheet's CTA calls `close`. Expanded, chapter detail,
  dimension standing and Settings are unreachable. Separately, `Expanded`'s stage
  is a bare `<div>` with pointer handlers and no `tabindex`, `role` or key
  handling, and it is the *only* control for the dimension axis, so a keyboard
  or screen-reader user is locked to the constructor's defaults. `role="img"`
  additionally prunes `Main`'s band hit areas from the accessibility tree; that
  screen survives only because the work-history rows set the same state, which is
  the correct dual-path pattern and exactly what Expanded lacks.
- **Settings' navigational rows are inert `<div>`s · I A.** Terms, Privacy, How
  the record works, Export everything, App language, none carry a button, a
  handler, or an href.
- **Registration corners are uniform treatment and document cosplay · B T.**
  32 identical instances across 8 of 9 screens, non-interactive, encoding
  nothing. `Public` drops them with a comment explaining why, which proves the
  system knows they are page furniture.
- **The mark is scaled below its own tier floor · B T.** One 28px fragment used
  everywhere; `Public` renders it at **20px**, inside the ≤23px band where §3
  mandates `tier_solid`, computing to a 0.89px stroke. `MARK56` is wired and
  used nowhere, so the 40–79 tier is dead code.
- **Vocabulary arrives undefined · W I.** "chapter" first appears at an
  irreversible action; the consent instrument never uses the word. "attested",
  "corroborated", "provenance", "standing", "append only" are unexplained.
  W adds that "party" reads as a celebration.
- **RTL is structurally blocked · A T.** 152 physical-direction declarations,
  zero logical properties, zero bidi isolation. `Main`'s 44px right padding
  exists solely to clear the edge nav, so mirroring breaks the layout rather than
  flipping it. `text-transform:uppercase` is a no-op in CJK and Arabic and the
  8%/14% tracking breaks Arabic cursive joining, which is the only thing
  distinguishing the micro and serial registers.

---

## 5. Single-reviewer, factually certain

Not convergent, but verifiable against the repo and therefore not opinion.

- **Three statements in the UI are false · L.** `Public`'s closing line "Records
  on Grain are written by the parties named, never by the person" sits above a
  self-asserted chapter. `Main`'s "Removing a chapter needs a written request"
  describes a path that does not exist. Consent row 05 and
  `ledger-design-0.1.md` §8.2.5 both say individual records never come out at
  all. `Empty`'s "Nothing is drawn until someone who was there confirms it" is
  contradicted by the next screen, which draws five unconfirmed chapters.
- **The record's exposure readout under-reports by the entire internet · L.**
  "2 parties can read this" counts grants only, omitting a live, always-indexed
  public page carrying name, country, five employers and optionally the imprint.
  `06-worker-app-ia.md` §10 makes audience-on-the-object a safety mechanism; the
  object under-reports.
- **The ceremony teaches a schema violation · L.** A single attestation landing
  resolves to "Attested by the party, and corroborated." `corroboration: multi`
  requires distinct parties.
- **The ceremony is also over budget and broken · B.** It runs 1330ms
  (1080 + a 250ms stagger) while `done` fires at 1080ms, so the last two paths
  snap mid-draw. §10 budgets 1080ms.
- **Reduced motion produces a flicker, not a state change · A.** The rule zeroes
  durations but not `animation-delay`, so every stagger survives: a 600ms
  staggered pop, worse for a vestibular-sensitive user than the original. One
  line fixes it. Separately, `Expanded`'s resting state is
  `stroke-dashoffset:1`, invisible, revealed only by the animation's `forwards`
  fill, so any environment that suppresses animations renders the imprint
  permanently blank. `Landing` already guards this with an explicit `.done` end
  state; the pattern is in the codebase and was not carried over.
- **The handle's transliteration does not exist · A.** The code comment claims
  the field "arrives prefilled by transliteration and is never rejected";
  `normalize()` strips to `[a-z0-9-]`, returning empty string for a Devanagari or
  Arabic name, which the component then classes as `empty`. The three fallbacks
  are hardcoded Latin. This is the mechanism decision 035 relies on to keep
  Latin-only URLs from reading as a rejection.
- **The imprint is 12px off-centre on the core screen · T.** `main` padding is
  `0 44px 56px 20px` to clear the edge index, so the figure's centre lands at
  x=168 on a 360px screen. Every other screen centres it at 180.
- **Four em dashes in shipped UI text · B**, banned by §12 and again by
  `01-banned-patterns.md`. Plus "48 entries · last today", which is broken
  English.
- **Quantified drift · T.** 37.8% of 172 spacing declarations are off the 4px
  scale. One primitive, the ledger row, is expressed four times at three
  different heights (`.row` 12px, `.prow` 13/gap 14, `.srow` 13, `.cRow` 14/gap
  14). Two off-scale type sizes (34px, 13px). `tabular-nums` is set globally on
  `body`, so every digit in running prose is tabular, which §5 names as a
  deliberate cost and this applies as a blanket.

---

## 6. Preserved disagreements

Recorded rather than resolved. Each needs a ruling, not a merge.

1. **May the figure carry a printed label?** I argues for one line under it,
   "Your imprint, touch a ring", reasoning that a label present *before* any
   interaction is an affordance, not a legend. B's standing position is that any
   printed explanation of the motif is the round-1 legend failure. Both cite the
   same document.
2. **What replaces opacity as selection?** I says raise unselected chapters to
   35–40%. A says the floor must be 0.55 to clear 3:1. B says stop using opacity
   for state entirely and let the four ink devices already present carry it.
   Three incompatible answers to one defect.
3. **§9 and §2 collide, and the design overrode it silently.** §9 specifies
   "selection as weave density in the row gutter"; §2 specifies "thread density =
   corroboration tier". The same channel, two meanings. B flags the collision and
   notes the design picked a workaround without recording it. This goes back to
   the spec, not to the screens.
4. **Provenance words in the row versus register overload.** W and I both want
   the provenance sentence on the `Main` row. T warns the caption register is
   already carrying four jobs it was not defined for, so a third line cannot be
   added until §6 has a data register. The fix has an ordering dependency.

---

## 7. What every reviewer left standing

Named so it survives revision.

- **The state-swatch ladder.** Dashed rule, solid rule, 2 threads, 4, 7. B ran
  the three-question test on it and passed it on all three, calling it the best
  object in the set: self-assertion drawn as a *different line quality* rather
  than a fainter one is law 8 done right and law 4 done right.
- **Colour discipline.** No accent, zero red, danger by ink inversion with
  explicit words and a two-step. Ink on paper 13.25:1. §5 fully honoured. §12's
  "never signal by colour alone" holds by construction.
- **Radius.** Exactly two values across 1,794 lines: 3px on controls, 0px
  everywhere else.
- **Nothing countable that reads as a rating on the core screen.** No checkmarks,
  badges, shields, stars, percentages or composite scores anywhere. Grepped.
- **`Empty`.** The graticule clipped to the fixed canvas, no core, no boundary
  ring, one line of what happens next.
- **`Consent`'s copy.** Six mechanics, permanence before commitment, the exit
  at row 05 at the same weight as the rest. Best writing in the set; only the
  zero-padded `01`–`06` numbering is wrong with it.
- **`Public`'s separate chassis.** The one place the system proves it can vary
  by meaning.
- **Promotions as hairline divisions inside a chapter**, tighter than the
  inter-chapter gap. §8 implemented correctly.
- **`Main`'s grant sheet copy.** L calls it the most accurate text in the
  product and wants it moved into the consent instrument verbatim.
- **The focus ring**, present in all nine files exactly as §12 specifies and
  never overridden.

---

## 8. What this implies for the spec, not the screens

Four defects have their cause in `DESIGN.md` rather than in the artboards, and
cannot be fixed by editing screens.

1. **§6 has no register for a tabular data column.** Until it does, the caption
   register will keep absorbing dates, values, states and sentences.
2. **§5 has one hairline token doing two jobs.** Pure separation is correctly
   1.34:1 and should recede; a meaning-bearing rule must clear 3:1. One token
   cannot be both.
3. **§9 and §2 assign the same channel two meanings** (disagreement 3 above).
4. **The imprint has no size tier system.** §3 established for the mark that
   scaling the master fails and gave it four drawn tiers; the imprint, whose
   entire content is guilloché pitch, is fluid-scaled across a 9.6% spread with
   none. NEEDS RENDER to establish where the tiers fall.
