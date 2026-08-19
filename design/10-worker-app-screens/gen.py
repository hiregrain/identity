import os, sys, math, json
REPO = "/Users/kylechoy/Desktop/Programming Projects/Personal/identity"
sys.path.insert(0, os.path.join(REPO, "imprint"))
import imprint
from imprint import Engagement as E
TAU, LOBES, C = imprint.TAU, imprint.LOBES, imprint.CENTRE
OUT = sys.argv[1]

# DESIGN.md gap 11 (029 §B6): the identity core is dropped.
imprint._core = lambda: ""
# DESIGN.md gap 10a, interim: base thread 0.70 -> 1.0 viewbox units. At 0.70 and
# 0.49 scale the threads compute to 0.32-0.37 CSS px, which paints at ~1.9:1 at
# dpr 1. Raising the stroke lowers the thread cap through the pitch rule, which
# IS the tier reduction §3 requires — a drawn reduction, not a scaled master.
imprint.STROKE = 1.0
_strand_orig = imprint._strand
def _strand(r_in, r_out, eng):
    out = _strand_orig(r_in, r_out, eng)
    return out.replace("stroke-width='1.20'", "stroke-width='1.60'")
imprint._strand = _strand

def thread_path(mid, amplitude, L, delta, samples=380):
    pts = []
    for j in range(samples + 1):
        t = TAU * j / samples
        r = mid + amplitude * L(t) * math.sin(LOBES*t + math.pi/2.0 + delta)
        pts.append("%.1f %.1f" % (C + r*math.cos(t), C + r*math.sin(t)))
    return "M" + " L".join(pts) + " Z"
imprint.thread_path = thread_path

SUNRISE=(3,3,3,1,3,2,2); PLATFORM=(2,0,2,4,1,1,2); METRO=(4,3,4,3,3,3,4); CEBU=(4,4,4,3,4,3,4)
CUR_PLAIN = E(88,107,"employment_verified")
CUR_WOVEN = E(88,107,"party_attested",CEBU,"multi")
WORKING = [E(0,18,"self_asserted"), E(18,48,"party_attested",SUNRISE,"multi"),
           E(36,66,"peer_attested",PLATFORM,None), E(66,88,"party_attested",METRO,"single"),
           CUR_PLAIN]
IMPORTED = [E(0,18,"self_asserted"),E(18,48,"self_asserted"),E(36,66,"self_asserted"),
            E(66,88,"self_asserted"),E(88,107,"self_asserted")]

def frag(rec):
    s = imprint.render(rec, size=600, background=False)
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
        per[i].append(imprint._strand(a, b, eng))
        hit.append({"ch": i, "r0": round(a,2), "r1": round(b,2)})
        if eng is CUR_PLAIN: r_cur = (a, b)
        else: base.append(imprint._strand(a, b, eng))
    r += width
json.dump(hit, open(os.path.join(OUT,"hit.json"), "w"))

chs = "".join("<g class='ch ch%d'>%s</g>" % (i,
        "".join(per[i]).replace("<path d=","<path pathLength='1' d=").replace("<circle ","<circle pathLength='1' "))
      for i in range(5))
open(os.path.join(OUT,"chapters.svgfrag"),"w").write(chs)

G = "<g fill='none' stroke='#1B2A44' stroke-width='1.00'>%s</g>"
open(os.path.join(OUT,"ceremony-base.svgfrag"),"w").write(G % "".join(base))
open(os.path.join(OUT,"ceremony-before.svgfrag"),"w").write(G % imprint._strand(r_cur[0], r_cur[1], CUR_PLAIN))
after = imprint._strand(r_cur[0], r_cur[1], CUR_WOVEN).replace("<path d=","<path pathLength='1' d=")
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
print("after-paths(multi tier)=%d" % after.count("<path"))
for h in hit: print(h)
