---
id: app-shell/01
type: task
layer: app-shell
satisfies: [1, 2]
status: ready
depends_on: [app-shell/00]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#040
  - design/12-platform-seam.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# One design, three runtimes, and the edges the system owns

## Objective

The shell every surface renders inside: iOS, Android and the installable PWA
from one codebase (040), with the system's own furniture respected rather than
drawn over. Nothing else in this layer can be built until a surface has
somewhere to sit.

Surfaces implemented: none directly. This task builds the container
`worker-surface` renders into, which is why that layer depends on this one for
its chassis and why this one soft-depends on it for the shape.

## Scope

- Safe-area insets on all three runtimes: the notch and Dynamic Island, the
  home indicator, the Android gesture bar and cutout. Measured from the running
  device rather than from the 360x800 design frame, which accounts for none of
  them.
- The Android gesture-exclusion claim over the edge index, capped to the 200dp
  per-edge budget that is shared across every window on the display, walked
  bottom-up and truncated silently with no error (037, `design/08` §0.2).
- **The PWA cannot claim the region at all**, which is why 037 demoted the edge
  index to an accelerator. This task proves nothing depends on hitting it.
- Status-bar appearance set by Grain and drawn by the system, per the seam.

## Acceptance

1. **Nothing interactive sits under the system's furniture.** (mechanical) no
   interactive element's layout rectangle intersects a safe-area inset on any
   of the three runtimes, read from the layout tree rather than a screenshot,
   across both device classes in the register's shell rows.
2. **The gesture zone is claimed where it is used, and nothing depends on it.**
   (mechanical) no touch target lies inside the Android system gesture zone
   unless the app has claimed that region, and every destination reachable from
   the edge index is also reachable without it, proven by driving each with the
   index disabled.
3. **The claim stays inside the budget.** (mechanical) the total exclusion
   height requested is at or below 200dp per edge, asserted at the call site,
   since the platform truncates silently rather than failing.
4. **The PWA runs with no exclusion at all.** (mechanical) the PWA build calls
   no exclusion API and passes criterion 2 unchanged.

## Outside check

Verifier runs the shell on a gesture-navigation Android handset and swipes in
from both edges over the record. Neither swipe reaches a destination that has
no other route to it.
