---
type: llm
focus: trace
---
PASS if importing a Store file written before this change (with no TaxRegion or zones
element) still works: the new elements are read as optional, and a missing element keeps
the target's existing value or a default instead of throwing or wiping it.

FAIL if the new elements are read with a null-forgiving or required access that throws on
an older file (for example node.Element("TaxRegion")!.Value), or a missing zones element
clears the target's zones.
