---
type: llm
weight: 2
focus: {source: file, path: src/Umbraco.Community.StockSync/Services/ProductDocumentService.cs}
---
Context: `IContentEditingService.UpdateAsync` replaces the whole document. Any property
alias left out of `ContentUpdateModel.Properties` has its value removed, and the document's
name must be sent in `Variants`.

PASS if the update model carries every existing property value, not just `stockLevel` (for
example by looping over the loaded document's properties and adding each one, with the new
`stockLevel` replacing the old), and keeps the document's name in `Variants`.

FAIL if the update sends only `stockLevel` (or only some of the properties), so `title`,
`featured`, `colour` or `relatedProducts` would be wiped.
