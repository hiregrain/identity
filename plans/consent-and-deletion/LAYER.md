---
id: consent-and-deletion
type: layer
status: draft
milestone: v1
depends_on: [person-identity]
binds:
  - decisions/LOG.md#036
  - decisions/LOG.md#038
  - decisions/LOG.md#040
  - design/ledger-design-0.1.md#2.5
  - design/ledger-design-0.1.md#8
  - counsel/brief-4-worker-agreements.md
evidence: []
verified_by: null
---

# consent-and-deletion

**Deletion mechanics settled 2026-08-19 across decisions 036, 038 and 040, and
they moved twice in one day, read all three.** The end state: deletion is a
**support-executed** process with an **in-app control that files the request**
(Apple App Review 5.1.1(v) requires in-app initiation; support-only is a
rejection) **and a web page that files the same request** (Google Play requires
both). Access stops the moment the request is filed; erasure follows a grace
period; **cancelling is an explicit affirmative act**, never a side effect of
signing in. The EDPB's deceptive-design guidelines name "dead ends" that
interrupt a deletion process, and a worker signing in to check on their deletion
must not thereby cancel it.

The consent instrument carries **seven** mechanics, not six (decision 038): the
seventh states that parties describe the worker's work on seven set measures,
that Grain derives a level from what they pick, and that it travels with every
grant and onto the public page if the imprint is published. A person agreeing
without that could not know they were consenting to be ranked.

The worker's two ultimate controls, engineered as subsystems.

**analytics/02 lands the named-recipient grant subset first** (decisions
057, 067): the grant table, address-proof open, expiry, revocation, and
the payload-side read log ship in the first-product milestone. This
layer builds the party-level standing-grant machinery on that table
rather than beside it; one grant object, one migration lineage, no
second read log.

Scope: the onboarding consent instrument (six-point plain-language
coverage per design 0.1 §8.2, contextual re-affirmation at each
verification request; final terms blocked on counsel brief 4, the flow
ships with placeholder copy, launch gates on returned terms); grant
machinery: party-level grant/revoke as append-only event pairs, immediate
effect on future reads, full read log; whole-profile deletion (R2):
anti-coercion confirmation window, immediate read stop + grant revocation,
payload purge within the published window, DEK destruction, spine
tombstones with no readable residue, party notification, provable
`payload_purged` event; the copy-map as code: every store a datum reaches
(replicas, WAL, backups, caches, exports) enumerated with per-copy deletion
SLOs and an acknowledgment saga; deletion propagation to derived state
(recompute, grain-pattern).

**Inherited requirement (foundation review, decision 052 context): the
journaled-but-readable window gets a watcher.** foundation/08's Destroy
commits the journal row before the payload shred; a crash between the two
leaves a person promised deleted in the permanent record but still
readable until a retry. This layer owns surfacing that state: a reconcile
check joining the deletion journal against the registry's destroyed rows,
with a threshold and a nonzero exit, in the shape core/outbox's reconciler
set. The 72-hour confirmation window (decision 052) is also implemented
here.

Acceptance:
1. **After deletion, a full scan of the database finds nothing left.** (mechanical) post-deletion, a full-database scan finds no
   readable personal data for the person; the tombstoned ID never reissues.
2. **Revoking a grant stops the very next read.** (mechanical) a revoked grant blocks the next packet read in the
   same second; the read log shows the denial.
3. **Every place data is copied is proven by a planted datum.** the copy-map is exercised by test. A datum planted in every
   enumerated store is gone within its SLO after deletion.
4. **Deleting during an open dispute still completes.** deletion during an open dispute completes; the dispute record
   survives only in unreadable spine form.
