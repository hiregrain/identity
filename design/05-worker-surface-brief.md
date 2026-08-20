# Worker surface design intent

Written 2026-08-18, before the core screen and grant flow are designed. This is
the intent to build against, not a spec. Everything here traces to a decision or
a research finding; where it traces to a *worker's words*, those are quoted,
because they are the most perishable thing in the repo.

Order of work (decision 028): **core screen, then the grant flow.**

---

## 1. The one idea worth building the screen around

**The bloom.** A chapter enters the record as a plain ring, dotted when
self-asserted and solid when employment is verified. When a party attests, it
*blooms*: it grows lobes and a weave. Nothing else in the system states the
product's thesis as economically. A worker's record visibly becomes more real.

Consequences:

- It is the **motivator**. The verification checklist is not a chore list; it is
  the set of rings that have not bloomed yet. Show them as such.
- It is one of the two heavy ceremonies in `DESIGN.md` §10, an attestation
  landing. Spend the animation budget here and almost nowhere else.
- It means **the empty and unverified states are not failures to be hidden**. A
  résumé import produces a set of bare rings. That is the honest picture and it
  is also the call to action.

## 2. The core screen

Order is settled (decision 028): **imprint · outstanding verification · work
history · sharing · identity.**

Verification sits second because it is the only element that asks the worker to
act, and an unattested record is the product's failure mode. Identity is last
because it is settled once and then irrelevant.

**Non-negotiables, each with its reason:**

- **No centre point on the imprint.** Every reviewer group read a concentric
  centre as a bullseye with the worker inside it. Two connected it directly to
  the ratings that already follow them at work.
- **The canvas is fixed.** Footprint that grows with tenure is an age proxy, and
  an age proxy on a hiring surface is a discrimination exposure (`DESIGN.md` §1
  law 7).
- **Absence is never drawn as diminished magnitude.** Pale and thin read as
  *lesser*, not *unconfirmed* (law 8).
- **Nothing on this screen is a score.** No composite, no percentage, no rank.
  Dimension standing belongs on a second screen: it is the most interpretive
  object in the product and must not be the first thing a worker learns about
  themselves.
- **Work history is rows, not cards**, per the ledger grammar of §8: left text,
  right tabular figures.

## 3. The grant flow

**This is the screen where worker custody either exists or does not.** It is also
the answer to the strongest criticism the research produced.

Four workers, in four countries, independently identified the same structural
risk, that "the employer confirms what you did" means the employer holds the pen:

> Dubai: the sponsor holds the visa, so disputing unpaid overtime may mark you difficult.
> Bengaluru: relieving letters are already withheld to block exits.
> Shenzhen: the factory does not want output records leaving the gate.
> Dhaka: *"official means it is theirs, not mine."*

The grant flow has to *demonstrate* control, not assert it:

- **Show what the requester would actually see, before consent.** Show the real
  payload, not a description of it.
- **Legible under pressure.** Someone deciding in thirty seconds whether to let a
  prospective employer read their record.
- **Expiry is mandatory.** A grant with no end is a permanent disclosure the
  worker forgets making.
- **The worker sees every grant issued, and its state**, which is one of
  issued, active, expired, or revoked. *Amended by decision 035 §B4: read events are not surfaced.*
  A read stream during a live application is an anxiety feed and surveillance of
  the employer; GDPR Art. 15(1)(c) is satisfied by a disclosure record available
  on request.
- **Revocation is one action, always reachable.**

## 4. The dispute path

Partners write freely with no countersign (decision 028, founder ruling). GDPR
Art. 16 gives a right of rectification regardless, so the correction moves from a
countersign gate to a post-hoc dispute, and that path must be **reachable from
any attested chapter**, not buried in settings.

A disputed claim stays **visible and marked**, with the worker's statement
attached, never silently removed. Grain adjudicates authenticity, never substance.

## 5. Conditions the design must survive

From eight simulated workers across Dhaka, Lagos, Bengaluru, Dubai, Jakarta,
Shenzhen, Warsaw and Osaka:

- **Cheap Android, bright sunlight, cracked screens.** Two independently described
  a low-contrast mark at icon size as *"dirt you would try to wipe off the phone."*
- **Thumbnail-first.** Much of the world will meet this product inside WhatsApp or
  a Play Store listing at 48px, not on a laptop.
- **Non-Latin names and scripts.** Archivo covers Latin, Cyrillic and Greek only.
  Bengali, Arabic, Devanagari and CJK are launch-blocking, not later work
  (`DESIGN.md` gap 7).
- **The word "official" is not a compliment everywhere.** It read as credibility
  in Dhaka, Dubai and Warsaw, and as *bureaucracy and gatekeeping* in Jakarta.

## 6. What must never appear

- A checkmark, a badge, a shield, or the pointer rendered without a count on a
  third-party surface (`mark/README.md` §4).
- A star, or anything countable that could read as a rating. Every reviewer group
  reached this independently; the two people who had been *rated for a living*
  reached it fastest.
- A percentage of completeness against a person.
- Career gaps rendered as gaps. Radius is cumulative *engaged* time; this is a
  deliberate refusal and not an oversight (`imprint/README.md` §5).

## 7. Open before building

1. **The record schema field list** exists at `model/record-schema.md` 0.1 but is
   proposed, not ratified. Five open items in its §8.
2. **`work_kind` vocabulary conflict.** Decision 028 says ESCO. Ratified decision
   006 says ledger-authored with crosswalks. The ratified position looks correct.
3. **The identity core versus the no-centre rule.** The core is inked at signup
   and carries the empty state (`imprint/README.md` §7). Unresolved.
4. **A companion typeface** for non-Latin scripts.
