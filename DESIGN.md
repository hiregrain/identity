# Grain: design system

**STATUS: DRAFT, 2026-08-18.** Not ratified. The mark and the pointer are settled
provisionally (§3, recorded in `mark/`). The wordmark and lockup are settled (§4, recorded in `mark/`). Everything
else in this file is settled by founder decision during the 2026-08-17/18 design
sessions unless marked otherwise.

Companion documents: `THESIS.md` (what the business is and where the seam sits),
`imprint/README.md` (the imprint's geometry, generator and open items, the source
of truth for §2), `mark/README.md` (the mark, its size tiers and the pointer,
the source of truth for §3), `model/record-schema.md` (what every surface renders), `design/01-banned-patterns.md` (the negative space, read it
before proposing anything), `design/03-design-perspectives.md` (the research-grounded
argument), `design/04-signature-element-brainstorm.md` (the candidate record).

Gaps are marked **[GAP]** and collected in §13.

---

## TLDR

A banknote engraver's system for a living record. One ink, one typeface, no
accent colour, states carried by line quality alone. At the centre is **the
imprint**, a per-person engraved figure computed from the verified record,
where richness is earned rather than styled. Around it, a component language in
which every primitive derives from either the figure or from chart-work, so no
screen reads as generic even when the figure is absent.

**Settled:** the imprint and its grammar; ink and paper; Archivo as the only
family; the state grammar; radius, depth, inputs and the component laws; the
derived vocabulary; the portable-core / vertical / internal three-tier split;
the celebration economy.

**Not decided:** the verification mark and the wordmark. §3 and §4 carry the
research constraints that any future proposal must satisfy, because those
constraints cost two full research tracks to establish and must not be
rediscovered.

**The one-line law:** *time divides the figure; only verification draws it.*

---

## 1. The laws

1. **No mark without a fact.** Every mark on any surface is addressable to a
   verified record entry. Nothing decorative survives review.
2. **Time divides, verification draws.** Tenure sets the geometry; only
   verification puts ink into it.
3. **One channel, one meaning.** Each visual channel carries exactly one
   variable. Density that means two things means neither.
4. **States by line quality.** Never by badge, dot colour or label colour.
5. **Precision is the texture.** Structural borrowing from physical trust
   artifacts, never pasted texture. Hairlines, absolute alignment, tabular
   figures are the on-screen equivalent of engraving cost.
6. **Nothing generic ships.** Every primitive derives from the figure or the
   chart.
7. **Size never scales with career length.** A footprint that grows with tenure is
   an age proxy, and an age proxy on a hiring surface is a discrimination
   exposure, not a style question. The canvas is fixed for everyone.
8. **Absence of attestation is never drawn as diminished magnitude.** Pale, thin
   and faint are the universal idiom for *lesser*, not for *unconfirmed*. An
   unverified strong record and a verified weak one must never look alike.

The three-question test for any proposed element is in
`design/01-banned-patterns.md` and is binding.

---

## 2. The imprint: geometry recorded in `imprint/`

A per-person figure computed from the verified record. Unique to the person,
recomputable from the ledger, and impossible to style richer than the record earns.
A **different object from the mark** (§3): the mark is invariant and carries no data.

**The geometry system, the channel set, the provenance states, the concurrency rule,
the decisions and the open items now live in [`imprint/README.md`](imprint/README.md),
alongside a runnable generator (`imprint/imprint.py`, standard library only) and
reference renders for every state (`imprint/examples/`).** That folder is the source of
truth; this section is the summary.

**Construction.** `r(t) = R + a · L(t) · sin(7·t + π/2 + delta_i)`, with
`delta_i = i · (2π/7) / n_curves`. The phase sweep across **one lobe period** is what
produces guilloché. A full 2π sweep gives a diamond mesh, and radial offsets give
parallel contour lines. Both destroy it.

**Channels.** Strand = one engagement · radial position = cumulative *engaged* time ·
width = duration · **lobe angle = which of seven responsibility dimensions, permanently
registered** · **lobe depth = level attained** · thread density = corroboration tier ·
plain-versus-lobed = whether anything about the work is attested · core = a person.

**Not drawn, deliberately:** slope, time-to-competence, complexity routed, outcome
trajectory, `work_kind`, `volume`, resource magnitude. All measured, all stored, all
belonging to the record and the analytics layer where they can be labelled.

**And, for v1, lobe depth (decision 054).** Nothing derived from the seven
measures renders on any surface. Parties are still asked and the ledger still
stores what they answer; every chapter draws a constant neutral profile, the
same for every chapter of every person, which carries no claim because it cannot
differ. The rest of the channel list above stands unchanged, and it is what a
reader is actually reading: bands, width, overlap, plain-versus-lobed, thread
density. Passing no levels was tried and collapses the figure to concentric
rings, because lobe depth is level and the phase sweep only separates while
amplitude is non-zero; `imprint/README.md` §3a carries the detail and the two
risks. One consequence here: plain-versus-lobed becomes a question about
provenance rather than about levels, so an attested chapter threads whether or
not levels are stored against it.

**Thread density is a contrast, never a count, decision 044.** A band is read
against its neighbours inside one figure. The thread *count* is set by the pitch
budget at the size and pixel density being drawn, floored at two device pixels,
so the same record legitimately draws a different number of threads at different
sizes and on different hardware, 9 / 17 / 27 at dpr 1 / 2 / 3 for one record at
320px, and the tier fractions survive as ratios rather than as quantities. Nobody counts
hairlines, and `imprint/README.md` §7.4 records that no human has been tested on
this channel at all, so an absolute reading never had evidence behind it.
**Recorded because it degrades an epistemic channel:** below a four-thread budget
the low and mid corroboration tiers both round to one thread, and corroboration
falls from three readable states to two. Nothing announces this yet.

**Two constraints that are not negotiable.** The canvas is fixed, because a footprint
that grows with career length is an age proxy and an age proxy on a hiring surface is a
discrimination exposure. And radius is cumulative engaged time rather than calendar
time, so employment gaps take no space and stay invisible, a deliberate refusal, not an
oversight, and not to be "improved" later.

**Superseded, self-asserted and unattested.** Superseded material is removed, not struck;
the ledger keeps it, the figure shows current truth. A chapter nobody attested has no
lobes and draws as a plain ring, dotted when self-asserted, solid when employment is
verified. That plainness carries meaning and must never be decorated. Under 054 the
test is provenance, not stored levels; before 054 it was both, and it read the same
way because nothing else could attest.

**Changed from the earlier draft**, and superseding it: `k` is no longer a variable
(seven fixed slots, one per dimension); `phi` no longer encodes start month (angle
carries dimension identity, which is worth more); `eps` is dropped (it would bend lobes
that must stay registered, and the real profile supplies uniqueness); pass count derives
from a pitch rule rather than directly from attestation count; and the figure is
recomputed rather than accreted.

**Slope is not drawn.** §2 of the earlier draft claimed slope reads as the relation
between consecutive bands. Slope is employer-side analytics, not worker-facing, and the
two statements contradicted. Entry and exit levels are recorded per dimension so slope is
computable, it is simply not in the figure.

**Open items**, including the missing angular anchor, the axis-set versioning problem,
and the fact that the level anchors are unvalidated, are enumerated in
[`imprint/README.md`](imprint/README.md) §7 and must not be treated as settled.

## 3. The mark and the pointer: provisional, recorded in `mark/`

Three objects, one construction, routinely confused. **The mark** is Grain's logo,
invariant, carrying no data. **The tiers** are purpose-drawn reductions of it for
small sizes. **The pointer** is the glyph that says a person has a record. All
three are recorded with a runnable generator in
[`mark/README.md`](mark/README.md); this section is the summary.

**The mark.** Three concentric threaded bands, seven lobes, radii 90 / 172 / 264
and amplitudes 22 / 30 / 40, **deliberately unequal, which is what makes it read
as a record rather than an ornament.** One lobe is deepened at a fixed angle: it
gives the mark a top, and it converts an unownable stock genre into a describable
feature that can be policed.

**The lobe count is provisional.** There is no unclaimed count. Every small
integer of radial symmetry is somebody's emblem somewhere. Three is Woolmark's
exact construction and Mercury's gestalt; five is the five-star rating
convention; seven reads as a law-enforcement badge to some; eight is the Rub el
Hizb and the Star of Lakshmi. Treat the count as a choice about *which*
association is acceptable, not as an escape from the problem.

**Tiers, drawn and never scaled.** Scaling the master is what fails. **Reduce
the weave before the bands:** three concentric bands are the mark's identity and
the threading is only its finish, so a tier drops threads and never a band.
Three threaded bands at 96px and above, with a per-band fallback to a single
contour where the pitch rule cannot separate threads; all three bands at one
contour each from 24 to 95; solid mass with a knocked-out counter at 23 and
below. **Dark renders stronger than light** at everything under ~120px.

**Corrected 2026-08-19 (decision 044).** This section previously specified
dropping the outer and inner band from 40 to 79 "because the middle band clogs
first". `mark.py` has not done that for some time and argues against it in
source: dropping a band is what makes the mark unrecognisable, and it was the
wrong order. The code is right and this paragraph was stale; the breakpoints
above are the ones `tier_for()` actually applies. **The mark's stroke unit is
sound.** `stroke_for(px)` derives the viewbox stroke from the render size, so
it lands at 1.00 CSS px at every tier and pitch at 2.2–2.8 CSS px, which is the
`PITCH_RATIO` defect §2 had and §3 never did.

### The pointer, and what it must never become

The pointer says **"this person has a record you can inspect."** It does not say
"this person is verified." That is the thesis, not a nuance: Grain states what is
known and how well; the partner decides what it means. A badge collapses a graded
epistemic claim into a yes, which is the credential logic this product exists to
replace.

**Permanently prohibited:** a filled disc, shield, ring or any container; a
checkmark in any form; a lobed disc beside a name at badge scale; any rendering
larger than the adjacent name's cap height.

**On third-party surfaces the pointer must carry a count**: "4 chapters, 3
corroborated". A bare glyph beside a name reads as endorsement whatever its
shape. On our own surfaces the context does that work and it may stand alone.

### Constraints established by research: do not re-derive

**From the visual landscape survey (~95 marks inspected):**

- **Lobed and scalloped silhouettes are disqualified for the pointer.** X's
  verified badge is an octofoil; LinkedIn's is a sixteen-point scallop; Meta,
  Instagram, Threads and TikTok share the family. **Pinwheel**, payroll and
  income verification, a direct adjacency, is a four-lobed quatrefoil. A lobed
  disc beside a name imports the endorsement meaning the mark must never carry.
  This is why the pointer is a citation glyph and not a badge.
- **Plain circles are dead** on crowding: roughly twenty of ninety-five marks.
- **Saturated and banned:** checkmark in any container, shield, solid hexagon
  (Onfido and Entrust are near-identical), ring of dots (Trulioo, CLEAR and
  Sora ID already collide with each other), letterform in a rounded square.
- **Guilloché interlace is claimed** in the immediate neighbourhood: Mercury
  (a true engine-turned rosette, fintech), Woolmark, Plaid, Alloy, Atomic.
- **Colour:** not blue-plus-check. Blue plus check is the verified-badge
  signature; red plus shield is antivirus.

**From the trademark research (research, not legal advice):**

- **Reg. 7142020, Smart Seal, Inc.**: an eight-lobed guilloché rosette in classes
  009 and 042 for proof-of-authenticity software. A later independent pass could
  not confirm this registration; **verify against the register before relying on
  it.**
- **Quatrefoil is the highest-risk silhouette.** Four-fold rotational symmetry is
  the most colonised symmetry order in the register.
- **Asymmetry is the strongest defensibility lever**, which is what the deliberate
  break buys.
- **Do not pursue a certification mark.** US law makes it cancellable where the
  owner supplies the certified service; EU Art. 83 bars the applicant outright.
- **A generated mark cannot be cleanly owned.** If the logo were an instance of
  the imprint generator, the company would be trying to own a shape its own
  product mass-produces. This is why the mark shares the imprint's grammar but is
  not a valid output of it.

**Also live, and independent of the mark:** at least two active fintechs operate
as *Grain*, one with a registration in class 009, one of our intended classes.
Clearance is a counsel question and sits upstream of any mark decision.

## 4. The wordmark: settled, recorded in `mark/`

**Archivo Expanded, weight 600, +9% tracking, all caps.** No second typeface (§6).
Expanded because §6's own scale already uses it for the display registers; tracked
because tracking is how this system signals register; 600 because 700 and above is
the consumer-software bracket.

**The lockup:** mark at 1.4× cap height, gap at 0.75× cap height, clear space one
cap height all round, wordmark cap-band centred on the mark's *optical* centre
(0.4875 of its height, not 0.5, the deliberate break shifts mass). **Minimum
lockup mark is 30px**; below that the mark goes alone, because `tier_solid` is a
dense mass and reads wrong beside outline-weight type. The mark reduces by dropping
the **weave** before the **bands**: three concentric bands hold down to 24px, and
the threading only appears above 150px, where the pitch rule can actually separate
it. Geometry, measured
constants and the reasoning are in [`mark/README.md`](mark/README.md) §4a.

**Recorded weakness.** Expanded tracked caps are the current default in crypto, AI
and fintech. The wordmark is coherent and not distinctive; all the ownability sits
in the mark, so `GRAIN` as plain text is anonymous. Custom letterforms were
considered and rejected. Unmodified type is what comparable infrastructure brands
use, and a bespoke cut is high-risk and licence-sensitive. Revisit only if the
identity must hold on text-only surfaces.

**The name is not clear.** `GRAIN` is a live standard-character US registration in
classes 009 and 042 (Grain Intelligence, Inc.) and in 009 (Grain Technology, Inc.);
Grain London Limited holds the EU word mark across 9, 35, 41 and 42. Grain Network,
Inc. (hiregrain) has no filings, so there are common-law rights in employment
services but nothing registered. Independent research also found an active B2B SaaS
company on grain.com and ~1,678 "Grain" trademark results.

**The founder has ruled the name is not changing** (2026-08-18). Consequences:
**file the device first and separately**, it is clear where the name is not, and
pursue the name on common-law use, since the composite descriptor was cut. Whether
to reinstate a composite purely for filing is a counsel question. **[GAP]**

---

## 5. Colour

The record is monochrome. There is no accent colour.

    ink         #1B2A44   structure, figures, every verified fact
    paper       #F8F5EE   every surface of record — warm, see below
    secondary   #5C6878   labels, captions, self-reported material
    rule        #7E8794   any line that carries meaning — state, selection, boundary
    hairline    #D3D7D6   pure separation only: the ledger grid, never a state
    page        #E9E5DE   behind the paper; app chrome ground

**The paper is warm and the ink is cool, changed 2026-08-19 (decision 049).**
Both grounds were faintly green (`#F5F6F3` and `#E6E6E4`, red minus blue of +2),
which put the whole product on the cold side of neutral and read as clinical
rather than as an instrument. The grounds are now warm (+10); **the ink and every
line derived from it stay exactly as they were.** Warm paper under cool ink is
what printed paper actually looks like, and it costs nothing: measured against
§12's floors, ink on paper moves 13.25 → 13.20, secondary 5.22 → 5.20, `rule`
3.35 → 3.34. No accent has been introduced and the state grammar is untouched.

**`rule` versus `hairline`, added 2026-08-19 (design review, `design/07`).** One
token was doing two jobs and failing one of them. `hairline` on `paper` computes
to **1.34:1**, against §12's 3:1 floor for meaning-bearing lines, correct for a
grid that should recede, and invisible for a state. Every state pair in the first
build (`.row`→selected, the attained ladder step, the input at rest, and the
disclosure rule itself) rode the failing half. `rule` is **3.35:1** on paper and
is the only value permitted to carry meaning. A line that a reader must notice is
`rule`; a line that merely divides is `hairline`. Opacity is never a substitute:
alpha on a stroke blends into the paper, so `.11` renders at 1.22:1 and `.45` at
2.62:1.

**Laws.** Primary controls are solid ink; secondary are hairline ink; links are
ink, underlined. Danger is carried by ink inversion, explicit words and a
confirmation ceremony, never by red. Our own verticals may re-ink paper and ink
together, as a currency series varies hue across denominations while the
skeleton holds; third parties may not (§11). **States are never themed by
anyone**: if a host could restyle them, a pending record in one product could
pass as verified in another.

**Dark mode:** the inversion rule is that the ink becomes the ground. Defined,
never rendered, ships light-only in v1. **[GAP]**

---

## 6. Typography

**Archivo, one family.** Hierarchy from width, weight and tracking only. No
second face. No mono voice. The serial layer is Archivo tracked wide.

    instrument numerals   Expanded 125% · 800 · 40px · tabular
    screen title          Expanded · 700 · 28px
    section head          Normal · 600 · 17px
    record voice          Normal · 600 · 15px
    body                  Normal · 400 · 14px · 1.6 line-height
    data                  Normal · 500 · 13px · tabular · sentence case
    meta                  Normal · 400 · 12px
    micro-caption         500 · 9.5px · +8% tracking · uppercase
    serial layer          500 · 11px · +14% tracking · uppercase

**The data register, added 2026-08-19 (design review, `design/07`).** §8 requires
rows to carry "right tabular figures" and this scale had no register for them, so
the first build put every date, duration, grant state, expiry and settings value
into **micro-caption**, 56 applications against the screen title's 6 and the
instrument register's 0, with 73 of 117 register applications at 12px or below.
Because micro-caption uppercases, it also rendered a worker's own name as
`LIEZEL MENDOZA` and their permanent address as `/U/LIEZEL-MENDOZA`. A caption
register carrying proper nouns, URLs, figure columns and running sentences is
four jobs it was not defined for, and it is the single most uniform treatment in
the set, a Cluster B tell by frequency alone.

**Micro-caption is now labels only.** Never a value, never a date, never a name,
never a sentence. Anything a reader reads *as information* is `data` or above.

Tabular numerals **where digits align**: the data and instrument registers, and
figure columns. Not globally: §5 names tabular figures as engraving cost, and a
blanket application puts gapped digits inside running prose, which costs nothing
and means nothing. **[GAP]** Archivo covers Latin, Cyrillic
and Greek but not Arabic or CJK; a companion face is needed for those markets,
matched on weight and width discipline.

---

## 7. Spacing, radius, depth

**Spacing:** 4px base. Steps 4 / 8 / 12 / 16 / 24 / 32 / 40 / 64. Screen margins
20px mobile, 40px web. Ledger rows 12px vertical padding.

**Radius, by meaning and never uniform:** record surfaces 0px (paper is cut
square); controls 3px; only state dots and the figure are fully round.

**Depth presses down; nothing floats.** Buttons compress 2px on press. Pending
rows sit 2px proud of the baseline grid and seat flush on verification with one
hard haptic at contact. Verified rows have zero press-give. Rigidity is how
permanence is expressed. Sheets are paper laid on paper: a hairline and a faint
contact line, never elevation shadow.

---

## 8. Components

**Settled 2026-08-19 (decision 047): this language is used on both platforms.**
Material and HIG components were drawn against it on the same screen and not
adopted. A record that renders differently per operating system is what §5
exists to prevent. Platform *mechanics* are a separate question and are owed in
full: safe areas, back and the gesture zones, 200% font scaling, screen-reader
order, haptics named per platform, deep links. The cost of an unfamiliar
component language is carried in 047: form may be unconventional, placement and
behaviour may not, and anything tappable must read as tappable without motion or
colour.

**Containers are deleted by default.** Hairlines and whitespace structure the
page. A drawn container appears only for the credential surface, an embedded
record, or a sheet.

**Inputs are ruled lines.** A micro-caption label above, a hairline rule you type
on; focus thickens the rule ink-ward. Boxed fields do not exist.

**Rows are the ledger grammar, everywhere.** Left text, right tabular figures,
hairline separators, a state-mark gutter, strikethroughs kept in place with the
correction dated, and an empty rule reserved for the next entry.

**Buttons:** primary solid ink at 3px; secondary hairline at 3px; tertiary bare
text at 600. No pills, no icons inside buttons.

**Chips** are square-cut at 0px with micro-caption type.

**Choice controls** use the state grammar: filled, dashed, hollow. **The product
contains no checkmarks.**

**Iconography is starved.** Drawn in-house, 24px grid, 1.5px hairline, square
terminals, never filled. Roughly eight exist.

**The core screen runs in one order** (decision 028, **amended by 035**):
identity and the imprint composed as one hero, then outstanding verification,
work history, sharing. Verification sits second because it is the only element
that asks the worker to act, and an unattested record is the failure mode.
Identity moved from last to first: 028's reasoning, settled once, then
irrelevant, holds for the returning user and fails for the new one, who would
otherwise land on an abstract figure with their name at the foot of a scroll.
The portrait was already paired beside the imprint here; 035 makes that pairing
the hero rather than splitting it across the screen. The whole app is this one
screen. There is no tab bar at v1 (`design/06-worker-app-ia.md` §1).

**A promotion is a division inside the band, not a new band.** The chapter is the
relationship with the party, so a position change is drawn as a hairline division
within the chapter, spaced tighter than the gap between chapters. Three positions
over six years at one employer must be legible as one relationship.

**Photography:** a square-cut portrait, document-grade, paired beside the imprint
in the identity block. The imprint remains the hero object.

---

## 9. The derived vocabulary

Twelve primitives, each drawn from the figure or the chart:

**From the figure**: ~~the person-mark~~ (**deleted 2026-08-19, decision 044**:
at the 20–28px such a glyph occupies, each band is about two pixels of radius and
seven lobes cannot separate at any device density, so a unique-but-unreadable
figure implied a legible identity it could not deliver. **A person is their name
and their imprint**, composed as one hero on the record screen. Attestor and party
rows carry the name alone, which decision 007 requires independently, since those
parties are frequently organisations and organisations are never subjects);
loading as an arc scribing; progress as a band closing; **selection as the
meaning-bearing rule (§5), never as weave density**; dividers carrying a faint
sine modulation at the figure's own frequency; choice controls from the state
grammar; tab indicators as arc segments.

**Corrected 2026-08-19 (design review, `design/07` §6.3).** This section
previously specified "selection as weave density in the row gutter" while §2
specifies "thread density = corroboration tier", the same channel carrying two
variables, which law 3 forbids. **Thread density means corroboration and nothing
else.** Selection moves to `rule`, where it is a line quality (law 4) and cannot
be confused with an epistemic claim. The first build hit this collision, chose a
workaround, and did not record it; that is the failure this correction closes.

**From the chart**: the plate (registration corners, a header band carrying
document class and serial, a footer carrying append-only status); the graticule
ground under empty states and credential surfaces, which is how global becomes
structural without drawing a globe; the place mark for any location reference;
rhumb connectors for relationships; the scale rule under any quantity.

---

## 10. Motion and the celebration economy

    press               60ms
    state change        180ms
    the seat            320ms, hard decelerate
    full ceremony       1080ms
    easing              cubic-bezier(0.2, 0, 0, 1)

**Two heavy ceremonies only:** an attestation landing, and a chapter beginning.
Both are state changes of something already on screen: never an overlay, never
confetti, never spawned UI. Light events get the 2px press and nothing more.

Under `prefers-reduced-motion`, ceremonies become instant state changes and the
haptic is retained: the meaning survives without the motion.

---

## 11. What travels: three tiers

**Portable core: fixed for everyone, including third parties.** The imprint
geometry; the verification mark and its phases; the state grammar; the ink of
the marks themselves; the display identifier; attribution and mark-resolution
links; the redaction-honesty rule that a partial record must state what lies
outside the grant without revealing it.

**Vertical layer: re-inkable by us, nobody else.** Our own verticals take their
own ink and paper. States are never re-themed.

**Internal system: never travels.** Archivo and the type scale; the plate;
edge-index navigation; ruled inputs; press-physics; the spacing scale; the
graticule ground; the ceremonies. Inside a partner's product we control our
marks and the record's semantics, not their chrome, type or layout.

---

## 12. Accessibility, voice, localisation

**The target is WCAG 2.2 AA, and the European Accessibility Act is why,
named 2026-08-19 (decision 046).** This section previously carried floors with
no standard behind them, which leaves "is it accessible" unanswerable at the
moment somebody asks. The EAA has applied to consumer-facing digital services
since June 2025, and a record an EU employer may read is in scope. AA is a
compliance obligation here, not a preference, and the items below are the parts
of it this design has to satisfy rather than the whole standard.

**Already specified.** Record text at or above 7:1 contrast; secondary at or
above 4.5:1; meaning-bearing hairlines at or above 3:1 (§5's `rule`). Touch
targets 44px minimum, AA's own floor is 24×24 under 2.5.8, so 44 is stricter
and stays. Focus is a 2px ink outline at 2px offset and is never removed. "Never
signal by colour alone" is satisfied by construction, since there is no colour.

**Specified nowhere, and required.** Each of these is a hole, not a nuance:

- **Text scaling.** AA 1.4.4 requires 200% without loss of content or function.
  Every screen in `design/10-worker-app-screens` is a fixed 360×800 with
  absolutely positioned bands; none has been tested at any scale factor, and
  iOS Dynamic Type and Android font scale both go well past 200%.
- **Screen-reader order and naming.** The imprint is a figure whose meaning is
  geometric. `aria-label` on the SVG is not a reading of it, and the seven
  measures need names and levels a screen reader can traverse in a stated order.
- **Reduced motion.** §10 handles duration; AA 2.3.3 is about the animation
  being non-essential, which the ceremony's teaching role puts in question.
- **Target spacing.** 2.5.8 governs adjacent targets, not only their size. The
  section index's stops sit 14px apart.
- **RTL** is claimed below and has never been rendered.

**None of this is drawn, and no screen has been audited against it.** That is
the state, recorded rather than implied.

**Voice.** Present tense, active, plain. Labels are nouns, buttons are verbs,
confirmations state what happened. Errors name the fix. No exclamation points,
no "you matter", no em-dash cadence in UI text.

**Localisation.** RTL mirrors fully except the imprint, which is radial and stays
unmirrored, and numerals. **[GAP]** Companion typeface for Arabic and CJK.

**Empty, loading, offline.** Empty is the identity core alone plus one line of
what happens next; loading is the scribing arc, never a spinner; offline is a
micro-caption band with the record still readable from cache.

---

## 13. Gaps

1. ~~The verification mark~~: **resolved 2026-08-18.** It exists, and it is a
   *pointer* rather than a badge: "this person has a record you can inspect."
   Form, prohibitions and usage rules in `mark/README.md` §4. Still open within
   it: the lobe count, the break angle (should be locked to the top), and
   silhouette agreement between the largest and smallest tiers.
2. ~~The wordmark~~: **settled 2026-08-18** (§4, `mark/README.md` §4a). Still
   open within it: whether to reinstate a composite purely for filing, given the
   name is fixed and not clearable alone; and whether the wordmark needs
   distinctiveness of its own for text-only surfaces.
3. **The display identifier**: whether a human-facing number is shown at all,
   and if so its format. Distinct from the opaque `ledger_person_id`, which is
   permanent and never surfaces. Four formats rendered, none chosen. **Newly
   entangled (035):** the public handle now exists (`hiregrain.com/u/<handle>`,
   Latin-only, claimed after the record exists, changeable but never released)
   and nothing has decided whether it becomes the display identifier.
4. ~~The record schema~~: **proposed 2026-08-18** in
   [`model/record-schema.md`](model/record-schema.md) (0.1). Objects: `chapter`,
   `position`, `attestation`, `chapter_standing`, `grant`, `dispute`. No `skill`
   object, the seven dimensions replace it, because a skill list is a
   self-asserted claim about capability where a dimension level is an attested
   claim about work performed. Five open items remain in its §8, including a
   vocabulary conflict between decision 028 and ratified decision 006.
5. **The marks enum**: blocking `plans/marks-and-embeds` from going ready.
6. **Dark mode**: **decision closed 2026-08-19 (037), drawing outstanding.**
   It ships at v1 as a *second palette*, not as a mechanical inversion: §5's
   "the ink becomes the ground" does not survive arithmetic, since `rule` at
   3.35:1 on paper is a different ratio inverted and the imprint's hairlines
   bloom on dark ground where they fade on light. Derive from §12's floors
   independently; every state must be distinguishable in both appearances or in
   neither.
7. **Companion typeface**: **closed for the first cohort 2026-08-19 (037):
   Noto Sans Devanagari**, with Noto siblings for Bengali, Arabic and CJK as
   those cohorts land. Recorded consequence: **Noto has no width axis**, and
   §6's two display registers are Expanded 125%, so in non-Latin scripts the
   display hierarchy comes from weight and size alone. The type system is
   genuinely weaker outside Latin, in a product whose population is largely
   non-Latin.
8. **The employer surfaces**: attest queue, dossier, disclosure-grant view,
   cohort view. Undesigned.
9. ~~Onboarding's first-run teaching sequence~~: **closed by deletion (035).**
   There is no tutorial; the first chapter landing is the teaching. The full
   first-open sequence is `design/06-worker-app-ia.md` §3. The mint/share
   artifact remains open.
10a. ~~**The imprint has no size tier system, and its stroke is specified in
    the wrong unit.**~~ **Closed 2026-08-19 (decision 044), there is no tier
    system; the pitch rule carries it.** Numbered 10a because three documents
    cite it by that label: `design/09`, `plans/app-shell/LAYER.md` and
    `design/10-worker-app-screens/gen.py`. §3 established for the mark that scaling the master fails, and
    gave it four purpose-drawn tiers. The imprint, whose entire content is
    guilloché pitch, is fluid-scaled and has none.

    **Corrected 2026-08-19, superseding this entry's first interim rule.** Raising
    the base thread from 0.70 to 1.0 viewbox units was insufficient: at a 600-unit
    viewbox rendered near 300px, 1.0 units is still **~0.5 CSS px**, below one
    device pixel at dpr 1, so the thread still paints pale rather than crisp. The
    unit is the defect. Verified behaviour, three surfaces:

    - **CSS `border-width`** snaps a sub-pixel value **up** to one device pixel
      (CSS Values 4, implemented across engines), so 0.3px and 0.9px render
      *identically*, and any meaning carried in the difference is lost.
    - **SVG `stroke-width`** has **no snapping rule**: sub-pixel strokes
      antialias to pale grey. This is the mechanism by which the figure fades.
    - **Skia at `strokeWidth = 0`** is documented as "always exactly one pixel
      wide in device space… thickness does not change as the canvas is scaled",
      the only one of the three that gives a crisp guarantee at any scale.

    **The rule: the imprint's stroke is expressed in device pixels, never in
    viewbox units.** In SVG that means `vector-effect="non-scaling-stroke"`; in a
    Skia renderer it means hairline mode.

    **Thread counts were NOT unaffected. This entry's last claim was wrong, and
    044 corrects it.** `PITCH_RATIO` asserted pitch against the stroke in the
    same viewbox units, and passed: the reference record's outer band carried
    ten threads at 1.67 units against a required 1.54, which at 296 px is
    **0.82 CSS px**, adjacent threads less than a pixel apart. Crisper strokes
    at that spacing merge sooner than pale ones, so fixing the stroke alone made
    it worse. **Pitch is now floored at two device pixels**, the tightest that
    resolves as two threads, so the figure is drawn as densely as the hardware
    carries. **There are no drawn tiers and none are needed**: §3's tiers drop
    bands, and every band here is somebody's job. The density ceiling is the
    *depth channel*, not the pixel grid: a two-period phase sweep would buy 1.8x
    the threads and blur level-attained, so §2's one-period rule stands.
    Verified through Skia; never verified on a human (`imprint/README.md` §7.4).

10. **Chart grammar for analytics**: hairline, ruled, unfilled, monochrome is a
    gesture rather than a specification.
11. ~~The identity core versus the no-centre rule.~~ **Closed 2026-08-19
    (decision 035 §B6): the core is dropped.** Every reviewer group read a
    concentric centre as a bullseye with the worker inside it, and that reading
    does not improve for being inside the imprint rather than the mark. The empty
    state is carried instead by the graticule ground clipped to the fixed canvas,
    §9's own primitive. Recorded as design, not as a ratified decision.
12. **The dispute surface.** Partners write freely with no countersign
    (decision 028), so a rectification path is required by GDPR Art. 16 regardless.
    A disputed claim stays visible and marked with the worker's statement attached.
    Undesigned.
13. **The grant flow and the share link.** The moment worker custody either exists
    or does not: an employer asks, the worker sees what would be disclosed, decides
    under time pressure. Plus the two-tier sharing model, a public URL and an
    expiring full-record link carrying a warning. Undesigned.
14. **The guidance surface**: **out of v1 (035).** Worker-facing suggestions
    are the only prospective content in an otherwise retrospective product and
    have no visual class; they must not borrow the self-reported treatment, which
    would read as a weak claim about the past rather than a proposal about the
    future. Outstanding verification already does the only prospective work v1
    needs. When guidance arrives it takes the reserved **Work** destination
    rather than being injected into the record, which is what gave it no visual
    class in the first place.
