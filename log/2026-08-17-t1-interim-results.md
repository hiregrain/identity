# T1 spike: interim results (tasks 1–3, all cells verified)

Supervised run per decision 011. Every cell: blind implementation → first
judge run recorded → supervisor independently re-judged the artifact.
Harness: 48 golden vectors, discriminating judge (negative-tested),
reference implementation in Node. Model dimension added by founder
instruction mid-run.

## First-submission defects (primary metric): all cells

| Cell | First submission | Iterations | Lines | Verified re-judge |
|---|---|---|---|---|
| t1 Go Fable | 23/23, 0 defects | 1 | 238 | ✔ |
| t1 TS Fable | 23/23, 0 defects | 1 | 126 | ✔ |
| t2 Go Sonnet | 10/10, 0 defects | 1 | 339 | ✔ |
| t2 TS Sonnet | 10/10, 0 defects | 1 | 164 | ✔ |
| t2 Go Opus | 10/10, 0 defects | 1 | ~250 | ✔ |
| t2 TS Opus | 10/10, 0 defects | 1 | 120 | ✔ |
| t3 Go Sonnet | 15/15, 0 defects | 1 | 251 | ✔ |
| t3 TS Sonnet | 15/15, 0 defects | 1 | 159 | ✔ |
| t3 Go Opus | 15/15, 0 defects | 1 | ~190 | ✔ |
| t3 TS Opus | 15/15, 0 defects | 1 | 113 | ✔ |

**10/10 cells green on first blind submission. Zero defect-rate separation
by language or model tier.**

## Findings beyond the headline

1. **The boilerplate tax is real and language-shaped, the defect gap is
   not.** Go paid 1.7–2.1× the lines on canonicalization-heavy tasks
   (hand-implementing ECMAScript number formatting and UTF-16 key order,
   every Go cell hit both, every Go cell got both right). TS got JCS
   nearly free but hit its own frictions (raw Ed25519 key import via
   hand-built DER; typed code buying nothing at the trust boundary, where
   runtime guards are the whole story, the Opus TS implementer's phrasing).
2. **Every implementer independently invented differential self-testing.**
   Each wrote its own reference implementation (Python or Node) and
   cross-checked before first judge contact, unprompted. The AI-native
   perspective's verification architecture is apparently the natural
   behavior of competent agents, not an imposition.
3. **Honesty machinery worked.** One implementer (t2 Go Sonnet)
   self-disclosed a minor boundary slip (`ls` of a sibling directory,
   filenames only, no contents, measurement unaffected). One (t3 TS
   Opus) surfaced that its only pre-judge error was in its own hand-written
   test expectation, and precisely characterized the promotion-rule
   footgun for future implementers.
4. **Judge quirk:** the task-filter argument is ignored (all tasks always
   run); per-task lines remain correct. Harmless; fix if the harness is
   extended.

## Honest scope caveat

Tasks 1–3 are crypto primitives, the most specification-pinned work in
the kernel, where precision dominates and type-system differences matter
least. The D2 litigation's live question (discriminated unions vs. sealed
interfaces on the ledger's state machines; fold/projection ergonomics) is
tested by tasks 4–10, which need harness extension (state-machine
vectors, supersession folds, the deliberately underspecified task).
Interim read: **no evidence against Go; D2's pre-committed rule is
trending "Go stands"**, but the discriminating tasks have not run yet.
