---
type: llm
weight: 2
focus: {source: file, path: client/src/campaigns/campaigns-dashboard.element.ts}
---
Context: an editor who narrows a long list down comes back to the dashboard later (another
section and back, or the next day). Losing the filter and sort each time is one of the
most common things sent back.

PASS if the chosen filter and sort survive leaving and coming back to the dashboard: kept
in `localStorage`/`sessionStorage`, in the URL (query string or path), or in user/session
state that outlives the element, and read back when the dashboard loads.

FAIL if the filter and sort live only in the element's own state, so they reset to the
defaults every time the dashboard is opened.
