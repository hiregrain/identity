---
id: party-registry
type: layer
status: ready
milestone: v1
depends_on: [foundation, trust-kernel]
binds:
  - decisions/LOG.md#005
  - decisions/LOG.md#007
  - decisions/LOG.md#015
  - decisions/LOG.md#016
  - design/stack-litigation/d4-verdict.md
  - design/ledger-design-0.1.md#3
acceptance: [AC-PR1, AC-PR2, AC-PR3, AC-PR4, AC-PR5, AC-PR6, AC-PR7]
evidence: []
verified_by: null
---

# party-registry

The single-root trust registry: who may attest, under what key, in what
state. Internal verticals, external partners, customer organizations
(decision 007), and verification vendors are all schema-identical party
entries; only vetting tier, capability grants, and trust weighting
differ, and all three live only here.

Scope: party lifecycle (`pending → active → suspended | revoked |
withdrawn`) as append-only `party_events` with closed-enum reason codes,
plus an **orthogonal freeze condition** that blocks new writes without
implying a finding; legal names as append-only rename events so historical
naming is reconstructible; public per-party status history at plain,
guessable URLs, carrying prior names; the
operator's own single self-entry, enforced unique, so ledger-issued
records verify through one lookup path; tiered vetting metadata held
orthogonal to individually granted, revocable capabilities
(`may_attest`, `may_request_packet`, `may_file_safety_marker` — the last
requiring a signed addendum on file per decision 015); key registration
for party-held keys (D4): proof of possession, 30–90-day validity,
ACME-style automated rotation with renewal failure halting that party's
ingestion (halt derived from key validity, never stored), a written
key-loss recovery ceremony that routes through ordinary registration
rather than a privileged bypass, the bootstrap-then-transfer kit deferred
to first external party per decision 005 sub-rulings; party principals as `party_users`,
structurally unlinkable to persons; suspension flags computed at read,
never written into attestations; invalidation *authority* for proven
fraud (the mechanism lives in `ingestion`); the registry-enforced
activation gate — **no external party can transition to `active` before
the witnessed transparency log exists** (D3), checked live and paired
with the executed liability-shield instrument; mandatory monthly party
countersignatures over their own issuance checkpoints, automated by the
integration kit.

Acceptance:
- AC-PR1 (mechanical): registry state transitions are append-only rows;
  attempting to activate an external-tier party without a live witnessed
  log, or without the recorded legal precondition, fails.
- AC-PR2: rotation completes unattended and a compromise report is
  filable only by the key's own party. (The *verification* rule — valid
  iff active at signing and pre-compromise — is `trust-kernel`'s
  AC and is not restated here; one guarantee, one owner.)
- AC-PR3: a suspended party's prior attestations remain cryptographically
  valid and acquire the derived read-time flag everywhere they render.
- AC-PR4 (mechanical): exactly one registry row may carry
  `custody_model: ledger_kms`, enforced by constraint; no code path signs
  with any other party's key.
- AC-PR5 (mechanical): `may_file_safety_marker` is unreachable without a
  *valid* addendum (signed, same party, effective, unrevoked, terms
  present), and no role can read both `party_users` and person tables.
- AC-PR6 (mechanical): a party parked in `pending` cannot outrun the D3
  deadline silently — crossing either limb without a witnessed log requires
  a signed governance event.
- AC-PR7 (mechanical): a suspended vendor flags the verification records
  whose evidence it produced and does not flag the operator generally.

## Outside check

Verifier attempts a second operator entry and each half of the operator
constraint independently, attempts activation with the witnessed log
stubbed absent, parks a party in `pending` past both deadline limbs,
attempts to derive a capability from tier alone, destroys a party key and
walks recovery, attempts the `party_users`-to-person join as every role,
and greps the schema for any free-text reason or detail column adjacent to
an adverse lifecycle event.
