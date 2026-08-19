# Red-path fixture: a labeled quote that drifted from its source

> **Verbatim from `test/fixtures/verbatim/source.md`:**
>
> The worker mostly keeps custody of the record, within reason.

The word "mostly" is commentary smuggled inside the quote;
`make check-red` asserts checks/verbatim-copies.mjs fails it.

> **Verbatim from `test/fixtures/verbatim/source.md`:**
>
> Every claim
> carries its provenance […] The worker keeps custody

The splice runs backwards through the source; the check fails that too.
