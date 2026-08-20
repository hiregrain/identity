---
id: analytics/02
type: task
layer: analytics
satisfies: [8]
status: ready
depends_on: []
migrations: [0029-share-link-grants]
binds: [decisions/LOG.md#035, decisions/LOG.md#066, model/record-schema.md]
evidence: []
verified_by: null
---

# Share-link grants: the first-product read gate

## Objective

A worker hands a reader a link; the link is the consent; revoking it
stops the very next read.

## Scope

- `0029-share-link-grants` (payload plane): the grant object per schema
  §5 in its share-link form: no `grantee_party_ref`, 30-day default
  expiry, expiry mandatory, revocable, state as append-only event pairs.
- Creation states what the recipient receives (full work-history
  detail and the ability to ask Grain to analyse it, decision 035),
  written as what the recipient gets.
- Enforcement: every analytics read resolves a live grant first; the
  liveness check reads the primary (the D1 fresh-read discipline), so
  revocation is effective on the next read, not the next cache expiry.
- Read log: every read under a live grant is logged with grant id and
  timestamp; the log feeds the worker's disclosure record surface
  later; `last_read_at` is retained and not worker-surfaced (decision
  035 §B4).
- Party-level standing grants are consent-and-deletion's scope, not
  here.

## Acceptance

1. AC (mechanical): a read under a revoked grant is refused in the same
   second as the revocation; a read under an expired grant is refused;
   the refusal is logged.
2. AC (mechanical): a grant cannot be created without an expiry; the
   default is 30 days.
3. AC (mechanical): every read under a live grant writes a read-log row;
   no analytics read path exists that skips the grant check, asserted
   by a check over the read paths, not by review.

## Outside check

Verifier revokes mid-fixture and asserts the next read fails, attempts
a no-expiry grant, and greps the read paths for any route around the
grant resolver.
