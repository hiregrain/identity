# Green-path fixture: exact copy, and a splice marked with […]

An exact quote:

> **Verbatim from `test/fixtures/verbatim/source.md`:**
>
> The worker keeps custody of the record. An employer's interest in your
> record ends when you leave; the worker's does not.

A deliberate splice, marked:

> **Verbatim from `test/fixtures/verbatim/source.md`:**
>
> The worker keeps custody of the record. […] Every claim
> carries its provenance and resolves to the evidence beneath it.

`make check-red` asserts checks/verbatim-copies.mjs passes this file.
The port must be proven to match, not only to fail.
