---
id: person-identity/07
type: task
status: ready
depends_on: [person-identity/01, consent-and-deletion/01]
migrations: [0014-enrollment-tokens]
binds: [decisions/LOG.md#013]
evidence: []
verified_by: null
---

# The enrollment token and re-registration

## Objective

"You can delete your record; you do not get a second identity" —
implemented as a universal, contentless token that survives deletion and
carries no judgment about anyone.

## Scope

- `0014-enrollment-tokens` (spine): one-way hashes of verified document
  identifiers (primary strength), plus phone/email if present (weak),
  with enrollment counts and timestamps. **No outcome tag, no cause
  label, no reputation content** — this is what keeps it lawful (fraud
  prevention is the named legitimate interest; retaining a judgment is
  not) and simple (no cause classification, no adjudication surface, no
  race condition where a bad actor deletes before a finding lands).
- Never expires (decision 013; counsel brief 1 carries the question —
  a window would be a config value, not a redesign).
- Written at verification and at deletion; survives payload purge.
- Re-registration matching a token: **new ledger id, internally linked**
  (a tombstoned id is never reissued — spine signatures reference it
  forever). First match: account usable, flagged for steward review.
  Repeat velocity: account created but **restricted** — no verification,
  no attestations, no grants — pending steward decision. **No automatic
  hard block.**
- Disclosure at deletion, plain language, in the confirmation flow and
  the consent instrument: the record is unrecoverable; the identity
  remains known; re-signup with the same documents will be recognized and
  may require review.
- Consequence to document, not fix: an account deleted before any
  verification leaves only weak channel tokens. Acceptable — an
  unverified account carried nothing worth escaping.

## Acceptance

- AC (mechanical): after deletion, the token contains no readable
  personal data and cannot be reversed to any identifier (proven against
  a raw dump).
- AC (mechanical): re-registration with the same verified document
  produces a new id, an internal linkage record, and a steward flag —
  never a reissued id and never an automatic denial.
- AC (mechanical): the restriction ladder triggers on count, not on any
  stored judgment (asserted by schema: no outcome column exists).
- AC: the deletion confirmation surfaces the disclosure text.

## Outside check

Verifier deletes a verified profile, inspects spine remnants for
readable data, re-registers with the same document, and confirms the
flag/restriction behavior and the absence of any hard block.
