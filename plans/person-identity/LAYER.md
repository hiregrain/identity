---
id: person-identity
type: layer
status: ready
milestone: v1
depends_on: [foundation]
binds:
  - design/ledger-design-0.1.md#1
  - research/03-person-id-and-merge.md
  - decisions/LOG.md#009
acceptance: [AC-PI1, AC-PI2, AC-PI3, AC-PI4]
evidence: []
verified_by: null
---

# person-identity

The person: ID issuance, auth, dedup, merge.

Scope: opaque `ledger_person_id` issued instantly at self-signup (UUIDv7
with hot-range-safe layout), never reissued or recycled, tombstoned on
deletion; passkey-primary worker auth with OTP fallback; account recovery
that must re-clear the account's derived assurance level, with time-locks
blocking takeover-then-delete destruction; phone/email as decaying channel
signals, never anchors; multi-field probabilistic duplicate detection
(Fellegi-Sunter) with candidate scoring; merge/unmerge as append-only
events with the permanent alias table — attestations keep their original
`subject_id` forever, resolution through the alias closure at read time;
mandatory human steward review before any merge touching attested history
(the review UI lands in `operator-console`); no identity-evidence retention
across deletion (decision 009a); anti-fraud layer scoped to concurrent
multi-accounting and synthetic identity, never fresh-start prevention.

Acceptance:
- AC-PI1 (mechanical): merge → unmerge round-trips with zero mutation of
  either event stream; reads through the absorbed ID resolve correctly in
  both states.
- AC-PI2: recovery of a document-verified account requires re-clearing
  document verification; a fresh SMS OTP alone cannot take the account.
- AC-PI3 (mechanical): no auto-merge executes where either profile carries
  attested history.
- AC-PI4: after profile deletion, re-signup with the same phone/documents
  yields a clean cold-start profile and no linkage artifact exists.
