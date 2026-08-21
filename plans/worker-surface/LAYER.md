---
id: worker-surface
type: layer
status: ready
milestone: first-product
depends_on: [person-identity, consent-and-deletion, self-asserted-record]
binds:
  - decisions/LOG.md#022
  - decisions/LOG.md#035
  - decisions/LOG.md#036
  - decisions/LOG.md#037
  - decisions/LOG.md#039
  - decisions/LOG.md#040
  - decisions/LOG.md#044
  - decisions/LOG.md#045
  - decisions/LOG.md#046
  - decisions/LOG.md#047
  - decisions/LOG.md#048
  - decisions/LOG.md#050
  - decisions/LOG.md#054
  - decisions/LOG.md#055
  - decisions/LOG.md#056
  - decisions/LOG.md#057
  - decisions/LOG.md#058
  - decisions/LOG.md#059
  - decisions/LOG.md#060
  - decisions/LOG.md#061
  - decisions/LOG.md#063
  - decisions/LOG.md#071
  - decisions/LOG.md#074
  - decisions/LOG.md#076
  - decisions/LOG.md#079
  - decisions/LOG.md#080
  - design/06-worker-app-ia.md
  - design/07-worker-app-design-review.md
  - design/08-app-inventory.md
  - design/12-platform-seam.md
  - design/ledger-design-0.1.md#7.1
  - design/ledger-design-0.1.md#8.1
gated_criteria: []
evidence: []
verified_by: null
---

# worker-surface

The worker's own application, the one surface the ledger owns end to end,
rendered in invariant ledger chrome on the ledger's origin.

Scope: the record view: every raw fact including superseded versions,
disputed/invalidated attestations with counter-statements, verification
history, all in provenance-graded rendering; grant management (who reads,
grant/revoke, full read log); dispute filing and tracking (the FCRA-shaped
flow from design 0.1 §4); deletion request flow; profile and self-asserted
claim editing (freeze states visible); notification of new attestations,
expiring grants and dispute deadlines (read events are **not** surfaced,
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
signup). **Adding a chapter never resolves a string into an employer** (decisions 039,
041). What is forbidden is resolution, not lookup: the screen may search the
parties Grain has actually registered, and it must always offer the raw string
as the worker typed it, carrying the self-asserted mark so no party is implied.
It captures that string faithfully plus disambiguating context, country and city
at minimum, and never forces a match. It records `party_country` and
`party_locality` (`model/record-schema.md`) because context not collected at
entry cannot be backfilled. An earlier draft of this layer read "adding a chapter
has no party search", which is a stronger claim than either decision makes and
contradicts the surface drawn in `design/13`. And **F3,
the identity-capture screen, is relaxed** (decision 040 §C): neither vendor
permits hosting capture in the host app's chrome, so it is our screen handing off
with the vendor named on it.

**The attester's surfaces are NOT here.** Decision 035 gave every attester an
account; decision 038 put that flow on the web. An invitation opens the web
attestation surface (`public-web`), the form itself is `peer-references`, and
this layer sees an attester only later, as a person holding their own record.

**The full screen and component inventory is
[`design/08-app-inventory.md`](../../design/08-app-inventory.md).** Task
decomposition follows that document, not this paragraph. No count of surfaces
appears here: `CLAUDE.md` forbids hand-written counts of checkable things, and
the three this layer used to carry had all drifted. Operator-side analytics are not shown (decision 002 §4,
decision 022); the raw record always is.

**The boundary of "the record", for criterion 1.** Analytics run records are
compliance artifacts about Grain's own processing, not entries in the
person's record, and are not shown here (decisions 022, 026). Attester
veracity events no longer exist (decision 025). Criterion 1's "nothing hidden"
therefore means every fact *about the person*, which is the whole record
and always was.

**Grill-before-ready is discharged** (decision 035, nine rounds; decision
036, follow-on rulings). Of the four founder gates raised in
`design/08-app-inventory.md` §0, decision 037 closed three: the platform target
is native iOS and Android with the PWA first-class from the same codebase,
Android intra-record navigation is settled by capping the edge index inside the
gesture budget and demoting it to an accelerator, and the companion typeface is
Noto Sans Devanagari. **The dark palette is decided and undrawn**: 037 ships it
at v1 as a second palette derived independently from §12's contrast floors
rather than as an inversion, and no surface exists in it.

**Two surfaces are blocked rather than undrawn, and neither is a design
problem.** The consent instrument is gated on decision 054's open question:
seven measures are collected and stored and none are rendered, and what consent
must say about them is unwritten. The app icon is gated on the mark itself,
whose lobe count and break angle `mark/README.md` §6 leaves open, and §2 keeps
the lobe count open partly over collision with existing marks. Both are drawn as
blocked in `design/13` so the flow walks; neither may be built.

**Three rulings after 2026-08-19 change what this layer renders.**

**Operator reads are disclosed; grantee reads are not** (decisions 035 §B4,
063). Read events by a grant holder are not recorded anywhere, so the disclosure
record cannot and does not show them. Privileged-operator reads are a different
thing: `trust-kernel` emits them as chained privileged actions with a recorded
reason, and **this layer renders them into the disclosure record**. One
tamper-evident record of operator actions, surfaced to the person it is about.

**The identity ladder never reaches a partner** (decision 071, superseding 028
on this line). The none/channel/document/biometric ladder is internal and
worker-facing. It appears in no packet and no party-facing payload, because a
binary chip is a graded claim collapsed to a yes, which the constitution
forbids. A screen that tells the worker what a reader will see about their
identity check is therefore asserting something that does not cross.

**Capture is a handoff, not a hosted camera** (decision 040 §C). Neither vendor
permits hosting the capture step inside the host app's chrome, so F3 is Grain's
own screen handing off, with the vendor named on it. A drawn viewfinder inside
Grain's frame overstates what the integration allows.

**The split, answered.** `plans/ORDER.md` guides four to eight tasks and this
layer could not fit it as one. It splits into nine, by flow rather than by
register section, with the shared vocabulary first: the record and the imprint
carry the ledger row, the provenance marks, the plate, the figure and §7's
depth, and every later task inherits them. That ordering is deliberate. In the
prototype the expensive errors were all shared-decision errors, and each would
have multiplied across the register had the surfaces been built first.

Task 09 holds the two surfaces that are blocked rather than undrawn, so
criterion 5's remainder has a declared home instead of quietly failing.

**What task authoring did not wait for.** The dark palette is still decided and
undrawn, but its criteria live in `app-shell` criterion 3, which checks the
numbers rather than the drawing. Nothing in this layer's criteria depends on it,
so authoring proceeded.

## Identity left this layer (decision 079)

Register section F, the identity flow's screens, is now
[`plans/worker-identity-surface`](../worker-identity-surface/LAYER.md). It was
task 05 here. The outside voice argued this layer was several layers wearing one
name, and that corner is gated on the Persona DPA, India DPDP residency and
counsel, none of which an engineer can clear. Left inside, a legal timetable
would have held the record, sharing, deletion and onboarding hostage.

The new layer depends on this one, because it renders in the chassis task 01
builds. Criteria 1, 5, 6, 7 and 8 lose one of their owners and every one is
still owned by at least four tasks.

## Design venue, and the mockup gate

**Design happens in the prototype**, not in repo tasks:

<https://claude.ai/code/artifact/3dba48b7-cacc-4823-b950-333f7e5681bf>

Its source of record is
[`design/13-platform-screens/`](../../design/13-platform-screens/), which is
authoritative where the two disagree. **The browser surface is
[`design/14-web-app/`](../../design/14-web-app/)** and it *imports* the record's
own surfaces from `design/13` rather than redrawing them, so the two cannot
drift on anything the record draws; what it authors is chrome, because a browser
returns almost every control the platform seam had handed to the system
(`design/12` "The seam in a browser"). `design/10-worker-app-screens/` is the
prior canvas and is kept as the record of how the system got here; where it and
`design/13` disagree, `design/13` governs, because 047's platform seam and the
rulings of 2026-08-20 are only in the latter. Repo tasks in this layer cover
*build*, against surfaces settled there.

**The seam is [`design/12-platform-seam.md`](../../design/12-platform-seam.md)**
and it binds: which controls are Grain's, which are the platform's, and the one
test that decides. Grain keeps a control only where the platform's version is
worse, never where it is merely different, and worse means a named failure
against decision 046's target.

**The gate, adopted from `dispatch/plans/console` and binding here: nothing in
this layer gets built, no task claimed, no screen coded, until the surface it
implements is drawn. A build task names the surface it implements; a build task
with no named surface is not authorable.** This is the design-track counterpart
of "code is written only against a `ready` plan layer."

**The register is [`design/08-app-inventory.md`](../../design/08-app-inventory.md) §1**,
which lists every surface with its status. **A task pins the register at the
commit it was authored against**, named in the task, because the register is
edited as design proceeds and an unpinned reference means a task's scope changes
without anyone deciding it (outside voice, decision 079). It is the checklist the gate runs
against, and it is also this layer's decomposition input. Tasks derive from it,
not from prose here.

**Decisions 074 and 076 are folded in.** Title, headcount and the countable
step reach the app through the add flow (074); education and certificates are
drawn at last, since 062 made them record objects and criterion 1 requires every
fact about the person to be reachable; and a pushed bar carries the wordmark
home (076), which amends `design/12`'s seam table on one row.

**Most surfaces are drawn now**, in `design/13-platform-screens`, which is a
working prototype rather than a set of artboards: every surface renders on both
platforms, at three text sizes, with the five states as a shell control rather
than as separate drawings. The register says which are drawn; this paragraph
does not, for the reason above.

**A drawn surface is not a settled one.**
[`design/07-worker-app-design-review.md`](../../design/07-worker-app-design-review.md)
records what six independent reviews found in the nine that exist, several of
which are still open in the source. A surface with unresolved review findings is
drawn, not settled, and the gate reads settled.

**This layer cannot be four to eight tasks.** `plans/ORDER.md` sets that guidance
and the register does not fit it. Splitting is unresolved and is the first
question its engineering review has to answer. `app-shell` had eleven scope items
and was split on the same grounds (decision 042).

Acceptance:
1. **Every fact about the person is reachable in the app.** A side-by-side
   against a raw API dump shows nothing hidden. **Narrowed by decision 035
   §B4/§B5:** read events are excluded (grant *state* is shown, not reads,
   the disclosure record is served on request). **Decision 079 reinstates the
   dispute flow** that 035 §B5 removed, bounded by 028's line: Grain
   adjudicates authenticity, never substance, and a substance disagreement is
   carried as the worker's counter-statement beside the claim. Its surfaces are
   undrawn, so the mockup gate blocks building them.
2. **Provenance is distinguishable everywhere it renders, without relying on
   colour.** Provenance classes are visually distinct at every rendering
   site, at WCAG-AA contrast, with no colour-only encoding.
3. **Grant, revoke and delete each complete on a small phone over a slow
   link.** Each is completable start to finish on a 360px viewport over a
   connection throttled to **400 kbps down, 400 kbps up and 400 ms round trip**,
   which is the standard Slow 3G profile and is reproducible rather than
   judged. Budgets, end to end including taps: a grant in 15 s, a revoke in
   8 s, a deletion request in 15 s. **The budgets are provisional until the
   first measurement on real hardware** and are stated so the criterion can
   fail; the profile is not provisional.
4. **Trust-bearing flows serve from the ledger's own origin.** (adjudicated)
   No vertical's branding, no theming beyond light and dark. This is the
   neutrality guarantee `CLAUDE.md`'s product test turns on, given Grain both
   holds the record and operates verticals on it (024). **Ungated by decision
   079**, which makes the invariant-chrome ruling, and owned by task 01, which
   already owns the chassis. **Owed:** "origin" is a web concept and the
   primary target is native. **Decision 080 settles it:** a trust-bearing flow
   is drawn by Grain's own code against Grain's API, with no vertical's
   webview, vendor-themed component or SDK-rendered screen inside it. The one
   exception is the contracted identity vendor, which 040 §C forces because
   neither vendor permits an app to host their capture step, and which 036
   bounds by requiring the vendor be named on screen before the handoff rather
   than after. On the web the criterion keeps its literal origin meaning.
5. **Every surface exists and carries all five of its states.** Every surface
   in `design/08-app-inventory.md` §1 **that the register does not declare
   blocked** exists and carries all five states
   named in its §2: loading, empty, error with a retry, offline, permission
   denied. A surface missing a state is not done. A state may be a shell
   renderer the surface declares rather than a separately drawn screen, which
   is how `design/13` carries them.
6. **No screen claims more than the record supports.** Checked against
   `design/07` §5: provenance is legible in words on the worker's own rows,
   a chapter's removability is described accurately, no ordinal renders a
   person on a scale, and the ceremony cannot produce corroboration from a
   single attestation.
7. **Every control sits on the correct side of the seam.**
   `design/12-platform-seam.md`'s table is the check: a control is Grain's only
   where the platform's version fails a target decision 046 already binds.
   Two do, and a third is a defect: the chassis forces butt terminals over
   `.icon`'s square ones, so §8's icon rule is contradicted on every screen
   that predates `design/13`.

8. **Every surface renders on both platforms and at 200% type.** Both, for
   each surface, with the imprint taking decision 044's small-tier behaviour
   rather than scaling past the display.
