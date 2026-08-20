---
id: broken-layer/03
type: task
layer: broken-layer
satisfies: []
status: done
depends_on: []
evidence: []
verified_by: null
---

# Done-without-evidence plan fixture

Red-path fixture: `status: done` with empty evidence and a null
verified_by. Both completion rules must fire. A completion claim with no
linked evidence does not stick, and only the verification recorder writes
done. `make check-red` greps for both messages by name.
