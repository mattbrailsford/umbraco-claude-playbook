---
type: llm
weight: 2
focus: trace
---
Context: sites upgrade from the v16 line to the v17 line. EF Core records each applied
migration by its ID. If v16's migration for this column has a different ID from v17's
`20260912103000_AcmeReviews_AddVerifiedAt`, an upgraded site runs the v17 migration again
and fails on the duplicate column. The v16 branch's different folders and namespaces don't
change this; the ID must still match.

PASS if the new migration files on this branch (outside `.worktrees/`), for both SQL Server
and SQLite, use the ID `20260912103000_AcmeReviews_AddVerifiedAt` in the `[Migration]`
attribute and the matching class/file name (namespace and folder adapted to v16's layout is
fine).

FAIL if either provider's migration gets a different ID, timestamp or name, only one
provider gets a migration, or the column is added to the entity with no migration.
