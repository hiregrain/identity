---
id: prior-packet
type: layer
status: draft
milestone: v1
depends_on: [ingestion, consent-and-deletion]
binds:
  - model/attestation-interface.md
  - decisions/LOG.md#008
  - design/ledger-design-0.1.md#5
acceptance: [AC-PP1, AC-PP2, AC-PP3, AC-PP4]
evidence: []
verified_by: null
---

# prior-packet

The read side: what a grantee sees, generated at read time, never stored,
never cached at the edge.

Scope: packet assembly per the ratified interface — alias-closure-resolved
ID, `verification[]`, provenance-graded `credentials[]`,
`dimension_standing[]`, `prior_attestations[]` with supersession/dispute/
issuer-state flags; dimension-standing derivation: the published
deterministic coarse rule (two-independent-attestation corroboration,
freshness window, `singly_attested` marking, below-bar stretch exclusion,
citations on every entry), introduced behind the shadow/promotion-gate
pattern and stored only as cache; **the post-selection gate for
work-authorization** (decision 008): the field is absent from any packet
served in a pre-selection context and available only via the post-selection
read path, enforced structurally, with reads logged; fresh-read discipline
(D1 obligation): grant/deletion liveness checks read the primary;
per-packet issuance logging visible to the worker.

Acceptance:
- AC-PP1 (mechanical): revocation, deletion, supersession, and a registry
  suspension are each reflected in the very next packet read.
- AC-PP2 (mechanical): no code path serves `work_authorization` to a
  pre-selection read; attempts are logged and structurally rejected.
- AC-PP3: every `dimension_standing` entry resolves to its supporting
  attestations; dropping the cache and recomputing reproduces identical
  packets (Dispatch AC-REP-2 pattern).
- AC-PP4: packets carry no sensitive-data-ban categories and no scores
  finer than the interface's coarse tiers.
