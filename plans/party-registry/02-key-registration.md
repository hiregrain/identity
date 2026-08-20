---
id: party-registry/02
type: task
layer: party-registry
satisfies: []
status: ready
depends_on: [party-registry/01, trust-kernel/02]
migrations: [0015-party-keys]
binds: [design/stack-litigation/d4-verdict.md, decisions/LOG.md#015]
evidence: []
verified_by: null
---

# Key registration and proof of possession

## Objective

A party's public key enters the registry only after that party proves it
holds the matching private key, and the ledger never holds one.

## Scope

- `0015-party-keys` (spine): current-state projection over the kernel's
  `0006-key-event-log`: `{party_id, key_id, public_key, valid_from,
  valid_until, custody_model}`. The event log stays the source of truth;
  this is a read projection, rebuildable from events.
- **Registration challenge, fully specified**: the registry issues a
  single-use nonce with a short TTL, bound to the party id, the candidate
  public key, the requested custody model, the requested validity window,
  and the registration intent. The party signs it with the candidate key;
  the registry verifies against the submitted public key, consumes the
  nonce, and rejects expired, reused, or rebound challenges before any row
  lands. An unproven key is never registered, including for internal
  verticals. Underspecified here means an implementer picks a TTL and a
  binding set by guess.
- Validity windows: 30–90 days at registration, per D4 §3. A registration
  requesting a longer window is rejected, not clamped.
- `custody_model` recorded per key. Vendors register with `none` and
  have no key path at all (decision 015). The registration endpoint
  rejects them rather than accepting an unused key.
- **The no-party-key rule, enforced structurally** (trust-kernel/02
  deferred it): the signing provider's type and permission boundary makes a
  non-operator `kid` unrepresentable at the call site. The control is the
  boundary, not vigilance. A regression test additionally proves the
  boundary has not been widened later; the test is the alarm, not the
  control.
- Registry lookup by `kid` is the single verification path for
  operator-issued and party-issued signatures alike.

## Acceptance

- AC (mechanical): registration without a valid challenge signature
  fails; a challenge signed by a different key fails; a replayed nonce, an
  expired nonce, and a nonce rebound to a different party, key, custody
  model, or window each fail independently.
- AC (mechanical): a request for a 120-day window is rejected with a
  structured error.
- AC (mechanical): a non-operator party `kid` is unrepresentable at the
  signing boundary, proven by a compile/type-level or permission-level
  assertion, with a regression test that fails if the boundary widens.
- AC: the projection rebuilds byte-identically from the key-event log.

## Outside check

Verifier replays a captured challenge, registers with a mismatched key,
attempts vendor key registration, and attempts to reach a signing call
with a partner `kid` from every service entry point.
