---
name: umbraco-extensibility
description: >-
  Umbraco's own extension mechanisms, and how to build on them instead of inventing your own —
  Composer registration, collection-builder extensibility, notification handlers, and
  attribute-based discovery. Use when deciding how to make a feature extensible by other
  packages, or when writing/reviewing any code that plugs into Umbraco's startup pipeline. For
  general backend package conventions that aren't about extension mechanisms specifically
  (async naming, repository visibility, public-API compatibility), see
  `umbraco-package-conventions` instead. Complements `dotnet-best-practices` (general C#/.NET
  language discipline, not Umbraco-specific).
---

# Extending Umbraco, not just building on top of it

## 🎯 Why: Design for Change

Umbraco packages live a long time and get extended by code you'll never see. The mechanisms
below exist to keep the extension surface stable while the implementation behind it changes
freely. If a convention here doesn't make the *next* change (by you, or by a package consumer)
easier, it's the wrong convention for this project.

Umbraco itself is built from a small set of extension mechanisms. A package that reuses them
feels native; one that invents its own DI/config/plugin system feels bolted on. This skill
covers only those mechanisms — for the conventions that make a package well-behaved beyond its
extension points, see `umbraco-package-conventions`.

## Composers — your package's DI entry point

A `Composer` (implementing `IComposer`) is how a package registers itself into Umbraco's
startup pipeline, auto-discovered via assembly scanning. Keep one composer per package (or
per logical concern, if the package is large), and keep it thin — it wires things up, it
doesn't contain logic:

```csharp
public class MyPackageComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
    {
        builder.Services.AddSingleton<IMyPackageService, MyPackageService>();
        builder.MyPackageThings().Add<DefaultThing>();
    }
}
```

## Collection builders — how you make *your own* extension points

If other packages (or the same package's own future features) need to plug into yours,
expose a collection builder rather than a raw list or a config flag. This is the same
mechanism Umbraco itself uses for content finders, editors, and notification handlers:

```csharp
public class MyPackageThingCollectionBuilder
    : OrderedCollectionBuilderBase<MyPackageThingCollectionBuilder, MyPackageThingCollection, IMyPackageThing>
{
    protected override MyPackageThingCollectionBuilder This => this;
}

public static class MyPackageBuilderExtensions
{
    public static MyPackageThingCollectionBuilder MyPackageThings(this IUmbracoBuilder builder)
        => builder.WithCollectionBuilder<MyPackageThingCollectionBuilder>();
}
```

Consumers then get `builder.MyPackageThings().Add<Custom>().InsertBefore<Custom, Default>()`
instead of a config setting or a hardcoded `if`. Ordering via `Append()`/`InsertBefore<T>()`/
`InsertAfter<T>()` is more change-safe than an `Order` property on the interface — the
registration site controls ordering, not every implementation having to know its place.

## Attribute-based discovery, when the extension point is "plugins"

If your package supports pluggable implementations shipped as separate NuGet packages
(providers, connectors, adapters), prefer attribute + assembly-scan discovery over a config
list the consumer has to remember to update:

```csharp
[MyPackageProvider("cool-vendor", "Cool Vendor")]
public class CoolVendorProvider : MyPackageProviderBase { /* ... */ }
```

This is what lets `dotnet add package My.Package.CoolVendor` be the whole integration step —
no code change required in the consuming project.

## Notification handlers, not raw event subscriptions

If your package needs to react to Umbraco content/media/member lifecycle events, implement
`INotificationHandler<T>` and register it via the composer, rather than subscribing to a
static event. Handlers are testable in isolation and don't leak subscriptions across app
restarts.

## Scope note

This skill is Umbraco's extension mechanisms only. Async naming, repository visibility,
public-API backwards compatibility, and where extension methods live are general package
conventions, not extension mechanisms — that's `umbraco-package-conventions`.
