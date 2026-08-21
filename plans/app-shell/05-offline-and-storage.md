---
id: app-shell/05
type: task
layer: app-shell
satisfies: [6]
status: ready
depends_on: [app-shell/00, app-shell/01]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#039
  - DESIGN.md#12
evidence: []
verified_by: null
---

# The record reads with no network, and the storage model that makes that true

## Objective

§12's rule that the record stays readable from cache, plus the storage and
staleness contract it needs. Decision 039 settles the hard part and it is not a
detail: **installation is the storage model, not a distribution preference.**

## Scope

- Offline is **read-only**. The whole record readable, the imprint computed on
  device, and **nothing queued for later write**: a queued attestation request
  firing days later against a changed registry is a correctness problem, and
  this population's connectivity makes those days real (039).
- **iOS**: the promise holds only for an installed Home Screen web app. WebKit
  deletes IndexedDB, local storage, the Cache API and the service-worker
  registration after seven days without interaction, and exempts installed web
  apps by name.
- **Android**: the app claims persistent storage, because eviction is
  least-recently-used under disk pressure.
- A staleness contract: what the worker is told about how old the cached copy
  is, and what the app does when it cannot tell.

## Acceptance

1. **The cache serves the whole record with the network off.** (mechanical)
   with the network disabled, the storage layer returns every record object it
   held, byte-identical to what it stored, proven against a fixture record
   driven cold. **Whether those objects then render is `worker-surface`'s**;
   this layer owns the cache and its contract, not the surfaces over it.
2. **The storage layer offers no write queue.** (mechanical) the cache exposes
   no enqueue path and rejects a write attempted while offline, asserted
   against the storage API alone. **Whether every product affordance is then
   disabled is `worker-surface`'s**, which owns the surfaces; this layer can
   only guarantee there is nothing for them to queue into.
3. **The cached copy states its age.** (mechanical) the offline state renders
   when the copy was last refreshed, and renders that it cannot tell when it
   cannot.
4. **Android asks for persistence and handles refusal.** (mechanical) the
   persistent-storage request is made, its result recorded, and **refusal is a
   handled state rather than an assumption**: when persistence is denied the
   layer reports its storage as evictable so a surface can say so. Requesting
   persistence is not being granted it, and browsers deny it.
5. **The tab case is not promised.** (mechanical) the storage layer reports
   whether it is running installed or in a tab, and reports the seven-day
   expiry when it is a tab, so a surface can tell the truth about it. **The
   copy that does so is register row H2-1, owned by `worker-surface`**; this
   criterion grades the signal, not the sentence.

## Outside check

Verifier installs on iOS, reads the record with the device in airplane mode,
leaves it untouched, and confirms the app's own copy about the seven-day window
matches what actually happens.
