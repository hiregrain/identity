# Decisions Log (green-path fixture: a deliberately marked gap passes)

## 001 — First entry (2026-01-01)

Body.

## 002 — Second entry (2026-01-02)

Body.

*Numbers 003 and 004 were never assigned. They were consumed in a
collision and lost in the reconciliation. The gap is permanent; do not
fill it.*

## 005 — Fifth entry (2026-01-05)

`make check-red` asserts checks/decisions-index.mjs passes this log: the
gap is explicitly marked never assigned, which is the one legal gap form.
