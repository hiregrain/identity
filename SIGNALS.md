# Signals: what Grain collects and why

**Status: living, 2026-08-20.** This file is a register of candidate signals
and the argument for each. It is not binding and it defines no fields.
`model/record-schema.md` owns the field list and `decisions/LOG.md` owns
anything settled; where this file and either of those disagree, they win and
this file is stale.

It exists because the field list alone does not carry its reasons, and a
signal admitted for a reason that later fails should leave when the reason
does. Every entry therefore carries **what would change this**. An entry with
no such line is not finished.

Companion to `THESIS.md` §1, which sets the standard: the record beats the
résumé by holding fields the résumé never had, taken from the party positioned
to know them, while they still know them.

---

## The organising claim

The résumé transmits the numerator and destroys the denominator. "Grew revenue
40%" is uninterpretable without the base, the team, the conditions, and
whether the person inherited the function or built it. Most of what follows is
denominator.

## The admission filter

A signal belongs on the core attester surface only if all three hold:

1. The attester knows it without investigating.
2. They can state it without exercising judgment.
3. Two attesters observing the same thing would state it identically.
4. It is useful on the first record it appears on, not only once many
   accumulate.
5. It is comparable across parties, or it is explicitly party-local. A field
   whose meaning depends on the attesting party's own scale is a strong local
   interaction and must not cross the boundary, whatever its value inside it.

A signal failing (2) or (3) is a quality score wearing a fact's clothes, and
`THESIS.md` §4 already rules those party-local and unnormalised. A signal
failing (4) cannot start the graph, only extend one that already exists
(`THESIS.md` §3). A signal failing (5) is not excluded, it is routed: it stays
with the issuing party and never enters a comparable channel.

## The binding constraint

Attester seconds, not schema design. `THESIS.md` §8 names the write incentive
as the real flywheel risk, so every field is a tax on the party Grain most
needs. Rank by signal per second of attester time, not by completeness.

---

## Attester-provided

### 1. Conditions at the time

State on arrival, team size and how it changed, resourcing, inherited or
founded, organisation growing or contracting.

**Why.** Converts every outcome fact from anecdote into evidence. Cheap for
the attester, impossible for a reader to reconstruct, and absent from the
résumé entirely.

**Status.** Candidate, and **party-local under filter 5**. A team of three
means different things at a seed company and at a bank, so team size and
resourcing are strong local interactions measured against the party's own
scale. They are recorded, readable under a grant, and never normalised or
compared across parties. An earlier draft of this file ranked the category as
the highest-value comparable field, which was wrong: it is high value and it
does not cross.

**What would change this.** A construction that expresses conditions on a
scale the ledger owns rather than the party's, which would move the category
into a comparable channel.

### 2. Surface and attribution

Decided, owned, executed, contributed, observed. Home is
`dimensions_exercised`.

**Why.** The résumé cannot distinguish the person who ran the thing from the
person who was near it. Readers know this and discount everyone accordingly,
which is why the honest candidate is punished by the incumbent format.

**Status.** Candidate. Blocked on the responsibility level definitions
(`THESIS.md` §10 gap 11).

**What would change this.** Level definitions proving unwritable in a way two
parties apply consistently.

### 3. Volume and cadence, with time

Counts of a defined activity over a bounded period, so the derived quantity is
a rate.

**Why.** A rate is the only honest input to slope before the fixed instrument
(§10 gap 19) exists, and it is immune to two of §5's three failure modes
because no grader is involved.

**Status.** Candidate. Volume is already one of §4's four comparable channels;
the addition here is the time denominator.

**What would change this.** Finding that activity definitions cannot be held
stable enough across parties for rates to compare.

### 4. Observer proximity

Relationship, distance, how long they observed, how directly.

**Why.** Provenance class answers what kind of party attested. This answers
how well positioned they were, which is a different axis and the one the
résumé cannot carry at all, because the résumé has no observer. A claim from
someone who sat with the person for two years is a different object from a
skip-level's.

**Status.** Candidate. Not in the model today.

**What would change this.** Evidence that self-reported proximity is inflated
enough to be uninformative.

### 5. Terminal facts, including the unflattering ones

Non-renewal, early termination, stretch offered and declined. Several already
appear in §4's outcome-fact channel.

**Why.** The highest-signal category in the design, and the one a self-authored
document structurally cannot contain.

**Status.** Partially ruled in, with an unresolved tension. Whole-profile
deletion is the worker's exit, so a population that deletes after a bad
outcome leaves a record whose silences are readable. Not ruled anywhere.
Founder call outstanding.

**What would change this.** A resolution of the deletion tension, in either
direction.

### 6. Currency

When the work was last performed.

**Why.** Most of what a stale résumé hides. Already one of the four epistemic
marks.

**Status.** Ruled in.

**What would change this.** Nothing foreseeable.

### 7. Revealed-preference facts

Not what the observer thinks, what the observer did. Rehired, referred to a
peer, tried to retain, allocated the scarce or ambiguous work, gave them the
new hire to train, put them in front of the customer.

**Why.** Each is a costly action by someone with skin in the game, which makes
it structurally harder to inflate than any assessment, and each is a single
click. "Would you work with them again" is stated preference and nearly
worthless. "Did you try to keep them" is revealed and expensive to fake. On
signal per attester second this is the strongest category on the list.

**Status.** Candidate, highest priority. Not in the model today. **Splits
under filter 5.** Rehired, referred to a peer and promoted during are
categorical events any party reports identically and they cross. Tried to
retain, allocated the scarce work and gave them the new hire to train are
measured against a party's own resources and headcount, so they stay
party-local on the same footing as entry 1.

**What would change this.** Evidence that these actions are driven by factors
uncorrelated with the worker often enough to be noise.

### 8. Non-managerial observers

Peers, reports, adjacent teams, customers.

**Why.** They observe different things, and a report is the only party who can
attest to whether someone made other people more effective. The résumé's limit
is not only that it is self-authored; it carries the top-down view alone, from
referees the candidate chose.

**Status.** Candidate. Interacts with the Sybil apparatus and with decision
025's reciprocity caps.

**What would change this.** Sybil exposure proving unmanageable at this
observer breadth.

---

## Ledger-derived

The attester surface stays cheap and factual. The value no competitor can
reach is derived across many parties over many years.

### 9. Repetition across contexts

Whether an outcome recurred under different conditions, at different parties,
with different teams.

**Why.** A single employer can never separate the person from the situation,
because they hold one observation of the situation. That is a structural bound
on what any employer can know about anyone, including the people they know
best, and it does not improve with better internal data. Grain is the only
party that can hold n greater than one. This is the sharpest answer both to
why the record beats the résumé and to why an employer cannot build it
themselves.

**Status.** The moat, and **it fails filter 4**. Repetition across contexts is
worth nothing on a first record and everything on a tenth, so it cannot be
what makes early records worth holding. That is a real property of the thing
being called a moat and it belongs beside the claim rather than behind it.
Requires depth on the same person across employers,
which makes §8's write-back problem the gate on the moat rather than a growth
constraint. `THESIS.md` §2 currently rests the independence argument on the
union of attestations rather than on what the union permits inferring, and
should be revised.

**What would change this.** Finding that cross-context repetition is too rare
in real career paths to compute on.

### 10. Time to independent ownership

Start to first unsupervised responsibility, and how that interval moves across
engagements.

**Why.** A rate rather than a grade, so it dodges two of §5's three failure
modes, and shortening it across parties is the cleanest evidence of
transferable ability available without a fixed instrument.

**Status.** Candidate. Depends on 2 and 3.

**What would change this.** Attesters proving unable to date the transition.

---

## Considered and ruled out

### 11. Compensation and its trajectory

**Why it is attractive.** Revealed preference by an employer spending real
money, and one of the highest-signal fields available anywhere.

**Why it is out.** Wage data flowing across competing employers through a
neutral intermediary is the precise fact pattern in the January 2025 DOJ/FTC
labour-market information-exchange guidelines, where being a neutral
third-party intermediary is expressly not a defence (`THESIS.md` §9).

**Status.** Ruled out on antitrust grounds, recorded here because it will be
proposed again.

**What would change this.** Counsel returning that a structure exists which
does not constitute an information exchange, or a change in the guidelines.

---

## Open

- The deletion tension in 5.
- Whether 4 and 8 belong in `model/record-schema.md` or in the attestation
  envelope.
- Whether repetition across contexts (9) needs its own object or falls out of
  querying chapters.
