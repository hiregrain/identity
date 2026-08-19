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
SWEEP_PERIODS = 2               # how many lobe periods delta sweeps. The family's radial
                                # spread is 2*a*sin(m*pi/k): at m=1 that is only 0.87a, which
                                # is why the weave looked thin. m=2 gives 1.56a — nearly twice
                                # the thread count — and the lobed silhouette still survives.
                                # A full 2*pi sweep gives the densest weave and destroys the
                                # lobes completely; it is a circle. Do not go there.

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
    """Threads at a pitch that actually separates them. Returns None if it cannot:
    the caller falls back to a single contour rather than drawing mush."""
    span = SWEEP_PERIODS * TAU / LOBES
    spread = 2.0 * amp * math.sin(min(SWEEP_PERIODS * math.pi / LOBES, math.pi / 2))
    n = int(spread / (pitch * weight))
    if n < 3:
        return None
    return "".join(
        "<path d='%s'/>" % contour(R, amp, direction * i * span / n, broken)
        for i in range(n)
    )


def stroke_for(px, base=1.0):
    """Hairline that stays ~1 device pixel, floored so it never disappears."""
    return max(VIEWBOX / px * base, 1.1)


# ------------------------------------------------------------------ size tiers
# Reduce the WEAVE before the BANDS. Three concentric bands are the mark's
# identity; the threading is only its finish. Dropping a band to buy a size is
# what makes the mark unrecognisable, and it was the wrong order.

WEAVE_MIN_PX = 96    # below this the pitch rule cannot separate threads on every
                     # band — computed, not chosen; see README section 3
SOLID_MAX_PX = 23    # below this line art has nothing to hold


def tier_full(px, broken=True):
    """>= WEAVE_MIN_PX. Three threaded bands, per-band fallback if pitch fails."""
    w = stroke_for(px)
    parts = []
    for R, a, d in BANDS:
        t = threads(R, a, d, w, broken)
        parts.append(t if t is not None else "<path d='%s'/>" % contour(R, a, 0.0, broken))
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (INK, w, "".join(parts))


def tier_contour(px, broken=True):
    """24-149px. Three bands, one contour each, no weave. Band count holds."""
    w = stroke_for(px, 1.25)
    return "<g fill='none' stroke='%s' stroke-width='%.2f'>%s</g>" % (
        INK, w,
        "".join("<path d='%s'/>" % contour(R, a, 0.0, broken) for R, a, _ in reversed(BANDS)))


def tier_solid(px, broken=True):
    """<= 23px. Mass, not line."""
    return "<path d='%s %s' fill='%s' fill-rule='evenodd'/>" % (
        contour(BANDS[2][0], BANDS[2][1] * 0.9, 0.0, broken),
        contour(BANDS[0][0] + 6, BANDS[0][1] * 0.9, 0.0, broken), INK)


def tier_for(px):
    if px >= WEAVE_MIN_PX: return tier_full
    if px > SOLID_MAX_PX: return tier_contour
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


# ------------------------------------------------------------------ the lockup
# Measured, not assumed. Re-measure if the typeface or the mark changes.
CAP_RATIO = 0.690        # Archivo cap height / font-size, at weight 600 stretch 125%
MARK_OPTICAL_CENTRE = 0.4875   # the mark's ink-bbox centre as a fraction of its height
MARK_RATIO = 1.4         # mark height / cap height
GAP_RATIO = 0.75        # gap / cap height — 1.3 read as a gulf; 0.6 crowds
CLEAR_SPACE = 1.0        # clear space on every side, in cap heights
MIN_LOCKUP_MARK = 30     # below this the mark goes alone: the solid tier is a dense
                         # mass and reads wrong beside outline-weight type

WORDMARK = dict(text="GRAIN", weight=600, stretch=125, tracking=0.09)


def lockup(mark_px, dark=False, font_family="Archivo"):
    """The horizontal lockup. Returns SVG fragment; caller supplies the viewBox.

    The mark uses tier_for(), so it swaps to the correct reduction as it shrinks —
    never a scaled master. Below MIN_LOCKUP_MARK, use the mark alone instead.
    """
    cap = mark_px / MARK_RATIO
    fs = cap / CAP_RATIO
    gap = cap * GAP_RATIO
    centre_y = mark_px * MARK_OPTICAL_CENTRE
    baseline = centre_y + cap / 2.0
    fg = PAPER if dark else INK
    body = tier_for(mark_px)(mark_px)
    if dark:
        body = body.replace(INK, PAPER)
    return ("<svg x='0' y='0' width='%.2f' height='%.2f' viewBox='0 0 600 600'>%s</svg>"
            "<text x='%.2f' y='%.2f' font-family='%s' font-size='%.2f' font-weight='%d' "
            "font-stretch='%d%%' letter-spacing='%.2f' fill='%s'>%s</text>"
            ) % (mark_px, mark_px, body,
                 mark_px + gap, baseline, font_family, fs,
                 WORDMARK["weight"], WORDMARK["stretch"], fs * WORDMARK["tracking"],
                 fg, WORDMARK["text"])


def wordmark_svg(cap_px, font_css="", pad=None):
    """The wordmark alone. cap_px is cap height; padding is one cap height."""
    fs = cap_px / CAP_RATIO
    pad = cap_px if pad is None else pad
    w = fs * 4.45 + pad * 2
    h = cap_px + pad * 2
    return ("<svg xmlns='http://www.w3.org/2000/svg' width='%.0f' height='%.0f' viewBox='0 0 %.0f %.0f'>"
            "<defs><style>%s</style></defs>"
            "<text x='%.2f' y='%.2f' font-family='Archivo' font-size='%.2f' font-weight='%d' "
            "font-stretch='%d%%' letter-spacing='%.2f' fill='%s'>%s</text></svg>"
            ) % (w, h, w, h, font_css, pad, pad + cap_px, fs,
                 WORDMARK["weight"], WORDMARK["stretch"], fs * WORDMARK["tracking"],
                 INK, WORDMARK["text"])


def lockup_svg(mark_px, dark=False, font_css="", pad=None, background=True):
    """A complete standalone lockup SVG. font_css should carry an @font-face for
    Archivo; without it the file renders in a fallback face."""
    cap = mark_px / MARK_RATIO
    fs = cap / CAP_RATIO
    gap = cap * GAP_RATIO
    pad = cap * CLEAR_SPACE if pad is None else pad
    w = mark_px + gap + fs * 4.45 + pad * 2      # calibrated: "GRAIN" advances 4.414em at +9% tracking
    h = mark_px + pad * 2
    rect = ""
    if background:
        rect = "<rect width='%.0f' height='%.0f' fill='%s'/>" % (w, h, INK if dark else PAPER)
    return ("<svg xmlns='http://www.w3.org/2000/svg' width='%.0f' height='%.0f' viewBox='0 0 %.0f %.0f'>"
            "<defs><style>%s</style></defs>%s"
            "<g transform='translate(%.2f,%.2f)'>%s</g></svg>"
            ) % (w, h, w, h, font_css, rect, pad, pad, lockup(mark_px, dark))
