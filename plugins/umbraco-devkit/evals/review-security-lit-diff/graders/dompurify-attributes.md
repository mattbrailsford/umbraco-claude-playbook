---
type: llm
---
PASS if the review flags that attributeNameCheck: /.+/ lets any attribute through on the
my-pkg-* elements, including on* event handlers, so the help text can still run script, and
suggests excluding on* attributes (for example /^(?!on)/) or an attribute allowlist.

FAIL if the review does not raise event handler attributes getting past the sanitizer.
