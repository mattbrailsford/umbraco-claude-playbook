# Content, routing, and search extension points

## Contents

- 1\. Property value converter
- 5\. Content finder
- 6\. URL segment provider
- 7\. Search indexing

Rows 1, 5, 6, 7 of the catalogue in `SKILL.md` — the extension points that define a
property's shape and sit between a request/query and the content it resolves to. A property
editor's own C# schema (`DataEditor`, `IConfigurationEditor`) is covered by the official
Backoffice Extension Skills plugin's `umbraco-property-editor-schema` skill, not here.

## 1. Property value converter

Write one for any property editor, built-in or custom — auto-registered by implementing the
interface, no explicit collection-builder call needed.

```csharp
public class RatingValueConverter : PropertyValueConverterBase
{
    public override bool IsConverter(IPublishedPropertyType propertyType)
        => propertyType.EditorAlias == "MyPackage.Rating";

    public override Type GetPropertyValueType(IPublishedPropertyType propertyType)
        => typeof(int);

    // Always set it; how to choose the level: umbraco-performance, "Property value converters".
    public override PropertyCacheLevel GetPropertyCacheLevel(IPublishedPropertyType propertyType)
        => PropertyCacheLevel.Element;

    public override object? ConvertIntermediateToObject(
        IPublishedElement owner, IPublishedPropertyType propertyType,
        PropertyCacheLevel referenceCacheLevel, object? inter, bool preview)
        => inter is string s && int.TryParse(s, out var value) ? value : 0;
}
```

If the property also needs to appear via the Content Delivery API, also implement
`IDeliveryApiPropertyValueConverter` (`GetDeliveryApiPropertyValueType` /
`ConvertIntermediateToDeliveryApiObject`) — it's a separate interface because the Delivery
API shape and the in-process `IPublishedContent.Value<T>()` shape are allowed to differ. When
a converter needs it, and how to write it, is in `delivery-api.md`.

**Content variation (culture/segment), not backoffice localization:** if the property editor
your converter targets can be set to vary by culture and/or segment, `propertyType.Variations`
tells you which, and reads go through `IPublishedContent.Value<T>()`'s own `culture`/`segment`
overloads rather than a fixed value — don't assume invariant. `VariationContext` (set via
`IVariationContextAccessor`) is what determines the "current" culture for a
request/render. This is Umbraco's *content* variation system — configured languages
(`ILanguageService`, replacing the obsolete `ILocalizationService`) and per-culture property
values — and it's a completely different mechanism from the official Backoffice Extension
Skills plugin's backoffice UI translation (`.json` lang files, `this.localize` in a Lit
element): one is about a content editor seeing different property values per language, the
other is about an editor seeing the backoffice's own buttons/labels in their language. Don't
conflate the two when writing or reviewing converter code.

## 5. Content finder

Implement `TryFindContent`, then insert into the ordered collection — order matters, first
match wins.

```csharp
public class MyContentFinder : IContentFinder
{
    public Task<bool> TryFindContent(IPublishedRequestBuilder request)
    {
        // inspect request.AbsolutePathDecoded / Uri, set request.SetPublishedContent(...)
        return Task.FromResult(false);
    }
}
```

```csharp
builder.ContentFinders().InsertBefore<ContentFinderByUrl, MyContentFinder>();
```

Pairs naturally with `IUrlSegmentProvider` (below) when a package changes how URLs are both
generated and resolved.

## 6. URL segment provider

```csharp
public class MyUrlSegmentProvider : IUrlSegmentProvider
{
    public string? GetUrlSegment(IContentBase content, string? culture = null) => null; // fall through to the next provider
}
```

```csharp
builder.UrlSegmentProviders().Insert<MyUrlSegmentProvider>();
```

## 7. Search indexing

Which API you extend depends on the search stack the site runs, not just the CMS major:

- **Umbraco Search** (`Umbraco.Cms.Search`) is built into v19 and replaces the built-in
  Examine indexes and their hooks (`IValueSetBuilder`, `TransformingIndexValues`). It's also
  an add-on for v17 and v18, with the same contracts under `Umbraco.Cms.Search.Core.*`
  namespaces instead of `Umbraco.Cms.Core.Search.*`.
- **Examine** is the built-in stack on v17 and v18 without the add-on.

A package supporting both needs both paths, behind its own seam. Check the project's
supported majors and whether it targets the add-on before writing either.

### Umbraco Search (v19, or v17/v18 with the add-on)

Three extension points, from lightest to heaviest:

- **`ContentIndexingNotification`** — cancelable, raised per item just before it's written.
  Handlers can add, remove or replace `Fields`, or set `Cancel` to skip the item. Reach for
  this to adjust what core already indexes.
- **`IContentIndexer`** — contributes fields for every content item indexed, alongside
  core's own system-field and property-value indexers. Reach for this to add derived fields
  (a computed price band, a flattened category path) to content.
- **`IPropertyValueHandler`** — turns one property's value into index fields. Reach for this
  when your package ships a property editor whose stored value isn't plain text.
  Auto-discovered (it's `IDiscoverable`); `CanHandle` picks the property types it owns.

```csharp
internal sealed class ProductSkuContentIndexer : IContentIndexer
{
    public Task<IEnumerable<IndexField>> GetIndexFieldsAsync(
        IContentBase content, string?[] cultures, bool published, CancellationToken cancellationToken)
    {
        if (content.ContentType.Alias != "product"
            || content.GetValue<string>("sku", published: published) is not { Length: > 0 } sku)
        {
            return Task.FromResult(Enumerable.Empty<IndexField>());
        }

        IEnumerable<IndexField> fields = [new IndexField("myPackageSku", new() { Keywords = [sku] }, null, null)];
        return Task.FromResult(fields);
    }
}
```

```csharp
public class MyPackageSearchComposer : IComposer
{
    public void Compose(IUmbracoBuilder builder)
        => builder.Services.AddTransient<IContentIndexer, ProductSkuContentIndexer>();
}
```

`IndexValue` has separate slots for each kind of value: `Keywords` for exact match,
`Texts`/`TextsR1`–`TextsR3` for full text (R1 ranks highest), plus `Integers`, `Decimals` and
`DateTimeOffsets`. Pick by how the field will be queried. Prefix custom field names with
your package name.

Indexing **data that isn't content** means registering your own index with
`IndexOptions.RegisterIndex<TIndexer, TSearcher>(alias)` (via
`builder.Services.Configure<IndexOptions>(...)`) and pushing documents through `IIndexer`
yourself. Query any index through `ISearcherResolver.GetSearcher(alias)`.

Indexer and handler code runs once per item, and a rebuild runs it for every item. Build
fields from the item you're handed; a service lookup in there is one database call per item.

Source: [Umbraco Search](https://docs.umbraco.com/umbraco-search),
`src/Umbraco.Core/Search/` in the CMS source on the v19 branch.

### Examine (v17/v18 without the add-on)

Two levels of override depending on how much control you need:

- Implement `IValueSetBuilder` to control what goes *into* an index — useful when a custom
  content type needs derived/computed fields indexed alongside its raw properties.
- Reconfigure an index's field definitions via `ConfigureNamedOptions<LuceneDirectoryIndexOptions>`
  in a composer, for cases that don't need a whole new value set builder.

```csharp
public class MyValueSetBuilder : IValueSetBuilder
{
    public IEnumerable<ValueSet> GetValueSets(params IContentBase[] contents)
        => contents.Select(c => new ValueSet(c.Id.ToString(), "content", c.ContentType.Alias));
}
```

To add fields to the built-in indexes, handle the index's `TransformingIndexValues` event
rather than replacing its builder. Reach for a full `IValueSetBuilder` only for your own
index, or when you're indexing something that isn't `IContentBase` at all.

Source: [Custom indexing](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/application-code/examine/indexing).
