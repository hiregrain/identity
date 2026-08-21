# Operator console design intent

Written 2026-08-21, revised the same day after a founder grilling. This is the
intent to build against, not a spec. Companion to
[`05-worker-surface-brief.md`](05-worker-surface-brief.md), which did the same
job for the record. The structure this intent produced is
[`17-operator-console-ia.md`](17-operator-console-ia.md), and the artboards are
[`16-operator-console`](16-operator-console/). Read the IA for what the console
is; this document is only why. The two surfaces share a design system and almost nothing
else, and §3 is the argument about which parts cross.

**The grilling moved the layer.** `operator-console` belongs in `first-product`,
not v1: a product you can sell cannot ship a steward queue with no steward.
Excluding it was a mistake. The frontmatter change, the scope amendment in §2,
and the decisions entries §8 names are separate commits and none of them are
made by this document.

---

## 1. The one idea worth building the console around

**The evidence comes before the action.**

The record is read slowly by the person it describes. The console is read fast by
a stranger with power over it. That inversion is the whole design problem. An
operator looking at a candidate pair holds more power over a worker's record in
that moment than the worker does, and the only thing between a wrong merge and a
contaminated career is whether the operator actually looked.

So a queue row is not a task to clear. It is a claim to adjudicate, and the
surface makes adjudication cheap and clearing expensive:

- **Action controls sit below the evidence, never beside a row.** There is no
  approve control in a list. Deciding requires opening the case.
- **No number prints on a row.** `person-identity/05` stores candidate pairs with
  per-signal contributions and a total score, and requires the total be
  reproducible from the contributions, "auditable, not a black box". The total
  drives sort order and appears only on the case screen beside the contributions
  it is derived from. A number in a row is a verdict an operator can act on
  without opening the case, which defeats everything above it.
- **Cannot determine is a first-class outcome**, drawn at the weight of the
  others. An operator who has no way to say "not on this evidence" will say yes.

**A merge is reversible, and that is not a reason to relax.** `ledger-design-0.1.md`
§1.4 and `person-identity/06`: unmerge appends an event, neither event stream is
touched, every signature still verifies. What does not reverse automatically is
the residue. Attestations issued against the survivor during the merged window
are flagged for re-assignment review, "the one genuinely manual residue of a
wrong merge, and the reason merges over attested history need review before, not
after". The friction is bought by the residue, not by permanence.

**One surface cannot obey this rule, and the design says so out loud.** See §2's
last row and §4.

## 2. The surfaces, and the two treatments

The layer's scope names four. Two more exist in `ready` task files and are
absorbed here rather than left to build a second console elsewhere.

| Surface | Treatment | Source |
|---|---|---|
| Merge review | adjudication | `person-identity/05`, `/06` |
| Party vetting | adjudication | `party-registry/05` |
| Unmerge re-assignment | adjudication | `person-identity/06` AC |
| Safety-marker match | adjudication, separately tiered | `person-identity/07`, decision 014 |
| Dispute administration | monitoring | `ledger-design-0.1.md` §4 |
| Deletion oversight | monitoring | `consent-and-deletion` |

**Adjudication and monitoring are opposite treatments inside one application.**
An adjudication surface slows the reader down. A monitoring surface lets a reader
confirm nothing is wrong in seconds and leave. Dispute deadlines fire
notifications and state transitions without operator polling (layer criterion 3),
so dispute administration is a state view and drawing it as a work queue would
invent work that criterion 3 exists to eliminate. Deletion oversight has nothing
to do on a good day, and its entire design goal is that a bad day is impossible
to miss.

This is a rule about behaviour, not an argument for two products. One console.

**What can fire depends on which layers land.** Deletion oversight and
safety-marker match both need `consent-and-deletion`, which is still `draft`.
They are declared as gated criteria under decision 073's rule that a layer is
`done` when every non-gated criterion is met, and they discharge when that layer
lands. Declaring it is the point; the undeclared case is the one that drifts.

**Two-operator approval is a state the queue renders, not a setting.** Decision
013 and `person-identity/06`: two approvals where both records carry verified
attestations, one otherwise, approval identities recorded on the event, with a
mechanical AC rejecting the single-approval path over two attested records. An
operator must be able to see which kind of case they are in before they act,
because the gradient is the difference between a decision they can finish and one
they cannot.

## 3. What crosses from the record's design system

**Crosses, because the console is a ledger surface and these carry meaning:**

- **The ledger row grammar** (`DESIGN.md` §8): left text, right tabular figures,
  hairline separators, a state-mark gutter, corrections struck in place and
  dated. A queue is a ledger of pending claims. This is the one place the row
  grammar needs no argument at all.
- **The state grammar by line quality** (law 4), never by badge or colour dot.
- **Monochrome, no accent** (§5). The console holds more states than any other
  surface and is exactly where an accent would get introduced "just for
  severity". It does not get one.
- **`rule` versus `hairline`** (decision 049). A line a reader must notice is
  `rule`. In a dense queue that discipline is load-bearing rather than pedantic.
- **Danger by ink inversion, explicit words and a confirmation ceremony, never by
  red** (§5). The console holds more destructive actions than every other surface
  combined, so this rule gets its heaviest use here.
- **Ruled inputs, square-cut chips, no checkmarks anywhere** (§8, decision 047).

**Does not cross:**

- **The plate.** Registration corners, the header band carrying document class
  and serial, the footer carrying append-only status. The plate is the chassis of
  a record. A queue is not a record, and dressing it as one is the
  document-cosplay ban in [`01-banned-patterns.md`](01-banned-patterns.md) that
  the founder rejected five renders over.
- **The graticule ground.** Reserved for empty states and credential surfaces.
- **Ceremony.** `DESIGN.md` §10 permits two heavy ceremonies, an attestation
  landing and a chapter beginning, both worker moments. **A completed merge gets
  none.** An operator finishing a piece of work is not a celebration, and a
  surface that rewards completion optimises for throughput. Confirmation friction
  before a destructive act and celebration after one are different objects; the
  console uses the first and never the second.
- **The imprint as a hero.** It renders here, read-only, as an object under
  adjudication, because whether a record carries attested history is what decides
  the approval gradient. Evidence on this surface, never the composition.

**The console never travels.** It is an internal tool. The human-queues product
line is Grain-operated review as a service, not licensed software, so the console
stays in §11's internal-system tier alongside the plate and the ceremonies. If a
second operator of a ledger ever exists, that is a new interface negotiation,
which is the move `ledger-design-0.1.md` §9 already makes for organization
identities. Designing now for a hypothetical licensee is how the plate ends up on
a queue.

## 4. Non-negotiables, each with its reason

**An operator sees an evidence extract, not two records.** The default view
carries the matched signals with their per-signal contributions, name variants,
chapter shapes and date ranges. A full-record view is a reasoned, logged
escalation. `person-identity/05` marks IP and device signals as "triage evidence
only, never identity proof", and an operator reading two full life histories will
weight narrative similarity over the signals the matcher actually scored, which is
the mixed-file failure arriving through the human instead of the algorithm. The
credit bureaus' litigation record is the cautionary tale §1.3 names, and a wrong
merge contaminates a career.

**Extract views are operator events; escalations are record reads.** An escalation
is disclosable on an Article 15(1)(c) request through the route
[`08-app-inventory.md`](08-app-inventory.md) H5 already builds, and never appears
as a feed. Decision 035 §B4, reaffirmed by decision 060, keeps full-record reads
off worker surfaces because a read stream during a live application is an anxiety
feed; that reasoning is about an employer reading a worker mid-application and
does not transfer to Grain's own staff, which is why the disclosure route stays
open and the feed stays closed. `ledger-design-0.1.md` §7.1 and §8.1 currently
assert the opposite, so this needs an entry (§8).

**No throughput on any adjudication surface.** No cleared count, no time per
case, no agreement rate, nothing per-operator anywhere, including for management.
The reason is not workload: the layer says operator decisions feed the matcher as
labels, so an operator who learns to agree with the matcher degrades the matcher
permanently, and any visible agreement statistic teaches exactly that. Queue depth
and latency are real operational facts and they live on an operations surface, not
on the screen where a decision is made.

**Nothing here is a score, including about parties.** Tier is a category, cap is a
number with a unit, reliability is a set of signals with their contributions.
None of them composite. `ledger-design-0.1.md` §3.5 is explicit that a visible
party score "would become the next Goodhart target".

**Reliability signals are self-labelling on their face.** Layer criterion 4 says
they render only inside the console, asserted by a check that no API or packet
field carries them. A check covers serialisation and not a screenshot pasted into
a support thread, and `party-registry/05` puts tier, cap and reliability behind a
shared internal-only fixture precisely because leakage is the failure mode. The
rendering states what it is, and never borrows the provenance mark vocabulary
that decision 055 made the sole carrier of provenance on surfaces that travel.

**A freeze is not a suspension, and the surface may never blur them.** Decision
015: falling off an accreditation allowlist freezes new writes and flags a human,
never auto-suspends, because external registries carry name changes and data
errors at rates that would take legitimate parties offline. The party stays
`active` and under no finding. Two visually similar states would defeat a ruling
that exists to protect innocent parties, so they take different line qualities and
different words, and the frozen state says on screen that no finding has been
made.

**Safety-marker review can only decide the match, and the screen says so.** The
marker row carries a keyed document hash, the filing party, a category from a
closed enum, and two dates. `person-identity/07` is explicit: "No payload, no
narrative, no performance content, no cause description", with an AC asserting no
schema path exists to store any of it. An operator therefore cannot review the
finding and must never appear to. The available outcomes are **same person**,
**not the same person**, and **cannot determine**; the screen states on its face
that no finding details exist by schema; and nothing on it is phrased as a
judgment about the person. Offering approve and reject over a person flagged for a
finding nobody on the surface can see invites the operator to supply the missing
judgment, which is exactly the shape the AEPD fined Goldcar over, a flag that
"does not refer with certainty to a fraud committed by the claimant". Decision 014
spent an entry avoiding it and two button labels can reintroduce it. This surface
also sits behind its own access tier: the population is people flagged for safety
findings, and the category enum alone is sensitive.

**Two roles, admin and operator.** Admin administers the console: access,
configuration, role grants. Operator works the queues. `steward` survives as the
name of the act rather than a role, so decision 013's two-steward rule reads as
two operators and no ratified prose or mechanical AC changes wording. Two rules
are mechanical rather than policy: the two approvals on a merge must be distinct
natural persons, and an admin who acted on a case may not be an approving operator
on that same case.

**The operator's own name is on screen before the action.** Layer criterion 2
requires every console action land as an append-only event with actor attribution.
Attribution discovered afterwards is an audit feature. Attribution read while
deciding is a design feature, and it is the cheapest deterrent available.

**No proactive duplicate disclosure leaks through the console.** Decision 013 and
`person-identity/05` forbid any worker-facing surface revealing a candidate match.
The console is not worker-facing, and support tooling reading from it is one paste
away from being so. Anything a support agent can copy must survive being read by
the worker.

**It runs at `ops.grainidentity.com`** (decision 084), on its own origin rather
than sharing one with the party console: the two hold different account kinds in
different schemas, and one origin would leave that separation at the database
without it ever reaching the browser. Public, behind the same CDN and WAF as
everything else, with decision 083's passkey as the lock. Decision 038 already sent the
attester flow to the web, and a native console would owe `app-shell` work that
buys nothing here.

## 5. What the console cannot prove, stated rather than discovered later

Decision 015 rules that the operator holds a single registry self-entry,
`custody_model: ledger_kms`, "enforced unique by a partial index, one row,
structurally", and that no code path invokes a registry-grade key other than that
one. There is therefore no per-operator signing key. Two operators approving a
merge produces one signature from one organisational key with two names as
attributes inside the payload.

Internally that is auditable: the approvals sit in the append-only event stream,
and decision 019 put privileged operator actions and governing events into the
chained and anchored set. Externally it is unfalsifiable. Nothing cryptographic
distinguishes two operators approving from one operator writing two names.

**So the two-operator rule is an internal control, not an external proof**, and
the design does not imply otherwise anywhere on screen. Per-operator keys held
outside the registry path are the hardening if a partner or a regulator ever
contests a merge, and they are cheap precisely because they never touch the
registry-grade path that 015's invariant protects. Not built now, named now.

## 6. Banned specifically here

Beyond the standing list, the console attracts these and they are refused:

- Stat cards across the top of any queue. See §4.
- Severity by colour, red, amber and green. The state grammar carries severity by
  line quality, and an alert board is where an accent gets smuggled in.
- Bulk approve, select-all, or any control whose purpose is acting on cases the
  operator did not open. Bulk defer is arguable; bulk approve is not.
- Terminal cosplay for the internal-tool register: monospace body, all-caps
  labels, dense data-table aesthetics as costume. Cluster B, and this is the
  surface most likely to reach for it as a shortcut to looking serious.
- A notification bell or an inbox count badge, which turn an alarm into ambient
  noise an operator learns to dismiss.
- Approve and reject as labels on the safety-marker surface. See §4.

## 7. The three questions, answered for this surface

Per [`01-banned-patterns.md`](01-banned-patterns.md), binding on every element.

1. **Provenance.** The console exists because rulings refuse automation: no merge
   over attested history without review, no auto-suspension on allowlist absence,
   no denial on a marker match. Every screen is a place the product deliberately
   chose a human, so every element answers to that choice or it is decoration.
2. **Cluster distance.** With the wordmark cropped, an operator queue is the
   easiest Grain surface to mistake for generic SaaS. §4 and §6 are the defence,
   and this is where review should be hardest.
3. **Variation.** Adjudication and monitoring take opposite treatments, and the
   adjudication surfaces vary by what the operator is actually deciding rather
   than by decoration.

## 8. What is recorded, and what is still open

The design gates this brief's first draft carried are closed and recorded.
**Decision 077** carries every ruling in §1 to §6: the layer's move to
`first-product`, the scope absorbing every steward surface, the admin and
operator roles, the evidence extract, the read-log resolution, the safety-marker
rule, the throughput refusal, and the single-key limitation in §5. **Decision
078** carries the milestone move that reaches past this layer.
`plans/operator-console/LAYER.md` and `plans/ORDER.md` are amended to match.

What remains open:

**`first-product` has no exit test.** Decision 078 withdrew the verification
exclusion, which removed the premise of `ORDER.md`'s second-read test, and ruled
no replacement. `ORDER.md` now declares the gap rather than hiding it. Nothing in
this layer is blocked by it, and the milestone has no condition for having
produced a product rather than a demonstration.

**Two questions decision 078 deliberately left open**, both older than it:
whether anything can be sold without the worker's deletion right in force, given
founder ruling R2 and `consent-and-deletion` still at `draft`; and what
worker-facing surface exists at `first-product` when `worker-surface` is `draft`.

**Deletion oversight and safety-marker review cannot be drawn against a settled
plan yet.** Both are gated on `consent-and-deletion`, which has a `LAYER.md` and
no authored tasks. §4's marker rule binds whenever they are drawn; the rest of
those two surfaces waits.

**Per-surface treatment for dispute administration and party vetting** is
execution rather than a gate, and resolves in the artboards against this brief.
