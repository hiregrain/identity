# Dispatch Positions to Test, and Questions That Are Yours

**Read this after your own design exists, not before.** The founder's
instruction for this repo is independent derivation: design the ledger from
the thesis and the interface contract, then diff your conclusions against the
positions below. Record every agreement and disagreement explicitly; surface
the disagreements to the founder. Independent agreement is validation;
independent disagreement is signal. Inherited agreement is neither.

## Part 1 — Dispatch positions to test

Positions Dispatch reached for its own identity-adjacent design. Each is a
claim about territory the ledger now owns, so each is yours to confirm or
contest.

1. **Identity and capability never share a record.** Capability belongs to a
   configuration (a person with particular tooling and training); identity
   persists when everything about how someone works changes. If the two share
   a record, "same person, better tooling" either mutates history or
   duplicates the identity — fatal to a system whose premise is that people
   move up.

2. **Nothing about what a person is good at is stored on the identity.**
   Reputation, capability, and trajectory are derived from evidence and
   recomputed; the identity record carries proofs, state, and references
   only.

3. **The evidence record is append-only and survives everything.** Promotion
   out, offboarding, restriction — all are transitions on a participation
   state, and none deletes history. A person who stops working is still a
   person the system knows things about. Corrections supersede; nothing
   edits.

4. **Identity verification is bought, not built.** External providers verify;
   the record holds resulting attestations with issuer and level. A person
   may hold several attestations from several issuers, and nothing depends on
   any one provider's identifier being the primary key. Whether the ledger
   *itself* eventually becomes an identity provider — verified identity plus
   demonstrated capability standing on its own — is a strategic option to
   keep open, not a commitment.

5. **Evidence is shared; inference is local.** The ledger holds evidence and
   coarse claims. Each vertical computes its own estimates and never syncs
   them up as facts. Duplicate models are deliberate; duplicate evidence
   stores are forbidden.

6. **Progression tracks responsibility dimensions, not titles.** Advance is
   "handled a harder class of thing," demonstrated in routed work and
   recorded as evidence — never a status granted by administrative act.
   Titles, where they exist, are renderings of position on the dimensions.

7. **Development bets are marked as such at the record level.** A deliberate
   above-level assignment that scores below the bar is an expected outcome of
   a development bet, and every surface rendering it — the worker's own
   record above all — must carry that context, or stretch data poisons both
   training and capability interpretation.

8. **No identity infrastructure around commodity knowledge work.** Work whose
   value and capability signal are perishable across a wide range of AI
   outcomes gets monetized opportunistically, never built around. The filter
   is what the work demands (coordination, ambiguity, accountability), not
   its channel or label.

9. **Routing internals are never career data.** The candidates considered and
   rejected for an assignment train the vertical's router; they say nothing
   attestable about a person.

10. **Portability is scoped, and the scope is a property of the record.**
    Performance history is portable within the company's verticals and to
    direct partners, not published externally — valuable enough to matter to
    a worker, scoped enough that the network still holds.

11. **The worker keeps portable outcomes; the vertical keeps traces and
    training rights.** (Dispatch status: proposed, not yet decided.) Verified
    results, capability evidence, and reputation are the worker's portable
    record; the behavioral orchestration record is the vertical's operational
    data. The evidence record surviving offboarding must be reconciled with
    jurisdiction-specific deletion rights by counsel before the first worker
    agreement, not after a request arrives.

## Part 2 — Questions that are the ledger's to answer

Identified by Dispatch as ledger territory. Dispatch holds no position on
these beyond what the interface contract implies.

1. **The person-ID scheme.** How ledger person IDs are issued, how duplicates
   are detected and merged, and what a merge does to attested history under
   append-only rules.

2. **The `work_kind` taxonomy.** Who authors the cross-vertical vocabulary,
   at what grain, and how it versions as verticals are added.

3. **The trust model of attestations.** The ledger stores claims signed by
   attesting parties. Does it ever re-verify? What is the dispute and appeal
   path when a worker contests an attestation? What happens to attestations
   from a vertical later found unreliable?

4. **Dimension standing: derived or attested?** Is standing on the
   responsibility dimensions recomputed by the ledger from attestations, or a
   fact each attestation asserts? (Dispatch's internal instinct — derive,
   never store — is position 2 above, but the ledger operates at coarser
   grain and may reasonably differ.)

5. **Consent and the worker's own view.** What the person sees of their
   record, what they consent to at onboarding, whether they can withhold an
   attestation from crossing to another vertical, and how deletion rights
   reconcile with append-only evidence — per jurisdiction.

6. **Read access.** Who may query a person's cross-vertical record: the
   person, a vertical considering them, an external partner, a customer?
   Under what grant?

7. **Attesting-party registration and signature.** How a vertical becomes an
   attesting party, how signatures are verified, how a compromised attesting
   key is handled in an append-only store.

8. **Schema governance.** How the attestation standard versions, who ratifies
   changes once multiple verticals write it, and what happens to attestations
   written under superseded versions.

9. **Organizations and customers.** Whether non-person identities
   (organizations, customers, vendors) are ledger identities or vertical-local
   records. Dispatch currently leans toward customers-as-identities for its
   own reasons (approval authority needs a referenceable identity) but treats
   this as open.

10. **The identity-provider option.** Under what conditions the ledger stops
    consuming external verification and becomes an identity layer in its own
    right — the option position 4 keeps open. A strategic call with its own
    timing, not a schema question.
