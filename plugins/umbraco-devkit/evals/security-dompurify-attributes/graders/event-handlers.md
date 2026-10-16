---
type: llm
weight: 2
---
Context: the help text is written by editors and shown to other backoffice users, so it
must be sanitized. DOMPurify's default config strips unknown custom elements; allowing them
needs `CUSTOM_ELEMENT_HANDLING`, and an `attributeNameCheck` like `/.+/` also lets `on*`
event handlers (onclick, onmouseover) through on those elements.

PASS if the final code sanitizes the markup before rendering it as HTML, keeps the two
`my-pkg-*` elements, and does not let `on*` attributes through on them: for example an
`attributeNameCheck` of `/^(?!on)/`, a named list of allowed attributes, or `ADD_TAGS` /
`ADD_ATTR` with only the elements' own attributes.

FAIL if the markup is rendered without sanitizing, or the sanitizer config accepts every
attribute on the custom elements (`/.+/`, `/.*/`, or a function returning true), or
otherwise allows `on*` attributes.
