---
type: llm
weight: 2
---
PASS if the answer flags that attributeNameCheck: /.+/ accepts every attribute on the
allowed custom elements, including on* event handlers such as onclick or onmouseover, so
editor-written help text can run script (stored XSS), and fixes it by excluding on*
attributes (for example /^(?!on)/) or by allowing only a named list of attributes.

FAIL if the answer says the configuration is safe, or does not identify event handler
attributes on the custom elements as the problem.
