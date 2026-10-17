---
type: llm
weight: 2
focus: {source: file, path: client/src/customers/customers-dashboard.element.ts}
---
Context: the orders dashboard next to it uses a `uui-box` with a headline, puts its action
in the box's `header-actions` slot as a compact button, shows a `uui-table` edge to edge
inside the box (`--uui-box-default-padding: 0`), localizes every string through
`this.localize.term`, and spaces with `--uui-size-*` tokens.

PASS if the customers dashboard follows that pattern: a `uui-box` with a headline, the
Export action in the box header (the `header-actions` slot), the list as a `uui-table`
inside the box, UUI tokens for spacing and colour, and user-facing strings localized.

FAIL if it invents its own layout instead: a heading element (h1/h2) or custom header
bar with a separate button row, a plain `<table>` or a list of cards, hard-coded colours
or pixel spacing, or hard-coded English strings where the sibling localizes.
