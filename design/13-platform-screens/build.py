import os, re, sys

# Same pipeline as design/10, pointed at the same fragments. The geometry,
# the lockup and the swatches are generated once by 10/gen.py and are not
# regenerated here: this directory redraws the chrome around the record, not
# the record's own figures.
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "10-worker-app-screens")


# HTML parsing ignores XML self-closing on unknown elements, so a run of
# <path/> siblings read out of a <template> nests instead of stacking and only
# the outermost renders. This silently dropped five of the imprint's eight
# paths. Explicit close tags are inert in SVG namespace and required in HTML.
def xclose(s):
    return re.sub(r"<([A-Za-z][\w-]*)((?:[^<>\"']|\"[^\"]*\"|'[^']*')*?)\s*/>", r"<\1\2></\1>", s)


def rd(n):
    return xclose(open(os.path.join(SRC, n)).read())


def local(n):
    return xclose(open(os.path.join(HERE, "tpl", n)).read())


# graticule, the chart ground (DESIGN.md 9), copied rather than imported
# because 10/build.py is a script rather than a module.
def graticule(w, h, step=12):
    p = []
    for y in range(step, int(h), step):
        p.append("<path d='M0 %d L%d %d'></path>" % (y, w, y))
    for x in range(step, int(w), step):
        k = (x - w / 2.0) / (w / 2.0)
        p.append("<path d='M%.1f 0 Q%.1f %.1f %.1f %d'></path>" % (x, x + k * 7, h / 2.0, x, h))
    return "".join(p)


TOK = {
    "@@CSS@@": rd("tpl/_shared.css"),
    "@@CHROME@@": rd("tpl/_chrome.part"),
    "@@ICONS@@": rd("tpl/_icons.part"),
    "@@SWATCHES@@": rd("tpl/_swatches.part"),
    "@@LOCKUP@@": rd("lockup.svgfrag"),
    "@@SINERULE@@": rd("sine-rule.svgfrag"),
    "@@CHAPTERS@@": rd("chapters.svgfrag"),
    "@@SW_SELF@@": rd("sw-self_asserted.svgfrag"),
    "@@SW_EMP@@": rd("sw-employment_verified.svgfrag"),
    "@@SW_PEER@@": rd("sw-peer_attested.svgfrag"),
    "@@SW_SINGLE@@": rd("sw-party_single.svgfrag"),
    "@@SW_MULTI@@": rd("sw-party_multi.svgfrag"),
    "@@GRATICULE_LG@@": graticule(296, 296, 24),
    "@@GRATICULE_SCREEN@@": graticule(402, 874, 28),
    "@@GRATICULE_SM@@": graticule(64, 64, 8),
    "@@PORTRAIT@@": local("_portrait.part"),
    "@@EMPTYFIG@@": local("_emptyfig.part"),
    "@@MARK56@@": rd("mark-56.svgfrag"),
    "@@ARC@@": rd("arc.svgfrag"),
    "@@MARK_SOLID@@": rd("mark-solid.svgfrag"),
    # Local parts: system chrome glyphs and two controls the seam hands over.
    "@@STATUSGLYPHS@@": local("_statusglyphs.part"),
    "@@ACCOUNTGLYPH@@": local("_accountglyph.part"),
    "@@SHAREGLYPH@@": local("_shareglyph.part"),
    "@@CHEV@@": local("_chev.part"),
    "@@SWITCH@@": local("_switch.part"),
}

# The standalone prototype: the same record, built as a page that is simply
# opened and driven. The canvas is a design surface, so an artboard there is
# selected rather than operated.
standalone = open(os.path.join(HERE, "standalone.tpl")).read()
for k, v in TOK.items():
    standalone = standalone.replace(k, v)
left = re.findall(r"@@[A-Z0-9_]+@@", standalone)
if left:
    sys.exit("unresolved token in standalone.tpl: %s" % set(left))
open(os.path.join(HERE, "grain-ios-prototype.html"), "w").write(standalone)
print("%-26s %7d bytes" % ("grain-ios-prototype.html", len(standalone)))

# The publishable variant. The Artifact host supplies its own doctype, head
# and body, so the page ships as title + style + content and nothing else.
head = standalone.split("<head>", 1)[1].split("</head>", 1)[0]
title = head.split("<title>", 1)[1].split("</title>", 1)[0]
style = "<style>" + head.split("<style>", 1)[1].split("</style>", 1)[0] + "</style>"
body = standalone.split("<body>", 1)[1].rsplit("</body>", 1)[0]
art = "<title>" + title + "</title>\n" + style + "\n" + body
open(os.path.join(HERE, "grain-ios-prototype.artifact.html"), "w").write(art)
print("%-26s %7d bytes" % ("grain-ios-prototype.artifact.html", len(art)))

for tpl in sorted(os.listdir(os.path.join(HERE, "tpl"))):
    if not tpl.endswith(".tpl"):
        continue
    src = open(os.path.join(HERE, "tpl", tpl)).read()
    for k, v in TOK.items():
        src = src.replace(k, v)
    left = re.findall(r"@@[A-Z0-9_]+@@", src)
    if left:
        sys.exit("unresolved token in %s: %s" % (tpl, set(left)))
    out = tpl[:-4] + ".dc.html"
    open(os.path.join(HERE, out), "w").write(src)
    print("%-22s %7d bytes" % (out, len(src)))
