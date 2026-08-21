-- 0037-authentication-and-sessions (person-identity/02; decisions 013,
-- 086, 089): everything authentication holds about a person. Number 0037
-- under the one shared numbering sequence, the next number no landed
-- file and no task claim holds. The task frontmatter carried no
-- migrations claim when it was authored; decision 086 rules that the
-- claim is amended on main after the file lands, the foundation/08
-- precedent.
--
-- One chain, one number. Nothing here touches the spine, and that is the
-- design rather than an omission: 0010-person-core states what the spine
-- holds for a person, the id, when it was issued, and the lifecycle
-- transitions that id has passed through, and nothing else. Sessions,
-- credentials, codes and the authentication trail are all facts about a
-- person's activity, so they are payload content, they are regional, and
-- they die with the person under the purge role (foundation/08) instead
-- of outliving them in an append-only ledger.
--
-- Nothing here is ever updated. identity_app holds SELECT and INSERT
-- (0002); this migration grants nothing further and exempts nothing. A
-- revoked session is a following row, not an edited column, and a code
-- attempt is a row rather than a counter, which is what lets the rate
-- limit be read from the record rather than trusted from a field.
--
-- These rows are written directly by the serving path, not through the
-- cross-plane outbox (0020). The outbox exists so a spine commit can
-- carry a payload half forward asynchronously; authentication has no
-- spine half to commit, and a session that arrives a moment after the
-- worker's next request is a session that does not work.

-- The keyed lookup index over contact channels (decision 089).
--
-- Signup sealed every address under the person's own DEK with no lookup
-- column, which made finding a person from a typed address impossible
-- and one-time-code login unbuildable. Refusing the index would have
-- demoted the code path, which decision 013 forbids.
--
-- The form is the one decision 020 ruled for safety markers: an HMAC of
-- the canonicalized address under a key held in the key management
-- service and never in this database (core/keys ScopeChannelLookup). A
-- plain hash would be enumerable, since the address space people
-- actually use is small and guessable, and a stored salt beside the
-- data does nothing against an attacker holding the table.
--
-- The cost is recorded with the ruling and is not softened here: this
-- column links every account that ever held one address, across the
-- whole population. Decision 089 bounds its use to login
-- (person-identity/02) and duplicate detection (person-identity/05); a
-- third use is a new decision.
--
-- NOT NULL with no default and no backfill. The column is derived from
-- the address, which is sealed, so no migration could compute it: a
-- default would be a lie and a nullable column would let a channel land
-- unfindable, which is the state that made login impossible in the first
-- place. This ALTER therefore requires an empty table, which is the
-- state of every database this repo has, development included, since the
-- compose pair declares no volumes.
ALTER TABLE person_contact_channel
    ADD COLUMN address_lookup bytea NOT NULL;

CREATE INDEX person_contact_channel_by_lookup
    ON person_contact_channel (address_lookup);

-- The person's passkey credentials. Multiple per person by design: a
-- worker with a phone and a laptop enrolls both, and losing one must not
-- lose the account.
--
-- credential_id is this ledger's own random id, not the authenticator's
-- credential id. The authenticator's id, its public key, its transports
-- and its AAGUID all travel inside credential_ciphertext, sealed under
-- the person's own DEK (foundation/05), because an AAGUID names a device
-- model and a raw credential id is a stable per-site identifier: both
-- are facts about the person's hardware and neither belongs in the clear
-- beside a person id.
--
-- Lookup is therefore always by person first, then by unsealing that
-- person's few credential rows. A discoverable passkey returns the
-- person id in its user handle and a typed address resolves to one
-- through address_lookup above, so both login shapes reach the person
-- before they need a credential.
--
-- label_ciphertext is what the worker calls the device in their own
-- credential inventory, free text they typed, so it is sealed like every
-- other thing they typed. NULL means they named nothing.
CREATE TABLE auth_credential (
    credential_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    credential_ciphertext bytea NOT NULL,
    label_ciphertext bytea,
    enrolled_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

CREATE INDEX auth_credential_by_person ON auth_credential (person_id);

-- A live session, issued by either authentication path.
--
-- token_commitment is a plain SHA-256 of the bearer token, and the
-- difference from address_lookup above is the reason: a session token is
-- 256 bits from the system CSPRNG, so there is no guessable space to
-- enumerate and a keyed hash would buy nothing. address_lookup covers a
-- value a person chose and an attacker can guess, which is what makes
-- the key load-bearing there and not here.
--
-- method records which path issued the session and is carried for the
-- worker's own session list, never as an authorization input. Decision
-- 086 defers session assurance to the verification layer and decision
-- 013 forbids the code path being demoted, so nothing in this repo may
-- read this column to decide what a session may do.
CREATE TABLE auth_session (
    session_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    token_commitment bytea NOT NULL UNIQUE,
    method text NOT NULL CHECK (method IN ('passkey', 'code')),
    issued_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

CREATE INDEX auth_session_by_person ON auth_session (person_id);

-- Revocation as a following row. The primary key is what makes it
-- write-once: revoking twice conflicts rather than overwriting, and no
-- path can un-revoke, because there is no DELETE and no UPDATE to reach
-- for.
CREATE TABLE auth_session_revocation (
    session_id spine_object_id PRIMARY KEY
        REFERENCES auth_session (session_id),
    recorded_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

-- The queryable form of "this session still authenticates". Both ways a
-- session dies, revoked and expired, are resolved here, so the serving
-- path has one place to ask and cannot check one and forget the other.
CREATE VIEW auth_session_live AS
SELECT s.session_id,
       s.person_id,
       s.token_commitment,
       s.method,
       s.issued_at,
       s.expires_at
  FROM auth_session s
 WHERE s.expires_at > now()
   AND NOT EXISTS (
     SELECT 1 FROM auth_session_revocation r
      WHERE r.session_id = s.session_id);

-- An outstanding one-time code.
--
-- code_commitment is a keyed code under the population scope, not a
-- plain hash: a six-digit code has a million-value space, so a plain
-- hash of every possible code is a table an attacker holding this one
-- could precompute in seconds. Same reasoning as address_lookup, same
-- key management, and the key is the reason neither column is worth
-- stealing on its own.
--
-- No column records which channel the code went to. The address is
-- resolved at request time and the code is delivered there; recording
-- the resolved channel would put a second copy of the lookup value in a
-- table that also carries timing, and the challenge belongs to the
-- person either way.
CREATE TABLE auth_code_challenge (
    challenge_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    code_commitment bytea NOT NULL,
    issued_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

CREATE INDEX auth_code_challenge_by_person
    ON auth_code_challenge (person_id, issued_at);

-- One row per code submitted against a challenge. This is the lockout
-- mechanism: the attempt count is read from these rows, so a lockout
-- cannot be cleared by writing to a counter, and the attempt history
-- survives for the abuse signals the same way signup's do.
CREATE TABLE auth_code_attempt (
    attempt_id spine_object_id PRIMARY KEY,
    challenge_id spine_object_id NOT NULL
        REFERENCES auth_code_challenge (challenge_id),
    outcome text NOT NULL CHECK (outcome IN ('accepted', 'rejected')),
    recorded_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region()
);

CREATE INDEX auth_code_attempt_by_challenge
    ON auth_code_attempt (challenge_id);

-- Every authentication event, append-only, one row per thing that
-- happened to the account's access.
--
-- The vocabularies are closed and impersonal. Nothing here records an
-- address, a device string, a network address or a code: those are
-- either sealed elsewhere or deliberately not kept, and an event log
-- that quietly accumulates them becomes the tracking surface the rest of
-- this schema is arranged to avoid.
CREATE TABLE auth_event (
    event_id spine_object_id PRIMARY KEY,
    person_id spine_object_id NOT NULL,
    method text NOT NULL
        CHECK (method IN ('passkey', 'code', 'session')),
    kind text NOT NULL
        CHECK (kind IN (
            'credential-enrolled',
            'code-requested',
            'code-rate-limited',
            'code-rejected',
            'authenticated',
            'session-revoked')),
    recorded_at timestamptz NOT NULL DEFAULT now(),
    residency_region residency_region NOT NULL
        DEFAULT declared_residency_region(),
    -- A session event is neither a passkey nor a code ceremony, and a
    -- ceremony event is never a session one. Without this the method
    -- column would be free to say 'passkey' about a revocation, and the
    -- trail would read two ways.
    CHECK (
        (method = 'session' AND kind = 'session-revoked')
        OR (method <> 'session' AND kind <> 'session-revoked'))
);

CREATE INDEX auth_event_by_person ON auth_event (person_id, recorded_at);
