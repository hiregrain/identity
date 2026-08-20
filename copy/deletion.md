# Deletion, worker-facing copy

<!--
This file is the CANONICAL worker-facing deletion copy (foundation/08).
Every surface that explains deletion to a worker, the in-app deletion
control (decision 038), settings, the consent instrument's deletion
paragraph, renders or paraphrases THIS text; no surface states its own
numbers. The day counts below are promises, and they are the same
numbers db/deletion-policy.json enforces: checks/deletion-copy.mjs fails
the build when this file and that config drift, in either direction.
Change the number there and here in the same commit, or the pipeline is
red. Grammar the check relies on: every day count in this file is
written as "<number> days".
-->

When you delete your record, this is what happens and when.

**Immediately.** Access to your record stops. Every grant you have made
is revoked, and you disappear from anything Grain would have issued
about you. The key that makes your record readable is destroyed. It is
not held anywhere else, so from this moment nothing about you can be
read from Grain by anyone, including us.

**Within 30 days.** The unreadable remains of your data are physically
removed from our systems on a fixed schedule, and every backup that
predates your deletion expires. Backups are kept for at most 30 days,
ever. If we ever restore from a backup, your deletion is re-applied
before that system serves a single request; a backup cannot bring you
back.

**What remains, permanently.** The ledger keeps an anonymous tombstone:
an internal identifier, cryptographic fingerprints, and timestamps. That
is enough for the ledger to prove its own history has not been tampered
with, and for the parties who attested about you to account for what
they issued. None of it says who you were, and none of it can be turned
back into your record. Your identifier is never given to anyone else.

**What deletion cannot do.** A record someone already received while you
permitted it is in their hands, under the terms they accepted; deletion
stops every future read, but it cannot recall a past one. And the
organisations that attested about you keep their own records of the work
itself. Those were never in Grain.

Deletion is your right, with no gate. Filing the request stops access at
once; the erasure itself completes after a 3 days confirmation window,
which you can cancel at any time in the app or through support. The
window exists only so nobody can force you to delete your record on the
spot.
