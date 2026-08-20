# Education and credential record shapes: prior-art survey

**Evidence tier: binds nothing.** Research informs decisions and constrains
no implementation. What a standard does is not what this schema must do.

**Status:** Research memo, prepared 2026-08-20 for the schema 0.2 education
and credential objects (decision 062). Sources are linked per section;
claims about maintenance status are as of this date.

---

## TLDR (conclusions first)

1. Every serious standard separates education (degree-granting, time-bound
   enrollment) from certification/license (issuer-granted, renewable,
   expiring) as distinct record types, even when both share an issuer
   concept.
2. The largest fork across standards is issuer-as-string versus
   issuer-as-typed-entity, and it tracks verifiability exactly.
   Self-asserted formats (JSON Resume, LinkedIn base fields) use free
   text; verifiable or institutionally governed formats (VC 2.0, Open
   Badges 3.0, CTDL, Europass/ELM, IPEDS/DAPIP) use a registry-resolvable
   organization entity.
3. No surveyed standard marks self-asserted versus issuer-verified inside
   one record. They switch schemas entirely (plain JSON versus signed VC)
   or bolt on a separate product (LinkedIn Verifications). Per-claim
   provenance grading inside one record shape has no prior art here.
4. Field-of-study taxonomies are never invented in-house by the
   institutional standards. CTDL defers to CIP; ELM defers to ISCED-F and
   EQF; ESCO is the taxonomy others reference. Only the self-asserted
   formats use free text.
5. Date precision converges on month or day where structured (LinkedIn:
   month+year). No standard has a fuzzy-precision date type.
6. Evidence attachment ranges from embedded (Open Badges bakes assertion
   JSON into the badge image) to URL-only (JSON Resume, LinkedIn) to
   out-of-band contractual (HR Open screening) to absent (CTDL, ESCO,
   registries).
7. Registry accessibility inverts by geography. US DAPIP and UK UKRLP are
   queryable registries. India's UGC/AICTE and the Philippine CHED publish
   recognition data as PDFs and static lists; only TESDA runs a real
   registration system with lifecycle state. Institution resolution in the
   target population leans on the fallback path, not the registry.

## 1. W3C Verifiable Credentials 2.0 + Open Badges 3.0

Actively maintained. VC 2.0 became a W3C Recommendation in May 2025; Open
Badges 3.0 went final at 1EdTech in June 2024 as a profile of VC 2.0.

VC defines the envelope: issuer, credentialSubject, issuance and optional
expiration dates, cryptographic proof, optional credentialStatus. OB 3.0
adds `AchievementCredential`: a subject achieved the criteria of an
`Achievement`, with `Alignment` links to external competency frameworks
and an `Evidence` field. There is no dedicated institution object; the
issuer is whoever signs, identified by DID or URL. No built-in degree or
field-of-study taxonomy. Dates are ISO 8601, typically day precision.
Renewal is not modeled; a renewal is a new credential. Revocation runs
through `credentialStatus` bitstring status lists published by the
issuer. The model assumes issuer-signed throughout; a self-asserted claim
would be a self-signed credential, indistinguishable in the spec from any
other issuer. Evidence can be linked URLs or embedded markdown, and the
badge image can carry the assertion JSON in its metadata.

Note: this repo's schema already adopts VC 2.0 as the envelope and
rejects OB 3.0 as the payload shape (record-schema §7, decision 028).
Nothing found here disturbs that split.

Sources: https://www.imsglobal.org/spec/ob/v3p0,
https://www.w3.org/TR/vc-overview/,
https://www.1edtech.org/standards/open-badges

## 2. CTDL (Credential Engine)

Actively maintained, US-focused, nonprofit-operated. An RDF/SKOS
description vocabulary for the credential landscape, not a signed
personal-credential format. `ceterms:CredentialOrganization` is a typed
entity with a registry id and external identifiers (IPEDS/OPEID). Field
of study uses CIP codes. Degree level is modeled as subclasses (Degree,
Certificate, Certification, Badge, MicroCredential) plus a controlled
CredentialStatus lifecycle vocabulary carrying renewal and revocation
semantics at the credential-type level. CTDL describes what a CPA is and
how it renews; whether a person holds one is out of scope, so there is no
self-asserted concept and no personal evidence handling.

Sources: https://credentialengine.org/credential-transparency/ctdl/,
https://credreg.net/page/typeslist

## 3. Europass / EDCI (European Learning Model)

Actively maintained, EU Commission-backed, built as an extension of the
VC data model. Institutions are typed Organisation/Awarding Body
entities cross-referenced against national registries, increasingly
resolved through EBSI's trusted-issuer registry, which gives a
governmental chain of trust plain VC lacks. Degree level maps to the
EQF's eight levels; field of study references ISCED-F via linked
concepts. `LearningAchievement`, `Qualification` and `Accreditation` are
distinct concepts, separating whether the credential is real from
whether the issuer is recognized. Supports linked and embedded evidence
documents in the signed payload.

Sources:
https://europa.eu/europass/en/european-digital-credentials-learning-interoperability,
https://github.com/european-commission-empl/European-Learning-Model

## 4. ESCO

Actively maintained by the Commission and Cedefop. A SKOS classification,
not a record schema: roughly 3,039 occupations mapped to ISCO-08, about
13,890 skill concepts, and a qualifications pillar connecting national
qualification databases. Its relevance is as a taxonomy other schemas
reference by concept URI. No issuer, attestation, or evidence concepts.

Source: https://esco.ec.europa.eu/en/about-esco/what-esco

## 5. HR Open Standards (formerly HR-XML)

Actively maintained (4.4 released February 2024). Interchange schemas for
recruiting and HRIS systems, not verifiable credentials. Education
institution is a structured name/address block, not a resolvable
external id; degree and field of study are free text or HR Open's own
code lists. Certifications are a distinct entity with issuer name, dates
and status. No signing; verification happens out of band through the
consortium's separate screening schema between contracted systems.
Self-asserted versus verified is not a schema distinction.

Source: https://www.hropenstandards.org/products/

## 6. JSON Resume

Community-maintained, widely used by resume tooling, no institutional
backing. Flat sections: `education` has `institution` (plain string),
`area` and `studyType` (free text), start and end date strings with
precision left to the value. `certificates` has name, date, issuer (free
text) and a bare `url`; no expiry, renewal or evidence fields in the base
schema. Entirely self-asserted, no verification concept, arbitrary
extension properties allowed.

Sources: https://docs.jsonresume.org/schema,
https://github.com/jsonresume/resume-schema

## 7. LinkedIn profile shape

Proprietary, partially documented through the Microsoft Learn partner
APIs. Education: `schoolName`, `degreeName`, `fieldOfStudy`, all
user-entered free text with autocomplete against LinkedIn's internal
entities, never a hard foreign key; dates are month+year, no day.
Certifications: name, `authority` (free text with autocomplete against
company pages), `licenseNumber`, month+year issue and expiry, `url`
typically pointing at an issuer verification page or a badge platform.
The base fields are entirely self-asserted; the Verifications feature is
a separate overlay product, not part of the profile schema.

Sources:
https://learn.microsoft.com/en-us/linkedin/shared/references/v2/profile/education,
https://learn.microsoft.com/en-us/linkedin/shared/integrations/people/profile-edit-api/certifications

## 8. National accreditation registries

These are the institution-identity layer an education claim would resolve
against, not personal-record schemas.

- **US, IPEDS/DAPIP.** Actively maintained, mandatory reporting for
  federally participating institutions. Parallel identifiers (OPE ID,
  IPEDS UnitID, DAPIP internal id) do not always match cleanly. DAPIP
  tracks accreditor-to-institution-to-program relationships over date
  ranges, the closest thing surveyed to a relational accreditation model.
- **UK, OfS register / UKRLP.** Actively maintained. UKPRN is the
  canonical provider identifier, UK-wide and broader than the OfS
  register itself, which covers English providers.
- **India, UGC/AICTE.** Maintained but fragmented. No canonical
  machine-readable registry API from the regulators; AICTE assigns its
  own institute ids, UGC publishes recognition lists largely as
  documents. Third-party scraped datasets fill the gap. The least
  programmatically accessible of the four.
- **Philippines, CHED/TESDA.** Mixed. TESDA's UTPRAS registration system
  issues a certificate per program and publishes a compendium with
  lifecycle state, a real registry. CHED publishes recognized-institution
  data as periodic lists and memoranda, the same gap as India.

Sources: https://nces.ed.gov/statprog/handbook/pdf/ipeds.pdf,
https://learning-provider.data.ac.uk/,
https://www.aicte-india.org/education/institutions/Universities,
https://www.tesda.gov.ph/AboutL/TESDA/26
