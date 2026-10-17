---
type: llm
weight: 2
focus: {source: file, path: client/src/loyalty/loyalty-status.element.ts}
---
Context: this panel appears in a full-width workspace view and in the order workspace's
info sidebar, which is only about 300px wide.

PASS if the panel's layout fits both widths: it stacks (label/value rows in a column), or
adapts with a container query, a grid with `auto-fit`/`auto-fill` and a minimum width, or
wrapping flex. No fixed pixel widths.

FAIL if it forces a wide side-by-side layout (several fixed columns or a non-wrapping row
of blocks) with no container handling, sets a fixed pixel width, or only adapts with a
viewport `@media` query, or the file doesn't exist.
