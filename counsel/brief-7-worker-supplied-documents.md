# Counsel engagement brief 7: what Grain asserts by accepting a worker-supplied document

**Jurisdictions:** United States (federal FCRA and state analogues), European Union, United Kingdom, Philippines, India
**Date prepared:** 2026-08-20
**Status of this document:** Instructions to counsel. This is a question put, not advice received. The product decision it concerns has already been taken (decision 062) with conservative defaults; the build does not wait on the answer, and the answer may change the defaults.

---

## 1. Background

Grain operates a worker-owned work-history ledger. Claims carry an
explicit provenance class (`self_asserted`, `peer_attested`,
`party_attested`); party attestations are cryptographically signed by
registered attesting parties. The ledger holds no document images from
identity verification by standing rule.

Decision 062 admits a new artifact class: a worker may attach a document
they supply themselves (a completion certificate, a license scan, a
stamped drawing, a contract) to a self-asserted credential record. The
defaults in force:

1. The file is stored encrypted under the subject's own key and is
   destroyed with the profile at deletion.
2. A reading party is told "document on file, self-asserted" and never
   receives the file.
3. The document's presence never changes the claim's provenance class.
   An uploaded PDF is not verification and no surface renders it as
   such.

## 2. The questions

1. **Assertion by acceptance.** When Grain accepts, stores, and signals
   the existence of a worker-supplied document, what if anything does
   Grain thereby assert to a reading party about the document's
   authenticity? Does the phrase "document on file, self-asserted"
   adequately disclaim authentication, or does the mere signal that a
   document exists carry an implied representation in any listed
   jurisdiction?
2. **CRA and analogous perimeter.** Does storing and signaling
   worker-supplied documents, without evaluating them, move Grain toward
   consumer-reporting or background-screening regulatory perimeters in
   the US, or equivalent regimes elsewhere, given that reading parties
   may use the record in hiring decisions?
3. **Forged documents.** If a worker uploads a forged certificate and a
   reading party later relies on the record, what is Grain's exposure
   under each jurisdiction, and does exposure change if Grain runs any
   automated screening on uploads (malware, image type) versus none?
   We need to know whether partial screening creates a duty that
   no-screening does not.
4. **Deletion and retention.** The file dies at profile deletion by
   design. Does any listed jurisdiction impose a retention duty on such
   documents once a dispute or investigation is open, and does India's
   DPDP retention rule (the question already with counsel from
   research/14 §2) reach worker-supplied files?
5. **Wording.** If the answer to question 1 recommends different or
   additional language, provide the language. The current copy is one
   sentence and we would like to keep it to one sentence.

## 3. What this brief does not ask

Whether to accept documents at all: decided (decision 062). Whether
documents should influence provenance or scoring: decided, they never
do. The verification of documents by Grain or by parties is a future
layer and will be briefed separately when scoped.
