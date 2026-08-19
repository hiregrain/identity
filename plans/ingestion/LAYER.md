---
id: ingestion
type: layer
status: draft
milestone: v1
depends_on: [trust-kernel, party-registry]
binds:
  - model/attestation-interface.md
  - model/roster-firewall.md
  - decisions/LOG.md#006
  - decisions/LOG.md#008
  - decisions/LOG.md#031
  - decisions/LOG.md#032
evidence: []
verified_by: null
---

# ingestion

The attestation write path: the only way facts enter the record.

Scope: durable idempotent ingest queue (hot parties at period close are a
business-model guarantee; partition by subject, never issuer); schema
validation — version, required fields, `work_kind@version` existence, the
sensitive-data ban including free-text scanning (A-4, extended by decisions
008/010: nationality, immigration detail, sanctions hit data); signature
verification via the kernel; issuer state + probation caps; subject
resolution through the alias closure; ledger hash-chain timestamp; append
to spine + payload; rejection returns to the party, never silent rewrite;
supersession authority enforcement (N-1: original issuer or ledger
invalidation only); SECURITY-DEFINER-style narrow write paths (Dispatch
pattern) so inserts happen only through recording functions; the D1
launch obligations at this boundary — **ack watermark** (no
acknowledgment until durable across failure domains) and two-phase
issuance receipts.

Acceptance:
1. **A duplicate delivery changes nothing.** (mechanical) a duplicate delivery is idempotent; an attestation
   acked to a party survives a simulated primary loss (watermark test).
2. **Banned data categories are rejected at the door, with a reason.** (mechanical) every sensitive-data-ban category is rejected with a
   structured error, including in free text.
3. **No party can overwrite another party's attestation.** party B cannot supersede party A's attestation; the ledger
   invalidation path can.
4. **The application role cannot write a fact directly.** the application role has no direct INSERT on fact tables — only
   the recording functions.
5. **An attestation that fails the roster firewall never lands.** (mechanical, `roster-firewall.md` RF-2) an attestation whose
   provenance is an employer roster is rejected unless it carries a live
   `verification_request_id` naming the subject as requester. No write path
   accepts a roster row as a source of truth. A deliberately constructed
   employer-push attestation fails ingestion with a structured error.
