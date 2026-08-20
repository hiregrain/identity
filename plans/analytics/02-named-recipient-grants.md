---
id: analytics/02
type: task
layer: analytics
satisfies: [8]
status: ready
depends_on: [person-identity/01]
migrations: [0029-recipient-grants]
binds: [decisions/LOG.md#035, decisions/LOG.md#057, decisions/LOG.md#066, decisions/LOG.md#067, model/record-schema.md]
evidence: []
verified_by: null
---

# Named-recipient grants: the first-product read gate

## Objective

The worker sends access to a named person; the person proves they hold
the address it went to; revoking them stops the very next read.

## Scope

- `0029-recipient-grants` (payload plane): the grant object per schema
  §5 in decision 057's shape: a named recipient address, mandatory
  expiry with a 30-day default, state as append-only event pairs with
  the §5 nullable columns as the projection (decision 067).
- Open-by-address-proof: the recipient opens by proving control of the
  address the send went to, one click, no account, no password.
  Reading the record requires nothing more. **Running analytics
  requires an account** (decision 057), and that account is the run
  record's requesting party.
- Creation states what the recipient receives (full work-history
  detail and the ability to ask Grain to analyse it, decision 035),
  written as what the recipient gets.
- Enforcement: every analytics read resolves a live grant first, with
  the liveness check reading the primary (the D1 fresh-read
  discipline), so revocation is effective on the next read. Revocation
  is per recipient.
- Read log: payload-side, under the subject's DEK, dying with the
  profile (decision 067). Workers never see analytics runs (decision
  022): no read event feeds any worker surface, and grant *state*
  (issued, active, expired, revoked) is what the worker sees, per
  decision 035 §B4.
- Party-level standing grants are consent-and-deletion's scope; this
  task lands the named-recipient subset first and that layer builds on
  it (noted in both layers).

## Acceptance

1. AC (mechanical): a read under a revoked or expired grant is refused
   on a liveness check against the primary; the refusal is logged
   payload-side.
2. AC (mechanical): a grant cannot be created without a recipient
   address or without an expiry; the default expiry is 30 days.
3. AC (mechanical): opening requires address proof; an analytics run
   without a recipient account is refused; a record read without an
   account succeeds.
4. AC (mechanical): every analytics read under a live grant writes a
   payload-side read-log row that dies at profile deletion, proven by
   the deletion fixture; the grant resolver is the only entry to the
   analytics read path, asserted by a check over the read paths.

## Outside check

Verifier revokes mid-fixture and asserts the next read fails, attempts
creation without address and without expiry, runs analytics without an
account, and confirms the read log is gone after the deletion fixture.
