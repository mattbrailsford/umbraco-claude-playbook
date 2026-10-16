---
type: llm
---
PASS if the review flags that the AI summary is rendered with unsafeHTML without
sanitizing, explaining that model output is not trusted markup (it can echo content from
the page, including injected markup, so this is an XSS risk), and suggests sanitizing it
(DOMPurify, Umbraco's sanitizeHTML) or rendering it as text.

FAIL if the review does not flag the unsanitized summary, or accepts the "trusted markup"
comment.
