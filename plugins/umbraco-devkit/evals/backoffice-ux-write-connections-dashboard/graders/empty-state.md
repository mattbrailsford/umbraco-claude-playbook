---
type: llm
focus: {source: file, path: client/src/connections/connections-dashboard.element.ts}
---
PASS if, when there are no connections, the element renders an empty state that says no
connections exist yet and offers the way to add the first one, instead of an empty table.

FAIL if an empty list renders as a bare table or nothing.
