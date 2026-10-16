---
type: llm
weight: 2
focus: {source: file, path: client/src/connections/connections-dashboard.element.ts}
---
PASS if choosing the content page uses a picker: Umbraco's document picker input
(umb-input-document) or the document picker modal (UMB_DOCUMENT_PICKER_MODAL), or an
equivalent ref-list plus "Choose" button that opens a modal. A plain select or text box for
the provider is fine.

FAIL if the content page is chosen from a <select>, uui-select or uui-combobox of pages, or
typed in as a key or name in a text box.
