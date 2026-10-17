---
type: llm
weight: 2
focus: {source: file, path: client/src/campaigns/campaign-editor.element.ts}
---
Context: a backoffice user is an entity with its own key. Umbraco's convention for choosing
an entity is a picker: the chosen item shown as a ref (name, avatar or icon) with a button
that opens a modal to search or browse, as Umbraco's own user picker does.

PASS if the reviewer is chosen through a picker: Umbraco's user input element
(`umb-user-input`), the user picker modal (`UMB_USER_PICKER_MODAL` via the modal manager),
or an equivalent ref plus "Choose" button that opens a modal.

FAIL if the reviewer is chosen from a `<select>`, `uui-select` or `uui-combobox` filled
with users, or typed in as a key, name or email in a text box.
