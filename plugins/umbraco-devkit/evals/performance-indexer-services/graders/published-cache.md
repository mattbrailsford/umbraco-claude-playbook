---
type: llm
weight: 2
---
Context: a full rebuild touches every published page, which on a large site is tens of
thousands. `IContentService` and `IDataTypeService` go to the database on each call.

PASS if the rebuild reads published content from Umbraco's published content cache
(`IPublishedContentCache`, `IPublishedContentQuery`, `IDocumentNavigationQueryService` plus
the cache, or the UmbracoContext's content cache) rather than loading each page through
`IContentService`, and does not look up a data type from `IDataTypeService` for each
property of each page (it uses the published property type, or resolves data types once
and reuses them).

FAIL if the rebuild loads pages one by one or in pages through `IContentService`
(`GetById`, `GetPagedDescendants` or similar) and reuses the per-property
`IDataTypeService` lookup, or only adds parallelism or batching around those calls.
