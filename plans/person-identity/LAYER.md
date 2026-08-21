---
id: person-identity
type: layer
status: ready
milestone: first-product
depends_on: [foundation]
binds:
  - design/ledger-design-0.1.md#1
  - research/03-person-id-and-merge.md
  - decisions/LOG.md#013
  - decisions/LOG.md#014
  - decisions/LOG.md#016
  - decisions/LOG.md#017
  - decisions/LOG.md#019
  - decisions/LOG.md#020
evidence: []
verified_by: null
---

# person-identity

The person: ID issuance, auth, dedup, merge.

Scope: opaque `ledger_person_id` issued instantly at self-signup (random
UUIDv4, decision 075), never reissued or recycled, tombstoned on
deletion; passkey-primary worker auth with OTP fallback; account recovery
that must re-clear the account's derived assurance level, with time-locks
blocking takeover-then-delete destruction; phone/email as decaying channel
signals, never anchors; multi-field probabilistic duplicate detection
(Fellegi-Sunter) with candidate scoring; merge/unmerge as append-only
events with the permanent alias table, attestations keep their original
`subject_id` forever, resolution through the alias closure at read time;
mandatory human steward review before any merge touching attested history
(the review UI lands in `operator-console`); **nothing survives deletion by
default, with one severity-gated safety marker as the exception** (decision
014 superseding 009a), matching a live marker yields a usable-but-restricted
account pending review, never a denial, so this is not a clean fresh start
and is not described as one; anti-fraud scoped to concurrent
multi-accounting and synthetic identity.

Acceptance:
1. **A merge can be undone with nothing mutated in the process.** (mechanical) merge → unmerge round-trips with zero mutation of
   either event stream; reads through the absorbed ID resolve correctly in
   both states.
2. **Recovering a verified account re-clears the same bar it first cleared.** recovery of a document-verified account requires re-clearing
   document verification; a fresh SMS OTP alone cannot take the account,
   **including through ordinary login**, since sensitive operations require a
   session whose assurance matches the account (decision 020).
3. **Nothing auto-merges when either side carries a safety marker.** (mechanical) no auto-merge executes where either profile carries
   attested history.
4. **Deleting without a marker means re-signup is genuinely clean.** (mechanical) deletion with **no marker** → re-signup is truly
   clean; nothing keyed to the person exists anywhere in spine or payload.
5. **Re-signup against a live marker is usable, and restricted.** re-signup matching a **live marker** → usable-but-restricted
   account pending steward review; no code path converts the match into a
   denial.
6. **An expired marker is a clean slate, and expiry is not a loophole.** (mechanical) re-signup matching an **expired marker** → clean;
   the marker is inert on every path.
7. **A prior merge in the history leaks nothing on re-signup.** (mechanical) a **prior merge** in the history does not leak
   across a deletion; the alias closure is destroyed with the person.
8. **A merge appends to both chains, and neither can be quietly dropped.** (mechanical) a merge appends to **both** subject chains, and a
   deletion of a merged person destroys every DEK in the alias closure.
