---
type: llm
---
PASS if the section is added through `IUserGroupService` (add the allowed section to the
group, then `UpdateAsync`), so the CMS's user-group cache and notifications see the
change. It must not add the section twice if the group already has it.

FAIL if it inserts into the user-group-to-section table with raw SQL or `Insert`, or adds a
duplicate row when the section is already allowed.
