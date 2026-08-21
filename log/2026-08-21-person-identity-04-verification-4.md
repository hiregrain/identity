# person-identity/04 verification, fourth pass

Implementation head SHA verified:
`40fd466b1308c9e770838449fff016ac59a3c19f`
(`fix(person): code review findings from person-identity/04's third
verification`, the code-review fix pass that landed after the third
verification passed at `ae3abf3`).

Verdict: **fail**, on criterion 3.

Clean context. The task file, the diff against `main`, and the PR body
were the only inputs. Everything below ran in a detached checkout of the
head SHA under a private compose project with no host port bindings,
since two other verification containers already held 5433 and 5434. No
program in the tree reads `db/connections.json`, so removing the host
ports changes nothing the suites depend on.

## Precondition

`make check` at the head SHA, exit 0, last line `check: green`. The run
included `person-test`, which carries this task's own suite
(`ok github.com/hiregrain/identity/core/person 41.015s`).

## Criteria

Criterion 1, mechanical. A mononym round-trips storage, matching and
packet render without acquiring an empty surname or being split; the MRZ
no-`<<` case is a named test. **Pass.**
Command: verifier-authored `TestVerifyFixtureIndonesianMononym`, run as
`GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -run TestVerify
-v ./person/...` from `core`. PASS in 12.82s. `ParseMRZName`
("SATRIYA<SUDARPA") returns primary "SATRIYA SUDARPA", empty secondary,
`IsMononym` true, `SeparatorPresent` false; the single-word case
("BUDI") behaves the same. The stored `document_name` reads back with
the same values, `CurrentNames` returns the person_name row with no
family part, and `DeriveIndexTokens` carries the whole name as one
token, with an explicit assertion that no token equals "SATRIYA" or
"SUDARPA" alone. The named test the criterion asks for exists at
`core/person/name_test.go`,
`TestMononymMRZWithNoDoubleFillerIsNotSplit`.

Criterion 2, mechanical. Dropping and regenerating `name_index`
reproduces it exactly. **Pass**, with the substitution the diff makes
explicit. `identity_app` holds no DELETE on `name_index_entry`, so a
literal drop is not reachable from the serving role; the property is
proven instead as an independent fresh derivation compared against the
persisted set. Verified twice, from two directions:
`TestNameIndexRegenerationReproducesExactly` in the shipped suite, and
the verifier's own `TestVerifyWriteIndexTwiceIsIdempotent`, which
calls `WriteIndex` twice with a drain after each and asserts the raw
`name_index_entry` row count is unchanged (8 entries applied on the
first call, 8 on the second, stored count identical), and that five
distinct `source_field` values survive, so no field's token is dropped
on the idempotency key. PASS in 23.74s.

Criterion 3, mechanical. A name change appends and end-dates; no row is
mutated; the prior name matches but is absent from an employer render.
**Fail.** The ordinary shape passes: verifier-authored
`TestVerifyFixturePostTransitionChange` appends two names for one
`(person, use, representation)` key with no drain between the calls,
drains once, and finds exactly one row current, the prior row absent
from `CurrentNames`, present in `AllNames` with a derived
`PeriodEnd`, and its own `period_end` column still NULL when read raw
as the table owner. PASS in 12.26s.

The failure is a second shape, reachable through the same public API.
`person_name_effective` computes the effective end as
`COALESCE(period_end, lead(asserted_at) OVER (...))`, so a stored
`period_end` always wins over the lead-derived one. A row whose own
stated end is in the future is therefore never end-dated by its
successor, and `person_name_current`'s decision 091 predicate
(`period_end IS NULL OR period_end > now()`) keeps it visible.
Command: verifier-authored `TestVerifySupersededRowWithAFutureStatedEnd`,
same run. FAIL in 9.91s:

    the superseded prior name is still in the employer render:
    [{Text:Deadname Here Use:official Representation:ABC
      PeriodEnd:2027-08-21 21:59:08 AssertedAt:2026-08-21 21:59:12}
     {Text:Chosen Name Use:official Representation:ABC
      PeriodEnd:<nil> AssertedAt:2026-08-21 21:59:13}]

Two rows for one key are simultaneously current, and the one the
criterion names as the thing to withhold, the prior name in the gender
transition case the task scope calls out by name, is the one still
rendered. `core/person/name.go`'s own comment on `CurrentNames` states
this cannot happen ("one row per (person_id, use, representation)
triple"), so the code and its comment disagree here too.

This is not the implementation deviating from decision 091. It is a
shape 091 did not rule on: 091 settled that a future-dated end stays
current, on a solitary row, and said the lead() derivation "continues to
supply the end for rows with no stored one". It did not say what an end
is when a row has both a stated one and a successor. Reading the effective
end as the earlier of the two rather than the stored one preserves
everything 091 fixed and closes this hole, but that is a founder call,
not a verifier's, and it is raised here rather than chosen quietly.

Criterion 4, adjudicated. A CJK name with ideographic, romanized and
phonetic entries renders correctly per purpose. **Pass.**
`representation` is part of the current view's partition key, so the
three coexist rather than displacing each other. Verifier-authored
`TestVerifyFixtureCJKThreeRepresentations` appends 李安 / Li An / ㄌㄧˇ ㄢ
under one use, drains, finds all three in `CurrentNames`, and reads each
back by naming its representation to `RenderFor`. PASS in 12.05s. What
would have failed it: a current view keyed on `(person_id, use)` alone,
which would have left one of the three visible and silently dropped the
other two.

Criterion 5, mechanical. Input exceeding the stated bound is rejected
with a worker-visible error; no path truncates silently. **Pass.**
Verifier-authored `TestVerifyFixtureJustOverTheBound` drives one input
one unit over each of the four bounds (`MaxNameTextRunes`,
`MaxNamePartRunes`, `MaxDocumentFieldRunes`, `MaxMRZLineLength`),
asserts each call returns an error, drains, and asserts `AllNames` and
`DocumentNames` are both empty, so nothing reached storage in truncated
form. It then appends a name of exactly `MaxNameTextRunes` runes and
asserts the stored text is that length, proving the rejection is a bound
and not a ban and that nothing on the accepted path trims. PASS in
57.29s.

## Outside check

The task's fixture set, all nine, verifier-authored and run against the
live planes at the head SHA.

    Indonesian mononym, two-word and single-word     PASS  12.82s
    CJK with three representations                   PASS  12.05s
    Spanish paternal + maternal                      PASS   8.13s
    Filipino with maternal middle name               PASS   6.61s
    Tamil patronymic                                 PASS   8.10s
    post-transition change                           PASS  12.26s
    MRZ-vs-VIZ disagreement                          PASS  39.49s
    39-character boundary name                       PASS  43.64s
    one input just over the stated bound             PASS  57.29s

The three cultural-structure fixtures were checked for the specific
corruption the task names, not only for a round trip. Spanish
`García`/`López` and Filipino `Reyes`/`Santos` both survive as
`fathers_family`/`mothers_family` inside `parts_ciphertext` with the
core `family` field left as the source gave it, so neither is coerced
into a Western surname column. The Tamil fixture asserts `family` stays
empty while `fathers_family` holds the patronymic, and that the
Tamil-script row produces only an `original` index token, never a
phonetic or romanized one. The MRZ-vs-VIZ fixture stores a 44-character
MRZ line that disagrees with the VIZ (`MUELLER` against `MÜLLER`) and
asserts both survive byte-for-byte with neither treated as
authoritative, and that the diacritic fold sits alongside the original
rather than replacing it. The boundary fixture asserts the ICAO
truncation signal fires on a full-width line ending in a letter and does
not fire when the last position is filler.

Decision 091's three shapes, each probed as its own verifier-authored
test rather than read off the shipped suite:

    future stored end stays current until it passes  PASS  29.38s
    past stored end beside a live row: one current   PASS   7.64s
    no overlap inversion on explicit windows         PASS  12.83s

The second confirms the zero-current-rows defect 091 names is closed:
an expired row beside an unsuperseded live one leaves exactly one
current row, the live one. The third confirms each row's effective end
is evaluated independently: two rows whose stated windows run opposite
to their assertion order each keep their own period, neither borrows the
other's, and with both windows closed and neither superseded the key
correctly reports zero current rows, which is what 091's "a temporary or
document-bounded name expires on schedule" requires.

A fourth shape, not in the shipped suite and not on the executive's
list, is the criterion 3 failure recorded above: a superseded row whose
own stated end is in the future. That is the overlap the inversion probe
does not reach, because the inversion probe's windows have both closed.

`WriteIndex` called twice: covered under criterion 2 above. The stored
set is unchanged and the raw row count does not grow.

## Findings

1. **The broadened `ON CONFLICT` in `core/outbox` did weaken
   idempotency for another table, and the comment claiming otherwise is
   wrong.** `core/outbox/instruction.go` now renders
   `ON CONFLICT DO NOTHING` with no target, and its comment states
   "every existing table still has only outbox_entry_id to conflict on,
   so this is not a behavior change for them."
   `db/migrations/payload/0036-person-record-and-channels.sql` declares
   `person_record.person_id spine_object_id NOT NULL UNIQUE`, and
   `person_record` is written through this exact apply path
   (`core/person/person.go`). Probed live, verifier-authored
   `TestProbeBroadenedOnConflictOnPersonRecord`:

       shipped path: Apply err=<nil>, person_record rows 1 -> 1
       counterfactual with the pinned target: err=psql(payload as
       identity): ERROR: duplicate key value violates unique constraint
       "person_record_person_id_key"

   An instruction writing a second `person_record` for a person who
   already has one is now applied, acknowledged, and drained with no row
   written and no error anywhere. Under the replaced form it raised
   `unique_violation`, which is what `cross-plane-outbox` scenario 6
   ("a permanently failing apply surfaces") and the reconciler exist to
   catch. `dek_registry`'s two partial unique indexes are not affected,
   since `core/envelope` writes that table directly rather than through
   the outbox. Fixing this without giving up `name_index_entry`'s
   idempotency needs either a per-instruction conflict target or a
   check on rows affected; it is a design call, and it also sits outside
   this task's stated scope, which names no `core/outbox` change at all.

2. **`WriteIndex`'s comment omits `source_field` from the constraint it
   names.** `core/person/name.go` states the UNIQUE key as
   `(person_id, source_table, source_outbox_entry_id, token_kind,
   generator_version)`. Migration 0011-names declares it with
   `source_field` included, and the migration's own comment explains at
   length why that column is load-bearing: without it a document's four
   name fields collide on one key. The same short form appears in
   `core/person/name_db_test.go`'s comment on
   `TestWriteIndexTwiceLeavesTheStoredSetUnchanged`. Decision 052 makes
   a comment whose claim has drifted from the code a review defect.

3. **`CurrentNames`'s comment claims a uniqueness the view does not
   provide.** "One row per (person_id, use, representation) triple" is
   false in the overlapping-window shape recorded under criterion 3, and
   was already false by construction the moment 091's predicate admitted
   stored future ends alongside lead-derived ones.

4. **The PR body's criterion 3 paragraph is stale.** It states
   "`person_name_current` is `person_name_effective WHERE period_end IS
   NULL`", which was true at `ae3abf3` and is not true at the head: the
   view now reads `period_end IS NULL OR period_end > now()`. The
   `## Verification` section likewise still records the third pass.

5. **`DeriveIndexTokens`'s comment says "every current source row".** It
   reads `AllNames`, which is every row, prior names included. That is
   the right behavior for a matching index and the wrong word for it.

## What the fail needs

Criterion 3 alone. The other four criteria and the full outside check
stand at this SHA and do not need rerunning if the fix is confined to
the effective-end derivation. The founder call that finding 3 and the
criterion 3 failure both turn on is a single question: when a
`person_name` row carries both its own stated `period_end` and a
successor in its partition, which one ends it. Decision 091 did not
reach that case.
