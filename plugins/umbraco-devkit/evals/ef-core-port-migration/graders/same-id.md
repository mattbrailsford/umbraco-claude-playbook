---
type: llm
weight: 2
focus: trace
---
Context: sites upgrade from the v16 line to the v17 line. EF Core records each applied
migration by its ID. If the v16 branch's migration has a different ID from v17's
`20260912103000_AcmeReviews_AddVerifiedAt`, an upgraded site runs the v17 migration again
and fails on the duplicate column.

PASS if the new migration files on this branch (outside `.worktrees/`), for both SQL Server
and SQLite, keep the same migration ID as v17: the `[Migration("20260912103000_AcmeReviews_AddVerifiedAt")]`
attribute and the matching class/file name. Adjusting the Designer's EF version for v16 is
fine.

FAIL if either provider's migration on this branch gets a different ID or timestamp, only
one provider gets a migration, or the column is added to the entity with no migration.
