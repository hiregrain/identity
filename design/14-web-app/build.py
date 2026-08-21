import os, re, sys

# design/13 drew the record inside iOS and Android. This directory draws the
# same record inside a browser, where the seam falls somewhere else entirely:
# a browser hands back the toolbar, back, sheets, confirmation and the month
# picker, and hands over no haptics at all. See design/12 "The seam in a
# browser".
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "10-worker-app-screens")
PLATFORM = os.path.join(HERE, "..", "13-platform-screens")


# HTML parsing ignores XML self-closing on unknown elements, so a run of
# <path/> siblings read out of a <template> nests instead of stacking and only
# the outermost renders. Same defect, same fix, as design/13.
def xclose(s):
    return re.sub(r"<([A-Za-z][\w-]*)((?:[^<>\"']|\"[^\"]*\"|'[^']*')*?)\s*/>", r"<\1\2></\1>", s)


def rd(n):
    return xclose(open(os.path.join(SRC, n)).read())


def local(n):
    return xclose(open(os.path.join(HERE, "tpl", n)).read())


# The record's own surfaces are IMPORTED from design/13, never copied. They
# reference only S.scale, S.state and @@ARC@@, and touch no DOM, which is what
# makes them portable across a chassis. A second copy of forty-nine bodies
# would drift within days, which is the failure CLAUDE.md names by name.
# Anchored on strings rather than line numbers so an edit upstream moves the
# slice instead of silently truncating it.
def surfaces():
    src = open(os.path.join(PLATFORM, "standalone.tpl")).read()
    a = src.find("var T = function(id)")
    b = src.find("\nfunction paintBar()")
    if a < 0 or b < 0 or b <= a:
        sys.exit("design/13 standalone.tpl no longer carries the surface slice anchors")
    cut = src[a:b]
    if "var SURFACES = {" not in cut:
        sys.exit("the imported slice does not contain the surface registry")
    return cut


# The content CSS, likewise imported: everything that styles the record itself
# rather than the device around it. The slice starts at the first content rule
# and stops where design/13's console begins, so the shell and the console are
# this directory's own and the record's drawing is not forked.
def contentcss():
    src = open(os.path.join(PLATFORM, "standalone.tpl")).read()
    a = src.find(".idhero{")
    b = src.find("/* ---------- the console")
    if a < 0 or b < 0 or b <= a:
        sys.exit("design/13 standalone.tpl no longer carries the content-CSS anchors")
    return src[a:b]


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
    "@@GRATICULE_SM@@": graticule(64, 64, 8),
    "@@GRATICULE_SCREEN@@": graticule(640, 760, 32),
    "@@GRATICULE_PAGE@@": graticule(1280, 820, 40),
    "@@PORTRAIT@@": xclose(open(os.path.join(PLATFORM, "tpl", "_portrait.part")).read()),
    "@@EMPTYFIG@@": xclose(open(os.path.join(PLATFORM, "tpl", "_emptyfig.part")).read()),
    "@@MARK56@@": rd("mark-56.svgfrag"),
    "@@ARC@@": rd("arc.svgfrag"),
    "@@MARK_SOLID@@": rd("mark-solid.svgfrag"),
    "@@ACCOUNTGLYPH@@": xclose(open(os.path.join(PLATFORM, "tpl", "_accountglyph.part")).read()),
    "@@SHAREGLYPH@@": xclose(open(os.path.join(PLATFORM, "tpl", "_shareglyph.part")).read()),
    "@@CHEV@@": xclose(open(os.path.join(PLATFORM, "tpl", "_chev.part")).read()),
    "@@SWITCH@@": xclose(open(os.path.join(PLATFORM, "tpl", "_switch.part")).read()),
    "@@SURFACES@@": surfaces(),
    "@@CONTENTCSS@@": contentcss(),
}

standalone = open(os.path.join(HERE, "standalone.tpl")).read()
# Two passes: the imported slice carries @@ARC@@ of its own.
for _ in range(2):
    for k, v in TOK.items():
        standalone = standalone.replace(k, v)
left = re.findall(r"@@[A-Z0-9_]+@@", standalone)
if left:
    sys.exit("unresolved token in standalone.tpl: %s" % set(left))
open(os.path.join(HERE, "grain-web-app.html"), "w").write(standalone)
print("%-30s %7d bytes" % ("grain-web-app.html", len(standalone)))

# The publishable variant. The Artifact host supplies its own doctype, head
# and body, so the page ships as title + style + content and nothing else.
head = standalone.split("<head>", 1)[1].split("</head>", 1)[0]
title = head.split("<title>", 1)[1].split("</title>", 1)[0]
style = "<style>" + head.split("<style>", 1)[1].split("</style>", 1)[0] + "</style>"
body = standalone.split("<body>", 1)[1].rsplit("</body>", 1)[0]
art = "<title>" + title + "</title>\n" + style + "\n" + body
open(os.path.join(HERE, "grain-web-app.artifact.html"), "w").write(art)
print("%-30s %7d bytes" % ("grain-web-app.artifact.html", len(art)))
