"""Grain imprint — canonical generator.

The imprint is the per-person figure computed from the verified record. It is a
DIFFERENT OBJECT from the Grain mark (the logo), which is invariant and carries no
data. See imprint/README.md for the geometry system and the decisions behind it.

Pure standard library. No dependencies.

    from imprint import render, Engagement
    svg = render([Engagement(0, 24, "party_attested", [3,1,2,2,4,1,4], "multi"), ...])
"""
from __future__ import annotations
import math
from dataclasses import dataclass

TAU = 2.0 * math.pi

# ---------------------------------------------------------------- constants
INK = "#1B2A44"
PAPER = "#F5F6F3"
VIEWBOX = 600.0
CENTRE = VIEWBOX / 2.0

R_INNER = 58.0          # inner edge of the first band
R_OUTER = 280.0         # fixed canvas: total size never scales with career length
CORE_RADII = ((26.0, 1.3), (34.0, 0.8))

# Stroke and pitch are DEVICE PIXELS, never viewbox units (decision 044,
# DESIGN.md gap 10a). A viewbox-unit stroke is scaled by the render size, so
# at 296px a 0.7-unit thread painted 0.35 CSS px and antialiased to grey; a
# viewbox-unit PITCH_RATIO passed its own assertion while adjacent threads
# sat 0.82 CSS px apart. Both numbers below are what actually reaches glass.
STROKE_PX = 1.0         # hairline: one device pixel. Skia hairline mode; in
                        # SVG, vector-effect='non-scaling-stroke'
MIN_PITCH_PX = 2.0      # a thread and the paper beside it, in DEVICE pixels —
                        # the tightest pitch that can resolve as two threads at
                        # all. The figure is drawn as densely as the hardware
                        # can carry, so a 3x phone earns a richer imprint than a
                        # 1x screen of the same size. That is deliberate: density
                        # is read as a contrast between bands within one figure
                        # (044), never as a count, so it does not have to be
                        # equal across devices to be honest
BEZIER_PX = 24.0        # arc length per cubic segment. Threads are emitted as
                        # cubic Beziers fitted to r(t) with analytic tangents,
                        # which decision 040 estimated at ~10x fewer vertices
                        # than a polyline; error is fourth-order in segment
                        # length where a polyline's is second, so a segment this
                        # long still holds well under a tenth of a device pixel
MAX_ERR_PX = 0.25       # the deviation budget the fit is verified against
BEZIER_MIN_SEG = 8        # per lobe: the curve turns LOBES times per revolution
                        # and a fit cannot resolve a wave it never samples
DEGENERATE_PX = {"full": 2.0, "mid": 1.4, "low": 1.0}   # see _strand
BAND_FLOOR = 12.0       # minimum drawable band width, in viewbox units
STRAND_FLOOR = 7.0      # below this, corroboration renders as line weight, not thread count
LEVEL_MAX = 6.0
LOBES = 7               # one per responsibility dimension; see README
LOBE_FLOOR = 0.04       # OPEN: should a level of 0 draw truly flat? see README

# SVG's way of saying "this width is in device space, do not scale it with the
# viewbox". Not an inherited property, so it goes on every stroked element.
NON_SCALING = " vector-effect='non-scaling-stroke'"

# weave tier -> fraction of the maximum thread count the pitch rule allows
TIER_FRACTION = {"full": 1.00, "mid": 0.50, "low": 0.18}

DIMENSIONS = (
    "Discretion",
    "Direction of Others",
    "Consequence Held",
    "Counterparty Exposure",
    "Method Authority",
    "Resource & Financial Accountability",
    "Systems & Tooling Responsibility",
)


@dataclass(frozen=True)
class Engagement:
    """One job or engagement.

    start_month / end_month are months since the record's first engagement.
    provenance  : "self_asserted" | "employment_verified" | "peer_attested" | "party_attested"
    levels      : seven ints 0-6 in DIMENSIONS order, or None when nothing is attested
    corroboration: "multi" | "single" | None  (only meaningful for party_attested)
    """
    start_month: int
    end_month: int
    provenance: str
    levels: tuple | None = None
    corroboration: str | None = None

    @property
    def tier(self) -> str | None:
        if self.provenance == "party_attested":
            return "full" if self.corroboration == "multi" else "mid"
        if self.provenance == "peer_attested":
            return "low"
        return None

    @property
    def woven(self) -> bool:
        return self.levels is not None and self.provenance in ("party_attested", "peer_attested")


# ---------------------------------------------------------------- geometry
def segment(engagements):
    """Split the timeline at every start and end.

    Returns [(duration, [live engagements])]. Periods with nothing live contribute
    NOTHING — that is how employment gaps become invisible, which is deliberate.
    """
    if not engagements:
        return []
    edges = sorted({e.start_month for e in engagements} | {e.end_month for e in engagements})
    out = []
    for a, b in zip(edges, edges[1:]):
        live = [e for e in engagements if e.start_month <= a and e.end_month >= b]
        if live:
            out.append((b - a, live))
    return out


def allocate(segments):
    """Width of each segment as a share of the FIXED canvas, honouring BAND_FLOOR.

    Where the floor cannot be met, the two EARLIEST adjacent segments merge — never
    the recent ones, because recent chapters carry the decision-relevant signal.
    """
    segs = [(d, list(l)) for d, l in segments]
    available = R_OUTER - R_INNER
    while True:
        total = sum(d for d, _ in segs)
        widths = [available * d / total for d, _ in segs]
        if not segs or min(widths) >= BAND_FLOOR or len(segs) == 1:
            return segs, widths
        (d0, l0), (d1, l1) = segs[0], segs[1]
        merged_live = list(dict.fromkeys(l0 + l1))
        segs = [(d0 + d1, merged_live)] + segs[2:]


def profile(levels):
    """Interpolate the seven levels into a continuous lobe-depth function of angle."""
    n = len(levels)

    def L(t):
        u = (t % TAU) / (TAU / n)
        i = int(u)
        f = u - i
        a = levels[i % n] / LEVEL_MAX
        b = levels[(i + 1) % n] / LEVEL_MAX
        ease = 0.5 - 0.5 * math.cos(math.pi * f)
        return LOBE_FLOOR + (1.0 - LOBE_FLOOR) * (a + (b - a) * ease)

    def dL(t):
        """dL/dt. The Bezier fit needs a tangent, and a numeric one costs the
        accuracy the fit exists to buy."""
        u = (t % TAU) / (TAU / n)
        i = int(u)
        f = u - i
        a = levels[i % n] / LEVEL_MAX
        b = levels[(i + 1) % n] / LEVEL_MAX
        d_ease = 0.5 * math.pi * math.sin(math.pi * f)
        return (1.0 - LOBE_FLOOR) * (b - a) * d_ease * n / TAU

    L.d = dL
    return L


def _point(mid, amplitude, L, delta, t):
    """The thread's position and tangent at t, both analytic."""
    ph = LOBES * t + math.pi / 2.0 + delta
    sin_ph, cos_ph = math.sin(ph), math.cos(ph)
    lt = L(t)
    r = mid + amplitude * lt * sin_ph
    dr = amplitude * (L.d(t) * sin_ph + lt * LOBES * cos_ph)
    cos_t, sin_t = math.cos(t), math.sin(t)
    return (CENTRE + r * cos_t, CENTRE + r * sin_t,
            dr * cos_t - r * sin_t, dr * sin_t + r * cos_t)


def thread_path(mid, amplitude, L, delta, px_per_unit=None):
    """One thread, as cubic Beziers fitted to r(t). delta is the phase sweep.

    Decision 040 recorded the old fixed 760-point polyline faceting into visible
    polygons at 4x zoom, called re-tessellation a correctness fix rather than an
    optimisation, and estimated Bezier fitting at a further ~10x fewer vertices.
    This is both. Segment count follows arc length, floored so the fit always
    samples every lobe: the curve turns LOBES times per revolution and no fit
    recovers a wave it never saw.

    Tangents are analytic (`_point`), which is what buys the accuracy — a
    numeric tangent would spend it again. Verified against a dense polyline in
    `examples.py`; the deviation budget is MAX_ERR_PX.
    """
    ppu = px_per_unit if px_per_unit else 1.0
    arc = TAU * (mid + amplitude)
    n = max(LOBES * BEZIER_MIN_SEG, int(math.ceil(arc * ppu / BEZIER_PX)))
    h = TAU / n
    x0, y0, dx0, dy0 = _point(mid, amplitude, L, delta, 0.0)
    out = ["M%.2f %.2f" % (x0, y0)]
    for j in range(1, n + 1):
        t = h * j
        x1, y1, dx1, dy1 = _point(mid, amplitude, L, delta, t)
        # Hermite -> Bezier: the interior controls sit a third of the step along
        # each endpoint's tangent.
        out.append("C%.2f %.2f %.2f %.2f %.2f %.2f" % (
            x0 + dx0 * h / 3.0, y0 + dy0 * h / 3.0,
            x1 - dx1 * h / 3.0, y1 - dy1 * h / 3.0, x1, y1))
        x0, y0, dx0, dy0 = x1, y1, dx1, dy1
    return "".join(out) + "Z"


def thread_count(amplitude, L, tier, css_per_unit, dpr):
    """Threads the band can hold, budgeted in rendered pixels not viewbox units.

    Pitch never falls below MIN_PITCH_PX device pixels, and the count is
    otherwise as high as the band can carry: the figure is drawn as richly as
    the hardware allows, at whatever size it is drawn.

    Density is read as a CONTRAST between bands within one figure, never as a
    countable quantity (decision 044), so the tier fractions are preserved as
    ratios of whatever budget the device allows, and two devices legitimately
    draw the same record at different richness.

    Known and deliberate: below a four-thread budget `low` (0.18) and `mid`
    (0.5) both round to one, and corroboration falls from three readable
    states to two. Recorded in 044; nothing here announces it.
    """
    mean = sum(L(TAU * q / 40) for q in range(40)) / 40.0
    spread = 2.0 * max(amplitude, 0.1) * mean * math.sin(math.pi / LOBES)
    cap = spread * css_per_unit * dpr / MIN_PITCH_PX
    return max(1, int(round(max(1, int(cap)) * TIER_FRACTION[tier])))


# ---------------------------------------------------------------- rendering
def _core():
    return "".join(
        "<circle cx='%.1f' cy='%.1f' r='%.1f' fill='none' stroke='%s' stroke-width='%.2f'/>"
        % (CENTRE, CENTRE, r, INK, w)
        for r, w in CORE_RADII
    )


def _strand(r_in, r_out, eng, css_per_unit, dpr):
    """One engagement inside one segment.

    `css_per_unit` is CSS pixels per viewbox unit; every stroke width below is
    a device-pixel value carried by NON_SCALING, and the geometric inset it
    implies is converted back into viewbox units here.
    """
    width = r_out - r_in
    mid = (r_in + r_out) / 2.0
    stroke_units = STROKE_PX / (css_per_unit * dpr)
    if not eng.woven:
        # nothing attested about the work: a plain ring. Dotted when self-asserted.
        dash = " stroke-dasharray='3.5 5'" if eng.provenance == "self_asserted" else ""
        return ("<circle cx='%.1f' cy='%.1f' r='%.1f' fill='none' stroke='%s' "
                "stroke-width='%.2f'%s%s/>"
                % (CENTRE, CENTRE, mid, INK, DEGENERATE_PX["mid"], NON_SCALING, dash))
    L = profile(eng.levels)
    amplitude = width / 2.0 - stroke_units
    if width < STRAND_FLOOR:
        # degenerate case: too narrow to thread. Corroboration becomes line weight
        # so a thin strand never reads as unverified merely because it is thin.
        # The thinnest weight is one device pixel: below that the tiers stop
        # differing at all, which is the same failure thread pitch had.
        w = DEGENERATE_PX[eng.tier]
        return "<path d='%s' fill='none' stroke='%s' stroke-width='%.2f'%s/>" % (
            thread_path(mid, max(amplitude, 0.8), L, 0.0,
                        px_per_unit=css_per_unit * dpr), INK, w, NON_SCALING)
    n = thread_count(amplitude, L, eng.tier, css_per_unit, dpr)
    # NON_SCALING on every path: vector-effect is not an inherited property, so
    # the group's copy does not reach the threads it is meant to govern.
    ppu = css_per_unit * dpr
    return "".join(
        "<path d='%s'%s/>" % (thread_path(mid, amplitude, L, i * (TAU / LOBES) / n,
                                          px_per_unit=ppu), NON_SCALING)
        for i in range(n)
    )


def render(engagements, size=512, background=True, dpr=1.0):
    """Return a complete SVG for one record, drawn for `size` CSS px at `dpr`.

    Thread counts come from the pitch budget at that size (decision 044). The
    count is a function of SIZE, not of the screen: `dpr` only guarantees the
    paper between two threads survives rasterisation. `_core()` is retained but
    never emitted: decision 035 SB6 dropped the identity core.
    """
    css_per_unit = size / VIEWBOX
    segs, widths = allocate(segment(engagements))
    parts = []
    r = R_INNER
    for (_, live), width in zip(segs, widths):
        share = width / len(live)
        for j, eng in enumerate(live):
            parts.append(_strand(r + j * share, r + (j + 1) * share, eng, css_per_unit, dpr))
        r += width
    body = "<g fill='none' stroke='%s' stroke-width='%.2f'%s>%s</g>" % (
        INK, STROKE_PX, NON_SCALING, "".join(parts))
    bg = "<rect width='%d' height='%d' fill='%s'/>" % (VIEWBOX, VIEWBOX, PAPER) if background else ""
    return ("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 %d %d' width='%d' height='%d'>"
            "%s%s</svg>" % (VIEWBOX, VIEWBOX, size, size, bg, body))
