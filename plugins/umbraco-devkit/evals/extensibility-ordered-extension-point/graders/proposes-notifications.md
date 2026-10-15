---
type: llm
---
PASS if the answer, without being asked, also proposes at least one notification other
packages can handle (for example a PdfGenerating or PdfGeneratedNotification handled with
INotificationHandler<T>), tied to a moment in the PDF's lifecycle.

FAIL if notifications are not mentioned, or are only mentioned as something to add later.
