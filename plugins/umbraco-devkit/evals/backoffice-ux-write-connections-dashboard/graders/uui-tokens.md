---
type: llm
focus: {source: file, path: client/src/connections/connections-dashboard.element.ts}
---
PASS if the element's styles take colours and spacing from UUI custom properties
(--uui-color-*, --uui-size-*) or set none at all. Values like 0, 100%, or 1fr are fine.

FAIL if the styles hard-code a colour (a hex, rgb() or named colour) or pixel spacing where
a --uui-* token exists.
