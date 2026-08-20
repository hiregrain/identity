-- 0021-deletion-journal (foundation/08; decisions 014, 017; design
-- ledger-design-0.1 §2.5): the append-only record of every destruction,
-- on the spine chain under the one shared numbering sequence. Number
-- claimed by the task frontmatter.
--
-- Why a journal exists at all: the destroy primitive (foundation/05,
-- core/envelope) makes a person's payload unreadable the instant their
-- DEK is destroyed. However, a backup taken before the deletion still
-- holds the wrapped key, so a restore resurrects the person at the byte
-- level.
-- Decision 017's ruling closes that: every restore of the payload plane
-- MUST replay this journal before the restored system accepts traffic
-- (the restore gate, migration 0022 and core/envelope). The journal is
-- therefore exactly what a replay needs and nothing more: which person,
-- when, on whose request. It lives on the spine because the spine is the
-- ordering and durability authority (decision 011) and because the
-- payload plane is the thing being restored. A journal stored in the
-- plane it repairs would be restored to its pre-deletion state too.
--
-- THE CRYPTO-SHREDDING LEGAL POSITION (decision 017 item 3, recorded
-- here at the schema site as a documented position, not a mechanical
-- proof). Destruction of the person's DEK is instant and irreversible;
-- the ciphertext rows that remain until the scheduled physical purge
-- (migration 0022) are unreadable to everyone, the ledger operator
-- included, because the subject-scoped key that could read them no
-- longer exists anywhere (single wrap, no co-owner key; migration 0005,
-- decision 017). Decision 014's analysis of *EDPS v SRB* (C-413/23 P)
-- carries the reasoning: data is personal to a holder only where that
-- holder can re-identify the person, and what made the rejected design
-- personal data was retaining the means of re-identification. Here the
-- means of re-identification IS the destroyed key. After destruction the
-- ledger cannot re-identify. That is the load-bearing fact, so key
-- destruction constitutes erasure of the payload content, and the purge
-- that later removes the dead ciphertext is hygiene on a stated
-- schedule (db/deletion-policy.json), not the erasure event itself.
-- The spine's own residue for a deleted person (tombstoned object ids,
-- commitments, timestamps; design §2.5 item 3) carries nothing
-- readable, which is the two-plane split doing its job.
--
-- What the journal deliberately does NOT carry: no name, no contact
-- channel, no content, no commitment, no reason text. None of it is
-- identifying. person_id is the tombstoned ledger id the spine retains
-- forever anyway (decision 014: never reissued), so the journal adds no
-- correlation surface the spine does not already have. A schema
-- assertion and a raw-dump grep in the acceptance suite
-- (core/deletion) hold the column set to exactly this.
--
-- Append-only like every spine table (migration 0002): the journal
-- GRANTS NOTHING and exempts nothing. A destruction is recorded by
-- INSERT as the serving role; nothing here is ever updated or deleted.
-- The journal must outlive every backup of the payload plane, which is
-- the property the replay stands on.
--
-- Write ordering (core/deletion executes it): the journal row commits
-- FIRST, then the payload-plane destroy (registry row + provider
-- shred, core/envelope). Both halves are idempotent, so a crash between
-- them is retried forward, the same recovery grammar as the cross-plane
-- outbox (0020), and the same reason there is no compensation path: the
-- spine is append-only. A journal row whose payload destroy has not
-- happened yet is completed by the next destroy retry or by any replay.
--
-- justify-column: deletion_journal.requester_class (text)
--   1 ordering: none; a closed two-value vocabulary, CHECK-enforced.
--   2 timestamp-granularity: not a timestamp.
--   3 external-roster-join: the values name which product flow filed
--     the destruction ('worker': the in-app control that files the
--     request, decision 038; 'support': the support-mediated execution
--     path, decision 036). No person-derived value can reach this
--     column.
--   4 commitment-salt-reuse: not a commitment; no salt.
--   5 partial-dataset-adversary: an adversary holding a spine dump
--     learns that a deletion was worker-filed or support-executed.
--     That is a fact about this product's only two deletion flows, the
--     same for every row; risk accepted, it describes process, never
--     the person.
--
-- recorded_at is the allow-listed ledger-timestamp domain; question 2
-- of the correlation checklist, answered for this column's semantics:
-- it reveals the instant of deletion, which the spine already exposes
-- as the tombstoning instant of the same id. No new granularity is
-- introduced, and the replay needs no precision at all (it replays
-- every row regardless of age).

CREATE TABLE deletion_journal (
    person_id spine_object_id NOT NULL,
    requester_class text NOT NULL
      CHECK (requester_class IN ('worker', 'support')),
    recorded_at spine_ledger_timestamp NOT NULL DEFAULT now()
);

-- One journal row per person, ever: a person is destroyed once (the
-- registry's dek_registry_one_destroyed mirrors this on the payload
-- side), and the destroy path inserts with ON CONFLICT DO NOTHING
-- against this index so a retried destroy is a no-op, never a second
-- row. A merged person's destruction journals every id in the alias
-- closure, one row per id, so a replay needs no closure computation.
CREATE UNIQUE INDEX deletion_journal_one_per_person
  ON deletion_journal (person_id);
