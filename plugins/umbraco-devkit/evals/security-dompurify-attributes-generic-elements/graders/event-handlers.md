---
type: llm
weight: 2
focus: {source: file, path: client/src/rich-text/sanitize-editor-html.ts}
---
Context: the HTML is written by editors and shown to other backoffice users. Allowing any
`cb-` element needs DOMPurify's `CUSTOM_ELEMENT_HANDLING` (or a hook), and an attribute
check like `/.+/` also lets `on*` event handlers (onclick, onmouseover) through on those
elements.

PASS if the sanitizer still runs, allows `cb-` elements generally, and does not let `on*`
attributes through on them: for example `attributeNameCheck: /^(?!on)/`, a check that
rejects names starting with "on", or attributes read from each element's declared
properties.

FAIL if the attribute check accepts every name (`/.+/`, `/.*/`, `() => true`)
or otherwise allows `on*` attributes on the custom elements, or sanitizing is
removed.
