---
type: llm
weight: 2
focus: trace
---
Look at every test method written for tag-filters.

PASS if each test makes exactly one assertion: one `Assert.That`/`Assert.Throws`-style call (or
one fluent assertion), with no loop of assertions and no `Assert.Multiple` grouping several.

FAIL if any test makes more than one assertion.
