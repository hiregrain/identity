import os, sys, math, json
REPO = "/Users/kylechoy/Desktop/Programming Projects/Personal/identity"
sys.path.insert(0, os.path.join(REPO, "imprint"))
import imprint
from imprint import Engagement as E
sys.path.insert(0, os.path.join(REPO, "mark"))
import mark
TAU, LOBES = imprint.TAU, imprint.LOBES
OUT = sys.argv[1]

# The identity core (035 §B6) and the stroke unit (gap 10a) are both settled in
# the generator now — decision 044 — so the monkey patches that used to carry
# them here are gone. `render()` no longer emits `_core()`, and stroke widths are
# device pixels carried by vector-effect rather than viewbox units.
#
# RENDER SIZE. Thread count is budgeted from the size the figure is DRAWN at, so
# a fragment is only correct for the surface it was budgeted for. These artboards
# set every imprint to width:100% inside a 360px frame, which lands near 296px —
# so that is what is budgeted here, and `Expanded` at full bleed is consequently
# drawn thinner than it has room for. One fragment cannot serve both; splitting
# them is a canvas change and has not been made.
FIGURE_PX = 300.0                      # measured, not assumed: the record screen
                                       # renders the figure at 300 CSS px inside
                                       # its 40px index gutter; Expanded 298,
                                       # Public 290. One fragment covers the range
DPR = 2.0                              # these artboards preview the 2x phone the
                                       # target population holds. A canvas opened
                                       # on a 1x display shows the figure denser
                                       # than that display would draw it
PPU = FIGURE_PX / imprint.VIEWBOX      # CSS pixels per viewbox unit at that size

# The 380-sample override that used to live here is gone: `thread_path` now
# tessellates by arc length at a 1.5-device-pixel chord target (044, closing
# 040's faceting item), which is both smoother and cheaper than a fixed count.

SUNRISE=(3,3,3,1,3,2,2); PLATFORM=(2,0,2,4,1,1,2); METRO=(4,3,4,3,3,3,4); CEBU=(4,4,4,3,4,3,4)
CUR_PLAIN = E(88,107,"employment_verified")
CUR_WOVEN = E(88,107,"party_attested",CEBU,"multi")
WORKING = [E(0,18,"self_asserted"), E(18,48,"party_attested",SUNRISE,"multi"),
           E(36,66,"peer_attested",PLATFORM,None), E(66,88,"party_attested",METRO,"single"),
           CUR_PLAIN]
IMPORTED = [E(0,18,"self_asserted"),E(18,48,"self_asserted"),E(36,66,"self_asserted"),
            E(66,88,"self_asserted"),E(88,107,"self_asserted")]

def frag(rec):
    s = imprint.render(rec, size=FIGURE_PX, background=False, dpr=DPR)
    return s.split(">",1)[1].rsplit("</svg>",1)[0]
for name, rec in {"working":WORKING, "imported":IMPORTED, "empty":[]}.items():
    open(os.path.join(OUT, name+".svgfrag"), "w").write(frag(rec))

segs, widths = imprint.allocate(imprint.segment(WORKING))
per = {i: [] for i in range(5)}; hit = []; base = []; r_cur = None
r = imprint.R_INNER
for (dur, live), width in zip(segs, widths):
    share = width/len(live)
    for j, eng in enumerate(live):
        a, b = r + j*share, r + (j+1)*share
        i = WORKING.index(eng)
        per[i].append(imprint._strand(a, b, eng, PPU, DPR))
        hit.append({"ch": i, "r0": round(a,2), "r1": round(b,2)})
        if eng is CUR_PLAIN: r_cur = (a, b)
        else: base.append(imprint._strand(a, b, eng, PPU, DPR))
    r += width
json.dump(hit, open(os.path.join(OUT,"hit.json"), "w"))

# The expanded view's lobe highlight — one path per chapter and measure, so the
# figure can light the lobe a reader is reading about. No spokes, no sector
# lines, no notches: they read as damage across the drawing. It used to be
# computed in the artboard's own JavaScript, which meant a second copy of
# profile() and a hardcoded stroke inset that no longer matched the generator,
# so the highlight sat off the band it was highlighting.
S = 0.86                               # the figure's scale inside Expanded's stage
def _P(rad, ang):
    return (300 + rad*S*math.cos(ang), 300 + rad*S*math.sin(ang))

lobes = []
for i, eng in enumerate(WORKING):
    span = next(h for h in hit if h["ch"] == i)
    r0, r1 = span["r0"], span["r1"]
    mid = (r0 + r1) / 2.0
    amp = (r1 - r0) / 2.0 - imprint.STROKE_PX / (PPU * DPR)
    row = []
    for dim in range(LOBES):
        if eng.levels is None:
            row.append("")
            continue
        L = imprint.profile(eng.levels)
        t0 = dim * (TAU / LOBES)
        pts = []
        for j in range(49):
            t = t0 - math.pi/LOBES + (TAU/LOBES) * (j/48.0)
            x, y = _P(mid + amp * L(t) * math.sin(LOBES*t + math.pi/2.0), t)
            pts.append("%.1f %.1f" % (x, y))
        row.append("M" + " L".join(pts))
    lobes.append(row)
json.dump(lobes, open(os.path.join(OUT,"lobes.json"), "w"))

chs = "".join("<g class='ch ch%d'>%s</g>" % (i,
        "".join(per[i]).replace("<path d=","<path pathLength='1' d=").replace("<circle ","<circle pathLength='1' "))
      for i in range(5))
open(os.path.join(OUT,"chapters.svgfrag"),"w").write(chs)

G = "<g fill='none' stroke='#1B2A44' stroke-width='1.00'>%s</g>"
open(os.path.join(OUT,"ceremony-base.svgfrag"),"w").write(G % "".join(base))
open(os.path.join(OUT,"ceremony-before.svgfrag"),"w").write(G % imprint._strand(r_cur[0], r_cur[1], CUR_PLAIN, PPU, DPR))
after = imprint._strand(r_cur[0], r_cur[1], CUR_WOVEN, PPU, DPR).replace("<path d=","<path pathLength='1' d=")
open(os.path.join(OUT,"ceremony-after.svgfrag"),"w").write(G % after)

# gutter swatches — the same construction unrolled over one lobe period, at a
# larger box and lower counts so 3-vs-5 is countable at 1x (design/07 §3).
W, MID = 34.0, 8.0
def unrolled(n, amp=5.6):
    out = []
    for i in range(n):
        d = i*(TAU/LOBES)/n
        pts = ["%.1f %.1f" % (W*j/72.0, MID + amp*math.sin(TAU*(j/72.0) + math.pi/2.0 + d)) for j in range(73)]
        out.append("<path d='M" + " L".join(pts) + "'/>")
    return "".join(out)
def flat(dash=False):
    return "<path d='M0 %.1f L%.1f %.1f'%s/>" % (MID, W, MID, " stroke-dasharray='3 4'" if dash else "")
for k, v in {"self_asserted": flat(True), "employment_verified": flat(),
             "peer_attested": unrolled(2), "party_single": unrolled(3), "party_multi": unrolled(5)}.items():
    open(os.path.join(OUT,"sw-"+k+".svgfrag"),"w").write(v)
# The mark, at the sizes the screens actually set. `README.md` said gen.py ran
# mark.py and it never did: the four mark fragments had no generator at all, so
# the committed artboards could not be rebuilt from source. They can now.
# tier_for() picks the drawn reduction; DESIGN.md section 3 records the breakpoints.
# NOTE: mark.contour() samples at a fixed 560 points regardless of size, so a
# 28px glyph carries 560 vertices per band. That is the defect imprint.py just
# had, in the other file; it is not fixed here because mark.py is out of this
# change's scope, and it costs ~16KB on every screen carrying the lockup.
for name, px in (("mark-28", 28), ("mark-56", 56), ("mark-solid", 20)):
    open(os.path.join(OUT, name + ".svgfrag"), "w").write(mark.tier_for(px)(px))
open(os.path.join(OUT,"pointer.svgfrag"),"w").write(mark.pointer(28))
# The lockup — mark plus the GRAIN wordmark (§4a). tier_for() inside lockup()
# swaps the mark to its correct drawn reduction, so this is never a scaled master.
LOCKUP_MARK_PX = 26
open(os.path.join(OUT,"lockup.svgfrag"),"w").write(mark.lockup(LOCKUP_MARK_PX))

print("after-paths(multi tier)=%d" % after.count("<path"))
for h in hit: print(h)
