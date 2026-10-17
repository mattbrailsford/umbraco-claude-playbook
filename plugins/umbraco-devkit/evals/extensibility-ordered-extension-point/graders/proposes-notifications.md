---
type: llm
focus: trace
---
PASS if the change, without being asked, also adds or proposes at least one notification
other packages can handle (for example a PdfGenerating or PdfGeneratedNotification handled
with INotificationHandler<T>), tied to a moment in the PDF's lifecycle.

FAIL if notifications are not mentioned, or are only mentioned as something to add later.
