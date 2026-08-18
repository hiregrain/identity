---
id: foundation/04
type: task
status: ready
depends_on: [foundation/03]
migrations: [0003-spine-core, 0004-payload-us-bootstrap]
binds:
  - decisions/LOG.md#011
evidence: []
verified_by: null
---

# Two-plane physical split

## Objective

Two physical databases from the first row of data (decision 011): the
global spine and `payload-us` — so the residency seam is real, not a
naming convention.

## Scope

- Two databases with separate migration chains (`db/migrations/spine/`,
  `db/migrations/payload/`; the harness from foundation/02 runs both);
  both carry the roles/append-only posture from foundation/03, with the
  payload chain using the documented exemption license where deletion
  requires it.
- `0003-spine-core`: the spine's base conventions — object-ID and
  commitment column domains, ledger-timestamp column, the rule that no
  spine column may be a readable-content type.
- `0004-payload-us-bootstrap`: the payload database's base conventions —
  `residency_region` NOT NULL on every table (enforced by the lint, seeded
  `'us'`), payload rows keyed by spine object ID.
- The **spine schema lint** (CI): allow-listed column types/domains only
  in spine migrations; any text/blob/JSON column outside the allow-list
  fails the build with a message naming the rule (AC-F3's mechanism).
- Connection plumbing: application config holds two connection strings;
  no code path may join across the planes in SQL (cross-plane assembly
  happens in application code, by design).

## Acceptance

- AC-F3 (mechanical): a test migration adding a readable column to the
  spine fails CI via the lint.
- AC-F4 (mechanical): a payload table without `residency_region` fails
  the lint; every seeded table carries it NOT NULL.
- AC: both chains replay from empty in CI; the append-only test from
  foundation/03 passes against both databases.

## Outside check

Verifier replays both chains, runs the lint against two planted bad
migrations (readable spine column; missing residency column), and
confirms both fail with the naming-the-rule messages.
