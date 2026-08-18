---
id: public-web
type: layer
status: draft
milestone: v1
depends_on: []
soft_depends_on: [marks-and-embeds]
binds:
  - decisions/LOG.md#002
  - decisions/LOG.md#024
acceptance: [AC-PW1, AC-PW2, AC-PW3, AC-PW4, AC-PW5]
evidence: []
verified_by: null
---

# public-web

The unauthenticated surface: what the world sees before anyone signs in.

Scope: **landing pages** — the worker-facing story ("your portable
verified record"), the partner/vertical-facing story ("attach to the
identity layer"; routes into party onboarding), and the developer surface
(docs, API reference, published canonicalization vectors, conformance
suite); localized worker landing variants as regional cohorts launch
(EN → TL/HI); acquisition-source landing variants (job-board arrivals,
program referrals) that vary copy and entry point but always terminate in
the same invariant identity flows; **mark resolution pages** — the
public, grant-scoped verification page every mark/QR resolves to (the
soft dependency on marks-and-embeds; the page ships with the mark
system); public party-status pages (registry state + history, per the
eIDAS-style transparency in the party-registry layer); **worker-published records** — a worker may publish their own record
(decision 024; the publish/unpublish control itself is grant machinery, so
that task depends on `consent-and-deletion` even though the layer does
not), served from the ledger origin in invariant chrome, scoped
to exactly what the worker chose to publish, revocable in the same second
as any grant, and carrying the same marks with the same resolution
behaviour as a granted read; SEO/social
hygiene; status page. Publishing is opt-in per record and is not
discoverability: no public person search — a record is reachable
only through worker-shared links and grants (decision 002 §7).

Acceptance:
- AC-PW1: each landing variant terminates in the identical ledger-chrome
  signup/consent flow; no variant forks the trust path.
- AC-PW2: a mark resolution URL renders correctly logged-out, shows
  exactly the grant-scoped content, and degrades gracefully for a revoked
  grant.
- AC-PW3: no unauthenticated route enumerates or searches persons — a
  published record is reachable only by its own link, and is excluded from
  indexing unless the worker opts in separately.
- AC-PW5 (mechanical): unpublishing takes effect on the next read; a
  published record shows exactly the published subset and never a field
  outside it, asserted by diffing against the worker's publish selection.
- AC-PW4: developer docs are generated from the same contract schema as
  the SDKs (no hand-maintained API prose to drift).
