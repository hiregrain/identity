import os, re, sys

# Same pipeline as design/13, pointed at the same shared fragments. The console
# draws no figures, so it pulls only the two tokens that would otherwise drift:
# the design system's CSS and the shared component chassis. Hand-copying either
# is how a second, divergent copy of the row grammar gets written.
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "10-worker-app-screens")


def xclose(s):
    return re.sub(r"<([A-Za-z][\w-]*)((?:[^<>\"']|\"[^\"]*\"|'[^']*')*?)\s*/>", r"<\1\2></\1>", s)


def rd(n):
    return xclose(open(os.path.join(SRC, n)).read())


def local(n):
    return xclose(open(os.path.join(HERE, "tpl", n)).read())


TOK = {
    "@@CSS@@": rd("tpl/_shared.css"),
    "@@CHROME@@": rd("tpl/_chrome.part"),
    "@@LOCKUP@@": rd("lockup.svgfrag"),
    "@@CONSOLE@@": local("_console.part"),
    "@@NAV@@": local("_nav.part"),
}

for tpl in sorted(os.listdir(os.path.join(HERE, "tpl"))):
    if not tpl.endswith(".tpl"):
        continue
    src = open(os.path.join(HERE, "tpl", tpl)).read()
    for _ in range(5):
        before = src
        for k, v in TOK.items():
            src = src.replace(k, v)
        if src == before:
            break
    left = re.findall(r"@@[A-Z0-9_]+@@", src)
    if left:
        sys.exit("unresolved token in %s: %s" % (tpl, set(left)))
    # Structural guards. A template that lost its doctype, grew a second logic
    # block, or binds a hole nothing returns still builds and still renders,
    # just wrong: the holes come out blank. All three happened while authoring
    # this directory, so they fail the build instead.
    if not src.lstrip().startswith("<!doctype html>"):
        sys.exit("%s does not start with a doctype" % tpl)
    if src.count("data-dc-script") != 1:
        sys.exit("%s carries %d logic blocks, expected 1" % (tpl, src.count("data-dc-script")))
    body, logic = src.rsplit("<script data-dc-script", 1)
    holes = set(re.findall(r"\{\{\s*([A-Za-z_][\w]*)\s*\}\}", body))
    # {{ true }} and friends are literals the runtime resolves itself, not
    # names the logic supplies; $-prefixed names are loop scope.
    LITERALS = {"true", "false", "null", "undefined"}
    missing = sorted(
        h for h in holes
        if h not in LITERALS and not h.startswith("$") and ("%s:" % h) not in logic
    )
    if missing:
        sys.exit("%s binds holes its logic never returns: %s" % (tpl, ", ".join(missing)))

    out = tpl[:-4] + ".dc.html"
    open(os.path.join(HERE, out), "w").write(src)
    print("%-22s %7d bytes" % (out, len(src)))
