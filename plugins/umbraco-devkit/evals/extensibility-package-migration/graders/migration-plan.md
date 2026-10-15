---
type: llm
weight: 2
---
PASS if the answer uses one PackageMigrationPlan with chained To<T>() steps (each step a
PackageMigrationBase or AsyncPackageMigrationBase), and adds the version 2 change as a new
step at the end of that same plan. A step may build the schema in code or import an embedded
package.xml; either is fine. Registration can rely on Umbraco auto-discovering the plan, or
call builder.PackageMigrationPlans().Add<T>() in a composer.

FAIL if it does not use a PackageMigrationPlan at all (for example a startup component or
notification handler that checks "does it exist yet" on every boot), or uses a separate
plan per package version.
