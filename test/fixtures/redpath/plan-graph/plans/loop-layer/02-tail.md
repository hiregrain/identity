---
id: loop-layer/02
type: task
layer: loop-layer
satisfies: []
status: ready
depends_on: [loop-layer/01, loop-layer/09]
evidence: []
verified_by: null
---

# loop-layer/02 (red-path fixture: task cycle, half two, plus a dangling ref)

loop-layer/09 does not exist and loop-layer is not draft, so the
reference is dangling; loop-layer/01 <-> loop-layer/02 is a task cycle;
loop-layer <-> tangle-layer is a layer cycle. `make check-red` asserts
checks/plan-graph.mjs fails all of them.
