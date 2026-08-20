---
id: foundation
type: layer
status: done
milestone: first-product
depends_on: []
binds:
  - decisions/LOG.md#005
  - decisions/LOG.md#011
  - decisions/LOG.md#012
  - decisions/LOG.md#016
  - decisions/LOG.md#017
  - design/stack-litigation/docket-rulings-0.1.md
evidence: ["log:log/2026-08-19-foundation-layer-close.md"]
verified_by: layer-close-verifier@2026-08-19
---

# foundation

Repo scaffolding and the storage substrate every other layer stands on.

Scope: monorepo layout (Go core / TS surfaces / language-neutral contract
schema per D2); CI ordered as a dependency graph, metadata checks before any
database boots; the spine/payload physical split with one shared migration
numbering sequence and `residency_region` stamped on every payload row from
row one; append-only enforcement on the application role with
default-privilege inheritance proven across both databases and multiple
schemas, exemptions granted only per table to a named role, and operational
boundaries so the restriction cannot be stepped around via owner
credentials or SECURITY DEFINER mutation; **cross-plane write consistency
via a spine-first transactional outbox with idempotent apply and a
reconciler** — no compensation path against an append-only spine;
subject-scoped per-person DEK envelope encryption; **deletion mechanics —
scheduled physical purge, bounded backup retention, and a mandatory
restore-time deletion replay**; a **spine linkage threat model** covering
what correlation leaks where columns leak nothing; mechanical checks adapted
from Dispatch (plan-graph, migration-numbers, migration-order,
decisions-index, schema-grep). Managed Postgres provisioning is **not** in
this layer's scope — it is a founder gate in ORDER.md, and no task here
requires cloud credentials.

Acceptance:
1. **Append-only is enforced by the database, not by discipline.** (mechanical) a test proves the application role cannot UPDATE or
   DELETE any table outside an enumerated exemption list, and that a newly
   created table inherits the restriction with no manual step — proven
   across both databases, more than one schema, and a second owner role.
2. **The migration chain replays from empty, and the types match.** (mechanical) CI replays the migration chain from empty twice and
   diffs generated types against the live schema.
3. **No spine column carries a type nobody justified.** (mechanical) no spine column uses a type outside the explicit spine
   allow-list, and every allow-listed exception carries a written justification
   in the migration that introduces it — enforced by the schema lint, which
   fails on a planted violation of each kind. The lint does not claim to prove
   opaque columns are free of personal data; that is criterion 8.
4. **Every payload row knows which region it lives in.** (mechanical) every payload table carries `residency_region` NOT NULL.
5. **A write interrupted between the two planes leaves nothing half-done.** (mechanical) a spine+payload write interrupted between planes is
   completed by retry with no duplicate and no silent backlog; nothing is
   acknowledged before both planes are durable.
6. **A restored backup does not resurrect deleted payloads.** (mechanical) restoring a pre-deletion backup and running the
   replay leaves nothing readable for a deleted person, and a restored
   system that has not replayed refuses traffic.
7. **Destroying the key destroys the readability.** (mechanical) payload content is unreadable after key destruction
   through every path — not merely absent from a dump grep — and rows about
   multiple people are keyed to the subject with no second wrap.
8. **No spine column can re-identify a person on its own.** (adjudicated) a verifier with a clean context, given
   `foundation/04`'s correlation checklist and the spine schema alone, finds no
   spine column from which a person could be re-identified without the payload
   plane. Split out of criterion 3 so the mechanical half cannot be reported as
   discharging the judgment half.
