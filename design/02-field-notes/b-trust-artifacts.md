# Field Notes B — Trust Artifacts

How trust, verification, and "permanent record" are rendered in shipped software.
Every note is grounded in a screenshot in `assets/b-trust-artifacts/`. Captured
2026-08-17 from live pages and official press/help imagery (Apple Newsroom,
GitHub, Mercury demo, LinkedIn Help, Flighty).

Sources per asset:
- `apple-wallet-*.jpg` — Apple Newsroom press images (2021/2022 ID-in-Wallet announcements)
- `github-*.png` — live github.com (microsoft/vscode, logged out)
- `mercury-*.png` — live demo.mercury.com (public interactive demo)
- `linkedin-verification-badge-inline.png` — LinkedIn Help article on verifications
- `flighty-passport-card-mrz.png` — flighty.com marketing page (real app render)

---

## Mechanisms

### 1. The credential is a card object, not a page section
`apple-wallet-id-card-hero.jpg` — The driver's license is a rounded-rect card
with fixed aspect ratio, full-bleed issuer artwork, and content pinned to the
card's corners: small-caps letterspaced category label ("DRIVER'S LICENSE") top
left, holder name bottom left, state seal bottom right. The card floats on a
flat neutral field with generous margin. Nothing else on the screen competes
with it. Mechanism: officialness comes from treating the credential as a
*physical artifact rendered on screen* — fixed geometry, corner-anchored
metadata, one card per viewport — not as a styled div in a scrolling list.

### 2. A seal that overlaps the artwork
`apple-wallet-id-card-hero.jpg`, `apple-wallet-add-id-seal-disclosure.jpg` —
The state seal is a circular stamp with radial text, rendered *on top of* the
card art, slightly rotated, partially transparent — like an ink stamp applied
after printing. It is the only element that crosses layout boundaries.
Mechanism: authority marks read as applied-to the artifact, not composed-with
it. A seal that sits inside the grid is decoration; a seal that violates the
grid is attestation.

### 3. Minimal data on the face, full data behind a gesture
`apple-wallet-id-card-hero.jpg` — The card face shows only "Mark P." — first
name, last initial. No DOB, no number, no address on the resting state.
Mechanism: the resting credential is a token; detail is disclosure-gated. The
absence of data on the face is itself a trust signal (it implies the real data
is protected somewhere beneath).

### 4. Name the verifier, itemize the disclosure
`apple-wallet-tsa-presentment-sheet.jpg` — At presentment, a sheet rises with:
(a) the requesting party's seal + full legal name ("Transportation Security
Administration"), (b) a white card listing *exactly* which fields will be
presented — Legal Name, Date of Birth, Sex, ID Number, State, Issue Date,
Expiration Date, Real ID Status, ID Photo — each with its own glyph, in a
two-column grid, (c) a physical confirmation ("Confirm with Side Button" with
an animated hardware diagram). Mechanism: trust in an exchange is rendered as
*who + what + deliberate act*, as three stacked zones. The field-level
itemization with per-field icons is the load-bearing device — it converts an
abstract "share my ID" into an auditable manifest.

### 5. Verification flows name the authority, not the platform
`apple-wallet-send-to-issuer-faceid.jpg` — The enrollment sheet is titled
"Send to Arizona MVD," not "Verify with Apple." It lists the three artifacts
being sent (front of license, back, selfie) as thumbnail rows, then gates
submission behind Face ID. `apple-wallet-add-id-seal-disclosure.jpg` shows the
same pattern in prose: "used by Apple *and your state issuing authority* to
prevent fraud," with a "See how your data is managed" link. Mechanism: the
platform renders itself as courier, the authority as counterparty. A
credential's issuer must be a named third party visible in the UI at both
enrollment and presentment.

### 6. Badge = claim; tap = evidence
`github-verified-commit-ledger.png`, `github-signature-popover-evidence.png` —
In the commit ledger, "Verified" is a small green-outlined pill, one per row,
right-aligned next to the SHA. Clicking it opens a popover containing the
actual evidence: green shield-check icon, plain-language method statement
("This commit was created on GitHub.com and signed with GitHub's verified
signature."), the GPG key ID in monospace, and a timestamp ("Verified on
Aug 17, 2026, 10:50 AM"), plus a "Learn about vigilant mode" link. Mechanism:
the badge itself is typographically quiet (outline pill, muted green, no fill,
xs type) — its credibility comes from being *backed*: every badge resolves to
key + method + time on demand. The pill is a handle to a proof, not the proof.

### 7. Verification state lives in the ledger row, not a summary
`github-verified-commit-ledger.png` — Each commit row carries its own
attestation pill at equal visual weight, repeated down the list. Unverified
commits would simply lack the pill — absence is the negative state; there is
no "unverified" badge. Mechanism: per-entry attestation, with silence as the
default. Rows earn a mark; nothing is stamped "unverified."

### 8. Inline, monochrome, name-scale identity badges
`linkedin-verification-badge-inline.png` — LinkedIn's verification badge is a
small gray shield-check *inline in the name line*, sized to the type, not a
colored medallion. The help doc's framing: clicking it "learn[s] more about
your active verifications" (identity / workplace / educational institution —
each with named third-party verifiers, e.g. CLEAR). Mechanism: badge scale and
color restraint correlate with credibility — a mark embedded in the identity
typography reads as a property of the person; a large colored medallion reads
as a property of the UI. And again: click-through to enumerated, dated,
third-party-named verifications.

### 9. The ledger renders state as color-of-amount plus pill-of-exception
`mercury-transactions-ledger.png` — Transaction rows: date | counterparty |
amount | account | method | attribution. Credits are green with explicit "+"
semantics, debits neutral dark with true minus sign, superscript cents. A
failed payment gets a red "Failed" pill AND its green amount struck through —
the money-state and the record-state are marked independently. Attribution is
per-row: "Alice C. ••1234", "Mary M. ••0332" — who acted, on which masked
instrument. A summary strip above (Net change / Money in / Money out) uses the
same color code. Mechanism: a trustworthy ledger colors the *value*, pills the
*exception*, and attributes the *actor* on every row; nothing is deleted,
failures stay visible with strikethrough rather than removal.

### 10. Masked numbers as a security texture
`mercury-accounts-vault.png`, `mercury-transactions-ledger.png` — Account rows
show "Checking ••1038" — two bullets + last 4, everywhere a number appears.
The headline balance carries a small blue shield-check seal directly appended
to the figure. Mechanism: partial redaction (••) used consistently is a
*visible act of protection* — it communicates vault without a single lock
illustration. Attaching the assurance seal to the number itself (not in a
footer) binds the guarantee to the thing guaranteed.

### 11. Movement between accounts rendered as a two-node timeline
`mercury-tx-detail-timeline.png` — A transfer's detail panel shows a vertical
timeline: origin node (gray dot, "Ops / Payroll", timestamp) connected by a
line to destination node (blue dot, timestamp). Amount in large type above.
Mechanism: provenance = nodes + connector + timestamps, even for a two-step
event. The timeline idiom scales to any "who did what, when" history.

### 12. Machine-readable texture as officialness typography
`flighty-passport-card-mrz.png` — Flighty's "My Flighty Passport" card
borrows passport furniture: small-caps letterspaced labels ("FLIGHTS",
"FLIGHT DISTANCE"), tabular stat numerals, trilingual caption ("PASSPORT ·
PASS · PASAPORTO"), and a literal MRZ strip (`2023<<MARKUS<<<<MEMBER12AUG19<`)
along the bottom edge in monospace. Mechanism: document-grade typography —
small-caps microlabels, tabular figures, monospace machine-readable strips —
imports state-document authority into a consumer stat card. Playful data
(flight counts) reads as "on the record" because it is typeset like a treaty
document.

### 13. Completion is a checkmark plus the artifact, nothing else
`apple-wallet-id-card-hero.jpg` (watch) — The Apple Watch confirmation is the
card thumbnail with "✓ Done" beneath it on black. The phone shows a quiet
notification card: issuer icon + "Your driver's license is ready to use."
Mechanism: the completion moment shows the *artifact in its final home* with a
minimal past-tense confirmation. No confetti; the reward is the object itself
existing.

---

## What makes a credential on a screen read as REAL vs. cosplay

Argued only from the captures above.

**Real:**
1. **A named counterparty other than the platform.** Arizona MVD, TSA, CLEAR,
   a GPG key ID. In every convincing screen, the authority is a third party
   with a name, a seal, or a key — the platform presents itself as carrier.
   (apple-wallet-send-to-issuer-faceid.jpg, apple-wallet-tsa-presentment-sheet.jpg,
   github-signature-popover-evidence.png, linkedin-verification-badge-inline.png)
2. **Every mark resolves to evidence.** GitHub's pill opens method + key +
   timestamp; LinkedIn's shield opens enumerated verifications; Apple's sheet
   itemizes fields. The mark is a handle; tapping it must produce specifics.
   A badge that opens nothing is cosplay by definition.
3. **Restraint at rest, detail on demand.** "Mark P." on the card face;
   ••1038 on the account row; a quiet outline pill in the ledger. The real
   ones under-display. Cosplay over-displays: big gold borders, filled
   medallions, data plastered on the face.
4. **Marks that break the grid.** The state seal overlapping card art at a
   slight rotation reads as applied attestation. Everything laid out neatly
   inside the component grid reads as designed by the same hand that designed
   the claim — self-issued.
5. **Document typography.** Small-caps letterspaced category labels, tabular
   numerals, monospace for keys and MRZ strips, superscript cents. The
   typographic registers of passports, ledgers, and cryptography carry
   authority; rounded friendly type carries none of it.
6. **Time is always attached.** "Verified on Aug 17, 2026, 10:50 AM", issue/
   expiration dates in the TSA manifest, timestamps on both timeline nodes.
   A record without a timestamp is an image; with one it is an entry.
7. **The negative state exists and is honest.** Failed payments stay in the
   ledger, struck through and pilled — not removed. Unverified commits
   simply lack the pill. A system that visibly retains its failures earns
   trust in its successes; a system where everything is "verified" verifies
   nothing.
8. **Ceremony at the moment of commitment.** Face ID before sending to the
   MVD; double-click side button to present; "✓ Done" only after. A physical
   or biometric act, then a past-tense confirmation showing the artifact in
   its home. Cosplay skips the ceremony and jumps to celebration.
