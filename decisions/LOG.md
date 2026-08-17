# Decisions Log

Append-only, numbered. Reversing a decision means a new entry, never an
edit. Each entry links the evidence live at the time. Convention inherited
from Dispatch per `handoff/HANDOFF.md`.

---

## 001 — Repo seeded from the Dispatch handoff package (2026-08-17)

The company is the ledger; Dispatch is the first vertical (founder,
2026-08-17, closing Dispatch decision 46 via Dispatch decision 49). Handoff
package committed at `handoff/`. The ledger is the system of record for the
person; each vertical is the system of record for its work.

## 002 — Founder grilling: ten settled decisions (2026-08-17)

Recorded in `research/00-founder-grilling-2026-08-17.md`: internal-first
with day-one external compatibility; partners read AND write; universal
self-signup identity; worker as first-class user seeing all raw facts;
provenance grades on every claim; self-asserted claims editable until
verified then frozen; party-level disclosure control; recruiter-not-CRA
positioning assumption; no economics embedded; grain as context not
constraint.

## 003 — Founder rulings R1 and R2 after research review (2026-08-17)

R1: not a CRA; worker-owned platform model governs design (contrary FCRA
analysis in `research/01` stays on record as evidence and counsel input).
R2: whole-profile deletion at any time; verified records never editable.
Recorded in `research/00`, "Founder rulings" section.

## 004 — Independent design 0.1 adopted as the working design (2026-08-17)

`design/ledger-design-0.1.md`, produced clean-context per the handoff
protocol. Diff against Dispatch positions: `design/dispatch-diff-0.1.md` —
nine of eleven positions independently re-derived; positions 3 and 8
modified by rulings 003/002; one genuine disagreement (see 007).

## 005 — Stack litigation rulings ratified (2026-08-17)

`design/stack-litigation/docket-rulings-0.1.md` (ratification header):
D1 managed Postgres with four launch-blocking obligations; D2 Go core +
TS surfaces + generated contract layer, gated on the T1 spike; D3 day-one
WORM-anchored ≤5-min Merkle checkpoints launch-blocking, witnessed tile log
by registry-enforced first-external-party-or-1M deadline; D4 party-held
registry-grade keys, hosted worker/peer keys. Sub-rulings: countersignatures
contractually mandatory; bootstrap tier deferred to first external party;
"zero loss of acknowledged attestations" adopted as a party-facing
contractual promise; residency counsel opinion commissioned for
US + EU + PH + India; first external party NOT confirmed within ~2 quarters.

## 006 — Interface contract RATIFIED with amendments; ownership transfers here (2026-08-17)

Per `design/interface-verdict-0.1.md`: the two-object boundary, never-crosses
list, and no-shadow rules ratified as-is; open items resolved R-1..R-4;
amendments A-1..A-5 applied; binding interpretations N-1..N-3 adopted. The
amended contract is `model/attestation-interface.md`, schema_version 0.2.
Per `handoff/HANDOFF.md`, ownership of the standard transfers to this repo;
Dispatch's `model/attestation.md` becomes the conforming copy
(notice: `handoff/ratification-notice-for-dispatch.md`).

## 007 — Organizations are never subjects; any org may register as an attesting party (2026-08-17)

Founder ruling on the one genuine Dispatch disagreement (Dispatch open
question 9, Dispatch leaned customers-as-identities). Ledger-native entity
types remain exactly two: persons (subjects) and attesting parties
(issuers). A customer organization — e.g., an in-person electrician
training program a worker is routed to — registers as an attesting party
and writes performance attestations back; it never holds a subject profile.
Approval-authority needs are met by party-registry entries or
vertical-local records.

## 008 — Work-authorization attestations, post-selection-only (2026-08-17)

Founder ratified the `research/08` proposal: work-authorization status may
live in the ledger as a jurisdiction-scoped, expiring verification
attestation carrying only a boolean + coarse basis-class — never documents,
visa type, or nationality — and readable only AFTER candidate selection.
Access is architecturally incapable of influencing routing/selection
(the eTeam/§1324b constraint expressed as access control). Reflected in
`model/attestation-interface.md` §work-authorization.

## 009 — No identity-evidence retention across deletion; reportability hook stays (2026-08-17)

(a) No salted document-hash survives profile deletion — R2's spirit
controls; the Uber-style retain-and-flag alternative is rejected. Revisit
trigger: fresh-start fraud materializing at measurable rates. (b) The
policy-configurable reportability window on adverse content (default: no
limit applied) is retained as a read-path hook. Recorded as the founder's
"4. a" ruling interpreted as adopting the recommended defaults on both;
flagged for correction if misread.

## 010 — KYC posture (2026-08-17)

Per `research/08`/`research/09`, adopted as working posture (not all items
founder-ratified individually; 008 is the ratified core): sanctions
screening is bought like verification and only signed pass/fail is stored;
document images never enter the ledger (results-only vendor integration);
vendor pilots Sumsub (global primary) + Persona (US primary), India-native
rail at India launch; KYB for party vetting is manual registry checks +
notarized UBO self-attestation at current volume. OPEN (not yet ruled):
formalizing the no-money-movement red line at the entity level.
