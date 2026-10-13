---
name: umbraco-performance
description: >-
  Keeping an Umbraco package fast on the sites that install it — reading published content
  from the cache instead of the services layer, tree traversal that doesn't walk the whole
  site, caching your own expensive lookups, property value converter cache levels, keeping
  hot paths (notification handlers, Examine events, startup) light, and backoffice screens
  that don't over-fetch. Use when writing or reviewing code that runs per request, per save,
  per indexed item, or at startup, or a backoffice screen that lists or searches data. For
  EF Core query shape (tracking, projection, one query per row), see `ef-core-data`; for
  when LINQ actually runs, see `dotnet-best-practices`.
---

# Performance for Umbraco packages

A package's code runs on sites its author never sees: a 50-page brochure site and a
200,000-node multi-site install get the same DLL. Write for the big one. Every rule below
is a pattern that's harmless on the demo site and costly in production.

Verify version-specific APIs against the CMS source and docs for the major the project
targets (`umbraco-cms-source`, `umbraco-docs`). The published content cache was rebuilt in
v15, so caching advice written for v13 and earlier is often wrong now. Search changes in
v19: Umbraco Search (`Umbraco.Cms.Search`) replaces the built-in Examine indexes and their
hooks. It's also an add-on for v17 and v18, so check which one the site uses, not just the
major.

## 🎯 Why: Design for Change

Slow code gets fixed by adding caches, and caches added late get bolted on in the wrong
place, with no plan for clearing them. Deciding up front where data is read from, and what
clears it, keeps a later speed fix a local change instead of a redesign.

## Read published content from the cache, not the services layer

The services layer (`IContentService`, `IMediaService`, `IRelationService` and friends)
reads and writes the database. It's for changing data, not rendering it. Anything that runs
per front-end request reads from the published cache instead:

```csharp
// Hits the database on every call
var item = _contentService.GetById(key);

// Reads the published cache
var item = _publishedContentCache.GetById(key);
```

The published cache is lazy-loaded: an item is read from the database the first time it's
requested, then served from memory. That makes the first read of a cold item a database
call too, which matters when a loop touches thousands of them (next section). For pages
that must be fast from first request, Umbraco's cache seeding (`ISeedKeyProvider`) preloads
chosen items at startup.

Source: [Common pitfalls](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/application-code/common-pitfalls),
[Cache seeding](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/cache/cache-seeding).

## Don't walk the whole tree

`Descendants()` / `DescendantsOrSelf()` visit every node below the starting point and load
each one. From the root, that's the whole site. A `.Where(x => x.Level == 2)` after it
still loads everything first:

```csharp
// Loads every node in the site to find a handful
var sections = root.DescendantsOrSelf().Where(x => x.Level == 2);

// Loads only the root's children
var sections = root.Children();
```

- Ask the navigation service tree questions. `IDocumentNavigationQueryService` (and its
  media counterpart) answers parent/child/descendant/ancestor questions from an in-memory
  structure of keys, without loading content. Filter by key and type there, then load only
  the items you need from the cache.
- Search the index, don't traverse. "Find every product with tag X" is a query, not a
  tree walk. On v19, or v17/v18 with the Umbraco Search add-on, get an `ISearcher` from
  `ISearcherResolver` and filter, sort and page in the query (`skip`/`take`). Without the
  add-on on v17/v18, query Examine.
- Store the result of a traversal you need twice. `Root()` walks up the tree each time it's
  called.
- A descendant walk is fine when the subtree is small by design (a settings folder, a
  three-level navigation). Say so in a comment, so a reviewer doesn't have to guess.

Source: [Common pitfalls](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/application-code/common-pitfalls),
[Umbraco Search](https://docs.umbraco.com/umbraco-search).

## Cache your own expensive lookups

Anything slow that a request repeats (a relation lookup, a call to an external API, a
computed aggregate) goes through Umbraco's `AppCaches`, not a static field or a private
`MemoryCache`:

- `AppCaches.RuntimeCache` (`IAppPolicyCache`) for values shared across requests, with an
  expiry.
- `AppCaches.RequestCache` for values reused within one request.

```csharp
var relations = _appCaches.RuntimeCache.GetCacheItem(
    $"MyPackage_ChildRelations_{key}",
    () => _relationService.GetByChildId(id, "umbDocument"),
    TimeSpan.FromMinutes(5));
```

- **Prefix every cache key** with your package name. The runtime cache is shared with core
  and every other package.
- **Decide what clears it, at design time.** An expiry alone means stale data for that
  long. If the data changes when your entity is saved, clear the key there.
- **Load-balanced sites need a cache refresher.** Clearing a key clears it on one server
  only. Route the clear through your package's `ICacheRefresher` so every server drops it
  (see `umbraco-extensibility`'s catalogue, row 4).

Source: [Accessing the cache](https://docs.umbraco.com/umbraco-cms/extend-your-project/server-side-extensions/cache/application-cache).

## Property value converters: set the cache level

`GetPropertyCacheLevel` decides how often a converter runs. Pick it deliberately:

| Level | Converted again when | Use for |
|---|---|---|
| `Element` | the owning page or block changes | the default; values that only depend on their own data |
| `Elements` | any content changes | values that reference other content (pickers) |
| `None` | every read | almost never; it's a large cost on every page view |

`PropertyValueConverterBase` returns `Snapshot`, which is obsolete and treated as `None`
by the current published cache. A converter that inherits the base class without
overriding `GetPropertyCacheLevel` runs its conversion on every read. Always override it.

Source: [Property value converters](https://docs.umbraco.com/umbraco-cms/extend-your-project/backoffice-extensions/property-editors/property-value-converters);
`PublishedProperty.GetCacheValues` in `Umbraco.PublishedCache.HybridCache`.

## Keep hot paths light

Some code runs far more often than it looks like it does:

- **Notification handlers** on save/publish run inside the editor's save. A bulk publish
  runs them once per item. Do slow work (external calls, reindexing your own data)
  after the save: queue it, or hand it to a background job.
- **Indexing code** runs once per item indexed, and a full rebuild runs it for every
  document and media item. With Umbraco Search, that's `IContentIndexer.GetIndexFieldsAsync`
  and `IPropertyValueHandler.GetIndexFields`. With Examine on v17/v18, it's
  `TransformingIndexValues` and similar events. A service lookup in there is one database
  call per item. Build fields from the content item you're handed. If you need related
  data, read it from the published cache or a cached lookup, not a service.
- **Startup** code runs on every app start, on every site that installs the package. Do
  work lazily, when it's first needed. Run one-time setup through a migration, which
  records that it ran, not a check on every boot.
- **Volatile data doesn't belong in content nodes.** Counters, form entries, logs and
  imported bulk data go in your own tables (`ef-core-data`). Content saves are slow by
  design: versioning, notifications, cache updates, reindexing.

Source: [Common pitfalls](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/application-code/common-pitfalls),
[Umbraco Search](https://docs.umbraco.com/umbraco-search).

## Backoffice screens: don't over-fetch

- **Page anything that can grow.** A list endpoint takes `skip`/`take` and returns a total;
  the screen pages it. Never load "all items" to show the first twenty. Collection views
  have paging built in; use it.
- **Debounce search-as-you-type.** Use `debounce` from `@umbraco-cms/backoffice/utils`, so
  a search fires when typing pauses, not on every key press.
- **Fetch once, share it.** Two elements on one screen that need the same data read it from
  a shared context or repository, not one request each.
- **Ask for what the screen shows.** A list endpoint returns list-sized models; the full
  detail model is for the detail screen.

## Reviewing a diff for performance

- A services-layer read (`IContentService`, `IMediaService`, ...) on a front-end request
  path.
- `Descendants()`/`DescendantsOrSelf()` from a root or other large node, without a comment
  saying why the subtree is small.
- A converter with no `GetPropertyCacheLevel` override, or one returning `None` without a
  stated reason.
- A cache added with no rule for what clears it, or cleared without a cache refresher on a
  package that supports load balancing.
- A cache key without the package prefix.
- A database or HTTP call inside a notification handler, a content indexer, a property
  value handler, an Examine event, or a loop over content.
- A list endpoint without paging, or a search box without a debounce.
