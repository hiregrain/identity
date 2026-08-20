---
id: self-asserted-record/05
type: task
layer: self-asserted-record
satisfies: [2, 5]
status: ready
depends_on: [self-asserted-record/01, self-asserted-record/03]
migrations: [0027-import-proposals]
binds: [decisions/LOG.md#062, decisions/LOG.md#063]
evidence: []
verified_by: null
---

# Import proposal contract, stub proposer, and confirmation flow

## Objective

Imported claims exist only after the worker says yes to each of them,
and a dead import always lands the worker in manual entry.

## Scope

- The proposal payload contract: the shape `extraction` must produce,
  defined here because this layer is the consumer. Every proposed field
  carries its source span; absent fields are blank, never inferred; a
  per-claim and per-match confidence slot exists but nothing reads a
  threshold yet (task 09).
- `0027-import-proposals` (payload plane): the short-lived staging
  store holding proposals and the extracted text layer while the
  worker reviews, TTL in hours per decision
  062, swept on expiry; the uploaded artifact's bytes are never
  written to any table or disk, resolved by decision 073.
- The upload disclosure (decisions 058/073): one sentence at upload
  stating the resume's text goes to a named third-party processor, and
  a consent flag recorded with the upload; no extraction call happens
  without the flag.
- The stub proposer: a fixture implementation of the contract, so this
  task and criterion 2 verify without `extraction` existing.
- The confirmation flow: per-claim confirm, edit, and discard; commit
  writes through task 01's recording functions with
  `origin: resume_parsed` and the confirmation reference schema §10
  requires (constraint shipped in `0023-record-objects`, exercised
  here). A confirmed institution match writes `institution_ref` through
  task 03's flow, which is why 03 is a dependency. Positions ride their
  chapter: no separate origin or confirmation per position. Batch
  commit plumbing exists but routes every batch to per-claim until task
  09 lands a threshold.
- Failure fallback: any import-path failure (unreadable file, proposer
  error, staging expiry) resolves to the manual-entry path with the
  worker's typed progress intact; no failure state dead-ends.

## Acceptance

1. AC (mechanical): no imported claim row exists without a confirmation
   reference, enforced by the database constraint; a commit attempt
   without one fails at the recording function and at the table.
2. AC (mechanical): every committed imported chapter, education, and
   credential carries `self_asserted` provenance and
   `origin: resume_parsed`; discarded and
   expired proposals leave no trace in the record tables.
3. AC (mechanical): the staging sweep removes expired proposals and
   text layers; the artifact's bytes appear in no table and on no disk
   at any point, proven by grep of the import code for file and byte
   writes plus a planted-artifact scan during and after the flow.
4. AC (adjudicated): each failure mode in scope resolves to manual entry
   with no dead end; the verifier walks unreadable-file, proposer-error,
   and expiry against the stub.
5. AC (mechanical): no extraction call happens without the recorded
   consent flag, proven by a flagless red-path fixture; the disclosure
   copy is present at the upload step.

## Outside check

Verifier runs the confirmation fixtures against the stub proposer only,
attempts the unconfirmed commit, and runs the planted-artifact scan
post-import.
