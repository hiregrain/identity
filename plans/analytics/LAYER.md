---
id: analytics
type: layer
status: ready
milestone: first-product
depends_on: [person-identity, self-asserted-record]
binds:
  - THESIS.md#5
  - decisions/LOG.md#022
  - decisions/LOG.md#026
  - decisions/LOG.md#057
  - decisions/LOG.md#066
  - decisions/LOG.md#067
  - research/13-retention-vs-erasure-and-reset-gaming.md
  - model/record-schema.md
gated_criteria: [3]
evidence: []
verified_by: null
---

# analytics

The first product: a read on a person's work history and trajectory,
computed on a requesting party's intent, delivered, and never written back
as a fact about the person (decision 022).

Grilled 2026-08-20 (decision 066); engineering review the same session
returned twenty-four defects, closed by decision 067's five corrections
and in-place fixes. Criteria are final.

This layer carries `milestone: first-product` with `person-identity` and
`self-asserted-record`: analytics on partially verified history needs signup
and the self-asserted record, and needs neither the party registry nor the
attestation round trip. `v1` remains the round trip.

**The v0 instrument is deterministic and algorithmic, and only that**
(decision 066): provenance-weighted evidence assembly, tenure and
responsibility meta-signals, fixed published weights, versioned. No LLM
produces or influences any number or any prose in v0; the run record's
model-version field exists and stays null until a decisions entry admits
a model (decision 067). LLM enhancement is a later, separately ruled
instrument version. Getting the deterministic instrument as good as it
can be comes first.

**Delivery is an API defined here** (decision 066): this layer defines
the analytics API shape and the presentation shape of a read. No partner
accounts beyond the recipient account 057 requires, no dashboards; admin
and employer-dashboard interfaces consume this API in later layers. The
first-product consent instrument is **the named-recipient grant of
decision 057** (correcting 066's share-link wording, decision 067): the
worker sends access to a named person, the recipient proves control of
the address it was sent to, and an account is required to run analytics,
never to read the record. The requesting party in a run record is that
account. Party-level standing grants stay in `consent-and-deletion`,
which builds on the grant subset this layer lands first (both layers
carry the note).

**Run records are split across the planes** (decisions 066, 067): the
spine half carries the requesting account, a day-precision timestamp,
instrument and model versions, and a per-run random pseudonym, and
survives deletion carrying no subject field and nothing derived from
one; the payload half carries subject linkage, input references, the
full timestamp, and the read log, under the subject's DEK, dying at
profile deletion. The pseudonym is generated per run and never reused,
so cross-run correlation requires the payload half, which is exactly
the half deletion kills. Retention of the spine half is six months,
stated as that number. Workers never see analytics runs (decision 022);
no read event feeds any worker surface.

**The confidence threshold is evidence-class-based, deterministic, and
published** (decision 066): a stated minimum of distinct sources and
provenance classes below which the product returns insufficient data,
expressible in one published sentence. The refusal renders the rule and
never the person's count (decision 067). The numeric parameters are set
against golden fixtures and ruled by the founder; criterion 3 is gated
because its satisfying task (07) is draft until that ruling.

**Employer normalization lands here when it lands (decision 040 §E, corrected
2026-08-19).** A read on one worker needs no employer resolution. The free-text
name is sufficient. Aggregating *across* workers does, and that is this layer's
territory, not `party-registry`'s. Capture-side context is collected from day
one because it cannot be backfilled; the resolution machinery is not scoped,
and when it is, the operating threshold is set against the **false-merge
rate**, never F1.

Scope: the scoring path: inputs assembled from the record objects at
whatever verification level exists (the `provenance` field on each
claim is the input; no attestation machinery is required to test
weighting, fixtures set provenance directly), structured references
where any exist (none in first-product), and observable meta-signals
(average tenure in role, described responsibility, seniority);
**provenance weighting** with corroboration counted once per claim,
never twice; **party quality scores excluded**: the scoring path
contains no reference to party score fields (the column itself arrives
with v1 ingestion); **confidence gating** per the ruled construction;
**slope disclosure** text drafted in the trajectory task under an
adjudicated criterion, founder-ratified at that task's review; **run
records** per the ruled split; **named-recipient grant creation,
address-proof, enforcement, and revocation** as the read gate.

Explicitly out of scope: any write to a fact table about a person; any
transmission of a Grain-computed ranking of candidates to a partner
(decision 022), enforced structurally by the API having no multi-person
shape; any worker-visible surfacing of a run; any LLM involvement in
v0; partner dashboards; employer normalization; customer-authored views
and mapping fidelity (deferred to v1, decision 067).

Acceptance:
1. **Analytics never writes a fact about a person.** (mechanical) no analytics code path writes to a fact table,
   asserted by the `foundation/06` schema-grep check and by an integration
   test inspecting all writes during a scored run.
2. **The same claim never counts twice, and better-known claims count
   more.** (mechanical) two fixtures asserting the same content at
   different provenance classes produce different weights; one claim
   corroborated by two sources is counted once at higher weight, never
   twice; a `self_asserted`-only fixture never reaches the confidence
   of a corroborated `party_attested` fixture with identical content.
3. **Below the evidence threshold it refuses rather than guesses.** (mechanical, gated) below the ruled threshold the product emits the
   insufficient-data result and no score; a golden-fixture person just below
   and just above the line produces the two distinct outputs; the
   refusal renders the published rule and never the person's source
   count. Gated: the satisfying task (07) is draft until the founder
   rules the parameters against the calibration fixtures.
4. **Every trajectory ships with the three limits that make it honest.** (adjudicated) every trajectory output carries the three slope
   disclosures on the rendered output, not only in the payload, stated
   accurately against decision 022's wording.
5. **Every run leaves exactly one record of itself.** (mechanical) every run leaves exactly one run record with the
   full field set and **no output field**, asserted at the schema level; run
   records are readable by the audit role and by no packet, ranking, or
   worker-facing read path, asserted by role privilege and a check over
   the read paths.
6. **The surviving half records our processing, not the person.** (mechanical) after profile deletion the payload half is gone and
   the spine half survives with the properties that make it
   non-identifying, each asserted directly: no subject field at the
   schema level, a pseudonym the red-path suite shows is not derived
   from any subject identifier, a day-precision timestamp, and a
   requesting party that is the recipient account, a party to the
   processing.
7. **A party's own scores never enter the computation.** (mechanical) the scoring path contains no reference to party
   score fields, asserted by a grep-class check over the query surface;
   the column-privilege assertion lands with v1 when ingestion creates
   the column.
8. **A revoked or expired grant stops the very next read.** (mechanical) an analytics read under a revoked or expired
   named-recipient grant is refused on a liveness check against the
   primary; every read under a live grant writes a payload-side read-log
   row; the grant resolver is the only entry to the read path, asserted
   by a check over the read paths.
9. **The instrument is deterministic and versioned.** (mechanical) the same inputs and instrument version produce
   byte-identical output across repeated runs and across processes; the
   run record carries the instrument version; a scored run completes
   with network egress blocked.
