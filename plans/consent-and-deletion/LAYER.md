---
id: consent-and-deletion
type: layer
status: draft
milestone: v1
depends_on: [person-identity]
binds:
  - design/ledger-design-0.1.md#2.5
  - design/ledger-design-0.1.md#8
  - counsel/brief-4-worker-agreements.md
acceptance: [AC-CD1, AC-CD2, AC-CD3, AC-CD4]
evidence: []
verified_by: null
---

# consent-and-deletion

The worker's two ultimate controls, engineered as subsystems.

Scope: the onboarding consent instrument (six-point plain-language
coverage per design 0.1 §8.2, contextual re-affirmation at each
verification request; final terms blocked on counsel brief 4 — the flow
ships with placeholder copy, launch gates on returned terms); grant
machinery — party-level grant/revoke as append-only event pairs, immediate
effect on future reads, full read log; whole-profile deletion (R2):
anti-coercion confirmation window, immediate read stop + grant revocation,
payload purge within the published window, DEK destruction, spine
tombstones with no readable residue, party notification, provable
`payload_purged` event; the copy-map as code — every store a datum reaches
(replicas, WAL, backups, caches, exports) enumerated with per-copy deletion
SLOs and an acknowledgment saga; deletion propagation to derived state
(recompute, grain-pattern).

Acceptance:
- AC-CD1 (mechanical): post-deletion, a full-database scan finds no
  readable personal data for the person; the tombstoned ID never reissues.
- AC-CD2 (mechanical): a revoked grant blocks the next packet read in the
  same second; the read log shows the denial.
- AC-CD3: the copy-map is exercised by test — a datum planted in every
  enumerated store is gone within its SLO after deletion.
- AC-CD4: deletion during an open dispute completes; the dispute record
  survives only in unreadable spine form.
