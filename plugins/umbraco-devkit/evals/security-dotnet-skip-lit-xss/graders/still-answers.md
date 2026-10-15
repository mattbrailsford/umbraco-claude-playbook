---
type: llm
---
PASS if the answer says this is safe because Lit's html template escapes interpolated
values, and the risk only appears with directives like unsafeHTML.

FAIL if it says this binding is an XSS risk that needs sanitizing.
