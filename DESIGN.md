# Grain — Design System

**STATUS: DRAFT, 2026-08-18.** Not ratified. Two central items are explicitly
**NOT DECIDED**: the verification mark (§3) and the wordmark (§4). Everything
else in this file is settled by founder decision during the 2026-08-17/18 design
sessions unless marked otherwise.

Companion documents: `THESIS.md` (what the business is and where the seam sits),
`design/01-banned-patterns.md` (the negative space — read it before proposing
anything), `design/03-design-perspectives.md` (the research-grounded argument),
`design/04-signature-element-brainstorm.md` (the candidate record).

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

The three-question test for any proposed element is in
`design/01-banned-patterns.md` and is binding.

---

## 2. The imprint — settled

A per-person figure computed from the verified record. Unique to the person,
recomputable from the ledger, and impossible to style richer than the record
earns.

**Construction** (preserve this — the generator is scratch and will be lost):

    r(t) = R + a · sin(k·t + phi + delta_i) · (1 + eps · sin(t + phi))

    band          one chapter (a job or engagement); bands accrete outward,
                  earliest innermost, and never reorder
    R, a          from tenure — band radial thickness is duration, linear
    k             lobe count = verified skills in that chapter, capped at 5
    phi           from the chapter's start month, phi = 2*pi*m/12
    eps           one-fold asymmetry keyed to the start date; this is what makes
                  the figure irregular, and irregularity is both the aesthetic
                  and the legal differentiator
    delta_i       i * (2*pi/k) / n_curves — sweeps one full lobe period across
                  the pass count. THIS is what produces the woven interference;
                  without it the figure reads as thin concentric loops
    n_curves      pass count, from attestations, log-capped
    identity core two tight eccentric loops at centre, inked at signup

**States within the figure:** fully attested chapters are drawn with the full
weave; partially verified chapters plainer; self-reported items appear as a
detached dotted hairline outside the figure, never woven in; superseded material
is struck and kept.

**Growth:** the canvas grows during roughly the first year, then holds fixed, so
career length never makes one person's figure larger than another's.

**Slope** is legible as the relationship between consecutive bands — a rising
record opens outward, a flat one repeats. Do not reintroduce the lobe and sweep
caps that flattened this; they were removed deliberately.

---

## 3. The verification mark — NOT DECIDED

A canonical mark, identical for every person, showing identity-assurance phase
(recorded / contact / document / biometric). A different object from the imprint,
doing a different job: the imprint says who this is, the mark says how well the
identity is proven. The imprint cannot carry this, because a per-person figure
varies for unrelated reasons and so cannot be compared across people.

Whether it should exist as a second object at all is itself open.

### Constraints any proposal must satisfy — established by research, do not re-derive

**From the visual landscape survey (~95 marks inspected):**

- **Lobed and scalloped silhouettes are disqualified.** X's verified badge is an
  octofoil; LinkedIn's is a sixteen-point scallop; Meta, Instagram, Threads and
  TikTok share the family. **Pinwheel** — payroll and income verification, a
  direct adjacency — is a four-lobed quatrefoil. A lobed disc beside a name
  reads as a social verification badge, importing the endorsement meaning the
  mark must never carry.
- **Plain circles are dead** on crowding: roughly twenty of ninety-five marks.
- **Saturated and banned:** checkmark in any container, shield, solid hexagon
  (Onfido and Entrust are near-identical), ring of dots (Trulioo, CLEAR and
  Sora ID already collide with each other), letterform in a rounded square.
- **Guilloché interlace is claimed** in the immediate neighbourhood: Mercury
  (a true engine-turned rosette, fintech), Woolmark, Plaid, Alloy, Atomic.
- **Genuinely unclaimed:** the punched cartouche of hallmarking; fingerprint
  geometry (zero occurrences in ninety-five marks); uncontained open-line marks.
- **Form guidance:** line-only, monochrome, single weight, uncontained. CE, the
  BSI Kitemark and the UK hallmarks are the marks that have lasted decades and
  all three are open-line with no fill and no container.
- **Colour:** not blue. Blue plus check is the verified-badge signature; red plus
  shield is antivirus.
- **Phase must be categorical, not ordered.** X's gold-versus-blue tiering reads
  as prestige rather than as a different verification method.

**From the trademark research (USPTO and EUIPO primary registers; research, not
legal advice):**

- **Reg. 7142020, Smart Seal, Inc.** — an eight-lobed guilloché rosette,
  registered, in classes 009 and 042, for proof-of-authenticity software. The
  single most important live obstacle. Any six- or eight-lobe rosette faces a
  citation risk and Smart Seal has standing to oppose. Counsel must be asked
  specifically about this registration.
- **Quatrefoil is the highest-risk silhouette.** Louis Vuitton's monogram flower
  is a four-petal quatrefoil, enforced aggressively; two credit unions hold
  four-leaf marks in classes 035/036/041; Workday holds a four-circle mark in
  ours. Four-fold rotational symmetry is the most colonised symmetry order in
  the register.
- **Asymmetry is the strongest defensibility lever.** Every crowded design code
  describes a regular form. Irregular-circumference circles hold roughly 2,550
  live marks in our classes against 50,000 for shaded circles, and two irregular
  forms are unlikely to be irregular in the same way.
- **Do not pursue a certification mark.** US law makes it cancellable at any
  time where the owner supplies the certified service, and EU Art. 83 bars the
  applicant outright. File an ordinary service mark. Revisit only if a separate
  standards-setting entity is created.
- **File the device before the name**, and separately. See §4.
- No check mark, no shield, no badge — §43(a) false-association exposure exists
  whether or not the platform badges are registered, and the survey could not
  find registrations for them.

### Where the exploration got to

Six derivations of the imprint were rendered and ranked, each changing exactly
one property of the construction in §2. Ranked on legibility at fifteen pixels,
distinctiveness, defensibility and fidelity to the source:

1. **Circular, cropped** — interference clipped hard at a true circle, lobes cut
   rather than closed. Takes the circular silhouette's legibility without the
   concentric-circle crowding or the scallop collision.
2. **Circular, contained** — the figure with a circular rule struck around it.
   More obviously descended from the record, but this is Mercury's construction.
3. **Circular by amplitude** — lobe amplitude driven to zero so the same curves
   converge into rings. Most elegant derivation, most legible, weakest ownership.
4. **Regularised** — the imprint with eps zeroed. Gives up the asymmetry that is
   its best defence.
5. **Single annulus** — reads as a star or flower at small size.
6. **Canonical four-lobe** — beautiful and effectively unownable.

**Reduction is mandatory and tiered**, not a scale-down: above 26px two or three
elements; 16–25px a single ring plus cored centre; below 16px a solid silhouette
with a knocked-out core, because line art does not hold below that size.

---

## 4. The wordmark — NOT DECIDED

Four Archivo treatments were rendered: expanded-tight, expanded-tracked,
sentence case, and condensed wide-tracked. The tracked treatments sit in the
document register the rest of the system occupies; the tight and sentence-case
ones read as consumer software. A wordmark in a second typeface is forbidden by
§6.

**The name is not clear.** `GRAIN` is a live standard-character US registration
in classes 009 and 042 (Grain Intelligence, Inc.) and in 009 (Grain Technology,
Inc.); Grain London Limited holds the EU word mark across 9, 35, 41 and 42. Not
realistically clearable as a standalone word in the classes we want. Grain
Network, Inc. (hiregrain) has no filings, so there are common-law rights in
employment services but nothing registered.

Consequence for sequencing: **file the device first and separately** — it is
clear where the name is not — and pursue the name as a composite, a two-word
variant, or on common-law use. **[GAP]** Not ruled.

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

1. **The verification mark** — whether it exists, and which form. §3 carries the
   binding constraints.
2. **The wordmark**, and the name-clearance sequencing in §4.
3. **The display identifier** — whether a human-facing number is shown at all,
   and if so its format. Distinct from the opaque `ledger_person_id`, which is
   permanent and never surfaces. Four formats rendered, none chosen.
4. **The record schema** — no field list exists anywhere for a work-history row,
   a skill, or a credential. Every surface in this document renders data that is
   not yet specified. Prior art to draw from: W3C Verifiable Credentials 2.0,
   Open Badges 3.0, 1EdTech CLR, ESCO, Velocity Network.
5. **The marks enum** — blocking `plans/marks-and-embeds` from going ready.
6. **Dark mode** — rule defined, never rendered.
7. **Companion typeface** for non-Latin scripts.
8. **The employer surfaces** — attest queue, dossier, disclosure-grant view,
   cohort view. Undesigned.
9. **Onboarding's first-run teaching sequence**, and the mint/share artifact.
10. **Chart grammar for analytics** — hairline, ruled, unfilled, monochrome is a
    gesture rather than a specification.
11. **The guidance surface.** Worker-facing suggestions are the only prospective
    content in an otherwise retrospective product and have no visual class. They
    must not borrow the self-reported treatment, which would read as a weak claim
    about the past rather than a proposal about the future.
