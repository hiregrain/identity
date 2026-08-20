---
id: ingestion
type: layer
status: ready
milestone: v1
depends_on: [trust-kernel, party-registry]
binds:
  - model/attestation-interface.md
  - model/roster-firewall.md
  - decisions/LOG.md#006
  - decisions/LOG.md#008
  - decisions/LOG.md#010
  - decisions/LOG.md#031
  - decisions/LOG.md#032
  - decisions/LOG.md#068
evidence: []
verified_by: null
---

# ingestion

The attestation write path: the only way facts enter the record.

Grilled 2026-08-20 (decision 068); tasks authored in the same session;
the engineering review over these criteria and tasks runs before any
task is claimed.

Scope, per the ratified interface (A-6/A-7 bound by decision 068) and
the rulings:

- Durable idempotent ingest queue: Postgres in the outbox pattern
  (decision 068, no Kafka-as-truth), partitioned by subject, never
  issuer, because hot parties at period close are a business-model
  guarantee; riding the trust-kernel/08 transport.
- **One external confirmation** (decision 068): a submission is
  rejected synchronously or confirmed once, and the confirmation is
  the zero-acked-loss promise, sent only after primary-plus-replica
  durability. Received/recorded states exist internally for
  monitoring; a party never sees received-then-rejected.
- Schema validation at the door: version, required fields,
  `work_kind@version` existence, and the banned-information list
  (interface A-4, extended by decisions 008/010) enforced in every
  field including free text by **fixed published patterns, never a
  model** (decision 068).
- Signature verification via the kernel under the R-3 validity rule:
  valid iff the key was active at signing time and the hash-chain
  timestamp predates any compromise report. Issuer state and probation
  caps (party-registry/05) enforced at admission.
- Subject resolution: the attestation's `subject_id` is the party's
  pairwise pseudonym (A-6), resolved ledger-side through the alias
  closure; **this layer owns the pairwise-pseudonym mapping** (decision
  068), keyed per partner, merge-invisible to the partner.
- Ledger hash-chain timestamp at write; append to spine and payload
  through recording functions only (the foundation/03 pattern);
  supersession authority per N-1: the original issuer or a signed
  ledger invalidation record, nobody else.
- The roster firewall (RF-2, decision 031): nothing derived from an
  employer roster enters except through a live worker-initiated
  `verification_request` (the schema §10 table, landed by
  self-asserted-record's freeze task in first-product).
- Out of scope: packet assembly (prior-packet), party registration and
  key lifecycle (party-registry), request issuance UX (verification),
  and any read surface.

Acceptance:

1. **A duplicate delivery changes nothing, and an acked attestation
   survives the primary dying.** (mechanical) a duplicate delivery is
   idempotent; the watermark test kills the primary mid-run and every
   confirmed attestation is present afterward, none double-recorded.
2. **Banned information is rejected at the door, with a reason.**
   (mechanical) every banned category, including one planted in each
   free-text field, is rejected with a structured error naming the
   category, by the published pattern set, proven against red-path
   fixtures; the pattern set is published, and changing a pattern
   without republishing fails a check.
3. **No party can overwrite another party's attestation.** (mechanical)
   party B's supersession of party A's attestation is rejected; the
   original issuer's supersession lands; the ledger invalidation path
   lands and is signed.
4. **The application role cannot write a fact directly.** (mechanical)
   the application role has no direct INSERT on fact tables, only the
   recording functions, proven by privilege inspection and bypass
   attempt.
5. **An attestation that fails the roster firewall never lands.**
   (mechanical, RF-2) an attestation without a live
   `verification_request` naming the subject as requester is rejected
   with a structured error; a deliberately constructed employer-push
   attestation fails ingestion.
6. **Every party-facing rejection precedes the confirmation.**
   (mechanical) every rejection path executes before the external
   confirmation is sent; after confirmation, no code path emits a
   party-facing rejection, and a post-confirmation processing failure
   retries until recorded, proven by a fault-injection fixture.
7. **No ledger id ever reaches a party, and merges are invisible.**
   (mechanical) every party-facing payload carries only the pairwise
   pseudonym; a merge changes no pseudonym any partner holds;
   resolution through the alias closure lands the attestation on the
   surviving identity.
8. **A signature is valid only in its key's honest window.**
   (mechanical) an attestation signed with a key inactive at signing
   time is rejected; one whose timestamp postdates a compromise report
   is rejected; both land cleanly when the window is honest, per R-3.
