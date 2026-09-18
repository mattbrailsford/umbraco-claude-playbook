# Content, routing, and search extension points

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

    public override object? ConvertIntermediateToObject(
        IPublishedElement owner, IPublishedPropertyType propertyType,
        PropertyCacheLevel referenceCacheLevel, object? inter, bool preview)
        => inter is string s && int.TryParse(s, out var value) ? value : 0;
}
```

If the property also needs to appear via the Content Delivery API, also implement
`IDeliveryApiPropertyValueConverter` (`GetDeliveryApiPropertyValueType` /
`ConvertIntermediateToDeliveryApiObject`) — it's a separate interface because the Delivery
API shape and the in-process `IPublishedContent.Value<T>()` shape are allowed to differ.

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

## 7. Examine custom indexing

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

Most packages should extend the *default* content value set builder's output (via a
notification handler on `Indexing*Notification` types) rather than replacing the builder
outright — reach for a full `IValueSetBuilder` only when you're indexing something that
isn't `IContentBase` at all.
