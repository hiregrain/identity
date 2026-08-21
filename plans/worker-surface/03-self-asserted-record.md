---
id: worker-surface/03
type: task
layer: worker-surface
satisfies: [1, 2, 5, 6, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#028
  - decisions/LOG.md#039
  - decisions/LOG.md#041
  - decisions/LOG.md#062
  - decisions/LOG.md#074
  - model/record-schema.md
  - design/13-platform-screens
evidence: []
verified_by: null
---

# Adding and importing chapters

## Objective

The moment of value creation. If a worker cannot get their work in, the
record stays empty and every other surface is moot.

Surfaces implemented: A9, A10, A11, A11a, A11b, C1, C2, C3, C4, C5, E2-1,
E2-2, E2-3.

**Widened by decisions 062 and 074.** E2 is education and certificates, which
062 made record objects and which no surface had ever carried, so criterion 1's
"every fact about the person is reachable" was failing on a third of the
ratified schema. C5 is the countable step and A11a/A11b are the two import
outcomes the layer's own defect list named. A11 now confirms each proposed party
match on the screen rather than applying it silently, which is the schema's rule
that a name match is not an identity, made visible.

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

1. **Typing a business Grain does not know attaches no party to it.** (mechanical) selecting the free-text fallback writes no `party_ref`,
  asserted on the resulting draft record.
2. **A committed chapter refuses every edit outside the minor set.** (mechanical) a committed chapter rejects every edit outside the minor
  set, proven by attempting a party change and asserting refusal.
3. **No date in this flow carries a day.** (mechanical) no date field in this flow accepts or stores a day
  component.
4. **An abandoned import leaves the record untouched.** (mechanical) nothing entered in the import review reaches the record
  until the commit action, proven by abandoning the flow and asserting the
  record is unchanged.
5. **The permanence screen says what cannot be undone, without apologising for it.** (adjudicated) the permanence surface states what cannot be changed
  without either burying it or apologising for it. A verifier reading only
  that screen can say correctly what happens to an attested chapter.

## Outside check

Verifier types an employer that is not in the registry, commits it, and
confirms the record shows the worker's own words with the self-asserted mark
and no party attached. Then attempts to remove an attested chapter and
confirms refusal.
