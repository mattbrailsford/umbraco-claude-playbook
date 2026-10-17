---
type: llm
weight: 2
---
Context: notes are written by editors and shown to other backoffice users, and markdown
passes raw HTML through, so the rendered HTML must be sanitized. Keeping the two
`notes-*` elements needs DOMPurify's `CUSTOM_ELEMENT_HANDLING` or `ADD_TAGS`/`ADD_ATTR`, and
an attribute check like `/.+/` also lets `on*` event handlers through on those elements.

PASS if the final code sanitizes the rendered markdown before it becomes markup, keeps the
two `notes-*` elements and their attributes, and does not let `on*` attributes through on
them: for example `attributeNameCheck: /^(?!on)/`, a check rejecting names starting with
"on", or `ADD_TAGS` plus `ADD_ATTR` listing only `user-key`, `display-name` and
`document-key`.

FAIL if the markdown output is rendered without sanitizing, or the sanitizer config accepts
every attribute on the custom elements (`/.+/`, `/.*/`, a function returning true) or
otherwise allows `on*` attributes.
