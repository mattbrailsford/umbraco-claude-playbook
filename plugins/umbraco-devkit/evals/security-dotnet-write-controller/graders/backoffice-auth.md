---
type: llm
focus: trace
---
PASS if the controller written in this run inherits ManagementApiControllerBase (or carries
an explicit backoffice authorization policy), and no action is [AllowAnonymous].

FAIL if the controller can be called without backoffice authentication.
