---
id: analytics
type: layer
status: draft
milestone: first-product
depends_on: [person-identity, self-asserted-record]
binds:
  - THESIS.md#5
  - decisions/LOG.md#022
  - decisions/LOG.md#026
  - decisions/LOG.md#066
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

Grilled 2026-08-20 (decision 066), which discharged the four items
decision 026 left open. Not yet through the engineering review over
these criteria and the authored tasks.

This layer carries `milestone: first-product` with `person-identity` and
`self-asserted-record`: analytics on partially verified history needs signup
and the self-asserted record, and needs neither the party registry nor the
attestation round trip. `v1` remains the round trip.

**The v0 instrument is deterministic and algorithmic, and only that**
(decision 066): provenance-weighted evidence assembly, tenure and
responsibility meta-signals, fixed published weights, versioned. No LLM
produces or influences any number or any prose in v0. LLM enhancement is
a later, separately ruled instrument version with its own decisions
entry. Getting the deterministic instrument as good as it can be comes
first.

**Delivery is an API defined here** (decision 066): this layer defines
the analytics API shape and the presentation shape of a read. No partner
accounts, no partner dashboard; admin and employer-dashboard interfaces
consume this API in later layers. The first-product consent instrument
is the worker-initiated share-link grant (schema §5: no
`grantee_party_ref`, mandatory expiry): the worker shares, the reader
holds the link, revocation stops the next read. Party-level standing
grants stay in `consent-and-deletion`.

**Run records are split across the planes** (decision 066, discharging
026's fork): the spine half carries requesting party, timestamp,
instrument and model versions, and a per-run random pseudonym, and
survives deletion carrying nothing that identifies anyone; the payload
half carries subject linkage and input references under the subject's
DEK and dies at profile deletion. The pseudonym is generated per run and
never reused, so cross-run correlation requires the payload half, which
is exactly the half deletion kills. Retention of the spine half is six
months, stated as that number.

**The confidence threshold is evidence-class-based, deterministic, and
published** (decision 066): a stated minimum of distinct sources and
provenance classes below which the product returns insufficient data,
expressible in one published sentence. The numeric parameters are set by
golden-fixture calibration and ruled by the founder when the fixtures
exist; until then criterion 3 is gated, declared below.

**Employer normalization lands here when it lands (decision 040 §E, corrected
2026-08-19).** A read on one worker needs no employer resolution. The free-text
name is sufficient. Aggregating *across* workers does, and that is this layer's
territory, not `party-registry`'s. Capture-side context (`party_country`,
`party_locality`, per `model/record-schema.md`) is collected from day one because
it cannot be backfilled; the resolution machinery is not scoped, and when it is,
the operating threshold is set against the **false-merge rate**, never F1.

Scope: the scoring path: inputs assembled from work history at whatever
verification level exists, skills-assessment results where any exist,
course performance, structured references (`peer-references`), and
observable meta-signals (average tenure in role, described responsibility,
seniority); **provenance weighting**, so a `self_asserted` history and a
`party_attested` one never carry equal weight for the same assertion;
**party quality scores excluded** from every computation. `score_summary`
is readable by its own issuer and by a human reader, and never enters
grading (thesis §4); **confidence gating** per the ruled construction
above; **slope disclosure**: every trajectory output carries the three
known failure modes (routing flattens raw grades while ability rises,
frozen difficulty priors read promotions as decline, grader drift tracks
the trend being measured) on its face, the text drafted in the
trajectory task under an adjudicated criterion and ratified at that
task's review (decision 066); **mapping fidelity** reported on any
output expressed against a customer-authored view; **run records** per
the ruled split above; **share-link grant creation, enforcement, and
revocation** as the read gate.

Explicitly out of scope: any write to a fact table about a person; any
transmission of a Grain-computed ranking of candidates to a partner
(decision 022); any worker-visible surfacing of a run (`worker-surface`
holds the ruled position that workers do not see analytics); any LLM
involvement in v0; partner accounts and dashboards; employer
normalization.

Acceptance:
1. **Analytics never writes a fact about a person.** (mechanical) no analytics code path writes to a fact table,
   asserted by the `foundation/06` schema-grep check and by an integration
   test inspecting all writes during a scored run.
2. **The same claim from two sources does not count twice.** (mechanical) two inputs asserting the same thing at different
   provenance classes produce different weights; a run over
   `self_asserted`-only evidence never reaches the same confidence as one
   over corroborated `party_attested` evidence.
3. **Below the evidence threshold it refuses rather than guesses.** (mechanical, gated) below the ruled threshold the product emits the
   insufficient-data result and no score; a golden-fixture person just below
   and just above the line produces the two distinct outputs. Gated: the
   numeric parameters await the calibration fixtures and the founder
   ruling (decision 066).
4. **Every trajectory ships with the three limits that make it honest.** (adjudicated) every trajectory output carries the three slope
   disclosures and,
   where a customer view is applied, its mapping fidelity, asserted on the
   rendered output, not only in the payload.
5. **Every run leaves exactly one record of itself.** (mechanical) every run leaves exactly one run record with the
   full field set and **no output field**, asserted at the schema level; no run
   record is reachable from any packet, ranking, or worker-facing read path,
   asserted by a check over the read paths.
6. **A run record survives deletion, because it records our processing, not the person.** (mechanical) the spine half of a run record survives the
   subject's profile deletion and carries nothing that identifies them
   after it, proven by deleting a scored person and inspecting the
   surviving record; the payload half is gone; two surviving records
   for the same deleted person are unlinkable to each other through any
   readable data.
7. **A party's own scores never enter the computation.** (mechanical) `score_summary` values from attesting parties are
   never read by the scoring path, asserted by a check over the query
   surface, not by review.
8. **A revoked or expired share link stops the very next read.** (mechanical) a read under a revoked or expired share-link grant is
   refused in the same second; every read under a live grant is logged;
   no read path exists that does not check the grant.
9. **The instrument is deterministic and versioned.** (mechanical) the same inputs and instrument version produce
   byte-identical output across repeated runs and across processes; the
   run record carries the version; no network or model call occurs
   during a scored run, asserted by the run executing with egress
   blocked.
