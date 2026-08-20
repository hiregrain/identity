---
id: analytics/06
type: task
layer: analytics
satisfies: [1]
status: ready
depends_on: [analytics/01, analytics/02, analytics/03]
migrations: []
binds: [decisions/LOG.md#022, decisions/LOG.md#066]
evidence: []
verified_by: null
---

# The analytics API and presentation shape

## Objective

One API defines how a read is requested and one presentation shape
defines what a reader sees; later surfaces consume both without
redefining either.

## Scope

- The API shape (decision 066): request a read under a share-link
  grant, receive the presentation-shaped result. Versioned from the
  first release. No partner accounts, no dashboards; admin and
  employer-dashboard surfaces consume this API in later layers.
- The presentation shape: the structure of a delivered read, including
  where the insufficient-data result, the slope disclosures, mapping
  fidelity, and provenance visibility live in it. The shape is the
  contract later surfaces render; it is defined here and rendered
  minimally here (a plain rendering at the share-link URL, enough for
  the first-product motion and the ORDER.md exit test).
- The full-run integration: a request drives grant check (02), assembly
  and scoring (03), threshold (04's construction), trajectory (05),
  and the run record write (01), in one path.
- The no-fact-write guarantee at the integration level: the scored run
  is inspected for writes; only the run record and the read log are
  permitted.
- Never transmitted: any Grain-computed ranking of candidates to a
  partner (decision 022). The API has no multi-person surface at all,
  which is the structural form of that ban.

## Acceptance

1. AC (mechanical): a full scored run through the API writes nothing
   except the run record and the read log, asserted by the
   foundation/06 schema-grep check and an integration test inspecting
   every write during the run.
2. AC (mechanical): the API accepts exactly one subject per request;
   no request shape exists that returns results for more than one
   person.
3. AC (mechanical): the presentation shape is schema-validated; the
   insufficient-data result, disclosures, and mapping fidelity each
   have a defined place, proven by fixtures rendering each state.
4. AC (mechanical): the API version is carried in every response and
   in the run record.

## Outside check

Verifier drives a full run through the API on a fresh clone, inspects
all writes, attempts a multi-subject request shape, and validates
fixture renderings against the presentation schema.
