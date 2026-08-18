---
id: party-registry/08
type: task
status: ready
depends_on: [party-registry/01, ingestion/01]
migrations: []
binds: [design/stack-litigation/d4-verdict.md, decisions/LOG.md#015]
evidence: []
verified_by: null
---

# Party-visible issuance feed

## Objective

A party can see every attestation the ledger holds in its name, whenever it
wants — not just a monthly hash telling it that something is wrong.

## Scope

- D4 §5 adopted the issuance feed and the monthly countersignature as **two
  separate controls**, and they are not substitutes: the root tells a party
  *that* the record disagrees with theirs, the feed tells them *which*
  record. Without the feed, a party with a bad countersignature has no way
  to find the cause.
- A party-scoped feed over every attestation recorded in its name, carrying
  the ingestion metadata D4 requires alongside each entry: submitting-channel
  identity and ingestion metadata as committed in the log entry.
- Read-only, party-scoped, and reachable only by that party's principals
  (task 04). No cross-party visibility exists in any query path.
- Carries **no internal-only field** — asserted against the shared fixture
  from task 05, not a second copy of the list.
- The party is the one entity with perfect knowledge of what it actually
  issued; the feed exists so that knowledge has somewhere to land. Rendering
  in the partner console ships with `integration-surface`; this task owns the
  data surface and its access scoping.

## Acceptance

- AC (mechanical): the feed returns exactly the attestations attributed to
  the requesting party — proven with a two-party fixture where each sees only
  its own.
- AC (mechanical): every entry carries the ingestion metadata D4 names; an
  entry missing it fails the check.
- AC (mechanical): the feed carries no internal-only field, asserted against
  the shared fixture.
- AC (mechanical): a principal of party A cannot reach party B's feed through
  any parameter, including direct id substitution.

## Outside check

Verifier seeds two parties with interleaved issuance, fetches each feed and
diffs against the raw attestation rows, substitutes the other party's id in
every request parameter, and checks one entry field-by-field against the
internal-only fixture.
