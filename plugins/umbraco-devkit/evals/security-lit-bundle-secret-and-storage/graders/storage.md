---
type: llm
---
PASS if the answer flags storing the access token in localStorage as unsafe (readable by any
script on the page, for example after an XSS or from a compromised dependency), and suggests
keeping it out of browser storage (for example handling the vendor token server-side).

FAIL if it does not flag the localStorage token.
