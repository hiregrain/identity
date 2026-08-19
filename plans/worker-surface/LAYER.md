---
id: worker-surface
type: layer
status: draft
milestone: v1
depends_on: [person-identity, consent-and-deletion]
binds:
  - decisions/LOG.md#039
  - decisions/LOG.md#040
  - decisions/LOG.md#022
  - decisions/LOG.md#035
  - decisions/LOG.md#036
  - design/06-worker-app-ia.md
  - design/07-worker-app-design-review.md
  - design/08-app-inventory.md
  - design/ledger-design-0.1.md#7.1
  - design/ledger-design-0.1.md#8.1
evidence: []
verified_by: null
---

# worker-surface

The worker's own application — the one surface the ledger owns end to end,
rendered in invariant ledger chrome on the ledger's origin.

Scope: the record view — every raw fact including superseded versions,
disputed/invalidated attestations with counter-statements, verification
history, all in provenance-graded rendering; grant management (who reads,
grant/revoke, full read log); dispute filing and tracking (the FCRA-shaped
flow from design 0.1 §4); deletion request flow; profile and self-asserted
claim editing (freeze states visible); notification of new attestations,
expiring grants and dispute deadlines (read events are **not** surfaced —
decision 035 §B4); localization scaffolding from day one (EN, then TL/HI
with the first regional cohort).

**The runtime moved out on 2026-08-19.** This layer previously scoped
"responsive web first, installable PWA before native." Native iOS and
Android is now the target and the platform contract is its own layer,
`app-shell`. What stays here is *what the worker sees*; what lives there
is everything true of every screen on a device.

**Three rulings changed screens here on 2026-08-19, after this layer was
otherwise settled.** A **deletion control returns to the app** and *files* the
support request rather than executing it (decision 040 §D; Apple 5.1.1(v) makes
support-only a rejection, and the consent instrument promises the right at
signup). **Adding a chapter has no party search** (decision 039) — search is not
effective at global scale, so the screen captures the raw employer string
faithfully plus disambiguating context, country and city at minimum, and never
forces a match. The screen records `party_country` and `party_locality`
(`model/record-schema.md`) because context not collected at entry cannot be
backfilled; resolving those strings into canonical employers is deliberately not
built (decision 041). And **F3,
the identity-capture screen, is relaxed** (decision 040 §C): neither vendor
permits hosting capture in the host app's chrome, so it is our screen handing off
with the vendor named on it.

**The attester's surfaces are NOT here.** Decision 035 gave every attester an
account; decision 038 put that flow on the web. An invitation opens the web
attestation surface (`public-web`), the form itself is `peer-references`, and
this layer sees an attester only later, as a person holding their own record.

**The full screen and component inventory is
[`design/08-app-inventory.md`](../../design/08-app-inventory.md)** — 52
surfaces, of which 9 are drawn. Task decomposition follows that document,
not this paragraph. Operator-side analytics are not shown (decision 002 §4,
decision 022); the raw record always is.

**The boundary of "the record", for criterion 1.** Analytics run records are
compliance artifacts about Grain's own processing, not entries in the
person's record, and are not shown here (decisions 022, 026). Attester
veracity events no longer exist (decision 025). Criterion 1's "nothing hidden"
therefore means every fact *about the person* — which is the whole record
and always was.

**Grill-before-ready is discharged** (decision 035, nine rounds; decision
036, follow-on rulings). Promotion to `ready` now waits only on the four
founder gates raised in `design/08-app-inventory.md` §0 and recorded in
`plans/ORDER.md` — the platform target, Android intra-record navigation,
the dark palette, and the companion typeface. Task files are authored when
those close.

## Design venue, and the mockup gate

**Design happens on the published canvas**, not in repo tasks:

<https://claude.ai/code/artifact/7d177fbe-88c2-4e18-97b8-5a8d1fd85232>

Its source of record is
[`design/10-worker-app-screens/`](../../design/10-worker-app-screens/), which
is authoritative where the two disagree. Repo tasks in this layer cover
*build*, against surfaces settled there.

**The gate, adopted from `dispatch/plans/console` and binding here: nothing in
this layer gets built — no task claimed, no screen coded — until the surface it
implements is drawn. A build task names the surface it implements; a build task
with no named surface is not authorable.** This is the design-track counterpart
of "code is written only against a `ready` plan layer."

**The register is [`design/08-app-inventory.md`](../../design/08-app-inventory.md) §1**,
which lists every surface with its status. It is the checklist the gate runs
against, and it is also this layer's decomposition input — tasks derive from it,
not from prose here.

**Nine of fifty-two surfaces are drawn.** Forty-three are listed with nothing
behind them, so most of this layer is gated today. That is the honest state and
the gate is what keeps it visible.

**A drawn surface is not a settled one.**
[`design/07-worker-app-design-review.md`](../../design/07-worker-app-design-review.md)
records what six independent reviews found in the nine that exist, several of
which are still open in the source. A surface with unresolved review findings is
drawn, not settled, and the gate reads settled.

**This layer cannot be four to eight tasks.** `plans/ORDER.md` sets that guidance
and thirty-six unbuilt app surfaces do not fit it. Splitting is unresolved and is
the first question its engineering review has to answer — `app-shell` had eleven
scope items and was split on the same grounds (decision 042).

Acceptance:
1. **Every fact about the person is reachable in the app.** A side-by-side
   against a raw API dump shows nothing hidden. **Narrowed by decision 035
   §B4/§B5:** read events are excluded (grant *state* is shown, not reads —
   the disclosure record is served on request), and there is no dispute UI,
   so a chapter renders its `disputed` field but no dispute flow exists in
   the app.
2. **Provenance is distinguishable everywhere it renders, without relying on
   colour.** Provenance classes are visually distinct at every rendering
   site, at WCAG-AA contrast, with no colour-only encoding.
3. **Grant, revoke and delete each complete on a small phone over a slow
   link.** Each is completable start to finish on a 360px viewport over a
   slow connection. Dispute is not in this list because decision 035 §B5
   removed the in-app dispute flow — see criterion 1's narrowing.
4. **Trust-bearing flows serve from the ledger's own origin.** No vertical
   chrome, no theming beyond light/dark (per the invariant-chrome ruling
   pending in the decisions log).
5. **Every surface exists and carries all five of its states.** Every surface
   in `design/08-app-inventory.md` §1 exists and carries all five states
   named in its §2 — loading, empty, error with a retry, offline, permission
   denied. A surface missing a state is not done.
6. **No screen claims more than the record supports.** Checked against
   `design/07` §5: provenance is legible in words on the worker's own rows,
   a chapter's removability is described accurately, no ordinal renders a
   person on a scale, and the ceremony cannot produce corroboration from a
   single attestation.
