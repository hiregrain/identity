---
id: party-registry/04
type: task
status: ready
depends_on: [party-registry/01, foundation/03]
migrations: [0016-party-principals]
binds: [decisions/LOG.md#007, decisions/LOG.md#015]
evidence: []
verified_by: null
---

# Party principals

## Objective

The humans who administer a party can log in — without becoming, or
becoming linkable to, subjects of the ledger.

## Scope

- `0016-party-principals` (spine, **its own schema**): `party_users` —
  auth records scoped to a party, with hardware-bound WebAuthn credentials
  (D4 §5, security-infra §4.4). No static API keys anywhere in this path.
- **The invariant is unlinkability, not absence of identifying data.** An
  admin login needs an email; pretending otherwise produced a
  self-contradicting spec. The real invariant, and what decision 007
  actually protects, is: **no foreign key to a person, no shared
  identifier, and no role that can read both `party_users` and the person
  tables.**
- **Enforced by schema separation and role grants, not by intent**, using
  the general schema-boundary posture established in `foundation/03`
  (decision 017) rather than a mechanism invented here. `party_users` lives
  in its own schema and the pair (`party_users`, person tables) is
  registered as a declared incompatible pair: no role holds SELECT on both,
  and the cross-schema lint fails any query touching both.
- **Duplicate detection is barred from linking `party_users` to
  persons** — now a consequence of the role split rather than a rule the
  matcher must remember. The founder noted the same human may separately
  hold a worker record; matching across the two would reconstruct exactly
  the linkage decision 007 forbids.
- Role model within a party: admin (manages principals and keys) and
  member (reads the issuance feed). No role grants capability — party
  capabilities are party-level grants (task 01), never delegated to a
  principal.
- **Principals are erasable; their actions are not.** A party admin is a
  natural person with erasure rights, and the reason worker records are
  append-only — attestations must survive to stay verifiable — does not
  apply to a console login. Actions carry an opaque `actor_id` that
  outlives the principal record, so the audit trail keeps every row and
  keeps "the same actor did these things" without holding the person's
  identity. Erasure removes the principal row and any identifying
  columns; the `actor_id` remains.
- This requires an explicit UPDATE/DELETE grant on `party_users` under
  foundation/03's documented exemption license, named per table in this
  migration with the erasure rationale cited.

## Acceptance

- AC (mechanical): `party_users` carries no foreign key to a person and
  no shared identifier; a schema assertion enforces it.
- AC (mechanical): no role can read both `party_users` and the person
  tables — proven by attempting the join as every defined role and having
  each fail at the permission layer.
- AC (mechanical): the duplicate matcher, given a `party_user` and a
  person with identical contact details, produces no candidate — proven
  against the live matcher, not a stub.
- AC (mechanical): no authentication path accepts a static secret.
- AC (mechanical): erasing a principal removes every identifying column
  and leaves every action row intact, still grouped by `actor_id` —
  proven by a raw-dump assertion plus an action-count check before and
  after.
- AC (mechanical): the exemption grant is table-scoped; the append-only
  test from foundation/03 still passes against every other table.

## Outside check

Verifier seeds a `party_user` and a person sharing name, email, and
phone, attempts the join as each defined role, runs the matcher, and
confirms silence; erases a principal with
prior actions and greps a raw dump for their identifiers while confirming
the action rows survive; then attempts console authentication with a
bearer token.
