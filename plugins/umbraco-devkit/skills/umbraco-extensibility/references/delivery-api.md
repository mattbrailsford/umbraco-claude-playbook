# Delivery API support in a package

## *Contents*

- Read the docs first
- Does your property editor need Delivery API support?
- Writing the Delivery API converter
- Custom selectors, filters, sorters, and index fields
- Telling site owners what to do
- Testing
- Review checklist

Extends row 1 of the catalogue in `SKILL.md`, and adds the query extension points the
Content Delivery API has. For what a package must do so a headless site can use it, not for
building a headless front end.

## Read the docs first

The docs cover setup and the basic contracts well. Read them for the target major
(`umbraco-docs`) before anything here:

- [Content Delivery API](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/headless-and-apis/content-delivery-api):
  settings, API keys, preview, start items, `expand` and `fields`.
- [Custom property editors support](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/headless-and-apis/content-delivery-api/custom-property-editors-support):
  `IDeliveryApiPropertyValueConverter`, with a worked picker example.
- [Extension API for querying](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/headless-and-apis/content-delivery-api/extension-api-for-querying):
  `ISelectorHandler`, `IFilterHandler`, `ISortHandler`, `IContentIndexHandler`.
- [Protected content](https://docs.umbraco.com/umbraco-cms/develop-with-umbraco/headless-and-apis/content-delivery-api/protected-content-in-the-delivery-api).

This file covers what those pages leave to the package author. Cache levels for the converter
and Delivery API output caching are in `umbraco-performance`.

## Does your property editor need Delivery API support?

Yes, if its value converter returns anything richer than a plain value. Without
`IDeliveryApiPropertyValueConverter`, the Delivery API serializes whatever
`ConvertIntermediateToObject` returns. That's fine for an `int`, a `string`, or a small
record. It goes wrong for:

- `IPublishedContent`, `IPublishedElement`, or a model that holds one: the JSON follows every
  property and parent, so it's huge, slow, or fails on a cycle.
- A type that holds services, or fields only the server should see.
- A value the front end can't use as is, such as an internal id where it needs a route.

If the package supports a major where the site may run headless, decide this for every
property editor it ships, and record "plain value, no Delivery API converter needed" in
`DECISION-LOG.md` when that's the answer.

## Writing the Delivery API converter

Follow the built-in converters in the CMS source (`umbraco-cms-source`), such as
`ContentPickerValueConverter`. They settle the points the docs example leaves open:

- **A missing item returns `null`.** Picked content that's deleted, unpublished, or the wrong
  item type gives `null`, never a stub object with only an id.
- **Pass `preview` through** to every cache lookup (`GetById(preview, key)`). A converter
  that ignores it shows published content in preview, or draft content outside it.
- **Reuse the API's own builders.** Return `IApiContentBuilder.Build(content)` (or the media
  equivalent) for a picked item, not a custom shape. The front end then gets the same item
  shape the API uses everywhere, and expansion works the same way.
- **Shallow by default, full on `expanding`.** Return only what identifies the item when
  `expanding` is `false`. Add details only when the caller asked with `expand`. The expanded
  output must not be cached across requests (`umbraco-performance`).
- **Return a type you own.** `GetDeliveryApiPropertyValueType` should name a small public
  model in the package, not `object` or a type from a third-party library. It shows up in the
  OpenAPI schema, and changing it breaks every front end that reads it.
- **Treat the response shape as public API.** Renaming or removing a property in it is a
  breaking change, the same as a public C# signature (`umbraco-package-conventions`).
- **Respect culture.** If the property editor can vary by culture, read the value for the
  culture the request asked for. See row 1 in `content-and-routing.md`.

**Don't leak.** The converter decides what a public, unauthenticated endpoint returns. Leave
out internal ids the front end doesn't need, editor-only settings, and anything about members.
Don't follow a picked item past what the caller expanded. Protected content is only hidden if
the site turned on member authentication for the Delivery API, so a converter that inlines a
protected item's data bypasses that.

Nested values (a block inside a block, a picker inside a block) are converted by their own
converters. A package converter only shapes its own property's value.

## Custom selectors, filters, sorters, and index fields

**Registration.** All four interfaces are `IDiscoverable`, so Umbraco finds the classes by
type scanning. No composer call is needed. Checked in the CMS source for v17, v18, and the v19
beta.

**One handler per query string wins.** For each `fetch`, `filter`, or `sort` value, the API
asks the handlers in turn and uses the first whose `CanHandle` returns `true`. No match gives
a `400 Bad Request`. The order across packages isn't something a package controls, so:

- Prefix every query keyword with the package name: `myPackageCategory:shoes`, not
  `category:shoes`. A short, generic keyword can be claimed by another package or a later CMS
  version.
- Make `CanHandle` match only your own prefix, exactly.

**Index fields.** An `IContentIndexHandler` adds fields to the Delivery API index.

- Prefix field names with the package name too, for the same reason.
- Pick the `FieldType` by how the field is queried: `StringRaw` for exact match,
  `StringAnalyzed` for "contains", `StringSortable` for sorting text, `Number` or `Date` for
  ranges and sorting.
- Set `VariesByCulture` to match the property you read. `GetFieldValues` is called once per
  culture, with `culture` set to `null` for invariant content.
- Keep `GetFieldValues` cheap: it runs for every item on a rebuild (`umbraco-performance`).

**Query semantics to document for users.** Several values in one filter are OR-ed
(`filter=myPackageTag:a,b`). AND means repeating the filter. Sorting by a field only orders
items that have it, so pair a sort with a filter that guarantees the field.

**Search stack.** On v17 and v18 these run on the Examine `DeliveryApiContentIndex`. On v19
they run on Umbraco Search, with the same interfaces. Write against the Delivery API
interfaces, not Examine types, and the same code works on both.

## Telling site owners what to do

A package can't assume the site turned the Delivery API on. Put these in the package's docs:

- Which properties and query keywords the package adds to the Delivery API, with an example
  request and response.
- That the Delivery API index must be rebuilt after installing the package or upgrading to a
  version that changes its index fields. Until then, the new filters and sorts return nothing.
- What the response looks like with `expand` and without.

Don't rebuild the index from a package migration. On a large site, a rebuild is slow and the
site owner should choose when it runs.

## Testing

- **Converter:** unit test `ConvertIntermediateToDeliveryApiObject` with an existing item, a
  missing item, `preview` on and off, and `expanding` on and off.
- **Handlers:** unit test `CanHandle` with your keyword, a near miss, and a built-in keyword
  (it must return `false` for `name:asc`). Test the option the handler builds for a valid
  value and a malformed one.
- **End to end:** in a test site with the Delivery API on, rebuild the index, then call the
  query endpoint with the new filter and sort. Check the response against the OpenAPI schema
  at `/umbraco/openapi`.

## *Review checklist*

- Every shipped property value converter either implements
  `IDeliveryApiPropertyValueConverter` or has a recorded reason it doesn't need to.
- Missing items return `null`. `preview` reaches every lookup.
- The response type is a small package-owned model. No `IPublishedContent`, services, or
  editor-only data in it.
- Response shape changes are treated as breaking changes.
- Query keywords and index field names carry the package prefix. `CanHandle` matches only
  them.
- Index field types match how the fields are queried. `VariesByCulture` matches the property.
- The package docs tell site owners to rebuild the Delivery API index.
