# person-identity/04: clean-context verification (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, PR #16's diff and body, and the repo protocol.

Implementation head verified:
`5116962c78c903ee75162b98c871067ba5052e8e`. Driven in an isolated
worktree checked out detached at that SHA, working tree clean. Sibling
worktrees hold compose host ports 5433/5434, so the run used a `!reset`
no-ports override; every database access in this repo goes through
`docker compose exec`, so nothing under test touches a host port. The
override and the verifier's own fixture files were removed before this
record landed, and the compose file declares no volumes, so the databases
were left as found.

Verdict: **FAIL**, on criterion 3. A name change appends and does not
end-date. Every other criterion, and the rest of the Outside check,
holds.

## The standing pipeline

Green at the head. `make check` was driven stage by stage rather than as
one target, because on this machine `db-reset`'s `--wait` returns while
the postgres entrypoint is still restarting past its initdb temporary
server, and the very next `node db/migrate.mjs spine` dies on a missing
socket. That reproduced on three consecutive `make check` runs at this
head and is a property of the harness under load, not of this diff: the
same stages pass when a plane-ready wait is inserted around the compose
reset, and nothing else about the target changed.

Exit 0, each run by the verifier at the head:

- `make metadata`, `make install`, `make lint`, `make go-check`
- the `migrate-verify` recipe, step for step (both chains replay from
  empty, second replay a no-op, dumps diffed): 0011-names applies before
  0036-person-record-and-channels, which is the ordering the PR body's
  `own_declared_residency_region()` judgment call rests on
- `make typegen-check append-only spine-schema payload-residency
  scored-columns two-plane-split cross-plane-constructs`
- `make envelope-test cross-plane-outbox`
- `cd core && GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -v
  ./person/...`, every test passing
- `make deletion-test`, `make ts-check`
- `make check-red`, `make check-red-db`

Green here is a precondition, not evidence for any criterion.

## Criteria

**1. A mononym round-trips storage, matching, and packet render without
acquiring an empty surname or being split; the MRZ no-`<<` case is a
named test.** PASS (mechanical).

`go test -tags db -run
'TestMononymMRZWithNoDoubleFillerIsNotSplit|TestMononymRoundTripsWithoutAnEmptySurname'`
passes, and the named test exists under that name. The verifier's own
fixture put the harder shape through it: a real TD3 name field is padded,
so `SATRIYA<SUDARPA` arrives as `SATRIYA<SUDARPA<<<<<<...`, which does
contain `<<`. `ParseMRZName` still returned
`{Primary:"SATRIYA SUDARPA" Secondary:"" IsMononym:true}`, the person_name
row read back with no parts at all, and no index token carried a
`SATRIYA` or `SUDARPA` fragment.

**2. Dropping and regenerating `name_index` reproduces it exactly.**
PASS (mechanical).

The shipped test compares a fresh derivation against the persisted set
without dropping anything, on the argument that `identity_app` holds no
DELETE. The verifier discharged the criterion as written instead: as the
owner role, `DELETE FROM name_index_entry WHERE person_id = $1`, confirmed
zero rows, then `WriteIndex` again and drained. `StoredIndexTokens` before
the drop and after the regeneration agree exactly, token for token, on
source table, source row, kind, and decrypted value.

**3. A name change appends and end-dates; no row is mutated; the prior
name matches but is absent from an employer render.** FAIL (mechanical).

Three of the four conjuncts hold, and the verifier confirmed each on a
post-transition fixture: two rows persist for one `(person_id, use,
representation)` triple, `CurrentNames` returns only the later text,
`AllNames` returns both, and the owner-role row count is 2.

The end-dating conjunct does not hold. Reading the raw columns after the
change:

```
SELECT coalesce(period_start::text,'-'), coalesce(period_end::text,'-')
  FROM person_name WHERE person_id = $1 ORDER BY asserted_at
-> -	-
   -	-
```

Neither row carries a period, and no path in the diff can put one on the
prior row: `Append` writes only the incoming row's own `period_start` and
`period_end`, `person_name` carries no UPDATE grant, and the migration
states the position outright, that an ordinary worker-driven name change
"carries neither" bound. That is a deliberate design change to an
authored criterion. It is defensible on its merits, since the view
resolves current from insertion order and an end-date would be redundant
state, but the task file says end-dates in its criterion, in its scope
line (`period` (validity bounds; absent = current)), and in its reference
model ("a name change is a new entry plus an end-date on the prior"). A
task that needs a decision the log has not made stops and raises it. This
one was settled in a migration comment, and it is absent from the PR
body's own list of judgment calls, which is where the reader would have
looked for it.

The named test compounds it. `TestNameChangeAppendsAndEndDatesWithoutMutation`
asserts appending, non-mutation, and the employer render, and asserts
nothing at all about an end-date. A test whose name claims the conjunct
it does not check is worse than one that omits it.

Either the criterion changes, by a decisions entry recording that
supersession-by-insertion-order replaces end-dating in this model, or the
implementation end-dates. The verifier does not pick between them.

**4. A CJK name with ideographic, romanized, and phonetic entries renders
correctly per purpose.** PASS (adjudicated).

`representation` is part of the current view's key, so all three coexist
as simultaneously current rows, and `RenderFor(use, representation)` is
the per-purpose read. What would have failed it: a current view keyed on
`(person_id, use)` alone, which would have evicted two renderings the
moment the third landed. The verifier's own fixture probed exactly that
by revising only the romanization after all three existed; the
ideographic and phonetic rows stayed current and rendered unchanged.

**5. Input exceeding the stated bound is rejected with a worker-visible
error; no path truncates silently.** PASS (mechanical).

Bounds are named constants with their reasoning at the write site, and
`Append` and `AppendDocumentName` refuse before any seal or enqueue. The
verifier drove text one rune over, a decomposed part one rune over, and a
document field one rune over: each returned a named error, and
`AllNames` and `DocumentNames` were both empty afterwards, so nothing
reached storage. The at-bound value stored and read back rune for rune,
so the rejection is a bound and not a truncation.

## Outside check

Run as written, against the live planes at the head. Passing: the
Indonesian mononym in both its bare and padded forms and its two-word
case; the CJK name in three representations; the Spanish
paternal-plus-maternal pair; the Filipino maternal middle name; the Tamil
patronymic; the MRZ-versus-VIZ disagreement; the 39-character boundary
name. Failing: the post-transition change, on end-dating alone, recorded
under criterion 3 above. The one-over-the-bound input passes.

The cultural fixtures all rode `Parts.FathersFamily` / `MothersFamily` /
`Relation` and read back unchanged, and the payload table carries no
`family`, `given`, `fathers_family`, or `mothers_family` column, so the
task's "extensions, never core columns" rule holds at the schema and not
only in prose.

On the disagreement fixture the stored capture kept `latin_name_raw` as
`Müller, Hans-Peter` and `mrz_line_1` as the upper-case
diacritic-stripped line, byte for byte, and the derived index carried
both spellings plus the folded form. Neither source was rewritten toward
the other.

## Findings

These do not fail a criterion. Each is a review defect under decision 052
or a gap a later task will inherit.

1. **The index does not normalize Unicode form, and a comment says it
   does.** Migration 0011's comment describes the `original` token as
   "the name as asserted, NFC-normalized". `GenerateIndexTokens` only
   trims whitespace. A name typed with a combining diaeresis
   (`U+0075 U+0308`) yields one token and no folded form; the same name
   precomposed (`U+00FC`) yields two. Same name on screen, different
   index, so the matching layer that consumes this will miss the pair.
   The determinism criterion still holds, since the function is a
   function, which is why this is a finding and not a failure.

2. **`ParseMRZName` collapses the distinction `is_mononym` exists to
   record.** The migration's comment says the boolean is explicit rather
   than inferred from an absent secondary identifier, "because at least
   one IDV vendor's undocumented behavior collapses 'no surname' and
   'extraction failed' into the same shape". The parser feeding it sets
   `IsMononym: secondary == ""`, so `SMITH<<` reports a mononym. The
   shipped suite fixes that behavior in place as
   `TestMRZWithExplicitEmptySecondaryIsAMononym`. The comment and the
   code state opposite things.

3. **`DeriveIndexTokens` skips `native_script_name`.** It indexes the
   primary identifier, the secondary identifier, and the Latin raw
   string. A CJK passport's native-script capture, the one field a
   same-script match would key on, never enters the index.

4. **`name_db_test.go` names a target that does not exist.** Its header
   says "Run by `make name-test`". The target is `person-test`, which
   this diff's own Makefile hunk documents correctly.

5. **`Append`'s comment keys current names on `(person, use)`.** The view
   keys on `(person_id, use, representation)`, which the PR body lists as
   a deliberate judgment call. The comment contradicts it.

## Scope

Nothing in the diff is outside the task. The Makefile hunk is comment
only, the generated plane types follow the migration, and the plan file
change is confined to `evidence`, which the fence licenses. The PR body's
judgment calls were checked against the diff and the running system: the
migration-ordering claim, the `(person_id, use, representation)` keying,
the single `parts_ciphertext` blob, and the hand-rolled fold table are
all accurate. The list is incomplete in one place, and that omission is
criterion 3.

The task's `evidence` entries name commit `a5cc923`, one commit behind the
head. `5116962` adds only those entries, so the pointer is honest, but
the PR body's Verification section should carry the head SHA this record
names.
