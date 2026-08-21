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
  - decisions/LOG.md#035
  - decisions/LOG.md#038
  - design/08-app-inventory.md
evidence: []
verified_by: null
---

# public-web

The unauthenticated surface: what the world sees before anyone signs in.

**Scope added 2026-08-19 (decision 040 §D): the account-deletion request page.**
Google Play requires **both** an in-app deletion path **and** "a web link resource
where users can request app account deletion." Decision 038 closed only the in-app
half; the web half is a store requirement no app change satisfies. It is a plain,
guessable page that files the same support request the app files, reachable
without an account, and it must agree with the consent instrument and with
decision 036 line by line; `app-distribution` criterion 3 checks that by diff.

**Scope added 2026-08-19 (decision 038): the attestation surface.** Decision 035
gave every attester an account with verified identity, and 038 ruled that flow
lives on the web rather than in the native app. So this layer also carries the
invitation landing a link opens, attester sign-up, work-email confirmation for
the manager tier, which also employment-verifies the attester's own chapter,
submission, and the hand-off to their own empty record. The **form itself stays
`peer-references`** (ledger-authored, no free-response field, decision 025); what
lives here is everything around it. This is the product's primary growth loop and
it is no longer gated on a mobile install.

Scope: **landing pages**: the worker-facing story ("your portable
verified record"), the partner/vertical-facing story ("attach to the
identity layer"; routes into party onboarding), and the developer surface
(docs, API reference, published canonicalization vectors, conformance
suite); localized worker landing variants as regional cohorts launch
(EN → TL/HI); acquisition-source landing variants (job-board arrivals,
program referrals) that vary copy and entry point but always terminate in
the same invariant identity flows; **mark resolution pages**: the
public, grant-scoped verification page every mark/QR resolves to (the
soft dependency on marks-and-embeds; the page ships with the mark
system); public party-status pages (registry state + history, per the
eIDAS-style transparency in the party-registry layer); **worker-published records**: a worker may publish their own record
(decision 024; the publish/unpublish control itself is grant machinery, so
that task depends on `consent-and-deletion` even though the layer does
not), served from the ledger origin in invariant chrome, scoped
to exactly what the worker chose to publish, revocable in the same second
as any grant, and carrying the same marks with the same resolution
behaviour as a granted read; SEO/social
hygiene; status page. Publishing is opt-in per record and is not
discoverability: no public person search. A record is reachable
only through worker-shared links and grants (decision 002 §7).

**The mockup gate applies here too** (`plans/worker-surface/LAYER.md` § Design
venue). The public page and the attestation surface are drawn before they are
built.

**Both halves of the public page are drawn**, in
[`design/13-platform-screens/`](../../design/13-platform-screens/) and imported
by `design/14-web-app`: the view a person loads, carrying the imprint, and the
crawler payload, which carries the same words with the figure left out. Decision
056 is what splits them, and they are two surfaces rather than one so the
difference is inspectable rather than asserted. Reached from the worker's own
public-page management screen, which is where a worker decides to publish at
all. `design/10-worker-app-screens/Public.dc.html` is the prior drawing and is
superseded by these.

**The attestation surface is still undrawn.** Decision 038 makes it this layer's
scope and the product's primary growth loop, and the mockup gate therefore
blocks building it. Its form is also partly gated: the seven-measure form itself
belongs to `peer-references` and cannot be drawn while decision 054's measure-set
divergence is open.

Acceptance:
1. **Every landing page ends in the same ledger chrome.** each landing variant terminates in the identical ledger-chrome
   signup/consent flow; no variant forks the trust path.
2. **A mark resolves without a login, and shows only what the grant allows.** (mechanical) a mark resolution URL renders logged-out and its
   rendered content equals the grant's scope exactly, no field outside it, and
   every field within it present. On a revoked, expired, or never-issued grant
   the same URL returns the identical response: the record exists, its contents
   are not disclosed, and nothing distinguishes the three cases to the caller,
   including by status code, body length, or timing.
3. **Nobody can enumerate or search people without signing in.** no unauthenticated route enumerates or searches persons. A
   published record is reachable only by its own link, and is excluded from
   indexing unless the worker opts in separately.
4. **Unpublishing takes effect on the very next read.** (mechanical) unpublishing takes effect on the next read; a
   published record shows exactly the published subset and never a field
   outside it, asserted by diffing against the worker's publish selection.
5. **The developer docs are generated from the contract, not written beside it.** developer docs are generated from the same contract schema as
   the SDKs (no hand-maintained API prose to drift).
