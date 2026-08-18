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

STROKE = 0.7            # hairline
PITCH_RATIO = 2.2       # thread pitch must exceed STROKE by this factor
BAND_FLOOR = 12.0       # minimum drawable band width, in viewbox units
STRAND_FLOOR = 7.0      # below this, corroboration renders as line weight, not thread count
LEVEL_MAX = 6.0
LOBES = 7               # one per responsibility dimension; see README
LOBE_FLOOR = 0.04       # OPEN: should a level of 0 draw truly flat? see README

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

    return L


def thread_path(mid, amplitude, L, delta, samples=760):
    """One thread. delta is the phase sweep — this is what makes it guilloche."""
    pts = []
    for j in range(samples + 1):
        t = TAU * j / samples
        r = mid + amplitude * L(t) * math.sin(LOBES * t + math.pi / 2.0 + delta)
        pts.append("%.2f %.2f" % (CENTRE + r * math.cos(t), CENTRE + r * math.sin(t)))
    return "M" + " L".join(pts) + " Z"


def thread_count(amplitude, L, tier):
    """Pitch must clear the stroke, so the band's amplitude caps the thread count."""
    mean = sum(L(TAU * q / 40) for q in range(40)) / 40.0
    spread = 2.0 * max(amplitude, 0.1) * mean * math.sin(math.pi / LOBES)
    cap = max(1, int(spread / (PITCH_RATIO * STROKE)))
    return max(1, int(round(cap * TIER_FRACTION[tier])))


# ---------------------------------------------------------------- rendering
def _core():
    return "".join(
        "<circle cx='%.1f' cy='%.1f' r='%.1f' fill='none' stroke='%s' stroke-width='%.2f'/>"
        % (CENTRE, CENTRE, r, INK, w)
        for r, w in CORE_RADII
    )


def _strand(r_in, r_out, eng):
    """One engagement inside one segment."""
    width = r_out - r_in
    mid = (r_in + r_out) / 2.0
    if not eng.woven:
        # nothing attested about the work: a plain ring. Dotted when self-asserted.
        dash = " stroke-dasharray='3.5 5'" if eng.provenance == "self_asserted" else ""
        return ("<circle cx='%.1f' cy='%.1f' r='%.1f' fill='none' stroke='%s' "
                "stroke-width='%.2f'%s/>" % (CENTRE, CENTRE, mid, INK, 1.2, dash))
    L = profile(eng.levels)
    amplitude = width / 2.0 - STROKE
    if width < STRAND_FLOOR:
        # degenerate case: too narrow to thread. Corroboration becomes line weight
        # so a thin strand never reads as unverified merely because it is thin.
        w = {"full": 1.6, "mid": 1.1, "low": 0.8}[eng.tier]
        return "<path d='%s' fill='none' stroke='%s' stroke-width='%.2f'/>" % (
            thread_path(mid, max(amplitude, 0.8), L, 0.0), INK, w)
    n = thread_count(amplitude, L, eng.tier)
    return "".join(
        "<path d='%s'/>" % thread_path(mid, amplitude, L, i * (TAU / LOBES) / n)
        for i in range(n)
    )


def render(engagements, size=512, background=True):
    """Return a complete SVG for one record."""
    segs, widths = allocate(segment(engagements))
    parts = []
    r = R_INNER
    for (_, live), width in zip(segs, widths):
        share = width / len(live)
        for j, eng in enumerate(live):
            parts.append(_strand(r + j * share, r + (j + 1) * share, eng))
        r += width
    body = "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (INK, STROKE, "".join(parts))
    bg = "<rect width='%d' height='%d' fill='%s'/>" % (VIEWBOX, VIEWBOX, PAPER) if background else ""
    return ("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 %d %d' width='%d' height='%d'>"
            "%s%s%s</svg>" % (VIEWBOX, VIEWBOX, size, size, bg, body, _core()))
