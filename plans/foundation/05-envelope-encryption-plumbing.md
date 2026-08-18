---
id: foundation/05
type: task
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
  lands). No caller can tell which is active.
- `0005-dek-registry` (payload chain): per-person wrapped-DEK table with
  key state (`active | destroyed`), destruction recorded as its own row
  (append-only), never an update.
- Payload write/read paths encrypt/decrypt through the person's DEK;
  content columns store ciphertext.
- Destruction semantics: `destroy(person)` transitions the DEK, after
  which reads fail closed — this is one leg of deletion
  (consent-and-deletion owns the full saga; this task owns the primitive).

## Acceptance

- AC (mechanical): after `destroy`, no payload row for the person is
  readable through any code path, and the plaintext is unrecoverable from
  a raw database dump (proven by test inspecting the dump).
- AC: provider swap (software ↔ stub-KMS) via config only; the test suite
  passes against both.

## Outside check

Verifier runs the destroy test, takes a raw dump, greps for planted
plaintext markers, and confirms absence; re-runs the suite under the
alternate provider.
