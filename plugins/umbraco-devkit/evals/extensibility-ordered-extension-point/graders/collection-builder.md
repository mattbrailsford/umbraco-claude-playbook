---
type: llm
weight: 2
---
PASS if the answer exposes the sections through an Umbraco collection builder (for example
OrderedCollectionBuilderBase plus a WithCollectionBuilder extension method on IUmbracoBuilder),
and other packages control position at registration with calls like Append, InsertBefore or
InsertAfter.

FAIL if ordering is driven by an Order or Priority property on the section interface, or if
the answer invents its own registry, plugin loader or config list instead of a collection
builder.
