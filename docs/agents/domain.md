# Domain Docs

How the engineering skills should consume this repo's domain documentation.
This repo predates this file and already carries its own equivalents; the
skills read those rather than a parallel structure. There is no `CONTEXT.md`
and no `docs/adr/` — do not create them.

## Before exploring, read these

- **`CLAUDE.md`** — the operating rules and the source-of-truth precedence.
- **`THESIS.md`** — the argument and the product; its `[GAP]` markers are the
  work queue.
- **`decisions/LOG.md`** — this repo's ADR log. Append-only, numbered; an
  entry is referenced by number (`decision 042`) and the number is stable.
- **`model/`** — binding structure. RATIFIED binds; PROPOSED does not.
- **`research/`** — evidence only; it informs and never constrains.

## Use the repo's vocabulary

When output names a domain concept (an issue title, a spec, a test name), use
the term as the thesis and model files define it: *person* and *attesting
party* (the only two entity types), *chapter*, *attestation*, *grant*, *mark*,
*imprint*, *packet*. Two hard rules from `CLAUDE.md`: organisations are never
subjects, and no surface collapses a graded epistemic claim into a yes.

If a needed concept has no defined term, that is a signal — either the
language is being invented (reconsider) or there is a real gap (raise it,
don't coin quietly).

## Flag decision conflicts

If output contradicts an entry in `decisions/LOG.md`, surface it explicitly
rather than silently overriding:

> _Contradicts decision 027 (the pointer never says "verified") — but worth
> reopening because…_

A decision is not reopened by inference; propose a superseding entry instead
of designing against it.
