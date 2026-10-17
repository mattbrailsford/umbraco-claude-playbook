---
type: llm
weight: 2
focus: trace
---
Context: the handlers import stores (1100) before countries (1110) and tax rates (1120). On a
new environment, when a store is imported, none of its tax rates exist yet.

PASS if the store's default tax rate is exported as the tax rate's Key (or another stable
value such as its alias), not its integer id, AND on import it is set once the tax rate
exists: a later pass, a step after tax rates import, or the tax rate import filling in the
store's default.

FAIL if the default tax rate is exported as the integer id, or is only looked up during the
store's own import (so on a new environment it's dropped, left empty, or fails the import),
with nothing to fill it in later.
