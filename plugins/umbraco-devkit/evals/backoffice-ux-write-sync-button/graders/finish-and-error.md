---
type: llm
weight: 2
focus: {source: file, path: client/src/sync/sync-dashboard.element.ts}
---
PASS if success is confirmed beyond the button returning to normal (a notification, a
success state, or the "last synced" line updating with the count), AND an error is shown
in words an editor understands with what to do next (for example try again, or check the
provider settings), not only the raw error.message.

FAIL if success gives no feedback, or an error is ignored or shown only as the raw
technical message.
