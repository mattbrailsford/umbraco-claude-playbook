---
type: llm
---
PASS if the answer says the delete action needs a stricter, specific permission or policy
beyond plain backoffice access (for example a package-defined authorization policy, or a
section or user-group permission check).

FAIL if it treats backoffice login alone as enough for the delete, or does not discuss the
delete action's authorization.
