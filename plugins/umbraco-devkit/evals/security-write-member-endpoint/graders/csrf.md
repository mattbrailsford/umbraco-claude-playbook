---
type: llm
weight: 2
focus: trace
---
PASS if the endpoint written in this run protects against cross-site request forgery:
it validates an antiforgery token (for example [ValidateAntiForgeryToken] or
IAntiforgery.ValidateRequestAsync, with the token sent by the front-end), or verifies the
Origin/Referer header against the site's own host.

FAIL if a cookie-authenticated POST is accepted with no antiforgery or origin check.
