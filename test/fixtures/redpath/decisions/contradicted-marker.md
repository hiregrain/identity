# Decisions Log (red-path fixture: marker contradicted by an entry)

## 001 — First entry (2026-01-01)

Body.

*Number 002 was never assigned. The gap is permanent; do not fill it.*

## 002 — Second entry (2026-01-02)

The marker above says 002 was never assigned, yet here it is;
`make check-red` asserts checks/decisions-index.mjs fails the contradiction.
