import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
def rd(n): return open(os.path.join(HERE, n)).read()

# graticule, the chart ground (DESIGN.md §9), how "global" becomes structural
def graticule(w, h, step=12):
    p = []
    for y in range(step, int(h), step):
        p.append("<path d='M0 %d L%d %d'/>" % (y, w, y))
    for x in range(step, int(w), step):
        k = (x - w/2.0) / (w/2.0)                     # meridians bow like a projection
        p.append("<path d='M%.1f 0 Q%.1f %.1f %.1f %d'/>" % (x, x + k*7, h/2.0, x, h))
    return "".join(p)

TOK = {
  "@@CSS@@":        rd("tpl/_shared.css"),
  "@@CHROME@@":     rd("tpl/_chrome.part"),
  "@@ICONS@@":      rd("tpl/_icons.part"),
  "@@SWATCHES@@":   rd("tpl/_swatches.part"),
  "@@MARK28@@":     rd("mark-28.svgfrag"),
  "@@MARK_SOLID@@": rd("mark-solid.svgfrag"),
  "@@MARK56@@":     rd("mark-56.svgfrag"),
  "@@POINTER@@":    rd("pointer.svgfrag"),
  "@@LOCKUP@@":     rd("lockup.svgfrag"),
  "@@SINERULE@@":   rd("sine-rule.svgfrag"),
  "@@ARC@@":        rd("arc.svgfrag"),
  "@@WORKING@@":    rd("working.svgfrag"),
  "@@CHAPTERS@@":   rd("chapters.svgfrag"),
  "@@LOBES@@":      rd("lobes.json"),
  "@@IMPORTED@@":   rd("imported.svgfrag"),
  "@@CBASE@@":      rd("ceremony-base.svgfrag"),
  "@@CBEFORE@@":    rd("ceremony-before.svgfrag"),
  "@@CAFTER@@":     rd("ceremony-after.svgfrag"),
  "@@SW_SELF@@":    rd("sw-self_asserted.svgfrag"),
  "@@SW_EMP@@":     rd("sw-employment_verified.svgfrag"),
  "@@SW_PEER@@":    rd("sw-peer_attested.svgfrag"),
  "@@SW_SINGLE@@":  rd("sw-party_single.svgfrag"),
  "@@SW_MULTI@@":   rd("sw-party_multi.svgfrag"),
  "@@GRATICULE_SM@@": graticule(76, 96, 12),
  "@@GRATICULE_LG@@": graticule(296, 296, 24),
}
for tpl in sorted(os.listdir(os.path.join(HERE, "tpl"))):
    if not tpl.endswith(".tpl"): continue
    src = rd(os.path.join("tpl", tpl))
    for k, v in TOK.items(): src = src.replace(k, v)
    left = re.findall(r"@@[A-Z0-9_]+@@", src)
    if left: sys.exit("unresolved token in %s: %s" % (tpl, set(left)))
    out = tpl[:-4] + ".dc.html"
    open(os.path.join(HERE, out), "w").write(src)
    print("%-22s %7d bytes" % (out, len(src)))
