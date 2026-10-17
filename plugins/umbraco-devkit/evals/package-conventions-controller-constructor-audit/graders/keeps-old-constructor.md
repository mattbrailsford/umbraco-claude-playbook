---
type: llm
weight: 2
focus: {source: file, path: src/Umbraco.Community.Coupons/Controllers/CouponController.cs}
---
Context: the package is on NuGet, and its 4.0.0 changelog says sites inherit from its public
controllers. ASP.NET Core creates controllers through `ActivatorUtilities`, which can't
choose between two public constructors unless one has `[ActivatorUtilitiesConstructor]`.

PASS if the existing `CouponController(ICouponService)` constructor is kept, marked
`[Obsolete]`, and still works for a subclass (it chains to the new constructor resolving
`ICouponAuditLog` through `StaticServiceProvider`, or resolves it later from
`HttpContext.RequestServices`), and, if there are two public constructors, the new one has
`[ActivatorUtilitiesConstructor]`. Also PASS if the constructor is left unchanged and the
audit log is resolved lazily from `HttpContext.RequestServices`, so there is still only one
public constructor.

FAIL if the existing constructor is changed in place or removed, an optional or nullable
parameter is added to it, or there are two public constructors and neither has
`[ActivatorUtilitiesConstructor]`.
