# foundation/08 — clean-context verification (2026-08-19)

Verifier: clean-context session, no implementer transcripts. Inputs: the
task file, the layer file, PR #8's diff and body, and the repo protocol.
Verified head: `db0dd6472c0306684256b61f5156399ae27bd3be` (initial pass
driven at `336c48cef51492bd3cdb88a98545971445637a39`; the delta between
the two — a red-path relabel and a merge of main's one-line migrations
claim — re-verified separately below). Fresh clone; sibling verification
held the compose host ports, so the clone ran under a no-ports override —
every database access in this repo goes through `docker compose exec`,
so nothing under test touches a host port.

Verdict: **PASS** — layer criteria 6 and 7's restore side, and every
task AC.

## CI

All ten checks green at `336c48c` and again at `db0dd64` (metadata,
red-path fixtures, lint, db replay + typegen, go, ts, envelope both
providers, outbox, deletion mechanics, fan-in).

## Diff scope and merge fidelity

`origin/main` at the time of the first pass was the merge-base, so the
task diff was exactly the 24 files the PR body claims. The mid-task
merge of main (foundation/06) was checked by re-running the merge
mechanically (`git merge-tree`) and diffing the trees: the hand
resolution is confined to the Makefile conflict — the union of both
branches' targets, `deletion-test` added to main's `check` line, the
database red path renumbered to db 10 — plus registering
`deletion-copy` in `checks/run.mjs`, which is main's runner owning
metadata membership. Nothing outside the buckets. The later merge at
`db0dd64` produced a tree bit-identical to the mechanical re-merge.
No scope creep found in the task content.

## The driven sequence (verifier's own, not the shipped test)

A one-process Go driver written by the verifier (software provider is
process-ephemeral by ruling, so the crypto-shred proof requires the
provisioning provider instance), driving `db/backup.mjs`,
`db/restore.mjs`, the `deletion` CLI and raw psql exactly as an
operator would. Outcomes, in order:

1. Two people provisioned with encrypted content markers.
2. Pre-deletion backup taken via `node db/backup.mjs` (retention prune
   ran and reported).
3. Person destroyed via `deletion.Destroy` (`worker`); read fails
   closed with `ErrNoActiveDEK`; journal row `worker` on the spine.
4. Backup restored via `node db/restore.mjs` into a recreated payload
   container. **Byte-level resurrection reproduced**: the restored
   registry held the person's pre-deletion `created` row with a 60-byte
   wrapped DEK and no `destroyed` row.
5. **Gate**: with the restore unreplayed, `Decrypt`, `Encrypt` and
   `Provision` all refused with `ErrNotServing` (living person
   included); `deletion status` would exit 1; `OpenRestores` reported
   exactly the one restore id.
6. `Destroy` confirmed to work while gated — the deliberately ungated
   verb the replay depends on; no deadlock.
7. `deletion.Replay` re-applied 1 journaled destruction and balanced
   the gate.
8. **Post-replay**: read fails closed (`ErrNoActiveDEK`) AND the
   registry-bypass path — pulling the restored wrapped DEK as owner and
   unwrapping at the provider — fails at the crypto-shred. Not app
   refusal alone.
9. The living person's content decrypted intact after the whole
   sequence; `deletion status` exited 0 serving.
10. Raw full dumps of BOTH planes grepped clean of both markers in
    plaintext and hex form.
11. Purge run via the CLI with `-initiated-by clean-context-verifier`;
    audit row inspected:
    `dek_registry|1|clean-context-verifier|identity_purge|us`. The
    shredded `created` row was removed; the `destroyed` row survived.
12. Retention copy-drift check fired in both directions — config moved
    (31) with the copy stale → exit 1 "hidden window"; copy stating 45
    days nothing enforces → exit 1 "promise nothing keeps" — and passed
    again after revert.

## Independent probes

- **RLS narrowing (raw psql as `identity_purge`)**: DELETE of a
  shredded `created` row removed it; DELETE targeting a living
  person's `created` row and a `destroyed` row completed as statements
  but affected zero rows — both rows survived, enforced by the policy,
  not an error message (RLS filters rather than errors; the protection
  claim holds). DELETE as `identity_app`: `permission denied`.
- **Journal**: free text into `requester_class` refused by the CHECK
  constraint; UPDATE and DELETE as the serving role both
  `permission denied`; the spine dump's journal section carries only
  the opaque uuid, the closed class value, and a timestamp.
- **Living-person survival**: item 9 above.
- **Standing proofs at head**: `test/append-only.test.mjs` — 18
  assertions green on both planes with EXEMPTIONS carrying exactly the
  one purge entry; red path db 10 (unlicensed DELETE grant to the purge
  role) fails the standing proof and the revert restores green;
  `make check-red` (all file-only red paths incl. the deletion-copy
  path), `make check-red-db`, and full `make check` all green at
  `db0dd64`.

## Judgment assessments

- **restore_gate as the honest pre-server "refuses traffic"**: sound.
  The rule is one SQL statement executed in one place
  (core/envelope's `servingGateSQL`), state is append-only database
  state a restart cannot forget, and both failure branches fail
  closed. What enforces that a future server cannot bypass it by
  skipping core/envelope: readability itself — payload content is
  ciphertext, and decryption passes through the envelope/provider, so
  a bypassing server obtains only wrapped bytes. The residual risk (a
  future server persisting plaintext outside the envelope) is outside
  this layer's claim and is governed by the layers that add content
  tables. Not theater.
- **Destroy deliberately ungated**: sound — the replay IS destruction;
  gating it deadlocks the step that opens the gate. Being ungated
  widens no readability.
- **30 days as unruled judgment**: correctly flagged as such; no
  decision rules a number, config is the single enforcement source,
  and the check forces the copy to move in the same commit. A founder
  decision entry can supersede it in one commit.
- **`copy/deletion.md` as a new top-level directory**: acceptable —
  `contract/` holds the ratified binding interface, `surfaces/` would
  wrongly bind canonical prose to one renderer.
- **RLS-scoped purge grant with SECURITY DEFINER helper**: strong; the
  helper is a single SELECT and the standing proof's SECURITY DEFINER
  scan covers it (1 function scanned, asserted green); ENABLE-not-FORCE
  justified by owner tooling.
- **Single-provider deletion-test**: sound — everything the suite
  proves is provider-independent registry/grant state; the swap is
  proven both ways in `envelope-test`.
- **The recorded RAISE (0022 unclaimed in `migrations:`)**: honestly
  surfaced in the PR body as outside the implementer's fence; resolved
  on main by `5b488c3` (docs(plans)) and merged into the branch, so the
  head's frontmatter claims both migrations.

## Delta re-verification (`336c48c..db0dd64`)

Content: exactly `8dc8737` (relabel deletion-copy red path 8 → 13,
closing the duplicate-8 collision with the decisions-index path) plus a
faithful merge of main carrying `5b488c3` (the one-line migrations
claim). Tree of the merge equals the mechanical re-merge. At the head:
`make check-red` prints a single "red path 8" (decisions-index) and the
deletion path as "red path 13" with the full sequence intact; CI green;
`make check` green locally.
