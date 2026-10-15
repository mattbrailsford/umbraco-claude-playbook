---
type: llm
weight: 2
---
PASS if the answer says the GET (and the PUT's response) send the real API key back to the
browser, that the password-style masking in the UI does not stop that, and that the response
must leave the key out or mask it on the server (for example a separate response model with
no key, or a "key is set" flag).

FAIL if it accepts the UI masking as enough, or does not flag the key in the response.
