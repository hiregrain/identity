# The imprint — geometry system

The **imprint** is the per-person figure computed from the verified record. It is a
different object from the **Grain mark** (the logo), which is invariant and carries no
data. Both share a construction; only the imprint encodes anything.

Status: **DRAFT**, 2026-08-18. The geometry below is settled enough to build against.
The open items in §7 are not, and two of them are load-bearing.

Companion documents: [`../DESIGN.md`](../DESIGN.md) §2 · [`../THESIS.md`](../THESIS.md) ·
[`../model/attestation-interface.md`](../model/attestation-interface.md) ·
[`../mark/README.md`](../mark/README.md) (the logo and the record pointer — a
**different object**, invariant, carrying no data)

---

## 1. The construction

    r(t) = R + a · L(t) · sin(7·t + π/2 + delta_i)

    R        the strand's mid-radius
    a        amplitude — half the strand width, less the stroke
    L(t)     lobe depth as a function of angle; interpolates the seven levels
    delta_i  i · (2π/7) / n_curves — the phase sweep

`delta_i` sweeping **one lobe period** across the passes is what produces guilloché.
Threads converge at the lobe tips and fan between them. This is load-bearing:

- sweeping a **full 2π** turns the figure into a diamond mesh and destroys the profile
- replacing the sweep with **radial offsets** makes the threads parallel — they never
  cross, and the result reads as contour lines, not engraving

## 2. Channels

| Channel | Encodes | Source |
|---|---|---|
| a strand exists | one engagement | ledger |
| radial position | cumulative **engaged** time — gaps removed, overlaps counted once | ledger |
| strand width | duration of that engagement | ledger |
| **lobe angle** | **which responsibility dimension — seven permanent slots, identical registration on every strand** | `dimensions_exercised` |
| **lobe depth** | **level attained, 0–6** | `dimension_standing[].level` |
| thread density | corroboration tier — three discrete states, read as a contrast between bands and never as a count (044) | provenance class × corroboration |
| plain vs lobed | whether anything about the work is attested at all | provenance class |
| ~~identity core~~ | dropped — 035 §B6; `_core()` is retained but no longer emitted by `render()` | — |

**Deliberately not drawn:** slope, time-to-competence, complexity of work routed,
outcome trajectory, `work_kind`, `volume`, resource magnitude. All are measured and
stored; all belong in the record and the analytics layer where they can be labelled.

## 3. The seven dimensions

Fixed angular slots, 360/7 apart, dimension 1 at 0° running counter-clockwise:

1. **Discretion** — how much of the what-and-how the person decided versus received
2. **Direction of Others** — how many people's work they were answerable for
3. **Consequence Held** — what happens if they get it wrong, and who catches it
4. **Counterparty Exposure** — direct dealings with people outside their own team
5. **Method Authority** — who decides how the work is correctly done, and who signs off
6. **Resource & Financial Accountability** — resource committed, and answering for it
7. **Systems & Tooling Responsibility** — responsibility for the systems the work runs on

Registration is permanent, so tracing one direction outward reads that dimension across
a whole career. A dimension not exercised is a legitimate 0 and draws flat.

Levels are **ledger-derived, never attester-numeric**: the attester picks a behavioural
anchor and the ledger maps it to an integer. Per engagement the drawn level is the
**exit** level. Where attesters disagree, the drawn level is the highest level at least
two parties agree on; a lone attester's claim draws at their level but carries the
single-corroboration tier. Disagreeing attesters are never averaged — averaging invents
a level nobody asserted.

## 4. Provenance states

| State | Drawn as |
|---|---|
| `self_asserted` — from a résumé, nobody confirmed it | plain ring, **dotted** |
| `employment_verified` — dates and employer confirmed, nothing about the work | plain ring, **solid** |
| `peer_attested` | lobed, **low** weave |
| `party_attested` + `single` | lobed, **mid** weave |
| `party_attested` + `multi` | lobed, **full** weave |

A chapter with no attested dimensions has no lobes, because lobe depth *is* level. The
plainness carries meaning and must not be decorated — unverified work must never be
made to look substantive.

Superseded material is **removed**, not struck through. The ledger stays append-only and
retains it; the figure is a projection of current truth. Consequently ink can decrease on
retraction: geometry follows time, ink follows verification, in both directions.

## 5. Allocation

- **Fixed canvas.** `R_OUTER` never changes, so total figure size does not scale with
  career length. This is a hard constraint: footprint that grows with career length is an
  age proxy, and an age proxy on a hiring surface is a discrimination exposure.
- **Radius is cumulative engaged time**, not calendar time. Employment gaps therefore
  take no radial space and are invisible. This is a deliberate refusal — rendering
  career breaks, caregiving or illness into an identity artifact is the exact harm this
  product exists to attack — and it must not be "improved" later.
- **Width is duration as a share of the canvas**, linear.
- **Floor.** Below `BAND_FLOOR` the two *earliest* adjacent segments merge, never the
  recent ones, because recent chapters carry the decision-relevant signal.

The figure is **recomputed**, not accreted: adding a chapter re-renders the whole record.
It is deterministic and reproducible from the ledger, but not pixel-stable across years.
Frozen geometry, a fixed canvas and unbounded chapters are over-determined; this drops
frozen geometry.

## 6. Concurrency

The timeline is segmented at every start and end. A segment with *k* live engagements
divides its ring into *k* equal strands, each carrying its own lobe profile. Strands are
self-identifying by profile shape, so a reader can follow one outward without labels.

Below `STRAND_FLOOR` a strand is too narrow to thread, and corroboration renders as
**line weight** rather than thread count — so a thin concurrent strand never reads as
unverified merely because it is thin. This matters: gig and hourly workers are a target
population, and splitting the ring otherwise suppresses their corroboration channel.

## 7. Open — do not treat as settled

0. ~~The identity core versus the no-centre rule.~~ **CLOSED 2026-08-19
   (decision 035 §B6): the core is dropped.** Reviewer panels reached the same
   conclusion independently — a small concentric element at the centre of a lobed
   radial figure reads as a **bullseye with the worker inside it**, and two
   reviewers connected it directly to the ratings that already follow them at
   work. That reading does not improve for being inside the imprint rather than
   the mark. The empty state, which was the only argument for keeping it, is
   carried instead by the graticule ground clipped to the fixed canvas
   (`DESIGN.md` §9). `_core()` in `imprint.py` is retained but no longer emitted
   by any worker surface.
1. **No angular anchor.** Nothing marks which lobe is which dimension. Profiles are
   comparable as shapes but not readable as claims. This is a hole in the most valuable
   channel, not a polish item.
2. **Seven lobes is frozen geometry on an axis set that is explicitly a founder
   hypothesis**, due for recalibration after two verticals. Committing to seven angular
   slots is really a commitment to the dimension set. Proposed fix: reserve N permanent
   slots now, assign dimensions to slots and never reassign, so old strands stay valid
   when the set grows.
3. **`LOBE_FLOOR`** is 0.04, so a level of 0 draws a faint lobe rather than a true flat.
   A hard flat would strengthen the strongest signal in the encoding. Undecided.
4. **Never tested with humans at the size it will be used.** The one structured
   evaluation used vision models, which cannot resolve hairline thread pitch — so its
   negative findings about density are not citable, and neither is any claim that the
   channel works.
5. **The level anchors are unvalidated.** No framework publishes behavioural anchors at
   this granularity. Nobody has checked whether two managers scoring the same employee
   produce the same numbers. If inter-rater agreement is poor, lobe depth draws noise.
6. **Consequence Held may go unattested.** An employer signing "this person was the last
   check before an irreversible act" is creating a portable record of where liability
   sat. If legal refuses, the dimension set collapses back to a management ladder.
7. **Thread pitch is floored at two DEVICE pixels and nobody has checked that
   against an eye.** Decision 044 draws the figure as densely as the hardware
   carries: 9 / 17 / 27 threads at dpr 1 / 2 / 3 for one record at 320 px,
   verified through a CanvasKit harness. That is arithmetic. Two device pixels
   is the tightest pitch that can resolve *at all*, which is not the same as the
   tightest that resolves to a person holding a cheap phone at arm's length —
   item 4 above governs, and if the floor is too tight the correction is the
   constant, not the rule. It also means one record looks materially richer on a
   3x screen than a 1x one, which is only honest because density is a contrast
   and never a count.
8. ~~The vertex cost.~~ **CLOSED 2026-08-19 (044).** Threads are cubic Beziers
   fitted to `r(t)` with analytic tangents, segment count following arc length
   and floored at eight per lobe. Verified against the analytic curve at 180
   band/level/phase/density combinations: worst deviation **0.062 device
   pixels** against a 0.25 budget. A mature nine-chapter record at 320 px costs
   21 / 59 / 124 KB of path data at dpr 1 / 2 / 3 — below decision 040's
   364 KB worst-case baseline while carrying 34 threads instead of 9. What
   remains untested is behaviour under live zoom on a device, which is where
   040 found the faceting in the first place.
9. **Corroboration silently drops to two states on small surfaces.** Below a
   four-thread budget `TIER_FRACTION`'s low (0.18) and mid (0.5) both round to
   one thread. The channel degrades from three readable states to two and
   nothing on the surface says so. Named in 044; undecided.
10. **The outermost strand is systematically the least verified** — a current employer is
   the least likely to attest — while being the largest and most prominent element.

## 8. Prior art and IP

**SAP US 10712908 B2** (filed 2016, granted 2020, active to 2035) claims a "milestone
circle" whose portions are career stages, subdivided into ratings-category segments that
"begin at the center section and extend outward," described in the patent as acting as
"a type of fingerprint."

All three independent claims (1, 15, 18) require **"receiving ratings from the user"** and
**"receiving input activating a portion."** The ratings limb holds: levels come from
signed third-party attestations. The non-interactivity limb **no longer holds** —
decision 035's expanded imprint makes the figure interactive (a lobe can
be activated to reach the evidence beneath it), which is close to the claims' "input
activating a portion." The geometry remains the transpose — SAP's angle is career stage
and radius is rating; ours is radius = time, angle = dimension — and that argument and
the ratings-source argument stand independently. Counsel was briefed on the earlier
three-limb version and needs the correction (design/09 §7). Not legal advice: the live
question for counsel is whether the patent family contains broader claims, and whether
it is citable prior art against any future Grain application.

Aesthetic neighbours worth knowing: **Woolmark** (swept hairlines in a lobed rosette,
used as a certification mark — the sharpest precedent), **Mercury** (monochrome line-only
circular knot, in fintech), and **Apple Activity Rings** (concentric arcs as personal
data; registered and in active design-patent litigation — do not drift toward thick
uniform-width arcs with rounded caps).

## 9. Running it

    python3 examples.py

Pure standard library, no dependencies. `imprint.py` is the whole generator;
`examples/` holds the reference renders for each state, time structure and profile.

`render()` takes `size` and `dpr` because thread count is budgeted in rendered
pixels rather than viewbox units (decision 044). The SVG it emits carries
`vector-effect='non-scaling-stroke'` on every stroked element — the property is
not inherited, so a copy on the group would not reach the threads it governs.

**SVG is not the product's renderer and is not evidence about this figure.**
Decision 040 selected Skia and disqualified `react-native-svg` because it cannot
express hairline mode at all. Imprint questions are settled against a CanvasKit
harness; it is a scratch tool and is deliberately not committed here.
