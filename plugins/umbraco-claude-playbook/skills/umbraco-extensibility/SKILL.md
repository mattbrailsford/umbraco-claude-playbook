---
name: umbraco-extensibility
description: >-
  Umbraco's own extension mechanisms, and how to build on them instead of inventing your own —
  Composer registration, collection-builder extensibility, notification handlers, and
  attribute-based discovery — plus a catalogue of the most common concrete, backend-side
  Umbraco CMS extension points (property value converters, Management API endpoints, content
  finders, URL segment providers, health checks, Examine indexing, and more). Use when
  deciding how to make a feature extensible by other packages, or when choosing which CMS
  extension point fits a given task. For general backend package conventions that aren't
  about extension mechanisms specifically (async naming, repository visibility, public-API
  compatibility), see `umbraco-package-conventions` instead. Anything already covered by the
  official Backoffice Extension Skills plugin — a property editor's Lit UI and its C# schema
  (`umbraco-property-editor-ui`, `umbraco-property-editor-schema`), dashboards, sections,
  trees — is deliberately left out here rather than duplicated. Complements
  `dotnet-best-practices` (general C#/.NET language discipline, not Umbraco-specific).
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

Don't confuse this with the official Backoffice Extension Skills plugin's
`umbraco-notifications` skill — that one is the backoffice's toast-style UI messages
(`UMB_NOTIFICATION_CONTEXT`), a completely different, frontend-only concept that just
happens to share the name.

## Catalogue: which CMS extension point for which job

Excludes anything the official Backoffice Extension Skills plugin already documents rather
than duplicating it: the Lit/UUI element and manifest for a backoffice-UI surface
(`umbraco-property-editor-ui`, `umbraco-dashboard`, `umbraco-sections`, `umbraco-tree`), and
the C# property editor schema itself (`umbraco-property-editor-schema` — covers `DataEditor`,
`IConfigurationEditor`, and even its own value converter example end to end). Property value
converters stay in this catalogue anyway, since you write one for any property editor,
built-in or custom, not only when authoring a new schema.

Signatures below can drift across Umbraco majors — this skill isn't version-pinned the way
the official plugin is, so check docs.umbraco.com against the target version before trusting
a base class or attribute shape verbatim. Full skeletons are in `references/`; read only the
file you need.

| # | Extension point | Interface / base class | Registered via | Reach for it when |
|---|---|---|---|---|
| 1 | Property value converter | `IPropertyValueConverter` (+ `IDeliveryApiPropertyValueConverter`) | auto-discovered | a property's stored value needs a typed shape at runtime |
| 2 | Management API endpoint | `ManagementApiControllerBase` | versioned route attributes | the backoffice needs to call your package's data |
| 3 | Health check | `HealthCheck` | `[HealthCheck]` attribute | a site builder should be able to self-diagnose your package's config |
| 4 | Cache refresher | `ICacheRefresher` | auto-discovered | your package's own entities need to stay in sync across a load-balanced site |
| 5 | Content finder | `IContentFinder` | `ContentFindersCollection` | resolving custom/virtual URLs to content |
| 6 | URL segment provider | `IUrlSegmentProvider` | `UrlSegmentProviders().Insert<T>()` | generating those same custom URL segments |
| 7 | Examine custom indexing | `IValueSetBuilder` | named options / composer | indexing something that isn't `IContentBase` |
| 8 | Custom file system | `IFileSystem` | `builder.SetMediaFileSystem()` (or similar) | media/files live somewhere other than local disk |

- **`references/content-and-routing.md`** — rows 1, 5, 6, 7.
- **`references/api-and-infrastructure.md`** — rows 2, 3, 4, 8.

## Scope note

This skill is Umbraco's extension mechanisms, and the concrete backend-side CMS extension
points built on them, only. Async naming, repository visibility, public-API backwards
compatibility, and where extension methods live are general package conventions, not
extension mechanisms — that's `umbraco-package-conventions`. Product-specific extension
points that other packages expose (an Umbraco Commerce payment provider, a Forms workflow
type, a Contentment data source) belong to *that* package's own docs, not here — this skill
is about what Umbraco CMS itself lets you plug into. Anything the official Backoffice
Extension Skills plugin already owns end to end — a backoffice-UI surface's Lit element and
manifest, and a property editor's C# schema (`umbraco-property-editor-ui`,
`umbraco-dashboard`, `umbraco-sections`, `umbraco-tree`, `umbraco-property-editor-schema`) —
is left to that plugin rather than duplicated here, even where the underlying code is plain
C#. A couple of names collide across the two plugins without meaning the same thing: that
plugin's `umbraco-notifications` and `umbraco-health-check` skills are both frontend/UI
concepts (toast messages, a health check's backoffice manifest), distinct from this skill's
`INotificationHandler<T>` and `HealthCheck` C# base class.
