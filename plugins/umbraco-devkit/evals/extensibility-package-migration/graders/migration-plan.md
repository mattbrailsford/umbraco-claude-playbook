---
type: llm
weight: 2
focus: trace
---
PASS if the code uses a PackageMigrationPlan (one plan for the package) with To<T>() steps,
each step a PackageMigrationBase or AsyncPackageMigrationBase, so the work runs once per
site and later releases can add new steps to the end of the same plan. A step may build the
schema in code or import an embedded package.xml; either is fine. Registration can rely on
Umbraco auto-discovering the plan, or call builder.PackageMigrationPlans().Add<T>() in a
composer.

FAIL if it does not use a PackageMigrationPlan at all (for example a startup component,
hosted service or notification handler that checks "does it exist yet" on every boot),
registers it with PackageMigrationPlans().Append, or says each later release should get its
own separate plan.
