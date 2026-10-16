---
type: llm
---
PASS if the review flags the delete modal: the import's fileName is inserted unescaped into
HTML through unsafeHTML around localize.string, so a file name containing markup is an XSS
risk, and suggests any valid fix (localize.htmlString, escaping the argument, sanitizing,
or a normal Lit binding).

FAIL if the review does not raise the unescaped fileName as a problem.
