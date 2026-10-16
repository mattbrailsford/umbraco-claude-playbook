---
type: llm
weight: 2
focus: {source: file, path: src/MySite/appsettings.json}
---
PASS if Umbraco:CMS:DeliveryApi in the file sets AllowedContentTypeAliases to a list
containing "article" and "author" (and nothing else is needed for new types to stay hidden).

FAIL if the file only uses DisallowedContentTypeAliases, invents a setting name, or doesn't
restrict the exposed document types.
