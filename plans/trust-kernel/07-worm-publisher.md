---
id: trust-kernel/07
type: task
layer: trust-kernel
satisfies: [3]
status: ready
depends_on: [trust-kernel/04]
migrations: []
binds: [design/stack-litigation/d3-verdict.md, decisions/LOG.md#005, decisions/LOG.md#019]
evidence: []
verified_by: null
---

# WORM publisher and second-cloud mirror

## Objective

Checkpoints land somewhere nobody can alter them, including us, on two
clouds, the part of D3 that makes the anchoring externally credible.

## Scope

- **Founder-gated.** This task cannot start before the cloud provider
  ruling (decision 011, open) and the cloud accounts + KMS + WORM bucket
  provisioning gate in ORDER.md. Split out of `trust-kernel/04` precisely
  so the rest of the checkpoint work is not blocked behind it.
- Object-lock storage in **compliance mode** in a **dedicated account**
  whose credentials cannot delete or shorten a lock, per D3. The separation
  is the point: an operator with full production access must still be
  unable to alter an anchored checkpoint.
- **Mirror to a second cloud**, per D3's two-cloud requirement, with an
  independent credential path.
- Anchoring drill: a rehearsed, documented exercise proving a checkpoint
  cannot be overwritten or deleted from either target with the strongest
  credentials the operator holds. Run on ephemeral environments, since
  decision 011 ruled out standing staging.
- Genesis-consistency proof: the published anchor chain verifies
  byte-equal from hour zero, per D3's §4.3 argument.
- Note: D3's text names AWS compliance-mode Object Lock specifically. If
  the provider ruling lands on GCP, the equivalent control and any
  capability gap is a finding for that ruling, not something this task
  resolves silently.

## Acceptance

3. (mechanical) checkpoints land in WORM within the interval under
   load, and a deliberate overwrite attempt fails at the storage layer using
   the most privileged credentials available.
- AC (mechanical): both clouds hold the same checkpoint sequence; a mirror
  divergence is detected.
- AC (mechanical): the genesis-consistency proof verifies from hour zero.
- AC: the drill is documented and rerunnable, with its evidence linked.

## Outside check

Verifier attempts deletion and lock-shortening against both targets with
operator credentials, breaks the mirror deliberately and confirms
detection, and re-runs the genesis proof from a clean environment.
