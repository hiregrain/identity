---
id: analytics/06
type: task
layer: analytics
satisfies: [1]
status: ready
depends_on: [analytics/01, analytics/02, analytics/03, analytics/04, analytics/05]
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

- The API shape (decisions 066, 067): request a read under a
  named-recipient grant with a recipient account, receive the
  presentation-shaped result. Versioned from the
  first release. No dashboards; admin and
  employer-dashboard surfaces consume this API in later layers.
- The presentation shape: the structure of a delivered read, including
  where the insufficient-data result, the slope disclosures, and
  per-claim provenance live in it. **Every claim in a delivered read
  carries its provenance class, and no field renders a graded claim as
  a bare yes** (the constitution's rule, made a criterion here because
  this is the first surface a partner sees). The shape is the
  contract later surfaces render; it is defined here and rendered
  minimally here (a plain rendering the recipient reaches through
  their grant, enough for
  the first-product motion and the ORDER.md exit test), carried
  knowingly beside the shape definition, the 03/05 pattern.
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
2. AC (mechanical): the request schema binds exactly one subject; a
   multi-subject payload fails schema validation with a structured
   error, proven by a red-path fixture.
3. AC (mechanical): the presentation shape is schema-validated; the
   insufficient-data result and the disclosures each
   have a defined place, every rendered claim carries its provenance
   class, and no boolean verified-style field exists in the schema,
   proven by fixtures rendering each state and a schema inspection.
4. AC (mechanical): the API version is carried in every response and
   in the run record.

## Outside check

Verifier drives a full run through the API on a fresh clone, inspects
all writes, attempts a multi-subject request shape, and validates
fixture renderings against the presentation schema.
