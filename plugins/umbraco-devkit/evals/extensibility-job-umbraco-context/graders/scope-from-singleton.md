---
type: llm
---
Context: `OutOfStockFinder` is registered as scoped. Umbraco background jobs
(`IRecurringBackgroundJob`, `IDistributedBackgroundJob`) are singletons.

PASS if the job doesn't inject a scoped service straight into its constructor: it creates
a DI scope per run (`IServiceScopeFactory`), or the finder's registration is changed to a
lifetime a singleton can safely hold.

FAIL if the singleton job takes `OutOfStockFinder` (scoped) in its constructor unchanged.
