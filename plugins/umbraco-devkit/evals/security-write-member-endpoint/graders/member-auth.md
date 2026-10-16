---
type: llm
focus: trace
---
PASS if the endpoint requires a logged-in member and takes the member's identity from the
authenticated user, not from a value in the request body or query string.

FAIL if anonymous requests are accepted, or the member id comes from the request.
