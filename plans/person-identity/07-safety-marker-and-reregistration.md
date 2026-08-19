---
id: person-identity/07
type: task
layer: person-identity
satisfies: [4, 5, 6, 7]
status: ready
depends_on: [person-identity/01, consent-and-deletion/01, party-registry/01]
migrations: [0014-safety-markers]
binds: [decisions/LOG.md#014, decisions/LOG.md#015, decisions/LOG.md#017, decisions/LOG.md#019, decisions/LOG.md#020, research/12-deletion-vs-reputation-evasion.md]
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
  marker leaves no token, hash, or residue keyed to the person. Evidence is
  decision 017's, not a dump grep alone: content unreadable after key
  destruction through every path, the alias closure destroyed with the
  person, the scheduled purge run, and a restore replaying the deletion
  journal before serving. (`consent-and-deletion` owns the saga;
  `foundation/08` owns purge, backups, and restore; this task owns the
  assertion that nothing identity-shaped is written here.)
- **The match key is a keyed hash, not a plain one** (decision 020).
  Document identifiers are low-entropy and follow published per-country
  formats, so a plain hash is enumerable: generate every valid number for a
  jurisdiction, hash each, compare. That would make this table a
  de-anonymizable list of who has been flagged — the structure the AEPD
  fined over, and the precise re-identification capability decision 014's
  *EDPS v SRB* analysis says makes a value personal data. Required, in full:
  keyed hash (HMAC or equivalent) with **the key held in the key management
  service and never in the database**, so possession of the table is
  useless; **issuer and document-type canonicalization**, so one document
  written two ways yields one key; a **key-rotation and re-derivation
  story** with its window stated, since re-keying needs the source document;
  a **collision policy**; and a written **brute-force analysis** against the
  weakest jurisdiction's format.
- `0014-safety-markers` (spine): marker rows carrying **only** —
  `document_identifier_keyed_hash`, `filing_party_id`, `category` (closed
  enum, most-critical safety/fraud only, Uber/Lyft ISSP-scoped), `filed_at`,
  `expires_at` (fixed clock, no discretionary extension).
- **Challenge state is append-only events, not a column** (decision 020).
  Challenges change over time, and a mutable field on an append-only marker
  row is a contradiction; current state is an explicitly defined projection
  over challenge events.
- **Marker filings and steward approvals are hash-chained and anchored**
  (decision 019 added privileged operator actions and governing events to
  chained coverage). A marker filing is the highest-exposure governing act
  in the system; it belongs in the anchored set rather than in ordinary
  audit logging. **No payload, no narrative, no performance content,
  no cause description.** Schema-enforced: there is no column a finding's
  details could occupy.
- **Filing is a party act, under an individually granted capability.**
  Only a party holding a live `may_file_safety_marker` grant may file
  (decision 015 — the capability is granted per party, revocably, and
  never implied by vetting tier), only against its own finding, and only
  on attestation that the evidential floor is met ("could confidently
  report to the police"). The grant itself requires a signed addendum on
  file, because filing imposes joint controllership and challenge-routing
  duties a party must have accepted. Filing is
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

- AC (mechanical): deleting a profile with no marker leaves nothing keyed
  to the person anywhere in spine or payload — asserted through decision
  017's evidence set (unreadable through every path, alias closure
  destroyed, purge run, restore replay honored), not by a dump grep alone.
- AC (mechanical): the match key is a keyed hash whose key is absent from
  the database — proven by attempting derivation with full database access
  and failing.
- AC (mechanical): the same document expressed two ways canonicalizes to
  one key; two different documents do not collide under the stated policy.
- AC (mechanical): challenge state is reconstructible from events; no
  mutable challenge column exists.
- AC (mechanical): a marker filing appears in the chained and anchored
  governing-event stream.
- AC (mechanical): no schema path exists to store finding details,
  performance content, or a cause narrative on a marker.
- AC (mechanical): a marker past `expires_at` is inert on every read
  path; expiry cannot be extended by any API.
- AC (mechanical): no code path converts a marker match into a denial —
  restriction plus review only.
- AC (mechanical): a party without a live `may_file_safety_marker` grant
  cannot file, including a fully vetted `external_standard` party — tier
  confers nothing.
- AC (mechanical): revoking the grant blocks new filings and leaves
  existing markers untouched.
- AC: only the filing party can file, challenge routing reaches that
  party, and challenge state is worker-visible.

## Outside check

Verifier deletes an unmarked profile and runs decision 017's full evidence
set against it; attempts to derive the match key with full database access;
canonicalizes one document written two ways; files a marker
as a party and confirms field-level minimality and its presence in the
anchored stream; advances the clock past
expiry and confirms inertness; attempts denial through every re-
registration path; attempts a filing as a vetted party holding no grant,
and again after revoking a grant; and confirms a second party cannot file
against another party's finding.
