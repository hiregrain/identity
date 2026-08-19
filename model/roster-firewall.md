# The Roster Firewall — 0.1 PROPOSED

The boundary between a vertical's operational data about its own workforce and
the ledger's record of a person. Companion to `attestation-interface.md`, which
governs what crosses between the ledger and a vertical; this governs what may
reach that crossing at all.

Proposed 2026-08-19 under decision 032. Not ratified.

---

## The rule

> Roster data serves the employer's operations. It becomes a worker's record only
> when the worker pulls it. What crosses is an attestation, never a copy.

## 1. Two planes

**Vertical plane.** An employer's operational data about its own workforce,
synced from its HR or staffing system. The employer is the controller; Grain is
a processor acting on the employer's instructions for the employer's own
staffing purpose. Employer-scoped, never joined across employers.

**Ledger plane.** The worker's record. The worker is the subject; Grain is the
controller. Every object is chained to a `ledger_person_id` that exists because
the worker created it (universal self-signup, no proofing gate).

This document governs crossings. There is exactly one, at §4.

## 2. What the vertical plane may hold

Per employing party, from a roster sync: team-member identity as the employer
holds it, role, employment start and end, employment status, schedule,
availability, shift assignments, and whatever else the employer's own operations
require.

- **Employer-scoped.** Rows carry the employing party and are never joined,
  counted or compared across employers.
- **No ledger identity.** No `ledger_person_id` is assigned to a roster row and
  no roster table may hold one.
- **Employer-instructed retention.** Rows are deleted on the employer's
  instruction and on termination of the employer relationship. Grain sets no
  independent retention period because Grain has no independent purpose.

## 3. Permitted and prohibited uses

**Permitted.** Running the employer's own operations — openings opening and
closing from team state, scheduling, the employer's own team views; showing the
employer its own roster, which it already holds; carrying the employer's
invitation to its own staff (§6).

**Prohibited, without exception.**

- Showing a roster row, or anything derived from one, to any other employer.
- Feeding any ranking, matching, analytics, recommendation or trust computation
  for any party, **including the supplying employer**.
- Joining roster rows across employers, or counting them toward any graph,
  corroboration measure or standing derivation.
- Creating a ledger person, an attestation, or any cross-employer artifact from
  a roster row.
- Being consulted by the ledger plane for any purpose.

The prohibition on feeding the supplying employer's own ranking is deliberate
and is the non-obvious one: roster data is held under the employer's
instructions for staffing operations, and ranking candidates is a different
purpose from operating a team.

## 4. The crossing

The only lawful path from vertical plane to ledger. Six steps; the order is
load-bearing.

1. **The worker holds a Grain identity**, created by them at self-signup.
   `ledger_person_id` exists because they made it exist.

2. **The worker names the employer**, asserting a chapter — employer, role,
   dates — which enters the record as `self_asserted`. At this point it is the
   only object that exists.

   **Grain may not prompt this from roster knowledge.** Surfacing "this employer
   is connected — is this you?" requires knowing the worker appears on that
   employer's roster, which is the crossing this document forbids. The worker
   names the employer unprompted, or selects from a list of connected employers
   shown identically to everyone. Without this constraint the firewall leaks at
   the first screen, and it leaks in a form that reads as a feature.

3. **The worker requests verification.** The request is the crossing trigger:
   worker-initiated, timestamped, carrying a `verification_request_id`. That id
   is the auditable evidence of worker initiation and every downstream object
   binds to it.

4. **The employer is asked to confirm.** Their connected system answers against
   their own roster, or a human at the employer answers. Grain does not answer
   on the employer's behalf from a store it holds for them.

5. **The employer signs an attestation** — `party_attested`, scope `period`,
   chained to the worker's `ledger_person_id`, carrying the
   `verification_request_id`.

6. **The attestation crosses; the roster row does not.** The row stays in the
   vertical plane and is never itself a ledger object. This preserves the
   no-shadow rule in both directions: the ledger holds attestations about work,
   never the work, and the vertical keeps no shadow of the ledger.

## 5. What an employer may see about a worker

- **Its own roster:** everything it holds, which it already holds.
- **Any other worker:** only what a live worker grant discloses, generated at
  read time as a prior packet — never stored, never edge-cached
  (`attestation-interface.md`, down direction).
- **Never:** that a candidate appears on another employer's roster, or any
  inference derived from roster data it did not supply.

## 6. Invitations

An employer may invite its own staff to Grain. That is an employer contacting
its own employee, which it may do, and it is the vertical's acquisition channel.

The invitation names the employer and states that a record can be claimed. **It
carries no worker-specific content beyond addressing** — no employment dates, no
role, no assertion about the person. The moment it carries record content, Grain
is asserting something about a non-user and the boundary has been crossed by the
message rather than the database.

## 7. Enforcement

Mechanical, following the precedent this repo already trusts: Dispatch's AC-04.3
schema-grep banning capability-score columns on fact tables, and grain's
shadow-log promotion gate. A firewall enforced by convention is not a firewall.

| # | Check | Fails on | Owning layer |
|---|---|---|---|
| RF-1 | Plane separation at the schema — roster and ledger tables in separate schemas, **no foreign key from any roster table to `ledger_person_id`** | any such constraint appearing | `foundation` (04 two-plane split, 06 checks port) |
| RF-2 | Worker initiation required — ingestion validation rejects any attestation with employer-roster provenance lacking a live `verification_request_id`; no write path accepts a roster row as a source of truth | any roster-derived write without the id | `ingestion` (`ingestion` criterion 5) |
| RF-3 | Analytics input allowlist — roster tables are not on it | any addition to the input set | `analytics` |
| RF-4 | Cross-plane join ban | any query joining a roster table to a ledger table | `foundation` (06 checks port) |
| RF-5 | Invitation payload schema-constrained to employer identity plus addressing | any worker-specific field | `integration-surface` (`integration-surface` criterion 5) |

RF-1 and RF-4 are grep-class checks over schema and query text and belong with
the other repo-metadata checks that run before any database boots
(`plans/foundation/01`). RF-3's allowlist is authored when `analytics` goes
ready; until then the constraint lives here and in decision 032.

## 8. Costs, stated

Cold start is slower: no pre-built records waiting to be claimed. Verification
latency depends on the employer's system being connected and responsive — the
fast confirmation is the good case, not the guaranteed one. An employer cannot
be told that some of its applicants already hold verified history elsewhere
unless those workers granted it.

## 9. Open

1. **Two production schema values now read wrong.** `method: 'employer_roster'`
   and `confirmedVia: 'roster_attestation'` exist in the hospitality product's
   `WorkHistoryVerification` today and imply employer push. Under this document
   they mean *confirmed against the employer's roster in response to a worker's
   request*. Rename or documented reinterpretation, plus the RF-2 gate.
2. **The negative answer is undesigned.** A worker asserts a chapter at a
   connected employer and the roster returns no match. Silence, dispute, or a
   stated non-confirmation — each has a different failure mode, and the third is
   the one most likely to injure a worker telling the truth about an employer
   with poor records. Counsel brief 5, question 5.
3. **Partial and stale rosters.** An employer connected in 2026 holds no rows
   for someone who left in 2023, so a truthful worker receives a non-answer from
   a connected employer. This is likely the common case in hospitality and it
   compounds item 2.
4. **Colorado's correction rule still bites.** 4 CCR 904-3 Rule 4.06(D)(4): an
   employer attestation is still not data received from the consumer, so a
   Colorado worker's bare assertion of inaccuracy establishes it absent
   documentation. Collides with R2 regardless of this document. Counsel brief 5,
   question 6.
