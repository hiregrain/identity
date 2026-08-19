# T1 Spike — Agent-Fluency Measurement, Go vs. TypeScript (gate on decision 005 / D2)

> **Discharged (decision 012): Go stands; the switch-triggers carry forward as
> the guard.** This file is the spike's frozen specification, kept because the
> pre-committed rule and the trigger register are still cited. Nothing below is
> live work.

Purpose: D2 (Go core) was ratified contingent on this spike. Pre-committed
rule: **Go stands unless its measured defect rate is materially worse than
TypeScript's** (working threshold: >1.5× oracle-detected defects, or any
task where agents fail to reach a correct implementation at all). The spike
measures our actual agent tooling on representative kernel work — it
replaces the litigation's contested fluency evidence with a measurement on
our own stack.

## Design

Ten tasks, each implemented twice (Go and TS) by the same agent tooling
under the same prompts, judged by language-neutral oracles. Order of
languages alternates per task to cancel prompt-learning effects. No human
fixes; humans only count.

### The ten tasks

1. **Canonical JSON serialization + Ed25519/JWS sign and verify** against a
   fixture party registry, passing shared cross-language test vectors
   (these vectors are a deliverable — they become part of the contract).
2. **Per-stream hash chain append + full-chain verification**, including
   detection of a single mutated historical record.
3. **Merkle checkpoint construction** over N stream heads + inclusion-proof
   generation and verification.
4. **Supersession-chain fold**: derive current truth from an attestation
   set with superseding pointers, including the party-A-cannot-supersede-
   party-B rule and ledger invalidation records.
5. **Merge/unmerge as events**: alias-table maintenance, alias-closure
   resolution at read time, unmerge with flagging of merge-period
   attestations.
6. **Claim-class state machine**: self-asserted → frozen-on-verification
   lifecycle with illegal-transition rejection (the discriminated-union /
   sealed-interface showcase — instrument how each language's idiom holds
   up under agent edits).
7. **Ingestion validation**: schema check including the sensitive-data ban
   (field and free-text), work_kind@version existence, issuer state,
   subject resolution through aliases.
8. **Prior-packet assembly** from fixtures: grants, revocation binding,
   derived issuer-state flags, provenance classes, post-selection gating of
   work-authorization.
9. **Deletion step**: DEK destruction + payload purge + tombstone +
   `PayloadPurged` event, with an oracle proving spine integrity survives
   and no readable payload remains.
10. **A deliberately underspecified task** (a realistic ticket with a gap):
    measures how each language's agent output fails when requirements are
    incomplete — failure legibility matters as much as failure rate.

### Oracles and metrics

- Language-neutral golden vectors + property-based differential tests
  (same inputs, both implementations, byte-identical canonical outputs).
- Metrics per task per language: oracle-detected defects after first
  submission; iterations to green; lines needing human reading (review
  burden proxy); any unfixable failure.
- Secondary observations: dependency count pulled per task (supply-chain
  surface), idiomatic uniformity across tasks (agent-consistency proxy).

### Harness

Two scratch repos (`t1-go/`, `t1-ts/`), pinned toolchains, CI running the
shared vector suite. Estimated effort: 2–4 days including harness. The
canonicalization vectors and several oracles survive the spike as real
contract/test assets regardless of outcome.

## Decision rule

- Go within threshold → decision 005's D2 stands ratified; record result in
  the decisions log.
- Go materially worse → new decisions-log entry reopening D2 with the
  measurements attached; the TS-everything + Go-CI-oracle hybrid from
  `design/stack-litigation/d2-typescript.md` becomes the default.
