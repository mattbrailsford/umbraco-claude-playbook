---
type: llm
weight: 2
focus: trace
---
PASS if the code written in this run gives the delete action a stricter authorization
requirement than plain backoffice access (for example its own [Authorize(Policy = ...)]
naming a policy, or a section/permission-based policy such as access to the Settings
section), AND that policy either is one Umbraco already registers or is registered in the
package's code (AddAuthorization / AddPolicy in a composer).

FAIL if delete relies only on the controller's inherited backoffice access, or names a
custom policy that nothing registers.
