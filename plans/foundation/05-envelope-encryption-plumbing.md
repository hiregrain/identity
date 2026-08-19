---
id: foundation/05
type: task
layer: foundation
satisfies: []
status: ready
depends_on: [foundation/04]
migrations: [0005-dek-registry]
binds:
  - decisions/LOG.md#011
  - design/ledger-design-0.1.md#2.5
evidence: []
verified_by: null
---

# Envelope-encryption plumbing

## Objective

Per-person data-encryption keys (DEKs) wrapping payload content, behind a
key-provider interface — so R2 deletion can crypto-shred and the
software/KMS split from decision 011 is a config choice, not a code path.

## Scope

- Key-provider interface: `wrap/unwrap/destroy` — two implementations:
  software provider (local/CI; keys ephemeral, decision 011) and the KMS
  provider (production; stub-tested now, wired when the cloud ruling
  lands). **Business logic is provider-agnostic; operational code is not.**
  The invariant is that no business path branches on which provider is
  active — not that the provider is invisible, because observability, audit
  records, and incident response legitimately need to know which one served
  a request.
- **Verification gap, named rather than discovered later:** decision 011
  ruled out a standing staging environment, and the KMS provider is
  stub-tested only. No environment currently exercises real KMS before
  production. The mitigation adopted here is a **provider conformance suite
  the real KMS must pass in an ephemeral environment before first
  production use**, run as part of the provisioning gate rather than left
  to first contact.
- `0005-dek-registry` (payload chain): per-person wrapped-DEK table with
  key state, destruction recorded as its own row (append-only), never an
  update. Because state is derived from an append-only log, the derivation
  is specified rather than implied: **at most one active DEK per person at
  any instant** (enforced by constraint, not convention), current state
  resolved by a single documented rule, and destruction **idempotent** — a
  second destroy is a no-op, not an error and not a second row.
- **DEK ownership: subject-scoped, single owner** (decision 017). A payload
  row about a person is encrypted under **that person's key alone**, even
  when the row records an attestation another party wrote. Deleting the
  person makes it unreadable to everyone including the issuing party. This
  is consistent with decision 014, whose reasoning already depends on
  parties holding their own work records outside the ledger; the partner
  agreement must state plainly that the ledger-side copy does not survive
  the subject's deletion. Rows concerning more than one person are keyed to
  the **subject**, never dual-wrapped — a dual wrap leaves a readable copy
  of a deleted person's record, which is the structure decision 014
  rejected.
- Payload write/read paths encrypt/decrypt through the person's DEK;
  content columns store ciphertext.
- Destruction semantics: `destroy(person)` transitions the DEK, after
  which reads fail closed. Specified rather than assumed: it is
  **idempotent**, safe under **concurrent reads and writes** (an in-flight
  read either completes against the live key or fails closed, never returns
  partial plaintext), and defined for **merged identities** — destroying a
  merged person destroys the DEKs of every id in its alias closure, since a
  surviving pre-merge key would leave the record readable.
  `consent-and-deletion` owns the full saga; `foundation/08` owns purge,
  backups, and restore; this task owns the primitive.

## Acceptance

- AC (mechanical): after `destroy`, no payload row for the person is
  readable through any code path. Evidence is **stronger than a dump
  grep**: a grep only proves one planted literal string is absent. Also
  asserted — every payload content column is ciphertext under the expected
  key scope, no plaintext appears in logs or error messages, no derived or
  denormalized plaintext column exists, and decryption fails after
  destruction rather than returning anything.
- AC (mechanical): a row about two people is readable only via the
  subject's key; no second wrap exists, asserted at the schema level.
- AC (mechanical): `destroy` is idempotent; a concurrent read during
  destruction either completes or fails closed and never returns partial
  plaintext.
- AC (mechanical): destroying a merged person destroys every DEK in its
  alias closure.
- AC (mechanical): at most one active DEK per person, enforced by
  constraint.
- AC: provider swap (software ↔ stub-KMS) via config only; the test suite
  passes against both.

## Outside check

Verifier runs the destroy test, takes a raw dump and greps for planted
markers, inspects every payload content column for ciphertext and every log
sink for leakage, destroys twice, races a read against a destroy, destroys a
merged identity and checks every alias, and re-runs the suite under the
alternate provider.
