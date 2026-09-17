---
name: umbraco-extensibility
description: >-
  Umbraco's own extension mechanisms, and how to build on them instead of inventing your own —
  Composer registration, collection-builder extensibility, notification handlers,
  attribute-based discovery, repository access, and public-API backwards compatibility. Use
  when deciding how to make a feature extensible by other packages, or when writing/reviewing
  any code that plugs into Umbraco's startup pipeline. Complements `dotnet-best-practices`
  (general C#/.NET language discipline, not Umbraco-specific) — use both together for any
  substantial backend change.
---

# Extending Umbraco, not just building on top of it

## 🎯 Why: Design for Change

Umbraco packages live a long time and get extended by code you'll never see. The idioms below
exist to keep the extension surface stable while the implementation behind it changes freely.
If a convention here doesn't make the *next* change (by you, or by a package consumer) easier,
it's the wrong convention for this project.

Umbraco itself is built from a small set of extension mechanisms. A package that reuses them
feels native; one that invents its own DI/config/plugin system feels bolted on.

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

## Async method naming: `[Action][Entity]Async`

| Component | Description | Examples |
|---|---|---|
| Action | Verb | `Get`, `Create`, `Update`, `Delete`, `Save`, `Find`, `List`, `Validate` |
| Entity | Noun | `Profile`, `Connection`, `Item`, `Context` |
| Async | Suffix | Always required |

Qualifiers come after the entity: `GetItemByAliasAsync`, `GetAllItemsAsync`. Existence
checks: `[Entity][Qualifier]ExistsAsync` (e.g. `ItemAliasExistsAsync`).

This is the dominant shape across real Umbraco service interfaces, though not universal —
treat it as a strong default, not a rule worth blocking a PR over on its own.

## Repository access: internal to the owning service, as a strong default

Repositories should be `internal` to the persistence assembly. Only the entity's own service
may touch its repository — controllers and other services go through the service layer:

```
Controller / other service ──▶ EntityService ──▶ EntityRepository (internal)
```

This keeps caching, validation, and business rules in one place (the service), and stops a
future refactor of the repository from becoming a breaking change for anyone but that one
service. Not a strict law — a repository can be `public` if something outside the normal
service layer (diagnostics, a health check) genuinely needs to reach it directly. Default to
`internal`; make a repository `public` only for a specific, nameable reason, not by omission.

## Public API backwards compatibility

Never break a public method's signature outright. When a new version needs new parameters,
keep the old signature and have it **proxy** to the new one, resolving the new parameter via
DI/service location if it can't be threaded through the call site:

```csharp
// Simple case — the new parameter has a sensible static default, no DI needed:
[Obsolete("Use GetItemAsync(id, options) instead. Will be removed in v19.0.0.")]
public Task<Item> GetItemAsync(Guid id) => GetItemAsync(id, ItemOptions.Default);

public Task<Item> GetItemAsync(Guid id, ItemOptions options) { /* real implementation */ }

// Harder case — the new logic genuinely needs a dependency the old call site never had,
// and the old method can't take a new constructor parameter without breaking every existing
// caller's `new MyService(...)` call. Resolve it via the static service provider instead:
[Obsolete("Use CreateAsync(item, permissionChecker) instead. Will be removed in v19.0.0.")]
public Task<Item> CreateAsync(Item item) =>
    CreateAsync(item, StaticServiceProvider.Instance.GetRequiredService<IItemPermissionChecker>());

public Task<Item> CreateAsync(Item item, IItemPermissionChecker permissionChecker) { /* real implementation */ }
```

Resolve via `StaticServiceProvider.Instance.GetRequiredService<T>()` inside the obsolete
overload, rather than duplicating the implementation, only when a static default genuinely
isn't available — a compile-time default parameter is always simpler when one exists.

Give consumers a real deprecation window — state the target version in the `[Obsolete]`
message. "Current major + 2" is a solid default; check the project's `CLAUDE.md` first and
follow whatever it actually states if it already commits to a different number.

## Extension methods

Keep them in a single, predictable namespace (e.g. `<RootNamespace>.Extensions`), not
scattered next to whatever class happened to need one first. A consumer should be able to
guess where to look.

## Multi-version support

If the package targets more than one Umbraco CMS major at once (common for anything with an
install base), keep each version line's branch independent rather than forward-merging, and
be explicit in `CLAUDE.md` about which major(s) are in active-feature phase vs.
security-patch-only vs. end-of-life — see Umbraco's own
[LTS/EOL policy](https://umbraco.com/products/knowledge-center/long-term-support-and-end-of-life/)
for the shape of that lifecycle. A fix developed against one version line usually needs
porting to the others; decide per-fix whether it applies, don't assume either direction.
