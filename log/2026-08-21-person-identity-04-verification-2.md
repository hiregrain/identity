# person-identity/04: clean-context verification, second pass (2026-08-21)

Verifier: clean-context session, no implementer transcripts or notes.
Inputs: the task file, PR #16's diff and body, the first verification
record on this branch, and the running system.

Implementation head verified:
`eca55e379924867c1c3874c2493e60572cbe8d89`, the rework commit answering
the first pass's criterion 3 failure. Driven in a worktree checked out
detached at that SHA, working tree clean, under its own compose project,
so host ports 5433 and 5434 were free and the stock `docker-compose.yml`
was used with no override. The compose file declares no volumes and the
run ended with `make db-down`, so the databases were left as found.

Verdict: **FAIL**, on criterion 3 again, for a different reason than the
first pass. The rework end-dates correctly on the path its own test
drives and does not end-date on an ordinary sequential path the public
API allows. Every other criterion holds, and the first pass's five
findings are all closed.

## The standing pipeline

`make check` at the head, one invocation, exit 0, ending `check: green`.
Nothing was staged by hand and no plane-ready wait was needed on this
machine. Green here is a precondition, not evidence for any criterion.

## Criteria

**1. A mononym round-trips storage, matching, and packet render without
acquiring an empty surname or being split; the MRZ no-`<<` case is a
named test.** PASS (mechanical).

`TestMononymMRZWithNoDoubleFillerIsNotSplit` exists under that name and
passes. The verifier's own fixture drove `SATRIYA<SUDARPA` and `BUDI`
through parse, seal, apply, and read-back: `IsMononym` true, secondary
empty, primary `SATRIYA SUDARPA` with the single `<` read as a word
separator, the stored `person_name` row carrying no family part, and no
index token holding a `SATRIYA` or `SUDARPA` fragment. What would have
failed it: splitting on a single `<`, or inferring a surname from the
first token.

**2. Dropping and regenerating `name_index` reproduces it exactly.**
PASS (mechanical).

The shipped test compares a fresh derivation against the persisted set
without dropping anything. The verifier discharged the criterion as
written: as the owner role, `DELETE FROM name_index_entry WHERE
person_id = $1`, confirmed zero rows remained, then `WriteIndex` again
and drained. `StoredIndexTokens` before the drop and after the
regeneration agree token for token on source table, source row, kind,
and decrypted value, 8 tokens each. Command:
`GRAIN_KEY_PROVIDER=software go test -tags db -count=1 -run
TestVerifierIndexDropAndRegenerateReproducesExactly ./person/...`,
exit 0.

**3. A name change appends and end-dates; no row is mutated; the prior
name matches but is absent from an employer render.** FAIL (mechanical).

On the drained path every conjunct now holds, and the verifier confirmed
each independently. Two rows persist for one `(person_id, use,
representation)` triple; the appending row names its predecessor in
`supersedes_outbox_entry_id`; `person_name_effective` resolves the prior
row's `period_end` to the successor's `asserted_at`; the prior row's own
`period_end` column reads NULL under the owner role, so nothing was
written to it; `identity_app` is refused UPDATE and DELETE on
`person_name` outright; and the `UNIQUE` constraint refuses a second row
claiming the same predecessor while the `CHECK` refuses self-supersession.
The derived-end-date mechanism is a sound answer to the first pass's
objection, and a derived end date is the only kind an append-only table
can carry.

The mechanism does not hold on a sequential path the public API allows.
`Append` resolves the row to supersede by querying
`person_name_current`, and that query cannot see a row still sitting in
the outbox. Two `Append` calls for one `(person, use, representation)`
before the worker drains therefore both write
`supersedes_outbox_entry_id` NULL. Reproduced:

```
PROBE RESULT: 2 current rows after two undrained appends
PROBE RESULT: current "Jordan Smith"  supersedes="" period_end=<nil>
PROBE RESULT: current "Jordan Rivera" supersedes="" period_end=<nil>
```

Two conjuncts fall together there. The change appends and does not
end-date, and the prior name is present in the employer-facing read,
which is the exact harm the criterion's third conjunct names and the
reason decision 013 put the withholding at the query layer.

`Append`'s own comment discloses the gap but describes it as a race
between concurrent writers. It is not a race. The probe is one goroutine
issuing two ordinary calls in order, and nothing in the API says a
caller must drain between them. A worker correcting a typo seconds after
submitting a name change is on this path, and foundation/07's reconciler
documents an alert threshold of 60 seconds, so the window is not
sub-second by construction.

The gap belongs to the chosen mechanism, not to the outbox. Both rows
land with distinct `asserted_at` values in outbox order, so a read-time
derivation over the partition would have end-dated the earlier row with
no write-time lookup and no window at all:

```
PROBE RESULT raw rows (asserted_at, supersedes):
  2026-08-21 20:11:58.044132+00	-
  2026-08-21 20:12:03.539864+00	-
PROBE RESULT ordering-derived period_end per row:
  2026-08-21 20:12:03.539864+00
  current
```

That is `lead(asserted_at) OVER (PARTITION BY person_id, "use",
representation ORDER BY asserted_at)`, run against the same two rows the
shipped view leaves both current. It keeps everything the rework bought,
a derived end date and no write against the prior row, and drops the
write-time read that opens the window. The verifier does not prescribe
the fix, only records that one exists inside this task's scope, which is
why this is a failure rather than a limit inherited from foundation/07.

**4. A CJK name with ideographic, romanized, and phonetic entries renders
correctly per purpose.** PASS (adjudicated).

`representation` is part of the current view's key, so all three coexist
as simultaneously current rows, and `RenderFor(use, representation)` is
the per-purpose read.
`TestCJKThreeRepresentationsRenderPerPurpose` drives all three and reads
each back. What would have failed it: a current view keyed on
`(person_id, use)` alone, which would evict two renderings the moment the
third landed. The keying is stated as a judgment call in the PR body and
the migration comment gives the reason at the schema site.

**5. Input exceeding the stated bound is rejected with a worker-visible
error; no path truncates silently.** PASS (mechanical).

Bounds are named constants with their reasoning at the write site, and
`Append` and `AppendDocumentName` refuse before any seal or enqueue. The
verifier drove text one rune over, a decomposed part one rune over, and a
document field one rune over: each returned a named error, `AllNames` and
`DocumentNames` were both empty afterwards, and the owner-role row count
on `person_name` was 0, so nothing reached storage in truncated form.
`TestNameTextAtTheBoundIsAccepted` shows the at-bound value is accepted,
so the rejection is a bound and not a ban.

## Outside check

Run as written against the live planes at the head, as a verifier-authored
fixture file deleted after the run.

Passing: the Indonesian mononym in its two-word and single-word forms;
the Spanish paternal-plus-maternal pair; the Filipino maternal middle
name; the Tamil patronymic with no family name at all; the CJK name in
three representations; the MRZ-versus-VIZ disagreement; the 39-character
boundary name; the input one rune over the bound.

Failing: the post-transition change, on the undrained path, recorded
under criterion 3. On the drained path the same fixture passes: the
prior name stays matchable through `DeriveIndexTokens` and is absent from
both `CurrentNames` and `RenderFor`.

Every cultural fixture rode `Parts.FathersFamily`, `Parts.MothersFamily`,
and `Parts.Relation` and read back unchanged, and `person_name` carries no
`family`, `given`, `fathers_family`, or `mothers_family` column, so
"extensions, never core columns" holds at the schema and not only in
prose.

On the disagreement fixture the capture kept `latin_name_raw` as
`Müller, Hans` and `mrz_line_1` as the upper-case diacritic-stripped
line, byte for byte, and the derived index carried both spellings.
Neither source was rewritten toward the other.

Privilege probes, all refused:

```
UPDATE person_name           -> ERROR: permission denied for table person_name
DELETE FROM person_name      -> ERROR: permission denied for table person_name
second row superseding one predecessor
                             -> ERROR: duplicate key value violates unique
                                constraint person_name_supersedes_outbox_entry_id_key
row superseding itself       -> ERROR: new row violates check constraint
                                person_name_check1
```

A full `pg_dump` of the payload plane after appending a distinctive name
and writing its index contains no plaintext of that name, so
`name_index_entry` does not become the first plaintext PII on the payload
plane.

## The first pass's findings

All five are closed at this head, checked against the diff rather than
against the commit message.

1. The NFC claim is gone from migration 0011's comment, which now states
   that no Unicode normalization runs and why. Behavior unchanged, so the
   comment and the code agree.
2. `ParseMRZName` gains `SeparatorPresent`, so a field carrying no `<<`
   is distinguishable from one carrying `<<` and an empty secondary.
   `TestMRZWithExplicitEmptySecondaryIsAMononym` asserts the distinction.
3. `DeriveIndexTokens` now indexes `native_script_name`, asserted in
   `TestNameIndexRegenerationReproducesExactly` and reconfirmed by the
   verifier's own fixture.
4. `name_db_test.go`'s header now names `make person-test`.
5. `Append`'s comment now keys current names on
   `(personID, n.Use, n.Representation)`, matching the view.

## Findings

Neither fails a criterion on its own.

1. **The task's `evidence` entries name `a5cc923`, two commits behind the
   head.** The tests those entries cite changed at `eca55e3`, so the
   pointer no longer names the code that was run. `evidence` is inside the
   fence a tool may rewrite; it stays untouched here because the task is
   not passing.
2. **The PR body still describes the superseded mechanism.** Its
   criterion 3 line says "current" is `DISTINCT ON` latest `asserted_at`,
   which `eca55e3` replaced with `person_name_effective` and the
   supersession pointer, and its judgment-call list does not mention the
   supersession pointer at all. A reader checking the claims against the
   diff finds them describing the previous commit.

## Scope

Nothing in the diff is outside the task. The Makefile hunk is comment
only, the generated plane types follow the migration, and the plan file
change is confined to `evidence`, which the fence licenses. The PR body's
judgment calls were checked against the diff and the running system: the
migration-ordering claim, the `(person_id, use, representation)` keying,
the single `parts_ciphertext` blob, the encrypted index, and the
hand-rolled fold table are accurate as far as they go. See finding 2 for
where the list has fallen behind its own diff.
