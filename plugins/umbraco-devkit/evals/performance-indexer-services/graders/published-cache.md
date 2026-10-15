---
type: llm
weight: 2
---
PASS if the answer identifies the per-record IContentService.GetById call and the
per-property IDataTypeService lookup as database work repeated for every page, and
recommends reading published content from Umbraco's published content cache (for example
IPublishedContent via IPublishedContentCache, IUmbracoContextFactory or a published
content query) and resolving data type information once, outside the loop, or from the
published property type.

FAIL if the answer does not call out the services-layer calls in the loop as the main
cost, or only suggests parallelising or batching the existing ContentService calls.
