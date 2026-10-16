---
type: llm
weight: 2
---
Context: a full rebuild touches every published page, which on a large site is tens of
thousands. Umbraco's own index populators page through `IContentService.GetPagedDescendants`
with a published filter, so paged service reads are an accepted way to rebuild. What costs
is one database call per page or per property.

PASS if the rebuild reads pages in bulk (pages of `IContentService.GetPagedDescendants`, or
the published content cache) rather than one `GetById` per page, and does not call
`IDataTypeService` per property per page (it uses the published property type, or resolves
data types once and reuses them).

FAIL if it loads each page with its own service call, or keeps a per-property
`IDataTypeService` lookup inside the loop, or only adds parallelism around those calls.
