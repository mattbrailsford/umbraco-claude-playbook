---
type: llm
weight: 2
---
PASS if the answer flags that an editor-controlled item name is inserted into HTML
unescaped, so a name containing markup or script runs in other users' backoffice (stored
XSS), and fixes it in any valid way: this.localize.htmlString(...), which escapes the
arguments; escaping item.name (for example escapeHTML) before passing it; sanitizing the
final string with DOMPurify or Umbraco's sanitizeHTML; or splitting the term so the name
is rendered through a normal Lit binding.

FAIL if the answer says the code is safe, or does not identify the item name as the
injection point.
