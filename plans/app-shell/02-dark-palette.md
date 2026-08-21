---
id: app-shell/02
type: task
layer: app-shell
satisfies: [3]
status: ready
depends_on: [app-shell/00, app-shell/01]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#046
  - decisions/LOG.md#049
  - DESIGN.md#12
evidence: []
verified_by: null
---

# The dark palette, derived rather than inverted

## Objective

Dark mode ships at v1 as a **second palette**, not a mechanical inversion
(037). It has never been drawn, and `DESIGN.md` gap 6's decision half is closed
while its drawing half is not.

## Scope

- A dark palette derived independently from §12's contrast floors, not from
  flipping the light one. 037 records why the inversion rule does not survive
  arithmetic: `--rule` at 3.35:1 on paper is a different ratio inverted, and the
  imprint's hairlines **bloom** on dark ground where they **fade** on light.
- Every state in the system distinguishable in both appearances or in neither.
- The imprint's stroke weights re-checked against the dark ground, since the
  figure is the surface most sensitive to it.

## Acceptance

1. **Every pair clears the same floor in both appearances.** (mechanical) every
   colour pair in the dark palette meets the contrast floors `DESIGN.md` §12
   sets for light, computed from the tokens rather than sampled from a render.
2. **No token distinguishes in one appearance only.** (mechanical) for every
   token pair the design system defines, the distinguishing property is present
   in both palettes or absent from both, asserted over the token set alone.
   **Whether the five provenance classes then read correctly is
   `worker-surface` criterion 2**, which already says provenance is
   distinguishable everywhere it renders without relying on colour.
3. **The figure holds on dark ground.** (mechanical) the imprint's thread
   separation at each drawn tier meets the same device-pixel floor 044 sets for
   light, computed on the dark stroke values.
4. **Nothing hard-codes a light value.** (mechanical) no meaning-bearing colour
   is a literal outside the token block, asserted by a grep over the surfaces.

## Outside check

Verifier renders the token set and the imprint's stroke values in both
appearances on a real handset in daylight and confirms the contrast floors hold
where a computed ratio and an eye disagree. Reading a real record in dark mode
is `worker-surface`'s outside check, not this layer's.
