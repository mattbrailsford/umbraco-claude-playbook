---
type: llm
---
PASS if the final answer (or the change) deals with the existing `order-summary.element.ts`
importing bare `lit`: it switches it to the backoffice's Lit, or tells the user it bundles a
second copy of Lit and should be switched. Removing `lit` from `dependencies` is a fine
extra.

FAIL if the existing element is left importing bare `lit` with nothing said about it.
