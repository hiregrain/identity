# Regulatory Trigger Map: KYC/AML, Right-to-Work, Sanctions Screening

**Status:** Research memo, not legal advice. Not counsel-reviewed. Written
2026-08-17. Companion to `01-regulatory-perimeter.md` (FCRA/GDPR/DPA perimeter)
and `07-synthesis.md`. Confidence is marked inline; settled statute, agency
guidance, industry practice, and my own inference are labeled separately
throughout.

**Scope:** US (BSA/FinCEN, IRCA/I-9/E-Verify, 8 U.S.C. §1324b, OFAC), EU
(AMLR, Employer Sanctions Directive, Reg. 269/2014, eIDAS 2), Philippines
(AMLA, DOLE, RA 10168/11479, PhilSys), India (PMLA, UAPA §51A, Aadhaar, DPDP).
Facts assumed: the ledger holds no funds, moves no money, runs no payroll, and
is not the employer of record; verticals and partners are.

---

## TLDR — all conclusions

**1. On today's facts the ledger is outside every KYC/AML regime in all four
jurisdictions, and this is the cleanest perimeter it has.** US money-transmitter
status under 31 CFR §1010.100(ff)(5)(i) requires *acceptance and transmission*
of funds — never satisfied, so the (ff)(5)(ii) exemptions never have to be
argued. The EU AMLR (Reg. (EU) 2024/1624) Art. 3 obliged-entity list is a closed
positive list that does not include identity, verification, recruitment, or
staffing services. PH AMLA §3(a) as amended through RA 11521 lists ten covered-
person categories, none of them employment or identity. India's PMLA reporting-
entity notifications reach company-formation and corporate-secretarial activity
by CA/CS/CMA professionals, not workforce platforms. Confidence: high on the
statutory reading; note that no regulator has adjudicated this exact fact
pattern anywhere, so this is a well-supported negative, not a ruling.

**2. The AML perimeter is protected by one architectural commitment, not by
positioning: never accept, hold, aggregate, or disburse funds.** Every plausible
crossing is a money-movement crossing — paying workers directly, escrow, agent-
of-EOR wage disbursement, earned-wage-access. Founder decision 9 ("no economics
embedded") already forbids this in the schema; the finding here is that it must
also be a *corporate* commitment, because AML status attaches to conduct at
entity level, not to what the ledger schema encodes. Selling verification into
financial-institution onboarding is the one adjacent-looking move that does
*not* cross: 31 CFR §1020.220(a)(6)'s reliance provision runs to the bank, not
the vendor, and IDV vendors serving banks are not registered MSBs. The exposure
there is contractual diligence flowing back, not BSA registration.

**3. Right-to-work is not the ledger's obligation and cannot be made so, but
the ledger can carry the evidence.** The I-9 duty attaches to the "employer"
under 8 CFR §274a.1(g) — whoever engages the labor for wages. The recruiter/
referrer-for-a-fee duty, which is what people assume catches platforms, is
limited by 8 CFR §274a.2(a)(1) to agricultural associations, agricultural
employers, and farm labor contractors. A non-agricultural routing platform has
no independent I-9 duty. Third-party carriage of the evidence is lawful and
routine: 8 CFR §274a.2(e)–(i) sets electronic I-9 standards (integrity controls,
indexed retrieval, permanent audit trail of every access and modification), and
the E-Verify Employer Agent MOU track exists for exactly this. But delegation of
the *act* never delegates the *liability* — the Form I-9 instructions state the
employer "is liable for any violations in connection with the form or the
verification process, including any violations committed by the authorized
representative acting on your behalf." Confidence: high, settled regulation.

**4. The real US right-to-work risk is not I-9 — it is 8 U.S.C. §1324b, and it
lands on the ledger's routing behavior, not on its storage.** DOJ/IER's June 20,
2024 settlement with **eTeam Inc.**, an online staffing agency, is the closest
precedent to this product: eTeam was penalized $232,500 plus $325,000 in worker
compensation for distributing job ads with citizenship-status restrictions and
screening out candidates by citizenship status — as an intermediary, not as the
employer of record. Extending this to an attestation-consuming routing algorithm
is my inference, not a decided case (no published IER action addresses an
automated attestation filter), but the structural match is close and it is the
platform's largest single US legal uncertainty in this memo.

**5. Answering the design question: work-authorization belongs in the ledger,
but only as a jurisdiction-scoped, coarse, expiring, party-attested
confirmation — and it must be read *after* selection, never used as a routing
filter.** The sensitive-data payload ban (`07` constraint 12, design §2.2) and
§1324b point the same direction: what may live in the payload is
`{jurisdiction, authorized_to_work: bool, basis_class, verified_at, expires_at,
issuer}` — no document numbers, no images, no visa category detail, no
immigration narrative. Oregon (SB 619) and Delaware enumerate citizenship or
immigration status as *sensitive data* requiring opt-in consent, which is the
US-side reason the coarse shape is not merely prudent. GDPR Art. 9 does *not*
list immigration status (closed list — settled textual reading), so the EU
constraint is minimization under Art. 5(1)(c) rather than special-category
prohibition. Expiry must be bound to the underlying permit's own end date, not
a platform TTL, and re-attestation must re-trigger examination rather than
silently renewing.

**6. Sanctions exposure does not sit on the ledger by default, and reliance
transfers nothing.** OFAC liability is strict (intent appears in Appendix A to
31 CFR Part 501 as a *penalty* factor, never as an element) and attaches to the
US person who deals with, employs, pays, or benefits from a blocked person —
i.e., the vertical or partner. There is no general codified screening mandate
for non-financial companies; screening is the practice that avoids strict
liability, and OFAC's May 2019 "Framework for OFAC Compliance Commitments" (five
components: management commitment, risk assessment, internal controls, testing
and audit, training) is expectation, not rule. Critically, **no safe harbor
exists for a downstream party relying on a third party's pass/fail** — a
negative finding worth stating plainly, because it is the crux of whether a
pass/fail attestation is a product at all.

**7. But whoever runs the screen inherits non-delegable recordkeeping, and that
is a reason for the ledger not to run screens itself.** 31 CFR §501.601 requires
a full and accurate record of each transaction retained **at least 10 years**
(not five); §501.603 requires blocking reports within 10 business days; §501.604
requires rejected-transaction reports within 10 business days. A ledger that
performs the SDN comparison acquires these duties directly and cannot discharge
them from a pass/fail token. The clean shape is therefore: **screening is bought
from a registered screening provider (as verification already is), the provider
holds the underlying match data and its own retention obligation, and the ledger
stores only a signed pass/fail-with-scope attestation.** This keeps hit data —
which is adverse, error-prone, and unrebuttable at the ledger layer — out of the
payload plane entirely.

**8. Partners in regulated industries will demand more than sanctions
screening, and the demand arrives contractually through audit frameworks, not
statute.** ISO/IEC 27001:2022 Annex A 6.1 (personnel screening proportionate to
risk and access) and SOC 2 CC1.4 are the actual vector by which a datacenter
operator pushes screening obligations onto a workforce supplier. Defense-
adjacent work adds a genuinely hard conflict: ITAR/EAR deemed-export rules (22
CFR §120.50/§120.62; 15 CFR §734.13(a)(2)) make nationality a lawful access-
control input for controlled technical data, while §1324b makes nationality an
unlawful hiring filter. DOJ's 2016 IER technical assistance letter and the
*DOJ v. SpaceX* complaint (filed Aug. 24, 2023) mark the boundary: export
control justifies per-person licensing for a specific controlled-data access
decision, never a blanket citizen-only eligibility gate.

**9. Re-screening: onboarding plus re-screen on every list update is the
defensible cadence; periodic quarterly/annual is materially weaker.** The SDN
list updates irregularly and sometimes multiple times a week. This is industry
and examiner practice, not a codified frequency for non-financial firms.
Continuous *criminal* monitoring is a separate track that reopens the FCRA
questions in `01` and should not be conflated with sanctions rescreening.

**10. Pricing the identity-provider option: the EU and UK are the only regimes
that charge for it; India charges for a different thing; the US and Philippines
charge nothing at the issuer layer.** Becoming a *qualified* EAA issuer under
eIDAS 2 (Reg. (EU) 2024/1183, Arts. 45d–45f + Annex V) requires full QTSP
status: CAB conformity assessment at initiation and at least every 24 months
(Arts. 20–24), supervisory notification, Art. 13 reversed-burden liability.
Issuing *non-qualified* EAAs is essentially unregulated and is the correct
default — the ledger's attestations are already shaped like non-qualified EAAs.
UK is the cheapest real certification: Home Office IDSP certification for right
to work / right to rent, 4–8 weeks, fee negotiated with a UKAS-accredited body,
2-year validity with annual surveillance audits, free listing on the DVS
register created by the Data (Use and Access) Act 2025; note DBS-equivalent
checks make certification *mandatory* rather than optional. India's cost is not
the issuer regime but the **DPDP consent-manager** regime — India-incorporated
company, ₹2 crore net worth, registration with the Data Protection Board — which
is the closest Indian analogue to an attestation broker. The US has no issuer
license; its exposure is downstream (FCRA per CFPB Circular 2024-06, state
biometric law) and attaches whether the ledger buys or builds.

**11. One item is live today regardless of any product evolution: EU relying-
party registration.** Under eIDAS 2 Art. 5b, a relying party that wants to
accept EUDI Wallet attestations must register in its Member State of
establishment. Member States must offer wallets by 31 Dec 2026. If the ledger
intends to consume wallet-issued credentials — which is the obvious ingestion
path for EU verification — this attaches in the *buy* posture, not the build
posture. Cheap, but it is a calendar item, not an option.

**12. The Philippines carries a non-AML risk that is larger than its AML
risk: DOLE D.O. 174-17 labor-only contracting.** An entity that supplies workers
without substantial capital or investment, where the receiving principal
directs and controls the work, is a labor-only contractor — and the principal is
then **deemed the employer**. Failure to register with DOLE creates a
*presumption* of labor-only contracting. This does not touch the ledger if it is
purely an identity layer, but it directly threatens any PH routing vertical's
structure, and it is the kind of finding that belongs in front of counsel before
the PH vertical is stood up rather than after.

---

## 1. KYC/AML perimeter

### 1.1 US: the perimeter is the fund-movement predicate, and it is binary

31 CFR §1010.100(ff)(5)(i)(A) defines money transmission as "the acceptance of
currency, funds, or other value that substitutes for currency from one person
and the transmission of currency, funds, or other value that substitutes for
currency to another location or person by any means." A platform that never
accepts funds fails the predicate before any exemption is reached. This is the
strongest possible posture: it does not depend on the (ff)(5)(ii) exemptions
holding.
(https://www.law.cornell.edu/cfr/text/31/1010.100)

That matters because the exemptions are read narrowly. FinCEN's FIN-2019-G001
(May 9, 2019) applies the (ff)(5)(ii)(B) payment-processor exemption to CVC
business models and finds it generally *unavailable*, because the exemption
requires clearance and settlement through a system whose participants are
BSA-regulated institutions. Anyone planning to add worker payments and fall back
on the payment-processor exemption is planning on the weaker argument.
(https://www.fincen.gov/system/files/2019-05/FinCEN%20Guidance%20CVC%20FINAL%20508.pdf)

**Payroll is a genuine gap, not a settled exemption.** I found no FinCEN
administrative ruling addressing payroll processors or EOR wage disbursement.
FIN-2013-R002 (Nov. 13, 2013) is frequently mis-cited as payroll authority; it
is not — it holds that a company accepting, holding, and transmitting customer
funds through its own account *was* a money transmitter, which is useful by
analogy (holding funds pending disbursement is transmission) and cuts against,
not for, a payroll carve-out.
(https://www.fincen.gov/system/files/administrative_ruling/FIN-2013-R002.pdf)

State money transmitter licensing is a separate axis and a 50-state patchwork.
The CSBS Model Money Transmission Modernization Act's agent-of-payee exemption
requires a written payee-agent agreement, public holding-out of the agent's
authority, and extinguishment of the payor's obligation on payment to the agent.
It was drafted for merchant billing, not wage payment, and its fit to payroll is
contested among adopting states rather than harmonized.
(https://www.csbs.org/sites/default/files/2023-02/CSBS%20Money%20Transmission%20Modernization%20Act.pdf)

Earned wage access deserves a specific flag because it is the crossing that
looks most like a worker benefit rather than a financial product. CFPB's
December 23, 2025 advisory opinion holds that "Covered EWA" (employer-partnered,
capped at earned wages, repaid only via payroll deduction) is not credit under
TILA/Reg Z — but Nevada SB 290 (2023) and successor statutes in Missouri,
Kansas, South Carolina, Wisconsin, Arkansas, Utah, and Indiana are *licensing*
regimes: they say EWA is not a loan **and** require registration.
(https://www.federalregister.gov/documents/2025/12/23/2025-23735/truth-in-lending-regulation-z-non-application-to-earned-wage-access-products)

**Verification sold into financial-institution onboarding does not cross.**
31 CFR §1020.220 is the bank's CIP obligation, not the vendor's. The reliance
provision at §1020.220(a)(6) permits a bank to rely on *another financial
institution* — regulated by a federal functional regulator, subject to a
31 U.S.C. §5318(h) AML program rule, and contractually certifying annually — to
perform CIP. A non-FI IDV vendor is not brought inside BSA by this provision; it
is an ordinary third-party service provider governed by the bank's vendor-risk
management. That IDV vendors operate at scale without MSB registration is market
practice confirming the reading, not doctrine.
(https://www.law.cornell.edu/cfr/text/31/1020.220)

### 1.2 EU: a closed positive list that does not name us

AMLR (Reg. (EU) 2024/1624) Art. 3 enumerates obliged entities exhaustively:
credit and financial institutions, auditors/accountants/tax advisors, notaries
and independent legal professionals in specified transactions, trust or company
service providers, estate agents, high-value goods traders, gambling providers,
plus the newly added crypto-asset service providers, crowdfunding
intermediaries, investment-migration operators, and professional football clubs
and agents. Identity verification, attestation issuance, recruitment, and
staffing appear nowhere. Application from **10 July 2027** (football agents
later, commonly reported as 10 July 2029).
(https://eur-lex.europa.eu/eli/reg/2024/1624/oj/eng)

Two precision notes for the counsel packet. First, "AMLD6" is ambiguous: the
2024 package is AMLR 2024/1624 plus Directive (EU) 2024/1640; Directive (EU)
2018/1673 is the criminal-law money-laundering directive also called AMLD6.
Second, my confirmation of the Art. 3 list is via the regulation's recitals and
consolidated summaries rather than a clean pull of the numbered Art. 3
paragraphs — the negative finding is solid, the pinpoint paragraph numbering
should be verified before it is quoted in a filed document.

### 1.3 Philippines and India

**PH:** RA 9160 §3(a) as amended through RA 11521 (2021) lists covered persons;
RA 11521 added real estate developers/brokers and offshore gaming operators and
their service providers. Employment, manpower, recruitment, and identity
services do not appear. The one definition worth reading closely is "company
service provider" (added earlier by RA 10365/10927), which covers formation
agents, nominee directors/secretaries/partners, registered-address provision,
and nominee shareholders — broad within corporate services, with no reading that
reaches worker identity or job routing. It would only bite if the company
separately offered incorporation or registered-agent services to clients.
(https://www.lawphil.net/statutes/repacts/ra2021/ra_11521_2021.html)

**India:** PMLA §2(1)(sa) and §2(1)(wa) plus the 3 May 2023 notification
(reported as S.O. 2036(E)) extend reporting-entity status to practising CA/CS/
CMA professionals performing company formation, director/secretary/partner
provision, registered-office provision, and express-trust trusteeship on behalf
of clients. Neither the base categories nor the notification reach staffing or
identity platforms. **This is the least-well-sourced jurisdiction in this memo**
— the India findings rest on Indian law-firm commentary rather than a direct
pull from indiacode.nic.in or fiuindia.gov.in, and the notification number
should be confirmed against the gazette before citation.

### 1.4 Where the safe side of the line is

Safe, on present sourcing: issuing identities; storing verification attestations
bought from providers; routing workers; charging partners for identity/
attestation access; selling verification output to financial institutions as a
vendor.

Crossing: accepting or holding client funds for onward payment; escrow;
disbursing wages under any label; acting as agent of an EOR for wage payment;
issuing stored value or wage advances. All five are the same crossing —
touching money — which is why the perimeter is defensible as a single corporate
rule rather than a compliance program.

---

## 2. Right-to-work / employment eligibility

### 2.1 US: the duty is the employer's, and the platform is not one

8 CFR §274a.1(g) defines "employer" as a person or entity, including an agent or
anyone acting directly or indirectly in its interest, "who engages the services
or labor of an employee to be performed in the United States for wages or other
remuneration," and expressly assigns the duty to the contractor rather than the
entity using contract labor. Whichever vertical or partner pays the worker is
the I-9 obligor.
(https://www.law.cornell.edu/cfr/text/8/274a.1)

The recruiter/referrer trap is narrower than reputation suggests: 8 CFR
§274a.2(a)(1) states that "all references to recruiters and referrers for a fee
are limited to a person or entity who is either an agricultural association,
agricultural employer, or farm labor contractor." A general routing platform is
not a covered recruiter or referrer.
(https://www.law.cornell.edu/cfr/text/8/274a.2)

For temporary staffing, USCIS Handbook M-274 assigns the I-9 (and any E-Verify
case) to the agency where the agency is the paying employer. E-Verify guidance
separately warns staffing agencies against selectively verifying placed workers
— cherry-picking who gets verified is itself a violation.
(https://www.e-verify.gov/about-e-verify/whats-new/reminder-staffing-agencies-must-not-selectively-verify-employees)

**Third-party carriage is lawful; third-party liability is not transferable.**
The Form I-9 instructions permit designating "any person you designate, hire, or
contract with" as an authorized representative to complete Section 2, and state
that the employer "is liable for any violations in connection with the form or
the verification process, including any violations committed by the authorized
representative acting on your behalf." Electronic storage by a vendor is
governed by 8 CFR §274a.2(e)–(i): integrity and accuracy controls, protection
against unauthorized creation/alteration/deletion, an inspection and quality-
assurance program, indexed retrieval, legible reproduction, and a secure
permanent audit trail recording the date, identity, and action of every access
or modification. Retention: three years after hire or one year after
termination, whichever is later.
(https://www.uscis.gov/i-9-central/form-i-9-resources/handbook-for-employers-m-274/20-who-must-complete-form-i-9)

E-Verify has a formal third-party track — the E-Verify Employer Agent /
Designated Agent MOU — under which an agent creates cases for client employers,
with training obligations and misuse consequences including termination of
participation. State mandates layer on top: Florida SB 1718 (2023) for private
employers with 25+ employees, Arizona LAWA for all employers, Tennessee (35+),
Georgia (11+). The commonly cited nine-state list (AL, AZ, FL, GA, MS, NC, SC,
TN, UT) comes from compliance-vendor compilations, not primary statutes, and
should be re-verified state by state before it drives design.

### 2.2 US: §1324b is where a routing platform actually gets caught

8 U.S.C. §1324b prohibits citizenship-status discrimination and unfair
documentary practices (over-documenting, under-documenting, or discriminating in
which valid documents are accepted). The controlling precedent for this product
shape is DOJ/IER's settlement with **eTeam Inc.** (June 20, 2024): an online
staffing agency, not an employer of record, penalized $232,500 in civil
penalties with $325,000 set aside for affected workers, for distributing job
advertisements with citizenship-status restrictions and screening out candidates
by citizenship status — harming lawful permanent residents, asylees, and
refugees both by deterring applications and by failing to meaningfully consider
those who applied. Also relevant in the other direction: the TekisHub matter
(IER charge complete Dec. 20, 2024) concerned limiting recruitment to H-1B
holders, i.e. discrimination against US workers and other work-authorized
individuals.
(https://justice.gov/opa/pr/justice-department-secures-agreement-staffing-agency-resolve-immigration-related;
settlement text at https://www.justice.gov/d9/2024-06/eteam.pdf)

**Inference, flagged as such:** eTeam establishes that liability follows the
entity making the screening or routing decision using citizenship-status data,
independent of employer-of-record status. An attestation-consuming router that
uses work-authorization as a filter on what work a person is shown is that
conduct, automated and at scale — and centralizing it means one bad rule (an
over-inclusive expiry, an ambiguous status treated as disqualifying) creates
liability across every vertical and partner at once. No published IER action
addresses an automated attestation filter specifically. This is the largest
genuinely open legal question in this memo.

### 2.3 EU, Philippines, India — high level

**EU:** Directive 2009/52/EC Art. 4 puts the duty on the *employer*: require
production of a valid residence permit or authorization before employment,
retain a copy or record for the duration of employment, notify competent
authorities of the start of employment. Art. 8 extends financial liability up a
subcontracting chain where the contractor **knew** the subcontractor employed
illegally-staying third-country nationals, with a carve-out for contractors that
undertook statutory due-diligence obligations. Directive 2008/104/EC confirms
that in temporary agency work the *agency* is the employer — so the EU duty
lands on the vertical or partner holding the contract, not on the ledger.
(https://eur-lex.europa.eu/eli/dir/2009/52/oj/eng)

GDPR Art. 9's special categories are a closed list and do not include
immigration or residence status — settled textual reading. The EU constraint on
holding work-authorization data is therefore Art. 5(1)(c) minimization plus
national rules on copying identity documents (Germany's Personalausweisgesetz
restrictions are the most-cited example). I could not confirm a dedicated EDPB
or DPA pronouncement on immigration status as special-category data, and the
per-Member-State ID-copying rules were only partially verified; treat both as
open items rather than settled.

**Philippines:** no I-9 analogue for Filipino citizens (absence-of-evidence
inference, not a confirmed negative). For foreign nationals, Labor Code Art. 40
and DOLE D.O. 221-21 require an Alien Employment Permit before employment
commences or within 10 working days of contract signing, with a 5-year filing
bar and PHP 10,000 per year of unauthorized employment for violations. The
larger PH exposure is structural rather than status-based: **D.O. 174-17**
prohibits labor-only contracting — supplying workers without substantial capital
or investment where the principal directs and controls the work makes the
principal the deemed employer — and non-registration with DOLE creates a
presumption of labor-only contracting.
(https://ncr.dole.gov.ph/alien-employment-permit/;
https://car.dole.gov.ph/news/department-order-number-174-17-and-labor-advisory-no-06-17/)

**India:** no work-authorization verification analogue for domestic hires.
Foreign nationals need an Employment Visa (MHA rules, salary threshold commonly
cited at US$25,000 with sectoral exceptions — verify against the current MHA
visa manual). EPFO requires UAN activation with Aadhaar-based OTP, employer-
driven for new joiners, with enumerated exemptions (Nov. 29, 2024 circular).
Aadhaar itself is restricted for private use: *K.S. Puttaswamy v. Union of
India* (2018) struck §57 of the Aadhaar Act, ending contract-based private
compulsion; the 2019 amendment's §4(4) plus the Good Governance Rules and their
31 Jan 2025 amendment reopened a narrow, approval-gated channel for private
entities on enumerated public-interest purposes. Commercial employment routing
is not an obvious fit. DPDP Act 2023 treats employment-purpose processing as a
ground independent of consent, which is favorable — but the exact statutory
provision should be pulled directly rather than relied on from commentary.

### 2.4 The design question, answered

**Verdict: work-authorization lives in the ledger as a jurisdiction-scoped,
coarse, expiring, party-attested confirmation — with a hard rule that it is
consumed post-selection, never as a routing filter.**

Arguments for keeping it vertical-local, and why they do not win:

- *Non-delegable I-9 liability.* True, and it means the examining act should
  happen under a documented agency relationship with the employer of record —
  it does not mean the *outcome* cannot be recorded centrally. E-Verify Employer
  Agents and electronic I-9 vendors already operate on precisely this liability
  allocation, lawfully, under §274a.2(e)–(i).
- *Data minimization.* Answered by granularity, not by location. A boolean plus
  jurisdiction plus expiry is less data than each vertical independently
  collecting and retaining document copies.

Arguments for centralizing, and the one that actually decides it:

- Standardizing what evidence is accepted *reduces* the unfair-documentary-
  practices surface, which is created by per-employer discretion about which
  documents to demand.
- A worker re-proving work authorization to every vertical is exactly the
  duplication the ledger exists to eliminate.

The tension with the sensitive-data payload ban is real and resolves cleanly on
granularity. `07` constraint 12 and design §2.2 ban education records beyond
credential name/issuer, government ID numbers, DOB, health, and criminal
proceedings from payloads. Immigration *documents* fall squarely inside that
ban; an immigration *conclusion* does not have to. Compliant shape:

```
work_authorization_attestation {
  jurisdiction:      ISO-3166 code          // scoped, never global
  authorized:        bool                   // no status narrative
  basis_class:       enum{unrestricted, time_limited, employer_sponsored}
  verified_at:       date
  expires_at:        date | null            // = underlying permit expiry
  issuer:            registered attesting party
}
```

Banned from this payload: document numbers, document images, visa category,
country of citizenship, nationality, status history. `basis_class` is
deliberately three-valued: an employer needs to know whether re-verification is
coming and whether sponsorship is implicated; it does not need the visa type,
and `employer_sponsored` deliberately does not identify the sponsor.

Expiry is bound to the permit's own end date, not a platform TTL, and expiry
re-opens the examination path rather than auto-renewing — stale attestations
relied on past legal validity are a known I-9 audit failure. Oregon SB 619 and
Delaware's DPDPA treat citizenship/immigration status as sensitive data
requiring opt-in consent, which is an independent reason to keep the field
coarse and to gate its disclosure through the existing party-level grant model
rather than exposing it in the default prior packet.

**The load-bearing rule is behavioral, not schematic:** the field must not be
readable pre-selection. Under the eTeam pattern, a filter that shapes which
opportunities a worker even sees is the violation. Reading the confirmation to
validate a placement already selected on non-citizenship criteria is not.

---

## 3. Sanctions and watchlist screening

### 3.1 Who bears it

**US.** OFAC prohibitions run against "United States persons" (31 CFR §560.314
and parallel definitions). The operative prohibition is on dealing — e.g.
31 CFR §594.204 prohibits transactions or dealings in blocked property
"including the making of any contribution or provision of funds, goods, or
services by, to, or for the benefit of any blocked person." Employing or paying
a blocked person is a provision of services within that text (plain-text
reading; I found no published OFAC enforcement action on a staffing/employment
fact pattern specifically, which is itself worth stating — OFAC's enforcement
history is weighted to banks, processors, insurers, and exporters).
(https://www.law.cornell.edu/cfr/text/31/594.204)

Liability is strict. Appendix A to 31 CFR Part 501 (Economic Sanctions
Enforcement Guidelines, Nov. 9, 2009) treats willfulness and recklessness as
General Factor A in *penalty* calibration, not as an element of the violation —
which is the regulatory basis for OFAC's consistent public characterization of
strict liability. There is no general codified screening mandate for
non-financial companies; the May 2, 2019 "Framework for OFAC Compliance
Commitments" sets five components (management commitment, risk assessment,
internal controls, testing and auditing, training) as expectation and as the
yardstick for penalty mitigation.
(https://ofac.treasury.gov/media/16331/download)

Entity-level exposure is broader than the SDN list: under OFAC's Revised
Guidance on Entities Owned by Blocked Persons (Aug. 13, 2014), an entity 50% or
more owned in aggregate by blocked persons is itself blocked without being
listed. So partner-entity ownership screening is a separate exposure from worker
screening — relevant to the trust registry, not just the person record.

**EU.** Council Reg. (EU) No 269/2014 Art. 2 freezes listed persons' funds and
economic resources and prohibits funds or economic resources being made
available "directly or indirectly, to or for the benefit of" them. The
Commission's 19 June 2020 Opinion reads "economic resources" broadly enough to
reach labour and services. Obligation falls on any person within EU
jurisdiction, again as a prohibition; express screening duties are codified only
for credit and financial institutions. The EU Best Practices (Council doc
10572/22, updated 2024) moved the ownership/control threshold from "more than
50%" to "50% or more," aligning with OFAC — guidance, not binding text.

**UN, PH, India.** UNSC resolutions (1267/1989/2253; 1373) bind member states,
not private parties directly; private duties arise through national
implementation. Philippines: RA 10168 and RA 11479 give the ATC designation
authority with AMLC implementing freezes; the freeze obligation is understood to
reach all persons holding relevant property rather than only AMLA "covered
persons" — probable but not verified against primary text (the AMLC 2021
Sanctions Guidelines URL 404'd; re-source from amlc.gov.ph). India: UAPA §51A
obliges freezing and prohibits any individual or entity from making funds,
assets, economic resources or related services available to listed persons —
broader than the regulated sector, per the MHA implementation order of 4 May
2023 (read via summary, not full text).

### 3.2 What partners will contractually demand

The demand does not arrive as statute. It arrives through **ISO/IEC 27001:2022
Annex A 6.1** (screening of personnel and relevant third parties, proportionate
to risk and access level, before access is granted) and **SOC 2 CC1.4** — the
audit frameworks a datacenter operator is certified against and must flow down
to workforce suppliers. Expect, in order of likelihood: identity verification to
a stated assurance level; sanctions/watchlist screening at onboarding with
periodic re-screen; criminal background screening scoped by access level; and
for controlled-technology environments, nationality-based access control.

Defense-adjacent work adds the sharpest conflict in this memo. ITAR deemed
export (22 CFR §120.50; "foreign person" at §120.62) and EAR deemed export
(15 CFR §734.13(a)(2), with §734.20 carve-outs) make release of controlled
technical data to a foreign person an export to their country of citizenship or
permanent residence — so nationality is a lawful input to a *specific
controlled-data access decision*. It is not a lawful input to hiring or
eligibility generally. DOJ IER's 31 March 2016 technical assistance letter
states export control creates no hiring requirement and no BFOQ for
citizens-only hiring; the remedy for a needed foreign-person hire is a
per-person export license. *DOJ v. SpaceX* (complaint filed Aug. 24, 2023,
alleging §1324b(a)(1)/(a)(6) violations from 2018–2022 citizens-and-LPR-only
hiring justified by export control) is the cautionary case — note a federal
court stayed DOJ's administrative proceeding in Nov. 2023 on separation-of-
powers grounds without resolving the merits, so it should not be read as
vindication.
(https://www.justice.gov/d9/2023-08/spacex_complaint.pdf)

Two adjacent models are worth knowing but are not vendor-addressable: NISPOM
(32 CFR Part 117) clearance eligibility is government-adjudicated via e-QIP —
a platform can at most carry clearance *status*, never conduct the
investigation; TWIC (49 CFR Part 1572) is the same pattern for maritime access.
CFATS' Personnel Surety Program authority lapsed 28 July 2023 and has not been
reauthorized, which shifts weight in the chemical-facility sector onto
facility-level and contractual screening.

### 3.3 May results be stored? Only pass/fail — and only if someone else screens

Three findings collide and resolve into one architecture.

First, **whoever runs the screen inherits the records.** 31 CFR §501.601
requires a full and accurate record of each transaction subject to the
regulations, available for examination **at least 10 years** after the
transaction, and for blocked property, the blocking period plus 10 years after
unblocking. §501.603 (blocking reports, 10 business days; annual reports as of
June 30 due September 30) and §501.604 (rejected-transaction reports, 10
business days) add affirmative filing duties. A ledger that performs SDN
comparison cannot discharge these from a pass/fail token.
(https://www.law.cornell.edu/cfr/text/31/501.601)

Second, **hit data is the worst possible payload content.** Name-based screening
produces heavy false positives from common names and transliteration variance —
exactly the population the ledger serves. An adverse "flagged" attestation
reaching a partner with no underlying data to rebut it is the FCRA-adjacent,
defamation-adjacent, §1324b-adjacent failure mode that `01` and `07` already
warn about, in its sharpest form.

Third, **reliance transfers nothing.** No OFAC regulation or FAQ establishes a
safe harbor for a party relying on a third party's screening result — a negative
finding stated explicitly because it is the crux. A partner that employs an SDN
is exposed regardless of what a ledger told it; a robust compliance program
mitigates penalty under Appendix A's general factors, not liability.

The architecture that satisfies all three is the one the ledger already uses for
identity verification: **buy the screen, store the attestation.** A registered
screening provider performs the comparison, holds the match data, and carries
its own §501.601/603/604 obligations. The ledger stores
`{issuer, list_scope, screened_at, result: clear|not_clear, expires_at}` with no
match detail. `not_clear` should route to human adjudication at the provider or
vertical, never render to a partner as a scarlet letter. And the attestation
should be marketed as *evidence that a screen was run*, never as transferred
compliance — because it cannot be.

### 3.4 Cadence

Defensible: screen at onboarding, re-screen on every list update, and re-screen
before each new placement into a regulated-industry engagement. The SDN list
updates irregularly, sometimes several times a week; quarterly or annual
re-screening is a materially weaker posture. This is examiner and industry
practice (the daily-refresh baseline comes from FFIEC BSA/AML expectations for
regulated financial entities), not a codified frequency for non-financial firms.
Keep continuous *criminal* monitoring on a separate track — it is FCRA-governed
in the US and reopens the adverse-action and dispute machinery discussed in
`01`, which sanctions screening does not.

---

## 4. Pricing the identity-provider option

This section scopes the option. It does not recommend exercising it.

**EU — eIDAS 2 (Reg. 910/2014 as amended by Reg. (EU) 2024/1183).** The ledger's
attestations map onto Electronic Attestations of Attributes. Issuing
*non-qualified* EAAs is essentially unregulated at EU level — no conformity
assessment, no supervisory notification — at the cost of the legal presumption
of authenticity that qualified attestations carry. Issuing *qualified* EAAs
(Arts. 45d–45f, Annex V) requires QTSP status: Art. 21 initiation with a
conformity assessment report to the national supervisory body, CAB reassessment
at least every 24 months (Arts. 20–24), Art. 24 identity-proofing obligations on
the QTSP itself, Art. 13 liability with reversed burden of proof, Art. 22
trusted-list inclusion and EU trust mark. Art. 45e obliges Member States to give
QTSPs electronic verification against national authentic sources for
public-sector-backed attributes — the real prize, and the reason to keep the
option open. **Cost is not publicly sourced:** no CAB publishes eIDAS assessment
pricing and ENISA's conformity-assessment report describes methodology only. Do
not carry a number into a board document without a quote.
(https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=OJ%3AL_202401183)

**EU relying-party registration is not part of the option — it is already due.**
Art. 5b requires relying parties accepting wallet-based attestations to register
in their Member State of establishment; Art. 5a requires Member States to offer
wallets by 31 Dec 2026, with registration infrastructure expected mid-2026.
Consuming EU wallet credentials in the buy posture triggers it.

**UK — DIATF / DVS.** The Data (Use and Access) Act 2025 (in force December
2025) gave the trust framework statutory footing and created the DVS register
and trust mark; the framework was renamed the UK digital verification services
trust framework, with v0.4 (gamma) operative through 2025 and a pre-release
v1.0 published March 2026 (recent — reconfirm currency before relying). The
directly relevant route is Home Office IDSP certification for right to work,
right to rent, and criminal record checks: certification by a UKAS-accredited
body, **4–8 weeks**, fee negotiated bilaterally and not published, validity up
to 2 years with annual surveillance audits, no cost to be listed. Note the
asymmetry: for right to work and right to rent, using a certified IDSP is
voluntary and Home-Office-recommended (the employer keeps liability regardless);
for DBS checks it is **mandatory**. If the product ever touches criminal-record
checking in the UK, certification stops being optional.
(https://www.gov.uk/government/publications/digital-identity-certification-for-right-to-work-right-to-rent-and-criminal-record-checks/digital-identity-certification-for-right-to-work-right-to-rent-and-criminal-record-checks)

**US — no issuer license; the cost is downstream and already attaches.** There
is no federal IDV licensing regime. Exposure is: FCRA, where CFPB Circular
2024-06 (Oct. 24, 2024) states that background dossiers and algorithmic scores
furnished to employers for hiring, promotion, or retention decisions are often
governed by FCRA and their providers may qualify as CRAs — which is the same
finding `01` reached by a different route, and which does **not** turn on buy vs.
build; and state biometric law if verification is ever performed in-house with
biometrics. Illinois BIPA (740 ILCS 14) carries a private right of action,
*Rosenbach v. Six Flags* (2019 IL 123186) removed the actual-injury requirement,
*Cothron v. White Castle* (2023 IL 128004) made each scan a separate violation,
and SB 2979 (Aug. 2024) prospectively collapsed repeat collections of the same
identifier by the same method into one violation. Texas CUBI (Bus. & Com. Code
§503.001) is AG-only at up to $25,000 per violation, with the Meta ($1.4B, July
2024) and Google ($1.375B, May 2025) settlements demonstrating appetite.
Colorado HB 24-1130 (effective July 1, 2025) is the one written for employees:
biometric consent may be a condition of employment only for secure facility
access, timekeeping, workplace safety monitoring, or public-safety emergencies.
I found no FTC or CFPB authority carving pure identity verification out of the
consumer-report definition; the argument is plausible from statutory text but
**is not sourced and should not be relied on**.
(https://www.consumerfinance.gov/compliance/circulars/consumer-financial-protection-circular-2024-06-background-dossiers-and-algorithmic-scores-for-hiring-promotion-and-other-employment-decisions/)

Note also the age-verification statutes as a template state legislatures now
reach for: Texas HB 1181 (upheld in *Free Speech Coalition v. Paxton*, 606 U.S.
___ (2025)) and Louisiana HB 142 impose *provider-level* prohibitions on
retaining identifying information after verification, with penalties reaching
$10,000/day, and Louisiana's version is non-waivable by contract. Not binding on
this product today; a plausible direction of travel.

**India — the cost is not the issuer regime, it is the consent-manager regime.**
Aadhaar authentication by private entities requires approval under §4(4) and the
Good Governance Rules as amended 31 Jan 2025, for enumerated public-interest
purposes that fit a commercial employment platform poorly; KUA/AUA/ASA
onboarding under the Aadhaar (Authentication and Offline Verification)
Regulations 2021 requires India-based compliant infrastructure, UIDAI
pre-approval for any Sub-KUA, and registered ASA partnerships (fees and
timelines not published). DigiLocker is the practical private-sector path. The
regime that actually matches an attestation broker is the DPDP Rules 2025
(notified 13 Nov 2025) **Consent Manager**: India-incorporated company, minimum
net worth ₹2 crore, fit-and-proper directors, registration with the Data
Protection Board, existing entities to register by 13 Nov 2026. A company
managing consent only for its own platform is a plain Data Fiduciary and does
not need this — but a cross-platform attestation broker is close to the
Consent Manager description, and this is the single India item most likely to
attach on the build path.

**Philippines — free.** RA 11055 §12 and EO 162 make PhilID/PSN sufficient proof
of identity for both government and private transactions, and private entities
are required to accept it. PSA operates PhilSys Check and National ID eVerify
free of charge for relying parties. There is no PH analogue to QTSP or IDSP
certification — the government occupies the issuer role, which makes PH the
cheapest jurisdiction to be a relying party and an uninteresting one in which to
become an issuer.

**Strategic read (inference).** Only the EU and UK charge for issuer status, and
the UK charge is small and fast. India charges for brokerage, not issuance. The
US charges nothing at the issuer layer and everything downstream, regardless of
posture. So the option is cheaper than it looks — and correspondingly, becoming
an issuer buys less insulation than it looks, because the expensive US exposure
(FCRA, state privacy) is invariant to the choice.

---

## 5. Bottom line

### 5.1 Trigger table

| # | Product evolution | Regime attached | Obligation | Design consequence |
|---|---|---|---|---|
| T1 | Ledger pays workers, holds escrow, or disburses on behalf of an EOR | US BSA (31 CFR §1010.100(ff)(5)); state MTL; PH/India/EU equivalents | MSB registration, AML program, SAR/CTR, state licenses | Prohibited. Fund movement never enters the ledger entity. Payment relationships stay vertical-local (founder decision 9 extended from schema to entity) |
| T2 | Ledger offers earned wage access / advances | CFPB advisory (not credit if "Covered EWA"); state EWA licensing (NV, MO, KS, SC, WI, AR, UT, IN) | State registration per jurisdiction | Separate legal entity if ever built; never inside the ledger |
| T3 | Ledger sells verification into FI onboarding | 31 CFR §1020.220 (bank's duty, not vendor's) | None direct; contractual diligence, evidence-quality warranties | Safe. Requires attestation-provenance auditability the design already has (spine, issuer, timestamp) |
| T4 | Work-authorization stored as attestation | 8 U.S.C. §1324b; Oregon SB 619 / Delaware DPDPA sensitive-data; GDPR Art. 5(1)(c); Dir. 2009/52/EC | Coarse field only; opt-in-grade consent in some US states; minimization | Jurisdiction-scoped boolean + basis_class + expiry. No documents, no nationality, no visa type |
| T5 | Work-authorization used to filter which work a worker is shown | 8 U.S.C. §1324b (eTeam pattern) | Civil penalties + back pay + monitoring | Hard prohibition: read post-selection only. Enforce in the read path, not policy |
| T6 | Ledger becomes the I-9 authorized representative for verticals | 8 CFR §274a.2(b), (e)–(i); E-Verify Employer Agent MOU | Per-employer agency agreements, electronic-I-9 audit trail, per-employer retrievability | Possible and lawful, but employer liability is non-delegable — requires indemnity and per-employer segregation of underlying evidence |
| T7 | Ledger performs sanctions screening itself | 31 CFR §501.601 (10-yr records), §501.603/§501.604 (10-business-day reports) | Direct, non-delegable OFAC recordkeeping and reporting | Do not. Buy screening from a registered provider; store pass/fail attestation only |
| T8 | Ledger stores screening hit detail | OFAC recordkeeping (on screener); FCRA-adjacent adverse-info exposure; PH DPA §34(e) | Retention duty + dispute/adverse-action surface | Banned from payload. `result` is `clear` / `not_clear`; `not_clear` routes to human adjudication off-ledger |
| T9 | Ledger routes into defense-adjacent or controlled-technology work | ITAR 22 CFR §120.50/§120.62; EAR 15 CFR §734.13; vs. §1324b | Nationality is a lawful input only to a specific controlled-data access decision | Nationality never enters the ledger. Access gating stays with the partner, per-person, per-engagement |
| T10 | Partner in a SOC 2 / ISO 27001 environment | ISO/IEC 27001:2022 Annex A 6.1; SOC 2 CC1.4 | Screening proportionate to access, evidenced pre-access | Attestation freshness and scope must be machine-readable and auditable; expiry is a first-class field |
| T11 | Ledger accepts EUDI Wallet credentials | eIDAS 2 Art. 5b | Relying-party registration in Member State of establishment | Calendar item, buy posture, from ~mid-2026 |
| T12 | Ledger issues qualified EAAs | eIDAS 2 Arts. 20–24, 45d–45f, Annex V | QTSP status, biennial CAB assessment, Art. 13 liability | Option only. Default is non-qualified EAA issuance, which is what the design already is |
| T13 | Ledger brokers attestations across parties in India | DPDP Rules 2025 Consent Manager | India-incorporated entity, ₹2 crore net worth, DPB registration | India entity structuring decision, not a schema decision |
| T14 | PH vertical supplies workers to a principal that directs the work | DOLE D.O. 174-17 | Contractor registration; else presumption of labor-only contracting and principal deemed employer | PH vertical must be a registered, capitalized contractor, or the structure collapses |

### 5.2 Design constraints for the design/counsel pipeline

**C1 — No funds, ever, in the ledger entity. [COUNSEL-LATER; DESIGN-NOW]**
Extend founder decision 9 from "no economics in the schema" to "no money through
the entity." This single rule holds the entire AML perimeter in four
jurisdictions and costs nothing today. Revisit with counsel only when a payment
product is actually proposed.

**C2 — Work-authorization is a coarse, jurisdiction-scoped, expiring attestation
with a banned-field list. [COUNSEL-NOW]** Field shape as specified in §2.4.
Counsel-now because the field set must be right before the first US worker's
status is recorded, and because Oregon/Delaware sensitive-data consent
mechanics affect the onboarding consent flow (design §8.2), not just storage.

**C3 — Work-authorization must be unreadable pre-selection. [COUNSEL-NOW]**
Enforce in the read path: work-authorization is excluded from the default prior
packet and released only against a specific engagement already selected on
non-citizenship criteria. This is the eTeam constraint and it is an access-
control rule, not a policy. Counsel-now because the mitigation is architectural
and retrofitting it after routing volume exists is expensive.

**C4 — Sanctions screening is bought, never performed. [COUNSEL-LATER]** The
ledger registers screening providers as attesting parties (same registry, same
signature scheme, per design §1.2) and stores
`{issuer, list_scope, screened_at, result, expires_at}`. No hit detail. This
keeps 31 CFR §501.601's 10-year retention and §501.603/604's reporting duties
with the provider. Counsel-later: the decision is architectural and clear;
counsel is needed on provider contract terms, not on whether to do it.

**C5 — Attestations are marketed as evidence, never as transferred compliance.
[COUNSEL-NOW]** No safe harbor exists for a partner relying on a third-party
pass/fail, and the same is true of I-9 delegation. Partner agreements must say
so explicitly. Counsel-now because it is a contract-drafting constraint that
must exist before the first external attesting party — the same timing as
constraint 11 in `07` (the qualified-privilege shield), and the two belong in
one drafting pass.

**C6 — Nationality and citizenship never enter the ledger. [DESIGN-NOW]** Not as
a field, not as a derived attribute, not as a `basis_class` value that discloses
it. Defense-adjacent access control stays with the partner as a per-person,
per-engagement export-licensing decision. This costs the product a partner
convenience and buys immunity from the §1324b/ITAR collision that caught SpaceX.

**C7 — Freshness and scope must be machine-readable on every verification-class
attestation. [DESIGN-NOW]** ISO 27001 Annex A 6.1 and SOC 2 CC1.4 audits ask
"was screening current at the time access was granted." The design already gives
verification attestations `verified_at` and `expires_or_decays_at` (§1.2);
extend the same discipline to work-authorization and screening attestations, and
make `list_scope` / `jurisdiction` explicit so a partner can prove sufficiency,
not just existence.

**C8 — PH vertical structure is a counsel question before it is a product
question. [COUNSEL-NOW]** D.O. 174-17's labor-only-contracting test (substantial
capital or investment; who controls the work) plus mandatory DOLE contractor
registration determines whether the PH vertical or its principal is the
employer. This does not touch the ledger schema; it determines who the attesting
party even is in the PH flows, which does.

**C9 — Verify the thin citations before anything is filed. [COUNSEL-NOW,
mechanical]** Named below in §5.3. Several load-bearing points in this memo rest
on secondary sourcing.

### 5.3 Confidence and known gaps

Well-sourced and settled: 31 CFR §1010.100(ff); §1020.220(a)(6); §501.601/603/
604; 8 CFR §274a.1(g), §274a.2(a)(1), (b), (e)–(i); Form I-9 authorized-
representative liability; the eTeam settlement facts and amounts; AMLR Art. 3's
omission of identity/staffing; RA 9160 §3(a) as amended by RA 11521; eIDAS 2
Arts. 5a/5b/20–24/45d–45f; UK IDSP certification mechanics; Illinois/Texas/
Colorado biometric law; PhilSys relying-party access.

Agency guidance, persuasive but not binding: FIN-2019-G001; OFAC's 2019
Framework and 2014 50-percent guidance; EU Best Practices 10572/22; CFPB
Circular 2024-06; CFPB's Dec. 2025 EWA advisory opinion; FFIEC-derived
re-screening cadence.

Inference, flagged: that eTeam extends to automated attestation-based routing
(no decided case); that an IDV vendor selling to banks is outside BSA (market
practice, no FinCEN statement found); that payroll is not federally money
transmission (silence plus the "integral to services" carve-out, no ruling);
that a pass/fail screening attestation is commercially sufficient for partners
(no authority either way).

Verify before filing: AMLR Art. 3's numbered paragraphs direct from EUR-Lex;
India PMLA notification S.O. 2036(E) from the gazette and PMLA text from
indiacode.nic.in; the reported 9 May 2023 India notification (unverified —
do not cite); RA 9160 §3(a) items (1)–(7) unredacted; the AMLC 2021 Sanctions
Guidelines (URL 404'd) for whether the PH freeze duty reaches all persons; MHA's
UAPA §51A order for the exact "any individual or entity" language; the exact
Aadhaar Act sections struck in *Puttaswamy* (secondary sources give inconsistent
numbers — §33(2)/§47/§57 vs. §32(2)); the current MHA employment-visa salary
threshold; state E-Verify mandate lists from primary statutes; the DPDP Act's
employment-processing provision from statutory text; per-Member-State EU rules
on retaining ID-document copies; the currency of UK trust framework v1.0.

Not researched: UK OFSI sanctions obligations; UK employment right-to-work
mechanics beyond IDSP certification; any jurisdiction outside the five in scope.

---

## Sources

- 31 CFR §1010.100 — https://www.law.cornell.edu/cfr/text/31/1010.100
- 31 CFR §1020.220 (CIP, reliance provision) — https://www.law.cornell.edu/cfr/text/31/1020.220
- 31 CFR §501.601 (10-year records) — https://www.law.cornell.edu/cfr/text/31/501.601
- 31 CFR Part 501 App. A (Enforcement Guidelines) — https://www.ecfr.gov/current/title-31/subtitle-B/chapter-V/part-501/appendix-Appendix%20A%20to%20Part%20501
- 31 CFR §594.204 (prohibited dealings) — https://www.law.cornell.edu/cfr/text/31/594.204
- FinCEN FIN-2019-G001 — https://www.fincen.gov/system/files/2019-05/FinCEN%20Guidance%20CVC%20FINAL%20508.pdf
- FinCEN FIN-2013-R002 — https://www.fincen.gov/system/files/administrative_ruling/FIN-2013-R002.pdf
- CSBS Model Money Transmission Modernization Act — https://www.csbs.org/sites/default/files/2023-02/CSBS%20Money%20Transmission%20Modernization%20Act.pdf
- CFPB EWA advisory opinion (Dec. 23, 2025) — https://www.federalregister.gov/documents/2025/12/23/2025-23735/truth-in-lending-regulation-z-non-application-to-earned-wage-access-products
- CFPB Circular 2024-06 — https://www.consumerfinance.gov/compliance/circulars/consumer-financial-protection-circular-2024-06-background-dossiers-and-algorithmic-scores-for-hiring-promotion-and-other-employment-decisions/
- Regulation (EU) 2024/1624 (AMLR) — https://eur-lex.europa.eu/eli/reg/2024/1624/oj/eng
- RA 11521 (PH AMLA amendment) — https://www.lawphil.net/statutes/repacts/ra2021/ra_11521_2021.html
- 8 CFR §274a.1 — https://www.law.cornell.edu/cfr/text/8/274a.1
- 8 CFR §274a.2 — https://www.law.cornell.edu/cfr/text/8/274a.2
- USCIS M-274 §2.0 (authorized representative, employer liability) — https://www.uscis.gov/i-9-central/form-i-9-resources/handbook-for-employers-m-274/20-who-must-complete-form-i-9
- E-Verify — staffing agencies must not selectively verify — https://www.e-verify.gov/about-e-verify/whats-new/reminder-staffing-agencies-must-not-selectively-verify-employees
- DOJ/IER eTeam settlement (June 20, 2024) — https://justice.gov/opa/pr/justice-department-secures-agreement-staffing-agency-resolve-immigration-related and https://www.justice.gov/d9/2024-06/eteam.pdf
- DOJ v. SpaceX complaint (Aug. 24, 2023) — https://www.justice.gov/d9/2023-08/spacex_complaint.pdf
- Directive 2009/52/EC (Employer Sanctions) — https://eur-lex.europa.eu/eli/dir/2009/52/oj/eng
- Directive 2008/104/EC (Temporary Agency Work) — https://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=OJ:L:2008:327:0009:0014:EN:PDF
- Council Regulation (EU) 269/2014 — https://eur-lex.europa.eu/eli/reg/2014/269/oj/eng
- EC Opinion on Art. 2 of Reg. 269/2014 (June 19, 2020) — https://finance.ec.europa.eu/system/files/2020-06/200619-opinion-financial-sanctions_en.pdf
- OFAC Framework for Compliance Commitments (May 2, 2019) — https://ofac.treasury.gov/media/16331/download
- OFAC 50 Percent Rule guidance — https://ofac.treasury.gov/faqs/399
- DOLE Alien Employment Permit / D.O. 221-21 — https://ncr.dole.gov.ph/alien-employment-permit/
- DOLE D.O. 174-17 — https://car.dole.gov.ph/news/department-order-number-174-17-and-labor-advisory-no-06-17/
- MHA UAPA §51A implementation order — https://www.mha.gov.in/sites/default/files/2023-05/ProcedureImplementationSection51A_04052023.pdf
- Regulation (EU) 2024/1183 (eIDAS 2) — https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=OJ%3AL_202401183
- ENISA, Conformity Assessment of QTSPs — https://www.enisa.europa.eu/publications/assessment-of-qualified-trust-service-providers
- Home Office IDSP certification guidance — https://www.gov.uk/government/publications/digital-identity-certification-for-right-to-work-right-to-rent-and-criminal-record-checks/digital-identity-certification-for-right-to-work-right-to-rent-and-criminal-record-checks
- DSIT, Announcing the 1.0 trust framework (Mar. 2026) — https://enablingdigitalidentity.blog.gov.uk/2026/03/03/announcing-the-1-0-trust-framework/
- Colorado HB 24-1130 — https://leg.colorado.gov/bills/hb24-1130
- Texas AG, Meta biometric settlement — https://www.texasattorneygeneral.gov/news/releases/attorney-general-ken-paxton-secures-14-billion-settlement-meta-over-its-unauthorized-capture
- Aadhaar (Authentication and Offline Verification) Regulations 2021 — https://uidai.gov.in/images/4_The_Aadhaar_Authentication_and_Offline_Verifications_Regulations_2021.pdf
- Aadhaar Good Governance Amendment Rules 2025 (PIB) — https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2098223
- DPDP Rules 2025, Schedule I-A (Consent Manager) — https://www.dpdpa.in/dpdpa_rules_2025/schedule1-A.htm
- PhilSys legal bases — https://philsys.gov.ph/legal-bases/
- National ID eVerify — https://everify.gov.ph/check
