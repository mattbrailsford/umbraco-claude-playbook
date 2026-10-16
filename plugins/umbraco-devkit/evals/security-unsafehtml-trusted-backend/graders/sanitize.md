---
type: llm
weight: 2
---
PASS if the answer says this is an XSS risk because AI-generated and rich-text content are
not trusted just because they come through the package's own backend, and that the HTML must
be sanitized before unsafeHTML (for example with DOMPurify), or rendered without unsafeHTML.
Sanitizing on the server with an allow-list sanitizer is also acceptable.

FAIL if it agrees the content is trusted because it came from the package's own API, or
does not flag the unsafeHTML call.
