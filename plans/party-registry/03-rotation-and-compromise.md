---
id: party-registry/03
type: task
layer: party-registry
satisfies: [2]
status: ready
depends_on: [party-registry/02]
migrations: []
binds: [design/stack-litigation/d4-verdict.md, design/ledger-design-0.1.md#3.3]
evidence: []
verified_by: null
---

# Rotation, renewal failure, compromise, and key-loss recovery

## Objective

Keys roll over by themselves. When they don't, the party's writes stop
loudly rather than continuing on a stale key quietly.

## Scope

- **ACME-style renewal**: the current key signs a registry challenge to
  activate its successor, which the party generated in its own
  environment. No out-of-band step, no operator involvement, no human in
  the path.
- Renewal windows open early enough that a failed attempt has room to
  retry before expiry; the schedule is registry-side, and the party is
  notified on failure through the party console and its registered
  operational contact.
- **Renewal failure halts that party's ingestion.** Loud and recoverable,
  never silent acceptance under an expired key (D4 §3). The halt is
  **derived, not stored**: a party is halted exactly when it holds no key
  whose validity window covers now. Exposed as a registry predicate over
  the key projection (task 02); no `halted` column exists anywhere, in
  keeping with the computed-not-stored rule decision 015 set for the
  activation gate.
- Compromise reporting: a party reports its own key compromised; the
  event lands in the kernel's key-event log. The kernel's existing rule
  governs: signatures ledger-stamped before the report stay valid,
  after it are flagged suspect. This task adds the reporting path and its
  authorization, not the verification rule.
- A party may hold overlapping valid keys during rotation; the
  verification path resolves by `kid`, never by "the party's current
  key."
- **Key-loss recovery ceremony, written rather than improvised.** ACME-style
  renewal assumes the current key still signs. It cannot cover missed
  expiry, cloud-account lockout, or admin compromise, and an unwritten
  ceremony is not an absent one, it is one invented under pressure in the
  exact place where improvisation destroys the D4 argument. Recovery is
  therefore **re-registration, not recovery**: the party proves possession
  of a fresh key through the ordinary task-02 challenge, gated on operator
  review and recorded as a registry event with its reason. **No privileged
  bypass path is created**. Recovery reuses the same registration code as a
  new party, so no new trusted path exists to audit.
- Recovery never reinstates the lost key and never backdates: signatures
  under the lost key keep their original validity, and the new key's window
  starts at activation.

## Acceptance

- AC (mechanical): a full rotation completes with no operator action and
  no gap in the party's ability to sign.
- AC (mechanical): with renewal blocked, ingestion for that party halts
  at expiry and returns a structured error naming the cause; other
  parties are unaffected.
- AC (mechanical): no schema path stores halt state, a schema assertion
  confirms the predicate is the only representation.
- AC (mechanical): a compromise report by party A cannot be filed against
  party B's key.
- AC (mechanical): recovery after total key loss goes through the ordinary
  registration challenge, asserted by proving no code path registers a key
  without proof of possession, recovery included.
- AC (mechanical): recovery neither reinstates the lost key nor backdates
  the new one; prior signatures keep their original validity.
- AC: signatures under both keys verify during the overlap window.

## Outside check

Verifier runs a rotation, blocks renewal and advances the clock past
expiry, confirms the halt is party-scoped, attempts a cross-party
compromise report, then destroys a party's key entirely and walks the
recovery ceremony end to end, confirming it produced a registry event, a
proof-of-possession challenge, and no backdated validity.
