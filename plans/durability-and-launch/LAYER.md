---
id: durability-and-launch
type: layer
status: draft
milestone: v1
depends_on: [foundation, trust-kernel, party-registry, ingestion, person-identity, verification, consent-and-deletion, worker-surface, prior-packet, integration-surface]
binds:
  - design/stack-litigation/docket-rulings-0.1.md
  - counsel/brief-4-worker-agreements.md
evidence: []
verified_by: null
---

# durability-and-launch

The launch-blocking obligations from the ratified docket, proven rather
than configured, plus the legal gate.

Scope: D1 obligations under test — ack watermark and checkpoint-escrow
watermark game-day'd (simulated primary loss at synthetic period-close
load; zero acknowledged attestations lost), fresh-read discipline
verified under replica lag; D3 obligations live — checkpoints landing in
cross-cloud WORM from the first real record, continuous chain
re-verification running as the production auditor (with alias-closure
consistency and deletion-completeness checks, per the AI-native
verification architecture); DR drills (restore from backup + WORM
checkpoint cross-verification of the restored state); "zero loss of
acknowledged attestations" published as the party-facing promise it was
ratified to be; security review of the kernel and auth/recovery paths;
worker agreements returned from counsel and wired into onboarding —
**no real worker onboards before this**; the witnessed-log deadline armed
in the registry (D3 sub-ruling); load validation at synthetic 1M-identity
volumes (trivial by the arithmetic; proven, not assumed).

Acceptance:
1. **The failover drill loses nothing that was acknowledged.** the failover game day loses zero acknowledged attestations and
   the restored state passes full chain + checkpoint cross-verification.
2. **The auditor runs continuously, and killing it is itself an alert.** (mechanical) the production auditor runs continuously and its
   alerts page a human; killing it is itself an alert.
3. **No real worker onboards before counsel signs the agreement.** onboarding structurally refuses a worker where no counsel-final
   consent terms are configured (the Dispatch capture-pipeline pattern).
4. **A million identities is proven, not assumed.** synthetic load at 1M identities / period-close burst meets the
   read and ingest SLOs with the watermarks enforced.
