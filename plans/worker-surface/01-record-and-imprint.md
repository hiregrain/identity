---
id: worker-surface/01
type: task
layer: worker-surface
satisfies: [1, 2, 4, 6, 7, 8]
status: draft
depends_on: []
binds:
  - decisions/LOG.md#035
  - decisions/LOG.md#044
  - decisions/LOG.md#045
  - decisions/LOG.md#047
  - decisions/LOG.md#048
  - decisions/LOG.md#050
  - decisions/LOG.md#054
  - decisions/LOG.md#055
  - decisions/LOG.md#076
  - decisions/LOG.md#079
  - design/12-platform-seam.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# The record, the imprint, and the vocabulary every other surface inherits

## Objective

The one screen a worker opens, and the components every later task reuses.
This is first because it carries the shared risk: a wrong ledger row or a
wrong provenance mark is wrong on every surface after it.

Surfaces implemented: B1, B3, B4.

## Scope

- The record: identity hero, the figure, and the actionable list. The figure
  is the record's index and a work-history row opens it; **the record does not
  also list the chapters underneath**, which was drawn and cut because a worker
  read the same employers three times on one screen.
- The imprint expanded, with its ring list and per-row disclosure in place.
  There is no chapter screen: four facts is not a destination.
- The shared vocabulary: the ledger row with its state gutter, the five
  provenance marks, section heads, the sine-modulated divider, the plate's
  registration corners, the graticule ground, and the type registers.
- §7's depth, drawn rather than described: a pending row sits 2px proud of the
  baseline grid, a verified row is flush with zero press-give.
- §10's attestation landing, which is one of the two heavy ceremonies the
  system reserves and has never been built: the row seats with a hard
  decelerate, its mark inks in, and the band that changed re-scribes. The
  haptic belongs to `app-shell`; the visual state change belongs here.
- **Nothing derived from the seven measures renders** (decision 054). Every
  chapter draws the constant neutral profile.

## Acceptance

1. **A party is never named twice on one surface.** (mechanical) rendering the demo record produces no element whose text
  content repeats a party name already rendered elsewhere on the same surface.
  The duplication this prevents is the defect that produced this scope.
2. **The five provenance marks are tellable apart in greyscale.** (mechanical) every provenance class renders a distinct mark, asserted by
  comparing the rendered geometry of all five, and no class is distinguished by
  colour alone. Greyscale conversion leaves all five distinguishable.
3. **No chapter renders a level, a rung or a comparison.** (mechanical) no lobe level, rung, ordinal or comparison appears in any
  rendered output for any chapter, asserted by a search over the render tree
  for the measure fields.
4. **An unattested row sits proud of an attested one.** (mechanical) a pending row's layout rectangle sits 2px above a verified
  row's on the same baseline, read from the layout tree.
5. **The record claims nothing the ledger does not carry.** (adjudicated) the record surface claims nothing the ledger does not
  carry. Given the criterion and the diff alone, a verifier finds no text
  asserting a person is verified, no count of chapters nobody has asked about,
  and no collapse of a graded fact into a yes.

6. **The record paints fast on a cheap phone, and the rows never wait for the figure.** (mechanical) the record's first paint, including the figure, completes
  within budget on a device at or below the Android Go class (2 GB RAM):
  2.5 s cold, 1 s warm. **The figure never blocks the rows from painting**,
  proven by asserting the rows are present in a frame before the figure is.
  The figure is computed on the device and never server-rendered (037), so
  nothing else bounds this cost. Budgets are provisional until first
  measurement; the progressive-paint rule is not.

## Outside check

Verifier renders the record and the imprint from a record with one attested and
one unattested chapter, converts both to greyscale, and confirms provenance is
still readable. Then plays the attestation landing and confirms the figure
re-scribes only the band that changed, not the whole figure.
