---
type: llm
focus: {source: file, path: client/src/connections/connections-dashboard.element.ts}
---
PASS if the element shows that the list is loading while requestAll runs (a loader or
waiting state), and shows a message when requestAll or create returns an error.

FAIL if a slow requestAll shows nothing, or an error is ignored.
