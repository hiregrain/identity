---
id: ingestion/04
type: task
layer: ingestion
satisfies: [7]
status: ready
depends_on: [ingestion/01, person-identity/06]
migrations: [0031-pairwise-pseudonyms]
binds: [model/attestation-interface.md, decisions/LOG.md#028, decisions/LOG.md#068]
evidence: []
verified_by: null
---

# Subject resolution and the pairwise-pseudonym mapping

## Objective

A party names a subject by a pseudonym only it knows; the ledger
resolves the person; a merge never tells the party anything happened.

## Scope

- `0031-pairwise-pseudonyms`: the per-partner mapping (A-6, decision
  068), derivation keyed per partner, one stable pseudonym per
  (partner, person). This layer owns the table; prior-packet reads it
  in v1 for the down direction.
- Resolution at ingestion: `subject_id` arrives as the party's
  pseudonym and resolves through the alias closure to the surviving
  `ledger_person_id`; the ledger id appears in no party-facing payload
  anywhere.
- Merge invisibility: resolution happens before pseudonym lookup, so a
  merged person's existing pseudonyms keep resolving and no partner's
  key changes.
- An attestation naming a pseudonym with no living person behind it is
  rejected pre-confirmation (the interface's waits-until-the-reference-
  exists rule).

## Acceptance

1. AC (mechanical): the same person yields different pseudonyms for
   two partners; the same partner gets the same pseudonym across
   requests; no party-facing payload in any fixture contains a
   `ledger_person_id`, proven by a scan over captured responses.
2. AC (mechanical): after a merge, both prior pseudonyms resolve to
   the surviving identity and neither partner's pseudonym changed;
   after an unmerge, resolution is restored, riding
   person-identity/06's fixtures.
3. AC (mechanical): an attestation for an unknown pseudonym is
   rejected before confirmation with a structured error.

## Outside check

Verifier runs the merge and unmerge fixtures, scans every captured
party-facing payload for ledger ids, and submits against an unknown
pseudonym.
