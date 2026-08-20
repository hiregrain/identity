# Diff: Independent Design 0.1 vs. Dispatch Positions

Produced per the HANDOFF protocol: the design in `ledger-design-0.1.md` was
derived in a clean context that never read
`handoff/dispatch-positions-and-open-questions.md`; this diff was produced by
a separate context that has read both. Independent agreement is validation;
independent disagreement is signal; both are recorded.

## Part 1. Against Dispatch's eleven positions

| # | Dispatch position | Verdict | Notes |
|---|---|---|---|
| 1 | Identity and capability never share a record | **Independent agreement** | Design: opaque ID carries proofs/state/references; capability lives in attestations and derived views. |
| 2 | Nothing about what a person is good at stored on the identity; derived and recomputed | **Independent agreement** | Design §5: standing is a deterministic derived view, stored only as cache, recomputable, citation-backed. |
| 3 | Evidence record append-only and **survives everything**, offboarding, restriction; nothing deletes history | **Partial disagreement, founder-driven** | Founder ruling R2 grants total worker-initiated profile deletion. The design preserves append-only *integrity* (spine survives; payloads erasable) but the record no longer survives the worker's own exit. Consequence Dispatch must hear: a worker can legally shed a bad record and restart cold (design §1.5 accepts this as the price of the worker-owned model). Dispatch's routing priors cannot assume ledger history is permanent. |
| 4 | Verification bought, not built; multi-issuer; no provider ID as primary key; ledger-as-IdP kept open as option | **Independent agreement** | Design: verification attestations from registered providers; opaque surrogate ID; VC-compatible envelope keeps the IdP option open without committing. |
| 5 | Evidence shared, inference local; duplicate models deliberate, duplicate evidence stores forbidden | **Independent agreement** (with a boundary nuance) | Design honors it and extends it to the ledger's own outputs: dimension standing is deliberately a coarse deterministic *summary with citations*, not a model estimate, so nothing score-like syncs down as fact. |
| 6 | Progression tracks responsibility dimensions, not titles | **Independent agreement** | Ratified as the contract grain; dimension set explicitly flagged as a hypothesis to recalibrate after two verticals (research `05`). |
| 7 | Development bets marked at record level; below-bar stretch must not read against the worker | **Independent agreement** | Design additionally enforces it in derivation: below-bar stretch outcomes are excluded from downward standing revision. |
| 8 | No identity infrastructure around commodity knowledge work | **Amended by founder decision** | Founder decision 3 narrows the filter: it governs where the company builds verticals and evaluation machinery, not who may hold an identity. Universal self-signup stands. Dispatch's filter survives as an investment rule, not an identity-issuance rule. |
| 9 | Routing internals never career data | **Independent agreement** | Never-crosses list ratified unchanged. |
| 10 | Portability scoped, scope a property of the record | **Agreement on intent, different mechanism, founder-amended scope** | Founder: external partners read *and write* from day one. Design: scope is enforced as revocable worker grants at party level plus read-time packet generation, rather than a blanket record-level policy. Same goal (portability valuable but bounded), different owner of the boundary: the worker, not the record. |
| 11 | Worker keeps portable outcomes; vertical keeps traces/training rights; offboarding-survival vs. deletion rights to counsel before first worker agreement | **Independent agreement, and the open half is now answered** | Design keeps the split exactly. The deletion question Dispatch deferred to counsel is resolved by R2 + the two-plane architecture: total deletion, payloads purged, vertical-local records untouched (which is what makes deletion honest). Counsel review still flagged (design §10). |

## Part 2. Against the ten questions Dispatch handed to the ledger

All ten are answered in `ledger-design-0.1.md` / `interface-verdict-0.1.md`.
Three warrant comment:

- **Q4 (dimension standing: derived or attested?)** Dispatch's internal
  instinct was "derive, never store." The clean-context design reached
  **derived** independently, for stated reasons (single-party assertion of a
  career-level fact is both an attack surface and a category error). This is
  the protocol's best case: independent convergence. [FOUNDER-CALL] on the
  pass-through alternative remains recorded in N-2.
- **Q9 (organizations and customers).** **The one genuine independent
  disagreement.** Dispatch leans customers-as-ledger-identities ("approval
  authority needs a referenceable identity"). The design concludes the
  opposite: only persons (subjects) and attesting parties (issuers) are
  ledger-native; organizations have no career and fail the litmus test
  ("would another vertical want this exact row, untranslated?"); an org that
  needs to attest registers as an attesting party, an issuer identity, not a
  subject. Dispatch's stated need (referenceable approval authority) is, on
  the design's analysis, satisfiable vertical-locally or via party registry
  entries without making orgs subjects. **This is signal, not noise: it was
  reached against Dispatch's lean without knowing the lean existed.**
  Resolution belongs to the founder at ratification.
- **Q10 (identity-provider option).** Kept open, consistent with Dispatch:
  VC-2.0-compatible envelope and per-attestation assurance make
  "ledger as identity layer" a later strategic call, not a schema change.

## Summary for the founder

- **Nine of eleven Dispatch positions independently re-derived**, strong
  validation of the shared architecture instincts.
- **Two positions modified, both by your rulings, not by design divergence**
  (universal identity vs. the commodity filter; R2 deletion vs.
  "survives everything"). Dispatch's copies of positions 3 and 8 should be
  updated at ratification so the verticals don't build against stale
  assumptions, especially position 3, since routing priors that assume
  permanent history will be subtly wrong.
- **One genuine independent disagreement to adjudicate:** customers/orgs as
  ledger identities (Dispatch leans yes; ledger design says no). Needs your
  call at ratification.
- The interface verdict (ratify with five amendments, four open items
  resolved) is ready for your ratification review; on ratification, the
  standard transfers to this repo and Dispatch's copy becomes conforming.
