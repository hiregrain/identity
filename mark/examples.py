"""Generate reference assets. Run: python3 examples.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mark as M

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "examples")
IOS = [1024, 180, 152, 120, 87, 80, 76, 60, 58, 40, 29]

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    w = lambda n, s: open(os.path.join(OUT, n), "w").write(s)
    # the mark and its tiers
    w("mark-full.svg",  M.svg(M.tier_full(512), 512))
    w("mark-two.svg",   M.svg(M.tier_two(64), 64))
    w("mark-line.svg",  M.svg(M.tier_line(32), 32))
    w("mark-solid.svg", M.svg(M.tier_solid(20), 20))
    # without the deliberate break, for comparison
    w("mark-full-unbroken.svg", M.svg(M.tier_full(512, broken=False), 512))
    # the pointer
    w("pointer-16.svg", M.svg(M.pointer(16), 16, background=False))
    w("pointer-24.svg", M.svg(M.pointer(24), 24, background=False))
    # lockups. Archivo is supplied by the consuming surface; if a woff2 is present
    # at mark/archivo.woff2 it is embedded so the file renders standalone.
    import base64
    fp = os.path.join(os.path.dirname(os.path.abspath(__file__)), "archivo.woff2")
    css = ""
    if os.path.exists(fp):
        b64 = base64.b64encode(open(fp, "rb").read()).decode()
        css = ("@font-face{font-family:'Archivo';src:url(data:font/woff2;base64,%s) "
               "format('woff2');font-weight:100 900;font-stretch:62%% 125%%;}" % b64)
    for px in (104, 80, 54, 44, 30):
        w("lockup-%d.svg" % px, M.lockup_svg(px, font_css=css))
        w("lockup-dark-%d.svg" % px, M.lockup_svg(px, dark=True, font_css=css))
    # app icons
    for px in IOS:
        w("icon-light-%d.svg" % px, M.app_icon(px, uid="l%d" % px))
        w("icon-dark-%d.svg" % px, M.app_icon(px, dark=True, uid="d%d" % px))
    print("wrote %d files to %s" % (6 + 10 + 2 * len(IOS), OUT))
