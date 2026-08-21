---
id: worker-surface/03
type: task
layer: worker-surface
satisfies: [1, 5, 6, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#028
  - decisions/LOG.md#039
  - decisions/LOG.md#041
  - decisions/LOG.md#062
  - model/record-schema.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# Adding and importing chapters

## Objective

The moment of value creation. If a worker cannot get their work in, the
record stays empty and every other surface is moot.

Surfaces implemented: A9, A10, A11, C1, C2, C3, C4.

## Scope

- Adding a chapter, adding a position inside one, minor edits after commit,
  and what permanence means.
- Importing: parse progress, and reviewing what was found before any of it is
  committed.
- **Lookup, never resolution** (decisions 039, 041). The screen may search the
  parties Grain has registered. It must always offer the raw string as typed,
  carrying the self-asserted mark, and it never resolves a free string into a
  canonical employer. `party_country` and `party_locality` are captured at
  entry because context not collected then cannot be backfilled.
- Month precision only, because no party attests a day.
- Only minor edits after commit (decision 028), with the correction dated and
  the version it replaced kept.

## Acceptance

- AC (mechanical): selecting the free-text fallback writes no `party_ref`,
  asserted on the resulting draft record.
- AC (mechanical): a committed chapter rejects every edit outside the minor
  set, proven by attempting a party change and asserting refusal.
- AC (mechanical): no date field in this flow accepts or stores a day
  component.
- AC (mechanical): nothing entered in the import review reaches the record
  until the commit action, proven by abandoning the flow and asserting the
  record is unchanged.
- AC (adjudicated): the permanence surface states what cannot be changed
  without either burying it or apologising for it. A verifier reading only
  that screen can say correctly what happens to an attested chapter.

## Outside check

Verifier types an employer that is not in the registry, commits it, and
confirms the record shows the worker's own words with the self-asserted mark
and no party attached. Then attempts to remove an attested chapter and
confirms refusal.
