# Grain Design Perspectives, v0.1 (proposed)

The rooted design position for Grain, argued from the product and from
field evidence ([02-field-notes/](02-field-notes/), assets referenced
inline). Everything here is a claim with evidence under it, per the
research protocol. Color and typography are deliberately not settled
here. They are decided by eye at the option-board stage, inside these
constraints.

## Premise

Grain stores a person's identity and entire verified work history. The
design's job is to make a screen read as a **document of record**, the
way a passport, a banknote, or a bound ledger reads, while feeling
alive the way Flighty's timeline feels alive. Software has almost never
attempted this seriously; the convergent AI aesthetics (both clusters
in [01-banned-patterns.md](01-banned-patterns.md)) have no answer to
"why should I trust what this screen says." That gap is the
differentiation.

The strategy: structural devices from pre-digital trust artifacts +
ordered granularity as a proprietary visual language + liveliness
mechanics proven by Duolingo/Flighty/X. Swiss grid discipline is the
layout law that holds it together.

---

## P1, The page is order; history is the stamp

The base surface is calm and rigidly gridded: ruled rows, absolute
alignment, reserved margins. **Events break the grid; nothing else
does.** A verification landing on the ledger renders as a stamp-class
event, bordered, issuer named in the border band, status verb, date,
serial, deliberately rotated/overlapping, like ink applied after
printing.

Evidence: the Korea entry stamp is a complete UI spec for this
(`c-physical-print/passport-us-visa-stamps-spread.jpg`); Apple renders
the state seal overlapping the Wallet ID card art the same way
(`b-trust-artifacts/apple-wallet-id-card-hero.jpg`); Müller-Brockmann
supplies the law. Any density is legible if alignment is absolute, and
the grid may be broken but never inconsistent.

Consequence: grid-breaking is a reserved resource. If decoration ever
breaks the grid, stamps stop meaning anything.

## P2, Append-only is visible

Records are never edited on screen, only layered upon: superseded
values struck through in place, state changes stamped over and dated,
empty ruled rows visibly reserved for the future. The UI physically
enacts the product rule (R2: delete everything, edit nothing).

Evidence: "CANCELLED BY REGISTRAR MAY 6 1901" stamped diagonally over a
live certificate (`c-physical-print/certificate-cbq-railroad-1887.jpg`);
Flighty keeps the superseded time struck through beside the green
actual (`a-named-apps/flighty-flight-detail-prediction-colors.png`);
Mercury keeps failed payments as struck-through rows rather than
hiding them (`b-trust-artifacts/mercury-transactions-ledger.png`).
That honesty is precisely what makes a surface read as a ledger rather
than a dashboard.

## P3, Ordered granularity is the proprietary language

The five brand readings collapse into one idea at three scales
(full study: [02-field-notes/d-grain-studies.md](02-field-notes/d-grain-studies.md)):

- **Fact scale, one grain, one fact.** Verified facts render as
  addressable units: countable, tappable, each resolving to evidence.
  Density of grains IS density of evidence. Constraint from looking:
  units survive in mass only when position and value carry meaning
  (Seurat); an unordered pile reads as anonymity
  (`d-grain-studies/unit-rice-pile-anonymity.jpg`).
- **Time scale, rings.** Accumulated history drawn as a ring/stratum
  timeline: each verified year adds a ring, spacing encodes volume.
  Dendrochronology already treats rings as a measured data series
  (`d-grain-studies/rings-dendro-lab-core-reading.jpg`). Drawn, never
  photographic.
- **Surface scale, stipple.** Banknote-grade ordered dot/line screens
  on credential surfaces, revealing more order under zoom, the visual
  language of the unforgeable
  (`d-grain-studies/stipple-banknote-washington-engraving.jpg`).

Rejected readings: film grain (randomness = counterfeit authenticity
cue, wrong for a verification brand) and against-the-grain as a visual
device (reads as damage; it stays in copy and strategy).

No software brand owns ordered granularity. This is the identity's
center of gravity.

## P4, Precision is the texture

Physical trust artifacts signaled trust through visible cost:
engraving, intaglio, guilloché. Pasting those textures onto a screen
copies the pixels and inverts the signal. On screen the honest
equivalent of cost is **precision**: absolute alignment, hairline
linework, tabular figures, template discipline, drawn pattern systems.

Evidence: Norway's 200-krone reverse strips all engraving texture,
keeps only structure, namely pixel mosaic, dotted vectors, and
twice-printed serial, and still reads unmistakably as money
(`c-physical-print/banknote-nok-200-back-pixel.jpg`). This settles the
skeuomorphism question from the brief: structural borrowing yes,
textural borrowing never.

## P5, Document, not dashboard

The worker's profile is a **document class**, not a stat screen:

- **Series template discipline.** One rigid skeleton for every
  instance; only designated slots vary. The consistency is itself the
  trust signal (Swiss franc series,
  `c-physical-print/banknote-chf-9th-series-full-set.png`).
- **Document furniture that works.** Serial numbers as their own
  visual layer; micro-caption labels over larger values; working
  borders and reserved margins; identity encoded redundantly
  (`c-physical-print/passport-finland-data-page.jpg`).
- **Attestations carry role, not just name.** For example, "verified
  by [party], [role], [date]", and every verification mark resolves to evidence
  on tap; the resting face shows little (minimal face, gated detail:
  `b-trust-artifacts/apple-wallet-tsa-presentment-sheet.jpg`,
  `b-trust-artifacts/github-signature-popover-evidence.png`). Absence
  of a mark is the negative state; nothing ever says "unverified."
- **The shareable is a document.** Flighty's Passport is the proof:
  MRZ chevrons, trilingual caps labels, split-flap digits.
  Screenshotting it feels like showing a document, not a stat screen
  (`a-named-apps/flighty-passport-card-mrz-detail.png`). Grain's
  shareable belongs to the same class: an earned instrument, in the
  world's visual language for credentials, rendered with P4 precision.

## P6, Celebration is a state change, spent by the moment hierarchy

Duolingo's mechanic, disciplined by the brief's celebration economy:
reward is an existing element changing state, the bar itself turning
gold, never a spawned overlay
(`a-named-apps/duolingo-lesson-screens-progressbar-states.png`).
Applied to Grain's heavy moments (hired; history verified; attestation
lands; milestone):

- The verification moment is a **stamp ceremony**: the stamp arrives
  as a physical event, grid-breaking, pressed into the page, haptic
  at the moment of contact, then the screen returns to calm with the
  artifact quietly in its home (Apple's pattern: ceremony at commit,
  then "✓ Done,"
  `b-trust-artifacts/apple-wallet-add-id-seal-disclosure.jpg`).
- **Rarity as material**: milestones re-mint the same object in
  scarcer finishes with the record embossed into it, rather than
  adding new UI (`a-named-apps/duolingo-personal-record-badge-materials.png`).
- Physicality is cheap and specific: Duolingo's entire tactile feel is
  a 2px darker bottom edge that compresses on press. Light moments
  (applying, adding unverified history) get at most that.
- No audio requirement. Haptics carry the physical channel.

## P7, Restraint is deleted containers; color is semantic

X's restraint decomposes mechanically: no cards, no borders. Hairlines
and whitespace only, so the one boxed element (quote tweet)
*means* "embedded object" (`a-named-apps/x-feed-density-detail.png`).
Flighty's color grammar: color attaches to typographic facts by state,
actual vs. predicted vs. physical
(`a-named-apps/flighty-flight-detail-prediction-colors.png`).

Grain's law, independent of whatever palette is chosen: **containers
and color both carry meaning or don't appear.** Accent color is a
state grammar (verified / pending / self-reported / revoked), never
decoration. Whether the base is warm paper or cold ink, light or dark,
one accent or two, open, for the option boards.

## P8, Alive means mutation in place

Flighty's ledger feel is mechanically: rows mutate in place, change
history stays visible in the row, UI is never spawned to announce
change. All three named apps share instrument-panel typography, big
heavy digits, small quiet labels, left-text/right-number rows. The
ledger should feel like a living document being written, not a feed
being refreshed.

---

## What this rules out

Everything in [01-banned-patterns.md](01-banned-patterns.md), plus now
specifically: pasted textures of any kind (P4), decorative grid-breaks
(P1), celebration overlays and confetti (P6), non-semantic accent
color (P7), "unverified" as a rendered state (P5), photographic
grain/rings (P3).

## The test, restated

Every screen: (1) could this element justify itself to a skeptical
worker whose career is on the page, on the axis of order, stamp,
grain, precision, or state? (2) cropped, could it be mistaken for
either slop cluster?
(3) is any treatment applied uniformly that should vary by meaning?

## Open, to the option boards

Palette direction, base value (paper-light vs. ink-dark vs. both),
accent hue(s) for the state grammar, and typography (the serif/sans
question becomes: what renders document-grade at P4 precision on a
phone). Decided by eye, outside the repo, then recorded here.
