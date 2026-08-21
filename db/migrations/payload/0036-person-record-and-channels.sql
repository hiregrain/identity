-- 0036-person-record-and-channels (person-identity/01; decisions 013,
-- 017, 075): the person's payload half, the partner of the spine's
-- 0010-person-core. Number 0036 under the one shared numbering
-- sequence, the next number no landed file and no task claim holds.
--
-- A number belongs to one chain and one file (decision 017: each chain
-- has gaps where the other's numbers fall), so the two halves of one
-- task's schema carry two numbers. Founder ruling on the raise this
-- task made when it first landed both halves under 0010. The task
-- frontmatter's claim is amended separately, on main.
--
-- Everything a person told us is here, and nothing here is readable
-- without the person's DEK. Content columns hold ciphertext core/envelope
-- produced under the person's key alone (foundation/05, decision 017's
-- single-owner rule), so destroying that key destroys the content for
-- everyone, this ledger included.
--
-- These rows arrive through the spine-first outbox (0020), never by a
-- direct write: the spine commit issues the id, and the worker applies
-- the payload row idempotently afterwards. `outbox_entry_id` with its
-- UNIQUE constraint is that idempotency, held by the database rather
-- than by worker memory, and it is why an apply may run any number of
-- times and leave one row.
--
-- Nothing here is ever updated. A changed channel is a new row, and the
-- surfaces that read a person read the current one. identity_app holds
-- SELECT and INSERT (0002); this migration grants nothing further and
-- exempts nothing.

-- The database's own residency declaration, as a value an INSERT can
-- take from a column default. 0004 makes the DATABASE authoritative for
-- residency and 0005's registry stamps the value with a subquery at
-- every insert. An outbox apply cannot: it renders one flat INSERT from
-- an instruction (core/outbox), and a subquery there would mean an
-- instruction could choose its own region.
--
-- A default alone is only a default: an INSERT naming the column still
-- overrides it. What makes the stamp binding on this path is that no
-- instruction may name the column at all, refused by the denylist in
-- core/outbox's Instruction.validate alongside outbox_entry_id, plus
-- checks/payload-residency.mjs, which fails any row whose region
-- disagrees with the database it sits in.
CREATE FUNCTION declared_residency_region() RETURNS residency_region
LANGUAGE sql STABLE AS $$
  SELECT residency_region FROM database_residency
$$;

-- One row per person: the optional worker-owned parts of an account.
-- display_name is free-text Unicode and optional, so NULL here means the
-- worker gave no name, which is the ordinary state of an account created
-- with one verified email and nothing else. The full name model, with
-- its uses, validity periods and matching index, is person-identity/04's
-- (0011-names); this column is the display string a worker types into
-- their own account and nothing more.
--
-- Bounds on the plaintext are enforced at the write site (core/person),
-- not by a column width, and over-length input is rejected loudly rather
-- than truncated (decision 020). A ciphertext column cannot express the
-- bound: sealing changes the length.
CREATE TABLE person_record (
    outbox_entry_id spine_object_id NOT NULL UNIQUE,
    person_id spine_object_id NOT NULL UNIQUE,
    display_name_ciphertext bytea,
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

-- The person's contact channels. Email-primary signup with verified
-- control of one channel (decision 013); phone is optional and never an
-- anchor.
--
-- verified_at is NOT NULL by construction, which is where "verified
-- control" is enforced rather than promised: an unverified channel has
-- no row to sit in. What produces the proof of control, one-time codes
-- and their rate limits, is person-identity/02's; that this ledger
-- records no channel without one is settled here.
--
-- The risk signals are the real anti-Sybil control (decision 013:
-- possession of a channel buys almost no uniqueness, since SMS-PVA
-- services run on infected handsets and multi-SIM is ordinary in the
-- target markets). v1 records the signals and the threshold that was in
-- force when the channel was taken; what to DO at the threshold is the
-- anti-fraud work, not this task. Recording the threshold alongside the
-- observation is what makes a later escalation policy reconstructable
-- against accounts that predate it.
--
-- carrier_reputation is a fact about a telephone carrier, not a judgment
-- about a person, which is the line checks/scored-columns.mjs draws and
-- the reason no column here scores anybody.
--
-- assurance carries the RA 11934 exception (decision 013): a Philippine
-- SIM is bound to a government ID by statute, so a verified PH mobile is
-- a higher-assurance signal and is recorded as one instead of being
-- flattened into "a phone was verified". The derivation is deterministic
-- and lives in one function (core/person); the column stores its result
-- so a later reader does not re-derive it from rules that have since
-- moved.
CREATE TABLE person_contact_channel (
    outbox_entry_id spine_object_id NOT NULL UNIQUE,
    person_id spine_object_id NOT NULL,
    channel_kind text NOT NULL
        CHECK (channel_kind IN ('email', 'phone')),
    address_ciphertext bytea NOT NULL,
    verified_at timestamptz NOT NULL,
    line_type text NOT NULL
        CHECK (line_type IN ('email', 'mobile', 'landline', 'voip', 'unknown')),
    line_country text
        CHECK (line_country ~ '^[a-z]{2}$'),
    carrier_reputation text NOT NULL
        CHECK (carrier_reputation IN ('unknown', 'clear', 'flagged')),
    velocity_observed integer NOT NULL CHECK (velocity_observed >= 0),
    velocity_threshold integer NOT NULL CHECK (velocity_threshold >= 1),
    assurance text NOT NULL
        CHECK (assurance IN ('channel-control', 'ph-sim-registered')),
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region(),
    -- Line metadata belongs to a telephone line. An email channel has no
    -- carrier and no country, and letting one carry them would make the
    -- assurance rule readable two ways.
    CHECK (
        (channel_kind = 'phone' AND line_type <> 'email')
        OR (channel_kind = 'email' AND line_type = 'email'
            AND line_country IS NULL)
    ),
    -- The elevated marker is reachable only the way decision 013
    -- describes it: a Philippine mobile line. The database refuses the
    -- marker on anything else, so a write-site bug cannot quietly
    -- promote an account.
    CHECK (
        assurance = 'channel-control'
        OR (line_type = 'mobile' AND line_country = 'ph')
    )
);

CREATE INDEX person_contact_channel_by_person
    ON person_contact_channel (person_id);
