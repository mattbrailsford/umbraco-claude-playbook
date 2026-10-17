---
type: llm
focus: {source: file, path: client/src/subscribers/subscribers-list.element.ts}
---
PASS if, while no rows are ticked, the Unsubscribe action is disabled and says why (a
`title`/tooltip or visible hint such as "Select one or more subscribers first"), or is
hidden until a row is ticked.

FAIL if Unsubscribe is disabled with no explanation of why, or stays enabled and does
nothing (or shows an error) when nothing is ticked.
