---
id: self-asserted-record/08
type: task
layer: self-asserted-record
satisfies: [10]
status: draft
depends_on: [self-asserted-record/01, party-registry/01]
migrations: []
binds: [decisions/LOG.md#051, decisions/LOG.md#063, decisions/LOG.md#064]
evidence: []
verified_by: null
---

# Issuer matching against the party registry

## Objective

A credential issuer that is a registered party gets linked, confirmed by
the worker, and the raw issuer string survives either way.

## Scope

- Draft by the gated_criteria convention: criterion 10 is gated on the
  party registry, a v1 layer, so this task cannot go ready inside
  first-product (decisions 051, 063). It exists so the criterion's
  satisfying task is declared rather than implied. **Promotion to
  ready is the gate and happens only when the party-registry layer is
  done**; the depends_on edge on party-registry/01 orders work but the
  ruling is layer-done, and draft status is what enforces it.
- When workable: the confirm flow for `issuer_ref`. The constraint
  itself already ships in `0023-record-objects` (task 01, decision
  064), which is why this task carries no migration;
  `issuer_asserted` stored verbatim in every case; match proposal
  itself stays in `extraction`.

## Acceptance

1. AC (mechanical): writing `issuer_ref` without a confirmation
   reference fails at the database; with one, it lands and
   `issuer_asserted` survives byte-for-byte.
2. AC (mechanical): a credential naming an unregistered issuer lands
   cleanly with `issuer_ref` null and `issuer_country` required.

## Outside check

Verifier attempts the unconfirmed write and confirms raw-string
survival on a confirmed match, the task 03 pattern applied to issuers.
