---
type: llm
weight: 2
focus: {source: file, path: client/src/settings/settings-view.element.ts}
---
Context: the backoffice has light and dark themes. Colours that should follow the theme
come from UUI custom properties (`--uui-color-*`). The existing info banner hard-codes hex
colours, so it breaks in dark mode.

PASS if the new warning banner's colours come from UUI colour tokens (for example
`--uui-color-warning`, `--uui-color-warning-standalone`, `--uui-color-warning-contrast`)
rather than hex, rgb or named colours. Leaving the old banner alone is fine; switching it
to tokens as well is fine. Using a UUI component with a warning look also passes.

FAIL if the new banner's background, text or border colour is a hard-coded hex, rgb() or
named colour (copying the info banner's approach).
