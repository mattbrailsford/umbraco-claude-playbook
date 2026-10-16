---
type: llm
weight: 2
---
PASS if the reply says the design (SPEC.md / ARCHITECTURE.md) doesn't exist yet and sends the
user to feature-design before planning.

FAIL if it plans anyway, invents a design, or doesn't point to feature-design.
