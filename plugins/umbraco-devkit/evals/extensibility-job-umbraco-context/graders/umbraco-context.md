---
type: llm
weight: 2
---
Context: a background job runs outside any HTTP request, so there is no UmbracoContext.
`IUmbracoContextAccessor.TryGetUmbracoContext` returns false there, and `OutOfStockFinder`
as written returns an empty list every night. URL generation also needs an UmbracoContext.

PASS if, in the final code, the job's lookup actually gets content and URLs when no request
exists: for example the job (or the finder) wraps the work in
`IUmbracoContextFactory.EnsureUmbracoContext()` inside a `using`, or the finder reads
through `IPublishedContentCache` and builds URLs inside an ensured context.

FAIL if the job calls `OutOfStockFinder` unchanged (still depending on
`TryGetUmbracoContext`) with no ensured context, or creates a context without disposing
it, or stores an `IUmbracoContext` in a field.
