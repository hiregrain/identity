---
id: worker-surface/06
type: task
layer: worker-surface
satisfies: [1, 2, 3, 5, 6, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#035
  - decisions/LOG.md#045
  - decisions/LOG.md#056
  - decisions/LOG.md#057
  - decisions/LOG.md#059
  - design/13-platform-screens
evidence: []
verified_by: null
---

# Sharing, grants, and the public page

## Objective

Where custody is exercised. Everything here is the worker deciding who
reads the record, and for how long.

Surfaces implemented: G1, G2, G5, G6.

## Scope

- The sharing destination, public page management, sending the record to a
  named person, and grant detail with revocation.
- **A grant goes to a named recipient and is not a forwardable link**
  (decision 057). The recipient proves control of the address before reading
  anything, and the grant ends on its own date.
- **The public page is off by default** (decision 056). The imprint renders
  for human visitors and never for a crawler.
- **Grant state is shown; reads are not** (decision 035 §B4). Revoking stops
  access from that moment and does not erase that the grant existed.
- Sharing is a destination reached from the bar, not a section of the record
  (decision 045).
- **The public page itself is not built here.** It is a separate
  server-rendered app per decision 037 and belongs to `public-web`.

## Acceptance

1. **A new record's public page is off.** (mechanical) the public page defaults to off on a newly created record,
  asserted on the stored state rather than the toggle's rendering.
2. **Nothing here surfaces a read event.** (mechanical) no surface in this task exposes a read event or any value
  derived from one.
3. **Revoking a grant stops it resolving from that moment.** (mechanical) a revoked grant stops resolving immediately, proven by
  attempting a read with the recipient's credential after revocation, and the
  grant remains listed as having existed.
4. **Grant, revoke and send each finish on a small phone over a slow link.** (mechanical) grant, revoke and send each complete on a 360px viewport
  over a throttled connection, driven end to end.
5. **Nothing offers a partial grant or implies one is possible.** (adjudicated) no surface offers a partial grant or implies one is
  possible, because a selection is itself a claim.

## Outside check

Verifier creates a grant, reads with it, revokes it, and confirms the read
fails immediately while the disclosure list still shows the grant existed and
when it ended.
