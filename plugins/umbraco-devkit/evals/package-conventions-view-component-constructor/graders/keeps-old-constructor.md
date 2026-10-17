---
type: llm
weight: 2
focus: {source: file, path: src/Umbraco.Community.Reviews/ViewComponents/ReviewsViewComponent.cs}
---
Context: the package is on NuGet and its README tells sites to inherit from
`ReviewsViewComponent` and call `base(reviewService)`. MVC creates view components through
`ActivatorUtilities`, which can't choose between two public constructors unless one has
`[ActivatorUtilitiesConstructor]`.

PASS if the existing `ReviewsViewComponent(IReviewService)` constructor is kept, marked
`[Obsolete]`, and still works for a subclass (it chains to the new constructor resolving
`IReviewSummaryService` through `StaticServiceProvider`, or resolves it later from
`HttpContext.RequestServices`), and, if there are two public constructors, the new one has
`[ActivatorUtilitiesConstructor]`. Also PASS if the constructor is left unchanged and the new
service is resolved lazily (for example from `HttpContext.RequestServices` inside
`InvokeAsync`), so there is still only one public constructor.

FAIL if the existing constructor is changed in place or removed (breaking subclasses that
call `base(reviewService)`), an optional or nullable parameter is added to it, or there are
two public constructors and neither has `[ActivatorUtilitiesConstructor]`.
