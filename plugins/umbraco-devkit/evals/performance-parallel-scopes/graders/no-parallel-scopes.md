---
type: llm
weight: 2
---
Context: each of the calls in `ReviewSummaryService.GetAsync` opens an Umbraco scope (the
repository through `IEFCoreScopeProvider`, the CMS services through `ICoreScopeProvider`).
Umbraco tracks the open scope per async flow in one stack and expects scopes to open and
close in strict order. Started together (`Task.WhenAll`, `Task.Run`, or starting a task
and awaiting it later) in the same execution context, they crash with "Scope X is not the
Ambient Scope Y", or join each other's transaction.

PASS if the final code does not run two scope-opening calls at the same time in the same
execution context. Any of these pass: keeping the calls awaited one after another and
explaining why they can't safely run in parallel (optionally speeding things up another
way, such as caching or a cheaper query); or running branches in parallel only with
`ExecutionContext.SuppressFlow()` (or an equivalent that gives each branch its own scope
stack), with each branch opening its own scope.

FAIL if the final code starts two or more of the scoped calls concurrently without
suppressing execution-context flow: `Task.WhenAll` over them, `Task.Run`, or starting one
task and awaiting it after another call.
