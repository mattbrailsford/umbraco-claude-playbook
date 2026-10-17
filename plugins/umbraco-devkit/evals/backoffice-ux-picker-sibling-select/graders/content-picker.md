---
type: llm
weight: 2
focus: {source: file, path: client/src/forms/form-settings.element.ts}
---
Context: a content page is an entity. Umbraco's convention is a picker (the chosen page as
a ref with a "Choose" button that opens a modal to search or browse the tree), not a
dropdown of every page. The existing "Thank you page" field uses a dropdown.

PASS if the new privacy policy page is chosen through a picker: `umb-input-document`, the
document picker modal (`UMB_DOCUMENT_PICKER_MODAL`), or an equivalent ref plus "Choose"
button that opens a modal. Switching the existing field to a picker as well passes, as long
as the new one is a picker.

FAIL if the privacy policy page is chosen from a `uui-select`, `<select>` or `uui-combobox`
of pages (copying the existing field), or typed in as a key.
