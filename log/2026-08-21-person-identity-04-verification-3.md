# person-identity/04 verification, third pass

Task: `plans/person-identity/04-name-model.md`
PR: #16, `task/person-identity-04`
Implementation head SHA verified: `ae3abf345a2f18c416e1a44c173f2253434211bd`
Verifier: clean context, no access to the implementer's session or notes.
Date: 2026-08-21

Two earlier passes failed criterion 3 and their records sit on this branch
(`log/2026-08-21-person-identity-04-verification.md` and `-2.md`). This
pass was run from scratch against the current head, with criterion 3
probed on the sequence that fell before.

## Precondition

`make check` at `ae3abf3`, run against a private compose project
(`COMPOSE_PROJECT_NAME=pi04verify`, host ports removed by an override so
it cannot collide with another session's containers), exit 0, final line
`check: green`. Two earlier attempts failed for environment reasons only:
a Postgres container reporting healthy while still shutting down, and a
relative `COMPOSE_FILE` that `go test` could not resolve after changing
directory. Neither touched the tree under verification.

## Per-criterion result

### 1. A mononym round-trips storage, matching and packet render without acquiring an empty surname or being split; the MRZ no-`<<` case is a named test. Mechanical. Pass.

```
go test -tags db -count=1 -run 'TestMononymMRZWithNoDoubleFillerIsNotSplit|TestMononymRoundTripsWithoutAnEmptySurname' ./person/...
ok  github.com/hiregrain/identity/core/person  5.888s   (exit 0)
```

`ParseMRZName` splits on `<<` and on nothing else, so `SATRIYA<SUDARPA`
yields `Primary: "SATRIYA SUDARPA"`, empty `Secondary`, `IsMononym: true`.
The verifier's own fixtures reproduced it for the padded field shape and
for the single-word case.

### 2. Dropping and regenerating `name_index` reproduces it exactly. Mechanical. Pass.

The implementation's own test compares a fresh derivation against the
persisted set rather than dropping anything, so the verifier ran the
criterion literally: write the index, read it back, `DELETE` every
`name_index_entry` row for the person as the owner role, confirm zero
rows remain, regenerate through `WriteIndex` and the ordinary drain, and
compare the second persisted set against the first.

```
go test -tags db -count=1 -run 'TestProbeDropAndRegenerateIndexReproducesItExactly' ./person/...
--- PASS: TestProbeDropAndRegenerateIndexReproducesItExactly (30.49s)   (exit 0)
```

The source content carried diacritics (`Zoë Ström`) across both a
`person_name` row and a `document_name` capture, so the fold path and the
original-alongside-fold rule were both in the compared set.

### 3. A name change appends and end-dates; no row is mutated; the prior name matches but is absent from an employer render. Mechanical. Pass.

The mechanism on this head is a read-time derivation:
`person_name_effective` computes each row's effective `period_end` as
`COALESCE(period_end, lead(asserted_at) OVER (PARTITION BY person_id,
"use", representation ORDER BY asserted_at, outbox_entry_id))`, and
`person_name_current` is that view filtered to `period_end IS NULL`.
Nothing is resolved at write time and the `supersedes` column is gone.

```
go test -tags db -count=1 -run 'TestNameChangeAppendsAndEndDatesWithoutMutation' ./person/...
--- PASS  (3.67s)   (exit 0)
```

Probed independently on the previously failing sequence: two sequential
`Append` calls for one `(person, use, representation)` key with **no
drain between them**, then a single drain.

- `CurrentNames` returns exactly one row, the later append.
- `RenderFor(official, ABC)`, the employer-facing read, returns the later
  name; the prior name does not appear.
- The prior row's raw `period_end` column, read past the view as the
  owner role, is still `null`.
- `person_name` holds two rows for the person, one per append.
- `AllNames` still returns the prior row, so it stays queryable for
  matching, and its derived `PeriodEnd` equals the later row's
  `AssertedAt`.

Extended to three appends with no drain between any of them: only the
last is current, and each earlier row's effective end is the next row's
`asserted_at`. Extended to a mixed key set: an append under
`(official, ABC)` does not end-date a row under `(nickname, ABC)`.

Edge probed as instructed, two rows sharing one `asserted_at` to the
microsecond, forcing the `outbox_entry_id` tiebreak. Rows inserted
directly as the owner role, then `person_name_current` read repeatedly:

```
--- read 1 / read 2 / read 3 (enable_seqscan = off)
 22222222-... | B        (one row, identical across all three reads)
--- effective view
 11111111-... | A | 2026-08-21 12:00:00+00
 22222222-... | B | null
```

Exactly one row is current and the answer is stable across repeated reads
and across a forced plan change. Determinism holds. Which row wins is
recorded as finding 1.

### 4. A CJK name with ideographic, romanized and phonetic entries renders correctly per purpose. Adjudicated. Pass.

`representation` is part of the current view's partition key, so the
three entries are simultaneously current rather than superseding one
another, and `RenderFor` takes both `use` and `representation`. What
would have failed it: partitioning on `(person_id, "use")` alone, which
would leave one of the three current and drop the other two from every
employer-facing read. Confirmed empirically as well, with `李明` / `Li
Ming` / `リ ミン`: three current rows, each rendering back under its own
representation.

```
go test -tags db -count=1 -run 'TestCJKThreeRepresentationsRenderPerPurpose' ./person/...
--- PASS  (5.84s)   (exit 0)
```

### 5. Input exceeding the stated bound is rejected with a worker-visible error; no path truncates silently. Mechanical. Pass.

```
go test -tags db -count=1 -run 'TestNameTextOverTheBoundIsRejectedLoudly|TestOverLengthNameTextIsRejectedLoudlyAtTheServiceBoundary' ./person/...
ok   (exit 0)
```

Probed with a 301-rune non-Latin string: `Append` returns
`ErrNameTextLength`, and `person_name` holds no row for the person
afterwards, so nothing reached storage to be truncated. A 300-rune string
is accepted and reads back at 300 runes. The bounds
(`MaxNameTextRunes` 300, `MaxNamePartRunes` 100, `MaxGivenNames` 10,
`MaxDocumentFieldRunes` 200, `MaxMRZLineLength` 44) carry their reasoning
beside them.

## Outside check

The task's fixture set, run as a verifier-authored suite against both
live planes, then deleted:

| Fixture | Result |
| --- | --- |
| Indonesian mononym, two words | pass, whole name in the primary identifier, no decomposition invented |
| Indonesian mononym, one word | pass, padded and unpadded field shapes both |
| CJK with three representations | pass, three simultaneously current rows, each rendering per purpose |
| Spanish paternal plus maternal | pass, both surnames round-trip as extensions, core `family` left empty |
| Filipino with maternal middle name | pass, same `mothers_family` mechanism, no bespoke field |
| Tamil patronymic | pass, patronymic in `fathers_family`, core `family` empty |
| Post-transition name change | pass, prior name absent from the employer read, present in the matching read |
| MRZ against VIZ disagreement | pass, both zones stored verbatim, neither treated as authoritative; the accented original sits alongside its fold in the derived tokens |
| 39-character boundary name | pass, full-width line ending alphabetic reads as possibly truncated, a shorter line does not |
| One rune over the stated bound | pass, rejected loudly, nothing stored |

Attempts made to break it that did not: draining between the two appends
was withheld deliberately; a third append was added to see whether the
middle row's end date resolved to the wrong neighbour; a second name key
was interleaved to see whether it was end-dated by an unrelated append;
the index was actually deleted rather than re-derived in memory; the
current view was read under a forced index plan to see whether the
window function's ordering was plan-dependent.

## Findings

1. **The `asserted_at` tiebreak is uuidv4 order, uncorrelated with
   append order.** Under an exact `asserted_at` tie the current row is
   the one with the greater `outbox_entry_id`. Probed in both
   assignments: with the greater uuid inserted second the later insert is
   current; with the lower uuid inserted second the *earlier* insert
   stays current and the later one is end-dated. `person.NewID` is random
   v4, so the tiebreak carries no time information, and no constraint
   forbids a tie. Not reachable through the product's own path today,
   since `outbox.Apply` runs one payload transaction per entry and
   `asserted_at` defaults to `now()`, so two entries cannot share a
   transaction timestamp. Criterion 3 holds: exactly one row is current
   and the answer is deterministic. Recorded for code review, not a
   blocker.

2. **`asserted_at` is assigned at drain time, not at `Append` time.**
   `outbox.Pending` orders by `created_at, entry_id`, so an ordinary
   drain preserves caller order. A failed entry stays pending and is
   applied on a later drain, after entries enqueued behind it have
   already landed, which would make the older name current. The spine
   already holds the enqueue time; the payload row does not carry it. No
   criterion covers this and the ordinary path is correct. Recorded for
   code review.

3. **`MRZName.SeparatorPresent` does not survive a padded field.** Its
   comment says it distinguishes a field carrying no `<<` anywhere from
   one carrying `<<` followed by an empty secondary identifier. Every
   real fixed-width MRZ name field is padded with `<`, so a padded
   mononym (`SUKARNO<<<<...`) reports `SeparatorPresent: true`,
   indistinguishable from the shape the comment says it tells apart. The
   implementation's own tests exercise the unpadded shape only.
   `IsMononym` is `true` in both, so criterion 1 is unaffected. A comment
   whose claim has drifted from what the code can deliver.

4. **`queryNames` discards timestamp parse errors silently.** `period_start`,
   `period_end` and `asserted_at` are each parsed under `if err == nil`,
   so an unparsable value presents as absent rather than as an error. For
   `period_end` that means a derived end date failing to parse would read
   as "this name is current". Not reachable given psql's output format,
   but it is a silent failure path inside the mechanism criterion 3 rests
   on.

5. **The plan file's evidence cited a superseded SHA.** The entries named
   `a5cc923`, two commits behind the head under verification. Refreshed
   in this pass's bookkeeping commit.

6. **The task file's `binds` names a file that does not exist.**
   `research/13-name-standards.md` is not in the tree; `research/13` is
   the retention-and-erasure brief, and the name-standards material is at
   `research/11-signup-identifiers-and-names.md`. Research binds nothing,
   so this constrains no implementation, and the fence keeps the verifier
   out of the task's `binds` field. Raised for the plan author.

No scope creep. The diff touches the migration, `core/person/name.go`,
its two test files, the two generated type files, the `person-test`
Makefile comment, the plan file's own bookkeeping fields, and the two
earlier verification records. Nothing else. The PR body declares its
judgment calls rather than claiming none; the two checked against the
tree (`research/13` missing, `declared_residency_region` defined only at
0036) are accurate.

## Verdict

**Pass.** Every criterion discharged, the outside check's full fixture set
behaves per criteria, and the previously failing sequence now holds under
direct probing. Findings 1 through 4 go to code review; findings 5 and 6
are bookkeeping.
