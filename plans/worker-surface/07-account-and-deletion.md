---
id: worker-surface/07
type: task
layer: worker-surface
satisfies: [1, 3, 5, 6, 7, 8]
status: draft
depends_on: [worker-surface/01, worker-surface/06]
binds:
  - decisions/LOG.md#035
  - decisions/LOG.md#036
  - decisions/LOG.md#038
  - decisions/LOG.md#059
  - decisions/LOG.md#063
  - design/13-platform-screens
evidence: []
verified_by: null
---

# The account, the ledger, and getting out

## Objective

Everything a worker does to their account rather than to their record,
including leaving.

Surfaces implemented: H1, H1a, H2, H3, H4, H5, H6, H7, H7a, H7b, I7.

## Scope

- Account, the ledger, notification preferences, language, export, the
  disclosure record, support, deletion and its grace state, unlock, sign out,
  and the notification permission.
- **The ledger is reachable and is the thing itself** (decision 059). The
  record is a reading of it; nothing in it can be edited or removed, by the
  worker or by Grain, and a correction is a new entry.
- **Deletion files a request and never executes it** (decision 038). Access
  stops the moment it is filed, support executes after the grace period, and
  signing in during that period resets it and requires a fresh request.
- **The disclosure record shows grants AND operator reads** (decisions 035
  §B4, 063). Grantee reads are not recorded so they cannot appear.
  Privileged-operator reads are chained kernel events with a recorded reason
  and are rendered here, which is the one read a worker does get told about.
- Export is asked for and arrives by email within 24 hours (decision 036).
- Unlock is biometrics or the device passcode, declinable, default on
  (decision 038). It cannot gate the public page, which is public by
  construction.
- Hindi is offered only when a Devanagari face exists; `DESIGN.md` gap 7 makes
  that launch-blocking rather than a coming-soon.

## Acceptance

- AC (mechanical): filing a deletion request revokes the worker's own read
  access immediately, and executes nothing, proven by advancing the clock past
  the grace period with no further action and confirming the record survives
  until support acts.
- AC (mechanical): signing in during the grace period cancels the request and
  restores every unexpired grant.
- AC (mechanical): the disclosure record renders every privileged-operator
  read with its recorded reason, and no grantee read, asserted against the
  kernel's event chain.
- AC (mechanical): no ledger entry can be mutated or deleted through any path
  this task exposes.
- AC (adjudicated): the deletion surface states that attestations other
  parties made are erased too and cannot be recovered by them either.

## Outside check

Verifier files a deletion, waits past the grace period without acting, and
confirms nothing was destroyed. Then signs in and confirms the request is
cancelled and grants are restored.
