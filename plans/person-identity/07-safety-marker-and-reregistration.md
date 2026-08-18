---
id: person-identity/07
type: task
status: ready
depends_on: [person-identity/01, consent-and-deletion/01, party-registry/01]
migrations: [0014-safety-markers]
binds: [decisions/LOG.md#014, research/12-deletion-vs-reputation-evasion.md]
evidence: []
verified_by: null
---

# Safety markers and re-registration

## Objective

Nothing survives deletion by default. The one exception — a
severity-gated safety/fraud marker filed by the party that made the
finding — is narrow, expiring, challengeable, and can never deny service
on its own.

Supersedes the universal enrollment token (decision 014 over 013): a
contentless universal flag is what the AEPD fined Goldcar €80,000 for
("does not refer with certainty to a fraud committed by the claimant"),
and CNIL expressly excludes cross-party mutualised registers.

## Scope

- **Default path: total erasure.** Deletion of a profile with no safety
  marker leaves no token, hash, or residue keyed to the person
  (`consent-and-deletion` owns the purge; this task owns the assertion
  that nothing identity-shaped is written).
- `0014-safety-markers` (spine): marker rows carrying **only** —
  `document_identifier_hash`, `filing_party_id`, `category` (closed enum,
  most-critical safety/fraud only, Uber/Lyft ISSP-scoped), `filed_at`,
  `expires_at` (fixed clock, no discretionary extension),
  `challenge_state`. **No payload, no narrative, no performance content,
  no cause description.** Schema-enforced: there is no column a finding's
  details could occupy.
- **Filing is a party act.** Only a registered party may file, only
  against its own finding, and only on attestation that the evidential
  floor is met ("could confidently report to the police"). Filing is
  itself append-only and attributable. This is also what handles the
  delete-before-the-finding race: the party holds its own work records
  regardless of ledger deletion and may file after the fact.
- **Joint controllership** with the filing party recorded on the marker;
  worker challenges route to that party, with the ledger tracking state
  and the expiry clock running regardless of challenge outcome.
- **Match behavior: review, never denial.** A re-registration matching a
  live marker creates a usable-but-restricted account (no verification,
  attestations, or grants) pending steward review. No automatic hard
  block exists anywhere in the code path.
- Re-registration mechanics independent of markers: new ledger id always
  (tombstoned ids are never reissued — spine signatures reference them
  forever); linkage recorded internally; steward flag raised.
- Disclosure at collection (not merely at deletion): the consent
  instrument states that a party may file a safety marker meeting the
  evidential floor, that it expires, and how to challenge it.

## Acceptance

- AC (mechanical): deleting a profile with no marker leaves nothing
  keyed to the person anywhere in spine or payload (raw-dump assertion).
- AC (mechanical): no schema path exists to store finding details,
  performance content, or a cause narrative on a marker.
- AC (mechanical): a marker past `expires_at` is inert on every read
  path; expiry cannot be extended by any API.
- AC (mechanical): no code path converts a marker match into a denial —
  restriction plus review only.
- AC: only the filing party can file, challenge routing reaches that
  party, and challenge state is worker-visible.

## Outside check

Verifier deletes an unmarked profile and greps a raw dump; files a marker
as a party and confirms field-level minimality; advances the clock past
expiry and confirms inertness; attempts denial through every re-
registration path; and confirms a second party cannot file against
another party's finding.
