# Worker app screens

The drawn surfaces of the worker app, as source — one template per screen. Committed on 2026-08-19
after decision 012's lesson was repeated: the T1 spike artifacts were lost to
temp-directory cleanup, and these nearly went the same way — they existed only
in a session scratchpad and a published Artifact.

**The design venue is a published canvas**, and that is where review and
iteration happen:

<https://claude.ai/code/artifact/7d177fbe-88c2-4e18-97b8-5a8d1fd85232>

This directory is the source of record behind it. If the two disagree, this
directory is authoritative and the canvas is republished from it.

## What is here

| | |
|---|---|
| `tpl/*.tpl` | the authored source for each screen |
| `tpl/_shared.css` | the type scale, colour tokens and press physics, from `DESIGN.md` §5–§7 |
| `tpl/_chrome.part` | the plate, ledger rows, section heads — the shared chassis |
| `gen.py` | runs `imprint/imprint.py` and `mark/mark.py` to emit the figures |
| `build.py` | substitutes those figures into the templates |
| `*.dc.html` | the built screens |
| `canvas.json` | artboard layout, pages, and the annotations carrying open questions |

## Rebuilding

```
python3 gen.py .        # regenerate the imprint, mark and swatch fragments
python3 build.py        # substitute into templates, emit the screens
```

`gen.py` imports the repo's own generators rather than copying their geometry,
so a change to `imprint/imprint.py` propagates. The intermediate `.svgfrag`
files are derived and deliberately not committed.

## The nine screens, and what each is evidence for

**Main** — the core screen. Identity and imprint composed as one hero, then
outstanding verification, work history, sharing (decision 035, amending 028).
**Expanded** — the imprint at full size. Angle reads the measure, radius reads
the chapter. This is what closes `imprint/README.md` §7.1, the missing angular
anchor. **Landing** — an attestation arriving, the heavier of the two ceremonies
`DESIGN.md` §10 allows. **Consent** — the seven mechanics. **Empty**,
**Imported**, **Handle** — the first-run sequence. **Settings** — read-only,
per decision 036. **Public** — the page a worker sends someone, on its own
chassis so it cannot be mistaken for a dossier.

## What these are not

They are not a specification. `design/06-worker-app-ia.md` owns the structure,
`design/08-app-inventory.md` owns what exists and what does not, and
`design/07-worker-app-design-review.md` records the defects six independent
reviews found in this exact source — several of which are still open in it.
Read 07 before treating any screen here as settled.

**Nine of fifty-two surfaces are drawn.** The other forty-three are listed in
`08` with no drawing behind them, and under the mockup gate in
`plans/worker-surface/LAYER.md` none of them is buildable yet.
