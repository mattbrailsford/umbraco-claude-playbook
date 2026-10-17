---
type: llm
---
PASS if the Markdown is converted to HTML and sanitized (DOMPurify or an equivalent
sanitizer) before it is rendered with `unsafeHTML` or `innerHTML`.

FAIL if the converted HTML is rendered without sanitizing it.
