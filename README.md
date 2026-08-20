# Grain: identity

The trust layer that replaces the résumé. A portable, worker-owned,
cryptographically verifiable record of what a person has actually done,
attested by the parties that observed it, visible to whoever the worker
permits.

The record layer is free to everyone, permanently. Analytics on a person's
work history and trajectory is the first product. Identity is the platform;
everything else is secondary to it.

**Org:** `hiregrain/identity` · **First vertical:** [`hiregrain/dispatch`](https://github.com/hiregrain/dispatch) ·
**Hospitality product:** [`hiregrain/grain`](https://github.com/hiregrain/grain)

Start with [`THESIS.md`](THESIS.md): the argument, what it commits the
architecture to, and the gaps that are the work queue.
[`decisions/LOG.md`](decisions/LOG.md) records the calls already made, in one
append-only numbered file. [`CLAUDE.md`](CLAUDE.md) is the agent and developer
guide and states which source wins when two disagree.

## Repository map

Each part has a position in a chain, and every arrow is a constraint:

```
THESIS.md        why this exists
    ↓
decisions/       what we have settled        ← research/ informs, never binds
    ↓
model/           the shapes that bind        ← counsel/ instructs outside counsel
    ↓
plans/           what to build, with acceptance criteria
    ↓
(code)           the running system — none yet; the plan gate holds
    ↓
log/             what happened
```

- Nothing in `model/` may contradict `decisions/`.
- Nothing in code may contradict `model/`. That check is why documentation and
  code share one repository.
- `plans/` reference `model/` by pointer and carry the criteria that gate
  completion. Execution order is derived from per-task `depends_on`, never
  written down twice, see [`plans/ORDER.md`](plans/ORDER.md).
- `research/` feeds decisions and **binds nothing**. A figure there describes
  what someone else did; it is not a requirement, a target, or a spec.

## The rest

- [`DESIGN.md`](DESIGN.md) and [`design/`](design/): the visual system, its
  laws and the research behind them; also the stack litigation that settled
  the infrastructure decisions.
- [`imprint/`](imprint/) and [`mark/`](mark/): the per-person figure and the
  logo, each with a runnable generator and its constraints recorded.
- [`counsel/`](counsel/): engagement briefs for outside counsel. Questions
  asked, not answers received.
- [`handoff/`](handoff/): the package this repo was seeded from. Dated
  records; the live versions live in `model/` and `THESIS.md`.
- [`contract/`](contract/): the language-neutral schema and canonicalization
  vectors any implementation is tested against.
