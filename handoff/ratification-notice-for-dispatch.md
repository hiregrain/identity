# Ratification Notice — for the Dispatch repo (2026-08-17)

To be carried to the Dispatch repo / its agents. Authored here; this file
is the notice, not the standard.

1. **The interface contract is ratified.** `attestation-interface.md`
   0.1-proposed → **schema_version 0.2**, owned by the ledger repo at
   `model/attestation-interface.md` (ledger decision 006). Per HANDOFF,
   Dispatch's `model/attestation.md` is now the conforming copy and
   Dispatch's evaluation machinery conforms to this rubric. Amendments
   Dispatch must pick up: `work_kind@version` immutable binding;
   `verification` → `verification[]`; explicit provenance class on all
   packet contents; sensitive-data ban in all attestation fields (now
   including nationality/immigration detail and sanctions hit data);
   data-handling clause for delivered packets; `bar_ref` on each
   `score_summary` basis entry; Ed25519/JWS + registry + hash-chain
   timestamp as the signature mechanism; supersession authority limited to
   the original issuer or ledger invalidation.

2. **Two Dispatch positions need updating** (see the ledger's
   `design/dispatch-diff-0.1.md`):
   - Position 3 ("evidence record survives everything"): superseded in part
     by founder ruling R2 — a worker may delete their entire profile at any
     time. Routing priors must not assume ledger history is permanent.
   - Position 8 (commodity-work filter): narrowed by founder decision —
     it governs where the company builds verticals, not who may hold an
     identity. Identity issuance is universal.

3. **The one contested question is ruled** (ledger decision 007): customers
   and organizations are never ledger subjects. An org needing to attest —
   including Dispatch customers with approval authority — registers as an
   attesting party (issuer identity). Dispatch's customers-as-identities
   lean is declined; approval-authority needs are met by party-registry
   entries or Dispatch-local records.

4. **Validation worth knowing:** nine of Dispatch's eleven positions were
   independently re-derived by the ledger's clean-context design session
   (including "derive, never store" for dimension standing). The full diff
   is in the ledger repo.
