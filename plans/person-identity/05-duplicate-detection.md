---
id: person-identity/05
type: task
layer: person-identity
satisfies: [3]
status: ready
depends_on: [person-identity/04]
migrations: [0012-match-candidates]
binds: [decisions/LOG.md#013, research/03-person-id-and-merge.md]
evidence: []
verified_by: null
---

# Duplicate detection

## Objective

Find likely duplicate identities continuously, rank them for human
review, and never act on them automatically.

## Scope

- Multi-field probabilistic matching (Fellegi-Sunter): `name_index`
  candidates, contact channels, document identifiers where verification
  captured them, and, as **triage evidence only, never identity proof**,
  IP and device signals (grain prior art: cafés, offices, VPNs and
  shared households produce false matches; PH/India populations use
  internet cafés heavily).
- Runs at signup and continuously as new evidence arrives (a later
  verification can reveal a duplicate invisible at signup).
- `0012-match-candidates`: candidate pairs with per-signal contributions
  and a total score, append-only, feeding the steward queue
  (`operator-console` owns the UI).
- Worker-initiated linking: a pull-only path ("I have another account").
  **No proactive disclosure of suspected duplicates** (decision 013,
  it leaks the existence of a matching account and teaches thresholds).
- Auto-merge permitted only where both records are attestation-free and
  match on strong evidence (same verified document); everything else
  queues.
- Expect meaningful organic duplicate volume (research/03: up to ~10%);
  instrument rates from day one.

## Acceptance

- AC (mechanical): no code path merges records where either carries an
  attestation.
- AC (mechanical): candidate scores are reproducible from stored
  per-signal contributions (auditable, not a black box).
- AC: no API or UI response reveals the existence of a candidate match
  to a worker.
- AC: a fixture set of known duplicates/non-duplicates (incl. common
  surnames, transliteration variants, shared household IP) produces
  ranked candidates without false auto-merges.

## Outside check

Verifier runs the fixture set, attempts a merge on an attested pair via
every available path, and probes the worker-facing API for candidate
leakage.
