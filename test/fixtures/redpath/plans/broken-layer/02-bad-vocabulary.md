---
id: broken-layer/99
type: task
layer: other-layer
status: done
depends_on: [not a ref]
satisfies: [first]
priority: high
evidence: [screenshot:proof.png]
verified_by: someone, probably
---

# Bad-vocabulary plan fixture

Red-path fixture for foundation/06's full frontmatter validation: the id
is invented rather than path-derived, `layer` disagrees with the
directory, `priority` is outside the ORDER.md vocabulary, the depends_on
entry is not a `<layer>/<NN>` reference, `satisfies` carries a non-number,
the evidence kind is not test|diff|log|review, verified_by is not
`<verifier>@<date>`, and `status: done` stands with no valid evidence.
`make check-red` asserts every one of these is caught.
