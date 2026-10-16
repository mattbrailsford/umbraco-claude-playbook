---
type: llm
weight: 2
focus: {source: file, path: client/src/sync/sync-dashboard.element.ts}
---
PASS if, while syncAll runs, the editor can see it's working (the button's waiting state,
a loader, or progress text) and can't start a second sync (the button is disabled or
ignores clicks while running).

FAIL if nothing changes on screen while the sync runs, or a second click starts another
sync.
