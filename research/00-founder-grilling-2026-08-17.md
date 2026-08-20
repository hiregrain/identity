# Settled decisions from founder grilling (2026-08-17)

Record of a grilling session with the founder, run against `founder-thesis.md`
and the handoff package, before any design work. These are founder decisions,
binding as inputs to the design session; the evidence files (`01`–`06`) are
research, binding on nothing.

Session protocol note: this session read the full handoff package including
`dispatch-positions-and-open-questions.md`, so it is disqualified from
producing the independent design. Design happens in a fresh session that loads
only `HANDOFF.md`, `founder-thesis.md`, `attestation-interface.md`, plus this
file and the research corpus.

## Settled decisions

1. **Trust perimeter: internal-first, externally compatible day one.** Built
   for internal use cases initially (same global scope: game devs, Philippine
   ops support, datacenter technicians), but immediately compatible with
   external partners. Example held as canonical: a datacenter company
   contracts the company to train and supply technicians; all trainees and
   eventual hires route through the ledger.

2. **External partners both read and write.** Partners are attesting parties,
   not read-only consumers. The schema must not be able to distinguish an
   internal vertical from an external partner; only the trust registry can.

3. **Universal identity issuance.** Anyone can sign up and create an identity,
   including the founder. People routed through company-run work or programs
   are the dominant source of signups, but signup is not gated on that. A
   self-signed-up person can add work history, references, connections,
   certifications, and verified skills. The thesis's commodity-work filter
   governs where the company builds verticals and evaluation machinery, not
   who may hold an identity.

4. **The worker is a first-class user.** The person sees every raw fact in
   their record because it is their record. Operator-side and consumer-side derived
   analytics need not be visible to the worker; raw facts always are.

5. **Provenance grades on everything.** Every claim carries an explicit trust
   grade. At minimum three classes: self-asserted, peer-attested, and
   party-attested (signed). Nothing self-asserted can be schematically
   confused with anything attested. Verification upgrades a claim's grade,
   never silently.

6. **Claim lifecycle: self-asserted claims are worker-editable until
   third-party verified, then frozen** into the append-only record. Party
   attestations are append-only from birth. Disputes are handled by
   worker-visible annotations that travel with the claim: never edit, never
   deletion. (Jurisdictional deletion rights are a legal question, researched
   in `01-regulatory-perimeter.md`, not a schema preference.)

7. **Disclosure control is party-level, not claim-level.** The worker governs
   *who* may read their record, not *which claims* a permitted reader sees.
   Rationale accepted by founder: claim-level curation destroys the record's
   meaning for consumers.

8. **Positioning assumption: global recruiter, not a reporting agency.**
   Founder's stated operating assumption. Recorded with an explicit caveat
   the founder saw: FCRA-style classification turns on conduct, not labels,
   and research file `01` tests whether the positioning holds and what
   constraints follow.

9. **No economics embedded.** Business model of the ledger is out of design
   scope; nothing in the schema should encode a payment relationship.

10. **grain is context, not constraint.** The hospitality product (grain, at
    `hiregrain.com`) was an early, deliberately scoped-down prototype of this
    identity infrastructure. Its identity anchor ADR, trust-graph adversarial
    model, and FCRA positioning doc are prior art to consult; its data model
    binds nothing. The identity infrastructure itself may end up carrying the
    grain name. The hospitality product remains as a vertical-style customized
    surface (owners / managers / front-line workers) tied to this layer.

## Founder rulings after research review (same day, final)

The research corpus surfaced two collisions (`07-synthesis.md`); the founder
ruled on both. These rulings supersede the corresponding text above and are
not open for re-litigation in the design session.

**R1: Not a CRA; worker-owned platform is the operating model (rules on
decision 8).** Workers own the record fundamentally, which is why it is
shaped this way. The product is the worker's portable digital verified resume
and world identity in one platform; partners integrate fluidly with that
identity layer. Model on known platforms and their constraints (the
worker-published-profile theory under which platforms like LinkedIn have
survived FCRA challenge), not on the CRA frame. The contrary FCRA analysis in
`01-regulatory-perimeter.md` remains on record as evidence and as a counsel
agenda item; it does not bind design.

**R2: Profile deletion yes, record editing no (refines decision 6).** A
worker can delete their entire profile at any time. They cannot edit
already-verified records. Consequences for design: whole-profile erasure is a
supported first-class operation (which also satisfies most
jurisdictional-erasure exposure), while verified claims remain append-only
and edit-proof for as long as the profile exists.

## Open items deliberately left to the design session

- Everything in `dispatch-positions-and-open-questions.md` Part 2, under the
  constraints above.
- The vetting/suspension mechanics of the attesting-party trust registry
  (decision 2 requires one; its design is unspecified).
- Sybil resistance for peer-attested claims (decision 5 creates the surface;
  research file `06` maps the threat model).
