---
id: app-shell/04
type: task
layer: app-shell
satisfies: [5]
status: ready
depends_on: [app-shell/00, app-shell/01]
binds:
  - decisions/LOG.md#047
  - design/12-platform-seam.md
  - DESIGN.md#10
evidence: []
verified_by: null
---

# One hard haptic at contact, named per platform

## Objective

§10's rule that the ceremony's meaning survives without the motion. The seam
gives haptics to the system with Grain naming which one, and the web has none
at all, which this task must state rather than paper over.

## Scope

- `.rigid` on iOS, `HapticFeedbackConstants.CONFIRM` on Android, at the
  attestation-landing seat and nowhere else. One hard contact, not a texture.
- **Retained under `prefers-reduced-motion`**, because §10 says the meaning
  survives without the motion and the haptic is the meaning.
- **The web has no haptic and must not pretend otherwise.** iOS Safari exposes
  no vibration API; the browser build carries the visual beat alone
  (`design/12`, "The seam in a browser").

## Acceptance

1. **The shell exports one haptic primitive, and it names the right constant.**
   (mechanical) this layer exports a single confirm-haptic primitive that
   resolves to `.rigid` on iOS and `HapticFeedbackConstants.CONFIRM` on
   Android, asserted at its definition. **The seat that calls it is
   `worker-surface`'s ceremony**, not this layer's; app-shell owns the plumbing
   and cannot assert a call site on a screen it does not build.
2. **It survives reduced motion.** (mechanical) with `prefers-reduced-motion`
   set, the animation is suppressed and the haptic call still fires.
3. **The shell offers no second way to vibrate.** (mechanical) no shell source
   calls a platform haptic API directly; the exported primitive is the only
   route, asserted by a grep over the shell sources with no exclusions. A
   device that buzzes at everything says nothing by buzzing, and the way to
   prevent that is one door rather than a rule.
4. **The web build calls no haptic API.** (mechanical) the PWA path contains no
   vibration call, and the seat's visual beat runs there unchanged.

## Outside check

**Unverified assumption, carried from `DESIGN.md` §10 and named rather than
assumed:** that reduced motion suppresses haptics is Grain's policy, not
observed platform behaviour, on either platform. The verifier confirms what the
platforms actually do and records it.
