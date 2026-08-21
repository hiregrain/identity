"""Regenerate the spike's worst-case imprint fixture from the canonical generator.

Run from the repository root:

    python3 surfaces/app-shell/fixtures/generate.py

The fixture is committed, so the harness and its Node tests never need Python.
This script exists so the committed bytes are reproducible rather than hand-made,
and so the load the spike puts on the renderer is the load `imprint/imprint.py`
actually produces rather than a number copied out of a decision.

Why these parameters. `app-shell/00` asks for the figure at 24,352 vertices,
which is decision 040's worst case measured against the fixed 760-sample
polyline the generator no longer emits. The Bezier fit that replaced it
(`thread_path`) cuts the same record at 360 CSS px on a 3x screen to 5,852
vertices. The stated load is reached instead by pinching: at 720 CSS px on a
3x screen, a 360 px figure held at 2x zoom, the densest reference record draws
23,585 vertices. That is the number the fixture carries and the number the
findings record.
"""

from __future__ import annotations

import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "imprint"))

import imprint  # noqa: E402
from examples import CASES  # noqa: E402

CASE = "12-profile-warehouse"
SIZE = 720
DPR = 3.0
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "imprint-worst-case.json")


def path_data(svg):
    """The `d` attribute of every <path> in the rendered SVG, in document order."""
    out = []
    cursor = 0
    while True:
        start = svg.find("<path d='", cursor)
        if start == -1:
            return out
        start += len("<path d='")
        end = svg.index("'", start)
        out.append(svg[start:end])
        cursor = end


def main():
    svg = imprint.render(CASES[CASE], size=SIZE, dpr=DPR)
    paths = path_data(svg)
    # Char-counting the command letters is exact only because imprint.py emits
    # absolute M and C (and a trailing Z), never L, relative commands, or the
    # shorthand. test/fixture.test.mjs asserts no path carries a letter outside
    # M/C/Z, which is what keeps this count and that one in agreement.
    vertices = sum(d.count("C") + d.count("L") + d.count("M") for d in paths)
    fixture = {
        "case": CASE,
        "size": SIZE,
        "dpr": DPR,
        "viewBox": imprint.VIEWBOX,
        "ink": imprint.INK,
        "paper": imprint.PAPER,
        "strokePx": imprint.STROKE_PX,
        "vertices": vertices,
        "paths": paths,
    }
    with open(OUT, "w") as fh:
        # indent=2 and a trailing newline are what `prettier --check` accepts,
        # so the generated file passes `make lint` without a prettier ignore.
        json.dump(fixture, fh, indent=2, sort_keys=True)
        fh.write("\n")
    print("wrote %s: %d paths, %d vertices" % (OUT, len(paths), vertices))


if __name__ == "__main__":
    main()
