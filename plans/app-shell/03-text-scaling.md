---
id: app-shell/03
type: task
layer: app-shell
satisfies: [4]
status: ready
depends_on: [app-shell/00, app-shell/01]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#046
  - design/08-app-inventory.md
evidence: []
verified_by: null
---

# Text that grows without breaking the record

## Objective

The open engineering problem `design/08` §0.4 names: a type scale expressed
entirely in fixed pixels, against iOS Dynamic Type at 3.12x the default and an
Android curve whose own documentation warns against reproducing it with a
multiplier.

## Scope

- Every meaning-bearing size and spacing expressed so the system's own scaling
  applies, rather than as a fixed pixel value.
- **The ledger row's right-hand figure column is `nowrap` today and has no
  reflow story.** `design/08` §0.4 names it as the first thing to fix, so it is
  named here rather than discovered.
- A reflow rule for every row that carries record data: dates, counts and the
  tabular figures that currently assume they fit.

## Acceptance

1. **Type and rhythm scale with the system.** (mechanical) no font size, line
   height or vertical rhythm is a literal px value outside the token block,
   asserted by a grep over `design/10-worker-app-screens/tpl/` and the shell
   sources, **excluding** hairlines, icon boxes, hit-target minimums and
   device-pixel values, which are legitimately fixed and are listed by name in
   the check. A grep criterion with no stated exclusions is grep theatre.
2. **The row primitives survive the largest setting.** (mechanical) **this
   layer owns the shared row primitives**, which is stated here because the
   boundary was hand-waved: they are chassis, not content, and
   `design/10-worker-app-screens/tpl/_chrome.part` already holds them in one
   place for exactly that reason. At iOS AX5 and the top of the Android curve,
   each row primitive this layer defines
   (`.row`, `.srow`, `.prow`, `.drow`, the ledger row) reflows without
   clipping, truncating or overlapping, driven against fixture content rather
   than against product surfaces. **The sweep over every real surface is
   `worker-surface` criterion 8**, which already reads "every surface renders
   on both platforms and at 200% type"; this layer owns the mechanism and that
   layer owns the sweep, because `app-shell` only soft-depends on it and a soft
   dependency is not read by the frontier.
3. **The figure column reflows rather than truncating.** (mechanical) the
   ledger row's right-hand column wraps or restacks at the largest setting and
   never renders an ellipsis over a date or a count.
4. **The scale is the system's, not a multiplier.** (mechanical) the Android
   path reads the platform's own scaled value rather than multiplying a base,
   asserted at the call site, because the curve is non-linear.

## Outside check

Verifier sets the largest system text size on both platforms and reads one
attested chapter end to end. Nothing is cut off and no number is replaced by an
ellipsis.
