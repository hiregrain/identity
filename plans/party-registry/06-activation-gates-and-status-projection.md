---
id: party-registry/06
type: task
layer: party-registry
satisfies: [3, 6, 7]
status: ready
depends_on: [party-registry/01, party-registry/05, trust-kernel/04]
migrations: [0018-party-activation-preconditions]
binds: [decisions/LOG.md#005, decisions/LOG.md#015, design/stack-litigation/d3-verdict.md]
evidence: []
verified_by: null
---

# Activation gates and derived status

## Objective

No external party goes live before the tamper-evidence infrastructure and
the legal instrument both actually exist, and neither condition is a
checkbox anyone can flip.

## Scope

- **Limb 1, technical**: activation queries the kernel live: does a
  witnessed transparency log exist and is it accepting entries. **No
  stored boolean** (decision 015: a cached flag is one UPDATE away from
  being flipped under deadline pressure).
- **Limb 2, legal**: `0018-party-activation-preconditions` records the
  executed conditional liability-shield instrument (design §3.1,
  research/06 §5), and **validates it rather than merely pointing at
  it**: party identity, instrument version, execution status, effective
  date, jurisdiction, and applicability to this party's scope. "Recorded
  by reference" with no conditions is satisfiable by garbage. Activation
  without a valid instrument fails.
- Both limbs are re-asserted by a check, not only evaluated at the
  transition. A party activated correctly under conditions that later
  lapsed is surfaced, not silently fine.
- **The 1M-attestation limb of decision 005 is a build deadline for the
  log, not a route to activation.** No code path consumes it as an
  activation input; a check asserts this.
- **The deadline clock starts at `pending`, and slipping is a signed act.**
  Gating activation alone leaves "pending forever" as a silent escape
  hatch: a party parked in `pending` never trips either limb, and a
  launch-blocking obligation quietly becomes an aspiration. So: an external
  party reaching `pending` starts the log-build clock; both limbs (first
  external party, 1M records) are tracked and reported; crossing either
  without a witnessed log requires an explicit **signed governance event**
  naming who accepted the slip and why. Slipping stays possible, it
  cannot happen silently, which is the actual requirement.
- Internal verticals are gated on limb 2 only; the witnessed-log gate is
  scoped to external tiers, per D3.
- **Derived read-time status**: the "issuer since suspended (reason
  class)" flag is computed from the registry at read and rendered
  wherever an affected attestation surfaces. Nothing is written into the
  attestation. `withdrawn` renders distinctly from `revoked` and carries
  no adverse flag; a freeze renders as a pending review, never adverse.
- **Status derives from the evidence source, not only the signer.** Under
  decision 015 the ledger signs verification attestations with the vendor
  recorded as `evidence_source`. Keying status off the signer alone would
  flag *the operator* on every verification record when a vendor is
  suspended, and leave the vendor's results rendering clean, exactly
  backwards. Status computation therefore takes both inputs: a suspended
  vendor flags the records whose evidence it produced, without implicating
  the ledger's signature. Cryptographic validity and substantive
  reliability stay two separately rendered facts.

## Acceptance

- AC (mechanical): with the witnessed log stubbed absent, external
  activation fails; internal activation succeeds.
- AC (mechanical): with the log present but the legal precondition
  missing, activation fails, and fails independently for each defect:
  wrong party, wrong version, unexecuted, not yet effective, wrong
  jurisdiction, out of scope.
- AC (mechanical): an external party reaching `pending` starts the clock;
  crossing either deadline limb without a witnessed log is refused unless a
  signed governance event exists.
- AC (mechanical): suspending a vendor flags the verification records whose
  evidence it produced and flags nothing signed by the operator generally.
- AC (mechanical): no code path reads the attestation-count metric as an
  activation input, proven by call-site assertion.
- AC (mechanical): suspending a party changes what every read renders and
  changes no stored attestation byte, proven by hashing the attestation
  rows before and after.
- AC: `withdrawn` produces no adverse flag on any surface.

## Outside check

Verifier stubs the log absent and attempts activation by every path,
plants one defective instrument per condition, parks a party in `pending`
and advances past both deadline limbs to confirm the refusal, suspends a
vendor and inspects what flags appear on verification versus other records,
hashes attestation rows across a suspension, and greps for consumers of the
deadline metric.
