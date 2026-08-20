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
  - research/13-retention-vs-erasure-and-reset-gaming.md
evidence: []
verified_by: null
---

# analytics

The first product: a read on a person's work history and trajectory,
computed on a requesting party's intent, delivered, and never written back
as a fact about the person (decision 022).

This layer carries `milestone: first-product` with `person-identity` and
`self-asserted-record`: analytics on partially verified history needs signup
and the self-asserted record, and needs neither the party registry nor the
attestation round trip. `v1` remains the round trip.

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
**party quality scores excluded** from every computation: `score_summary`
is readable by its own issuer and by a human reader, and never enters
grading (thesis §4); **confidence gating**: the published threshold below
which the product returns insufficient data plus a suggestion to take an
assessment, rather than a weak number; **slope disclosure**: every
trajectory output carries the three known failure modes (routing flattens
raw grades while ability rises, frozen difficulty priors read promotions as
decline, grader drift tracks the trend being measured) on its face;
**mapping fidelity** reported on any output expressed against a
customer-authored view; **run records** (decision 026): requesting
party, timestamp, input references, and instrument and model versions.
**Never the output**, and nothing else attributable to a person: the AI Act
prescribes no log content for an Annex III point 4 system, and its Art. 19
retention floor expressly yields to data protection law, so a retained
capability projection about a deleted worker has no lawful basis
(`research/13`). Retention is a stated number of months, not "the compliance
period", which resolved to four different periods across the regimes
surveyed. Reachable by regulator and audit, and by no read path that touches
ranking or a worker's packet.

Explicitly out of scope: any write to a fact table about a person; any
transmission of a Grain-computed ranking of candidates to a partner
(decision 022); any worker-visible surfacing of a run (`worker-surface`
holds the ruled position that workers do not see analytics).

**OPEN, blocking `ready`** (decision 026):
- The confidence threshold and whether it is published.
- The exact disclosure text for slope.
- **The run-record pseudonym.** A pseudonymised run record works only if the
  pseudonym is not the `ledger_person_id`. Decisions 013 and 020 make
  tombstoned ids permanent and spine-referenced forever, which is a retained
  means of singling out (EDPB Guidelines 01/2025). Undesigned.
- **The spine/payload fork.** Under `foundation/05` a run record either sits
  inside the subject's DEK envelope, dying at deletion and breaching Art. 19,
  or outside it, surviving readable. It has to be split across the planes and
  no task owns that.

Acceptance:
1. **Analytics never writes a fact about a person.** (mechanical) no analytics code path writes to a fact table,
   asserted by the `foundation/06` schema-grep check and by an integration
   test inspecting all writes during a scored run.
2. **The same claim from two sources does not count twice.** (mechanical) two inputs asserting the same thing at different
   provenance classes produce different weights; a run over
   `self_asserted`-only evidence never reaches the same confidence as one
   over corroborated `party_attested` evidence.
3. **Below the evidence threshold it refuses rather than guesses.** (mechanical) below the threshold the product emits the
   insufficient-data result and no score; a golden-fixture person just below
   and just above the line produces the two distinct outputs.
4. **Every trajectory ships with the three limits that make it honest.** every trajectory output carries the three slope disclosures and,
   where a customer view is applied, its mapping fidelity, asserted on the
   rendered output, not only in the payload.
5. **Every run leaves exactly one record of itself.** (mechanical) every run leaves exactly one run record with the
   full field set and **no output field**, asserted at the schema level; no run
   record is reachable from any packet, ranking, or worker-facing read path,
   asserted by a check over the read paths.
6. **A run record survives deletion, because it records our processing, not the person.** (mechanical) a run record survives the subject's profile deletion
   and carries nothing that identifies them after it, proven by deleting a
   scored person and inspecting the surviving record.
7. **A party's own scores never enter the computation.** (mechanical) `score_summary` values from attesting parties are
   never read by the scoring path, asserted by a check over the query
   surface, not by review.
