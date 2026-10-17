---
type: llm
weight: 2
focus: {source: file, path: client/src/stock/stock-summary.element.ts}
---
Context: the same element renders in a wide workspace view and in the product workspace's
info sidebar, which is only about 300px wide. Four fixed columns side by side don't fit
the sidebar.

PASS if the layout adapts to the width it's given: a container query on the element, a
grid with `auto-fit`/`auto-fill` and a minimum column width, flex with wrapping, or an
explicit narrow layout, so the four figures reflow or stack in the sidebar.

FAIL if the four figures are forced into one row regardless of width (for example
`grid-template-columns: repeat(4, 1fr)` or a non-wrapping flex row with no container or
media handling), if it sets a fixed pixel width, or if it only adapts to the viewport
with a `@media` query (the sidebar is narrow on a wide screen too).
