---
type: llm
weight: 2
focus: trace
---
PASS if the final code exposes the sections through an Umbraco collection builder (for
example a class deriving from OrderedCollectionBuilderBase plus a builder extension method
on IUmbracoBuilder), the package registers its own sections through it, and other packages
choose the position at registration with calls like Append, InsertBefore or InsertAfter.

FAIL if ordering is driven by an Order or Priority property on the section interface, or if
the code invents its own registry, plugin loader or config list instead of a collection
builder.
