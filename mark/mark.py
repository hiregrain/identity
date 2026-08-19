"""Grain mark — the logo, its size tiers, and the record pointer.

Three objects, one construction. Do not confuse them:

  THE MARK      Grain's logo. Invariant, carries no data. Three threaded bands.
  THE TIERS     Purpose-drawn reductions of the mark for small sizes. NOT scaled
                copies — scaling the master is what fails below ~40px.
  THE POINTER   The glyph that says "this person has a record you can inspect".
                It is NOT a verification badge and must never behave like one.

Everything derives from LOBES and BANDS. LOBES is provisional (see README §2).
Pure standard library. No dependencies.
"""
from __future__ import annotations
import math

TAU = 2.0 * math.pi
INK = "#1B2A44"
PAPER = "#F5F6F3"
VIEWBOX = 600.0
CENTRE = VIEWBOX / 2.0

LOBES = 7                       # provisional — the whole system is parameterised on this
BANDS = (                       # (mid radius, amplitude, sweep direction)
    (90.0, 22.0, +1),
    (172.0, 40.0, -1),
    (264.0, 30.0, +1),
)
PITCH_RATIO = 2.2               # thread pitch must exceed stroke by this factor or they fuse

# The deliberate irregularity. One lobe deepened, at a fixed angle, so the mark has a
# describable feature to police and an unambiguous top. Set BREAK_AMOUNT to 0 to disable.
BREAK_ANGLE = TAU * 1.0 / LOBES
BREAK_AMOUNT = 0.42
BREAK_WIDTH = 0.30


def _amplitude_at(t: float, amp: float, broken: bool) -> float:
    if not broken or BREAK_AMOUNT == 0:
        return amp
    d = (t - BREAK_ANGLE + math.pi) % TAU - math.pi
    return amp * (1.0 + BREAK_AMOUNT * math.exp(-(d * d) / (2 * BREAK_WIDTH ** 2)))


def contour(R, amp, phase=0.0, broken=False, samples=560, t0=0.0, t1=TAU):
    pts = []
    for j in range(samples + 1):
        t = t0 + (t1 - t0) * j / samples
        r = R + _amplitude_at(t, amp, broken) * math.sin(LOBES * t + phase)
        pts.append("%.2f %.2f" % (CENTRE + r * math.cos(t), CENTRE + r * math.sin(t)))
    closed = " Z" if abs(t1 - t0 - TAU) < 1e-9 else ""
    return "M" + " L".join(pts) + closed


def threads(R, amp, direction, weight, broken=False, pitch=PITCH_RATIO):
    n = max(2, int(2.0 * amp * math.sin(math.pi / LOBES) / (pitch * weight)))
    return "".join(
        "<path d='%s'/>" % contour(R, amp, direction * i * (TAU / LOBES) / n, broken)
        for i in range(n)
    )


def stroke_for(px, base=1.0):
    """Hairline that stays ~1 device pixel, floored so it never disappears."""
    return max(VIEWBOX / px * base, 1.1)


# ------------------------------------------------------------------ size tiers
def tier_full(px, broken=True):
    """>= 80px. Three threaded bands. This is the mark."""
    w = stroke_for(px)
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (
        INK, w, "".join(threads(R, a, d, w, broken) for R, a, d in BANDS))


def tier_two(px, broken=True):
    """40-79px. Outer and inner band; the middle band clogs first, so it goes first."""
    w = stroke_for(px, 1.15)
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (
        INK, w,
        threads(BANDS[2][0], BANDS[2][1], +1, w, broken, pitch=3.0)
        + threads(BANDS[0][0], BANDS[0][1], +1, w, broken, pitch=3.0))


def tier_line(px, broken=True):
    """24-39px. One contour per band, weave dropped."""
    w = stroke_for(px, 1.5)
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (
        INK, w,
        "".join("<path d='%s'/>" % contour(R, a * 0.85, 0.0, broken)
                for R, a, _ in reversed(BANDS)))


def tier_solid(px, broken=True):
    """<= 23px. Mass, not line — below this size line art has nothing to hold."""
    return "<path d='%s %s' fill='%s' fill-rule='evenodd'/>" % (
        contour(BANDS[2][0], BANDS[2][1] * 0.9, 0.0, broken),
        contour(BANDS[0][0] + 6, BANDS[0][1] * 0.9, 0.0, broken), INK)


def tier_for(px):
    if px >= 80: return tier_full
    if px >= 40: return tier_two
    if px >= 24: return tier_line
    return tier_solid


# ------------------------------------------------------------------ the pointer
def pointer(px, weight=None):
    """"This person has a record you can inspect." A citation glyph, not a badge.

    RULES, and they are not stylistic:
      - never a filled disc, never a checkmark, never inside a shield or a ring
      - never rendered larger than the adjacent name's cap height
      - on THIRD-PARTY surfaces it must be accompanied by a count
        ("4 chapters, 3 corroborated"). A bare glyph beside a name reads as
        endorsement whatever its shape, and endorsement is what the thesis forbids.
    """
    w = weight if weight is not None else stroke_for(px, 0.85)
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s%s</g>" % (
        INK, w,
        "<path d='%s'/>" % contour(240.0, 40.0, 0.0),
        "<path d='%s'/>" % contour(106.0, 38.0, math.pi / LOBES))


# ------------------------------------------------------------------ output
def squircle(size, n=5.0, steps=160):
    """The iOS superellipse mask."""
    a = size / 2.0
    pts = []
    for i in range(steps + 1):
        t = TAU * i / steps
        ct, st = math.cos(t), math.sin(t)
        pts.append("%.2f %.2f" % (
            a + a * (1 if ct >= 0 else -1) * abs(ct) ** (2.0 / n),
            a + a * (1 if st >= 0 else -1) * abs(st) ** (2.0 / n)))
    return "M" + " L".join(pts) + " Z"


def svg(body, size, background=True):
    bg = "<rect width='%d' height='%d' fill='%s'/>" % (VIEWBOX, VIEWBOX, PAPER) if background else ""
    return ("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 %d %d' width='%d' height='%d'>"
            "%s%s</svg>") % (VIEWBOX, VIEWBOX, size, size, bg, body)


def app_icon(px, dark=False, inset=0.74, uid="mask"):
    """Icon in the iOS mask. Dark is the stronger of the two for this mark."""
    bg, fg = (INK, PAPER) if dark else (PAPER, INK)
    body = tier_for(px * inset)(px * inset)
    if dark:
        body = body.replace(INK, PAPER)
    m = px * inset
    off = (px - m) / 2.0
    return ("<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d' viewBox='0 0 %d %d'>"
            "<defs><clipPath id='%s'><path d='%s'/></clipPath></defs>"
            "<g clip-path='url(#%s)'><rect width='%d' height='%d' fill='%s'/>"
            "<svg x='%.2f' y='%.2f' width='%.2f' height='%.2f' viewBox='0 0 600 600'>%s</svg>"
            "</g></svg>") % (px, px, px, px, uid, squircle(px), uid, px, px, bg, off, off, m, m, body)
