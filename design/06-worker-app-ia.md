# The worker app — information architecture

Settled 2026-08-19 (decision 041). This is what the app *is*: its structure, its
surfaces, and what sits on each. It is not a spec — `model/record-schema.md`
owns the fields and `DESIGN.md` owns the grammar.

Companion documents: [`../DESIGN.md`](../DESIGN.md) ·
[`05-worker-surface-brief.md`](05-worker-surface-brief.md) (the design intent
this implements) · [`01-banned-patterns.md`](01-banned-patterns.md) ·
[`../plans/worker-surface/LAYER.md`](../plans/worker-surface/LAYER.md).

Where a ruling here supersedes an earlier document, decision 041 §B says so.

---

## 1. Structure

**The record is the app.** There is no tab bar at v1 and no Activity surface.

The argument for an Activity destination is that the layer requires notification
of reads, new attestations and dispute deadlines. The argument against it, which
wins, is that every one of those events already has a home on the record: a read
is grant state in Sharing, an attestation blooms the chapter and drops it out of
outstanding verification, a dispute marks the chapter. The ceremony *is* the
notification, and it is a better one than a list item. A destination that is
empty most of the time trains people to ignore it.

Unseen changes surface three ways: the record's own changed state, the plate
footer's last-entry line, and an OS push that deep-links to the changed object.
No badge, no dot, no count bubble.

**Work and Earnings are reserved as the third and fourth destinations.** The
bottom bar appears when they exist; nothing above it moves, because the record's
edge index is intra-record navigation and is unaffected. Earnings is a read-only
view over a vertical's or a licensed partner's payment records for as long as
`research/08` §5.2 C1 holds — that constraint is posture, not ruling (decision
010), so the slot is reserved and nothing is designed into it.

## 2. Page inventory

| Surface | Reached from | Kind |
|---|---|---|
| **Record** | app launch | destination |
| Chapter detail | a work-history row, or a ring on the figure | pushed |
| Dimension standing | chapter detail | pushed |
| Imprint, expanded | the figure | full-screen |
| Public profile | Sharing | pushed |
| Grant detail | Sharing | pushed |
| Settings | the Record header | sheet |
| Onboarding | first open, or a shared link | own stack |

## 3. First open

    identifier  →  name  →  consent  →  [account exists]  →  empty record
                →  first chapter  →  handle

**Identifier.** Email *or* phone, verified control of one, neither a uniqueness
key (`research/11` Part A: phone is a strong access barrier and a weak
uniqueness constraint in exactly the markets targeted, which is the wrong trade
in both directions).

**Name.** One free-text Unicode field labelled "Full name". No surname
requirement, no two-token requirement, no script rejection (`research/11` Part
B). The name renders at full size in its own script everywhere it appears.

**Consent.** One instrument, six mechanics, as ledger rows — parties write
signed append-only attestations; verification freezes the claim; disclosure is
party-level; dispute rights; the deletion right; what a receiving party may
retain (`design/ledger-design-0.1.md` §8.2). The deletion control is linked from
the instrument, so the exit is seen once before anything is put in.

**Document proofing appears nowhere in signup.** It is gated to the first
value-bearing action. The single coldest moment in a normal signup is therefore
absent from this one, which does more for the brief's "make it feel safe" than
any copy could.

**Arriving from a shared link** runs the same flow and unlocks at account
creation: the visitor lands on the profile they came for, and the empty canvas
is what they meet on leaving it. Seeing a real record before your own is a
better introduction to the empty state than arriving cold — and since attesting
requires an account, this is the path most people will take into the product.

## 4. The record

Order (amends decision 028):

1. **Identity and imprint, composed** — name and portrait with the figure.
   `DESIGN.md` §8 already pairs them; this makes the pairing the hero rather
   than splitting them to opposite ends of the scroll. 028 put identity last on
   the reasoning that it is settled once and then irrelevant. That is true of
   the returning user and false of the new one.
2. **Outstanding verification** — the rings that have not bloomed.
3. **Work history** — ledger rows, positions as divisions inside the chapter.
4. **Sharing** — the public page, and every grant with its state.

**Audience lives on the object.** A chapter carries a mark *only while a live
grant covers it*, and shows nothing when nobody can see it. Silence when
private, a mark when exposed. That puts the answer to "who can see this" where
the anxiety is, and keeps the default record clean.

**The expanded imprint** closes `imprint/README.md` §7.1 — the missing angular
anchor, recorded there as "a hole in the most valuable channel, not a polish
item." Full-screen and interactive: dimension slots light one at a time under
touch, carrying the name and the attained level; tapping a ring walks that
dimension outward across the whole career, which is what permanent angular
registration was built for. **The small figure stays unlabelled.** Labels earned
by interaction are not a legend; printed ones remain banned.

**Dimension standing** is one step past chapter detail. `05` §2 rules it off the
core screen as the most interpretive object in the product; it is never a tab
and never a landing surface.

**No dispute UI.** The chapter renders its `disputed` field because that is a
record value. Intake and adjudication sit outside the app.

## 5. The public profile

**Address.** `hiregrain.com/u/<handle>`. A dedicated identity domain is a
possible pre-launch requirement; the never-reissue rule below makes a later 301
free.

**Handle.** Latin-only `[a-z0-9-]`, prefilled by auto-transliteration of the
person's name and never rejected — the field arrives already populated, so the
moment reads as *here is your link, change it if you like* rather than *your
name does not work here*. Claimed in onboarding **after** the record exists: no
handle without a record, which also kills bulk squatting for free.

**Changeable, never released.** A retired handle redirects permanently to the
same person and is never reissued to anyone. Both halves are load-bearing.
LinkedIn, X, Instagram and GitHub all release handles back to the pool — correct
for a social address, wrong for one that points at a permanent work record used
in hiring, where release is an impersonation vector. Immutability is equally
wrong: `research/11` requires name changes be appends with prior names never
surfacing in employer-visible views, and an immutable handle is a prior name in
the URL forever. Collision alternates are non-numeric.

**Contents.** Whole record or no record. There is no per-chapter curation on any
surface — the one lever is the imprint, full or absent, nothing between.

**Indexing and access.** Always indexed. Crawlers and logged-out visitors get a
reduced page: name, verification status, chapter list without detail. **The
imprint is always behind sign-in**, even when published, because an indexable
imprint is the seven-dimension exposure at its widest. Viewing requires an
account.

**Views.** A recent count, never viewer identities. Naming viewers turns the
page into a social product and creates the coercion hazard `05` §3 records for
Dubai and Bengaluru: a current employer's name appearing there tells a worker
they have been noticed looking.

## 6. Private sharing

A grant is **whole-record, always**. The public page and a grant divide by
**depth, not selection**:

| | Public page | Grant / share link |
|---|---|---|
| Chapters, parties, dates | yes | yes |
| Provenance state | yes | yes |
| The imprint | worker's choice, behind sign-in | yes |
| What each party attested | no | yes |
| Dimension standing | no | yes |
| Dispute state, superseded versions | no | yes |

One states what is true; the other states what was said, and by whom. Neither is
curated.

Expiry is mandatory. Revocation is one action and always reachable.

**The worker sees the grant's state — issued, active, expired, revoked — and no
read events.** This supersedes the full read log in
`design/ledger-design-0.1.md` §7.1/§8.1, `grant.last_read_at`, and `05` §3. A
read stream during a live application is an anxiety feed and surveillance of the
employer. **GDPR Art. 15(1)(c) is then satisfied by a disclosure record
available on request** — that is a required consequence of the ruling, not an
optional extra, and it has to exist somewhere.

**At creation the worker is told what the recipient gets**: full work-history
detail, and the ability to ask Grain to analyse it. Stated as what the recipient
receives — not as a warning, and not framed as a hazard.

## 7. Settings

A sheet from the Record header, not a destination — and **read-only**
(decision 036). Every account change is a support request.

- **Account** — full name, phone, email, identity tier, address. Shown, not
  edited. One route out of the group to support.
- **Identity** — opens the verification flow (§7a) at any time.
- **Notifications** — which events push
- **Language**
- **Your data** — request an export, delivered by email **within 24 hours**;
  the disclosure record that satisfies GDPR Art. 15(1)(c)
- **About** — version, terms, privacy
- **Deleting your record** — named here, routed to support. There is no in-app
  control. Access stops when the request is filed; erasure follows a grace
  period; **signing in during that period resets the request**, and continuing
  means filing a new one.

The right is named rather than hidden because the consent instrument promises it
at signup (`design/ledger-design-0.1.md` §8.2 item 5), and a promised right that
cannot be found is worse than one never offered. Decision 036 records the
Art. 12(2) exposure this carries.

## 7a. Identity verification

Two entry points: **self-serve from Settings at any time**, and **an employer's
request at application**. It is not gated to the first grant.

Storage is already settled by decision 010 and `research/08`: results-only vendor
integration, no document images ever in the ledger, Sumsub as global primary with
Persona for the US, sanctions screening bought with only a signed pass/fail
stored and no hit detail. Four internal tiers — recorded, contact, document,
biometric — of which **only two surface to partners: identity verified, or not**.
The worker sees the internal tier, because the worker sees all raw facts.

Three steps:

1. **What happens, before anything is taken.** What is photographed, who takes
   it, what is kept, what is never kept, and what a partner will see. If an
   employer triggered it, the screen says who asked and what declining costs.
2. **Capture, in Grain's chrome, with the vendor named** on the screen where the
   document is taken. The worker is never handed to a stranger mid-flow.
3. **Result, and a separate liveness offer.** Liveness is declinable and comes
   *after* the document passes, so refusing it costs nothing already held —
   which is what decision 028's "biometric stays opt-in for a stated reason"
   requires in practice, given BIPA and the EU AI Act.

The name the document carries and the name the worker wrote are both kept and
neither replaces the other (`research/11` Part B, three name layers). The
worker's own `display_name` is what shows.

## 8. Accounts and attestation

**One account type.** Everyone holds one, with verified identity — including
attesters. This reverses 028's *"a signed link and one click, no account."* A
basic account is required to view; document tier remains the worker's own
identity-verified status.

**The attester ladder.** Weight derives from relationship and verified
employment, not identity tier:

| Attester | Established by | Weight |
|---|---|---|
| Coworker | an account | lowest |
| Manager | employment at the party verified by work email | middle |
| Partner employer account | party registration | full |

A manager verifying their work email is verifying **their own employment at that
party**. The same event employment-verifies their own chapter. Vouching for
someone verifies you, and that is the product's primary growth loop.

**The imprint geometry does not change.** Three thread densities stand; the
finer ladder lives in the rows and the expanded view. The figure states how well
something is known; the record states who said it. This also protects the one
channel `imprint/README.md` §7.4 records as never tested with humans at the size
it will be used.

## 9. Parties

A party is **named, never drawn** — record voice, with registry state as a
micro-caption: registered, unregistered, or suspended. No emblem, no logo. Every
human in the product is drawn as their own mini-imprint (`DESIGN.md` §9); orgs
are never subjects (decision 007) and get no mark. The absence carries meaning:
people are drawn, parties are named. Recorded as restraint, not as a gap.

## 10. Safety, expressed structurally

`DESIGN.md` §12 forbids the usual instrument — no exclamation points, no "you
matter", no reassurance cadence — so none of this is copy.

- **Permanence is shown before commitment, never after.** Every irreversible act
  in this product states its permanence at the moment of choosing.
- **Commitment is progressive.** No document at signup; proofing arrives when
  something is actually at stake.
- **The name renders correctly, at full size, in its own script.** `research/11`
  argues this directly: for a population credential systems routinely fail,
  never being told your real name is invalid is not a cosmetic concern.
- **The exit is visible before the entrance.** The deletion control is linked
  from the consent instrument at signup.
- **Audience is on the object**, so the answer to "who can see this" is never
  more than zero taps away.

## 11. Open

The identity domain. Money at entity level (decision 010). Whether the handle
becomes the display identifier `DESIGN.md` gap 3 leaves unchosen — it now exists
and nothing has decided this. Employer surfaces (gap 8). Companion typeface (gap
7). Dark mode (gap 6). The marks enum (gap 5).
