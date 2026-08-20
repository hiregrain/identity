---
id: self-asserted-record/04
type: task
layer: self-asserted-record
satisfies: [7]
status: ready
depends_on: [self-asserted-record/01]
migrations: [0026-credential-documents]
binds: [decisions/LOG.md#062, decisions/LOG.md#063, model/record-schema.md]
evidence: []
verified_by: null
---

# Credential document attachment

## Objective

A worker can attach a certificate to a credential record, the file dies
with the profile, and its existence never reads as verification.

## Scope

- `0026-credential-documents` (payload plane): document blob storage
  under the subject's DEK through foundation/05's envelope plumbing;
  `document_ref` on `credential` per schema §9.
- Accepted types and size cap defined here and enforced at the recording
  function; rejection is a structured error.
- Deletion: the blob is inside the subject's DEK scope, so profile
  deletion kills it through the existing foundation/08 mechanics;
  detaching a document from an unfrozen credential removes the blob.
- Provenance untouched: attaching, detaching, or replacing a document
  never writes `provenance`, enforced by the recording function having
  no such parameter.
- What any packet renders is prior-packet's inherited criterion, not
  this task.

## Acceptance

1. AC (mechanical): a document attaches to a credential and is readable
   back only through the payload plane under the subject's DEK; no
   other read path exists, proven by the envelope test pattern.
2. AC (mechanical): attaching and detaching leave `provenance` unchanged
   byte-for-byte; no recording function accepts a provenance argument on
   the document path.
3. AC (mechanical): profile deletion destroys the blob with the DEK; the
   deletion fixture plants a document and proves it unreadable
   post-deletion.
4. AC (mechanical): an oversized or wrong-type upload is rejected with a
   structured error and no partial blob persists.

## Outside check

Verifier runs the envelope and deletion fixtures with a planted
document, and greps the document write path for any provenance touch.
