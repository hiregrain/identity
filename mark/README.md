# The mark, the tiers, and the record pointer

Status: **PROVISIONAL, 2026-08-18.** The lobe count is explicitly open — see §2.
Everything here is parameterised so a change of `LOBES` or `BANDS` propagates.

Three objects, one construction. They are routinely confused and must not be:

| Object | Job | Varies? |
|---|---|---|
| **the mark** | Grain's logo. App icon, site, decks, partner listings. | never |
| **the tiers** | purpose-drawn reductions of the mark for small sizes | never |
| **the pointer** | "this person has a record you can inspect" | never |
| **the imprint** | the per-person figure — a *different object*, see [`../imprint/`](../imprint/) | per person |

Companion documents: [`../DESIGN.md`](../DESIGN.md) §3 · [`../imprint/README.md`](../imprint/README.md)

---

## 1. Construction

    r(t) = R + a · sin(7·t + delta_i)

Three concentric bands at radii 90 / 172 / 264, amplitudes 22 / 40 / 30, sweep
direction alternating. **The band widths are deliberately unequal** — that is what
makes the figure read as a record rather than an ornament, and it is the first
thing to preserve under any change.

`delta_i` sweeps one lobe period across the pass count. Thread pitch must exceed
the stroke by ~2.2× or the threads fuse into a solid ribbon; the pass count is
derived from that constraint rather than chosen.

**The deliberate break.** One lobe is deepened ~42% at a fixed angle. Two reasons,
both practical: it gives the mark an unambiguous top, and it converts "a
seven-lobed rosette" — an unownable stock genre with over 1,500 near-identical
free vectors in circulation — into something with a describable feature that can
be searched and policed. Set `BREAK_AMOUNT = 0` to disable.

## 2. Why seven, and why that is provisional

Seven is the imprint's own lobe count, so the mark is grammatically consistent
with the per-person figure without being an instance of it.

The founder has flagged that this may change. Known trade-offs if it does:

- **three** — Woolmark's exact construction *and* lobe count; also Mercury's
  gestalt in the same industry; also adjacent to the valknut, an ADL-listed
  appropriated symbol. Fails below ~32px. Rejected.
- **five** — five-star rating is the universal convention. Worst possible count
  for a product that must not appear to score people.
- **seven** — current. Reads as a law-enforcement badge shape to some viewers;
  also Jordan's flag and the neopagan Elven Star.
- **eight** — Rub el Hizb (a Quranic section marker), Star of Lakshmi, Surya
  Majapahit, the Philippine flag sun.

**There is no unclaimed count.** Every small integer of radial symmetry is
somebody's emblem somewhere. Do not treat lobe count as a way to escape that;
treat it as a choice about *which* association you accept.

## 3. Size tiers — drawn, not scaled

Scaling the master is what fails. Each tier is drawn for its range.

| Tier | Range | What it is | What goes first |
|---|---|---|---|
| `tier_full` | ≥ 80px | three threaded bands | — |
| `tier_two` | 40–79 | outer and inner band, weave thinned | the middle band clogs first |
| `tier_line` | 24–39 | one contour per band, no weave | the weave |
| `tier_solid` | ≤ 23 | solid body, counter knocked out | line art entirely |

**Dark is the stronger rendering** at every size below ~120px — light threads on
ink hold contrast better than ink on paper. This is not a theme preference; it
affects which icon ships.

**iOS.** The superellipse mask crops harder than a square, so the mark sits at
0.74 inset. Android adaptive icons confine artwork to the inner 72 of 108dp,
which will crop a radial mark's outer band — check before shipping.

## 4. The pointer — and what it must never become

The pointer says **"this person has a record you can inspect."** It does **not**
say "this person is verified." That distinction is the thesis, not a nuance:
Grain states what is known and how well it is known; the partner decides what it
means. A badge collapses a graded epistemic claim into a yes, which is the
credential logic the product exists to replace.

**Prohibited, permanently:**

- a filled disc, a shield, a ring, or any enclosing container
- a checkmark, in any form
- a lobed disc beside a name at badge scale — X's verified badge is an octofoil,
  LinkedIn's a sixteen-point scallop, and **Pinwheel**, in payroll and income
  verification, is a four-lobed quatrefoil. A lobed disc in the badge position
  reads as social verification and imports the endorsement meaning the mark must
  never carry.
- rendering larger than the adjacent name's cap height

**On third-party surfaces the pointer must be accompanied by a count** —
"4 chapters · 3 corroborated". A bare glyph beside a name reads as endorsement
whatever its shape. On Grain's own surfaces the surrounding context does that
work and the glyph may stand alone.

## 5. Constraints inherited from the imprint, and why

These are recorded with their reasons so they are not "improved" later.

1. **No centre point.** A small concentric element at the middle of a lobed radial
   figure reads as a bullseye with the worker inside it. Every reviewer group
   reached this independently; two connected it directly to the ratings that
   already follow them at work.
2. **Size must never scale with career length.** Footprint that grows with tenure
   is an age proxy, and an age proxy on a hiring surface is a discrimination
   exposure, not a style question.
3. **Absence of attestation must never render as diminished magnitude.** Pale,
   thin and faint are the universal idiom for *lesser*, not for *unconfirmed*.
   An unverified strong record and a verified weak one must not look alike.

## 6. Open

- **The lobe count** (§2).
- **The break angle** is currently wherever the parameter put it. It should be
  locked to the top so the mark has a stated orientation.
- **Silhouette agreement across tiers.** `tier_solid`'s outer edge is slightly
  rounder than `tier_full`'s, because the threading no longer widens the
  excursion. Someone seeing the favicon and then the header should see one shape.
- **The centre-point rule collides with the imprint's identity core**, which is
  inked at signup and carries the empty state. Removing it from the mark was
  right; whether it survives in the imprint is unresolved. See
  [`../imprint/README.md`](../imprint/README.md) §7.
- **The wordmark** and its lockup with the mark — `DESIGN.md` §4, still open.

## 7. Running it

    python3 examples.py

Standard library only. Writes the mark, its tiers, the unbroken comparison, the
pointer at 16 and 24, and the full iOS icon set in light and dark to `examples/`.
