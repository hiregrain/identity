# The operator console information architecture

Written 2026-08-21, after the first drawing pass produced a navigation nobody
could read. This is what the console *is*: its structure, its surfaces, what
sits on each, and what state each one owes. It is not a spec.
`plans/operator-console/LAYER.md` owns the scope and `DESIGN.md` owns the
grammar.

Companion documents: [`../DESIGN.md`](../DESIGN.md) ·
[`15-operator-console-brief.md`](15-operator-console-brief.md) (the design
intent this implements) · [`01-banned-patterns.md`](01-banned-patterns.md) ·
[`../plans/operator-console/LAYER.md`](../plans/operator-console/LAYER.md).
Modelled on [`06-worker-app-ia.md`](06-worker-app-ia.md), which is the document
the first console pass skipped.

Rulings are decision 077 unless another entry is named.

---

## 1. Structure

**The console is a rail and a pane.** The rail answers which queue you are in.
The pane answers everything else. Nothing else navigates.

The first pass stacked a masthead, a tab strip and a case bar, all horizontal,
two of which answered different questions. A reader cannot tell which of three
identical bars means *where* and which means *how deep*, and the whole thing
read as chrome rather than as structure. Splitting the two questions onto two
axes is the fix, and it is why the rail is worth its 220px.

**Decision 048 does not reach here and its reasoning argues the other way.** It
refused a tab bar for the worker app because "the destination count is two, not
five" and "tabs are paid for by switching, and there is none here", measured on
an Android safe box of 728dp. The console inverts every term: the destinations
are the queues, switching between them is the job, and a desk browser has
horizontal room a phone does not. 048 scopes itself to v1 of the app in its own
last line.

**The rail is grouped, not just divided.** `15` §2 argues that adjudication and
monitoring want opposite treatments, which a 1px divider in a horizontal strip
states too quietly. The groups are labelled **Decide** and **Watch**, and the
label is the argument made visible.

**A queue says it holds work and never how much.** A count on a surface where
cases are decided is what `15` §4 refuses, for the reason the layer gives:
operator decisions feed the matcher as labels, and anything that makes an
operator feel measured teaches them to agree with the matcher. Presence is a
filled square in the state grammar. Queue depth and latency are real and live on
an operations surface.

**No left indicator bar.** `01-banned-patterns` names that device twice and
calls a left rail the laziest hierarchy device available. The active item takes
the paper of the pane beside it and cuts through the rail's own border, so it
reads as joined to what it opened. The rail sits on `--page` and the pane on
`--paper`, both existing tokens, no new colour.

## 2. Surface inventory

| Surface | Group | Reached from | Kind |
|---|---|---|---|
| **Merges** | Decide | the rail | destination |
| A merge case | | a candidate row | pushed |
| Both records in full | | a case, by request | pushed, logged |
| A re-assignment | | a re-assignment row | pushed |
| **Parties** | Decide | the rail | destination |
| A party, in three views | | a party row | pushed |
| **Markers** | Decide | the rail, when granted | destination |
| A marker match | | a match row | pushed |
| **Disputes** | Watch | the rail | destination |
| A dispute case | | the exception section only | pushed |
| **Deletions** | Watch | the rail | destination |
| A stuck deletion | | an alarm row | pushed |

Nothing on this table is reached from anywhere except the rail and its own
destination's list. There is no cross-queue link, no global search, and no
recently-viewed. An operator arrives at a case because a queue put it in front
of them, which is what makes the queue the record of what was decided and why.

## 3. Depth reads off the chrome

One rule, and it is the whole navigation model:

- **No case bar: you are at the top of a queue.** The rail is the only chrome.
- **A case bar: you are inside something.** It names where back goes, so back
  reads "Merges" rather than a bare chevron that could mean anywhere.
- **A case bar naming a case: you are one level below that case.** Only the
  escalation reaches here, and it is the only screen that opens a full record.

Depth stops at three. Nothing in the scope needs a fourth, and a fourth would
mean an operator could get somewhere they cannot describe.

## 4. Merges

Two lists under one destination, separated by section heads rather than by a
sub-navigation. Both are adjudication and both act on the same object, so a
segmented control would add a control to answer a question the section heads
already answer.

**Candidate pairs.** Ranked by match weight, which orders the list and is never
printed on it. The row carries the two names, the approval gradient, and how
long the case has waited. No number, no checkbox, no bulk control.

**Re-assignments after an unmerge.** `person-identity/06` requires that
attestations issued against the survivor during a merged window surface for
re-assignment, and until now no layer owned that queue. It belongs here because
it is the residue of a decision made here.

**The case.** Evidence extract by default: the matched signals with their
per-signal contributions, name variants, chapter shapes and dates. The two
triage signals sit inside a labelled fence at full contrast, never faded,
because law 8 forbids drawing a weaker claim as a fainter one. The approval
gradient is a rendered state, not a setting: two approvals where both records
carry verified attestations, one otherwise (decision 013).

**The escalation.** The only place a full record opens, and a deliberate step
rather than a default. It is logged as a read of both records and disclosable to
either worker on request. It carries no decision at all, which is what keeps the
decision on the case screen where the extract is.

## 5. Parties

**Nothing here creates a party.** Registration, party logins, keypair
generation, the sandbox and the conformance run are self-serve on the partner's
side, because `integration-surface`'s own success measure is that the second
partner integrates without talking to us. The operator holds the middle of that
pipeline and nothing else.

**There is no access to grant.** The party generates its keypair in its own
environment and proves possession against a single-use nonce before anything
registers, so the console holds a public half and never a private one. Party
logins are hardware-bound WebAuthn with no static API key anywhere in the path.
What an operator grants is a capability, one at a time, revocably.

**A party has three views**, switched from the case bar rather than the rail,
because the switch moves you inside one thing rather than between queues.
Overview carries lifecycle and, for a party still `pending`, the two activation
gates. Capabilities carries the grants and their append-only history. Keys
carries key validity, traffic against the declared cap, the conformance run and
the monthly countersignature.

**Both activation gates are asked live and neither is a checkbox.** The
witnessed-log limb queries the kernel on every load, with no stored boolean,
because a cached flag is one write away from being flipped under deadline
pressure. The legal limb validates the executed instrument field by field rather
than pointing at it. Activation is genuinely closed while either fails, drawn
with the chassis's dashed disabled treatment, and going ahead anyway takes a
signed governance event. Parking a party in `pending` is not a way around it:
the clock starts at `pending` and the screen keeps reporting it.

**The vetting queue**, and one distinction the surface may never blur. Decision
015: falling off an accreditation allowlist freezes new writes and flags a
human, never auto-suspends, because external registries carry name changes and
data errors at rates that would take legitimate parties offline. A frozen party
stays `active` and under no finding.

Frozen and suspended therefore take different line qualities and different
words, and the frozen state says on its face that no finding has been made. Tier
is a category, cap is a number with a unit, reliability is a set of signals with
their contributions. None of them composite, and none leave the console.

## 6. Markers

**Separately granted, and absent from the rail for operators without the
grant.** The population is people flagged for safety findings and the category
enum alone is sensitive.

**The match screen decides identity and nothing else.** `person-identity/07`
limits a marker to a keyed document hash, a filing party, a category and its
dates, with an acceptance criterion asserting no schema path exists to store
finding details. So the operator cannot review the finding and must never appear
to. Outcomes read *the same person*, *not the same person*, *cannot determine*.
The screen states on its face that no finding details exist, and routes the
question to the filing party, who holds the finding and receives the worker's
challenge.

Nothing here closes an account. The match already produced a usable-restricted
account and the marker expires on a clock no surface can extend.

## 7. Disputes

**A state view, not a work queue.** Deadlines fire notifications and state
transitions without operator polling, so drawing this as a queue would invent
work the layer's third criterion exists to eliminate.

Two sections. **Waiting on a person** carries the exceptions, and it is the only
part of the screen with a control: an unresponsive issuer, a deadline about to
close. **Running on their own** states facts, so those rows carry no chevron and
no hover, which is the chassis rule that a fact dressed as a control lies about
what can be changed. Clocks use the closing band, for the one case where the
length is genuinely known.

## 8. Deletions

**An alarm surface, and the only one whose correct state is empty.** Saga
progress, copy-map acknowledgment, and the reconcile watcher
`consent-and-deletion` inherits for the window where a person is journaled as
deleted but still readable.

The design goal is not throughput and not review. It is that a stuck deletion is
impossible to miss on a screen an operator glances at and leaves. That makes the
empty state the primary state, and it must read as correct rather than as
broken.

## 9. What every surface owes

The chassis draws these once and no screen invents a second version.

| State | What it must not do |
|---|---|
| Loading | claim a duration. The scribing arc, no percentage |
| Empty | read as failure. A queue with nothing waiting is the good outcome |
| Error, with a retry | lose the case an operator was working |
| Grant absent | appear at all, on Markers. The rail omits it |

**The empty state carries the most weight and is the least drawn.** For every
adjudication queue, nothing waiting is the correct end state, and for Deletions
it is the normal one. A queue that renders emptiness the way a failed load
renders trains operators to distrust it.

## 10. Drawn, and not

Artboards live in [`16-operator-console`](16-operator-console/), built from
`tpl/` by `build.py`, which pulls the chassis from `10-worker-app-screens` so
the console cannot drift from `_shared.css`.

| Surface | State |
|---|---|
| Merges, the queue | drawn |
| Merges, nothing waiting | drawn |
| Merges, a case, at all three approval stages | drawn |
| Merges, first approval recorded | drawn |
| Merges, the escalation | drawn |
| Parties, the queue | drawn |
| Parties, a frozen party | drawn |
| Parties, the activation gates | drawn |
| Parties, capability grants | drawn |
| Parties, keys and sync health | drawn |
| Markers, a match | drawn |
| Disputes, the state view | drawn |
| Merges, unmerge and its re-assignment case | not drawn |
| Markers, the queue | not drawn |
| Disputes, a case | not drawn |
| The escalation's reason capture | not drawn |
| Deletions, both levels | blocked, see below |
| Loading, and error with a retry | not drawn |
| Sign-in, and the verified assertion on an appending act | not drawn, ruled by 083 |
| Creating an operator, as a two-admin act | not drawn, ruled by 083 |

**Deletions is the one destination in the rail that goes nowhere**, and it is
blocked rather than skipped: `consent-and-deletion` is `draft` with no authored
tasks, so there is nothing settled to draw against. It is the costliest absence,
because it is the surface whose entire design goal is the glance.

**Drawing the two-operator flow changed the case screen**, which is the reason
that flow was drawn first. The primary control cannot carry both meanings: for
the first operator it records an approval and returns the case to the queue, and
for the second it executes the merge. Same control, opposite consequence, so the
label and the sentence above it are bound to the stage rather than fixed.

## 11. Open

**`15` §1's organising idea needs replacing rather than patching.** It reads
"the evidence comes before the action, on every screen, always", and then §4
concedes that a marker match has no evidence and cannot obey it. An idea with an
exception clause for one of its own surfaces is a generalisation. The sentence
that covers every surface without one is **every screen names exactly what it
can and cannot determine**, which is also what the marker screen already does.
Proposed here, not yet applied to the brief.

**The design checks do not reach this directory.** `checks/design-system.mjs`
and `checks/artboards.mjs` both default to `design/10-worker-app-screens` and
crash when pointed here, because they expect that directory's own
`tpl/_shared.css` and its canvas manifest. So the console is covered by
`checks/unslop.mjs` alone, and nothing mechanically holds it to the type
registers or the spacing scale. `13-platform-screens` and `14-web-app` appear to
have the same hole. Closing it is a checks task, not a design one.

**No operator-side issuance view is ruled.** `party-registry/08` gives the
issuance feed to the party: read-only, party-scoped, reachable only by that
party's principals, with no cross-party visibility in any query path. Nothing
grants the operator an equivalent, which holds until a dispute needs a specific
entry investigated. That is the precise place the roster firewall gets tested,
since an operator view rendering per-party issuance against subjects would
reconstruct the correlation pairwise pseudonyms exist to prevent. The Keys view
currently sends an operator to ask the party instead, which is an answer that
works and has never been ruled.

**Operator authentication is ruled** (decision 083) and undrawn. Operators are a
third kind of account in their own schema, unlinkable to persons by the same
invariant `party_users` uses. Authentication is Grain's own, with no external
identity provider on the console path. Passkeys, synced ones permitted, with user
verification required on every act that appends: approving a merge, activating a
party, granting or revoking a capability, recording a signed slip. Reads ride the
session, the escalation to a full record included.

Two consequences the surfaces have to carry. **Recusal is self-declared and
unenforceable by construction**, so wherever an operator can step away from a case
there is a declaration to capture rather than a check to pass. And **creating an
operator is a two-admin act**, which is a console surface nothing has drawn and
which sits behind the admin role rather than the operator one.

**Deletions and marker review cannot be drawn against a settled plan yet.** Both
are gated on `consent-and-deletion`, which has a `LAYER.md` and no authored
tasks. §6's ruling binds whenever the marker screen is drawn. The rest waits.
