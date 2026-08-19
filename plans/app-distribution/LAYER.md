---
id: app-distribution
type: layer
status: draft
milestone: v1
depends_on: [app-shell, worker-surface, public-web]
binds:
  - decisions/LOG.md#037
  - decisions/LOG.md#038
  - decisions/LOG.md#040
  - design/08-app-inventory.md
evidence: []
verified_by: null
---

# app-distribution

How the app and a person find each other: the link that reaches the app, the
notification that reaches the person, and the listing that puts the app on the
phone.

Split out of `app-shell` on 2026-08-19 (engineering review). That layer scoped
eleven items against `plans/ORDER.md`'s four-to-eight guidance, and these four
gate on different things — the mark's open items and counsel, not on whether a
screen behaves correctly on a device. `app-shell` owns the runtime; this owns
reach.

Scope: **deep links** — universal links on iOS and App Links on Android for
`hiregrain.com/u/<handle>`, with the hosted association files, and the rule that
a link opens the app when installed and the reduced public page when not
(decision 037); **push** — the three events `plans/worker-surface/LAYER.md`
names, their written content, and the moment permission is asked; **launch
identity** — app icon, launch screen and store listing assets; and **store
submission** — privacy nutrition labels and Play data-safety declarations, plus
the two store requirements that are product rulings rather than engineering
ones (decision 038): Apple 5.1.1(v)'s in-app deletion initiation, and Play's
separate requirement for a **web** deletion-request URL, which `public-web`
carries.

**Push content is a boundary, not a preference.** Decision 039 rules that a
notification names the fact and never the content — "Sunrise Foods signed your
work record", never what was said. A lock screen is read by whoever holds the
phone, which on a shared handset is not always the worker; this is the same
reasoning that put biometric unlock on the app.

**Blocked on the mark.** `DESIGN.md` gap 1 leaves the lobe count, the break
angle and largest-to-smallest silhouette agreement open. Decision 039 rules the
app icon **is** the mark, so the icon inherits all three. This layer cannot go
`ready` while they stand, and they are store-submission assets, so the block is
real rather than cosmetic.

Acceptance:
1. **A shared link opens the app if it is installed, and the page if it is not.** a `hiregrain.com/u/<handle>` link opens the app when installed and the
   reduced public page when not, verified on real iOS and Android hardware, with
   the association files served and validated by each platform's own checker.
2. **Every notification names the fact and never the content.** each of the three push events has written content that names the fact
   and never the content, checked by reading every string against decision 039 —
   and the permission prompt fires at a moment tied to the worker's own action,
   never at launch.
3. **The store privacy declarations match the consent instrument line by line.** (mechanical) the store privacy declarations match the consent
   instrument and decisions 036 and 038 line by line, checked by a diff rather
   than by reading. A declaration that drifts from the consent instrument is the
   failure mode this criterion exists to catch.
4. **Deletion satisfies Apple and Play, which require different things.** the deletion path satisfies both stores — an in-app control that
   *initiates* deletion (Apple 5.1.1(v); support-only is a rejection) and a web
   URL where deletion can be requested (Play; no in-app change satisfies it).
5. **The icon holds its silhouette at every size a store demands.** the app icon renders correctly at every store-required size, and its
   silhouette agrees between the largest and smallest tiers — which `DESIGN.md`
   gap 1 lists as open and which this criterion forces closed.

**Outside check.** A person who has never seen the product taps a shared link on
a phone without the app installed, reads the page, installs, and lands on the
record they were sent to. Then they get one notification and can tell, from the
lock screen alone, what happened without learning anything about the work.
