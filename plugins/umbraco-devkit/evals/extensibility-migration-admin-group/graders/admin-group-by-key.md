---
type: llm
weight: 2
---
Context: the Administrators group's int id is a database identity value. It is 1 on a
fresh install but not on every site, so a migration that assumes it hits a foreign-key error
or changes the wrong group, and a failing package migration leaves the site stuck
upgrading. The group's key (`Constants.Security.AdminGroupKey`) and alias
(`Constants.Security.AdminGroupAlias`, "admin") are the same on every site.

PASS if the new migration step finds the admin group by its key or alias (for example
`IUserGroupService.GetAsync(Constants.Security.AdminGroupKey)`, or a query on the alias),
and handles the group not being found by skipping rather than throwing.

FAIL if the code uses a hard-coded int id for the group (such as `userGroupId = 1` or
`WHERE id = 1`), or throws or fails the migration when the group is missing.
