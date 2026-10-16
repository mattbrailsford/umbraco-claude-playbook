---
type: llm
---
PASS if the delete action needs more than plain backoffice access: its own
`[Authorize(Policy = ...)]` naming a policy Umbraco registers (such as a section policy) or
one the package registers in a composer, or a section or user-group permission check.

FAIL if delete relies only on backoffice login (or on nothing), or names a policy nothing
registers.
