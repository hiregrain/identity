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
evidence: []
verified_by: null
---

# prior-packet

The read side: what a grantee sees, generated at read time, never stored,
never cached at the edge.

Scope: packet assembly per the ratified interface: alias-closure-resolved
ID, `verification[]`, provenance-graded `credentials[]`,
`dimension_standing[]`, `prior_attestations[]` with supersession/dispute/
issuer-state flags; dimension-standing derivation: the published
deterministic coarse rule (two-independent-attestation corroboration,
freshness window, `singly_attested` marking, below-bar stretch exclusion,
citations on every entry), introduced behind the shadow/promotion-gate
pattern and stored only as cache; fresh-read discipline
(D1 obligation): grant/deletion liveness checks read the primary;
per-packet issuance logging visible to the worker.

Acceptance:
1. **The packet is generated live, so nothing stale can survive in it.** (mechanical) revocation, deletion, supersession, and a registry
   suspension are each reflected in the very next packet read.
2. ~~**Work authorization is unreadable before a selection has been
   made.**~~ Removed by decision 070: work authorization is not stored
   at all, so no packet carries it and no read gate for it exists. The
   criterion number is retired, not reused.
3. **Every standing entry resolves to the attestations behind it.** every `dimension_standing` entry resolves to its supporting
   attestations; dropping the cache and recomputing reproduces identical
   packets (Dispatch AC-REP-2 pattern).
4. **Packets carry no banned data and no scores.** packets carry no sensitive-data-ban categories and no scores
   finer than the interface's coarse tiers.

Inherited criterion candidates (decisions 063, 064), obligations for
this layer's grilling, not suggestions: a packet rendering of a
credential with an attached document says "document on file,
self-asserted" and never carries or links the file; and no packet
carries any claim version history, only current versions. The storage
and access-path halves are proven in `self-asserted-record`; what a
packet renders is provable only here.
