# Grain — Design System

**STATUS: DRAFT, 2026-08-18.** Not ratified. The mark and the pointer are settled
provisionally (§3, recorded in `mark/`). The wordmark and lockup are settled (§4, recorded in `mark/`). Everything
else in this file is settled by founder decision during the 2026-08-17/18 design
sessions unless marked otherwise.

Companion documents: `THESIS.md` (what the business is and where the seam sits),
`imprint/README.md` (the imprint's geometry, generator and open items — the source
of truth for §2), `mark/README.md` (the mark, its size tiers and the pointer —
the source of truth for §3), `model/record-schema.md` (what every surface renders), `design/01-banned-patterns.md` (the negative space — read it
before proposing anything), `design/03-design-perspectives.md` (the research-grounded
argument), `design/04-signature-element-brainstorm.md` (the candidate record).

Gaps are marked **[GAP]** and collected in §13.

---

## TLDR

A banknote engraver's system for a living record. One ink, one typeface, no
accent colour, states carried by line quality alone. At the centre is **the
imprint** — a per-person engraved figure computed from the verified record,
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

## 2. The imprint — geometry recorded in `imprint/`

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
produces guilloché — a full 2π sweep gives a diamond mesh, and radial offsets give
parallel contour lines. Both destroy it.

**Channels.** Strand = one engagement · radial position = cumulative *engaged* time ·
width = duration · **lobe angle = which of seven responsibility dimensions, permanently
registered** · **lobe depth = level attained** · thread density = corroboration tier ·
plain-versus-lobed = whether anything about the work is attested · core = a person.

**Not drawn, deliberately:** slope, time-to-competence, complexity routed, outcome
trajectory, `work_kind`, `volume`, resource magnitude. All measured, all stored, all
belonging to the record and the analytics layer where they can be labelled.

**Two constraints that are not negotiable.** The canvas is fixed, because a footprint
that grows with career length is an age proxy and an age proxy on a hiring surface is a
discrimination exposure. And radius is cumulative engaged time rather than calendar
time, so employment gaps take no space and stay invisible — a deliberate refusal, not an
oversight, and not to be "improved" later.

**Superseded, self-asserted and unattested.** Superseded material is removed, not struck;
the ledger keeps it, the figure shows current truth. A chapter with no attested
dimensions has no lobes and draws as a plain ring — dotted when self-asserted, solid when
employment is verified. That plainness carries meaning and must never be decorated.

**Changed from the earlier draft**, and superseding it: `k` is no longer a variable
(seven fixed slots, one per dimension); `phi` no longer encodes start month (angle
carries dimension identity, which is worth more); `eps` is dropped (it would bend lobes
that must stay registered, and the real profile supplies uniqueness); pass count derives
from a pitch rule rather than directly from attestation count; and the figure is
recomputed rather than accreted.

**Slope is not drawn.** §2 of the earlier draft claimed slope reads as the relation
between consecutive bands. Slope is employer-side analytics, not worker-facing, and the
two statements contradicted. Entry and exit levels are recorded per dimension so slope is
computable — it is simply not in the figure.

**Open items** — including the missing angular anchor, the axis-set versioning problem,
and the fact that the level anchors are unvalidated — are enumerated in
[`imprint/README.md`](imprint/README.md) §7 and must not be treated as settled.

## 3. The mark and the pointer — provisional, recorded in `mark/`

Three objects, one construction, routinely confused. **The mark** is Grain's logo,
invariant, carrying no data. **The tiers** are purpose-drawn reductions of it for
small sizes. **The pointer** is the glyph that says a person has a record. All
three are recorded with a runnable generator in
[`mark/README.md`](mark/README.md); this section is the summary.

**The mark.** Three concentric threaded bands, seven lobes, radii 90 / 172 / 264
and amplitudes 22 / 30 / 40 — **deliberately unequal, which is what makes it read
as a record rather than an ornament.** One lobe is deepened at a fixed angle: it
gives the mark a top, and it converts an unownable stock genre into a describable
feature that can be policed.

**The lobe count is provisional.** There is no unclaimed count — every small
integer of radial symmetry is somebody's emblem somewhere. Three is Woolmark's
exact construction and Mercury's gestalt; five is the five-star rating
convention; seven reads as a law-enforcement badge to some; eight is the Rub el
Hizb and the Star of Lakshmi. Treat the count as a choice about *which*
association is acceptable, not as an escape from the problem.

**Tiers, drawn and never scaled** — scaling the master is what fails. Three
threaded bands at 80px and above; outer and inner band from 40 to 79, because the
middle band clogs first; one contour per band from 24 to 39; solid mass with a
knocked-out counter at 23 and below. **Dark renders stronger than light** at
everything under ~120px.

### The pointer — and what it must never become

The pointer says **"this person has a record you can inspect."** It does not say
"this person is verified." That is the thesis, not a nuance: Grain states what is
known and how well; the partner decides what it means. A badge collapses a graded
epistemic claim into a yes, which is the credential logic this product exists to
replace.

**Permanently prohibited:** a filled disc, shield, ring or any container; a
checkmark in any form; a lobed disc beside a name at badge scale; any rendering
larger than the adjacent name's cap height.

**On third-party surfaces the pointer must carry a count** — "4 chapters, 3
corroborated". A bare glyph beside a name reads as endorsement whatever its
shape. On our own surfaces the context does that work and it may stand alone.

### Constraints established by research — do not re-derive

**From the visual landscape survey (~95 marks inspected):**

- **Lobed and scalloped silhouettes are disqualified for the pointer.** X's
  verified badge is an octofoil; LinkedIn's is a sixteen-point scallop; Meta,
  Instagram, Threads and TikTok share the family. **Pinwheel** — payroll and
  income verification, a direct adjacency — is a four-lobed quatrefoil. A lobed
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

- **Reg. 7142020, Smart Seal, Inc.** — an eight-lobed guilloché rosette in classes
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
as *Grain*, one with a registration in class 009 — one of our intended classes.
Clearance is a counsel question and sits upstream of any mark decision.

## 4. The wordmark — settled, recorded in `mark/`

**Archivo Expanded, weight 600, +9% tracking, all caps.** No second typeface (§6).
Expanded because §6's own scale already uses it for the display registers; tracked
because tracking is how this system signals register; 600 because 700 and above is
the consumer-software bracket.

**The lockup:** mark at 1.4× cap height, gap at 0.75× cap height, clear space one
cap height all round, wordmark cap-band centred on the mark's *optical* centre
(0.4875 of its height, not 0.5 — the deliberate break shifts mass). **Minimum
lockup mark is 30px**; below that the mark goes alone, because `tier_solid` is a
dense mass and reads wrong beside outline-weight type. The mark reduces by dropping
the **weave** before the **bands** — three concentric bands hold down to 24px, and
the threading only appears above 150px, where the pitch rule can actually separate
it. Geometry, measured
constants and the reasoning are in [`mark/README.md`](mark/README.md) §4a.

**Recorded weakness.** Expanded tracked caps are the current default in crypto, AI
and fintech. The wordmark is coherent and not distinctive; all the ownability sits
in the mark, so `GRAIN` as plain text is anonymous. Custom letterforms were
considered and rejected — unmodified type is what comparable infrastructure brands
use, and a bespoke cut is high-risk and licence-sensitive. Revisit only if the
identity must hold on text-only surfaces.

**The name is not clear.** `GRAIN` is a live standard-character US registration in
classes 009 and 042 (Grain Intelligence, Inc.) and in 009 (Grain Technology, Inc.);
Grain London Limited holds the EU word mark across 9, 35, 41 and 42. Grain Network,
Inc. (hiregrain) has no filings, so there are common-law rights in employment
services but nothing registered. Independent research also found an active B2B SaaS
company on grain.com and ~1,678 "Grain" trademark results.

**The founder has ruled the name is not changing** (2026-08-18). Consequences:
**file the device first and separately** — it is clear where the name is not — and
pursue the name on common-law use, since the composite descriptor was cut. Whether
to reinstate a composite purely for filing is a counsel question. **[GAP]**

---

## 5. Colour

The record is monochrome. There is no accent colour.

    ink         #1B2A44   structure, figures, every verified fact
    paper       #F5F6F3   every surface of record
    secondary   #5C6878   labels, captions, self-reported material
    hairline    #D3D7D6   rules, borders, the ledger grid
    page        #E6E6E4   behind the paper; app chrome ground

**Laws.** Primary controls are solid ink; secondary are hairline ink; links are
ink, underlined. Danger is carried by ink inversion, explicit words and a
confirmation ceremony — never by red. Our own verticals may re-ink paper and ink
together, as a currency series varies hue across denominations while the
skeleton holds; third parties may not (§11). **States are never themed by
anyone**: if a host could restyle them, a pending record in one product could
pass as verified in another.

**Dark mode:** the inversion rule is that the ink becomes the ground. Defined,
never rendered, ships light-only in v1. **[GAP]**

---

## 6. Typography

**Archivo, one family.** Hierarchy from width, weight and tracking only. No
second face. No mono voice — the serial layer is Archivo tracked wide.

    instrument numerals   Expanded 125% · 800 · 40px · tabular
    screen title          Expanded · 700 · 28px
    section head          Normal · 600 · 17px
    record voice          Normal · 600 · 15px
    body                  Normal · 400 · 14px · 1.6 line-height
    meta                  Normal · 400 · 12px
    micro-caption         500 · 9.5px · +8% tracking · uppercase
    serial layer          500 · 11px · +14% tracking · uppercase

Tabular numerals wherever digits align. **[GAP]** Archivo covers Latin, Cyrillic
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
hard haptic at contact. Verified rows have zero press-give — rigidity is how
permanence is expressed. Sheets are paper laid on paper: a hairline and a faint
contact line, never elevation shadow.

---

## 8. Components

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

**Choice controls** use the state grammar — filled, dashed, hollow. **The product
contains no checkmarks.**

**Iconography is starved.** Drawn in-house, 24px grid, 1.5px hairline, square
terminals, never filled. Roughly eight exist.

**The core screen runs in one order** (decision 028): the imprint, outstanding
verification, work history, sharing, identity. Verification sits second because it
is the only element that asks the worker to act, and an unattested record is the
failure mode. Identity goes last because it is settled once and then irrelevant.

**A promotion is a division inside the band, not a new band.** The chapter is the
relationship with the party, so a position change is drawn as a hairline division
within the chapter, spaced tighter than the gap between chapters. Three positions
over six years at one employer must be legible as one relationship.

**Photography:** a square-cut portrait, document-grade, paired beside the imprint
in the identity block. The imprint remains the hero object.

---

## 9. The derived vocabulary

Twelve primitives, each drawn from the figure or the chart:

**From the figure** — the person-mark (every human in the product, attestors
included, rendered as their own mini-imprint rather than a photo or initials);
loading as an arc scribing; progress as a band closing; selection as weave
density in the row gutter; dividers carrying a faint sine modulation at the
figure's own frequency; choice controls from the state grammar; tab indicators
as arc segments.

**From the chart** — the plate (registration corners, a header band carrying
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
Both are state changes of something already on screen — never an overlay, never
confetti, never spawned UI. Light events get the 2px press and nothing more.

Under `prefers-reduced-motion`, ceremonies become instant state changes and the
haptic is retained: the meaning survives without the motion.

---

## 11. What travels — three tiers

**Portable core — fixed for everyone, including third parties.** The imprint
geometry; the verification mark and its phases; the state grammar; the ink of
the marks themselves; the display identifier; attribution and mark-resolution
links; the redaction-honesty rule that a partial record must state what lies
outside the grant without revealing it.

**Vertical layer — re-inkable by us, nobody else.** Our own verticals take their
own ink and paper. States are never re-themed.

**Internal system — never travels.** Archivo and the type scale; the plate;
edge-index navigation; ruled inputs; press-physics; the spacing scale; the
graticule ground; the ceremonies. Inside a partner's product we control our
marks and the record's semantics, not their chrome, type or layout.

---

## 12. Accessibility, voice, localisation

**Accessibility.** Record text at or above 7:1 contrast; secondary at or above
4.5:1; meaning-bearing hairlines at or above 3:1. Touch targets 44px minimum.
Focus is a 2px ink outline at 2px offset and is never removed. Note that "never
signal by colour alone" is satisfied by construction, since there is no colour.

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

1. ~~The verification mark~~ — **resolved 2026-08-18.** It exists, and it is a
   *pointer* rather than a badge: "this person has a record you can inspect."
   Form, prohibitions and usage rules in `mark/README.md` §4. Still open within
   it: the lobe count, the break angle (should be locked to the top), and
   silhouette agreement between the largest and smallest tiers.
2. ~~The wordmark~~ — **settled 2026-08-18** (§4, `mark/README.md` §4a). Still
   open within it: whether to reinstate a composite purely for filing, given the
   name is fixed and not clearable alone; and whether the wordmark needs
   distinctiveness of its own for text-only surfaces.
3. **The display identifier** — whether a human-facing number is shown at all,
   and if so its format. Distinct from the opaque `ledger_person_id`, which is
   permanent and never surfaces. Four formats rendered, none chosen.
4. ~~The record schema~~ — **proposed 2026-08-18** in
   [`model/record-schema.md`](model/record-schema.md) (0.1). Objects: `chapter`,
   `position`, `attestation`, `chapter_standing`, `grant`, `dispute`. No `skill`
   object — the seven dimensions replace it, because a skill list is a
   self-asserted claim about capability where a dimension level is an attested
   claim about work performed. Five open items remain in its §8, including a
   vocabulary conflict between decision 028 and ratified decision 006.
5. **The marks enum** — blocking `plans/marks-and-embeds` from going ready.
6. **Dark mode** — rule defined, never rendered.
7. **Companion typeface** for non-Latin scripts. Archivo is Latin-only and the
   product is global — Bengali, Arabic, Devanagari and CJK are launch-blocking,
   not later work.
8. **The employer surfaces** — attest queue, dossier, disclosure-grant view,
   cohort view. Undesigned.
9. **Onboarding's first-run teaching sequence**, and the mint/share artifact.
10. **Chart grammar for analytics** — hairline, ruled, unfilled, monochrome is a
    gesture rather than a specification.
11. **The identity core versus the no-centre rule.** Removing the centre point
    from the mark was right — every reviewer group read a concentric centre as a
    bullseye with the worker inside it. But the imprint's identity core is inked
    at signup and carries the empty state. Whether it survives there is unresolved.
12. **The dispute surface.** Partners write freely with no countersign
    (decision 028), so a rectification path is required by GDPR Art. 16 regardless.
    A disputed claim stays visible and marked with the worker's statement attached.
    Undesigned.
13. **The grant flow and the share link.** The moment worker custody either exists
    or does not: an employer asks, the worker sees what would be disclosed, decides
    under time pressure. Plus the two-tier sharing model — a public URL and an
    expiring full-record link carrying a warning. Undesigned.
14. **The guidance surface.** Worker-facing suggestions are the only prospective
    content in an otherwise retrospective product and have no visual class. They
    must not borrow the self-reported treatment, which would read as a weak claim
    about the past rather than a proposal about the future.
