---
id: person-identity/04
type: task
status: ready
depends_on: [person-identity/01]
migrations: [0011-names]
binds: [decisions/LOG.md#013, research/13-name-standards.md]
evidence: []
verified_by: null
---

# The name model

## Objective

A name model that works for a mononymic Indonesian worker, a Filipino
with a maternal middle name, a Tamil patronymic, a CJK name with several
valid romanizations, and a US electrician — without imposing Western
structure or losing matching power.

## The reference model: FHIR HumanName

Adopted as the shape (`research/13`), because it is the only surveyed
model that treats a name as **temporal, multi-valued, and
purpose-tagged**, which is exactly what an append-only ledger needs: a
name change is a new entry plus an end-date on the prior, never a
mutation. Aadhaar (one opaque string) and PhilSys (four fixed fields
including a derived, mutable-semantics middle name) both fail at
opposite ends, and share one flaw this design must not repeat: **neither
gives the name its own identifier — the display string doubles as the
matching key.**

Corollary to enforce everywhere: **"the person's name" is not a scalar.**
Every read specifies a purpose and a point in time.

## Scope

- `person_name` rows, append-only, each with: its own id; `text` (the
  authoritative rendering, single free-text Unicode, no length cap, no
  case normalization, no required family part); optional decomposed parts
  (`family` 0..1, `given` 0..*, `prefix`/`suffix` 0..*); `use`
  (`usual | official | old | maiden | nickname | anonymous | temp`);
  `period` (validity bounds; absent = current); `representation`
  (`IDE | ABC | SYL` — the CJK ideographic/romanized/phonetic mechanism).
  Invariant: when both `text` and parts are present, `text` contains
  nothing absent from a part.
- Cultural structure as extensions, never core columns:
  `fathers_family` / `mothers_family` (the Spanish/Portuguese two-surname
  case AND the PhilSys maternal middle name — same mechanism, no
  bespoke field), own-name vs partner-name for marriage-derived surnames.
- `document_name`, immutable per verification, in ICAO 9303 vocabulary:
  `primary_identifier` / `secondary_identifier` (ICAO deliberately does
  not define what a surname is — it is a per-issuer partition),
  `is_mononym`, raw MRZ lines, raw visual-zone string, script + ISO 15924
  code, source. Both MRZ and VIZ retained: they routinely disagree
  (MRZ is upper-case, diacritic-stripped, 39 chars at line-1 positions
  6–44), and no vendor documents a precedence rule.
- Truncation handling: the ICAO truncation signal is **ambiguous by
  design** — an alphabetic character at position 44 means "may have been
  truncated" and cannot be distinguished from an exactly-fitting name.
  Store the raw MRZ and a `possibly_truncated` flag; never treat MRZ as
  authoritative over VIZ or DG11.
- **Mononym parsing trap (must be tested):** a mononym MRZ contains no
  `<<` at all (`SATRIYA<SUDARPA`), so a parser that splits on `<<`
  assigns the entire name to surname with an empty given name. This is
  precisely how three of six major IDV vendors corrupt mononyms; our
  parser must not.
- Transliteration is non-deterministic and non-invertible (Ä → "AE" *or*
  "A"; `OE` may be Ö, Ø, Œ, or literal O+E). Store originals; generate
  transliterations as *additional* index entries, never replacements.
- `name_index` (derived, regenerable, never source of truth):
  normalized forms plus multiple transliterations alongside originals; no
  phonetic hashing of non-Latin input; produces candidates only.
- Query-layer rule: prior names remain queryable for matching but are
  withheld from employer-visible views (gender transition, marriage).

## Acceptance

- AC (mechanical): a mononym round-trips storage → matching → packet
  render without acquiring an empty surname or being split; the MRZ
  no-`<<` case is a named test.
- AC (mechanical): dropping and regenerating `name_index` reproduces it
  exactly.
- AC (mechanical): a name change appends and end-dates; no row is
  mutated; the prior name matches but is absent from an employer render.
- AC: a CJK name with ideographic + romanized + phonetic entries renders
  correctly per purpose.

## Outside check

Verifier runs a fixture set: Indonesian mononym (incl. two-word), CJK
with three representations, Spanish paternal+maternal, Filipino with
maternal middle name, Tamil patronymic, post-transition change,
MRZ-vs-VIZ disagreement, and a 39-char boundary name. All eight behave
per criteria.
