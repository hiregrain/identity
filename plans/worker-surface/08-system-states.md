---
id: worker-surface/08
type: task
layer: worker-surface
satisfies: [5, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#035
  - DESIGN.md#12
  - design/08-app-inventory.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# The five states, and the screens that are only a state

## Objective

The states every surface must carry, built once as shell renderers rather
than drawn sixty times, plus the surfaces that are nothing but a state.

Surfaces implemented: H2-1, H2-2, H2-3, H2-4, I1, I2, I3, I4, I5, I8, I10.

## Scope

- Loading, empty, error with a retry, offline, and permission denied, as
  renderers a surface declares rather than screens each surface redraws.
  `design/08` §2 treats these as work remaining per surface, which is five
  times the register; this is the same coverage at a fraction of the surface
  area.
- Offline is §12's micro-caption band with the record still readable from
  cache, never a dialog.
- Address not found, update required, signed out unexpectedly, the content of
  each push notification, and the legal surfaces.
- **Push content carries no read events** (decision 035 §B4). The three events
  are a party attesting, a grant ending, and a dispute deadline.
- Address not found never reveals whether an address once existed.

**The browser's own states, added after the review** (decision 081). Register
section H2 is the four surfaces a browser makes necessary and no task owned
them, though the register called them BUILT: the install invite and what
offline actually promises in a tab, unlock by passkey, the newer-version
reload, and the copy-link send. `app-shell` owns the *signal* underneath them,
whether the app is installed and whether its storage is evictable; this task
owns the *surfaces that say so*, because every register surface is
`worker-surface`'s.

**What is still gated is the timing, not the surface.** When a tab user is
invited to install, and what the prompt says, is a founder gate in
`plans/ORDER.md`. The surface exists and tells the truth about which mode it is
in; the criterion below grades that honesty, not the persuasion.

## Acceptance

1. **Every surface declares which of the five states it carries.** (mechanical) every surface in the register declares which of the five
  states it has, and every declared state renders non-empty and distinct.
  A surface declaring none fails.
2. **Offline still reads the record.** (mechanical) the offline state leaves the record readable, proven by
  cutting the network and asserting the cached record still renders.
3. **No notification copy derives from a read event.** (mechanical) no notification **copy** this task renders contains a field
  derived from a read event. The **payload** rule moves to `app-distribution`,
  which owns push (decision 079); this layer owns the wording, register row I8.
4. **A record that never existed and one that was deleted answer identically.** (mechanical) the not-found surface emits an identical response for an
  address that never existed and one that was deleted.
5. **The install invite states the storage truth and never overstates it.**
   (mechanical) in an uninstalled browser tab the invite renders and states the
   seven-day expiry; once installed it does not render at all; and no surface
   in either mode claims the record reads offline while running in a tab,
   asserted over the render tree in both states. The **timing** of the invite
   is a gate in `plans/ORDER.md` and is deliberately not graded here.
6. **No error blames the worker or shows a raw fault.** (adjudicated) no error surface blames the worker or reports a raw
  exception.

## Outside check

Verifier cuts the network mid-session and confirms the record still reads,
then requests a deleted handle and a never-existent one and confirms the two
responses are indistinguishable.
