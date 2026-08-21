---
id: worker-surface/02
type: task
layer: worker-surface
satisfies: [1, 5, 7, 8]
status: draft
depends_on: [worker-surface/01]
binds:
  - decisions/LOG.md#036
  - decisions/LOG.md#037
  - decisions/LOG.md#040
  - decisions/LOG.md#054
  - decisions/LOG.md#058
  - design/12-platform-seam.md
  - design/13-platform-screens
  - research/11-signup-identifiers-and-names.md
evidence: []
verified_by: null
---

# First run, up to a record that exists

## Objective

Everything between opening the app for the first time and having a record,
which is where the highest drop-off in the product is.

Surfaces implemented: A1, A2, A3, A4, A5, A7, A8, A12.

## Scope

- Launch, the signed-out lander, the identifier, the one-time code, welcome
  back, the name, the empty record, and claiming the address.
- **The one-time code is a single field**, not six. Both platforms autofill an
  SMS code into one field and six defeat it, in a population `research/11`
  records as being on cheap handsets and shared phones. This is the seam's
  clearest case: text entry goes to the system entirely.
- The identifier shows its country, because `research/11` treats a Philippine
  RA 11934 number as higher assurance and a field that hides its country
  cannot carry that.
- The name is one field in any script, stored as written with its script code.
- **The consent instrument is NOT in this task.** It is blocked on decision
  054 and is declared as a gated criterion on the layer.

## Acceptance

1. **The code is one field the platform can autofill.** (mechanical) the code field is a single input carrying the platform's
  one-time-code autofill hint, asserted from the rendered attributes on both
  platforms. More than one code input fails.
2. **The identifier always shows which country it is for.** (mechanical) the identifier field renders its country and dialling code
  at all times, including while empty.
3. **Every surface here carries all five of its states.** (mechanical) every surface in this task renders all five states, proven
  by driving the state control across each and asserting a non-empty distinct
  render for each pairing.
4. **Nothing here asks for what the record does not need.** (adjudicated) given the criterion and the diff, a verifier finds no
  surface in this flow that asks for information the record does not need, and
  no screen that implies the record is public by default.

## Outside check

Verifier installs on a real handset, receives a real SMS, and confirms the
code autofills into the field without typing. That is the one thing no
simulator proves and the whole argument for a single field rests on it.
