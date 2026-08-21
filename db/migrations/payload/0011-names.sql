-- 0011-names (person-identity/04; decisions 013, 020; research/11's
-- reference model is FHIR HumanName, cited in the task file as
-- research/13, a stale number this migration does not correct: the
-- fence reserves plan and research files to human/agent authorship, and
-- the content the task cites lives at 11-signup-identifiers-and-names.md
-- today). Number 0011 under the one shared numbering sequence, claimed
-- by the task frontmatter, the next payload number no landed file holds.
--
-- Everything here is name content: worker-owned free text, verified
-- document capture, or a derived matching index. All three are payload
-- content, sealed under the person's own DEK before they ever reach this
-- plane (core/envelope, following person_record.display_name_ciphertext
-- and person_contact_channel.address_ciphertext, migration
-- 0036-person-record-and-channels). A ciphertext column cannot express a
-- length bound; sealing changes the length. Bounds live at the write
-- site (core/person) and are enforced there, loudly, never by silent
-- truncation (decision 020).
--
-- Nothing here is ever updated or deleted. identity_app holds SELECT and
-- INSERT (migration 0002); this migration grants nothing further and
-- exempts nothing, so test/append-only.test.mjs proves these tables the
-- same way it proves every other payload table.
--
-- Every payload table's residency_region needs a DEFAULT, never a value
-- an INSERT names: core/outbox's Instruction refuses any instruction
-- that names the column, because an instruction choosing its own region
-- is the exact thing the default exists to prevent (0036's own
-- reasoning). 0036-person-record-and-channels defines
-- declared_residency_region() for that purpose, but it lands at number
-- 0036, after this file under the shared numbering sequence, so this
-- migration cannot call it. own_declared_residency_region() below is the
-- same one-line function under a name that does not collide with 0036's
-- when both migrations are live in one database.
CREATE FUNCTION own_declared_residency_region() RETURNS residency_region
LANGUAGE sql STABLE AS $$
  SELECT residency_region FROM database_residency
$$;

-- person_name: append-only name assertions (decision 013's three-layer
-- model, layer one and its FHIR HumanName shape). One row per assertion,
-- never mutated. "A name change appends and end-dates" (the task's
-- criterion) is met without an UPDATE, by the same idiom migration
-- 0010-person-core already uses for lifecycle: the CURRENT name for a
-- (person_id, use, representation) triple is the latest row, read
-- through the view below,
-- exactly as person_tombstoned reads the latest lifecycle transition.
-- period_start/period_end hold a validity window ONLY when the source
-- of the name states one explicitly (a document's own stated period);
-- an ordinary worker-driven name change carries neither, and "current"
-- still resolves correctly because it comes from insertion order, not
-- from a column a later write would have to touch.
--
-- text_ciphertext is the authoritative rendering and is always present:
-- unlike person_record.display_name_ciphertext (optional, worker may
-- give no name at all), a person_name row exists only because a name was
-- asserted, so its text is never absent. The invariant that text
-- contains nothing absent from parts_ciphertext is enforced at the
-- write site (core/person), since a ciphertext column cannot express it
-- either.
--
-- parts_ciphertext is one JSON blob, not one column per decomposed part:
-- family (0..1), given (0..*), prefix (0..*), suffix (0..*), plus the
-- cultural extensions the task requires never become core columns
-- (fathers_family, mothers_family, the Spanish/Portuguese two-surname
-- case and the PhilSys maternal middle name sharing this one mechanism;
-- relation distinguishing a person's own lineage name from a
-- marriage-derived partner name). One blob keeps every cultural
-- structure an extension of the same field rather than a bespoke
-- column, which is the task's own rule for this part of the model.
-- NULL when the name carries no decomposition at all (an Aadhaar-style
-- unsplit string, or any name given only as running text).
CREATE TABLE person_name (
    outbox_entry_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    text_ciphertext bytea NOT NULL,
    parts_ciphertext bytea,
    "use" text NOT NULL
        CHECK ("use" IN ('usual', 'official', 'old', 'maiden', 'nickname', 'anonymous', 'temp')),
    representation text NOT NULL
        CHECK (representation IN ('IDE', 'ABC', 'SYL')),
    period_start timestamptz,
    period_end timestamptz,
    asserted_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT own_declared_residency_region(),
    CHECK (period_end IS NULL OR period_start IS NULL OR period_end >= period_start)
);

CREATE INDEX person_name_by_person ON person_name (person_id);

-- The query-layer rule, as a view rather than a column: the CURRENT name
-- per (person_id, use, representation) is the most recently asserted
-- row. Representation is part of the key, not just use, because a CJK
-- person legitimately holds three simultaneously current rows for one
-- use (ideographic, romanized, phonetic); collapsing on use alone would
-- make two of the three vanish from every "current" read the moment all
-- three exist. This is what makes a prior name "absent from an employer
-- render" without deleting or mutating it: an employer-facing read
-- selects through this view, a matching read selects the base table
-- directly, and the same rows answer both questions.
CREATE VIEW person_name_current AS
SELECT DISTINCT ON (person_id, "use", representation)
       outbox_entry_id, person_id, text_ciphertext, parts_ciphertext,
       "use", representation, period_start, period_end, asserted_at,
       residency_region
  FROM person_name
 ORDER BY person_id, "use", representation, asserted_at DESC, outbox_entry_id DESC;

-- document_name: one row per verified document, immutable, in ICAO
-- Doc 9303's own vocabulary (primary/secondary identifier, never
-- first/last name, because ICAO's split is not the Western one and a
-- mononym is its normal path rather than an error case). name_ciphertext
-- carries the sensitive strings as one sealed JSON blob: primary_identifier,
-- secondary_identifier (absent for a mononym), native_script_name, and
-- latin_name_raw (the VIZ Latin string), plus mrz_line_1/mrz_line_2 when
-- the document carries an MRZ. Both MRZ and VIZ are retained, because
-- they routinely disagree without either side being wrong (ICAO's own
-- transliteration tables, 39 characters of name field on a TD3 passport)
-- and no vendor documents a precedence rule; core/person never treats one
-- as authoritative over the other.
--
-- possibly_truncated is the ICAO truncation signal, stored rather than
-- resolved: an alphabetic character at MRZ line-1 position 44 means "may
-- have been truncated" and is indistinguishable from a name that exactly
-- fills the field. Recording the flag is the honest answer; guessing
-- which case it was would not be.
--
-- is_mononym is an explicit boolean, not inferred from a null
-- secondary_identifier, because at least one IDV vendor's undocumented
-- behavior collapses "no surname" and "extraction failed" into the same
-- shape (research/11 B.2); recording which one this row asserts is the
-- whole reason the column exists.
CREATE TABLE document_name (
    outbox_entry_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    document_type text NOT NULL CHECK (length(document_type) BETWEEN 1 AND 64),
    issuing_country text NOT NULL CHECK (issuing_country ~ '^[a-z]{2}$'),
    script_code text NOT NULL CHECK (script_code ~ '^[A-Z][a-z]{3}$'),
    source text NOT NULL
        CHECK (source IN ('MRZ', 'VIZ', 'BARCODE', 'SELF_ATTESTED')),
    is_mononym boolean NOT NULL,
    possibly_truncated boolean NOT NULL,
    name_ciphertext bytea NOT NULL,
    captured_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT own_declared_residency_region()
);

CREATE INDEX document_name_by_person ON document_name (person_id);

-- name_index: derived, regenerable, never a source of truth (decision
-- 013). Dropping every row for a person and regenerating from
-- person_name and document_name must reproduce the same logical set
-- (the task's own mechanical criterion), which is a property of
-- core/person's generator, not of this table.
--
-- token_ciphertext, not plaintext: an unencrypted index would be the
-- first plaintext PII this repo's payload plane has ever carried, and it
-- would survive deletion in the clear, which contradicts the standing
-- "nothing survives deletion by default" posture (decision 014) that no
-- decisions entry has licensed an exception to for this table. What that
-- means in trade: this table cannot be queried across people for
-- candidates while ciphertext is per-person-keyed. Building the
-- queryable structure that makes cross-person fuzzy matching possible
-- against encrypted content (a keyed blind index, the same shape decision
-- 020 already required for the safety-marker match key) is
-- person-identity/05's problem to solve, not this task's; the row shape
-- here only proves the derivation is deterministic and regenerable.
--
-- token_kind is the closed, honest set this task actually implements:
-- 'original' (the name as asserted, NFC-normalized) and
-- 'diacritic_folded' (the same token with combining marks stripped,
-- kept ALONGSIDE the original, never replacing it, per the task's own
-- rule). No phonetic hashing of non-Latin input, per the same rule.
CREATE TABLE name_index_entry (
    outbox_entry_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    source_table text NOT NULL CHECK (source_table IN ('person_name', 'document_name')),
    source_outbox_entry_id spine_object_id NOT NULL,
    token_kind text NOT NULL CHECK (token_kind IN ('original', 'diacritic_folded')),
    generator_version integer NOT NULL CHECK (generator_version >= 1),
    token_ciphertext bytea NOT NULL,
    residency_region residency_region NOT NULL
        DEFAULT own_declared_residency_region()
);

CREATE INDEX name_index_entry_by_person ON name_index_entry (person_id);
CREATE INDEX name_index_entry_by_source
    ON name_index_entry (source_table, source_outbox_entry_id);
