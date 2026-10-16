---
type: llm
focus: {source: file, path: src/Umbraco.Community.StockSync/Services/ProductDocumentService.cs}
---
Context: `IContentEditingService` runs each sent value through the property editor's
`FromEditor`, so values must be in editor format. The stored value from
`IContent.GetValue()` is a different shape for pickers, toggles and dropdowns (for
example a stored "umb://document/..." string or a JSON string, where the editor expects an
array).

PASS if the existing values are converted to editor format before being sent, for example
through each property's data editor value editor `ToEditor` (via `PropertyEditorCollection`
or `IDataValueEditorFactory`), or by another means that produces the editor shape.

FAIL if the stored values from `GetValue()` are copied into the update model as they are,
or if the code doesn't resend the other properties at all.
