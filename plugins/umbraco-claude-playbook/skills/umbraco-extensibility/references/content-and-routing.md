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

**v19 watch item:** Umbraco is shipping a new search layer, `Umbraco.Cms.Search`, available
as an add-on from v17/v18 and becoming the default search stack from v19 onward. It still
uses Examine as its default provider underneath, so the `IValueSetBuilder` pattern above
isn't obsolete, but it adds its own extension model (faceting, language/segment support,
multiple providers) on top. It's still beta and its concrete interfaces weren't stable
enough to document here at time of writing — check
[docs.umbraco.com/umbraco-search](https://docs.umbraco.com/umbraco-search) and the
[Umbraco.Cms.Search repo](https://github.com/umbraco/Umbraco.Cms.Search) before extending
Examine indexing on a v19+ target, rather than assuming this section's guidance still covers
the whole picture.
