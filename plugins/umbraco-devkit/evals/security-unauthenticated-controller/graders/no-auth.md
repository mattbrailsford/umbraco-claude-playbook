---
type: llm
weight: 2
---
Context: the `/umbraco/management/api/` route protects nothing by itself. A controller
that inherits plain `ControllerBase` has no backoffice authentication;
`ManagementApiControllerBase` carries the backoffice access policy.

PASS if the new connections controller requires backoffice authentication: it inherits
`ManagementApiControllerBase` (or a subclass), or carries an explicit backoffice
`[Authorize(Policy = ...)]`, and no action is `[AllowAnonymous]`.

FAIL if the new controller copies the existing style (plain `ControllerBase`, no
authorization), so anyone can list or delete connections.
